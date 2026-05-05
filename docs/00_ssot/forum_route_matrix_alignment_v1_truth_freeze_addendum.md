---
owner: Codex 总控
status: frozen
purpose: Freeze the current Forum app-facing route matrix after aligning OpenAPI, generated contracts, BFF source routes, and Server source routes.
layer: L0 SSOT
---

# Forum Route Matrix Alignment V1 Truth Freeze Addendum

## 1. Ruling

This addendum is the current formal truth for the Forum app-facing route matrix.

The current Forum route matrix is frozen as:

- App-facing family: `/api/app/forum/*`.
- BFF source route count: `30`.
- Server source route count: `30`.
- OpenAPI path count for `/api/app/forum/*`: `30`.
- Generated app API path count for `/api/app/forum/*`: `30`.

The matrix is aligned only at the contract/source level in this round. It does not claim Aliyun cloud runtime deployment, cloud process activation, or real-account UI acceptance.

## 2. Active Route Families

The active app-facing Forum route families are:

- `GET /api/app/forum/feed`
- `GET /api/app/forum/topic/metadata`
- `GET /api/app/forum/topic/list`
- `GET /api/app/forum/topic/detail`
- `GET /api/app/forum/author/profile`
- `GET /api/app/forum/author/posts`
- `GET /api/app/forum/post/detail`
- `GET /api/app/forum/post/comments`
- `POST /api/app/forum/post/comment`
- `POST /api/app/forum/post/like`
- `POST /api/app/forum/post/bookmark`
- `POST /api/app/forum/post/edit`
- `POST /api/app/forum/post/delete`
- `POST /api/app/forum/author/follow`
- `GET /api/app/forum/interaction/inbox`
- `POST /api/app/forum/publish`
- `POST /api/app/forum/draft/save`
- `GET /api/app/forum/draft/list`
- `GET /api/app/forum/draft/detail`
- `POST /api/app/forum/draft/delete`
- `GET /api/app/forum/me/index`
- `GET /api/app/forum/me/posts`
- `GET /api/app/forum/me/comments`
- `GET /api/app/forum/me/bookmarks`
- `GET /api/app/forum/me/likes`
- `GET /api/app/forum/me/follows`
- `GET /api/app/forum/search`
- `POST /api/app/forum/report/submit`
- `GET /api/app/forum/reports/mine`
- `GET /api/app/forum/reports/mine/{ticketId}`

## 3. Author Follow vs Topic Follow

`POST /api/app/forum/author/follow` is the active V1 follow command.

`POST /api/app/forum/topic/follow` is not an active V1 app-facing route. Existing historical references to `topic/follow` are superseded by this addendum unless a future route-family freeze explicitly reopens topic follow.

V1 follow truth is bounded to author follow:

- BFF forwards and shapes only.
- Server owns follow persistence and permission truth.
- Flutter may consume only the BFF-shaped author-follow projection.
- Topic, organization, board, and tag follow are future extension slots, not current runtime commitments.

## 4. Draft Delete Alignment

`POST /api/app/forum/draft/delete` is an active V1 app-facing route and must be present in:

- OpenAPI.
- Generated app API path types.
- App-facing BFF controller.
- Legacy BFF controller compatibility surface.
- Server Forum controller.

Server remains the only owner of draft deletion truth. The command is a controlled state transition to `deleted`; Flutter and BFF must not delete local truth or invent a second draft state machine.

## 5. Report And My-Asset Alignment

The current V1 contract/source matrix includes:

- `GET /api/app/forum/me/likes`
- `POST /api/app/forum/report/submit`
- `GET /api/app/forum/reports/mine`
- `GET /api/app/forum/reports/mine/{ticketId}`

These routes are current contract/source truth. UI upgrades may refine their presentation, but must not add fake report processing actions, fake moderation states, fake counts, or direct Server calls.

## 6. Layer Boundaries

BFF:

- Owns app-facing forwarding, aggregation, error normalization, and view-model shaping only.
- Does not own Forum business truth.
- Does not define a second follow, like, bookmark, draft, comment, or report state machine.

Server:

- Owns Forum business truth, persistence, permission checks, and state transitions.
- Owns comment, like, bookmark, author follow, draft continuation, owner post edit/delete, and report ticket truth.

Flutter:

- Consumes `/api/app/forum/*` through BFF only.
- May improve presentation only after this matrix is kept aligned.
- Must not add fields, fake counts, fake statuses, or direct Server calls for UI polish.

## 7. No-Go List

This round does not authorize:

- UI redesign.
- Cloud deployment.
- Aliyun PM2 restart or Nginx reload.
- Database writes or migrations.
- New topic follow, topic subscription, board follow, or organization follow truth.
- New private messaging capability.
- New report processing / moderation workflow.
- Changing bottom navigation routes.
- Treating generated contracts as runtime evidence.

## 8. Verification Receipt

The local verification target for this freeze is:

- YAML parse passes for `openapi.yaml` and `error_codes.yaml`.
- `pnpm contracts:generate` passes.
- `pnpm contracts:check` passes.
- App-facing BFF source routes, Server source routes, OpenAPI paths, and generated paths all report `30` Forum app-facing routes with no missing or extra routes.
- BFF build passes.
- Server build passes.

Cloud runtime evidence is explicitly outside this receipt until a separately approved runtime stage runs through the `8080` tunnel.
