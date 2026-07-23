# RULE-release.md — Versioning Principle Rewrite (Proposal)

Status: ✅ Đã áp dụng (2026-07-23) — thực thi vào `payload/RULE-release.md` A4 (severity-driven bump), B1 (cold-start reconstruction), B2 (anti-skip invariant), B3 (audit mode). Scope: `payload/RULE-release.md`, mục "Versioning — semver `major.minor.patch`" và "Identify the current version before bumping" (dòng ~23-53)

---

## Vấn đề gốc (tóm tắt phân tích /akithink)

Bug report ban đầu: "mỗi khi update hay bị nhảy cóc version so với production khi có quá nhiều thay đổi chưa deploy". Ba lần bàn lại đã loại bỏ các hướng sai:

1. ~~Check version qua network (curl production endpoint)~~ — loại, vì không phải project nào cũng có endpoint (CLI, Tauri không có "production URL"), phá vỡ scope "any stack" của rule.
2. ~~Git tag khi deploy thành công~~ — loại, vì production/tag không phải gốc vấn đề: production 1.0.0 nhảy thẳng 2.0.0 vẫn có thể hoàn toàn hợp lệ nếu nội dung xứng đáng major bump. Neo vào production tự nó không phân biệt được "nhảy đúng" và "nhảy sai".

Root cause thật sự, sau khi lật lại root case bằng first-principles:

- **Cold-start fragility.** Bước "Identify current version" hiện tại (dòng 33-38) chỉ đọc `git log --oneline -3` — 3 dòng gần nhất. Nếu quá trình bump bị context-switch qua nhiều session/nhiều ngày, phần lớn thay đổi tích lũy nằm ngoài 3 dòng đó và bị bỏ sót ngay ở bước đọc dữ liệu, trước khi kịp tính version. Rule không tự phục hồi đúng trạng thái dù có quay lại chạy qua quy trình bao nhiêu lần.
- **Sai đơn vị đo "skip".** Rule hiện diễn giải "không nhảy cóc" theo **số bước cấp version** ("no skipping (e.g. `1.4.2 → 1.6.0` is invalid without explicit justification)"), chứ không theo **nội dung thay đổi**. Hệ quả: không có tiêu chí rõ ràng để phân biệt "nhảy lớn vì đúng là có breaking change" (hợp lệ) với "nhảy lớn vì bỏ sót ghi nhận một cột mốc release đã có thật" (lỗi thật).
- **Không có chế độ audit cho project có sẵn.** Rule hiện chỉ tính cho luồng "tạo mới từ đầu, kỷ luật đúng ngay từ commit đầu". Khi áp vào một project đã tồn tại với CHANGELOG lộn xộn/rời rạc/nhảy cóc từ trước (không do quy trình này tạo ra), rule không có bước nào để phát hiện và sửa hồi tố.

---

## Nội dung đề xuất thay thế

Thay đoạn "Identify the current version before bumping" (dòng 29-53 hiện tại) bằng 4 khối sau. Phần "Versioning — semver" (dòng 23-27, định nghĩa patch/minor/major) giữ nguyên không đổi.

```markdown
## Identify the current version — cold-start, not session-memory

Never rely on remembering a prior session. Every time this step runs — 5 minutes
or 5 months since the last run — it must re-derive the correct state from the
repo alone, from exactly these 3 sources:

1. `package.json` (or equivalent) — the recorded version.
2. `CHANGELOG.md` — full history, not just the top entry.
3. `git diff` / `git log` from the commit tied to the last CHANGELOG version
   entry through HEAD — the complete, unbounded list of what has accumulated
   and is not yet recorded.

Source 3 is the step most often shortcut (e.g. `git log --oneline -3`) and is
the actual cause of wrong bumps: a fixed line count silently drops everything
accumulated before it across earlier, forgotten sessions. Do not cap it.

## Bump level — driven by content severity, not by step-count or session-count

Classify every accumulated change found in source 3 independently:
- breaking / not backward-compatible → major
- new capability, backward-compatible → minor
- fix / internal-only → patch

**New version = last recorded version + exactly one step at the HIGHEST
severity found across the full accumulation.** Do not add steps per session
or per commit.

This is what makes a large jump legitimate: if the accumulation contains one
breaking change, `1.4.2 → 2.0.0` is a correct single major step — semver
itself resets minor/patch to 0 on a major bump; that is the mechanism, not an
error. A jump is invalid for a different reason entirely — see next section.

## The real anti-skip invariant

A version jump is only actually wrong when there is evidence that a release
boundary was already completed and left unrecorded — not because the number
moved by more than one minor/patch. Concretely:

- Every git tag matching a version pattern (if the project uses tags) MUST
  have exactly one matching CHANGELOG entry.
- Every entry that exists in `app/data/releases.json` (web stacks) MUST have
  exactly one matching CHANGELOG entry, and vice versa.
- CHANGELOG versions must increase monotonically with no duplicates, no gaps
  in the sequence, no entries out of order.

If a tag or milestone exists without a matching entry, that is a real gap —
write the missing entry retroactively; do not just warn and move on. If no
such boundary was skipped, a large single bump driven by severity is valid,
not a defect.

## Audit mode — for any project with a pre-existing, undisciplined CHANGELOG

Run once whenever `CHANGELOG.md` was not produced under this rule from
project inception (imported project, messy history, disorganized entries):

1. List every version appearing in `CHANGELOG.md`; verify monotonic order, no
   duplicates, no empty entries.
2. Cross-check against every version-pattern git tag (if any exist).
3. Cross-check against `app/data/releases.json` (if the project has one).
4. Report every mismatch found, specifically (which version, which source
   disagrees). Propose a retroactive entry for each real gap. Never renumber
   or delete a version that is already public.
5. Once audited, treat the repo as clean and apply the 3 sections above going
   forward.
```

---

## Việc cần làm nếu được duyệt để áp dụng thật

1. Thay thế đoạn dòng 29-53 trong `payload/RULE-release.md` bằng nội dung trên.
2. Không đổi phần semver definitions (dòng 23-27) và phần "No version gaps in releases.json" (dòng 60-68) — 2 phần này vẫn tương thích, audit mode ở trên chỉ mở rộng thêm bước cross-check.
3. Cập nhật mô tả RULE-release.md trong `payload/index.md` (dòng 21) nếu tóm tắt hiện tại không còn phản ánh đúng — cần thêm ý "cold-start version reconstruction, severity-driven bump, audit mode for legacy changelogs".
4. Kiểm tra `claude/skills/akigitcommit/SKILL.md` — hiện nó đọc CHANGELOG để nhóm commit; xác nhận nó không giả định gì về "3 dòng git log gần nhất" (không thấy phụ thuộc, nhưng cần soát lại khi áp dụng).

## Rủi ro / cần cân nhắc thêm trước khi chốt

- **Audit mode gặp gap không rõ nội dung lịch sử** (tag tồn tại nhưng không ai nhớ nó gồm gì): entry hồi tố phải ghi rõ "nội dung lịch sử không xác định được" thay vì tự suy diễn/bịa ra thay đổi.
- **Project chưa từng dùng git tag:** audit mode graceful — bỏ qua bước cross-check tag, chỉ dựa vào tính đơn điệu của CHANGELOG và (nếu có) releases.json.
- **CHANGELOG entry có thể phình to** khi nhiều severity khác nhau dồn vào 1 bản major — chấp nhận được, vì đã có tiền lệ "one release = one version; bundle the session's changes under it" trong rule gốc.
- Đây là thay đổi vào rule dùng chung nhiều project (theo `payload/index.md` § Change policy) — cần xác nhận rõ ràng trước khi ghi đè file thật.

---

Bản plan đề xuất này đã được duyệt và thực thi vào `payload/RULE-release.md` (xem status ở đầu file).
