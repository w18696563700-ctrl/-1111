---
owner: Codex 总控
status: active
purpose: >
  Record the current local/cloud baseline evidence for the `消息楼互动中心`
  and `我的竞标承接 / 竞标摘要` bounded object before any new stage prompt
  bundle, so later docs-only freezes and any future implementation gate are
  grounded in the real runtime state instead of inherited stale claims.
layer: L0 Evidence
updated_at: 2026-04-23
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_bounded_object_ruling_addendum.md
---

# 《消息楼互动中心与我的竞标承接 cloud baseline evidence receipt》

## 1. Verification Topology

- 验证时间：
  - `2026-04-23 22:35 CST`
- 云端隧道：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 验证口径：
  - current active cloud runtime only

## 2. Cloud Runtime Facts

### 2.1 Health

- `GET /health/bff/live -> 200`
- `GET /health/server/live -> 200`

### 2.2 Not materialized yet

- `GET /api/app/message/index -> 404 Cannot GET`
- `GET /api/app/my/bids -> 404 Cannot GET`
- `GET /api/app/exhibition/trading/participant-card?... -> 404 Cannot GET`

### 2.3 Already alive as controlled route families

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
  -> `401 AUTH_SESSION_INVALID`
- `POST /api/app/profile/personal/nickname`
  -> `401 AUTH_SESSION_INVALID`
- `POST /api/app/profile/personal/avatar`
  -> `401 AUTH_SESSION_INVALID`
- `POST /api/app/file/upload/init` for `businessType=profile` +
  `fileKind=avatar` with minimally valid no-auth body
  -> `401 AUTH_SESSION_INVALID`

## 3. Local Source Facts

### 3.1 Already present

- Server/BFF already expose:
  - `project clarification`
  - `bid thread detail`
  - `bid thread message send`
  - `bid thread confirmation create`
- Server persistence already contains:
  - `project_clarifications`
  - `bid_thread_messages`
  - `bid_thread_confirmation_cards`
- Flutter already contains:
  - `MessagesRegisteredEntryRegistry` entries for
    `project_clarification.open` and `bid_thread.open`
  - `我的竞标` frontend carry placeholder family
  - personal avatar / nickname edit pages

### 3.2 Not found as active runtime source

- No currently active local BFF/Server route family was found for:
  - `GET /api/app/message/interactions`
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/submission/snapshot`

## 4. Baseline Meaning

当前基线正式写死为：

- `message/index` 仍未 materialize
- `my_bids` 仍未 materialize
- `participant-card` 仍未 materialize
- `formal-info`
  - alive
  - controlled
  - not router-missing
- `头像 / 昵称`
  - alive
  - controlled
  - not router-missing

## 5. Formal Conclusion

- 当前云端 baseline 已被正式固定。
- 后续任何文书不得再把：
  - `message/index`
  - `my/bids`
  - `participant-card`
  写成当前 live 已完成。
- 后续任何文书不得再把：
  - `formal-info`
  - `头像 / 昵称`
  写成当前 live 仍为 router `404`。
