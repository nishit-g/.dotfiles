import type { Plugin } from "@opencode-ai/plugin"
import { execSync, exec } from "child_process"
import { existsSync, readFileSync, appendFileSync, mkdirSync } from "fs"
import { homedir } from "os"
import { join } from "path"

const CONFIG_PATH = join(homedir(), ".config/opencode/notifier.json")
const CONFIG_LOCAL_PATH = join(homedir(), ".config/opencode/notifier.local.json")
const ASSETS_DIR = join(homedir(), ".config/opencode/plugin/assets")
const LOG_DIR = join(homedir(), ".local/share/opencode")

const loadConfig = () => {
  const defaults = {
    ntfy: {
      enabled: true,
      server: "https://ntfy.sh",
      topic: "chaosmonk-oc",
      auth: { enabled: false, username: "", password: "" },
      priority: { complete: 3, error: 5, permission: 4, question: 4 },
    },
    local: { enabled: true, sounds: true },
    rateLimit: { enabled: true, minInterval: 5000 },
    logging: { enabled: true },
    focusMode: { enabled: false, start: 22, end: 8 },
    webhook: { enabled: false, url: "", onlyErrors: true },
  }
  let config = { ...defaults }
  if (existsSync(CONFIG_PATH)) {
    try { config = deepMerge(config, JSON.parse(readFileSync(CONFIG_PATH, "utf-8"))) } catch {}
  }
  if (existsSync(CONFIG_LOCAL_PATH)) {
    try { config = deepMerge(config, JSON.parse(readFileSync(CONFIG_LOCAL_PATH, "utf-8"))) } catch {}
  }
  return config
}

const deepMerge = (t: any, s: any): any => {
  const o = { ...t }
  for (const k of Object.keys(s)) {
    o[k] = s[k] && typeof s[k] === "object" && !Array.isArray(s[k]) ? deepMerge(t[k] || {}, s[k]) : s[k]
  }
  return o
}

const SOUNDS = {
  complete: join(ASSETS_DIR, "complete.wav"),
  error: join(ASSETS_DIR, "error.wav"),
  permission: join(ASSETS_DIR, "permission.wav"),
  question: join(ASSETS_DIR, "question.wav"),
}

let sessionStartTime: number | null = null
let toolCallCount = 0
let filesModified: string[] = []
let lastNotificationTime = 0
let sessionId = ""

const generateSessionId = () => Math.random().toString(36).substring(2, 8)

const isFocusMode = (c: any) => {
  if (!c.focusMode.enabled) return false
  const h = new Date().getHours()
  const { start, end } = c.focusMode
  return start > end ? h >= start || h < end : h >= start && h < end
}

const isRateLimited = (c: any) => {
  if (!c.rateLimit.enabled) return false
  const n = Date.now()
  if (n - lastNotificationTime < c.rateLimit.minInterval) return true
  lastNotificationTime = n
  return false
}

const formatDuration = (ms: number) => {
  const s = Math.floor(ms / 1000)
  if (s < 60) return s + "s"
  const m = Math.floor(s / 60)
  const sec = s % 60
  if (m < 60) return m + "m " + sec + "s"
  return Math.floor(m / 60) + "h " + (m % 60) + "m"
}

const playSound = (type: keyof typeof SOUNDS, c: any) => {
  if (!c.local.sounds) return
  if (existsSync(SOUNDS[type])) exec("afplay \"" + SOUNDS[type] + "\"", () => {})
}

const notifyLocal = (title: string, msg: string, c: any) => {
  if (!c.local.enabled) return
  try {
    execSync("terminal-notifier -title \"" + title + "\" -message \"" + msg + "\"", { stdio: "ignore" })
  } catch {
    try {
      execSync("osascript -e 'display notification \"" + msg + "\" with title \"" + title + "\"'", { stdio: "ignore" })
    } catch {}
  }
}

const notifyNtfy = (title: string, msg: string, pri: number, tags: string[], c: any) => {
  if (!c.ntfy.enabled) return
  let auth = ""
  if (c.ntfy.auth.enabled && c.ntfy.auth.username) {
    auth = "-H \"Authorization: Basic " + Buffer.from(c.ntfy.auth.username + ":" + c.ntfy.auth.password).toString("base64") + "\""
  }
  const tagsHeader = tags.length ? "-H \"Tags: " + tags.join(",") + "\"" : ""
  const cmd = "curl -s -X POST \"" + c.ntfy.server + "/" + c.ntfy.topic + "\" -H \"Title: " + title + "\" -H \"Priority: " + pri + "\" " + auth + " " + tagsHeader + " -d \"" + msg + "\" &"
  exec(cmd, () => {})
}

const notifyWebhook = (title: string, msg: string, type: string, c: any) => {
  if (!c.webhook.enabled || !c.webhook.url) return
  if (c.webhook.onlyErrors && type !== "error") return
  const payload = JSON.stringify({ text: "*" + title + "*\n" + msg, username: "ChaosMonk" })
  exec("curl -s -X POST \"" + c.webhook.url + "\" -H \"Content-Type: application/json\" -d '" + payload + "' &", () => {})
}

const logSession = (event: string, data: Record<string, any>, c: any) => {
  if (!c.logging.enabled) return
  if (!existsSync(LOG_DIR)) mkdirSync(LOG_DIR, { recursive: true })
  const entry = JSON.stringify({ timestamp: new Date().toISOString(), session: sessionId, event, ...data }) + "\n"
  appendFileSync(join(LOG_DIR, "sessions.log"), entry)
}

type EventType = "complete" | "error" | "permission" | "question"

const notify = (type: EventType, title: string, msg: string, tags: string[], c: any) => {
  if (isFocusMode(c) || isRateLimited(c)) return
  playSound(type, c)
  notifyLocal(title, msg, c)
  notifyNtfy(title, msg, c.ntfy.priority[type], tags, c)
  notifyWebhook(title, msg, type, c)
  logSession("notify." + type, { title, msg }, c)
}

export const ChaosMonkNotifier: Plugin = async ({ project }) => {
  const config = loadConfig()
  const projectName = project?.name || "OpenCode"

  return {
    "session.start": async () => {
      sessionId = generateSessionId()
      sessionStartTime = Date.now()
      toolCallCount = 0
      filesModified = []
      logSession("session.start", { project: projectName }, config)
    },

    "session.complete": async () => {
      const d = sessionStartTime ? formatDuration(Date.now() - sessionStartTime) : "?"
      const stats = d + " | " + toolCallCount + " tools | " + filesModified.length + " files"
      notify("complete", "✅ " + projectName, stats, ["white_check_mark"], config)
      sessionStartTime = null
    },

    "session.error": async (e) => {
      const msg = (e?.error?.message || "Error").substring(0, 100)
      notify("error", "❌ " + projectName, msg, ["x"], config)
    },

    "permission.request": async (e) => {
      notify("permission", "⚠️ " + projectName, "Permission: " + (e?.tool?.name || "?"), ["warning"], config)
    },

    "tool.after": async (e) => {
      toolCallCount++
      const name = e.tool?.name
      const path = e.tool?.input?.filePath
      if ((name === "write" || name === "edit") && path && !filesModified.includes(path)) {
        filesModified.push(path)
      }
    },

    "message.part": async (e) => {
      if (e.part?.type === "text" && e.part?.content?.includes("?")) {
        if (sessionStartTime && Date.now() - sessionStartTime > 30000) {
          notify("question", "❓ " + projectName, "Question for you", ["question"], config)
        }
      }
    },
  }
}

export default ChaosMonkNotifier
