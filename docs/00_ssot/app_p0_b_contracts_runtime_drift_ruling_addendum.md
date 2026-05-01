---
owner: 总控 Agent
status: frozen
purpose: Freeze Day 4 P0-B contracts/runtime drift rulings before any OpenAPI or generated-type rewrite.
layer: L0 SSOT
freeze_date_local: 2026-05-01
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/openapi/openapi.bundle.json
  - packages/contracts/src/generated/app-api.types.ts
  - docs/00_ssot/s1_c01_message_index_minimal_closure_result_verification_receipt_addendum.md
  - docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_controller_review_conclusion_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
  - apps/bff/src/routes/auth/**
  - apps/bff/src/routes/message_interaction/**
  - apps/bff/src/routes/profile/**
  - apps/mobile/lib/core/auth/**
  - apps/mobile/lib/features/messages/**
  - apps/mobile/lib/features/profile/**
  - apps/server/src/modules/auth/**
  - apps/server/src/modules/message_interaction/**
  - apps/server/src/modules/profile/**
---

# 《P0-B contracts/runtime 漂移裁决冻结》

## 1. 总裁决

P0-B 当前结论固定为：`Conditional Go for bounded sync`。

本轮允许继续进入第 6 天，但不得把以下任一项写成 full pass：

- `password auth`：App/BFF/Server 代码可见，且历史运行记录显示云端路由可达；但未纳入 formal OpenAPI / generated app path，不能按完整合同完成项处理。
- `message/index`：formal OpenAPI / generated path 存在；但当前冻结口径是 non-active placeholder / registered-entry projection，不得升级成消息主线。
- `message/interactions`：当前 BFF/App 代码消费主线成立；但未进入 formal OpenAPI / generated path list，必须标记为 contracts drift。
- `profile/governance/appeals`：formal OpenAPI 同时包含 `GET` 与 `POST`；当前代码和前端只闭合 list/detail 只读链路，`POST submit` 不得判为完成。
- `security-events`：formal OpenAPI 中存在 Server Admin path；当前不属于 App P0，且 runtime 是否上线待人工复核。

## 2. 漂移矩阵

| 项 | 文书依据 | contracts/generated 依据 | 代码依据 | runtime 依据 | 当前裁决 | 第 5 天处理 |
| --- | --- | --- | --- | --- | --- | --- |
| App password auth | `auth_password_login_round_b_*` 声称 `password/login|set|reset` | `openapi.yaml`、bundle、`APP_API_PATHS` 未纳入 password family | BFF `AuthController/AuthService`、Server `AuthController`、Flutter login form 均可见 | 历史 ledger 记录 `POST /api/app/auth/password/login` 返回 app-facing `401 AUTH_PASSWORD_LOGIN_INVALID`；本轮未主动复测 | `Conditional`：不是纯历史残留，但合同未完成 | 不新增业务；冻结为“已实现但 formal contract 缺口”，后续干净合同窗口二选一：补 OpenAPI/generated 或隐藏入口 |
| `account_password_plus_second_factor` | `identity_permission_minimum_contracts.yaml`、`auth_contracts.yaml` 仍有旧术语 | 非当前 OpenAPI app path 真源 | 本轮未见当前 UI/BFF 按该术语运行 | 待复核 | `Deprecated wording`：不得作为当前 P0 术语 | 后续文书清理，不做实现 |
| `GET /api/app/message/index` | S1-C01 已冻结为 placeholder / fail-closed | formal OpenAPI、bundle、`APP_API_PATHS` 已纳入 | 当前 BFF 未见 active owner；App `loadIndex()` 已降为 deprecated wrapper | 待人工复核 | `Reserved formal placeholder`：保留但非 active mainline | 不补 active owner；不得承接项目沟通主线 |
| `GET /api/app/message/interactions` | 多份 BFF/frontend/contracts addendum 声称当前互动主线 | 未进入 formal OpenAPI、bundle、`APP_API_PATHS` | BFF `message_interaction`、Server `message_interaction`、Flutter `MessagesPage` 当前消费 | 历史 runtime receipt 有 401 auth-gated 记录；本轮未主动复测 | `Implemented-code mainline with contract drift` | 不改代码；记录为后续 formal OpenAPI/generated 同步项 |
| `GET /api/app/profile/governance/appeals*` | S1-R05 冻结 current-actor list/detail | formal OpenAPI、bundle、`APP_API_PATHS` 已纳入 | BFF/Server/Profile Flutter 均有 GET list/detail | 待人工复核 | `Bounded read pass` | 只承认只读链路 |
| `POST /api/app/profile/governance/appeals` | blacklist/whitelist addendum 与 formal OpenAPI 声称存在 | formal OpenAPI 包含 POST | BFF command / Server profile controller / Flutter 未见 submit 闭环 | 用户既有口径曾指向 POST 404；本轮待人工复核 | `No-Go for completion`：进入第 6 天单独裁决 | 不直接补；第 6 天决定补通、降级或移出 P0 |
| `GET /server/admin/security-events` | account/enterprise certification addendum 声称 admin security-events | formal OpenAPI、bundle 已纳入 Server Admin path | 本轮未确认对应 Admin controller 已闭合 | 待人工复核 | `Docs/contracts-only for P0`：不进 App P0 | 保留为 P2/Admin 安全增强或后续 runtime 复核项 |

## 3. 第 5 天最小同步边界

本轮第 5 天不直接重写 `docs/01_contracts/openapi.yaml`、`packages/contracts/openapi/openapi.bundle.json`、`packages/contracts/src/generated/app-api.types.ts`，原因固定为：

- 这些文件在本轮进入第 5 天前已有既存改动，直接生成会混入非 P0-B 差异。
- `message/index` 与 `message/interactions` 的正式路径关系仍需先冻结“placeholder vs active mainline”口径。
- `password auth` 是否正式补入 formal OpenAPI，必须与登录产品口径和上架合规入口一起确认，不能只因代码存在就补合同。
- `appeal submit` 是否进入 P0 需第 6 天裁决，不能在第 5 天抢先补写。

第 5 天只允许输出：

- 本 SSOT 裁决冻结稿。
- `docs/01_contracts/app_p0_b_contracts_runtime_minimal_sync_addendum.md` 合同同步 addendum。
- 后续 OpenAPI/generated clean-window 修改清单。

## 4. 当前门禁影响

| gate | 状态 | 说明 |
| --- | --- | --- |
| P0-B contracts/runtime drift | `OPEN` | 漂移已被定位，但 formal OpenAPI/generated 尚未统一。 |
| 进入第 6 天 | `ALLOW` | 举报治理闭环裁决不依赖立即重生成 contracts。 |
| P0 full Go | `BLOCKED` | 在 `message/interactions`、password auth、appeal submit 等合同漂移关闭前，不得 full pass。 |

## 5. 后续唯一合同动作

在进入 OpenAPI/generated 修改前，必须先完成一个干净合同窗口：

1. 确认 `message/interactions` 是否作为正式 app-facing active route 写入 formal OpenAPI。
2. 确认 `message/index` 是否保留为 deprecated/placeholder，还是从 formal active path 中降级说明。
3. 确认 `password auth` 是正式 App 登录方式还是临时兼容入口。
4. 确认 `POST /api/app/profile/governance/appeals` 是补通、降级为 future，还是移出 P0。
5. 在 clean worktree 下统一生成 bundle、manifest 与 generated types。
