---
owner: 总控 Agent
status: frozen
purpose: Freeze the P0-B contracts clean-window rulings before OpenAPI and generated type synchronization.
layer: L0 SSOT
freeze_date_local: 2026-05-01
scope:
  - message/index
  - message/interactions
  - profile/governance/appeals POST
  - password auth
depends_on:
  - AGENTS.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/openapi/openapi.bundle.json
  - packages/contracts/src/generated/app-api.types.ts
  - apps/bff/src/routes/auth/**
  - apps/bff/src/routes/message_interaction/**
  - apps/bff/src/routes/profile/**
  - apps/mobile/lib/core/auth/**
  - apps/mobile/lib/features/messages/**
  - apps/mobile/lib/features/profile/**
  - docs/00_ssot/app_p0_b_contracts_runtime_drift_ruling_addendum.md
  - docs/01_contracts/app_p0_b_contracts_runtime_minimal_sync_addendum.md
---

# 《P0-B contracts clean-window 裁决表》

## 1. 总裁决

P0-B clean-window 正式裁决为：`Go for minimal contracts sync`。

本窗口只允许处理四个漂移项：`message/index`、`message/interactions`、`profile/governance/appeals POST`、`password auth`。不得借合同同步扩写支付、信用、会员、通用消息后台、工单重系统、settings/flags center、order/contract/fulfillment/settlement，也不得把 Admin 做成第二业务真值。

## 2. 单项裁决矩阵

| 项 | 当前 formal contracts / generated | 当前代码与 App 消费 | runtime 结果 | 单一裁决 | 第 2 天允许动作 | 禁止动作 | 依据类型 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `GET /api/app/message/index` | `openapi.yaml`、bundle、`APP_API_PATHS` 已声明 | BFF 未见 active owner；Flutter `loadIndex()` 已降级为 deprecated wrapper 并转调 `loadInteractions()` | 2026-05-01 本轮隧道复核：`404 Cannot GET /api/app/message/index` | `Deprecated reserved`：从当前 active app-facing contract 中降级，不再承接消息主线 | 从 formal active path 清理或明确标注为 deprecated/reserved；generated active path 不应继续把它列为可用主线 | 不补 BFF owner；不恢复旧消息中心；不与 `message/interactions` 双主线并存 | contracts / 代码 / runtime / 文书 |
| `GET /api/app/message/interactions` | 未进入 `openapi.yaml`、bundle、`APP_API_PATHS` | BFF `message_interaction` 已挂载；Flutter Messages 当前消费主线 | 2026-05-01 本轮隧道复核：`401 AUTH_SESSION_INVALID`，说明路由已挂载并鉴权 | `Formal active`：作为当前 P0 消息交互主线纳入 formal contracts/generated | 补入 OpenAPI/bundle/generated；只覆盖列表读取与当前已冻结响应模型 | 不扩成通用聊天后台；不新增群聊/DM/支付/履约语义 | 文书 / 代码 / runtime / contracts |
| `POST /api/app/profile/governance/appeals` | `openapi.yaml` 与 bundle 声明 POST；generated path 只体现 path 常量，未形成 App submit 消费闭环 | BFF command controller 未挂载；Flutter 只读 list/detail，页面文案明确不开放提交 | 2026-05-01 本轮隧道复核：`404 Cannot POST /api/app/profile/governance/appeals` | `Future reserved / remove from active P0`：当前不实现，不算 P0 完成项 | 从 active formal POST 中移除，或标成 future reserved；保留 GET list/detail | 不补用户侧申诉提交；不牵出证据附件、处罚状态机、申诉重系统 | contracts / 代码 / runtime / 文书 |
| `POST /api/app/auth/password/login`、`POST /api/app/auth/password/set`、`POST /api/app/auth/password/reset` | 未进入 formal OpenAPI / generated；已有独立合同 addendum | BFF、Server、Flutter UI/consumer 均存在；登录页有密码模式 | 2026-05-01 本轮隧道复核：`password/login` 已挂载，空 body 返回 `400 AUTH_CONSENT_REQUIRED`；`set/reset` 由 BFF 参数校验保护 | `Formal active bounded auth`：纳入 formal contracts/generated，但不扩大为账号密码后台或 Admin 登录 | 补三条 app-facing password auth path；复用现有 Auth session envelope / error envelope 口径 | 不引入后台账号密码登录；不新增二次因子状态机；不绕过 consent/session 规则 | 文书 / 代码 / runtime / contracts |

## 3. 当前最小闭环

- 登录与会话：OTP 继续是正式最小闭环；password auth 因 App/BFF/Server/runtime 均可见，进入 bounded formalization。
- 消息楼：`message/interactions` 是当前唯一 active App 消费主线；`message/index` 只保留 deprecated/reserved 语义，不作为 runtime 可用主线。
- 治理申诉：`GET /api/app/profile/governance/appeals` 与 `GET /api/app/profile/governance/appeals/{appealCaseId}` 保持只读 active；`POST submit` 移出当前 P0 active。

## 4. 需要保留但暂不开通

- `message/index` 可以作为后续 registered-entry / todo projection 扩展位，但本轮不得实现。
- `profile/governance/appeals POST` 可以作为后续申诉提交能力扩展位，但必须先冻结状态机、证据边界、审计与权限。
- password auth 只 formalize 既有三条 app-facing path，不引入新的账号体系或 Admin 密码登录。

## 5. 第 2 天同步边界

第 2 天只允许修改：

1. `docs/01_contracts/openapi.yaml`
2. `packages/contracts/openapi/openapi.bundle.json`
3. `packages/contracts/src/generated/app-api.types.ts`
4. 必要时同步 `packages/contracts/contracts-manifest.json`

第 2 天验收标准：

- `APP_API_PATHS` 不再把 `message/index` 写成当前 active path。
- `APP_API_PATHS` 纳入 `message/interactions`。
- active OpenAPI 不再声明当前不存在的 `POST /api/app/profile/governance/appeals`。
- active OpenAPI 纳入 bounded password auth 三条路径。
- diff 控制在 P0-B clean-window，不引入无关 churn。

## 6. 门禁结论

第 1 天 `P0-B contracts clean-window 裁决冻结`：`Pass`。

允许进入第 2 天 `P0-B 最小 Contracts 同步`。
