# Plan — Gom luật đặt tên thành một địa chỉ gọi được

**Trạng thái:** 🟢 đã chốt (phương án D, 2026-07-21) · **Mở:** 2026-07-21 · **Phạm vi:** `payload/` (ảnh hưởng nhiều dự án)

## 1. Vấn đề

Luật đặt tên hiện **rải khắp 5 file**, không có địa chỉ nào để gọi. Khi cần viện dẫn "luật naming", không biết trỏ vào đâu:

| Địa chỉ | Nội dung | Phạm vi |
|---|---|---|
| `agent.C1` | Tên file: ngắn, literal, ổn định; cấm `misc`/`draft`/`new`/`temp`; theo convention sẵn có của dự án trước | file |
| `design.A7` | Name by role, never by concrete value (`retryLimit` không phải `three`) | mọi định danh |
| `coding.B1` | "Use clear, descriptive names" | code |
| `stack.C1` | Bảng canonical component names | ⟨Aki⟩ Nuxt |
| `ui` (dòng 18, 107) | Trỏ lại `design.A7` + cấm tự đặt tên component mới ngoài `stack.C1` | ⟨Aki⟩ UI |

Ngoài ra `RULE-content-write.md` giữ **semantic stability** (đổi tên một khái niệm dùng xuyên sản phẩm) — cùng họ vấn đề nhưng nằm ở file thứ 6.

## 2. Chẩn đoán

Đây là **`design.A1` (SSoT) bị vi phạm ngay trong chính bộ luật**: một chủ đề, năm nơi chứa, không nơi nào là gốc. Ba hệ quả đo được:

1. **Khó gọi** — không có `naming.*` để viện dẫn; phải nhớ 5 địa chỉ khác nhau.
2. **Khó nhớ** — người dùng (chủ sở hữu bộ luật) không nhớ nổi nó nằm đâu. Nếu tác giả không nhớ thì agent lại càng không.
3. **Khó biết đủ chưa** — không có chỗ nào liệt kê trọn vẹn để rà. `coding.B1` ("clear, descriptive names") thực chất **rỗng nghĩa và trùng** `design.A7`, nhưng không thấy được vì nằm khác file.

## 3. Câu hỏi cần trả lời trước khi làm

- **Naming có đủ trọng lượng để thành file riêng không?** Đối chiếu `design.A2` (Rule of Three): đã lặp ở ≥3 nơi, ≥2 ngữ cảnh không liên quan → **đủ chứng cứ để trích xuất**. Nhưng file mới cũng là một tầng gián tiếp mới; cần cân với phương án B bên dưới.
- **Ranh giới với `design`?** Naming *là* một định luật thiết kế (`A7`). Tách ra có làm `design` mất tính trọn vẹn không?
- **⟨Aki⟩ `stack.C1` có kéo theo không?** Bảng canonical component name là fact riêng hệ sinh thái, không nên rời khỏi `stack`.

## 4. Ba phương án

| | Phương án | Được | Mất |
|---|---|---|---|
| **A** | File mới `RULE-naming.md`, topic `naming` | Có địa chỉ `naming.A1`; một nơi để rà đủ | Thêm 1 file vào Tier 2; phải viết signal cho router; `design.A7` rỗng đi hoặc thành trỏ chéo |
| **B** | Gom vào `design`, thành nhóm riêng `design.D` | Không thêm file; naming vốn là luật thiết kế | `design` phình; vẫn phải nhớ "naming nằm trong design" |
| **C** | Giữ nguyên, chỉ thêm bảng tra ở `index.md` | Rẻ nhất, không đụng nội dung | Không sửa gốc: vẫn 5 nơi, chỉ dễ tìm hơn |

## 5. Chẩn đoán lại (akithink 2026-07-21) — §2 sai khung

Phần §2 gộp hai vấn đề khác nhau vào một nhãn "vi phạm SSoT". Tách ra thì thấy **chỉ 1/5 địa chỉ là trùng lặp thật**:

| Địa chỉ | Loại | Xử lý |
|---|---|---|
| `design.A7` — name by role | **Gốc nguyên lý** | Giữ, tuyên bố là root |
| `coding.B1` — "clear, descriptive names" | **Trùng thật** (rỗng nghĩa, nói lại A7) | Xoá, thay bằng con trỏ |
| `agent.C1` — tên file, cấm `misc`/`temp` | Đối tượng khác (file ≠ định danh code) | Giữ tại chỗ |
| `stack.C1` — canonical component names | Fact ⟨Aki⟩, áp dụng cục bộ | Giữ tại chỗ |
| `ui` L18/L107 | **Đã trỏ chéo** về `design.A7` → đúng SSoT rồi | Giữ |
| `release` v-prefix · `content` semantic stability | Áp dụng cục bộ trong domain | Giữ |

`design.A1` nói: mỗi rule sống một chỗ, **chỗ khác tham chiếu**. Con trỏ không phải bản sao. Vậy cái còn thiếu không phải "gốc", mà là **địa chỉ gọi được + chỗ rà cho đủ** — đây là bài toán *findability*, không phải *SSoT*. Ràng buộc của Aki ("bỏ khỏi rule lẻ là bị hụt") chính là bằng chứng: các mục kia không phải bản sao, mà là **áp dụng** — di dời chúng sẽ bóc ngữ cảnh khỏi nơi cần đọc.

**Pre-mortem của phương án A:** 6 tháng sau, `RULE-naming.md` tồn tại nhưng các mục domain vẫn nằm nguyên chỗ cũ (vì đúng là phải nằm đó) → naming từ 5 nơi thành **6 nơi**, cộng thêm 1 signal router có thể không kích hoạt (mỗi hop mềm là một lần model bỏ qua — xem `UNIDOC/DEV.MD §3`). File mới không xoá được gì thì chỉ là phép cộng.

**Steelman A:** một file cho phép trả lời "đã đủ chưa?". → Được đáp ứng rẻ hơn bằng bảng lens ở `index.md` mà không thêm hop nạp. **Tấn công phương án chốt:** bảng lens có thể drift so với file nó trỏ tới. Giảm thiểu: bảng **chỉ chứa địa chỉ, không chứa chữ luật** — con trỏ lệch thì phát hiện rẻ, còn văn bản trùng thì không.

## 6. Chốt — phương án D (C+, không tạo file mới)

1. `design.A7` = **gốc chính thức** của nguyên lý đặt tên; thêm 1 câu tự khai vai trò gốc.
2. **Xoá** bullet `coding.B1` "Use clear, descriptive names" → thay bằng con trỏ `design.A7`.
3. Giữ nguyên `agent.C1`, `stack.C1`, `ui`, `release`, `content` — chúng là *áp dụng*, không phải bản sao.
4. `payload/index.md`: thêm mục **Cross-cutting lens** — bảng chỉ-địa-chỉ: `Naming → gốc design.A7 · file agent.C1 · component ⟨Aki⟩ stack.C1 · token ui.A · version/tag release.A1 · đổi tên khái niệm content`.
5. **Không** thêm lens thứ hai (security/i18n/verification…) cho tới khi có bằng chứng đau thật — `design.A2` Rule of Three áp cho chính bộ luật.
6. Không tạo file mới, không thêm signal router, không sửa `SKILL.md`.

**Giả định cần theo dõi:** nếu sau vài tháng vẫn phải nhớ 6 địa chỉ mới viện dẫn được naming, tức bảng lens không đủ → khi đó mới xét lại A.
