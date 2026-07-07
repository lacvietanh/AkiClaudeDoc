#!/usr/bin/env python3
"""AkiClaudeDoc update-check hook (Claude Code SessionStart).

Notify-only. Compares the installed CHANGELOG.md top entry against the public
repo copy; if the remote has newer entries, prints a user-visible notice
(systemMessage) plus the "what's new" delta as context for Claude
(additionalContext).

Design guarantees:
- Fail-silent: any error, missing file, or network problem exits 0 with no
  output, so it can never disrupt a session.
- Throttled: checks at most once per THROTTLE_HOURS, even on failure.
- Never auto-updates: it only reports and points at the manual install command.
- No third-party deps: stdlib only (urllib), so it runs anywhere python3 does.
"""
import json
import os
import sys
import time
import urllib.request

REMOTE_URL = "https://raw.githubusercontent.com/lacvietanh/AkiClaudeDoc/master/CHANGELOG.md"
CHANGELOG_URL_HUMAN = "https://github.com/lacvietanh/AkiClaudeDoc/blob/master/CHANGELOG.md"
THROTTLE_OK_HOURS = 24    # after a definitive result, wait a full day
THROTTLE_FAIL_HOURS = 1   # after offline/timeout, retry sooner so a notice is not lost
NETWORK_TIMEOUT = 3       # seconds

HOME = os.path.expanduser("~")
INSTALL_ROOT = os.path.join(HOME, ".aki", "claudedoc")
LOCAL_CHANGELOG = os.path.join(INSTALL_ROOT, "CHANGELOG.md")
SOURCE_REPO_FILE = os.path.join(INSTALL_ROOT, ".source-repo")
THROTTLE_FILE = os.path.join(HOME, ".claude", "hooks", ".aki-update-check")


def silent_exit():
    sys.exit(0)


def check_due():
    """True if it is time to check again (also when the marker is missing/unreadable)."""
    try:
        with open(THROTTLE_FILE) as f:
            return time.time() >= float(f.read().strip())
    except (OSError, ValueError):
        return True


def defer_check(hours):
    """Record the next-allowed check time."""
    try:
        os.makedirs(os.path.dirname(THROTTLE_FILE), exist_ok=True)
        with open(THROTTLE_FILE, "w") as f:
            f.write(str(int(time.time() + hours * 3600)))
    except OSError:
        pass


def split_entries(text):
    """Return [(header, [lines])] for each '## ' section, in file order."""
    entries = []
    cur = None
    for line in text.splitlines():
        if line.startswith("## "):
            cur = (line[3:].strip(), [line])
            entries.append(cur)
        elif cur is not None:
            cur[1].append(line)
    return entries


def main():
    if not check_due():
        silent_exit()

    try:
        with open(LOCAL_CHANGELOG, encoding="utf-8") as f:
            local_entries = split_entries(f.read())
    except OSError:
        defer_check(THROTTLE_OK_HOURS)  # broken/missing install, nothing to retry soon
        silent_exit()
    if not local_entries:
        defer_check(THROTTLE_OK_HOURS)
        silent_exit()
    local_head = local_entries[0][0]

    try:
        req = urllib.request.Request(REMOTE_URL, headers={"User-Agent": "aki-update-check"})
        with urllib.request.urlopen(req, timeout=NETWORK_TIMEOUT) as resp:
            remote_text = resp.read().decode("utf-8", "replace")
    except Exception:
        defer_check(THROTTLE_FAIL_HOURS)  # offline/timeout -> retry soon, do not lose the notice
        silent_exit()

    defer_check(THROTTLE_OK_HOURS)  # we have a definitive answer; next check in a day

    entries = split_entries(remote_text)
    if not entries:
        silent_exit()
    remote_head = entries[0][0]
    if remote_head == local_head:
        silent_exit()  # up to date

    # Where does the installed version sit inside the remote changelog?
    pos = next((i for i, (h, _) in enumerate(entries) if h == local_head), None)
    if pos is None or pos == 0:
        # local is ahead / diverged / unknown -> do not nag (e.g. a dev machine)
        silent_exit()

    new_entries = entries[:pos]  # everything strictly newer than what is installed

    try:
        with open(SOURCE_REPO_FILE, encoding="utf-8") as f:
            repo = f.read().strip()
    except OSError:
        repo = ""
    update_cmd = (
        f"cd {repo} && git pull && bash install.sh"
        if repo
        else "pull the AkiClaudeDoc repo and run: bash install.sh"
    )

    delta_lines = []
    for _, lines in new_entries:
        delta_lines.extend(lines)
    delta = "\n".join(delta_lines).strip()
    max_delta = 1400
    if len(delta) > max_delta:
        delta = delta[:max_delta].rstrip() + "\n… (xem đầy đủ ở link bên dưới)"

    banner = (
        "📢 AkiClaudeDoc có bản cập nhật mới\n"
        f"   Mới nhất: {remote_head}   |   Đang dùng: {local_head}   "
        f"({len(new_entries)} bản ghi mới)\n"
        f"   Cập nhật:  {update_cmd}\n"
        f"   Changelog: {CHANGELOG_URL_HUMAN}\n\n"
        f"{delta}"
    )
    context = (
        "The AkiClaudeDoc shared-rule corpus has a newer version available.\n"
        f"Installed: {local_head}. Latest: {remote_head}.\n"
        f"To update, run: {update_cmd}\n\n"
        "What's new (from CHANGELOG.md):\n" + "\n".join(delta_lines)
    )

    print(json.dumps({
        "systemMessage": banner,
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
        },
        "suppressOutput": True,
    }, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        silent_exit()
