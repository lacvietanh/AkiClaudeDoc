# RULE-release.md — A5 Review: "minted at release" vs distributed-artifact projects (Proposal)

Status: Approved & Implemented (2026-07-23) — Applied to `payload/RULE-release.md` § A5.

Scope: `payload/RULE-release.md` § A5 ("A version is minted at the release event, never at work-completion", ABSOLUTE). Không đụng tới A1-A4, B1-B5, C1-C4.

**Quan hệ với `versioning-principle-rewrite.md`:** plan đó đã xử lý xong A4 (bump level theo severity, không theo step-count) và B1 (cold-start state table, bao gồm state "Drifted"), và theo git log đã được áp dụng vào file thật. Plan này **không mở lại** phần đó — A4/B1 giữ nguyên, được coi là nền tảng đúng. Câu hỏi ở đây hẹp hơn nhiều: không phải "làm sao tính đúng version number" (A4/B1 đã trả lời), mà là "khi nào được phép mint nó" — tức đúng phạm vi của A5. Bất kỳ thay đổi nào được duyệt ở đây phải tương thích ngược với state table của B1 (đặc biệt state **Drifted**, vốn đã tồn tại chính vì A5) chứ không được mâu thuẫn với nó.

---

## Vấn đề gốc — case cụ thể làm phát sinh review này

Project: một Tauri v2 desktop app (RULE-stack-tauri.md áp dụng) tuân thủ toàn bộ Aki-RULE corpus. Lịch sử commit release gần nhất của project đó:

```
f121b27 1.12.0 - usage monitor freeze self-heal, AG timeout fix, statusline hook v3, New Project button relocation
1c1f8a0 1.11.0 - pin window across Spaces, proxy-mode locks native Claude monitor, project table narrowed, agent usage decluttered, app-icon menu consolidation
3e52a99 1.10.1 - update dialog fixes, statusline auto-install, blocking-UI fix, SSH color, AkiClaudeDoc menu
```

Mỗi commit này, trong **một** commit duy nhất: bump `package.json` + `Cargo.toml`, viết CHANGELOG section có số hiệu, và mang theo toàn bộ code thay đổi. Đây chính xác là điều A5 gọi là bug: *"Never bump the manifest `version` field in the same task as the code change. […] A task that ends with 'bumped to 0.2.0' but nothing deployed is the bug."*

Một audit (agent review theo A5) đã flag project này là vi phạm ABSOLUTE rule. Chủ project đã xem lại và kết luận: quy ước của project là **đúng và giữ nguyên** — không xin exception, mà đặt câu hỏi ngược lại: bản thân A5 có đang bị over-fit vào một loại project (web, continuously-deployed) và áp sai lên loại khác (Tauri desktop, phân phối bằng file build) hay không. Chính sự bất đồng audit-vs-owner này là bằng chứng cho thấy cần xem lại A5, chứ không phải một yêu cầu "nới lỏng rule vì project của tôi khó làm theo".

Bằng chứng phụ cho thấy A5 không vô nghĩa ngay cả với loại project này: tại thời điểm review, working tree của project đó đang ở version `1.13.0` trong manifest nhưng tag thật gần nhất chỉ là `1.12.0` — tức chính là trạng thái **Drifted** mà A5/B1 định nghĩa: bump đã mint nhưng tag/build chưa từng cắt. Vậy A5 không phải chuyện lý thuyết suông — nó đang mô tả đúng một tình huống có thật ngay trong chính project đang challenge nó.

---

## Root cause phân tích từ first-principles

A5 được viết ra để chặn một failure mode cụ thể: *drift* — local version number chạy vượt xa version đang chạy thật ("production"), tích luỹ qua nhiều session không ai theo dõi, tới lúc release thì đã sai lệch (ví dụ mint `0.3.4` trong khi đáng lẽ là `0.2.0`). Cơ chế A5 chọn để chặn: tách rời hoàn toàn hành động "ghi nhận version" khỏi hành động "hoàn thành code", bắt buộc dùng bucket `[Unreleased]` làm vùng đệm trung gian.

Cơ chế đó **ngầm giả định một topology cụ thể**: có một "production" đang chạy, tách biệt về thời gian và không gian khỏi local — nghĩa là continuously-deployed target (web app, service). Trong topology đó:
- "Released" là một sự kiện xảy ra **sau và tách rời** khỏi "code xong" — có thể là do CI/CD, do người khác approve deploy, do một cron, do khách hàng chưa muốn lên bản mới — và **có thể không bao giờ tới** trong một khoảng thời gian dài.
- Vì vậy local (đã code xong) và production (đã deploy) là hai trạng thái có thể lệch nhau tuỳ ý về thời gian, và rule cần một cách ghi nhận "đã code xong nhưng chưa lên production" mà không mint số — đó chính là `[Unreleased]`.

Nhưng với một project phân phối bằng artifact rời rạc (Tauri desktop `.dmg`, CLI binary, bất cứ gì build ra một file rồi phát hành) — **"release" và "build ra artifact" là cùng một sự kiện, không phải hai**. Không có "production" chạy độc lập để lệch khỏi. Artifact build ra **từ** chính manifest đã bump — bump không "chạy trước" build, nó **là một phần cấu thành** của build. Nói cách khác: với loại project này, "work-completion" cho một release cycle và "release event" có xu hướng trùng khít về mặt logic, vì hành động build luôn đọc version từ manifest tại thời điểm build — không tồn tại khoảng "code xong, để đó, rồi sau đó mới release" theo kiểu web (không có ai "deploy hộ" một file .dmg đã build sẵn vào một ngày khác mà không build lại).

Nếu đúng vậy, yêu cầu bucket `[Unreleased]` + tách bump ra một task riêng, cho loại project này, đang thêm một bước bắt buộc để phòng một loại drift **về mặt cấu trúc không thể xảy ra** trong topology đó — tức là over-fit: root cause thật của A5 (rule hiện có) là chống drift-do-continuously-deployed-topology, nhưng văn bản lại viết như một invariant universal, không phân biệt topology.

### Steelman: giữ nguyên A5, không đổi gì

Trước khi đề xuất tách, cần xét nghiêm túc lý do A5 nên đứng nguyên:

1. **Bằng chứng phản biện mạnh nhất: "bump rồi không bao giờ build" vẫn drift, kể cả ở artifact project.** Chính project nêu trên đang ở trạng thái Drifted (`1.13.0` trong manifest, tag thật dừng ở `1.12.0`) — nghĩa là "bump cùng lúc với code" không hề miễn nhiễm với drift. Task hoàn thành, ghi "bumped to 1.13.0", nhưng chưa có tag/build/dmg nào cắt ra — đúng nguyên văn câu A5 mô tả là bug. Vậy lý lẽ "artifact project không có khoảng lệch để drift" là **sai trên thực tế quan sát được**, không chỉ là lý thuyết.
2. **A5 không chỉ chống drift-số — nó còn chống "version rác" (materiality test).** Việc bump-cùng-code dễ dẫn tới mint version cho những thay đổi nhỏ không đáng một con số riêng (three versions of two bullets each). `[Unreleased]` ép người viết phải nhìn toàn bộ accumulation trước khi quyết định có đáng mint hay không. Nếu bỏ yêu cầu này cho artifact project, project có thể quay lại thói quen mint version cho từng patch nhỏ nhặt mà không có bước "cân nhắc materiality" nào chặn lại.
3. **"Build luôn đọc version tại thời điểm build" là giả định về kỷ luật, không phải sự thật cấu trúc.** Không có gì ngăn một người bump manifest, không build ngay, làm thêm việc khác vài ngày, rồi mới build — lúc đó khoảng lệch y hệt web project vẫn tồn tại. Nói "artifact project không có production riêng nên không có gì để lệch" nhầm lẫn giữa *có deploy target riêng biệt* và *có khoảng thời gian giữa mint và build* — hai thứ độc lập nhau.
4. **Một rule chung cho nhiều project cần một bất biến đơn giản, không cần biết stack.** A5 hiện tại có lợi thế là không cần hỏi "project này có tách rời deploy khỏi build không" — nó áp dụng như nhau bất kể topology. Thêm một nhánh điều kiện theo topology tăng chi phí nhận thức mỗi lần áp dụng rule (phải phân loại project trước khi biết áp bản nào), đúng loại phức tạp mà corpus này cố tránh.

Sau khi cân nhắc 4 điểm trên, steelman không hoàn toàn vô hiệu, nhưng điểm (1) — bằng chứng thực tế đang là ngoại lệ hỗ trợ A5, không phải phản bác nó — cho thấy vấn đề thật không nằm ở chỗ A5 sai, mà ở chỗ **cơ chế A5 chọn để chặn (buộc tách task) có thể không phải cơ chế duy nhất chặn được cùng một thứ**. Việc phân biệt topology, nếu làm, phải giữ lại đúng cái A5 bảo vệ (không mint version rác, không drift không phát hiện được) chứ không phải bỏ bảo vệ đó đi.

---

## Câu hỏi mở cần trả lời chính xác

A5 có đang gộp chung hai topology khác nhau — (a) continuously-deployed (web, service) nơi "released" là một sự kiện tách rời có thể trễ vô hạn định, và (b) distributed-artifact (desktop app, CLI, bất cứ gì build-and-ship) nơi "released" về logic trùng với "build ra artifact từ manifest đã bump" — và nếu đúng, A5 nên được **tách theo điều kiện** (một điều khoản riêng cho nhóm (b)) thay vì **nới lỏng chung** cho toàn bộ rule? Đây là câu hỏi cần trả lời, chưa phải kết luận.

---

## Hai hướng giải quyết ứng viên

### (a) Giữ A5 áp dụng vô điều kiện, thêm một điều khoản riêng cho distributed-artifact

Thêm một sub-clause định nghĩa: với project loại (b), "release event" hợp lệ là **hành động bump + tag + build xảy ra atomic trong cùng một commit/task** — miễn là build/tag thực sự được cắt ra ngay sau đó (không chỉ bump rồi để đó). Bucket `[Unreleased]` trở thành optional cho loại project này: nếu một task tự tin đó là điểm dừng release (sẽ build/tag ngay), được phép bump + viết CHANGENUM + code cùng lúc; nếu không chắc, vẫn nên dùng `[Unreleased]` như thường.

- **Ưu điểm:** giữ nguyên tinh thần "một invariant, ít ngoại lệ ẩn"; project Tauri không còn bị flag sai bởi audit; văn bản rule vẫn một chỗ, dễ tra cứu theo topology.
- **Nhược điểm:** thêm một nhánh điều kiện nghĩa là mọi lần áp A5 giờ phải phân loại project trước; định nghĩa "atomic" mơ hồ — task đó có thực sự build ngay không, hay chỉ *định* build? Rủi ro: điều khoản ngoại lệ dễ bị lạm dụng làm cái cớ cho đúng thói quen A5 vốn chặn (mint rồi quên build), như quan sát thực tế ở chính project này (`1.13.0` chưa build/tag).

### (b) Giữ A5 nguyên văn; guard thật sự còn thiếu là một invariant kiểm tra, không phải một quy trình

Không đổi A5. Thay vào đó thêm một **pre-bump check** (đặt cạnh B1 hoặc B2, không phải sửa A5): trước khi cho phép bump version tiếp theo, xác nhận **version trước đó đã có tag/build/release tương ứng**. Nếu chưa (đúng case `1.13.0`/`1.12.0` hiện tại), chặn bump mới, yêu cầu xử lý version treo trước — cắt tag/build cho nó, hoặc rollback nếu nó thực sự không cần tồn tại riêng. Bản thân quy trình "bump cùng code trong một commit" của Tauri project được giữ nguyên như một cách làm hợp lệ, miễn là mỗi bump đều đi kèm tag+build ngay sau (không có bump "treo").

- **Ưu điểm:** không cần phân loại topology — invariant là "manifest version phải luôn có tag/build đứng sau trước khi bump tiếp", áp dụng đều cho mọi loại project, kể cả web (một continuously-deployed project bump rồi không bao giờ deploy cũng bị chặn y hệt). Đây là một **check** (rẻ, máy verify được: `git tag -l` so với manifest version), không phải một **quy trình bắt buộc hai bước** (đắt, dựa vào kỷ luật con người nhớ mở/đóng bucket đúng lúc).
- **Nhược điểm:** không giải quyết được "materiality test" — vẫn có thể bump+build liên tục cho từng thay đổi nhỏ nếu không có gì nhắc dừng lại cân nhắc trước. Cũng không cấm A5 nguyên văn coi việc bump cùng-task-với-code là sai per se — nghĩa về mặt văn bản A5 (ABSOLUTE, "never bump in the same task") vẫn mâu thuẫn với thực hành Tauri project trừ khi văn bản A5 cũng được nới đúng câu chữ đó.

**Nghiêng về:** kết hợp cả hai, không chọn một. (b) là guard nền tảng nên có bất kể chọn gì — nó rẻ, máy verify được, và trực tiếp đóng đúng lỗ hổng mà case thực tế đang minh chứng (version treo không tag). Nhưng (b) một mình không giải quyết được mâu thuẫn câu chữ "never bump in the same task" — nên (a) vẫn cần một sub-clause ngắn định nghĩa rõ "release event" cho distributed-artifact, NHƯNG ràng buộc nó bằng chính guard của (b): sub-clause chỉ hợp lệ nếu "atomic bump+build" luôn đi kèm build/tag thực sự cắt ra ngay, verify được bằng check của (b) — nếu không, quay lại bị coi là Drifted như A5 gốc đã định nghĩa. Nói cách khác: (a) định nghĩa "thế nào là release event hợp lệ cho loại này", (b) là cách **phát hiện** khi ai đó nói dối định nghĩa đó (bump nhưng không build). Một mình (a) dễ bị lạm dụng; một mình (b) không giải quyết mâu thuẫn câu chữ. Cần cả hai để A5 sau khi sửa vẫn coherent với B1's Drifted row.

---

## Bằng chứng cần có để chốt

- Khảo sát toàn bộ Aki project đang dùng corpus này: phân loại project nào continuously-deployed (web/Cloudflare Pages/Workers) vs distributed-artifact (Tauri, CLI, khác) — corpus hiện có `RULE-stack-akiNuxtCf.md` (web) và `RULE-stack-tauri.md` (desktop) nên việc phân loại này có sẵn tín hiệu, không cần đoán.
- Với mỗi project distributed-artifact: kiểm tra `git tag -l | sort -V` so với version trong manifest — có bao nhiêu project đang ở trạng thái Drifted (manifest vượt tag) giống case này? Nếu nhiều, đó là bằng chứng ủng hộ hướng (b) (thiếu guard, không thiếu topology exception). Nếu case này là cá biệt, bớt cấp thiết.
- Có project continuously-deployed nào từng thực sự bị drift nghiêm trọng (mint số vượt xa production) mà A5 (ở dạng hiện tại) đã ngăn được không — hay A5 tới giờ chỉ tồn tại trên giấy, chưa có ca thật nào chứng minh nó cứu được gì? Nếu chưa từng, cân nhắc rằng A5 hiện tại có thể đang phòng một sự cố lý thuyết bằng một chi phí quy trình thực tế mỗi ngày.

---

## Việc cần làm nếu được duyệt để áp dụng thật

*(Chưa làm bất kỳ bước nào dưới đây — liệt kê để tham khảo khi có quyết định.)*

1. Xoá dòng pointer comment tạm thời dưới heading `### A5.` trong `payload/RULE-release.md`.
2. Nếu chọn hướng kết hợp (a)+(b): viết lại A5 với một sub-clause "Distributed-artifact release event" định nghĩa atomic bump+tag+build là hợp lệ, có điều kiện ràng buộc bằng guard ở bước 3.
3. Thêm guard "matching tag/build required before next bump" vào B1 hoặc B2 (không phải A5) — máy verify được, dùng `git tag -l | sort -V | tail -1` so với manifest version trước khi cho phép bump.
4. Rà lại B1's state table — "Drifted" row cần dẫn chiếu rõ guard mới ở bước 3 làm cách phát hiện, không chỉ định nghĩa suông.
5. Cập nhật tóm tắt `RULE-release.md` trong `payload/index.md` nếu mô tả hiện tại ("version minted only at the release event") không còn phản ánh đúng sau khi thêm điều kiện.

## Rủi ro / cần cân nhắc thêm trước khi chốt

- **Đây là thay đổi vào một ABSOLUTE rule dùng chung nhiều project** — theo `payload/index.md` § Change policy, cần xác nhận rõ ràng, tường minh trước khi ghi đè file thật. Không tự áp dụng plan này chỉ vì chủ một project đồng ý — cần soát với các project khác cũng có thể bị ảnh hưởng. Không rewrite bất kỳ câu chữ rule nào trong task tạo ra file này; chỉ thêm một dòng pointer comment (xem bên dưới).
- **Sub-clause "atomic release event" dễ bị lạm dụng làm lý do hợp thức hoá thói quen A5 vốn chặn** (mint rồi không build) nếu không có guard (b) đi kèm bắt buộc, không optional.
- **Case bằng chứng hiện có chỉ có một project** (case gây ra review này) — kết luận "nhiều project drift giống vậy" trong mục Bằng chứng cần có ở trên chưa được khảo sát thật, chỉ là giả thuyết cần kiểm tra trước khi coi A5 là over-fit trên diện rộng.
- **Không đụng A4/B1 hiện có** — chỉ thêm, không sửa lại nội dung đã áp dụng từ `versioning-principle-rewrite.md`. Nếu người review muốn sửa cả A4/B1 cùng lúc, đó là phạm vi khác, cần một plan riêng.

---

Đây là bản plan đề xuất — chưa chỉnh sửa nội dung rule thật của `payload/RULE-release.md` (chỉ có một dòng pointer comment tạm thời trỏ về file này, thêm ngay dưới heading `### A5.`). Quay lại yêu cầu áp dụng khi đã cân nhắc xong và có sign-off rõ ràng.
