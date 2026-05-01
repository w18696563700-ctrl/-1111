---
owner: 总控 Agent
status: superseded_by_clean_window
purpose: Record the earlier low-risk P0-B boundary; superseded by the later clean-window sync receipt.
layer: L1 Contracts
freeze_date_local: 2026-05-01
depends_on:
  - docs/00_ssot/app_p0_b_contracts_runtime_drift_ruling_addendum.md
  - docs/00_ssot/app_p0_b_contracts_clean_window_ruling_addendum.md
  - docs/00_ssot/app_p0_b_contracts_clean_window_sync_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/openapi/openapi.bundle.json
  - packages/contracts/src/generated/app-api.types.ts
---

# 《P0-B contracts/runtime 最小同步补丁》

> 2026-05-01 更新：本文是进入 clean-window 前的低风险边界冻结。后续正式同步结果以
> `docs/00_ssot/app_p0_b_contracts_clean_window_sync_receipt_addendum.md`
> 为准。

## 1. 本补丁解决什么

本补丁只解决 P0-B 的合同口径冻结，不解决业务实现，不新增接口，不改状态机，不生成新类型。

本补丁的正式作用是：在 `openapi.yaml`、bundle、generated 已存在既存改动的情况下，先把漂移项分为 `formal active`、`formal reserved`、`implemented but not formal`、`docs/contracts-only`、`not P0` 五类，避免后续把文书、代码、runtime 任一单侧事实误写成完成。

## 2. 路径状态冻结

| path / family | 当前合同状态 | 当前实现状态 | P0-B 合同裁决 | 后续合同动作 |
| --- | --- | --- | --- | --- |
| `POST /api/app/auth/otp/send`、`POST /api/app/auth/otp/login`、`POST /api/app/auth/refresh`、`POST /api/app/auth/logout` | formal OpenAPI / generated 已纳入 | 属于当前登录最小闭环 | `formal active` | 保持 |
| `POST /api/app/auth/password/login`、`POST /api/app/auth/password/set`、`POST /api/app/auth/password/reset` | 未进入 formal OpenAPI / generated；仅 addendum 与代码存在 | BFF/Server/Flutter 代码可见 | `implemented but not formal` | 在 clean contract window 中二选一：补入 formal OpenAPI/generated，或冻结为兼容入口并隐藏 UI |
| `GET /api/app/message/index` | formal OpenAPI / generated 已纳入 | 当前无 active BFF/Server owner，S1-C01 冻结为 placeholder | `formal reserved` | 可保留为 registered-entry / todo projection，但不得承接互动主线 |
| `GET /api/app/message/interactions` | 未进入 formal OpenAPI / generated | BFF/Server/Flutter 当前主线代码可见 | `implemented but not formal` | 若继续作为当前主线，必须补入 formal OpenAPI/generated；不得继续只靠 addendum |
| `GET /api/app/message/counterpart-conversation/detail`、project communication message family | 未在本补丁展开 | 属于 bounded trading exception 的消息交互扩展 | `pending formal review` | 进入同一个 clean contract window，不在本补丁偷开 |
| `GET /api/app/profile/governance/appeals`、`GET /api/app/profile/governance/appeals/{appealCaseId}` | formal OpenAPI / generated path 已纳入 | BFF/Server/Flutter 只读链路可见 | `formal active bounded read` | 保持只读 |
| `POST /api/app/profile/governance/appeals` | formal OpenAPI 已声明 | BFF/Server/Flutter 未见提交闭环 | `formal claim without runtime/code closure` | 第 6 天裁决：补通、降级或移出 P0；第 5 天不补 |
| `GET /server/admin/security-events` | formal OpenAPI 中存在 Server Admin path | runtime/controller 闭合待复核 | `docs/contracts-only for P0` | 不进入 App P0；后续 Admin/security 专项复核 |

## 3. 禁止误读

- 不得把 `message/index` 写成当前消息楼 active mainline。
- 不得把 `message/interactions` 仅凭代码存在写成 formal contract 已完成。
- 不得把 `password auth` 仅凭 UI/BFF/Server 存在写成合同已完成。
- 不得把 `POST /api/app/profile/governance/appeals` 仅凭 OpenAPI 存在写成 runtime 已完成。
- 不得把 `security-events` 拉入 App P0 用户侧能力。
- 不得借合同同步扩写 payment、credit、membership、order、contract、fulfillment、settlement。

## 4. 允许后续修改清单

后续如进入干净合同窗口，只允许修改以下合同面，且必须同步生成物：

1. `docs/01_contracts/openapi.yaml`
2. `packages/contracts/openapi/openapi.bundle.json`
3. `packages/contracts/contracts-manifest.json`
4. `packages/contracts/src/generated/app-api.types.ts`

允许修改的内容仅限：

- 为已确认正式保留的 `password auth` family 补 formal path。
- 为已确认正式主线的 `message/interactions` family 补 formal path。
- 将 `message/index` 标注或迁移为 reserved/deprecated placeholder 口径。
- 对 `POST /api/app/profile/governance/appeals` 执行第 6 天裁决后的合同修正。

## 5. 当前验收结论

第 5 天最小同步状态固定为：`PASS WITH OPEN DRIFT`。

通过理由：

- 漂移项已按正式合同、代码实现、前端消费和待人工 runtime 复核拆开。
- 未在脏 worktree 中重生成合同产物。
- 未新增业务状态机。
- 未扩大 Phase 0 bounded exception。

仍开放的阻断：

- formal OpenAPI/generated 与当前代码主线仍未完全一致。
- `POST /api/app/profile/governance/appeals` 需第 6 天给出单一裁决。
- `message/interactions` 若继续作为当前主线，必须进入后续合同 clean-window。
