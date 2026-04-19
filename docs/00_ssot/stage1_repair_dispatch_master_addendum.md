---
owner: Codex 总控
status: frozen
purpose: Freeze the stage-1 repair dispatch master sheet, including the full repair object set, strict execution order, role routing, forbidden scopes, verification routing, and closure-entry conditions, without granting stage-2 entry or release approval.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/current_stage_and_unique_mainline_ruling_v1.md
  - docs/00_ssot/platform_completion_document_freeze_sync_review_receipt_addendum.md
  - docs/00_ssot/app_infrastructure_upgrade_scan_addendum.md
  - docs/00_ssot/p0_1_public_login_opening_judgment_addendum.md
  - docs/00_ssot/stage_dispatch_routing_matrix_v1.md
  - apps/server/src/modules/auth/auth.controller.ts
  - apps/server/src/modules/auth/auth-anti-abuse.service.ts
  - apps/server/src/modules/shell/shell.controller.ts
  - apps/server/src/modules/profile/profile.controller.ts
  - apps/server/src/modules/review/organization-review.controller.ts
  - apps/bff/src/routes/profile/app-profile-read.controller.ts
  - apps/bff/src/routes/profile/profile-command.service.ts
  - apps/bff/src/routes/profile/profile-governance-appeals.service.ts
  - apps/admin/src/core/server/admin-api-client.ts
  - apps/mobile/lib/features/messages/data/messages_consumer_layer.dart
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
---

# 《阶段 1 repair dispatch 总派工单》

## 1. stage 1 repair dispatch master receipt

- 当前真实阶段固定为：
  - `阶段 1｜P0 前置依赖修复总包`
- 本轮文书完成后，当前阶段推进到：
  - `dispatch 完成`
- 本轮只冻结：
  - 阶段1完整 repair 对象清单
  - 严格执行顺序
  - 第一执行角色与配合角色
  - 禁止范围
  - verification 路由
  - closure 进入条件
- 本轮不授予：
  - `阶段2` 进入权
  - `release-prep`
  - `launch`
  - 任何超出阶段1边界的 implementation 扩写
- 角色与拓扑固定如下：
  - `前端 Agent`：本地
  - `BFF Agent`：阿里云
  - `后端 Agent`：阿里云
  - `结果校验 Agent`：独立复核
  - `联调发布 Agent`：阶段1不得介入
  - 云端受控隧道：`ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

## 2. stage 1 repair object list

### 2.1 阶段 1 必做 repair

| 编号 | repair 对象 | 阶段1最小 closure 目标 | 第一执行角色 | 配合角色 | 当前不得混入 |
|---|---|---|---|---|---|
| `S1-R01` | `P0-1a` 公开登录开通 backend repair | 关闭 `AUTH_PUBLIC_OTP_SEND_ENABLED + whitelist/test gate` 语义漂移，稳定 `/server/auth/otp/send`、登录后 session、audit、anti-abuse 的公众可用口径。 | `后端 Agent` | `BFF Agent`、`前端 Agent` | 不得顺手打开 `P0-2+`、不得写成公众正式上线、不得新开第二套登录路径。 |
| `S1-R02` | `P0-2` organization scope 最小闭环 | 稳定 `/server/shell/context`、`/server/profile/organization/create|join-by-code|switch`、`/api/app/profile/organization/mine` 的承接，确保 `organizationId / roleKeys / certificationStatus / membershipStatus / visibleBuildings` 可稳定消费。 | `后端 Agent` | `BFF Agent`、`前端 Agent` | 不得扩成 `my_building Round 1`、不得新增 profile 第二真源。 |
| `S1-R03` | `P0-3` 企业认证上传 / 提交 / 重提闭环 | 把移动端认证主路径从手填 `licenseFileId` 改成 `init -> direct upload -> confirm -> submit/resubmit`，对齐 `/api/app/file/upload/init|confirm` 与 `/api/app/profile/certification/submit|resubmit`。 | `前端 Agent` | `BFF Agent`、`后端 Agent` | 不得保留手填 `licenseFileId` 为主路径、不得混入个人实名。 |
| `S1-R04` | `P0-4` 企业认证最小审核运营闭环 | 形成 `server/admin/reviews/organizations` 最小审核可运行闭环，保证认证状态能稳定进入 `approved / rejected` 并可被 profile/shell 正确承接。 | `后端 Agent` | `前端 Agent` | 不得扩成完整 Admin 平台、不得混入 content-safety 任务体系。 |
| `S1-R05` | `BFF <-> Server governance appeals` 路由对齐 | 关闭 `/api/app/profile/governance/appeals*` 与 `Server` profile 侧真实读路由漂移，消除 BFF 假可用。 | `后端 Agent` | `BFF Agent` | 不得只在 BFF 伪兜底、不得把 admin appeals 路由冒充 profile reads。 |
| `S1-R06` | `P0-5` 消息楼单一对象真源裁决 | 锁死 `messages` building 当前唯一 active object，裁掉 `forum interaction inbox` 与 `message/index` 双主线并存。 | `总控` | `总控文书冻结` | 不得直接进入 `message/index` body 扩写、不得让两套对象并存。 |

### 2.2 阶段 2 前置依赖，但阶段 1 只做最小 closure

| 编号 | 对象 | 阶段1必须完成的最小 closure | 第一执行角色 | 配合角色 | 明确留给阶段2的部分 |
|---|---|---|---|---|---|
| `S1-C01` | `message/index` 最小 closure | 在 `S1-R06` 后，明确 `/api/app/message/index` 的 active owner、最小 contract、错误语义、routeTarget 对齐口径；若当前仍未正式开放，必须 fail-closed，不能再让客户端把它当已运行 transport。 | `总控文书冻结` | `后端 Agent`、`BFF Agent`、`前端 Agent` | 真实列表/详情/动作 body 的完整实现与扩写。 |
| `S1-C02` | 展览交易主链 transport 最小 route / contract / inventory closure | 对 `bid / order / contract / milestone / inspection / rating / dispute` 做最小 route/contract/inventory 对齐，显式区分“当前可运行 / 当前关闭 / 当前缺载体”，并把 ghost route 从首发可运行口径里剔除。 | `总控文书冻结` | `后端 Agent`、`BFF Agent`、`前端 Agent` | 各交易 family 的完整 controller/service/body 实现。 |
| `S1-C03` | Admin `content-safety/review-tasks` 最小接口闭环 | 给当前 Admin client 依赖的 `/content-safety/review-tasks` 建立最小接口闭环或同等 canonical 对齐，消除现有 orphan API gap。 | `后端 Agent` | `前端 Agent` | 完整内容安全任务编排、批量操作、运营可视化深化。 |

### 2.3 当前暂不进入

| 编号 | 当前暂不进入对象 | 不进入原因 |
|---|---|---|
| `S1-X01` | `message/index` 完整 body 扩写 | 必须等 `S1-R06` 与 `S1-C01` 完成后，再按阶段2进入。 |
| `S1-X02` | 完整 `bid / order / contract / milestone / inspection / rating / dispute` implementation 主线 | 当前只允许最小 route/contract/inventory closure，不允许进入完整交易实现。 |
| `S1-X03` | `payment / billing` | 当前不属于阶段1。 |
| `S1-X04` | `V2.3 私域操作系统整理` | 当前不属于阶段1。 |
| `S1-X05` | `个人实名` | 当前不属于阶段1。 |
| `S1-X06` | `release-prep / launch` | 当前阶段尚未满足任何发布前提。 |

## 3. repair execution order

1. `S1-R01`  
进入条件：当前主线仍停留在 `stage-1 dispatch authoring`。  
进入下一项条件：后端执行回执形成，且 `结果校验 Agent` 确认公开 OTP send 不再依赖开发态/白名单语义。

2. `S1-R02`  
进入条件：`S1-R01` 通过。  
进入下一项条件：`shell/context + organization create/join-by-code/switch + organization/mine` 在真实公众 actor 前提下稳定承接。

3. `S1-R03`  
进入条件：`S1-R02` 通过。  
进入下一项条件：移动端认证主路径已不再把手填 `licenseFileId` 当主路径，上传三段式与 submit/resubmit 串通。

4. `S1-R04`  
进入条件：`S1-R03` 通过。  
进入下一项条件：最小认证审核闭环可把状态稳定推进为 `approved / rejected`，并且可被 profile/shell 回读。

5. `S1-R05`  
进入条件：`S1-R04` 通过。  
进入下一项条件：`/api/app/profile/governance/appeals*` 已不再漂移到不存在的 server profile 路由。

6. `S1-R06`  
进入条件：`S1-R05` 通过。  
进入下一项条件：`messages` building active object 已被总控裁死，文书冻结已同步。

7. `S1-C01`  
进入条件：`S1-R06` 通过。  
进入下一项条件：`message/index` 的阶段1最小 closure 已完成，客户端不再把不存在的 transport 当作已运行内核。

8. `S1-C03`  
进入条件：`S1-C01` 通过。  
进入下一项条件：Admin `review-tasks` 已不再是 orphan API gap。

9. `S1-C02`  
进入条件：`S1-C03` 通过。  
进入 closure 评估条件：交易主链最小 route / contract / inventory closure 已形成，且 ghost route 不再冒充可运行 transport。

## 4. role assignment

| 对象 | 第一执行角色 | 为什么先给这个角色 | 后续接力 |
|---|---|---|---|
| `S1-R01` | `后端 Agent` | 真实阻塞在 `Server` runtime gate、OTP send 语义、session truth。 | `BFF Agent` 对齐错误语义，`前端 Agent` 对齐 fail-closed 承接。 |
| `S1-R02` | `后端 Agent` | organization scope 与 `shell/context` 真相在 `Server`。 | `BFF Agent` 聚合，`前端 Agent` 回读与守卫消费。 |
| `S1-R03` | `前端 Agent` | 当前主缺口是移动端仍以手填 `licenseFileId` 为主路径。 | `BFF Agent` 保持 transport 一致，`后端 Agent` 保持 fileAsset/certification truth。 |
| `S1-R04` | `后端 Agent` | `organization review` 的真相与状态推进在 `Server`。 | `前端 Agent` 只补最小运营消费面。 |
| `S1-R05` | `后端 Agent` | canonical profile read route 应由 `Server` 先定。 | `BFF Agent` 再改转发与 shaping。 |
| `S1-R06` | `总控` | 这是对象真相裁决，不是执行角色自行决定。 | `总控文书冻结` 同步口径，`结果校验 Agent` 独立复核。 |
| `S1-C01` | `总控文书冻结` | 先锁最小 contract/owner/error 口径，再允许执行角色接入。 | `后端 Agent`、`BFF Agent`、`前端 Agent` 按冻结口径做最小 closure。 |
| `S1-C03` | `后端 Agent` | 当前缺的是 server 侧最小接口闭环。 | `前端 Agent` 对齐 Admin client consumption。 |
| `S1-C02` | `总控文书冻结` | 这是最小 route/contract/inventory closure，不是完整交易实现。 | `后端 Agent`、`BFF Agent`、`前端 Agent` 仅做必要对齐。 |

## 5. forbidden scopes

- 阶段1全局禁止：
  - 直接切入 `阶段2`
  - 直接发 `release-prep / launch` 口令
  - 借 repair 顺手打开 `payment / billing`、`V2.3`、`个人实名`
  - 把 `总控` 或 `总控文书冻结` 变成代码执行角色
- `S1-R01` 禁止：
  - 宣称公众正式上线
  - 新开第二登录体系
- `S1-R02` 禁止：
  - 把 profile 写成第二状态机或第二真源
- `S1-R03` 禁止：
  - 保留手填 `licenseFileId` 为 happy-path 主路径
- `S1-R04` 禁止：
  - 扩成完整 Admin 平台建设
- `S1-R05` 禁止：
  - 只在 BFF 静态兜底假装路由存在
- `S1-R06` 禁止：
  - 未裁决先开 `message/index` implementation
- `S1-C01` 禁止：
  - 在双对象并存状态下宣称 `message/index` 已可运行
- `S1-C02` 禁止：
  - 进入 `bid/order/contract/milestone/inspection/rating/dispute` 完整 body 实现
- `S1-C03` 禁止：
  - 借最小接口闭环扩成完整内容安全平台

## 6. verification routing

| 对象 | 验证角色 | 核验重点 | 通过后才能进入 |
|---|---|---|---|
| `S1-R01` | `结果校验 Agent` | 公众 OTP send 语义、rate limit、audit、session establish、BFF/mobile 兼容性 | `S1-R02` |
| `S1-R02` | `结果校验 Agent` | `shell/context`、organization scope、guard handoff、真实 actor 承接 | `S1-R03` |
| `S1-R03` | `结果校验 Agent` | 上传三段式、submit/resubmit、无手填主路径、受控错误态 | `S1-R04` |
| `S1-R04` | `结果校验 Agent` | 组织认证最小审核链、状态回读、审计留痕 | `S1-R05` |
| `S1-R05` | `结果校验 Agent` | appeals list/detail 路由不漂移、BFF 不再伪成功 | `S1-R06` |
| `S1-R06` | `结果校验 Agent` | messages active object 结论是否单一、是否无双主线口径 | `S1-C01` |
| `S1-C01` | `结果校验 Agent` | `message/index` 最小 contract、owner、error 语义、客户端不再误判已运行 | `S1-C03` |
| `S1-C03` | `结果校验 Agent` | Admin `review-tasks` 最小接口闭环与现有 client 对齐 | `S1-C02` |
| `S1-C02` | `结果校验 Agent` | 交易主链最小 route/contract/inventory closure、ghost route 清除、S2 packet 可引用 | `closure 评估` |

- 阶段1中的 `联调发布 Agent`：
  - 不得介入 execution
  - 不得出任何 release 口径
  - 如需云端证据采样，只能在总控单独授权下做受控取证

## 7. closure entry conditions

- 只有同时满足以下条件，阶段1才允许进入 `verification / closure`：
  - `S1-R01 ~ S1-R06` 全部完成并通过独立校验
  - `S1-C01 ~ S1-C03` 的阶段1最小 closure 全部完成并通过独立校验
  - `Gate-F1 ~ Gate-F5` 已不再作为进入后续阶段的当前 veto 阻断
  - `messages` 不再存在双对象口径
  - 交易主链 ghost route 已被显式清点，不再冒充可运行 transport
  - Admin `review-tasks` 不再是 orphan API gap
  - 认证上传主路径已不再依赖手填 `licenseFileId`
  - 遗留到阶段2的对象都已被显式登记为“完整 body / 扩写”，而不是未识别缺口

## 8. next unique action

- 当前阶段完成度：
  - `dispatch 完成`
- 当前下一步唯一动作：
  - `总控向后端 Agent 发出 S1-R01《P0-1a public login opening backend repair execution》口令`
- 下一步执行角色：
  - `总控`
- 下一步进入条件：
  - 本派工单已冻结
  - 当前主线仍为 `S1`
  - 未新增更高优先级 veto

## 9. Formal Conclusion

- 阶段1的 repair 对象、顺序、角色、禁止范围、verification 路由、closure 进入条件现已全部冻结。
- `message/index`、交易主链 transport 最小 route/contract/inventory closure、Admin `content-safety/review-tasks` 最小接口闭环，已明确留在阶段1派工单内，不再被模糊外移。
- 当前不得推进到：
  - `阶段2`
  - `release-prep`
  - `launch`
