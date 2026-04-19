---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF surface boundary for `项目交易骨架 P0`, including allowed
  app-facing shaping, error normalization, auth shaping, and the hard rule that
  BFF must not build a second trade-state machine.
layer: L4 BFF
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_transaction_skeleton_p0_gate_checklist.md
  - docs/01_contracts/project_transaction_skeleton_p0_contracts_addendum.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/my_project/my-project.controller.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/bff/src/routes/profile/app-profile-read.controller.ts
---

# 项目交易骨架 P0 BFF Surface Addendum

## 1. Scope

本文件只冻结 `项目交易骨架 P0` 的 `BFF` surface。

本文件不做：

- `Server` truth owner 改写
- 资金 / 风控 / 审核 / visibility BFF surface
- `apps/bff/**` 实现

## 2. BFF 角色总边界

`BFF` 在 `P0` 的唯一职责是：

- app-facing path 暴露
- 请求转发
- 最小响应整形
- 统一 envelope
- controlled error normalization
- public/private auth shaping

`BFF` 当前明确不得：

- 自建第二交易状态机
- 自建第二资格状态机
- 自建 archive-ready / visibility-ready / review-ready 推断
- 把 `profile/*` posture 家族接成交易 runtime

## 3. App-facing Path Table

| app-facing path | auth shaping | BFF 定位 | 当前裁决 |
|---|---|---|---|
| `GET /api/app/project/list` | public read | 公开读取与最小整形 | 保持现状，不属于 P0 新实现对象 |
| `GET /api/app/project/detail` | optional auth | 公开 detail + optional owner-aware handoff | 保持现状，不属于 P0 新实现对象 |
| `GET /api/app/my/projects` | private read | 私域资产聚合 | 保持现状，不得交易真源化 |
| `GET /api/app/my/projects/{projectId}` | private read | 私域单项目聚合 | 保持现状，不得交易真源化 |
| `GET /api/app/exhibition/workbench` | private read | 私域 summary posture | 保持现状，不得交易真源化 |
| `POST /api/app/bid/submit` | private write | P0 write corridor 起点的 app-facing shaping | 批准进入 P0 |
| `GET /api/app/order/detail` | private read | 交易 read corridor shaping | 保留 read-only |
| `POST /api/app/order/create` | private write | P0 write corridor | 批准进入 P0 |
| `GET /api/app/contract/detail` | private read | 交易 read corridor shaping | 保留 read-only |
| `POST /api/app/contract/confirm` | private write | P0 write corridor | 批准进入 P0 |
| `GET /api/app/milestone/list` | private read | 交易 read corridor shaping | 保留 read-only |
| `POST /api/app/milestone/submit` | private write | P0 write corridor | 批准进入 P0 |
| `GET /api/app/inspection/detail` | private read | 交易 read corridor shaping | 保留 read-only |
| `POST /api/app/inspection/submit` | private write | P0 write corridor | 批准进入 P0 |

## 4. BFF Allowed Responsibilities

`BFF` 当前只允许：

1. 透传 actor / session / organization scope 所需上下文。
2. 把 `Server` 返回的最小 canonical payload 整形成 App 使用的最小结构。
3. 把 `Server` 错误归一到既有 app-facing envelope。
4. 保持 `project/detail` 的 optional-auth 策略。
5. 保持 `project/list` 的 public-read 策略。
6. 保持 `my/projects / workbench / P0 write paths` 的 private-auth 策略。

## 5. BFF Forbidden Responsibilities

`BFF` 当前明确禁止：

1. 生成 `owner` 权限总真值
2. 生成 `tradeState` 第二状态机
3. 生成 `archiveReady` / `visibilityReady` / `reviewReady`
4. 把 `summary.stateLabel` 提升为业务真值
5. 把 `workbench summary` 提升为交易实例真值
6. 把 `privateProgress` 提升为命令真值
7. 在本地判断 payment / deposit / guarantee / credit gate
8. 在本地决定 `rating / dispute` 是否应放开

## 6. Error Normalization Boundary

当前 `BFF` 对 `P0` 只允许做：

- controlled invalid
- controlled unavailable
- controlled forbidden / unauthorized
- 统一 envelope 中的 `source`、`code`、`message`

当前 `BFF` 不允许做：

- 重新发明本地错误命名空间
- 用 `BFF` 自造状态解释替代 `Server` 最终错误语义
- 把 admin-only 错误改造成 app-facing 假语义

## 7. Public / Private Auth Shaping Boundary

### 7.1 Public / Optional-auth

以下 family 继续只允许：

- `project/list`
  - `public read`
- `project/detail`
  - `optional auth + owner-aware handoff`

### 7.2 Private-auth

以下 family 必须保持：

- `my/projects*`
- `exhibition/workbench`
- `bid/submit`
- `order/*`
- `contract/*`
- `milestone/*`
- `inspection/*`

即：

- 未登录不得被 `BFF` 偷放行
- `BFF` 也不得因缺少登录态而把 public detail 预先打成 `401`

## 8. 如果写链进入 P0，BFF 如何只做 shaping

若 `bid/order/contract/milestone/inspection` 进入 `P0`，`BFF` 只能做：

1. `request -> Server` 命令透传
2. 成功响应最小字段回传
3. 错误 envelope 归一
4. continuation anchor 透出

`BFF` 仍不得做：

1. 订单创建可否成立的最终判断
2. 合同确认有效性的最终判断
3. 里程碑/验收状态推进的最终判断
4. 下游 `rating / dispute` 放行判断

## 9. 非 P0 path family 规则

以下 family 当前只能保持：

- 透传保留或不开放

不得被 `BFF` 升格为 `P0`：

1. `contract/amend`
2. `inspection/recheck`
3. `rating/*`
4. `dispute/*`
5. `profile/payment-and-billing-status/*`
6. `profile/credit-and-constraints/*`
7. `profile/membership/*`

## 10. Formal Conclusion

`项目交易骨架 P0` 的 `BFF surface` 正式冻结为：

- `BFF` 只拥有 app-facing shaping 权限
- 不拥有任何交易真相
- 不拥有任何第二状态机
- 只批准：
  - `bid/submit`
  - `order/create`
  - `contract/confirm`
  - `milestone/submit`
  - `inspection/submit`
  配套的最小 shaping
- `rating / dispute / payment / deposit / guarantee / credit / membership`
  全部不进入当前 `P0 BFF` 解锁范围

