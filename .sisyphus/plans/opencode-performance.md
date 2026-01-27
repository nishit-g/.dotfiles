# OpenCode Startup Performance Optimization

## Context

### Original Request
User reports OpenCode takes "huge time to load" - 10-20 seconds startup time, which is unacceptable.

### Interview Summary
**Key Discussions**:
- User confirmed 10-20 second startup times
- User uses antigravity-auth and oh-my-opencode
- User agreed to drop cc-safety-net (not critical)
- User wants investigation before cache clearing

**Additional Finding (Momus Review)**:
- `opencode-openai-codex-auth` is configured but NEVER installed or used
- Not found in cache, not referenced in oh-my-opencode.json agent configs
- Will be removed alongside cc-safety-net

**Research Findings**:
- Root cause: Sequential `bun add --force` for EACH plugin on every startup
- `@latest` tags force npm registry resolution (~10.6s total)
- Plugin timing breakdown:
  - `opencode-antigravity-auth@latest`: 1.45s
  - `oh-my-opencode`: 2.34s
  - `cc-safety-net`: 1.09s
  - `@tarquinen/opencode-dcp@latest`: 5.70s
- Cache is 254MB with corruption (missing jose/bogus.js)
- Cache has stale plugins (8 cached vs 5 configured)

### Metis Review
**Identified Gaps** (addressed):
- Rollback strategy: Added backup step before changes
- Version validation: Versions extracted from current cache for 3 working plugins (antigravity-auth, oh-my-opencode, dcp)
- Incremental verification: Test after each change, not just at end
- Acceptance criteria: Specific numeric target (<3s) and functionality tests

---

## Work Objectives

### Core Objective
Reduce OpenCode startup time from 10-20 seconds to under 3 seconds by pinning plugin versions and removing unused plugins.

### Concrete Deliverables
- Modified `dotfiles/opencode/.config/opencode/opencode.json` with pinned versions
- Removed cc-safety-net plugin
- Cleared corrupted cache
- Verified startup time improvement

### Definition of Done
- [ ] `time opencode --help` completes in < 1 second (3 consecutive runs)
- [ ] Full TUI startup completes in < 3 seconds
- [ ] All 4 remaining plugins load without errors
- [ ] Can invoke agent successfully (tests auth + config)
- [ ] `discard`/`extract` tools available (tests DCP plugin)

### Must Have
- Backup of original opencode.json before changes
- Pinned versions for all 4 remaining plugins
- Cache cleared after config changes
- Verification at each step

### Must NOT Have (Guardrails)
- DO NOT reorganize plugin order or config structure
- DO NOT add logging, telemetry, or "future-proofing"
- DO NOT modify provider/model configurations
- DO NOT update bun/npm configuration
- DO NOT create automated update checkers
- DO NOT touch oh-my-opencode.json or other config files

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: NO (no automated tests for config)
- **User wants tests**: Manual verification
- **Framework**: N/A

### Manual QA Procedures

Each TODO includes specific verification commands with expected outputs.

**Verification Tools:**
| Type | Tool | Procedure |
|------|------|-----------|
| Startup time | `time` command | Measure 3 consecutive runs, average |
| Plugin loading | `opencode debug skill` | Should complete without ENOENT errors |
| Functionality | TUI launch | Agent should be invocable |

---

## Task Flow

```
Task 0 (Baseline) → Task 1 (Backup) → Task 2 (Pin Versions) → Task 3 (Remove Plugin) → Task 4 (Clear Cache) → Task 5 (Final Verify)
```

## Parallelization

| Task | Depends On | Reason |
|------|------------|--------|
| 0 | None | Baseline measurement |
| 1 | 0 | Need baseline before changes |
| 2 | 1 | Need backup before edits |
| 3 | 2 | Sequential config changes |
| 4 | 3 | Clear cache after all config changes |
| 5 | 4 | Final verification after cache clear |

---

## TODOs

- [ ] 0. Measure Baseline Startup Time

  **What to do**:
  - Close all OpenCode instances
  - Run `time opencode --help` three times consecutively
  - Record average time as baseline
  - Run `opencode debug skill` to confirm current error state

  **Must NOT do**:
  - Do not modify any files
  - Do not clear cache yet

  **Parallelizable**: NO (must be first)

  **References**:
  - None needed - measurement only

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [ ] Command: `time opencode --help` (run 3 times)
  - [ ] Record: Baseline average time (expected: 0.4-0.5s for --help)
  - [ ] Command: `opencode debug skill`
  - [ ] Expected: ENOENT error (confirms cache corruption exists)
  - [ ] Document baseline for comparison

  **Commit**: NO

---

- [ ] 1. Backup Current Configuration

  **What to do**:
  - Create backup of opencode.json before any modifications
  - Backup location: `dotfiles/opencode/.config/opencode/opencode.json.bak`

  **Must NOT do**:
  - Do not modify the original file yet

  **Parallelizable**: NO (depends on 0)

  **References**:
  - `dotfiles/opencode/.config/opencode/opencode.json` - File to backup

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [ ] Command: `cp dotfiles/opencode/.config/opencode/opencode.json dotfiles/opencode/.config/opencode/opencode.json.bak`
  - [ ] Verify: `diff dotfiles/opencode/.config/opencode/opencode.json dotfiles/opencode/.config/opencode/opencode.json.bak`
  - [ ] Expected: No output (files identical)

  **Commit**: NO (temporary backup)

---

- [ ] 2. Pin Plugin Versions in opencode.json

  **What to do**:
  - Edit `dotfiles/opencode/.config/opencode/opencode.json`
  - Change plugin array from:
    ```json
    "plugin": [
      "opencode-antigravity-auth@latest",
      "oh-my-opencode",
      "opencode-openai-codex-auth",
      "cc-safety-net",
      "@tarquinen/opencode-dcp@latest"
    ]
    ```
  - To (pinned versions, cc-safety-net removed):
    ```json
    "plugin": [
      "opencode-antigravity-auth@1.3.1",
      "oh-my-opencode@3.0.1",
      "opencode-openai-codex-auth@4.4.0",
      "@tarquinen/opencode-dcp@1.2.7"
    ]
    ```

  **Must NOT do**:
  - Do not change plugin order beyond removing cc-safety-net
  - Do not modify provider/model configurations
  - Do not add comments or formatting changes

  **Parallelizable**: NO (depends on 1)

  **References**:
  - `dotfiles/opencode/.config/opencode/opencode.json:3-9` - Plugin array to modify
  - Current working versions extracted from cache:
    - opencode-antigravity-auth: 1.3.1
    - oh-my-opencode: 3.0.1
    - opencode-openai-codex-auth: 4.4.0
    - @tarquinen/opencode-dcp: 1.2.7

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [ ] Command: `grep -A5 '"plugin"' dotfiles/opencode/.config/opencode/opencode.json`
  - [ ] Expected: Shows 4 plugins with pinned versions (no @latest, no cc-safety-net)
  - [ ] Command: `time opencode --help`
  - [ ] Expected: Should still work (config valid)

  **Commit**: YES
  - Message: `perf(opencode): pin plugin versions and remove cc-safety-net`
  - Files: `opencode/.config/opencode/opencode.json`
  - Pre-commit: `opencode --help` (verify config valid)

---

- [ ] 3. Clear Corrupted Cache

  **What to do**:
  - Remove the entire OpenCode cache directory
  - OpenCode will rebuild it on next startup with pinned versions

  **Must NOT do**:
  - Do not delete ~/.config/opencode (that's config, not cache)
  - Do not delete ~/.local/share/opencode (that's logs/data)

  **Parallelizable**: NO (depends on 2)

  **References**:
  - `~/.cache/opencode/` - Cache directory to clear (254MB)

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [ ] Command: `rm -rf ~/.cache/opencode`
  - [ ] Verify: `ls ~/.cache/opencode 2>&1`
  - [ ] Expected: "No such file or directory"

  **Commit**: NO (cache is not in git)

---

- [ ] 4. Verify Startup Time Improvement

  **What to do**:
  - Launch OpenCode to rebuild cache with pinned versions
  - Measure startup time (3 consecutive runs)
  - Verify all plugins load correctly
  - Compare to baseline

  **Must NOT do**:
  - Do not modify any files
  - Do not add @latest back

  **Parallelizable**: NO (depends on 3)

  **References**:
  - Baseline measurement from Task 0

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [ ] Command: `time opencode --help` (first run - cache rebuild)
  - [ ] Note: First run may be slower (rebuilding cache)
  - [ ] Command: `time opencode --help` (run 3 more times)
  - [ ] Expected: Average < 1 second (was 0.4-0.5s baseline, should be similar or faster)
  - [ ] Command: `opencode debug skill`
  - [ ] Expected: Completes without ENOENT error (cache rebuilt correctly)
  - [ ] Command: Launch OpenCode TUI, verify startup < 3 seconds
  - [ ] Test: Invoke an agent briefly to confirm auth works
  - [ ] Test: Verify `discard`/`extract` tools appear (DCP plugin loaded)

  **Commit**: NO

---

- [ ] 5. Document Results and Cleanup

  **What to do**:
  - Record final startup times vs baseline
  - Remove backup file (no longer needed)
  - Confirm improvement meets target (>70% reduction)

  **Must NOT do**:
  - Do not create documentation files
  - Do not add to README

  **Parallelizable**: NO (final task)

  **References**:
  - Baseline from Task 0
  - Final measurements from Task 4

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [ ] Calculate: (Baseline - Final) / Baseline × 100 = % improvement
  - [ ] Expected: >70% improvement (10-20s → <3s)
  - [ ] Command: `rm dotfiles/opencode/.config/opencode/opencode.json.bak`
  - [ ] Verify: Backup removed

  **Commit**: NO

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 2 | `perf(opencode): pin plugin versions and remove cc-safety-net` | opencode/.config/opencode/opencode.json | `opencode --help` works |

---

## Success Criteria

### Verification Commands
```bash
# Startup time (should be < 1s)
time opencode --help

# Plugin loading (should complete without errors)
opencode debug skill

# TUI startup (should be < 3s)
time opencode
```

### Final Checklist
- [ ] Startup time reduced from 10-20s to < 3s (>70% improvement)
- [ ] All 4 plugins load successfully
- [ ] No ENOENT or cache corruption errors
- [ ] Auth works (can invoke agents)
- [ ] DCP plugin works (discard/extract tools available)
- [ ] cc-safety-net removed
- [ ] No @latest tags remaining
- [ ] Backup file cleaned up

---

## Rollback Procedure

If something breaks:
```bash
# Restore original config
cp dotfiles/opencode/.config/opencode/opencode.json.bak dotfiles/opencode/.config/opencode/opencode.json

# Clear cache to reset
rm -rf ~/.cache/opencode

# Verify restored
opencode --help
```
