---
owner: 结果校验 Agent
status: active
purpose: Record the second real-runtime verification rerun for 项目发布工作台 / 项目发布 / 项目展示 using the fixed approved buyer-admin sample and the frozen tunnel entry.
layer: L0 SSOT
based_on:
  - docs/00_ssot/three_board_real_chain_result_verification_dispatch_round1.md
  - docs/00_ssot/three_board_real_chain_verification_checklist_v1.md
  - docs/00_ssot/three_board_real_chain_verification_checklist_v1_draft_round0.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_signoff.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
freeze_date_local: 2026-04-10
verification_entry:
  - http://127.0.0.1:8080
runtime_sample:
  mobile: 18696563700
  organizationId: e6bf4567-016e-45f9-9420-9c950237690e
  role: buyer_admin
  certificationStatus: approved
---

# 《三板块真实链路核查表 V1》二次真实复核回执

## 1. 核验前提与本轮样本

- 本轮只认 `http://127.0.0.1:8080` 隧道下的实时返回。
- 本轮固定样本为：
  - `mobile = 18696563700`
  - `otpCode = 000000`
  - `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`
  - `role = buyer_admin`
  - `certificationStatus = approved`
- 本轮登录返回：
  - `POST /api/app/auth/otp/login -> 200`
- 本轮组织切换返回：
  - `POST /api/app/profile/organization/switch -> 201`
  - `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`
  - `roleKeys = ["buyer_admin"]`
  - `certificationStatus = approved`

## 2. 主链核查表

| 链路段 | 所属板块 | 预期行为 | 当前证据来源 | 当前判定 | 是否阻断联调发布 | 备注 |
|---|---|---|---|---|---|---|
| 首页发布入口 -> 工作台 | 项目发布工作台 | 从首页进入工作台或发布相关私域入口，不误导成公域展示页 | 无本轮页面点击证据；仅有移动端路由与页面代码 | 不稳定 | 否 | 本轮未直接操作 Flutter 页面；只确认工作台承接 API 已真实命中。 |
| 工作台 -> 发布页 | 项目发布工作台 / 项目发布 | 工作台只做摘要与导流，可进入发布页 | `GET /api/app/exhibition/workbench -> 200`；移动端路由代码 | 真实命中 | 否 | 工作台返回 `project_chain.canCreateProject = true`，符合“私域摘要 + 导流”边界。 |
| 发布页加载 | 项目发布 | 发布页按既有冻结字段加载，不新增第二状态机 | `docs/01_contracts/openapi.yaml` + 现网 `create/detail` 返回字段 | 真实命中 | 否 | 本轮直接复核了 create/detail 最小字段闭环。 |
| 上传三步链 | 项目发布 | `init -> direct upload -> confirm` 正常承接 | 沿用既有签收文书；本轮未重跑 upload | 真实命中 | 否 | 本轮目标不在 upload；沿用已冻结 development-stage 证据。 |
| create 提交 | 项目发布 | `POST /api/app/project/create -> 202 + projectId` | 现网 tunnel 复测 | 真实命中 | 否 | `POST /api/app/project/create -> 202`，返回 `projectId = 0516a679-1989-4108-ba46-4cd4887654d6`。 |
| create 成功 -> 公域详情 | 项目发布 / 项目展示 | 使用返回 `projectId` 进入公域详情 | 现网 tunnel 复测 | 真实命中 | 否 | `GET /api/app/project/detail?projectId=0516a679-1989-4108-ba46-4cd4887654d6 -> 200`。 |
| 公域项目列表 | 项目展示 | 列表读取已发布项目，不混入私域态 | 现网 tunnel 复测 | 真实命中 | 否 | 正式承接路径是 `GET /api/app/project/list -> 200`；fresh `projectId` 已出现在列表首项。 |
| 公域项目详情 | 项目展示 | 详情只读公开字段，owner 只做 handoff，不做私域真值 | 现网 tunnel 复测 | 真实命中 | 否 | 正式承接路径是 `GET /api/app/project/detail -> 200`；返回 `viewerProjectRelation = owner`，未混入私域进度真值。 |
| 公域详情 -> 我的项目 | 项目展示 / 项目发布工作台 | owner 可回流到私域承接面 | 现网 tunnel 复测 + 移动端路由代码 | 真实命中 | 否 | `GET /api/app/my/projects/0516... -> 200`，形成 owner 私域回流。 |
| 我的项目列表 | 项目发布工作台 | 展示当前组织项目分组，不替代工作台或展示页 | 现网 tunnel 复测 | 真实命中 | 否 | `GET /api/app/my/projects -> 200`；fresh 项目位于 `ongoingProjects` 首项。 |
| 我的项目详情 | 项目发布工作台 | 承接 owner 私域详情与 privateProgress | 现网 tunnel 复测 | 真实命中 | 否 | 正式承接路径是 `GET /api/app/my/projects/{projectId} -> 200`；返回 `publicProject + privateProgress`。 |

## 3. demo fallback 剥离表

| 页面/接口 | 是否存在 demo fallback | 触发条件 | 当前真实链路状态 | 是否会误导为已打通 | 是否必须先清除 |
|---|---|---|---|---|---|
| `/exhibition/workbench` | 是 | 移动端 `futureReal` 返回 `errorRetryable` 且 message 为 `current fake transport did not provide this canonical path` 时切 demo | 本轮对应 canonical API `GET /api/app/exhibition/workbench -> 200` | 否 | 否 |
| `/exhibition/projects` | 是 | 同上；页面实际依赖 canonical API `GET /api/app/project/list` | 本轮 canonical API `GET /api/app/project/list -> 200`；用户补充核对中的 `/api/app/exhibition/projects -> 404 raw Not Found` 不是正式承接路径 | 否 | 否 |
| `/exhibition/projects/detail` | 是 | 同上；页面实际依赖 canonical API `GET /api/app/project/detail` | 本轮 canonical API `GET /api/app/project/detail?projectId=0516... -> 200`；`/api/app/exhibition/projects/detail?... -> 404 raw Not Found` 不是正式承接路径 | 否 | 否 |
| `/exhibition/my/projects` | 是 | 同上；页面实际依赖 canonical API `GET /api/app/my/projects` | 本轮 canonical API `GET /api/app/my/projects -> 200`；`/api/app/exhibition/my/projects -> 404 raw Not Found` 不是正式承接路径 | 否 | 否 |
| `/exhibition/my/projects/detail` | 是 | 同上；页面实际依赖 canonical API `GET /api/app/my/projects/{projectId}` | 本轮 canonical API `GET /api/app/my/projects/0516... -> 200`；错误写法 `/api/app/my/projects/detail?projectId=... -> 404 AUTH_RESOURCE_UNAVAILABLE` | 否 | 否 |

补充说明：

- 移动端页面层仍保留 demo fallback 机制。
- 但当前代码与测试已把来源文案显式区分为：
  - `当前展示：已接通内容`
  - `当前展示：演示内容`
- 因此，当前风险不是“demo 被当真”，而是“核验时必须使用正确 canonical API，而不是把页面路由名误当 API 路由名”。

## 4. 真值边界核查表

| 对象 | 当前 owner | 允许语义 | 禁止语义 | 当前是否漂移 | 处理结论 |
|---|---|---|---|---|---|
| `project.state` | `Server project` | 公域生命周期 | visibility / review / 私域推进 | 否 | 本轮 `project/list`、`project/detail`、`my/projects/{id}` 返回均未发现职责漂移。 |
| `publishedAt` | `Server project` | 公域准入 | 生命周期全语义 | 否 | 本轮未见额外 visibility carrier 注入。 |
| `viewerProjectRelation` | `project/detail` 读投影 | owner/non-owner handoff | 权限真值 | 否 | 本轮 `project/detail -> owner` 仅承担 handoff。 |
| `privateProgress` | `my/projects/{id}` 读投影 | 私域推进与完结投影 | 公域展示判断 | 否 | 本轮仅出现在 `my/projects/{id}`，未回写进公域 detail。 |
| `workbench summary` | `exhibition/workbench` 摘要投影 | 私域摘要与 route handoff | 第二状态机 / 第二后台 | 否 | 本轮 `workbench` 仅返回四容器摘要与 route-handoff 位。 |

## 5. 板块结论表

### 5.1 项目发布工作台

- 当前状态：
  - 私域读链已真实命中：
    - `GET /api/app/exhibition/workbench -> 200`
    - `GET /api/app/my/projects -> 200`
    - `GET /api/app/my/projects/{projectId} -> 200`
  - create 后再次读取 `workbench`，`recentProjectId` 已更新为 fresh `projectId = 0516a679-1989-4108-ba46-4cd4887654d6`。
- 结论类型：
  - `真实闭环`
- 当前是否允许进入联调发布判断：
  - `允许`
- 当前阻断项：
  - 无当前主链阻断项

### 5.2 项目发布

- 当前状态：
  - `POST /api/app/project/create -> 202`
  - `GET /api/app/project/detail?projectId=<fresh> -> 200`
  - fresh `projectId` 已回流进入：
    - `workbench.recentProjectId`
    - `my/projects ongoingProjects`
    - `project/list items`
- 结论类型：
  - `真实闭环`
- 当前是否允许进入联调发布判断：
  - `允许`
- 当前阻断项：
  - 无当前主链阻断项

### 5.3 项目展示

- 当前状态：
  - 正式公域展示链的 canonical API 已真实命中：
    - `GET /api/app/project/list -> 200`
    - `GET /api/app/project/detail?projectId=<fresh> -> 200`
  - 用户补充核对中的：
    - `/api/app/exhibition/projects`
    - `/api/app/exhibition/projects/detail`
    - `/api/app/exhibition/my/projects`
    均为 raw `404 Not Found`，不能作为展示面承接证据。
- 结论类型：
  - `真实闭环`
- 当前是否允许进入联调发布判断：
  - `允许`
- 当前阻断项：
  - 无当前主链阻断项

## 6. 总控裁决区

### 6.1 passed gates

- 真实认证样本已可登录并切换到指定组织：
  - `login -> 200`
  - `organization/switch -> 201`
- 私域读链已真实命中：
  - `workbench -> 200`
  - `my/projects -> 200`
  - `my/projects/{projectId} -> 200`
- `project/create` 已真实命中：
  - `202 + fresh projectId`
- `create -> detail` 已形成真实闭环：
  - `project/detail -> 200`
- create 后 fresh `projectId` 已同时进入：
  - `workbench`
  - `my/projects`
  - `project/list`
- 页面 demo fallback 仍存在，但当前已通过显式来源文案与正确 canonical API 证据完成剥离，不再构成“把 demo 当真”的直接误判条件。

### 6.2 failed gates

- 无本轮主链 failed gate

### 6.3 veto gates

- `No-Go for production release`
- 当前所有通过结论仍只成立于：
  - `development-stage real-chain verification`

### 6.4 stage decision

- `Go for 真实链路联调`
- `Go for 联调发布前置准备`
- `No-Go for production release`

## 7. 强制结论格式

1. 真实命中的链路是：
   - `POST /api/app/auth/otp/login`
   - `POST /api/app/profile/organization/switch`
   - `GET /api/app/exhibition/workbench`
   - `GET /api/app/my/projects`
   - `POST /api/app/project/create`
   - `GET /api/app/project/detail`
   - `GET /api/app/project/list`
   - `GET /api/app/my/projects/{projectId}`
2. 只是 demo 承接的不是上述 canonical API 主链；当前仍保留 demo fallback 的是页面层 `/exhibition/workbench`、`/exhibition/projects`、`/exhibition/projects/detail`、`/exhibition/my/projects`、`/exhibition/my/projects/detail`，但它们在当前代码中已被明确标识为 `当前展示：演示内容`，本轮未把 demo 当成通过证据。
3. 当前仍然只是 `development-stage` 结论，不是 release-ready 结论。
4. 当前允许进入联调发布，但只允许按当前 development-stage 已真实命中的三板块主链进入，不得升格解释为 production release。

## 8. 复核摘要

- `私域读链是否已真实命中`
  - 是。`workbench -> 200`，`my/projects -> 200`，`my/projects/{projectId} -> 200`。
- `project/create 是否已真实命中`
  - 是。`project/create -> 202 + projectId`。
- `create -> detail 是否已形成真实闭环`
  - 是。fresh `projectId` 已命中 `project/detail -> 200`，并回流到 `workbench`、`my/projects`、`project/list`。
- `当前是否允许进入联调发布`
  - 允许，但范围仅限本轮已验证通过的 development-stage 三板块主链。
