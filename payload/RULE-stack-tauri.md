# Tauri v2 + Rust Stack Rule

<!-- Address map: tauri.A1-2 · tauri.B1-5 -->

## Scope — when this applies
Every Aki desktop project built on Tauri v2 + Rust (backend commands) + any JS frontend framework. Generic lessons only — project-specific facts (titlebar height, bundle naming, etc.) stay in that project's own `CLAUDE.md`.

## A. Không block UI

### A1. Never block the UI (ABSOLUTE — zero exceptions, no case-by-case judgment calls)

This bug class recurs constantly across Aki's Tauri projects because it is easy to miss in review: a `#[tauri::command]` that runs a **blocking subprocess wait** (`Command::output()`, `.wait()`, `.wait_with_output()`, an SSH round-trip, a poll-and-sleep loop) or a **blocking network call** directly on the thread that dispatches the IPC call. Tauri does not put a plain `fn` command on a separate thread for you — a slow subprocess or a dead network directly freezes window repaint and all input for however long that call takes, with zero partial-progress feedback to the user. Two concrete real-world instances: an app's statusline-customizer auto-install froze the whole window on modal-open because its host-check ran a blocking SSH probe synchronously; a `check_for_updates` command ran a blocking `curl` call on every single app launch with no timeout.

**The rule, no exceptions:** any `#[tauri::command]` whose body runs a subprocess or a blocking network call **must** be `async fn`, and the blocking call **must** be wrapped in `tauri::async_runtime::spawn_blocking(move || { … }).await.map_err(|e| format!("spawn_blocking panicked: {}", e))?`. Never call the blocking function directly inside the `async fn` body "just this once because it's quick" — network and remote-host calls have no fast-path guarantee; a bad connection is exactly the case that must not freeze the app.

**Before adding or reviewing any `#[tauri::command]`**, ask: does this call a subprocess, SSH, or the network? If yes, `spawn_blocking` goes in from the first draft, not as a follow-up fix. Audit with `grep -n "#\[tauri::command\]" -A2 src-tauri/src/*.rs` before closing out any Tauri-touching task, and check every new/changed command against this rule.

Plain, fast, synchronous local file I/O (reading a small JSON/config file, a single `Path::exists()` check) is **not** this bug class and does not need `spawn_blocking` — the line is "does this call wait on a subprocess or the network," not "is this technically a syscall."

### A2. Subprocess PATH-resolution race at cold start (ABSOLUTE — apply to every spawned CLI binary)

Any Rust code that spawns a shell to invoke a user-installed CLI (`Command::new("sh"/"zsh"/"bash")`, or over `ssh host sh`) and relies on `zsh -lc`/`bash -lc` login-shell PATH resolution to find that binary is racing the user's shell rc/profile (nvm, path_helper, zinit, etc.) — which may not have finished sourcing yet if the subprocess is spawned right at/near app cold-start. Symptom: intermittent `exit=127 command not found: <bin>` that self-heals within minutes and is NOT reproducible when testing the identical command manually a bit later — easy to misdiagnose as a CLI-version or auth problem instead of a timing race.

**Fix pattern**: resolve the binary via static, well-known install-directory candidates FIRST (a `[ -x "$path" ]` file-existence test has zero dependency on rc-sourcing timing), falling back to `command -v` / login-shell PATH lookup only if none match — do this in ONE shared preamble injected at the single funnel where scripts are dispatched, not patched ad hoc at each call site. Seed the candidate path list for the platform(s) the app actually ships for first (e.g. macOS-only apps: `~/.local/bin`, `~/.claude/local`, `/opt/homebrew/bin`, `/usr/local/bin` for Claude Code specifically) — extend the list only when a new platform build actually ships, rather than guessing paths for platforms not yet supported.

## B. Boundary & config

### B1. Titlebar sacred boundary
`"decorations": false` + `"transparent": true` → no native titlebar. All `position: fixed/absolute` elements **must** start at `top: var(--titlebar-h)` (or the app's titlebar height), never `top: 0`. Window controls (drag/minimize/close) via JS `@tauri-apps/api/window`.

### B2. IPC capability silent fail
Every Tauri command AND window API call must be granted in `src-tauri/capabilities/default.json`. Missing → **silent no-op**, no error, no log. Window needs: `core:window:allow-minimize`, `core:window:allow-close`, `core:window:allow-start-dragging`.

### B3. Serde fields + old JSON
New fields on structs deserialized from persisted JSON need `#[serde(default)]` or old records silently drop the field instead of erroring.

### B4. `#[cfg(target_os = "macos")]` scoping
Declare variables **inside** the cfg block. Declared outside but used only inside → unused-variable warning on non-macOS builds.

### B5. Version SSOT
`package.json` only. `tauri.conf.json` → `"version": "../package.json"`. Never hardcode version in `tauri.conf.json`. `Cargo.toml` has its own crate version (separate concern) and **must always be bumped to the same number in the same commit** — a mismatch between `package.json` and `Cargo.toml` is the same class of bug as a bad tag. See [[RULE-release]] § Version string format for the absolute no-`v`-prefix rule that governs both fields and every git tag.
