---
owner: Codex 总控
status: frozen
purpose: Reconcile the cloud active runtime on `47.108.180.198` with the current stage documents, separating what is actually running from what is only documented, and freezing the next concrete worklist from this real state.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_completion_stage_route_map_v1.md
  - docs/00_ssot/current_stage_and_unique_mainline_ruling_v1.md
  - docs/00_ssot/stage_entry_exit_conditions_table_v1.md
  - docs/00_ssot/stage_dispatch_routing_matrix_v1.md
  - docs/00_ssot/stage2_transport_admin_support_closure_conclusion_addendum.md
  - docs/00_ssot/stage3_stage_gate_checklist_addendum.md
  - docs/00_ssot/bff_runtime_repo_drift_closure_assessment_addendum.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - cloud runtime observation at `47.108.180.198` on `2026-04-09`
---

# 《云上 active runtime 真实状态对账回执 V1》

## 1. Scope

- 本回执只回答：
  - 云上当前 active runtime 到底有哪些东西真的在跑
  - 哪些对象已经完成
  - 哪些对象只是 skeleton / support / 历史 smoke evidence
  - 哪些阶段文书需要被重新理解
  - 从这个真实状态出发，接下来有哪些工作必须完成
- 本回执不做：
  - implementation unlock
  - execution dispatch
  - release go/no-go
  - 直接改写阶段总路线文书

## 2. 云上真实拓扑

当前 `47.108.180.198` 的真实拓扑已核验为：

- `:80`
  - `nginx`
- `:3000`
  - active `BFF`
- `:3001`
  - active `Server`
- `:3002`
  - active `Admin (Next.js)`
- `:3100`
  - staging / smoke `BFF`
- `:3101`
  - staging / smoke `Server`
- `:18080`
  - staging / smoke `nginx`

当前 active release 与运行来源已核验为：

- `BFF`
  - `/srv/apps/bff/current -> /srv/releases/bff/20260407125632/apps/bff`
- `Server`
  - `/srv/apps/server/current -> /srv/releases/server/20260407113018`
- `Admin`
  - `/srv/apps/admin/current -> /srv/workspaces/exhibition-infra-monorepo/apps/admin`
  - 当前不是 release artifact
  - 当前是 workspace 直挂

## 3. 已在云上真实成立的对象

### 3.1 BFF / Server 运行本体

- `BFF` 与 `Server` active process 已成立。
- `3000/3001` 都能返回健康响应。
- `Nginx` 已将 app-facing `/api/app/*` 家族 rewrite 到 `BFF`。

### 3.2 Admin skeleton 已真实存在

当前 `Admin` 不是空目录。已核验到：

- 页面入口：
  - `/login`
  - `/review`
  - `/governance`
  - `/project_review`
  - `/template_config`
  - `/audit`
  - `/ticketing`
- `Nginx` 已将上述页面路由与 `/_next/*`、`/api/health`、`/api/admin/*` 接入 `3002`。
- `GET /api/health` 已返回：
  - `ok = true`
  - `mode = phase1b-admin-skeleton`
  - `serverAdminApiBaseUrl = http://127.0.0.1:3001/server/admin`

### 3.3 Admin 不是纯静态壳，已有真实 service client 和 action form

当前 `apps/admin` 已存在真实模块与服务端调用代码：

- `src/modules/review/review-shell.tsx`
  - 调 `fetchContentSafetyReviewTasks`
  - 调 `fetchContentSafetyReviewTask`
  - 调 `approveProfileSafetySubmission`
  - 调 `rejectProfileSafetySubmission`
- `src/modules/governance/penalty-shell.tsx`
  - 调 `fetchGovernancePenalties`
  - 调 `fetchGovernancePenalty`
  - 调 `applyGovernancePenalty`
- `src/modules/governance/appeal-shell.tsx`
  - 调 `fetchGovernanceAppeals`
  - 调 `fetchGovernanceAppeal`
  - 调 `decideGovernanceAppeal`

这说明：

- `阶段 3` 并不是“完全没做”
- 已经有：
  - workbench 页面骨架
  - API client
  - form action
  - Nginx route
  - `Server Admin API` passthrough

### 3.4 部分 app-facing profile / my-project 读走廊已真实存在

在 `:80` active chain 上，以下接口至少已走到 `BFF` auth guard：

- `GET /api/app/profile/index`
- `GET /api/app/profile/organization/mine`
- `GET /api/app/profile/certification/current`
- `GET /api/app/my/projects`
- `GET /api/app/profile/governance/status`

它们当前返回 `401 AUTH_SESSION_INVALID`，而不是原始 nginx 404。

这说明：

- 这些路由 family 在 active runtime 中已存在
- 当前缺的是有效会话或更深层 runtime 对齐
- 不是“根本没接线”

## 4. 当前没有真实完成，或只停在 skeleton 的对象

### 4.1 Admin 登录仍是占位态

当前 `/login` 页面明确仍然是：

- 登录占位页
- 账号/密码 disabled
- 登录按钮 disabled
- 凭据来源待确认

因此：

- `Admin login` 没有形成真实可登录闭环
- 当前 `review / governance / project_review / audit / ticketing` 都仍受登录占位态阻断

### 4.2 展览交易主链 app-facing transport 没有在 active runtime 成立

在 `:80` active chain 与 `:18080` smoke chain 上，以下接口均返回 `404`：

- `GET /api/app/order/detail`
- `GET /api/app/contract/detail`
- `GET /api/app/milestone/list`
- `GET /api/app/inspection/detail`

因此：

- 旧 `stage2 transport closure` 不能直接等价理解为“当前 active runtime 已完成”
- 至多只能理解为：
  - 曾有历史 smoke / 文书证据
  - 但尚未 materialize 到当前 active release

### 4.3 `message/index` 当前没有成立

当前在 `:80` 与 `:18080` 上：

- `GET /api/app/message/index -> 404`

因此：

- `message/index` 当前不应被写成 active runtime 已完成
- 当前仍需要 `阶段 4` 重新收口

### 4.4 `profile/governance/appeals` 当前没有成立

当前：

- `POST /api/app/profile/governance/appeals -> 404`

但：

- `GET /api/app/profile/governance/status -> 401`

这说明：

- `governance status` 读路径有一定接线
- `appeals` 写路径当前未 materialize

### 4.5 staging / smoke 链存在 runtime drift

在 `:18080` 上，以下接口返回 `502`，上游指向 `127.0.0.1:3003`：

- `GET /api/app/profile/index`
- `GET /api/app/profile/organization/mine`

因此：

- 当前 smoke 链自身就存在上游漂移
- `:18080` 不能直接被当作稳定 closure 证据

### 4.6 Admin 当前不符合 release artifact discipline

当前：

- `apps/admin/current` 直接指向 workspace
- 不是 `/srv/releases/...`

因此：

- 当前 `Admin` 不能被当作正式 release artifact 管理对象
- 这会直接阻断后续 `阶段 10 release-prep`

## 5. 对阶段系统的影响

### 5.1 哪些结论应保留

- `阶段 1` 已有较强 closure 证据，当前不必重做。
- `阶段 3` 已有真实 skeleton 与 workbench 基座，不能再被说成“完全没开始”。

### 5.2 哪些结论必须降级理解

- 旧 `stage2 closure`
  - 必须降级理解为：
    - `历史文书 / smoke evidence`
  - 不能继续口头偷换成：
    - `当前 active runtime on :80 已 closure`

### 5.3 当前最真实的项目状态

从 active runtime 看，当前项目不是“阶段 2 和阶段 3 都完整完成”。

当前更准确的状态应理解为：

- `阶段 2`
  - active runtime materialization 未完成
- `阶段 3`
  - skeleton / service client / route wiring 已完成一部分
  - 但 login、session、真实闭环未完成

因此当前后续工作不能再只按旧文书说“直接进入阶段 3 后段”，
而应先做：

- runtime truth reconciliation
- 然后按真实链路重新安排 `阶段 2` 与 `阶段 3` 的收口顺序

## 6. 接下来必须完成的工作总清单

以下工作按必须顺序排列，不允许跳步。

### 工作包 0：总控文书重裁

目标：

- 用本回执替代“凭文书记忆推进”
- 把云上 active runtime 与现有阶段文书重新对齐

必须完成：

- 输出 `阶段状态重裁单`
  - 明确 `阶段 2` 哪些只是历史 smoke closure
  - 明确 `阶段 3` 哪些已经是 skeleton 完成
  - 明确当前唯一主线到底先收 `阶段 2 active runtime` 还是先收 `阶段 3 login/admin closure`
- 输出 `prod current` 与 `smoke current` 的正式口径
- 输出 `Admin workspace current` 的风险登记

完成标准：

- 后续所有阶段判断都以 active runtime truth 为准
- 不再拿旧 closure 直接替代当前 80 链现状

### 工作包 1：运维与发布基线修正

目标：

- 把当前运行环境从“能跑”收成“可发布、可回滚、可验收”

必须完成：

- 把 `apps/admin/current` 从 workspace 直挂改成 release artifact 切换模式
- 明确 `3000/3001/3002/3100/3101/18080` 的正式角色定义
- 修复 `:18080 -> 3003 ECONNREFUSED` 的 smoke drift
- 核清谁负责 active process：
  - `systemd`
  - `pm2`
  - 不允许同一对象双口径漂移
- 补 active health 路径口径
  - 当前对外不是 `/health/live`
  - 而是 `/health/bff/live`、`/health/server/live`

完成标准：

- `prod` 和 `smoke` 的运行边界清楚
- `Admin` 进入 release artifact 管理
- rollback unit 可引用

### 工作包 2：阶段 2 active runtime materialization

目标：

- 把展览交易主链的最小 app-facing transport 真正落到当前 `:80` active chain

必须完成的接口族：

- `GET /api/app/order/detail`
- `GET /api/app/contract/detail`
- `GET /api/app/milestone/list`
- `GET /api/app/inspection/detail`

必须完成的实现面：

- `Server`
  - 最小 read corridor truth
  - scope / actor / state gate
  - 统一错误语义
- `BFF`
  - app-facing route materialization
  - response shaping
  - canonical path 与 error normalization
- `mobile`
  - 当前你本地前端消费面与 active route 对齐
  - 去除对不存在 upstream 的伪依赖

必须核验：

- `:80` 上不是 404
- `:18080` smoke 链也稳定
- 有效会话下能返回真实受控数据
- 无效会话下返回预期的 auth / forbidden 语义

完成标准：

- 这四条路在当前 active runtime 真正成立
- `阶段 2` 才能被再次判为 closure

### 工作包 3：阶段 3 Admin 最小运营与治理闭环

目标：

- 把已经存在的 Admin skeleton 推进到最小可用工作台闭环

当前已存在的基础，不要重做：

- 登录页
- review shell
- governance penalty shell
- governance appeal shell
- project review / template config / audit / ticketing 页面骨架
- `api/admin/*` nginx passthrough
- `serverAdminApiBaseUrl` 注入

必须补齐的点：

- 真实管理员会话方案
  - 凭据来源
  - session carrier
  - cookie / bearer / second factor 方案
- Admin 登录完成后能真正进入：
  - `/review`
  - `/governance/penalties`
  - `/governance/appeals`
- 当前 `review-shell` 依赖的接口必须全部可用：
  - `/content-safety/review-tasks`
  - `/content-safety/review-tasks/{taskId}`
  - `/content-safety/profile-submissions/{submissionId}/approve`
  - `/content-safety/profile-submissions/{submissionId}/reject`
- 当前 `penalty-shell` 依赖的接口必须全部可用：
  - `/governance/penalties`
  - `/governance/penalties/{penaltyId}`
  - `POST /governance/penalties`
- 当前 `appeal-shell` 依赖的接口必须全部可用：
  - `/governance/appeals`
  - `/governance/appeals/{appealCaseId}`
  - `POST /governance/appeals/{appealCaseId}/decide`

执行角色：

- 第一执行 owner：
  - 后端
  - 覆盖 `apps/server` 与 `apps/admin`
- `BFF`
  - 不得成为 Admin 主通道
- 你本地前端：
  - 本阶段默认不介入

完成标准：

- Admin 真实可登录
- review / governance 页面真实加载数据
- form action 提交不再只回错误
- 所有治理动作通过 `Server` 留审计

### 工作包 4：阶段 4 消息楼与 `message/index`

目标：

- 把 `message/index` 从当前 404 状态收成明确闭环

必须完成：

- 正式裁决 `/api/app/message/index`
  - 是继续 `fail-closed`
  - 还是补最小真实 upstream
- 若继续 fail-closed：
  - contract、error semantics、mobile consumer 必须统一
- 若补真实 upstream：
  - `Server`、`BFF`、`mobile` 三段都要接齐

必须核验：

- `forum inbox` 和 `message/index` 不形成双 active object
- `routeTarget` 与 mobile 跳转承接一致
- 当前 `:80` 上不能再是裸 404

完成标准：

- `message/index` 要么是受控 fail-closed
- 要么是最小可用
- 但绝不能是现在这种“文书写过，runtime 404”

### 工作包 5：阶段 5 我的楼功能本体 Round 1

目标：

- 在前面的 runtime 基座稳定后，重新收口 `我的楼 / profile / 我的项目`

必须完成：

- 修正历史阻塞：
  - `certificationStatus` 语义漂移
- 复核 active runtime 的 profile command family：
  - organization create / join / switch
  - certification submit / resubmit
- 复核 `my/projects` 与 `my/projects/{projectId}` 在当前链上的真实表现
- 重做 integration verification

你本地前端需要做的具体工作：

- 对齐 `apps/mobile/lib/features/profile/**`
- 对齐 `apps/mobile/lib/features/exhibition/**` 中 `my_project` 的承接页
- 对齐认证状态分支和测试
- 只消费真实存在的云上 app-facing route

完成标准：

- `profile` 和 `my_project` 不再靠 placeholder 撑结论
- Round 1 result verification 与 integration verification 均通过

### 工作包 6：阶段 6 V2.0 membership package

目标：

- 先把会员从边界文书推进到 rules / contracts / truth / surface / implementation

必须完成：

- `rules-freeze judgment`
- contracts 冻结
- backend truth 设计
- BFF surface
- mobile 消费面

必须坚持：

- 不复用 `membershipStatus`
- 不偷带 `V2.1 / V2.2 / V2.3`

完成标准：

- paid membership 成为独立真相对象族
- entitlement / quota 可执行可审计

### 工作包 7：阶段 7 V2.1 信用 / 保证金 / 交易保障

目标：

- 从 boundary freeze 推进到 rules / contracts / truth / surface / execution

必须完成：

- 信用 posture
- 保证金 requirement / status / handoff
- 交易保障 eligibility / restriction / handoff
- 与交易链、审计链、处罚/申诉链绑定

完成标准：

- 不是只看文案说明
- 而是真正具备受控执行与追踪

### 工作包 8：阶段 8 V2.2 支付 / 账单 / 服务费

目标：

- 建立 payment / billing / service-fee 的最小结算闭环

必须完成：

- payment family
- billing family
- service fee 核算
- 失败与回退语义
- 审计链

完成标准：

- 当前不能再停留在 boundary 文书
- 必须走完整的 `rules -> contracts -> backend -> bff -> frontend -> verification`

### 工作包 9：阶段 9 V2.3 私域操作系统整理

目标：

- 只整理 `我的楼` 的 regrouping / entry-order / corridor

必须完成：

- 入口顺序重整
- bounded IA 重整
- corridor 与 handoff 重整
- 性能与首屏负载复核

必须坚持：

- 不做第二 dashboard
- 不做 cross-building rewrite

完成标准：

- `我的楼` 的私域分层、导流和可达性稳定

### 工作包 10：阶段 10 release-prep -> launch -> 上线后 90 天运营

目标：

- 在前面所有阶段 closure 后，做真正可回滚、可复核的上线

必须完成：

- release artifact 管理
  - 包括 `Admin`
- env partition
  - `local / dev / staging / prod`
- 灰度 / 白名单 / flag rollback 顺序
- 独立验证入口
- 90 天平台化运营收口

完成标准：

- 不是“服务跑着就算上线”
- 而是：
  - release-prep 可复核
  - launch 可回滚
  - 90 天运营可结案

## 7. 现在的唯一下一步

当前唯一下一步动作固定为：

- `由总控输出《云上 active runtime 对账后的阶段重裁单》`

原因固定为：

- 当前 active runtime 已证明旧阶段结论与现状有漂移
- 不先重裁，后续 implementation 会继续建立在错误阶段定位上

## 8. Formal Conclusion

- 云上确实已经完成了一部分工作：
  - `BFF / Server` active runtime
  - `Admin` skeleton、module shell、API client、Nginx route
  - 部分 `profile / my-project / governance status` app-facing 入口
- 但当前 active runtime 明确没有完成：
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `inspection/detail`
  - `message/index`
  - `profile/governance/appeals`
  - `Admin` 真实登录闭环
- 因此接下来必须先做：
  - runtime truth reconciliation
  - 再按真实状态推进 `阶段 2 / 阶段 3 / 阶段 4 / 阶段 5...`
