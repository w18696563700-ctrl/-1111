---
owner: Codex 总控
status: frozen
purpose: Freeze a full capability diagnosis for `我的楼`, cross-checking current SSOT, code truth, route/transport/guard ownership, and prerequisite dependencies into `exhibition` and `messages`, without granting implementation unlock.
layer: L0 SSOT
freeze_date_local: 2026-04-08
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/my_building_code_prerequisite_dependency_audit_checklist_addendum.md
  - docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - apps/mobile/lib/features/profile/**
  - apps/bff/src/routes/profile/**
  - apps/server/src/modules/profile/**
  - apps/server/src/modules/auth/**
  - apps/server/src/modules/organization/**
  - apps/bff/src/routes/auth/**
  - apps/mobile/lib/core/auth/**
  - apps/mobile/lib/features/exhibition/**
  - apps/bff/src/routes/project/**
  - apps/bff/src/routes/forum/**
  - apps/server/src/modules/project/**
  - apps/server/src/modules/exhibition_workbench/**
  - apps/mobile/lib/features/messages/**
---

# 《我的楼全量能力诊断与跨楼层前置依赖审计》

## 1. Scope

- 本审计只回答：
  - `我的楼` 当前哪些能力已经真实成立
  - 哪些只是表层存在
  - 哪些是继续推进 `展览楼 / 消息楼` 前必须先补的前置
  - 下一步唯一动作应该是什么
- 本审计不代表：
  - implementation unlock
  - release-prep
  - launch
  - 新的 closure
  - 直接进入任何 agent 派工

## 2. Diagnostic Ruling

- `我的楼` 当前已经是正式的 current-user / organization / certification / governance / private-entry hub。
- 当前最核心的问题不是“我的楼没有代码”，而是：
  - 已有不少页面、route、transport、truth 分层存在
  - 但跨楼继续开发真正依赖的前置闭环还没有全部成立
- 当前最真实的跨楼阻断链仍然是：
  1. 公开登录尚未真正对公众开通
  2. 新 actor 登录后，`organizationId / roleKeys / certificationStatus` 还不能被视为“稳定公众前置”
  3. 企业认证 happy path 仍依赖手填 `licenseFileId`
  4. 企业认证审核没有在当前 `我的楼 -> 展览楼` 继续开发前形成正式运营闭环
  5. `消息楼` 当前对象不单一，`forum interaction inbox` 与 `/api/app/message/index` 并存
  6. `exhibition` 里多条私域继续面仍直接依赖 `我的楼` 的登录、组织、认证、角色和 shell handoff

## 3. 已真实成立

| 能力 | 页面 / route 面 | transport 面 | Server truth 面 | 当前判断 |
|---|---|---|---|---|
| 受控登录与会话走廊 | `profile` 下已有登录入口页 | `BFF` 已有 `/api/app/auth/otp/send|login|refresh|logout` | `Server` 已有 `/server/auth/otp/send|login|refresh|logout`，并建立 access/refresh session | **已真实成立，但只成立为受控登录，不等于公众开放登录** |
| 登录后壳层 bootstrap | Flutter 已有壳层 bootstrap 与 refresh | `BFF` 已有 `/api/app/shell/context` | `Server` 已有 `/server/shell/context`，并返回 `organizationId / roleKeys / certificationStatus / membershipStatus / visibleBuildings` | **已真实成立** |
| 我的楼 compact hub | `我的楼`、个人资料、我的公司、我的论坛、设置页面已存在 | `BFF` 已有 `/api/app/profile/index` 等只读 surface | `Server` 已有 `profile index` truth | **已真实成立** |
| 组织承接基础家族 | 组织创建 / 加入 / 切换 / 当前组织 / 成员管理页面与 sheet 已存在 | `BFF` 已有 `/api/app/profile/organization/*` | `Server` 已有 `create / join-by-code / switch / mine / members` | **已真实成立** |
| 个人资料基础更新 | 头像 / 昵称页存在 | `BFF` 已有 profile command family | `Server` 已有 `personal/avatar / nickname / intro` 与 safety submission truth | **已真实成立** |
| 设备安全最小面 | 会话与设备页面存在 | `BFF` 已有 `/api/app/profile/security/devices*` | `Server` 已有 `security/devices` 与 revoke | **已真实成立** |
| 治理状态与申诉记录 | 个人资料页治理记录、申诉列表 / 详情页已存在 | `BFF` 已有 `/api/app/profile/governance/status` 与 `/appeals*` | `Server` 已有对应 truth 与 read slice | **已真实成立** |
| 拉黑最小家族 | `profile` 侧有 block status / block / unblock 消费与展示位 | `BFF` 已有 `/api/app/profile/block*` | `Server` 已有 `block / unblock / block/status` | **已真实成立** |
| 我的项目 entry + list/detail | `我的楼 -> 我的项目` entry、`我的项目` list/detail 已存在 | `BFF` 已有 `/api/app/my/projects*` | `Server` 已有 `/server/my/projects*` 与 `publicProject + privateProgress` | **已真实成立** |
| 我的论坛资产入口 | `我的论坛` 及 `我的帖子 / 我的评论 / 我的收藏 / 我的关注 / 草稿箱` 已存在 | `BFF` 已有 forum read family | `Server` 已有 forum bounded truth families | **已真实成立** |
| bounded 会员 / 信用约束 / 支付账单只读族 | `我的楼` 首层已有 entry | `BFF` 已有 `/api/app/profile/membership/*`、`credit-and-constraints/*`、`payment-and-billing-status/*` | `Server` 已有对应 query truth | **已真实成立，但当前不是跨楼继续开发的首要前置** |

## 4. 形式存在但内核未成立

| 能力 | 形式存在证据 | 内核未成立点 | 当前判断 |
|---|---|---|---|
| 公开登录开通 | 登录页、OTP send/login/refresh/logout、自动建户、shell bootstrap 全都已存在 | `authPublicOtpSendEnabled` 仍是 runtime gate；`whitelist / dev OTP` 仍保留正式链路语义；不能据此判定为公众开放登录 | **形式存在但内核未成立** |
| “登录成功即自动建用户 = 公众注册闭环” | `auth-session.service.ts` 的 `findOrCreateUser(...)` 已存在 | 自动建户只说明 OTP 验证成功后可 materialize 用户，不等于公众入口已开放、风控已切换、产品已对公众可用 | **形式存在但内核未成立** |
| organization scope 对公众 actor 的稳定承接 | `create / join / switch / mine` 全部存在，登录后 `shellBootstrapState=no_organization` 也已存在 | 这条链在当前仍建立在受控登录前提上；不能把“已有组织 command family”直接判成“公众组织承接已稳定” | **形式存在但内核未成立** |
| 企业认证 happy path | `certification current / submit / resubmit` 页面、BFF、Server command 都存在 | Flutter 当前仍手填 `licenseFileId`；没有独立营业执照上传 `init -> direct upload -> confirm` 闭环；happy path 仍不成立 | **形式存在但内核未成立** |
| 企业认证闭环后的审核完成态 | `Server` 已有 organization review query/write truth | 当前 `apps/admin` 没有企业认证 / 企业入驻正式运营面；不能把 server-side review truth 当作运营闭环已成立 | **形式存在但内核未成立** |
| 消息楼作为独立消息域 | `MessagesPage`、`MessagesConsumerLayer`、`/api/app/message/index` consumer、`MessagesRouteTarget` 已存在 | repo 中未找到对应 `BFF / Server` `message/index` truth owner；同时 `MessagesPage` 实际消费的是 `forum interaction inbox` | **形式存在但内核未成立** |
| 展览楼深层私域继续面 | `bid / contract / inspection / rating / dispute / enterprise apply` 页面大量存在 | 这些继续面大量依赖 `我的楼` 登录、组织、认证、角色；部分 transport family 与当前 BFF 暴露面仍未完全对齐 | **形式存在但内核未成立** |

## 5. 当前前置缺口

| 缺口 | 当前缺的不是页面，而是 | 为什么是前置缺口 |
|---|---|---|
| 公开登录开通 | `Server` 侧白名单 / dev OTP 语义与公众 OTP send 语义切分 | 不补，所有后续“公众 actor 进入展览楼 / 消息楼”都只是测试链路 |
| organization scope 最小闭环 | 登录后 `organizationId / roleKeys / certificationStatus / membershipStatus` 的稳定公共承接 | 不补，`project create / bid submit / enterprise apply / forum command` 都会反复被 guard 卡死 |
| 企业认证上传 / 提交 / 重提闭环 | 认证专用文件上传三段式与 `licenseFileId` truth 自动化 | 不补，认证仍不是 happy path，只是手工 ID 表单 |
| 企业认证审核闭环 | 运营侧正式 review console 与最小操作闭环 | 不补，认证状态无法稳定进入 `approved / rejected` 的正式运营链 |
| 消息楼单一对象真源 | `forum interaction inbox` 与 `message/index` 的唯一 active mainline 裁决 | 不补，`messages` building 继续开发会一直建立在分裂对象上 |
| forum / exhibition transport inventory closure | mobile canonical paths 与当前 BFF 实际 controller family 对齐 | 不补，`exhibition / messages` 后续页面会继续踩 ghost route 或占位继续面 |

## 6. 未来战略位，当前不应上提

- `payment / billing / V2.3 私域操作系统整理`
- person-first 第二套 identity / certification truth
- 通用 IM / 会话中心 / conversation center
- `messages` 的完整消息平台化扩写
- `我的项目` 深层 CTA 矩阵与完整附件体系
- release-prep
- launch approval

这些都不是当前最先阻断 `展览楼 / 消息楼` 继续开发的根因，当前不应抬成第一前置。

## 7. profile ↔ exhibition dependency findings

### 7.1 当前依赖关系

- `exhibition` building 对游客可见，但不是所有动作都可继续：
  - `AppBootstrapController.guardBuilding(...)` 对 `AppBuilding.exhibition` 放宽了 unauthenticated 顶层入口
  - 这只代表“可浏览入口”，不代表“私域动作已可继续”
- `展览楼` 的私域继续动作明确依赖 `我的楼`：
  - `竞标提交` 明确依赖：
    - 已登录
    - `organizationId`
    - `certificationStatus=approved|verified`
    - supplier role
  - `企业入驻申请` 明确依赖：
    - 已登录
    - `organizationId`
    - `certificationStatus=approved|verified`
  - `项目工作台 / 项目创建 / 我的项目` 都依赖 `CurrentActorEligibilityService.getCurrentOrganizationScope(...)`
- `forum` 的 command header 也依赖 `profile/shell`：
  - BFF 会先读 `/server/shell/context`
  - 若还缺组织范围，再读 `/server/profile/organization/mine`
  - 然后补 `x-organization-id / x-actor-role`

### 7.2 结论

- `展览楼` 当前最大的真实阻塞不是页面数量，而是：
  - 登录
  - 组织范围
  - 认证状态
  - role-based shell handoff
- 只要这些前置还没闭环，`exhibition` 里很多“继续处理页”就只是 guarded continuation，不是稳定 runtime 能力。

## 8. profile ↔ messages dependency findings

### 8.1 当前真实现状

- 当前 `messages` building 不是单一对象：
  - 一条线是 `MessagesPage` 实际使用 `ForumConsumerLayer.loadInteractionInbox(...)`
  - 另一条线是 `MessagesConsumerLayer` 期望 `/api/app/message/index` 返回 `instance_todo`
- `messages` building 在 shell 中可见，但代码层没有找到与 `/api/app/message/index` 对应的 `BFF / Server` truth owner。

### 8.2 当前裁决

- `消息楼` 当前更像：
  - `论坛互动 inbox` 与
  - `instance_todo` 候选体系
  的并存状态
- 因此它当前**不是**已经成立的独立消息域。
- 在这条对象裁决完成前，不能继续把 `messages` building 当作一个稳定的业务主楼继续扩写。

## 9. P0 prerequisite list

1. `P0-1` 公开登录开通
当前 root blocker。必须先把 whitelist/dev OTP 与公众可用 OTP send 语义切开，形成真实受控公开登录。

2. `P0-2` organization scope 最小闭环
必须固定 `shell/context`、`organization/mine`、`create / join / switch` 与登录后的 first-time handoff。

3. `P0-3` 企业认证上传 / 提交 / 重提闭环
必须补齐营业执照文件上传三段式，消灭 hand-entered `licenseFileId`。

4. `P0-4` 企业认证审核最小运营闭环
必须让认证进入最小可运营 review 闭环，不能只停在 server-side write truth。

5. `P0-5` 消息楼单一对象真源裁决
必须先裁掉 `forum interaction inbox` 与 `message/index` 双主线。

## 10. P1 prerequisite list

1. forum app-facing route family closure
让 mobile forum consumer 期望面与 BFF 实际暴露面重新对齐。

2. exhibition 私域继续面 transport inventory closure
对齐 `bid / order / contract / milestone / inspection / rating / dispute` 的 mobile path、BFF controller、Server truth。

3. 我的楼功能本体 Round 1 consistency closure
只在 P0 prerequisites 处理后再进入，目标是收口 `entry owner / route owner / page owner / truth owner` 的漂移，而不是抢在前置没闭环时先做表层增量。

## 11. P2 deferred list

1. `payment / billing / V2.3` 相关扩写
2. 通用 IM / conversation center
3. `我的项目` 深层附件与更大 CTA 矩阵
4. person-first 第二套 identity / certification truth
5. 任何 release-prep / launch 相关动作

## 12. Structural Risks

1. **truth owner 漂移风险**
`profile` 已经同时承接 identity / organization / certification / governance / project entry / forum entry；如果不持续写死“entry owner 不等于 truth owner”，很容易把 `profile` 误做成第二工作台或第二后台。

2. **form/page 伪完成冒充内核完成**
登录页、认证页、消息页、展览继续页很多都存在，但存在并不等于 runtime 闭环成立。

3. **messages 对象分裂风险**
当前 `messages` building 的页面 owner 与 object truth owner 没锁死，是最明显的结构风险之一。

4. **public-vs-controlled login 语义混写风险**
当前代码里既有公众样式登录入口，也有 whitelist/dev OTP 语义；如果不单独修复，产品层会反复把“受控登录”误写成“公众开放登录”。

5. **guard 先于真闭环风险**
`bid submit`、`enterprise apply` 等 guard 已经写出正确依赖，但如果前置真闭环不补，guard 只会稳定把用户挡住，无法转化成真正可推进能力。

## 13. 阶段门禁核查表

### 13.1 passed gates

- `真源门禁`：当前诊断以 `docs/**` 为唯一 formal truth root
- `架构边界门禁`：`mobile -> BFF -> Server` 仍成立，`Admin` 仍是直连 `Server Admin API`
- `目录洁癖门禁`：本轮只允许 `docs/00_ssot/**` 落盘
- `阶段控制门禁`：当前只做诊断，不做 implementation dispatch

### 13.2 failed gates

- `前端体验门禁` 未过：
  - 认证 happy path 仍依赖手填 `licenseFileId`
  - 登录页已是公众入口文案，但后端公开开通语义未闭环
- `契约门禁` 未过：
  - `message/index` 在 mobile 存在，但未形成当前 active BFF / Server truth owner
  - `forum / exhibition` 的部分 mobile canonical path 仍超出当前 BFF 实际暴露面
- `阶段控制门禁` 未过：
  - 当前不能跳过 prerequisite bundle，直接进入 `我的楼` Round 1 增量施工或切回 `exhibition / messages` 主线

### 13.3 veto gates

- 公开登录仍未真正开通：**veto**
- organization scope 尚未形成稳定公众承接：**veto**
- 企业认证上传 / 提交 happy path 未闭环：**veto**
- 企业认证审核最小运营闭环未成立：**veto**
- `messages` 单一对象真源未裁决：**veto**

只要以上任一项未关，当前就：
- `No-Go for direct exhibition/messages continuation`
- `No-Go for my-building Round 1 incremental implementation dispatch`
- `No-Go for release-prep`

## 14. Stage Recommendation

- 当前阶段唯一建议：
  - **Go for P0 prerequisite bundle judgments**
  - **No-Go for 我的楼功能本体 Round 1 增量施工派工判断**
  - **No-Go for 继续直接扩写 exhibition / messages 表层页面**

## 15. Next Unique Action

- 当前唯一下一步动作锁定为：
  - `P0-1a《公开登录开通 backend repair dispatch judgment》`
- 原因：
  - 当前阻断链仍然从“公开登录没有真正开通”开始
  - `organization scope`
  - `certification`
  - `exhibition private continuation`
  - `messages single-object judgment`
  都建立在这条公众 actor 可进入的真实登录走廊之上

## 16. Formal Conclusion

- `我的楼` 当前不是“没做”，而是“已有不少真实能力，但跨楼继续开发真正依赖的前置闭环尚未全部成立”。
- 当前必须明确区分：
  - **已真实成立**
  - **形式存在但内核未成立**
  - **当前前置缺口**
  - **未来战略位**
- 当前阶段结束时，只能得到一个结论：
  - 先走 `P0 prerequisite bundle judgments`
  - 第一项唯一动作是 `P0-1a《公开登录开通 backend repair dispatch judgment》`
- 在此之前，不得自动进入：
  - `implementation`
  - `release-prep`
  - `launch`
  - `exhibition / messages` 继续扩写主线
