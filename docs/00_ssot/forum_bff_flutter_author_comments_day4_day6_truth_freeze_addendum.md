---
owner: Codex 总控
status: active
purpose: Freeze the Day-4 to Day-6 execution boundary for BFF forum aggregation, Flutter author avatar consumption, public author home, and inline comment interaction.
layer: L0 SSOT
---

# Forum BFF And Flutter Author Comments Day-4 To Day-6 Truth Freeze

## 1. Current Minimum Loop
- Current object:
  - `帖子详情 -> 作者头像/作者主页 -> 详情页内评论读取/提交`
- Current stage:
  - `2026-04-27` BFF aggregation and error copy
  - `2026-04-28` Flutter data consumption
  - `2026-04-29` Flutter page interaction
- Current minimum closed loop:
  - Flutter only requests BFF `/api/app/forum/*`
  - post detail author summary consumes `avatarUrl`
  - author avatar and author text area open the public author home
  - public author home reads real author profile and public author posts
  - post detail reads the first `10` comments through BFF
  - comment entry stays on post detail; it does not force a separate full
    comments page

## 2. Canonical Interface Boundary
- No new app-facing path is introduced in this stage.
- The only active BFF-facing paths for this loop are:
  - `GET /api/app/forum/author/profile`
  - `GET /api/app/forum/author/posts`
  - `GET /api/app/forum/post/comments`
  - `POST /api/app/forum/post/comment`
- Flutter must not call `/server/forum/*` or any direct Server port.
- BFF may shape responses and normalize errors only; it must not own forum
  author truth, post truth, comment truth, like truth, or bookmark truth.

## 3. Flutter Data Boundary
- `ForumAuthorSummaryView` must carry:
  - `authorId`
  - `displayName`
  - `avatarUrl`
  - `organizationName`
- Public author posts must use a public-author post model, not private
  `我的帖子` edit/delete truth.
- Comment reads must support:
  - `postId`
  - optional `cursor`
  - explicit `pageSize=10` for the first detail-page page
- Comment submit remains:
  - text-only
  - first-level by default
  - authenticated
  - persisted by Server and refreshed back through BFF

## 4. Flutter Interaction Boundary
- Post detail author area:
  - shows avatar when `avatarUrl` exists
  - falls back to the existing initial badge when `avatarUrl` is empty
  - opens public author home when tapping avatar or author text
- Post detail action area:
  - keeps like, comment, and bookmark in one action row
  - comment action expands the inline text box on the same detail page
  - first page shows up to `10` comments below the action row
  - `查看更多评论` loads the next comment page inline
- The old standalone comments page may remain as an inert compatibility route,
  but the post detail page must not force users into it for the normal comment
  loop.

## 5. Copy And Failure Rule
- Generic copy such as `当前内容暂不可用` must not be the first visible reason
  when the system can distinguish the cause.
- Required visible distinctions:
  - not logged in: `请先登录后再继续` or the BFF returned session-expired copy
  - BFF route missing or not deployed: name the BFF route capability
  - forbidden: name the current account permission problem
  - network failure: name temporary network/service unreachability
  - author unavailable: `当前作者主页暂不可用`
  - comment invalid: name the missing `postId` or missing comment body
  - like/bookmark unavailable: controlled deferred capability, not fake success

## 6. Stage Gate Checklist
- Passed gates:
  - Day-1 to Day-3 Server/BFF backend closure receipt exists
  - canonical BFF paths exist in contracts and generated app API paths
  - tunnel smoke confirms BFF author/comment routes no longer raw `404`
  - like/bookmark real write chains stay out of scope
- Failed gates:
  - none blocking Day-4 to Day-6 Flutter implementation
- Veto gates:
  - no direct Server calls from Flutter
  - no frontend-owned comment, like, or bookmark truth
  - no public author home expansion into DM, follow, private profile, or trading
- Next-stage decision:
  - `Go` for bounded BFF shaping refinement and Flutter implementation.

## 7. Platform Tradeoff Ruling
- More stable:
  - keep Flutter on BFF canonical paths and let Server stay the only truth owner.
- Lower cost:
  - implement inline first-page comments plus inline `load more`; do not build a
    full comment center or nested reply UI now.
- Best for current stage:
  - land avatar consumption, public author home read, and inline comments before
    opening any social expansion.
- Higher risk:
  - direct Server calls, frontend fake states, real like/bookmark persistence
    without frozen tables, or merging public author home into private profile.
