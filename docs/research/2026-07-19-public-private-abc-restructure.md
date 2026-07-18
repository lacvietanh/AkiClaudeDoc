# Chuẩn hoá AkiClaudeDoc — tách chung/riêng + tái cấu trúc A/B/C

**Ngày**: 2026-07-19 · **Trạng thái**: ✅ Đã thực thi lên `payload/` + `claude/` + propagate
**Loại**: decision record + execution tracker (bản md này để agent tự dõi theo khi thực thi).

> Đây là bản quyết định + kế hoạch. HTML trực quan: `REPORT.html` ở gốc repo (bản đọc nhanh).
> Nguồn sự thật là file này, không phải HTML.

---

## 1. Vấn đề (restate)

AkiClaudeDoc là repo **public** (đã share, auto-load qua `akirule`). Nó ra đời **trước** khi
`AkiNuxtCf/UNIDOC` tồn tại, nên một phần nội dung thực chất là **đặc thù riêng hệ sinh thái Aki**
(canonical component names, `aki-info-detect`, `usePageSeo`, `releases.json`…) — thứ giờ đã có nhà
riêng là UNIDOC. Ba việc:

1. Tách bạch cái **chung** (auto, public, mọi người) khỏi cái **riêng** (đặc thù Aki).
2. Sau khi tách, **tinh gọn** phần còn lại thành nhóm rõ ràng.
3. Đặt **mã gọi dễ nhớ**: mỗi file = 1 topic → nhóm A/B/C → điều 1/2/3.

## 2. Chuỗi mục tiêu (goal chain)

Gọn context khi context-switch cao (user làm ~20 dự án) → mỗi rule dễ định vị/nhắc đích danh →
ranh giới public/private rõ để lỡ share không lộ tài sản riêng → **mục tiêu tối thượng: rule corpus
vừa tiện cho user chính, vừa an toàn để public, không tăng gánh bảo trì.**

Xung đột mục tiêu đã nhận diện: **"sạch để public" ↔ "tiện cho user chính"**. User là người dùng
chính → **ưu tiên tiện** (giữ auto-load), "sạch public" hạ xuống thành *nhãn logic* thay vì tách
vật lý.

## 3. Phát hiện gốc (first principles)

- **Doctrine tách public/private ĐÃ tồn tại**: `UNIDOC/arch/knowledge-governance.md §3` +
  `UNIDOC/plan/done/2026-07-05-standard-public-allocation.md`. Luật: AkiClaudeDoc = public, tự đứng
  được, không nhắc UNIDOC/site nào. → Đây là **audit tuân thủ**, không phải bài toán mới.
- **Rò rỉ chỉ ở 3 file lai**, không phải cả 14: `RULE-seo`, `RULE-release`, `RULE-stack-akiNuxtCf`.
  11 file còn lại đã universal đúng chuẩn.
- **Phần Aki-private trong `stack` gần như đã mirror sẵn** trong STANDARD qua `(mirror:)`. Đây vừa
  là gánh nặng đồng bộ 2 chiều thủ công (drift-prone), vừa là cơ hội: cô lập được rõ ràng.

## 4. Quyết định (đã chốt — tự quyết để giảm tải cho user)

| # | Quyết định | Lý do |
|---|---|---|
| D1 | **Không dời file sang UNIDOC, không gate bằng trigger.** Giữ nguyên repo, giữ auto-load. | User là user chính → ưu tiên tiện, được nhắc tự động. |
| D2 | **Tách chung/riêng bằng nhãn logic, không tách vật lý.** Chỉ 3 file lai có phần riêng → dồn vào **nhóm cuối gắn cờ `⟨Aki⟩`**. | Ranh giới hiện rõ mà không mất tiện; sau này muốn xuất public sạch chỉ strip nhóm `⟨Aki⟩`. |
| D3 | **Không đổi tên file.** A/B/C là cấu trúc *bên trong* file. | Đổi tên phá `(mirror:)` trong STANDARD + tham chiếu `akitao.com` + SKILL/index/install. Không đáng. |
| D4 | **Sơ đồ địa chỉ 3 tầng**: `topic.A2` (vd `coding.B3`, `stack.C1`). Topic = tên file bỏ tiền tố `RULE-`/`METHOD-`. | Dễ nhắc, dễ nhớ, ổn định. |
| D5 | Cờ `⟨Aki⟩` **chỉ để tài liệu hoá + sẵn sàng strip** (MVP). Chưa làm install-flag lọc tự động đợt này. | YAGNI — chưa có nhu cầu xuất bản public riêng ngay. |
| D6 | **Chưa sửa 14 file rule trong đợt tạo báo cáo này.** Báo cáo là bản kế hoạch để review + dõi theo. | Sửa rule chung ảnh hưởng ~20 dự án → cần user liếc kế hoạch trước (RULE-agent-behavior: decision boundaries). |

## 5. Phản biện (rejected alternatives)

- **Dời hẳn sang UNIDOC** (bị loại): sạch nhất về lý thuyết, khớp doctrine, diệt `(mirror:)`. Loại
  vì mất auto-load tiện cho user chính — chính điều user nói "sẽ mệt".
- **Gate bằng trigger "UNIDOC"** (bị loại): file ở lại repo nhưng chỉ nạp khi gõ "UNIDOC". Loại vì
  (a) vẫn ship nội dung riêng trong bản install public; (b) user không muốn phải gọi tay.
- **Đổi tên file sang mã A1.md…** (bị loại): xem D3 — chi phí phá tham chiếu > lợi ích.

**Pre-mortem** (điều cần canh, mục 8): ranh giới general/private *bên trong* `seo`/`release` mờ →
nguy cơ nhét đặc thù Aki lại vào nhóm A/B universal vì tiện tay. Cờ `⟨Aki⟩` + "nhóm cuối" là hàng
rào chống việc đó.

## 6. Sơ đồ tái cấu trúc A/B/C (bản thực thi tham chiếu)

Quy ước: **`⟨Aki⟩`** = nhóm đặc thù hệ Aki (strip được khi public). File không có `⟨Aki⟩` = universal 100%.

### Core (Tier 1 — auto mọi task)

**`agent`** — RULE-agent-behavior *(public)*
- **A. Giao tiếp** — A1 Response language · A2 Working style
- **B. Kỷ luật phạm vi & quyết định** — B1 Scope discipline · B2 Verification & claims · B3 Decision boundaries
- **C. File & bộ nhớ** — C1 File creation/naming · C2 File vs chat separation · C3 File formatting · C4 Memory discipline

**`coding`** — RULE-coding *(public)*
- **A. Triết lý & nguồn sự thật** — A1 Language · A2 Philosophy (MVP/DRY/YAGNI) · A3 Source of truth
- **B. Chất lượng & sửa code** — B1 Code quality · B2 Changing existing code (before/after) · B3 Verification
- **C. An toàn runtime** — C1 Error handling (+ no fake data) · C2 Result pattern · C3 Performance · C4 Security · C5 Unicode/UTF-8 safety

### Contextual (Tier 2 — theo signal)

**`design`** — RULE-design-core *(public)*
- **A. 8 định luật** — A1..A8 (SSoT · Rule-of-Three · SRP-"and" · OCP · Composition · Stable boundaries · Name-by-role · One-flow-not-guarded)
- **B. Phân rã & quét rừng** — B1 Module decomposition · B2 Forest pass · B3 Critique gate
- **C. Chốt** — C1 Definition of done (design level)

**`db`** — RULE-db-design *(public)*
- **A. Nguyên tắc dữ liệu** — A1 Immutability/Event Sourcing · A2 1NF atomicity · A3 Bounded Context · A4 Flat queries
- **B. Unicode** — B1 DB không phải lưới an toàn Unicode

**`docs`** — RULE-docs *(public)*
- **A. Cấu trúc topic** — A1 Topic folders · A2 Business backbone `docs/biz/` · A3 Index
- **B. Vòng đời & đồng bộ** — B1 Plan lifecycle · B2 Documentation behavior

**`content`** — RULE-content-write *(public)*
- **A. Nguyên tắc nội dung** — A1 Scope · A2 Semantic stability
- **B. Văn phong & pattern** — B1 Interface text patterns · B2 Writing style · B3 Human+LLM readability
- **C. Tách bạch** — C1 Separation (chat ↔ product copy)

**`seo`** — RULE-seo *(mixed → nhóm C là ⟨Aki⟩)*
- **A. Meta & cấu trúc** — A1 Meta title/description limits · A2 Schema.org matrix · A3 Trailing slash · A4 Robots & sitemap · A5 OG image
- **B. Hiển thị AI & entity** — B1 AI/LLM visibility · B2 Entity & ecosystem linking · B3 Vietnamese keyword handling · B4 Prerender/SSR cho SEO
- **C. ⟨Aki⟩ API & tooling stack** — C1 `usePageSeo` API · C2 `@nuxtjs/seo` titleTemplate · C3 `validate-seo.js` checklist

**`release`** — RULE-release *(mixed → nhóm C là ⟨Aki⟩)*
- **A. Versioning core** — A1 CHANGELOG bắt buộc/scope · A2 Semver levels · A3 Version string format (no-`v`) · A4 Bump theo severity
- **B. Xác định & audit** — B1 Cold-start version identification · B2 Anti-skip invariant · B3 Audit mode · B4 GitHub Release output · B5 Content discipline
- **C. ⟨Aki⟩ Web release artifacts** — C1 Two channels (CHANGELOG vs releases.json) · C2 releases.json schema · C3 No gaps in releases.json · C4 Sync check

**`stack`** — RULE-stack-akiNuxtCf *(mixed → nhóm C là ⟨Aki⟩; file lai nặng nhất)*
- **A. Cloudflare & TypeScript nền** — A1 Build & TS (strict · script-setup · relative server imports · clean build · npm/node build-image pin) · A2 Worker runtime constraints (no fs/child_process · fetch · crypto.subtle · Unicode-byte) · A3 Preset & output (`cloudflare_pages` · `dist/`)
- **B. Render · i18n · Vue patterns** — B1 Rendering split (SSG/SSR/SPA · noindex admin) · B2 Vue/Nuxt patterns (`:key` · NuxtLink · `useSwal` · attr order) · B3 i18n (co-location · trailingSlash · strategy) · B4 State (useState-first · localStorage onMounted) · B5 UI baseline (z-index/radius scale · FA Free · aria · favicon/manifest)
- **C. ⟨Aki⟩ Quy ước hệ sinh thái** — C1 Canonical component names · C2 Layout chrome (breadcrumb/scroll-to-top) · C3 Layout width SSoT · C4 Admin isolation + `i18n.pages=false` + `localePath` undefined-trap · C5 Firebase composable boundary · C6 `aki-info-detect` + AkiTao favicon tool · C7 Dev scripts (killport/D1) · C8 Deploy verification (wrangler pages)

**`tauri`** — RULE-stack-tauri *(public — bài học Tauri tổng quát)*
- **A. Không block UI** — A1 Never block UI / `spawn_blocking` · A2 Subprocess PATH cold-start race
- **B. Boundary & config** — B1 Titlebar boundary · B2 IPC capability silent-fail · B3 Serde `#[serde(default)]` · B4 `cfg(target_os)` scoping · B5 Version SSOT

**`ui`** — RULE-ui-pattern *(public — enforcement design-system; trỏ `stack.C1` cho canonical names)*
- **A. Taxonomy & tokens** — A1 Four-tier class taxonomy · A2 Design tokens SSoT · A3 Arbitrary-value policy
- **B. Cấu trúc component** — B1 Atomic structure · B2 Variant API · B3 Composition not copy · B4 Documentation duty
- **C. Audit playbook** — C1 Inventory scan · C2 Classify severity · C3 Priority matrix · C4 Safe refactor loop · C5 Scorecard

### Analytical (on-demand / Tier 3)

**`think`** — METHOD-deep-think *(public)*
- **A. Khung quyết định** — A1 One-way vs two-way door · A2 Two modes (passive/active)
- **B. 5 Modules** — B1 Goal excavation · B2 First principles · B3 Critique · B4 Techbiz lens · B5 MVP/SFX/EC
- **C. Radar** — C1 Radar rule (escalate `/akithink`)

**`flow`** — METHOD-flow-audit *(public)*
- **A. Tư duy flow** — A1 Core mindset · A2 When to use
- **B. 8 câu hỏi first-principles** — B1..B8
- **C. Chốt & output** — C1 Decision test · C2 Red flags · C3 Output format

## 7. Checklist thực thi (đã xong)

- [x] Áp cấu trúc A/B/C + đánh số vào từng file `payload/*.md` (13 file rule/method; không đổi tên file).
- [x] Gắn cờ `⟨Aki⟩` cho `seo.C`, `release.C`, `stack.C`.
- [x] Cập nhật `payload/index.md`: thêm cột Topic/Loại + bảng địa chỉ `topic.A/B/C`.
- [x] Cập nhật `claude/skills/akirule/SKILL.md`: giới thiệu sơ đồ địa chỉ (không đổi logic routing).
- [x] Cập nhật `README.md` (manifest/what-you-get) cho khớp cấu trúc mới.
- [x] `CHANGELOG.md`: 1 entry cho đợt tái cấu trúc 2026-07-19.
- [x] `bash install.sh` để propagate xuống `~/.aki/claudedoc` — thành công, output liệt kê đúng cột Loại mới.
- [x] Soát `(mirror:)` trong STANDARD vẫn trỏ đúng — `grep` xác nhận mọi marker vẫn trỏ tên file cũ (`RULE-stack`, `RULE-db-design`), không có gì vỡ vì không đổi tên file.

**Lệch nhỏ so với sơ đồ gốc (mục 6), ghi nhận để tránh nhầm lẫn khi tra cứu:**
- `content`: sơ đồ gốc bỏ sót mục "Interface text" (UI language) → thêm làm `content.A2`, đẩy Semantic
  stability thành `content.A3` (thay vì A1–2 như dự kiến ban đầu).

## 8. Giả định cần canh (assumptions to monitor)

- **A1** — Các web project của Aki lấy stack-rule qua `akirule` auto-load, KHÔNG hardcode đường dẫn
  `RULE-stack-akiNuxtCf.md`. *(Cần verify trước khi thực thi; nếu có project ref cứng thì không sao
  vì ta không đổi tên/vị trí — chỉ cấu trúc nội bộ đổi.)*
- **A2** — Không đổi tên file ⇒ `(mirror:)` markers + `akitao.com` FAQ + install.sh vẫn đúng.
- **A3** — Cờ `⟨Aki⟩` đủ làm hàng rào chống rò rỉ ngược; nếu vẫn thấy đặc thù Aki lọt vào nhóm A/B
  universal, cân nhắc nâng lên cơ chế strip tự động (D5 revisit).

## 9. Bottom line

Giữ nguyên repo + auto-load (tiện cho user chính). Tách chung/riêng bằng **nhãn logic `⟨Aki⟩`** cô
lập vào nhóm cuối của đúng **3 file lai** (`seo`/`release`/`stack`). Tái cấu trúc **mọi file** thành
**nhóm A/B/C + điều 1/2/3**, gọi bằng `topic.A2`. Không đổi tên file, không dời sang UNIDOC. Báo
cáo này là bản kế hoạch để dõi theo; thực thi lên `payload/` là bước sau khi user duyệt.
