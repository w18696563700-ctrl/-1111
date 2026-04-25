---
owner: Codex 总控
status: active
purpose: Record the Day-4 to Day-6 BFF and Flutter execution receipt for forum author avatar, public author home, and inline comments.
layer: L0 SSOT
---

# Forum BFF And Flutter Author Comments Day-4 To Day-6 Execution Receipt

## 1. Execution Scope
- Execution date:
  - `2026-04-24`
- Runtime shape:
  - Flutter App local macOS build
  - BFF and Server on Aliyun
  - tunnel validation through `127.0.0.1:8080`
- Executed scope:
  - BFF author read error message normalization
  - BFF public author posts shaping aligned to frozen public author post card
  - Flutter `author.avatarUrl` consumption through author summary
  - Flutter public author post model and parser split from private `我的帖子`
  - Flutter post comments first page `pageSize=10`
  - Flutter inline comment pagination by `查看更多评论`
  - post detail author row avatar and whole-row public author-home click
  - post detail action row ordered as `点赞 / 评论 / 收藏`
  - comment input expands on detail page
  - comment list stays on detail page instead of forcing the standalone full
    comments page

## 2. Local Verification
- `cd apps/bff && npm run build`
  - passed
- `cd apps/mobile && flutter analyze lib/features/exhibition/data/forum_consumer_layer.dart lib/features/exhibition/presentation/forum/forum_pages.dart test/forum_content_governance_and_report_test.dart test/forum_routes_test.dart`
  - passed
- `cd apps/mobile && flutter test test/forum_content_governance_and_report_test.dart test/forum_interaction_loop_test.dart`
  - passed
- Targeted Flutter tests:
  - `comment item can submit duplicate report with bounded result`
  - `forum author profile consumes bounded block status block and unblock`
  - `forum feed author avatar hands off to public author profile`
  - `forum detail author area hands off to public author profile`
  - all passed
- Full `test/forum_routes_test.dart` status:
  - still has one pre-existing unrelated failure:
    `forum publish media upload failure keeps Chinese controlled feedback`
  - the failure is outside this author/avatar/comment scope.

## 3. Cloud Deployment
- Remote BFF backup:
  - `/srv/backups/forum-bff-author-copy-20260424164536`
- Remote paths touched:
  - `/srv/apps/bff/current/src/routes/forum/forum-author-profile.service.ts`
  - `/srv/apps/bff/current/src/routes/forum/forum-command-error.service.ts`
  - `/srv/apps/bff/current/dist/apps/bff/src/routes/forum/forum-author-profile.service.js`
  - `/srv/apps/bff/current/dist/apps/bff/src/routes/forum/forum-command-error.service.js`
  - matching `.d.ts` files
- Restarted service:
  - `exhibition-bff.service`
- Final runtime state:
  - `exhibition-bff.service = active`

## 4. Tunnel Curl Evidence
- `GET /api/app/forum/author/profile?authorId=missing-author`
  - status `404`
  - code `FORUM_AUTHOR_UNAVAILABLE`
  - message `当前作者主页暂不可用。`
  - previous upstream English message retained only in `details.originalMessage`
- `GET /api/app/forum/author/posts?authorId=ebb8d922-e7da-43fa-897b-360214dfd6e4&pageSize=2`
  - status `200`
  - returned public author post cards with:
    - `postId`
    - `topicId`
    - `topicTitle`
    - `title`
    - `excerpt`
    - `state`
    - `publishedAt`
    - `updatedAt`
    - `canEdit=false`
    - `canDelete=false`
- `GET /api/app/forum/post/detail?postId=c3a03af4-2306-4ee8-9e78-f714721c76b0`
  - with `x-user-id`
  - status `200`
  - returned `author.avatarUrl`
- `GET /api/app/forum/post/comments?postId=c3a03af4-2306-4ee8-9e78-f714721c76b0&pageSize=10`
  - with `x-user-id`
  - status `200`
  - returned first comment page with comment author `avatarUrl`
- unauthenticated `POST /api/app/forum/post/comment`
  - status `401`
  - code `AUTH_SESSION_INVALID`
  - message `当前登录状态已失效，请重新登录后再试。`

## 5. Computer Use Verification
- Rebuilt and launched macOS app through:
  - `apps/mobile/scripts/run_macos_formal.sh`
  - `APP_RUNTIME_ENTRY_MODE=ssh_tunnel`
  - BFF base URL `http://127.0.0.1:8080/api/app`
- Verified screens:
  - post detail shows real author avatar
  - tapping author row enters public author home
  - public author home shows public profile and public posts
  - post detail action row shows `点赞 / 评论 / 收藏`
  - tapping `评论` expands inline text input on the same page
  - first comment page is shown below the action row
  - no `查看全部评论` forced jump remains on post detail

## 6. Stage Gate Result
- Passed gates:
  - truth-first execution
  - BFF app-facing routes remain `/api/app/forum/*`
  - Flutter does not call `/server/forum/*`
  - Server remains author/post/comment truth owner
  - BFF remains shaping and error normalization only
  - no fake like/bookmark success added
  - frontend avatar, author-home, and inline comment loop verified
- Failed gates:
  - none for this scoped closure
- Residual risks:
  - standalone `ForumCommentInteractionPage` remains as a compatibility route
    but is no longer forced from post detail
  - fake bootstrap token was used for UI read联调, so real in-app comment submit
    success remains covered by curl and earlier authenticated backend receipt
  - unrelated forum publish media upload failure test still needs a separate
    package
- Next-stage decision:
  - `Go` for product review/UAT of the author avatar, public author home, and
    inline comment loop.
