# app infrastructure upgrade scan receipt

- 扫描类型：基于当前代码与当前真源的“平台级基础设施升级扫描”（非推倒重来）
- 扫描范围：Flutter（`profile/exhibition/messages/core/auth + route/guard/bootstrap`）、BFF（`auth/profile/project/my_project/forum/exhibition_home/exhibition_workbench/file`）、Server（`auth/profile/organization/project/my_project/exhibition_workbench/forum/review/enterprise_hub/membership/payment_billing/credit_constraints/governance/audit/runtime-config`）、Admin（运营台现状）
- 交叉依据：`AGENTS.md`、`docs/00_ssot/source_of_truth_map.md`、`docs/00_ssot/gate_register_v1.md`、`docs/04_frontend/flutter_screen_map.md`、`my_building/package1/my_project`相关 judgment/audit/checklist 文书与当前实现
- 结论口径：每个能力点仅使用以下六类之一：`已真实成立` / `部分成立` / `形式存在但内核未成立` / `当前缺口` / `战略保留` / `对其他楼层的前置阻塞项`

## 10 大基础设施能力逐项状态

### 1) 身份与登录基础设施
- 公开登录（OTP 登录主链）：`已真实成立`
- OTP 发送与校验：`已真实成立`
- Session 校验与 bearer carrier：`已真实成立`
- Refresh：`已真实成立`
- Bootstrap（无组织/有组织分流）：`已真实成立`
- 公众登录恢复路径（未登录可浏览 + 登录后恢复）：`部分成立`
- 白名单/开发态残留（dev OTP / login whitelist 开关）：`当前缺口`

### 2) 组织与认证基础设施
- organization create/join/switch：`已真实成立`
- 企业认证提交/重提：`已真实成立`
- 个人实名：`当前缺口`
- 认证上传闭环（init-upload-confirm 到认证表单）：`部分成立`
- 认证审核闭环（admin review 通过/驳回）：`已真实成立`
- 组织 scope 对业务影响（project/my_project/enterprise_hub）：`已真实成立`

### 3) 我的楼私域承接基础设施
- 我的楼 compact hub 主入口与索引聚合：`已真实成立`
- hub 内多域承接（identity/security/membership/payment/credit/governance/my_project）：`部分成立`
- 形式存在但内核未成立项（部分入口依赖未闭合 transport）：`形式存在但内核未成立`
- 作为展览楼前置依赖（组织/认证/scope）：`已真实成立`
- 作为消息楼前置依赖（身份/scope + route 语义）：`部分成立`
- 首屏负载控制：`当前缺口`
- 入口 owner / truth owner 清晰度：`部分成立`

### 4) 我的项目私域项目基础设施
- 入口（`/api/app/my/projects`）：`已真实成立`
- 列表（ongoing/historical 分区）：`已真实成立`
- 详情双区（publicProject + privateProgress）：`已真实成立`
- 状态语言（formalCompletion/evaluation）：`已真实成立`
- 与工作台关系：`部分成立`
- 对展览楼继续开发承接：`对其他楼层的前置阻塞项`

### 5) 展览楼交易主链基础设施
- 项目发布：`已真实成立`
- 项目展示：`已真实成立`
- 竞标：`对其他楼层的前置阻塞项`
- 选标：`对其他楼层的前置阻塞项`
- 合同：`对其他楼层的前置阻塞项`
- 履约（里程碑/巡检）：`对其他楼层的前置阻塞项`
- 验收：`当前缺口`
- 评价：`对其他楼层的前置阻塞项`
- 争议/售后：`对其他楼层的前置阻塞项`
- 备注：移动端存在 canonicalPath 与页面壳，但 BFF/Server 未形成对应 app-facing transport（属于“transport 缺失 + placeholder/demo”）。

### 6) 消息楼对象与 transport 基础设施
- 独立消息域：`当前缺口`
- 当前是否论坛互动 inbox：`已真实成立`
- `message/index` 真实存在性：`当前缺口`
- `routeTarget/canonicalPath` 机制可用性：`形式存在但内核未成立`
- 与展览楼/我的楼对齐：`对其他楼层的前置阻塞项`

### 7) Admin 运营与治理基础设施
- Admin 是否真实运营台：`部分成立`
- 企业认证审核：`部分成立`
- 企业入驻审核（enterprise hub）：`部分成立`
- 项目治理：`当前缺口`
- 内容治理（处罚/申诉）：`部分成立`
- 风险事件查看：`部分成立`
- 审计可见性：`形式存在但内核未成立`
- 能否支撑平台运营：`对其他楼层的前置阻塞项`

### 8) 平台商业引擎基础设施
- membership.*（entitlement/quota 语义 + 实体）：`部分成立`
- payment.*（status/reference/handoff 语义）：`部分成立`
- 会员/支付/账单/保证金/发票真实承接层：`当前缺口`
- 未来 package 方向：`战略保留`
- 对我的楼结构反向影响：`对其他楼层的前置阻塞项`

### 9) 全国平台能力基础设施
- 省市区标准化字段（组织/项目/企业）：`部分成立`
- 服务范围/半径/跨城表达：`部分成立`
- 主体模型全国化适配：`部分成立`
- 搜索/筛选/分类预埋：`部分成立`
- 仍偏地方黄页式的能力缺口：`当前缺口`

### 10) 架构长期演化基础设施
- 应留在我的楼的能力边界：`部分成立`
- 仅在我的楼有入口但 truth 不在 profile 的约束：`部分成立`
- truth owner 防 profile 吞并：`部分成立`
- 未来 package 首屏拖爆风险：`对其他楼层的前置阻塞项`
- 必须二级页/懒加载的能力：`对其他楼层的前置阻塞项`
- 最易发生的架构回退点：`对其他楼层的前置阻塞项`

# current real capabilities

- OTP 登录/刷新/登出、session 校验、current-session verification、anti-abuse 与 auth 审计落库。
- organization create/join/switch 全链路可用，且组织 scope 已真实约束 project/my_project/enterprise_hub。
- 企业认证 submit/resubmit + 审核通过/驳回（server admin reviews organizations）已闭合。
- 项目发布与项目展示（`/api/app/project/list|create|detail`）已可运行。
- 我的项目（`/api/app/my/projects`）列表/详情与 private progress 推导可运行。
- 论坛 feed/topic/draft/publish/report/mine 路由与服务可运行。
- enterprise_hub truth 写入 + 查询 + admin 审核/发布/下线/冻结能力可运行。
- membership / payment_billing / credit_constraints 已有独立服务端模块与 profile 读取接口（读模型层）。

# partial capabilities

- 公众未登录浏览与登录恢复语义存在，但跨楼层恢复与路径一致性仍不完全。
- 认证上传闭环后端存在，前端认证入口仍以 `licenseFileId` 手填为主，未完全产品化。
- 我的楼作为跨楼层 hub 已成立，但部分条目依赖的后端 transport 未闭合。
- Admin 有治理处罚/申诉 UI + 对应 server admin API，但登录与部分模块仍占位态。
- 全国化能力已有省市区字段与企业服务区域实体，但跨城/半径表达仍偏弱。

# pseudo-complete capabilities

- 消息楼 `routeTarget/canonicalPath` 在客户端有严格校验与注册表，但 `message/index` 后端 transport 缺失，属于“形式存在但内核未成立”。
- 展览交易链大量页面与 canonicalPath 已存在，但 BFF/Server 对应交易路由（bid/order/contract/milestone/inspection/rating/dispute）未成链，属于伪完成外观。
- Admin 的审计台、工单台、模板配置台当前为 module shell 占位，不可视为运营内核。
- Admin 登录页明确“凭据来源待确认”，`mock-login` 固定拒绝，不能视为已运营登录链路。
- BFF `profile/governance/appeals` 读取接口存在，但 server 侧无 `server/profile/governance/appeals` 对应 controller，属于对接伪闭环。

# missing prerequisite capabilities

- 独立消息域最小真相：`/api/app/message/index`（BFF + Server + 数据来源）缺失。
- 展览交易主链 app-facing transport（竞标/选标/合同/履约/验收/评价/争议）缺失。
- 验收独立真相承载缺失（`my_project` 代码已显式注释“无 dedicated acceptance truth carrier”）。
- Admin 内容安全审核任务接口（admin client 调用的 `content-safety/review-tasks` 等）缺失。
- 个人实名/自然人认证基础设施缺失。
- 认证上传在移动端的可用闭环缺失（仍高度依赖手动 fileId）。

# profile ↔ exhibition dependency findings

- exhibition 的“可持续开发前提”是 profile 侧组织/scope/认证，当前这部分已基本成立。
- 但 exhibition 交易主链核心 transport 缺失，导致 profile 中“我的项目 private progress”虽有读取逻辑，仍无法稳定反哺完整交易生命周期。
- profile 作为 hub 暴露了交易相关入口与状态语言；若先继续扩展展览页面而不补 transport，会扩大“页面先行、真相滞后”的架构债务。

# profile ↔ messages dependency findings

- profile 与 messages 在身份/scope 上共享同一 auth/session 基座，这部分成立。
- 当前 messages 实际承载的是 forum interaction inbox（通过 forum 报告/互动数据），不是独立 message 域。
- messages 客户端 routeTarget 注册已冻结，但缺少 `message/index` 真正供给，导致 profile ↔ messages 的跨楼层动作可达性存在断层。

# admin / governance findings

- server 侧治理能力存在：`/server/admin/governance/penalties`、`/server/admin/governance/appeals`、`/server/admin/governance/rescan-jobs`。
- server 侧组织认证审核能力存在：`/server/admin/reviews/organizations`。
- enterprise_hub admin 审核与上下线能力存在：`/server/admin/exhibition/enterprise-hub/*`。
- admin 前台治理处罚/申诉页面可调用真实 server admin 接口。
- admin 登录不是可运营链路（仅 cookie guard + 占位登录页）。
- admin 审计/工单/模板配置为占位壳，不满足“可运营台”标准。
- admin client 依赖的 content-safety 审核任务接口在 server 未发现对应 controller，存在关键断链。

# commercial engine findings

- `membership`：有实体（付费周期/配额快照）、目录规则、query service、profile 暴露，属于“已落地的读模型引擎”。
- `payment_billing`：有支付状态/账单引用/handoff 三实体与 query service，属于“状态与承接语义层”。
- `credit_constraints`：有信用约束/保证金/交易担保姿态实体与 query service，属于“约束语义层”。
- 当前未见真实支付/账单/发票/保证金交易执行链路，仍是“读层 + handoff”而非商业结算内核。
- 对我的楼的结构影响已出现：商业相关卡片过多，首屏耦合风险上升。

# national-platform findings

- 组织、项目、企业均包含省市区编码与名称字段，具备基础地理标准化基底。
- enterprise_hub 支持按省市过滤与服务区域实体，但“服务半径/跨城能力”主要以文本表达，结构化不足。
- 平台主体模型（demand/supplier/platform + org member role）可支撑全国扩展，但搜索筛选维度仍偏浅。
- 当前更接近“结构化黄页 + 私域承接”，距离全国级交易基础设施仍缺关键交易 transport 与治理联动。

# architecture evolution risks

- 风险 1：profile 首屏继续承载新增 package 摘要，导致 hub 失控膨胀。
- 风险 2：将“有页面/有canonicalPath”误判为“可依赖内核”，引发跨楼层错误依赖。
- 风险 3：messages 在无独立 message truth 的前提下继续扩面，形成二次返工。
- 风险 4：admin 登录与内容审核链不闭环，运营动作无法稳定执行。
- 风险 5：dev whitelist/测试态开关治理不足，易造成生产安全策略漂移。

# P0 prerequisite list

- P0-1：补齐 `message/index` 最小闭环（Server truth + BFF app-facing + 与 routeTarget frozen registry 对齐）。
- P0-2：补齐展览交易主链最小 transport 闭环（至少从 `order/contract/milestone/inspection/rating/dispute` 建立可调用最小读写面）。
- P0-3：补齐 Admin 内容安全审核任务接口闭环（与现有 review 页面调用契约一致）。
- P0-4：修复 BFF `profile/governance/appeals` 与 server 路由不对齐问题（避免前端假可用）。

# P1 prerequisite list

- P1-1：认证上传移动端产品化闭环（去除手填 `licenseFileId` 的主路径依赖）。
- P1-2：个人实名能力是否纳入 Package 1 的明确结论与真相落点。
- P1-3：Admin 真实登录与管理员会话载体统一（替换占位登录态）。
- P1-4：我的楼首屏拆载与懒加载策略（商业/治理/项目摘要下沉二级页）。

# P2 deferred list

- P2-1：全国化高级检索/分类/跨城履约能力深化。
- P2-2：商业引擎从“读层 + handoff”向“交易执行层”演进（支付/账单/发票/保证金）。
- P2-3：治理重扫任务与风险事件的可视化运营编排完善。

# top 10 infrastructure upgrade points

1. `message/index` 独立消息域最小闭环。
2. 展览交易主链 app-facing transport 最小闭环。
3. 验收真相载体补齐（消除 acceptance 空洞）。
4. Admin 内容安全审核任务接口补齐。
5. BFF ↔ Server 治理申诉路由契约对齐。
6. 认证上传移动端闭环产品化（fileAsset 真相直达）。
7. Admin 真实登录与权限承载闭环。
8. 我的楼首屏分层与懒加载（防 hub 膨胀）。
9. dev whitelist/测试态运行时开关治理加固。
10. 全国化结构化能力增强（服务半径/跨城可履约表达）。

# passed gates

- Gate-P1：`Flutter App -> BFF -> Server` 单向调用边界成立。
- Gate-P2：Server 仍是组织/项目/论坛/治理等业务 truth owner。
- Gate-P3：文件三段式上传能力在平台层存在（init/upload/confirm），并用于头像等主路径。
- Gate-P4：认证与会话校验、审计事件写入链路成立。
- Gate-P5：我的项目私域承接（list/detail + private progress）已形成可用基座。

# failed gates

- Gate-F1：消息楼独立 transport gate 失败（`message/index` 缺失）。
- Gate-F2：展览交易主链 transport gate 失败（bid/order/contract/milestone/inspection/rating/dispute 缺失）。
- Gate-F3：Admin 内容审核链路 gate 失败（UI 调用存在但 server endpoint 缺失）。
- Gate-F4：profile-governance-appeals BFF↔Server 对齐 gate 失败。
- Gate-F5：认证上传前端闭环 gate 未完成（手填 fileId 主路径）。

# veto gates

- Veto-1：在 `message/index` 未闭环前，不允许将消息楼宣称为独立消息域并继续扩面。
- Veto-2：在交易主链 transport 未闭环前，不允许把展览交易页面作为后续开发内核依赖。
- Veto-3：在 Admin 登录与内容审核接口未闭环前，不允许将 Admin 判定为可支撑平台运营。

# stage recommendation

- 当前阶段结论：`扫描完成，但升级前置未通过`。
- 阶段建议：保持在“基础设施升级前置判定阶段”，不进入 implementation / release-prep / launch。

# next unique action

- 唯一下一步动作：进入 **`P0 prerequisite bundle judgments`**（仅做前置包判定，不施工），并以 `message/index`、交易主链 transport、Admin 内容审核接口三项为同一判定包核心。

# written file path

- `docs/00_ssot/app_infrastructure_upgrade_scan_addendum.md`
