import type { Plugin } from "@opencode-ai/plugin";
import { execSync, exec } from "child_process";
import { existsSync, readFileSync, appendFileSync, mkdirSync } from "fs";
import { homedir } from "os";
import { join, basename } from "path";

const PATHS = {
  config: join(homedir(), ".config/opencode/notifier.json"),
  configLocal: join(homedir(), ".config/opencode/notifier.local.json"),
  assets: join(homedir(), ".config/opencode/plugins/assets"),
  logs: join(homedir(), ".local/share/opencode"),
} as const;

const LIMITS = {
  questionDelayMs: 30000,
  errorMessageMaxLength: 100,
  maxFilesInSummary: 3,
  maxToolsInSummary: 4,
} as const;

const TOOL_PRIORITY = ["edit", "write", "bash", "read", "grep", "glob"] as const;

interface NtfyConfig {
  enabled: boolean;
  server: string;
  topic: string;
  auth: { enabled: boolean; username: string; password: string };
  priority: { complete: number; error: number; permission: number; question: number };
}

interface Config {
  ntfy: NtfyConfig;
  local: { enabled: boolean; sounds: boolean };
  rateLimit: { enabled: boolean; minInterval: number };
  logging: { enabled: boolean };
  focusMode: { enabled: boolean; start: number; end: number };
  webhook: { enabled: boolean; url: string; onlyErrors: boolean };
}

interface SessionState {
  startTime: number;
  toolCallCount: number;
  filesModified: string[];
  toolsUsed: Set<string>;
  lastNotificationTime: number;
}

type EventType = "complete" | "error" | "permission" | "question";

const DEFAULT_CONFIG: Config = {
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
};

const deepMerge = <T extends Record<string, unknown>>(target: T, source: Partial<T>): T => {
  const output = { ...target };
  for (const key of Object.keys(source) as (keyof T)[]) {
    const sourceVal = source[key];
    const targetVal = target[key];
    if (sourceVal && typeof sourceVal === "object" && !Array.isArray(sourceVal)) {
      output[key] = deepMerge(
        (targetVal || {}) as Record<string, unknown>,
        sourceVal as Record<string, unknown>
      ) as T[keyof T];
    } else if (sourceVal !== undefined) {
      output[key] = sourceVal as T[keyof T];
    }
  }
  return output;
};

const loadConfig = (): Config => {
  let config = { ...DEFAULT_CONFIG };
  
  for (const path of [PATHS.config, PATHS.configLocal]) {
    if (existsSync(path)) {
      try {
        const fileContent = JSON.parse(readFileSync(path, "utf-8"));
        config = deepMerge(config, fileContent);
      } catch {
        // Config file exists but is invalid - continue with current config
      }
    }
  }
  
  return config;
};

const SOUNDS: Record<EventType, string> = {
  complete: join(PATHS.assets, "complete.wav"),
  error: join(PATHS.assets, "error.wav"),
  permission: join(PATHS.assets, "permission.wav"),
  question: join(PATHS.assets, "question.wav"),
};

const ICON_PATH = join(PATHS.assets, "icon.png");

const createSessionState = (): SessionState => ({
  startTime: Date.now(),
  toolCallCount: 0,
  filesModified: [],
  toolsUsed: new Set(),
  lastNotificationTime: 0,
});

let currentState: SessionState = createSessionState();

const resetState = (): void => {
  currentState = createSessionState();
};

const getTmuxSession = (): string | null => {
  try {
    const pane = execSync("echo $TMUX_PANE", {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();
    
    if (!pane) return null;
    
    return execSync("tmux display-message -p '#S'", {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim() || null;
  } catch {
    return null;
  }
};

const formatFileList = (files: string[]): string => {
  if (files.length === 0) return "";
  
  const basenames = files.map((f) => basename(f));
  
  if (basenames.length <= LIMITS.maxFilesInSummary) {
    return basenames.join(", ");
  }
  
  const shown = basenames.slice(0, LIMITS.maxFilesInSummary).join(", ");
  const remaining = basenames.length - LIMITS.maxFilesInSummary;
  return `${shown} +${remaining} more`;
};

const formatToolsSummary = (tools: Set<string>): string => {
  if (tools.size === 0) return "";
  
  const sorted = Array.from(tools).sort((a, b) => {
    const aIndex = TOOL_PRIORITY.indexOf(a as typeof TOOL_PRIORITY[number]);
    const bIndex = TOOL_PRIORITY.indexOf(b as typeof TOOL_PRIORITY[number]);
    
    if (aIndex === -1 && bIndex === -1) return a.localeCompare(b);
    if (aIndex === -1) return 1;
    if (bIndex === -1) return -1;
    return aIndex - bIndex;
  });
  
  if (sorted.length <= LIMITS.maxToolsInSummary) {
    return sorted.join(", ");
  }
  
  const shown = sorted.slice(0, LIMITS.maxToolsInSummary).join(", ");
  const remaining = sorted.length - LIMITS.maxToolsInSummary;
  return `${shown} +${remaining}`;
};

const formatDuration = (ms: number): string => {
  const totalSeconds = Math.floor(ms / 1000);
  
  if (totalSeconds < 60) return `${totalSeconds}s`;
  
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  
  if (minutes < 60) return `${minutes}m ${seconds}s`;
  
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  return `${hours}h ${remainingMinutes}m`;
};

const isFocusMode = (config: Config): boolean => {
  if (!config.focusMode.enabled) return false;
  
  const hour = new Date().getHours();
  const { start, end } = config.focusMode;
  
  return start > end 
    ? hour >= start || hour < end 
    : hour >= start && hour < end;
};

const isRateLimited = (state: SessionState, config: Config): boolean => {
  if (!config.rateLimit.enabled) return false;
  
  const now = Date.now();
  if (now - state.lastNotificationTime < config.rateLimit.minInterval) {
    return true;
  }
  
  state.lastNotificationTime = now;
  return false;
};

const escapeShellArg = (arg: string): string => {
  return arg.replace(/"/g, '\\"');
};

const formatTitleForMac = (title: string): string => {
  return title.replace(/\[/g, "\\[");
};

const buildTitle = (tmux: string | null): string => {
  return tmux ? `[${tmux}] | OpenCode` : "OpenCode";
};

const playSound = (type: EventType, config: Config): void => {
  if (!config.local.sounds) return;
  
  const soundPath = SOUNDS[type];
  if (existsSync(soundPath)) {
    exec(`afplay "${escapeShellArg(soundPath)}"`, () => {});
  }
};

const notifyLocal = (title: string, subtitle: string, msg: string, config: Config): void => {
  if (!config.local.enabled) return;
  
  const macTitle = escapeShellArg(formatTitleForMac(title));
  const macSubtitle = escapeShellArg(subtitle);
  const macMsg = escapeShellArg(msg);
  const iconArg = existsSync(ICON_PATH) ? ` -appIcon "${ICON_PATH}"` : "";
  
  try {
    execSync(
      `terminal-notifier -title "${macTitle}" -subtitle "${macSubtitle}" -message "${macMsg}"${iconArg} -group opencode`,
      { stdio: "ignore" }
    );
  } catch {
    try {
      execSync(
        `osascript -e 'display notification "${macMsg}" with title "${macTitle}" subtitle "${macSubtitle}"'`,
        { stdio: "ignore" }
      );
    } catch {
      // Both notification methods failed - nothing we can do
    }
  }
};

const notifyNtfy = (
  title: string,
  subtitle: string,
  msg: string,
  priority: number,
  tags: string[],
  config: Config
): void => {
  if (!config.ntfy.enabled) return;
  
  const { server, topic, auth } = config.ntfy;
  const escapedTitle = escapeShellArg(title);
  const fullMsg = escapeShellArg(subtitle ? `${subtitle}\n${msg}` : msg);
  
  let authHeader = "";
  if (auth.enabled && auth.username) {
    const credentials = Buffer.from(`${auth.username}:${auth.password}`).toString("base64");
    authHeader = ` -H "Authorization: Basic ${credentials}"`;
  }
  
  const tagsHeader = tags.length > 0 ? ` -H "Tags: ${tags.join(",")}"` : "";
  
  const cmd = `curl -s -X POST "${server}/${topic}" -H "Title: ${escapedTitle}" -H "Priority: ${priority}"${authHeader}${tagsHeader} -d "${fullMsg}" &`;
  
  exec(cmd, () => {});
};

const notifyWebhook = (title: string, msg: string, type: EventType, config: Config): void => {
  if (!config.webhook.enabled || !config.webhook.url) return;
  if (config.webhook.onlyErrors && type !== "error") return;
  
  const payload = JSON.stringify({
    text: `*${title}*\n${msg}`,
    username: "ChaosMonk",
  });
  
  exec(
    `curl -s -X POST "${config.webhook.url}" -H "Content-Type: application/json" -d '${payload}' &`,
    () => {}
  );
};

const logSession = (
  sessionId: string,
  event: string,
  data: Record<string, unknown>,
  config: Config
): void => {
  if (!config.logging.enabled) return;
  
  if (!existsSync(PATHS.logs)) {
    mkdirSync(PATHS.logs, { recursive: true });
  }
  
  const entry = JSON.stringify({
    timestamp: new Date().toISOString(),
    session: sessionId,
    event,
    ...data,
  }) + "\n";
  
  appendFileSync(join(PATHS.logs, "sessions.log"), entry);
};

const notify = (
  state: SessionState,
  type: EventType,
  title: string,
  subtitle: string,
  msg: string,
  tags: string[],
  config: Config
): void => {
  if (isFocusMode(config) || isRateLimited(state, config)) return;
  
  playSound(type, config);
  notifyLocal(title, subtitle, msg, config);
  notifyNtfy(title, subtitle, msg, config.ntfy.priority[type], tags, config);
  notifyWebhook(title, msg, type, config);
};

const extractSessionId = (event: unknown): string => {
  const e = event as Record<string, unknown>;
  const props = e.properties as Record<string, unknown> | undefined;
  return (props?.session_id ?? e.session_id ?? e.sessionID ?? "unknown") as string;
};

const extractErrorMessage = (event: unknown): string => {
  const e = event as Record<string, unknown>;
  const props = e.properties as Record<string, unknown> | undefined;
  const error = props?.error as Record<string, unknown> | undefined;
  const message = (error?.message ?? "Something went wrong") as string;
  return message.substring(0, LIMITS.errorMessageMaxLength);
};

const extractPermission = (event: unknown): string => {
  const e = event as Record<string, unknown>;
  const props = e.properties as Record<string, unknown> | undefined;
  return (props?.permission ?? "Action needed") as string;
};

const extractMessagePart = (event: unknown): { type?: string; content?: string } | null => {
  const e = event as Record<string, unknown>;
  const props = e.properties as Record<string, unknown> | undefined;
  return (props?.part as { type?: string; content?: string }) ?? null;
};

export const ChaosMonkNotifier: Plugin = async ({ project }) => {
  const config = loadConfig();
  const projectName = project?.name ?? "OpenCode";

  return {
    event: async ({ event }) => {
      const sessionId = extractSessionId(event);
      const eventType = (event as { type: string }).type;

      switch (eventType) {
        case "session.created": {
          resetState();
          logSession(sessionId, "session.created", { project: projectName }, config);
          break;
        }

        case "session.idle": {
          const duration = formatDuration(Date.now() - currentState.startTime);
          const tmux = getTmuxSession();
          const title = buildTitle(tmux);
          
          const parts: string[] = [duration];
          if (currentState.filesModified.length > 0) {
            parts.push(formatFileList(currentState.filesModified));
          }
          if (currentState.toolsUsed.size > 0) {
            parts.push(`🔧 ${formatToolsSummary(currentState.toolsUsed)}`);
          }
          
          const msg = parts.join(" | ");
          
          notify(currentState, "complete", title, "✅ Session Complete", msg, ["white_check_mark"], config);
          logSession(sessionId, "session.idle", {
            msg,
            tmux,
            files: currentState.filesModified,
            tools: Array.from(currentState.toolsUsed),
          }, config);
          break;
        }

        case "session.error": {
          const tmux = getTmuxSession();
          const title = buildTitle(tmux);
          const errorMsg = extractErrorMessage(event);
          
          notify(currentState, "error", title, "❌ Error", errorMsg, ["x"], config);
          logSession(sessionId, "session.error", { error: errorMsg }, config);
          break;
        }

        case "session.deleted": {
          resetState();
          break;
        }

        case "permission.updated": {
          const tmux = getTmuxSession();
          const title = buildTitle(tmux);
          const permission = extractPermission(event);
          
          notify(currentState, "permission", title, "⚠️ Permission Required", permission, ["warning"], config);
          break;
        }

        case "message.part.updated": {
          const part = extractMessagePart(event);
          const isQuestion = part?.type === "text" && part?.content?.includes("?");
          const hasEnoughTime = Date.now() - currentState.startTime > LIMITS.questionDelayMs;
          
          if (isQuestion && hasEnoughTime) {
            const tmux = getTmuxSession();
            const title = buildTitle(tmux);
            
            notify(currentState, "question", title, "❓ Question", "Waiting for your input", ["question"], config);
          }
          break;
        }
      }
    },

    "tool.execute.after": async (input) => {
      currentState.toolCallCount++;
      currentState.toolsUsed.add(input.tool);
      
      const filePath = (input.args as Record<string, unknown>)?.filePath as string | undefined;
      const isFileModifyingTool = input.tool === "write" || input.tool === "edit";
      
      if (isFileModifyingTool && filePath && !currentState.filesModified.includes(filePath)) {
        currentState.filesModified.push(filePath);
      }
    },
  };
};

export default ChaosMonkNotifier;
