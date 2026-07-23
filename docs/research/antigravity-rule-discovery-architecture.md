# Research: Antigravity Native Rule Discovery Architecture & Specification

**Ngày tạo:** 2026-07-22  
**Cập nhật lần cuối:** 2026-07-23 15:25:00 (UTC+7)  
**Phạm vi:** Google Antigravity IDE (Bản Đen), Antigravity 2.0 Standalone App (Bản Trắng), `agy` CLI, AkiClaudeDoc Ecosystem Integration  
**Trạng thái:** Confirmed / Empirical Evidence Verified  

---

## 1. Tổng quan Kiến trúc Ứng dụng & Phân định Vai trò

Từ phiên bản 2.0, hệ sinh thái Google Antigravity chia thành 2 ứng dụng độc lập trên cùng một nền tảng Agentic Engine:

| Đặc điểm | Antigravity Standalone App (Logo Nền Trắng) | Antigravity IDE (Logo Nền Đen) |
|---|---|---|
| **Vai trò chính** | **Agent Manager / Command Center:** Điều phối các AI Agent, chạy task ngầm/dài hạn, lập lịch tự động (cron/schedule). | **Code Editor & Pair Programmer:** Môi trường lập trình dựa trên VS Code, tương tác code inline và refactor trực tiếp. |
| **Giao diện** | Giao diện quản lý Agent-first (không bộ gõ code editor). | Giao diện IDE tích hợp đầy đủ file tree, terminal, editor canvas. |
| **Xung đột khi mở cùng lúc** | **Không xung đột logic:** Cả 2 app dùng chung engine và bổ trợ cho nhau.<br>*Lưu ý:* Tránh để Agent bên bản Trắng sửa cùng 1 file mà bản Đen đang mở chưa lưu (unsaved changes). |

---

## 2. Chứng cứ Kỹ thuật & Liên kết Tài liệu Chính thức

### 2.1. Nguồn tài liệu chính thức (Official Specs & Links)
- **Rules Documentation Home:** `https://antigravity.google/docs/rules`
- **Agent Permissions & Security Spec:** `https://antigravity.google/docs/agent-permissions`
- **Skills & Customizations Spec:** `https://antigravity.google/docs/skills`

### 2.2. Cơ chế Nạp Quy tắc (Daemon-less Native Discovery)
- **Không có tiến trình chạy ngầm:** Hệ thống `AkiClaudeDoc` chỉ đóng vai trò script cài đặt tĩnh (`install.sh`), copy/biên dịch file rule vào đĩa local (`~/.gemini/GEMINI.md`). `AkiClaudeDoc` không chạy bất kỳ daemon/background process nào.
- **Client Native Discovery:** Khi khởi chạy phiên làm việc mới, chính Antigravity Client (App Trắng, IDE Đen, hoặc `agy` CLI) thực hiện lệnh đọc đĩa (`File I/O`) để nạp các file quy tắc và nhét vào khối thẻ `<user_rules>` của System Prompt gửi tới LLM Model.

---

## 3. Phân tích So sánh: `GEMINI.md` vs `AGENTS.md`

### 3.1. Bản chất & Tiêu chuẩn
- **`GEMINI.md`:** Là tiêu chuẩn **Native Legacy Standard** ban đầu của Google Gemini CLI và Antigravity 1.0. Mang tên định danh chuyên biệt cho hệ sinh thái Google.
- **`AGENTS.md` (và cấu trúc `.agents/`):** Là tiêu chuẩn **Native Modern Standard** từ Antigravity 2.0 trở đi. Thiết kế theo hướng **LLM-Agnostic** (liên nền tảng) giúp dùng chung quy tắc giữa các công cụ AI khác nhau (Antigravity, Claude Code, Cursor,...).

### 3.2. Thứ tự Ưu tiên & Giải quyết Xung đột (Conflict Resolution)
Khi cả `GEMINI.md` và `AGENTS.md` cùng tồn tại ở một cấp độ hoặc giữa Global và Workspace, Antigravity áp dụng bảng phân cấp ưu tiên chính thức sau (trích từ `https://antigravity.google/docs/rules`):

| Thứ tự ưu tiên | Cấp độ Rule | Vị trí Tệp / Nguồn | Mô tả Chi tiết |
|---|---|---|---|
| **1 (Cao nhất)** | User Direct Prompt | Giao diện Chat (Direct Turn) | Lời dặn/câu hỏi trực tiếp trong lượt chat luôn đè lên mọi file rule tĩnh. |
| **2** | Workspace Specific Native | `<workspace_root>/GEMINI.md` | Ưu tiên hàng đầu trong các file tĩnh của project trên Antigravity Engine. |
| **3** | Workspace Generic Standard | `<workspace_root>/AGENTS.md`<br>`<workspace_root>/.agents/rules/` | Fallback quy tắc project dùng chung liên nền tảng (cross-tool). |
| **4** | Global Specific Native | `~/.gemini/GEMINI.md` | Quy tắc chung toàn máy của Antigravity (nơi chứa `[AKIRULE-AG-OVERRIDES]`). |
| **5 (Thấp nhất)** | Global Generic Standard | `~/.gemini/config/AGENTS.md` | Quy tắc chung toàn máy dạng generic. |

> **Nguyên tắc vàng khi có xung đột:**  
> Nếu `GEMINI.md` và `AGENTS.md` có 2 điều khoản mâu thuẫn nhau tại cùng thư mục gốc project: **Antigravity Engine sẽ ưu tiên thi hành điều khoản nằm trong `GEMINI.md`**.

> [!IMPORTANT] **Trạng thái kiểm chứng (2026-07-22).** Hai mức trong bảng trên có độ tin cậy khác nhau — đừng đọc cả bảng như nhau:
>
> - ✅ **Đã xác nhận thực nghiệm:** `~/.gemini/GEMINI.md` (mức 4) **thực sự được nạp**, ở cả ba bề mặt — AG desktop, AG IDE, và AGY CLI. Bằng chứng là dấu vân tay `[AKIRULE-AG-OVERRIDES-V…]` xuất hiện trong context của cả ba. Đây là quan sát trực tiếp, không phải suy luận.
> - ⚠️ **Chưa kiểm chứng:** thứ tự `GEMINI.md` **trên** `AGENTS.md` (mức 2 vs 3, và "nguyên tắc vàng"). Spec do vendor ship kèm `agy` (`~/.gemini/antigravity-cli/builtin/skills/agy-customizations/SKILL.md`) mô tả hai file này là **cùng một loại customization**, phát hiện ở cùng một cấp và khử trùng lặp theo đường dẫn — không có thứ tự ưu tiên nào giữa chúng. Cho tới khi có test phân giải, **đừng thiết kế hệ thống dựa vào việc `GEMINI.md` đè được `AGENTS.md`.**
> - ⚠️ **Chưa kiểm chứng:** `~/.gemini/config/` được spec gọi là "Global Customizations Root". Việc nó xếp *dưới* `~/.gemini/GEMINI.md` là suy đoán từ bảng web, chưa đối chiếu hành vi.
>
> Một lần suy luận trước đây đã đi từ string trong binary mà kết luận sai rằng `~/.gemini/GEMINI.md` không hề được đọc. Bài học: **ở vùng này, quan sát runtime thắng suy luận tĩnh** — thí nghiệm canary (đặt câu đánh dấu khác nhau vào từng vị trí rồi hỏi agent thấy câu nào) là trọng tài duy nhất.

---

## 4. Mô hình Phối hợp trong Hệ sinh thái AkiClaudeDoc

```text
[AkiClaudeDoc Centralized Repo]
<source-repo>/payload/          (đường dẫn thật của máy nằm ở ~/.aki/claudedoc/.source-repo)
          │
          │ (Chạy `bash install.sh` tĩnh)
          ▼
┌───────────────────────────────┬───────────────────────────────┐
│ Target 1: Claude Code Agent   │ Target 2: Antigravity Engine  │
│ ~/.claude/CLAUDE.md           │ ~/.gemini/GEMINI.md           │
└───────────────────────────────┴───────────────────────────────┘
                                          │
                                          │ (Native File I/O Scan)
                                          ▼
                               [Antigravity Client (Trắng/Đen/CLI)]
                                 • Inject vào <user_rules>
                                 • Thực thi theo Prompt Hierarchy
```

1. **Centralized SSOT:** Sửa quy tắc tại `<source-repo>/payload/`.
2. **Deployer:** Chạy `bash install.sh` để cập nhật `~/.gemini/GEMINI.md`.
3. **Runtime Execution:** Antigravity tự động đọc `~/.gemini/GEMINI.md` và `<workspace>/GEMINI.md` mỗi khi tương tác với người dùng.

---

## 5. Kết quả Kiểm chứng Cross-Platform (2026-07-23)

### 5.1. Phát hiện mới về `trigger: glob`
- Rule với `trigger: glob` (ví dụ: `akirule-stack-tauri.md`, `akirule-stack-akinuxtcf.md`) **không xuất hiện trong context dump ban đầu**. Đây là thiết kế có chủ đích của Antigravity Engine nhằm tiết kiệm token budget.
- Engine giữ glob rules trên đĩa và chỉ inject vào context khi user tương tác với file khớp glob pattern (`.rs`, `.vue`, `tauri.conf.json`, v.v.).
- Hệ quả: test "liệt kê context" sẽ **luôn luôn** báo thiếu glob rules. Test đúng: mở file khớp pattern rồi kiểm tra rule có được nạp không.

### 5.2. Phát hiện mới về Skill Discovery
- `skills.json` với đường dẫn `~` (tilde) **không được AG parser mở rộng**. Parser đọc literal string, không gọi shell expansion.
- Giải pháp: rsync trực tiếp vào `~/.gemini/config/skills/` (Standard Global Customizations Root) — AG auto-discover 100% tại đây mà không cần `skills.json`.
- `skills.json` giữ lại làm secondary với cả absolute path lẫn tilde path.

### 5.3. YAML Frontmatter cho SKILL.md
- Các trường `name:` và `description:` trong YAML frontmatter **phải nằm trên dòng vật lý riêng biệt**.
- Nếu dính liền trên 1 dòng (`name: x description: y`), AG parser đọc toàn bộ thành giá trị của `name`, key `description` biến mất → skill bị skip âm thầm.

### 5.4. Ma trận Kiểm chứng

| Surface | OS | Skills (5/5) | Rules (13/13) | Kết quả |
|---|---|---|---|---|
| AG IDE | macOS | ✅ | ✅ | PASS |
| AGY CLI | Linux | ✅ | ✅ | PASS |
| Claude Code | macOS | ✅ | ✅ | PASS |
| Claude Code | Linux | ✅ | ✅ | PASS |
