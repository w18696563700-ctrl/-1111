---
owner: Codex 总控
status: active
purpose: Record the Day-1 to Day-3 execution receipt for forum author avatar projection, public author home reads, inline comments, and controlled like/bookmark deferral.
layer: L0 SSOT
---

# Forum Author Avatar And Inline Comment Day-1 To Day-3 Execution Receipt

## 1. Execution Scope
- Execution date:
  - `2026-04-24`
- Runtime shape:
  - Flutter App local
  - BFF and Server on Aliyun
  - tunnel validation through `127.0.0.1:8080`
- Executed scope:
  - post detail `author.avatarUrl`
  - public author profile read
  - public author posts read
  - post comments first page read with default `10`
  - authenticated text-only comment create
  - feed/topic reply count projection from `ForumPost.commentCount`
  - controlled like/bookmark deferral
- Explicitly not executed:
  - real like persistence
  - real bookmark persistence
  - follow
  - DM
  - nested comment UI
  - comment attachment
  - frontend inline-comment layout change

## 2. Local Verification
- `ruby packages/contracts/scripts/generate_contracts.rb`
  - passed
- `ruby packages/contracts/scripts/check_contracts.rb`
  - passed
- `cd apps/server && npm run build`
  - passed
- `cd apps/bff && npm run build`
  - passed
- Server forum file length gate after split:
  - `forum.query.service.ts`: `415`
  - `forum-comment.service.ts`: `221`
  - `forum-author.query.service.ts`: `103`
  - `forum-author-projection.service.ts`: `87`
  - `forum.presenter.ts`: `374`

## 3. Cloud Deployment
- Remote backup:
  - `/srv/backups/forum-author-comments-20260424161546`
- Remote paths touched:
  - `/srv/apps/server/current/src/modules/forum`
  - `/srv/apps/server/current/dist/modules/forum`
  - `/srv/apps/bff/current/src/routes/forum`
  - `/srv/apps/bff/current/dist/apps/bff/src/routes/forum`
  - `/srv/apps/bff/current/dist/packages/contracts/src/generated`
- Restarted services:
  - `exhibition-server.service`
  - `exhibition-bff.service`
- Final runtime state:
  - both services `active`

## 4. Tunnel Curl Evidence
- `GET /api/app/forum/post/detail?postId=c3a03af4-2306-4ee8-9e78-f714721c76b0`
  - status `200`
  - `author.avatarUrl` returned a signed readable OSS URL
- `GET /api/app/forum/author/profile?authorId=ebb8d922-e7da-43fa-897b-360214dfd6e4`
  - status `200`
  - returned `authorId / displayName / avatarUrl / organizationName / publicPostCount / publicCommentCount`
- `GET /api/app/forum/author/posts?authorId=ebb8d922-e7da-43fa-897b-360214dfd6e4&pageSize=10`
  - status `200`
  - returned public posts only
- `GET /api/app/forum/post/comments?postId=c3a03af4-2306-4ee8-9e78-f714721c76b0&pageSize=10`
  - status `200`
  - returned latest comments first
- `POST /api/app/forum/post/comment`
  - authenticated status `202`
  - created comment `934a9b55-3dbc-4332-b872-01d60cffea2a`
  - refresh of comment list returned the same comment
- unauthenticated `POST /api/app/forum/post/comment`
  - status `401`
  - code `AUTH_SESSION_INVALID`
  - message `当前登录状态已失效，请重新登录后再试。`
- authenticated `POST /api/app/forum/post/like`
  - status `503`
  - code `FORUM_INTERACTION_UNAVAILABLE`
  - message `点赞能力尚未接真实写链，本期暂不保存状态。`
- authenticated `POST /api/app/forum/post/bookmark`
  - status `503`
  - code `FORUM_INTERACTION_UNAVAILABLE`
  - message `收藏能力尚未接真实写链，本期暂不保存状态。`
- `GET /api/app/forum/feed?scope=square`
  - status `200`
  - target post `replyCount=1` after comment create

## 5. Stage Gate Result
- Passed gates:
  - truth-first execution
  - contracts generated and checked
  - Server owns author/comment truth
  - BFF remains aggregation and error shaping only
  - Flutter still talks only to BFF
  - no fake like/bookmark success
  - cloud services healthy after deploy
- Failed gates:
  - none for the Day-1 to Day-3 backend/BFF closure
- Veto gates:
  - none triggered
- Next-stage decision:
  - `Go` for the frontend phase that displays avatar, links author area to
    public author home, and moves comments into the post-detail inline action
    row using the now-verified BFF routes.

## 6. Formal Conclusion
- The Day-1 to Day-3 backend/BFF closure is complete for:
  - author avatar projection
  - public author home read chain
  - public author posts read chain
  - post comments read chain
  - authenticated text-only comment write chain
  - controlled like/bookmark deferral
- The next open work is frontend consumption and Computer Use UI联调.
