#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ROOT="$HOME/.aki/claudedoc"
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d%H%M%S)"

backup() {
  if [ -e "$1" ]; then
    cp -R "$1" "$1.akiclaudedoc-backup-$STAMP"
  fi
}

mkdir -p "$INSTALL_ROOT" "$CLAUDE_DIR/skills"
rsync -a --delete --exclude 'ref-ECC/' --exclude '.DS_Store' "$REPO_ROOT/payload/" "$INSTALL_ROOT/"

for skill in akidoc-rules akidoc-flow-audit akidoc-techbiz-optimizer; do
    mkdir -p "$CLAUDE_DIR/skills/$skill"
  cp "$REPO_ROOT/claude/skills/$skill/SKILL.md" "$CLAUDE_DIR/skills/$skill/SKILL.md"
done

mkdir -p "$CLAUDE_DIR"
backup "$CLAUDE_DIR/CLAUDE.md"
cp "$REPO_ROOT/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  printf '{}\n' > "$CLAUDE_DIR/settings.json"
fi
backup "$CLAUDE_DIR/settings.json"
python3 - "$CLAUDE_DIR/settings.json" "$INSTALL_ROOT" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
install_root = sys.argv[2]
data = json.loads(target.read_text())

data.setdefault('permissions', {})
data['permissions'].setdefault('allow', [])
data['permissions'].setdefault('additionalDirectories', [])

read_rule = f'Read(//{install_root.lstrip("/")}/**)'
data['permissions']['allow'] = [item for item in data['permissions']['allow'] if item != f'Read(//{install_root}/**)']
if read_rule not in data['permissions']['allow']:
    data['permissions']['allow'].append(read_rule)

if install_root not in data['permissions']['additionalDirectories']:
    data['permissions']['additionalDirectories'].append(install_root)

data.setdefault('skillOverrides', {})
for skill in ['akidoc-rules', 'akidoc-flow-audit', 'akidoc-techbiz-optimizer']:
    data['skillOverrides'][skill] = 'on'

target.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')
PY

printf 'AkiClaudeDoc installed to %s\n' "$INSTALL_ROOT"
