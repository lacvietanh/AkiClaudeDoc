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

# Keep only the 2 most recent backups for a given base path (portable: macOS bash 3.2 + GNU bash)
prune_backups() {
  local base="$1"
  local dir
  dir="$(dirname "$base")"
  local name
  name="$(basename "$base")"
  local count
  count=$(find "$dir" -maxdepth 1 -name "${name}.akiclaudedoc-backup-*" | wc -l | tr -d ' ')
  if [ "$count" -le 2 ]; then
    return
  fi
  find "$dir" -maxdepth 1 -name "${name}.akiclaudedoc-backup-*" | sort | head -n "$((count - 2))" | while IFS= read -r f; do
    echo -e "  🗑️  Xóa backup cũ: $(basename "$f")"
    rm -rf "$f"
  done
}

inspect_status() {
  echo -e "\033[1;36m=== KIỂM TRA TRẠNG THÁI HỆ THỐNG TRƯỚC KHI CÀI ĐẶT ===\033[0m"

  if [ -d "$INSTALL_ROOT" ]; then
    echo -e "📦 Payload rules: Sẽ \033[1;33mCẬP NHẬT đè\033[0m lên $INSTALL_ROOT"
  else
    echo -e "📦 Payload rules: Sẽ \033[1;32mTẠO MỚI\033[0m tại $INSTALL_ROOT"
  fi

  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo -e "📝 Global CLAUDE.md: Sẽ \033[1;33mGHI ĐÈ\033[0m $CLAUDE_DIR/CLAUDE.md (có backup)"
  else
    echo -e "📝 Global CLAUDE.md: Sẽ \033[1;32mTẠO MỚI\033[0m $CLAUDE_DIR/CLAUDE.md"
  fi

  for skill_dir in "$REPO_ROOT"/claude/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    if [ -f "$CLAUDE_DIR/skills/$skill_name/SKILL.md" ]; then
      echo -e "🔧 Skill $skill_name: Sẽ \033[1;33mCẬP NHẬT đè\033[0m $CLAUDE_DIR/skills/$skill_name/SKILL.md"
    else
      echo -e "🔧 Skill $skill_name: Sẽ \033[1;32mTẠO MỚI\033[0m $CLAUDE_DIR/skills/$skill_name/SKILL.md"
    fi
  done

  local old_skills=()
  for s in akidoc-rules akidoc-flow-audit akidoc-techbiz-optimizer; do
    [ -d "$CLAUDE_DIR/skills/$s" ] && old_skills+=("$s")
  done
  if [ ${#old_skills[@]} -gt 0 ]; then
    echo -e "🗑️  Skill cũ sẽ bị XÓA: \033[1;31m${old_skills[*]}\033[0m"
  fi

  echo -e "⚙️  settings.json: Khám quyền đọc và skill overrides..."
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    python3 - "$CLAUDE_DIR/settings.json" "$INSTALL_ROOT" <<'INSPECT_PY'
import json, pathlib, sys
target = pathlib.Path(sys.argv[1])
install_root = sys.argv[2]
OLD_SKILLS = ['akidoc-rules', 'akidoc-flow-audit', 'akidoc-techbiz-optimizer']
try:
    data = json.loads(target.read_text())
    read_rule = f'Read(//{install_root.lstrip("/")}/**)'
    allow = data.get('permissions', {}).get('allow', [])
    if read_rule in allow:
        print("  ✅ Đã có quyền Read cho thư mục payload.")
    else:
        print("  ⚠️  CHƯA CÓ quyền Read. Sẽ bổ sung tự động.")
    overrides = data.get('skillOverrides', {})
    if overrides.get('akirule') == 'on':
        print("  ✅ Skill akirule đã được bật (on).")
    else:
        print("  ⚠️  Sẽ tự động bật skill: akirule")
    stale = [s for s in OLD_SKILLS if s in overrides]
    if stale:
        print(f"  🗑️  skillOverrides cũ sẽ bị XÓA: {', '.join(stale)}")
except Exception as e:
    print(f"  ❌ Lỗi đọc settings.json: {e}")
INSPECT_PY
  else
    echo -e "  ⚠️  Chưa có settings.json. Sẽ TẠO MỚI."
  fi
  echo -e "\033[1;36m====================================================\033[0m"
}

print_summary() {
  echo -e "\n\033[1;32m=== ĐÃ CÀI ĐẶT THÀNH CÔNG ===\033[0m"

  # Version info
  local git_hash=""
  if git -C "$REPO_ROOT" rev-parse --short HEAD &>/dev/null; then
    git_hash=" ($(git -C "$REPO_ROOT" rev-parse --short HEAD))"
  fi
  echo -e "📅 Thời điểm: $(date '+%Y-%m-%d %H:%M:%S')${git_hash}"
  echo -e "📂 Payload : $INSTALL_ROOT"
  echo -e "🔧 Skills  : $CLAUDE_DIR/skills/"
  echo ""

  # Rule manifest with tiers
  echo -e "\033[1;36mRules đã deploy:\033[0m"
  python3 - "$INSTALL_ROOT/index.md" <<'PY'
import re, pathlib, sys
index = pathlib.Path(sys.argv[1]).read_text()
tier_colors = {"Core": "\033[1;31m", "Contextual": "\033[1;33m", "Analytical": "\033[1;34m"}
reset = "\033[0m"
for line in index.splitlines():
    m = re.match(r'\|\s*`([^`]+)`\s*\|\s*(\w+)\s*\|(.+)\|', line)
    if m:
        fname, tier, desc = m.group(1), m.group(2).strip(), m.group(3).strip()
        color = tier_colors.get(tier, "")
        print(f"  {color}{tier:<12}{reset} {fname:<30} {desc}")
PY

  # Skills installed
  echo ""
  echo -e "\033[1;36mSkills đã deploy:\033[0m"
  for skill_dir in "$CLAUDE_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    echo -e "  🔧 $(basename "$skill_dir")"
  done

  echo -e "\n\033[1;32m==============================\033[0m"
}

inspect_status

confirm="y"
if [ -t 0 ]; then
    read -p "Bạn có chắc chắn muốn cài đặt/cập nhật với các thay đổi trên? (y/n): " confirm
fi
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Đã hủy cài đặt."
    exit 1
fi
echo "Đang tiến hành cài đặt..."

mkdir -p "$INSTALL_ROOT" "$CLAUDE_DIR/skills"
rsync -a --delete --exclude 'ref-ECC/' --exclude '.DS_Store' "$REPO_ROOT/payload/" "$INSTALL_ROOT/"

# Copy changelog so any machine knows what's installed without the repo
cp "$REPO_ROOT/CHANGELOG.md" "$INSTALL_ROOT/CHANGELOG.md"

# Write version stamp
{
  echo "installed=$(date '+%Y-%m-%d %H:%M:%S')"
  if git -C "$REPO_ROOT" rev-parse --short HEAD &>/dev/null; then
    echo "commit=$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
    echo "branch=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
  fi
} > "$INSTALL_ROOT/.version"

for skill_dir in "$REPO_ROOT"/claude/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  mkdir -p "$CLAUDE_DIR/skills/$skill_name"
  cp "$skill_dir/SKILL.md" "$CLAUDE_DIR/skills/$skill_name/SKILL.md"
done

for old_skill in akidoc-rules akidoc-flow-audit akidoc-techbiz-optimizer; do
  rm -rf "$CLAUDE_DIR/skills/$old_skill"
done

mkdir -p "$CLAUDE_DIR"
backup "$CLAUDE_DIR/CLAUDE.md"
echo -e "🧹 Dọn backup CLAUDE.md (giữ 2 gần nhất):"
prune_backups "$CLAUDE_DIR/CLAUDE.md"
cp "$REPO_ROOT/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  printf '{}\n' > "$CLAUDE_DIR/settings.json"
fi
backup "$CLAUDE_DIR/settings.json"
echo -e "🧹 Dọn backup settings.json (giữ 2 gần nhất):"
prune_backups "$CLAUDE_DIR/settings.json"
python3 - "$CLAUDE_DIR/settings.json" "$INSTALL_ROOT" <<'PY'
import json, pathlib, sys

target = pathlib.Path(sys.argv[1])
install_root = sys.argv[2]
data = json.loads(target.read_text())

if not isinstance(data.get('permissions'), dict):
    data['permissions'] = {}
perms = data['permissions']
if not isinstance(perms.get('allow'), list):
    perms['allow'] = []
if not isinstance(perms.get('additionalDirectories'), list):
    perms['additionalDirectories'] = []

read_rule = f'Read(//{install_root.lstrip("/")}/**)'
perms['allow'] = [item for item in perms['allow'] if item != read_rule]
perms['allow'].append(read_rule)

if install_root not in perms['additionalDirectories']:
    perms['additionalDirectories'].append(install_root)

if not isinstance(data.get('skillOverrides'), dict):
    data['skillOverrides'] = {}
for old_skill in ['akidoc-rules', 'akidoc-flow-audit', 'akidoc-techbiz-optimizer']:
    data['skillOverrides'].pop(old_skill, None)
data['skillOverrides']['akirule'] = 'on'

target.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')
PY

print_summary
