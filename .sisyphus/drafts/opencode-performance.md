# Draft: OpenCode Startup Performance

## Problem Statement
User reports OpenCode takes "huge time to load" - unacceptable startup latency.

## Research Findings

### Baseline Measurements
- `opencode --version`: 0.416s
- `opencode --help`: 0.479s
- Full TUI startup: TBD (user reports slow)

### Critical Issues Found

#### 1. CORRUPTED CACHE (HIGH PRIORITY)
- `opencode debug skill` fails with ENOENT error
- Missing: `~/.cache/opencode/node_modules/@openauthjs/openauth/node_modules/jose/dist/browser/runtime/bogus.js`
- Cache size: **254MB** - potentially bloated

#### 2. Plugin Installation on Every Startup
- Logs show `bun add @opencode-ai/plugin` runs EVERY startup
- Then `bun install` in ~/.config/opencode
- Plugin installation takes 1.77s per startup
- This is likely the main culprit

#### 3. Plugins Configured (5 total)
```json
"plugin": [
  "opencode-antigravity-auth@latest",
  "oh-my-opencode",
  "opencode-openai-codex-auth",
  "cc-safety-net",
  "@tarquinen/opencode-dcp@latest"
]
```
- Using `@latest` may trigger version checks on each startup

#### 4. Skills Loading
- 12 skills total
- 4 local directories
- 8 symlinks to ~/.agents/skills/
- Each skill needs parsing/loading

#### 5. Cache Contents
- `~/.cache/opencode/`: 254MB
- Contains: node_modules (192 entries), models.json (945KB), bun.lock
- package.json has 8 plugin dependencies (more than config!)

### Configuration Files
- Main config: `~/.config/opencode/opencode.json` (symlink to dotfiles)
- Agent config: `~/.config/opencode/oh-my-opencode.json` (symlink to dotfiles)
- DCP config: `~/.config/opencode/dcp.jsonc`
- Custom plugin: `plugins/chaosmonk-notifier.ts`

## User Answers
1. **Perceived startup time**: 10-20 seconds (SEVERE)
2. **Clear cache**: User wants more investigation first
3. **Plugins**: Can drop some

## ROOT CAUSE IDENTIFIED

From startup log analysis - **sequential plugin installation with @latest**:

| Plugin | Time | Issue |
|--------|------|-------|
| `opencode-antigravity-auth@latest` | 1.45s | @latest forces npm resolution |
| `oh-my-opencode` | 2.34s | Implicit latest |
| `cc-safety-net` | 1.09s | Implicit latest |
| `@tarquinen/opencode-dcp@latest` | 5.70s | @latest + large deps |
| **TOTAL** | **~10.6s** | Matches user's 10-20s! |

Every startup runs `bun add --force` for EACH plugin, even when already installed.

## Confirmed Fix Strategy
1. **Pin all plugin versions** (e.g., `opencode-antigravity-auth@1.3.1` not `@latest`)
2. **Remove unused plugins** (user can drop some)
3. **Clear corrupted cache** after config changes
4. **Remove opencode-openai-codex-auth** if not using OpenAI Codex

## Pending
- Which plugins can user drop?
