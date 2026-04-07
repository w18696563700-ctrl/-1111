---
owner: Codex 总控
status: frozen
purpose: Freeze the code-level prerequisite dependency audit for `我的楼`, elevating prerequisite repair over continued `exhibition` and `messages` expansion, and ordering the current repair mainline into `P0 / P1 / P2`.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_truth_closure_review_addendum.md
  - docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v23_private_operating_system_reorganization_bounded_implementation_review_conclusion_addendum.md
---

# 《我的楼代码前置依赖审计清单》

## 1. Scope

- 当前对象仅限：
  - `我的楼`
  - 代码层前置依赖审计
  - `展览楼 / 消息楼` 继续开发前的 prerequisite repair ordering
- 本文唯一作用：
  - 把“形式已存在但内核未闭环”的问题写成正式主线
  - 冻结当前真正的战略级修复顺序
  - 给后续 docs-only judgment / contracts / truth freeze 提供唯一优先级口径
- 本文不代表：
  - implementation unlock
  - 直接进入 `apps/**` 大规模改造
  - 直接放开交易主流程 runtime
  - 重写 `V2.0 / V2.1 / V2.2 / V2.3` 已冻结 package truth

## 2. Strategic Ruling

- 当前正式裁决如下：
  - `我的楼` 的当前战略级主线不再是继续扩写表层 entry，而是：
    - `代码前置依赖修复与优化主线`
- 当前主线的核心判断如下：
  - `展览楼` 与 `消息楼` 当前继续开发的主要阻断项，不在 `payment / billing`
  - 主要阻断项在：
    - 公开登录开通
    - organization scope 成立
    - 企业认证上传 / 提交 / 审核闭环
    - admin 最小运营闭环
    - messages 单一对象真源
    - forum / exhibition app-facing transport 缺口
- 当前再次写死：
  - `个人实名` 不等于 `企业认证`
  - `个人实名` 当前不是首轮 `展览楼 / 消息楼` 继续开发的强依赖前置
  - `V2.2 payment/billing` 与 `V2.3 私域操作系统整理` 继续保留各自 package truth，但不是当前跨楼继续开发的首要修复主线

## 3. Current Blocking Chain

- 当前代码层真实阻断链固定如下：
  1. 登录未对公众开通
  2. 登录后未必能稳定进入 `organizationId / roleKeys / certificationStatus` 私域上下文
  3. 企业认证 happy path 仍依赖手填 `licenseFileId`
  4. 企业认证即使可提交，也缺少最小 admin 审核运营台
  5. `消息楼` 当前对象不单一，论坛互动中心与 `message/index` 候选链并存
  6. `forum / exhibition` mobile canonical paths 与 BFF 实际暴露面不一致
- 因此当前必须写死：
  - 不得继续把 `展览楼 / 消息楼` 的表层页面开发，当作当前唯一优先级
  - 必须先修依赖内核，再继续扩楼

## 4. 阶段门禁核查表

### 4.1 Passed Gates

- `真源门禁`：
  - 当前审计仍以 `docs/**` 为唯一 formal truth authoring root
- `架构边界门禁`：
  - 当前 repo 仍保持 `mobile -> BFF -> Server`
  - `Admin` 仍是直连 `Server Admin API` 的独立面
- `基础私域走廊存在`：
  - `organization create / join / switch` 已存在最小代码走廊
  - `project create / list / detail` 已存在最小代码走廊

### 4.2 Failed Gates

- `前端体验门禁` 未过：
  - 企业认证 happy path 仍依赖手填 `licenseFileId`
  - demo / placeholder 仍进入真实继续面
- `契约门禁` 未过：
  - mobile 定义的 canonical path family 超出当前 BFF 实际暴露面
  - `message/index` 在 mobile 中存在，但在 BFF / Server 中未形成对应真值入口
- `阶段控制门禁` 未过：
  - 若继续在 `展览楼 / 消息楼` 侧推进表层页面，会绕开 prerequisite closure

### 4.3 Veto Gates

- 以下任一项未关闭前，直接阻断 `展览楼 / 消息楼` 的进一步继续开发：
  - 公开登录仍被白名单机制锁死
  - 企业认证上传闭环未成立
  - 企业认证审核无法通过最小 admin 运营台闭环
  - `消息楼` 仍然同时保留两条相互竞争的对象主线
  - 继续把 hand-entered ID 当作 happy path
- 以下 veto 当前继续保留：
  - `No-Go for direct trading-flow runtime expansion`
  - `No-Go for using payment/billing or V2.3 to replace the current prerequisite-repair mainline`

### 4.4 Stage Decision

- 当前阶段唯一允许结论：
  - `Go for docs-only prerequisite-repair mainline`
  - `No-Go for direct exhibition/messages continuation beyond prerequisite repair`
  - `No-Go for direct trade-flow runtime implementation`

## 5. P0 Checklist

### P0-1 公开注册 / 登录受控开通

- 当前问题：
  - 登录 technically 存在，但 OTP send 被白名单拦截，公众不可用
- 当前代码证据：
  - [auth-otp.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-otp.service.ts)
  - [auth-session.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-session.service.ts)
- 当前目标：
  - 冻结并修复 `非白名单受控登录开通`
  - 让 `登录成功即最小建户` 不再依赖 debug whitelist
  - 保留风控、频控、受控灰度，不放任意开放
- 完成判定：
  - 非白名单手机号可以进入受控 OTP 登录链
  - 登录后用户能稳定进入壳层 bootstrap
  - 公开登录不再依赖测试口径伪装成正式入口

### P0-2 organization scope 最小闭环

- 当前问题：
  - `展览楼` 多个私域动作依赖 `organizationId / roleKeys / certificationStatus`
  - 若当前壳层只停留在“已登录但无组织”，后续私域继续动作全部被 guard 拦住
- 当前代码证据：
  - [profile_identity_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/data/profile_identity_consumer_layer.dart)
  - [bid_submit_guard_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart)
  - [enterprise_hub_apply_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_apply_pages.dart)
- 当前目标：
  - 固定 `create / join / switch / mine / shell context` 的一致性
  - 固定壳层最小必需字段：
    - `organizationId`
    - `roleKeys`
    - `membershipStatus`
    - `certificationStatus`
- 完成判定：
  - 新登录用户可进入有效组织承接路径
  - 切组织后壳层上下文同步稳定
  - 私域 guard 不再被“上下文未建立”反复卡死

### P0-3 企业认证上传 / 提交 / 重提闭环

- 当前问题：
  - mobile 认证页要求手填 `licenseFileId`
  - upload truth 当前只支持 `project/evidence`
  - Server submit / resubmit 明确要求已确认的 license file truth
- 当前代码证据：
  - [profile_identity_access_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart)
  - [upload-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload-write.service.ts)
  - [profile-certification-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts)
- 当前目标：
  - 为企业认证补齐独立三段上传闭环
  - 消灭 hand-entered `licenseFileId`
  - 让 `submit / resubmit / current status` 形成真实 happy path
- 完成判定：
  - 用户可在 app 内完成营业执照上传并得到正式 `FileAsset`
  - 认证提交流程不再要求手输内部 ID
  - `current certification` 可稳定承接已提交、驳回、过期、重提状态

### P0-4 Admin 最小审核运营闭环

- 当前问题：
  - Server Admin API 已有，但 `apps/admin` 仍是 skeleton
  - 企业认证与企业入驻审核缺少正式运营面
- 当前代码证据：
  - [README.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/README.md)
  - [organization-review.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review.controller.ts)
  - [enterprise-hub-admin.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts)
- 当前目标：
  - 交付最小 admin review console
  - 先承接：
    - 企业认证审核
    - 企业入驻申请审核
    - 企业发布 / 下线 / 冻结最小动作
- 完成判定：
  - 运营不再依赖裸 API 执行核心审核
  - 企业认证与企业入驻可以形成最小可运营闭环

### P0-5 `消息楼` 单一对象真源裁决

- 当前问题：
  - 当前可见 `消息楼` 页面仍是论坛互动中心
  - 但 mobile 同时定义了 `/api/app/message/index` 及 route-target 体系
  - BFF / Server 未形成对应后端入口
- 当前代码证据：
  - [messages_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/messages/presentation/messages_page.dart)
  - [messages_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/messages/data/messages_consumer_layer.dart)
  - [forum_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/forum_consumer_layer.dart)
- 当前目标：
  - 先裁决 `消息楼` 当前首发对象到底是什么
  - 只允许保留一条 active mainline：
    - 要么 `论坛互动中心`
    - 要么 `instance_todo / message index`
- 完成判定：
  - mobile / BFF / Server 只保留一条活跃消息主线
  - 不再存在 orphan canonical path
  - 后续消息楼开发不再建立在分裂对象上

## 6. P1 Checklist

### P1-1 Forum app-facing route family closure

- 当前问题：
  - mobile forum consumer 期望的 route family 远大于当前 BFF 实际暴露面
- 当前代码证据：
  - [forum_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/forum_consumer_layer.dart)
  - [app-forum.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/forum/app-forum.controller.ts)
- 当前目标：
  - 清掉 forum 的 ghost route family
  - 让 mobile 期望面与 BFF 实际面重新对齐
- 完成判定：
  - forum canonical paths 不再“定义很多、接通很少”
  - forum 与消息互动链的打开动作不再踩空

### P1-2 Exhibition 私域继续面 transport inventory closure

- 当前问题：
  - mobile 已定义 `bid / order / contract / milestone / inspection / rating / dispute`
  - BFF 当前没有对应 app-facing controller family
  - workbench / trade pages 仍充满 placeholder 与 demo fallback
- 当前代码证据：
  - [exhibition_canonical_paths.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart)
  - [app-exhibition-home.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/exhibition_home/app-exhibition-home.controller.ts)
  - [app-exhibition-workbench.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts)
  - [exhibition-workbench.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts)
  - [contract_confirm_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_confirm_page.dart)
  - [bid_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart)
- 当前目标：
  - 对展览私域继续面逐项标记：
    - 已接通
    - 待补 transport
    - docs-only freeze
    - Phase 0 明确禁止 runtime
- 完成判定：
  - `exhibition` 不再混用真入口、placeholder、demo、战略预留
  - 后续每个继续面都有唯一状态口径

### P1-3 Demo / placeholder fail-closed policy

- 当前问题：
  - demo fallback 正在侵入真实继续面
  - placeholder 可能被用户误读为“内核已成立”
- 当前目标：
  - 写死 demo 只可存在于明确受控演示面
  - 真实继续面缺依赖时必须 fail-closed
- 完成判定：
  - 不再出现“看起来能继续，实则仍是 demo” 的伪承接

## 7. P2 Checklist

### P2-1 个人实名 package judgment

- 当前判断：
  - `个人实名` 当前不是首轮跨楼继续开发的强依赖前置
  - 不得把它和企业认证混写
- 当前目标：
  - 保留为后续 package judgment 候选
  - 不抢占当前 P0 主线资源

### P2-2 `payment / billing` 与 `V2.3` 不上提为当前修复主线

- 当前判断：
  - `V2.2 payment/billing`
  - `V2.3 私域操作系统整理`
  - 均不是当前 `展览楼 / 消息楼` prerequisite repair 的首要阻断项
- 当前目标：
  - 维持既有 package truth
  - 不允许拿它们替代当前 P0 prerequisite closure

### P2-3 交易主流程 runtime 继续保持战略保留

- 当前判断：
  - `order / contract / inspection / rating / dispute` 的完整 runtime 开放，仍受 Phase 0 guardrail 限制
- 当前目标：
  - 当前只允许做 truth closure、transport inventory、guarded placeholder rectification
  - 不允许把它们偷写成“现在就开工的主线”

## 8. Explicit No-Go

- 当前明确 `No-Go`：
  - 把白名单 OTP 当作“已开通注册登录”
  - 把手填 `licenseFileId` 当作正式 happy path
  - 把 raw admin API 操作当作长期运营方式
  - 在 `消息楼` 主对象未裁决前继续叠加功能
  - 在 forum / exhibition transport 未对齐前继续堆叠前端页面
  - 在无额外正式解锁前直接推进交易主流程 runtime

## 9. Formal Conclusion

- 当前正式结论如下：
  - `我的楼代码前置依赖修复` 已被提升为当前战略级主线
  - 当前最先要修的不是更多页面，而是：
    - `登录`
    - `organization scope`
    - `企业认证闭环`
    - `admin 最小审核闭环`
    - `消息楼单一对象真源`
  - `forum / exhibition transport` 缺口修复属于紧随其后的 `P1`
  - `个人实名`、`payment/billing`、`V2.3`、完整交易主流程 runtime 当前均不应抢占这条主线

## 10. 下一步唯一动作

- 当前从总控角度唯一允许的下一步是：
  - 进入 `P0 prerequisite bundle judgments`
- 当前唯一正确顺序固定为：
  1. `公开登录开通 judgment`
  2. `organization scope closure judgment`
  3. `企业认证上传与审核闭环 judgment`
  4. `消息楼对象裁决 judgment`
- 在上述 `P0` judgment 未形成前：
  - 不再继续派发新的 `展览楼 / 消息楼` 扩展开发口令
