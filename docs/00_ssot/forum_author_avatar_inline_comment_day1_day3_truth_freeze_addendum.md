---
owner: Codex 总控
status: active
purpose: Freeze the Day-1 to Day-3 executable truth for forum author avatar projection, public author home reads, inline post comments, and the current like/bookmark deferral boundary.
layer: L0 SSOT
---

# Forum Author Avatar And Inline Comment Day-1 To Day-3 Truth Freeze

## 1. Current Minimum Loop
- Current object:
  - `论坛帖子详情 -> 公共作者主页 -> 帖内一级评论`
- Current stage:
  - `2026-04-24` truth freeze through `2026-04-26` Server/BFF executable read/write closure
- Current minimum closed loop:
  - post detail author summary exposes `avatarUrl`
  - tapping the author area opens the public author home
  - public author home reads only public author summary and public posts
  - post detail reads the first comment page with default `pageSize=10`
  - authenticated actor may submit a text-only first-level comment
- This loop is the current-stage target because it is the smallest content
  consumption loop that fixes the visible forum break without expanding forum
  into a full social product.

## 2. Canonical App-facing Interface List
- `GET /api/app/forum/post/detail`
  - query:
    - `postId`
  - response:
    - `author.authorId`
    - `author.displayName`
    - `author.avatarUrl`
    - `author.organizationName`
- `GET /api/app/forum/author/profile`
  - query:
    - `authorId`
  - response:
    - `authorId`
    - `displayName`
    - `avatarUrl`
    - `organizationName`
    - `publicPostCount`
    - `publicCommentCount`
- `GET /api/app/forum/author/posts`
  - query:
    - `authorId`
    - optional `cursor`
    - optional `pageSize`
  - response:
    - public visible post cards only
    - default page size is `10`
- `GET /api/app/forum/post/comments`
  - query:
    - `postId`
    - optional `cursor`
    - optional `pageSize`
  - response:
    - visible text comments only
    - default page size is `10`
    - latest comments are returned first in this stage so a newly submitted
      comment can be verified after refresh
- `POST /api/app/forum/post/comment`
  - body:
    - `postId`
    - optional `parentCommentId`
    - `body`
  - response:
    - `commentId`
    - `postId`
    - `state=published`
    - `publishedAt`

## 3. Like And Bookmark Decision
- `POST /api/app/forum/post/like` is not a real write-chain target in this
  stage unless an existing Server-owned persistence table is present.
- `POST /api/app/forum/post/bookmark` is not a real write-chain target in this
  stage unless an existing Server-owned persistence table is present.
- Current scan result:
  - no existing forum like persistence table is frozen for this closure
  - no existing forum bookmark persistence table is frozen for this closure
- Therefore the current stage may only expose controlled unavailable responses
  for like/bookmark instead of returning fake success or frontend-owned truth.

## 4. Public Author Home Boundary
- Public author home belongs to `exhibition/forum`.
- It reads only:
  - public identity projection
  - public avatar projection
  - public organization name projection
  - public forum post list
  - public forum comment/post counts
- It must not carry:
  - private profile settings
  - author follow truth
  - DM entry truth
  - transaction, quote, order, payment, or settlement truth
  - a second personal center

## 5. Comment Boundary
- Current comment submit is text-only.
- Current comment submit creates only visible forum comment truth.
- Current comment submit must not create:
  - a comment draft lifecycle
  - comment attachments
  - nested reply UI beyond optional `parentCommentId`
  - moderation console state
  - messages-owned discussion truth

## 6. Copy And Failure Rule
- The current UI and BFF copy must not use generic copy such as:
  - `当前内容暂不可用`
  - `这个内容现在还不能查看`
- When a capability is not deployed or intentionally not open, copy must name
  the concrete blocker, for example:
  - `公共作者主页读链尚未接入，请稍后再试。`
  - `评论提交能力正在接入，请稍后再试。`
  - `点赞/收藏能力尚未接真实写链，本期暂不保存状态。`

## 7. Stage Gate Checklist
- Passed gates:
  - the work remains inside `exhibition/forum`
  - Flutter App keeps talking only to BFF
  - BFF remains aggregation/shaping only
  - Server remains the truth owner for author reads and comment writes
  - author avatar is projection only, not forum-owned avatar truth
- Failed gates:
  - none for the Day-1 to Day-3 minimum loop after this freeze
- Veto gates:
  - no BFF-owned comment state
  - no frontend fake like/bookmark success
  - no public author home under `profile` or `messages`
  - no transaction/DM/follow expansion
- Stage decision:
  - `Go` for bounded Server/BFF implementation of the routes and fields listed
    in this freeze only.

## 8. Cost, Stability, And Risk Judgment
- More stable:
  - implement author reads, avatar projection, and text-only comments first
- Lower cost:
  - defer real like/bookmark persistence until a dedicated table and state
    truth are frozen
- Best fit for current stage:
  - public author home plus inline first-page comments
- Higher risk:
  - adding follow, DM, nested comments, comment media, or transaction handoff in
    the same package

## 9. Formal Conclusion
- The current executable truth is frozen to:
  - public author avatar projection
  - public author profile read
  - public author posts read
  - post comments read with default first `10`
  - authenticated text-only comment submit
  - controlled like/bookmark deferral
- The next implementation may proceed only within this boundary.
