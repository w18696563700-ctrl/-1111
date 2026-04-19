---
owner: Codex 总控
status: frozen
purpose: Freeze the current full-function register for the exhibition app across platform core, five buildings, and Admin, using current cloud active runtime first, then local hanging entries, then frozen future-package truth.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/feature_status_register_v1_template.md
  - docs/00_ssot/cloud_active_runtime_truth_reconciliation_receipt_v1.md
  - docs/00_ssot/content_safety_capability_tracking_table_v1.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md
  - docs/00_ssot/exhibition_home_public_board_closure_conclusion_addendum.md
  - docs/00_ssot/exhibition_home_weather_warning_v1_closure_conclusion_addendum.md
  - docs/00_ssot/enterprise_hub_v1_implementation_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
  - docs/00_ssot/forum_implementation_unlock_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_result_verification_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v23_private_operating_system_reorganization_bounded_implementation_review_conclusion_addendum.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - apps/mobile/lib/shell/navigation/app_building.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/profile/navigation/profile_routes.dart
  - apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart
  - cloud probe receipts on 47.108.180.198 at 2026-04-09
---

# 《展览 app 全功能总表 V1》

## 0. 判定口径

- 本表当前状态只允许使用：
  - `已完成`
  - `受控可用`
  - `占位已挂出`
  - `冻结待实现`
  - `阻断中`
  - `明确延期`
- 当前状态的判定顺序固定为：
  - 先看云上 `:80` active runtime
  - 再看本地 `mobile/admin` 已挂出的真实入口与页面
  - 最后看已冻结的 future package 文书
- 旧文书里已经 `PASS / closure / bounded implementation pass` 的对象，如果当前 active runtime 已漂移或未 materialize，不得直接写成 `已完成`，只能写入 `当前已完成` 一栏并将当前状态降为：
  - `受控可用`
  - `占位已挂出`
  - `阻断中`

## A. 全功能总表

### A1. 平台底座

| 功能编号 | 楼栋/域 | 功能簇 | 功能项 | 当前状态 | 当前已完成 | 当前未完成 | 入口是否挂出 | 页面/路由 | 真相 owner | 当前依赖 | 下一开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CORE-001 | 平台底座 | 账号体系 | 登录注册 | 阻断中 | `mobile` 登录页、`BFF/Server` auth route family、session carrier 已存在；`POST /api/app/auth/otp/login` 已到真实错误语义 | `POST /api/app/auth/otp/send` 当前 `503`；注册闭环未独立成立；refresh/logout 还缺真实会话 smoke | 是 | `/profile/login`；`/api/app/auth/otp/*` | Server/Auth | 会话、短信、风控 | OTP 发送资源恢复且 `80` 链登录 smoke 通过 |
| CORE-002 | 平台底座 | 账号体系 | 组织/公司切换 | 受控可用 | 组织 handoff/create/join/switch/mine 页面和 route family 已存在；云上 create/join/switch/mine 已到 auth guard | 真实已登录组织切换 smoke、成员全量治理、组织资料编辑仍未完整收口 | 是 | `/profile/organization*`；`/api/app/profile/organization/create|join-by-code|switch|mine` | Server/Organization | 组织真源、当前会话 | 真实组织上下文 smoke 与成员链收口 |
| CORE-003 | 平台底座 | 身份权限 | 角色与权限 | 阻断中 | DB-backed role truth、`profile/index.roleKeys`、Admin guard 基线已存在 | `organization member role/disable` 在 current `:80` 未 materialize；ACL 一致性仍未闭环 | 否/部分 | `我的公司成员面板`；`/api/app/profile/organization/members*` | Server | membership、ACL、Admin guard | member role/disable current runtime 对齐 |
| CORE-004 | 平台底座 | 认证体系 | 企业认证 | 受控可用 | `current/submit/resubmit` route family、移动端认证页、Admin Review P0 基座已存在 | 当前 `我的楼 Round 1` 仍有 `certificationStatus` 语义漂移；真实认证会话 smoke 未重签 | 是 | `/profile/certification/*`；`/api/app/profile/certification/*` | Server/Profile | 审核台、组织上下文 | Round 1 认证语义修正并复签通过 |
| CORE-005 | 平台底座 | 上传体系 | 文件上传/图片上传 | 受控可用 | `upload init -> confirm` 已在 active runtime 返回真实校验错误；direct-upload flag 默认开启 | 各业务对象的上传接入未全量复核；云上对象存储与业务确认链还未逐包复签 | 是 | 多处复用；`/api/app/file/upload/init|confirm` | Server/Upload | MinIO/OSS、FileAsset/Evidence | 各业务包上传 smoke 与归档验证通过 |
| CORE-006 | 平台底座 | 搜索筛选 | 全局搜索与筛选 | 占位已挂出 | 企业列表和论坛局部筛选已出现；部分页面有筛选 UI | 没有统一全局搜索入口、没有统一索引 owner、没有跨楼统一筛选 contract | 是/部分 | 展览企业列表、论坛局部搜索 | BFF/Server | 索引、过滤条件、搜索主线 | 全局搜索主线正式打开 |
| CORE-007 | 平台底座 | 消息通知 | 系统通知 | 占位已挂出 | `messages` building 已挂出；消息域 contract 已登记 | `message/index` 当前 `404`；系统通知没有真实 active path；不是完整消息域 | 是 | `/messages`；`/api/app/message/index` | Server | 通知渠道、消息主线 | 阶段 4 `message/index` materialize |
| CORE-008 | 平台底座 | 内容安全 | 内容安全治理 | 受控可用 | forum report、block relation、Admin Review P0、penalty、appeal、my report、my appeal、violation score、rescan、AI gateway 已有完成证据 | whitelist/permanent-ban、message safety、interaction blocking P0-B、Admin real login、统一治理闭环未完成 | 否/部分 | `review`、`governance`、`/profile/governance/*`、forum report path family | Server/Admin | 审核、举报、拉黑、审计 | Admin 登录闭环与 whitelist/ban 主线打开 |
| CORE-009 | 平台底座 | 支付账单 | 支付/账单状态边界包 | 受控可用 | `status / explanation / handoff / dependency` bounded package 已有实现与 route family | 真支付、回调、清结算、发票、财务后台未进入当前范围 | 是 | `我的楼账单状态页`；`/api/app/profile/payment-and-billing-status/*` | Server | 财务依赖、支付主线 | 支付 MVP 主线解锁 |
| CORE-010 | 平台底座 | 支付账单 | 真实支付系统 MVP | 冻结待实现 | 支付状态边界包可复用 | 下单、支付、回调、结算、发票、财务后台都未开放 | 否 | 后续新增 | Server/Finance | Provider、清结算、税务 | 支付主线正式打开 |
| CORE-011 | 平台底座 | 审计留痕 | 审计日志 | 受控可用 | Safety Audit P0、identity/project publish audit 底座已存在；Admin `/audit` 页面已挂出 | 完整审计检索、过滤、导出工作台未闭环；当前 Admin login 仍阻断 | 否/部分 | `/audit`；Server audit slices | Server | 安全治理、审计主线 | Admin 审计台和 append-only 检索闭环成立 |
| CORE-012 | 平台底座 | 数据分析 | 埋点/报表/运营统计 | 冻结待实现 | 页面与后续看板可预留 | 埋点体系、报表、运营看板、统计链未开启 | 否 | 后台预留 | BFF/Admin | 数据主线 | 数据主线解锁 |
| CORE-013 | 平台底座 | 平台预埋 | Live/Geo/Map 预埋底座 | 已完成 | 五栋壳、flag-off baseline、`platform.live/geo/map` 预埋与默认关闭规则已正式存在 | 业务化 live/map/geo 能力按设计不在当前轮次打开 | 否 | flag only | Frontend/BFF | Phase 0 pre-embed baseline | 后续仅在专门主线中解锁业务能力 |
| CORE-014 | 平台底座 | AI 底座 | AI 审核服务统一接入层 | 已完成 | `ai_review_gateway_requests/results`、provider normalization、trace linkage、no-public-route boundary 已完成 | 不开放 `/api/app/*` AI 路由、不开放 AI 管理台是当前设计内非目标 | 否 | Server internal only | Server | provider adapter、内容安全 | 仅在未来 AI 控制台主线重开 |

### A2. 展览楼

| 功能编号 | 楼栋/域 | 功能簇 | 功能项 | 当前状态 | 当前已完成 | 当前未完成 | 入口是否挂出 | 页面/路由 | 真相 owner | 当前依赖 | 下一开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EXH-001 | 展览楼 | 首页聚合 | 展览首页聚合 | 阻断中 | 首页页面、历史公域板块封板文书、历史天气 V1 文书已存在 | 当前 active `GET /api/app/exhibition/home` 为 `404`；`refresh/location/select` 也未在 current artifact 命中 | 是 | `/exhibition`；`/api/app/exhibition/home*` | BFF/Server | 内容源、推荐、home current artifact | `home*` route family 在 current `:80` 恢复 |
| EXH-002 | 展览楼 | 企业展示 | 优秀公司 | 受控可用 | company list/recommendations route family 已存在；列表页和筛选 UI 已挂出 | 当前多为空状态；真实实体链未闭环；首页卡片依赖 home API 恢复 | 是 | `/exhibition/companies`；`/api/app/exhibition/enterprise-hub/recommendations|enterprises?boardType=company` | Server/Enterprise | enterprise_hub truth、真实实体数据 | real entity chain 复核通过 |
| EXH-003 | 展览楼 | 企业展示 | 优秀工厂 | 受控可用 | factory list/recommendations route family 已存在；列表页已挂出 | 当前多为空状态；真实实体链未闭环；首页卡片依赖 home API 恢复 | 是 | `/exhibition/factories`；`/api/app/exhibition/enterprise-hub/*factory*` | Server/Enterprise | enterprise_hub truth、真实实体数据 | real entity chain 复核通过 |
| EXH-004 | 展览楼 | 企业展示 | 优秀供应商 | 受控可用 | supplier list/recommendations route family 已存在；列表页已挂出 | 当前多为空状态；真实实体链未闭环；首页卡片依赖 home API 恢复 | 是 | `/exhibition/suppliers`；`/api/app/exhibition/enterprise-hub/*supplier*` | Server/Enterprise | enterprise_hub truth、真实实体数据 | real entity chain 复核通过 |
| EXH-005 | 展览楼 | 企业展示 | 企业详情页 | 阻断中 | company/factory/supplier detail 页面、detail path family 已存在；not-found 语义已有证据 | 当前未证明真实公域实体从列表跳到详情；real entity detail chain 未闭环 | 是 | `/exhibition/*/detail`；`/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}` | Server | 实体真源、展示素材 | 列表 -> 真实实体 -> 真实详情 smoke 通过 |
| EXH-006A | 展览楼 | 企业展示 | 企业展示工作台 | 阻断中 | `workbench` read path、工作台页、readiness/blocker read model 已存在；现网工厂画像 `factoryName/processTypes/coreProducts` 保存链可达 `200` 并可回读 | `organization.provinceCode/cityCode = 000000`；`certification.establishedAt/address = null`；mobile 基础资料保存被本地 guard 拦住且 `PUT basic` 未发出；`basic.*` 仍为空且 `submitReady = false` | 是 | `/exhibition/enterprise/apply`；`/api/app/exhibition/enterprise-hub/workbench`；`/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic|profiles/*` | Server/Enterprise | organization 真值、certification OCR 真值、workbench readiness truth | 组织有效省市真值补齐且 mobile `PUT basic` 真正发出并回读 |
| EXH-006 | 展览楼 | 企业展示 | 企业入驻申请状态/续办 | 受控可用 | `applications create/submit/status` path family 与状态页已登记；continue handoff 已和工作台绑定 | 真实组织会话下的提交后状态回读、续办与提交流仍待复签；当前提交前阻断仍受工作台真值限制 | 是/部分 | `/exhibition/enterprise/application-status`；`/api/app/exhibition/enterprise-hub/applications*` | Server | 登录、组织、workbench submit 链 | enterprise workbench blocker 清零后完成真实 submit/status smoke |
| EXH-007 | 展览楼 | 项目体系 | 项目展示广场 | 受控可用 | `project/list` path family、项目列表页、项目详情页已挂出；current runtime 已到 auth guard | 真实公域项目列表/详情数据、项目审核联动尚未复签 | 是 | `/exhibition/projects`；`/api/app/project/list|detail` | Server/Project | 项目真源、审核 | 真实项目数据 smoke 通过 |
| EXH-008 | 展览楼 | 项目体系 | 项目发布 | 受控可用 | `project/create` 路由和页面已挂出；current runtime 已到 auth guard | 已登录且具备资格时的发布 smoke、项目审核台联动、上传链全量验证仍未完成 | 是 | `/exhibition/projects/create`；`/api/app/project/create` | Server/Project | 身份、认证、上传、审核 | 已登录项目发布 smoke 通过 |
| EXH-009 | 展览楼 | 项目体系 | 报名/竞标/接单 | 冻结待实现 | mobile route、openapi path、基础 command carrier 已登记 | 真实竞标席位、报价、选择、资格校验都未进入当前主线 | 可挂入口 | `/exhibition/bids/submit`；`/api/app/bid/submit` | Server/Bidding | 权限、支付、履约 | 竞标主线正式打开 |
| EXH-010 | 展览楼 | 项目体系 | 下单 | 冻结待实现 | `order/create` routeTarget 与页面骨架已登记 | 真订单对象、金额计算、支付承接、订单中心都未正式打开 | 可挂入口 | `/exhibition/orders/create`；`/api/app/order/create` | Server/Order | 支付、订单真源 | 交易主线正式打开 |
| EXH-011 | 展览楼 | 项目体系 | 合同/履约读取走廊 | 阻断中 | 本地 `mobile + BFF + Server` 均已有 read corridor 文件与页面；历史 stage2 文书存在 | current active `order/detail`、`contract/detail`、`milestone/list`、`inspection/detail` 全部 `404` | 是 | `/exhibition/orders/detail`；`/exhibition/contracts/detail`；`/exhibition/milestones`；`/exhibition/inspections/detail`；`/api/app/order|contract|milestone|inspection/*` | Server | 阶段 2 active runtime materialization | 四条 read corridor 在 `:80` 成立 |
| EXH-012 | 展览楼 | 项目体系 | 合同/履约执行命令 | 冻结待实现 | confirm/amend/milestone submit/inspection submit/recheck 的 command carrier 和页面已登记 | 真合同、真节点、真验收、真执行状态机还未在当前主线闭环 | 可挂入口 | `/exhibition/contracts/confirm|amend`；`/exhibition/milestones/submit`；`/exhibition/inspections/submit|recheck` | Server/Contract | 文件、权限、履约状态机 | 履约主线打开 |
| EXH-013 | 展览楼 | 项目体系 | 评价/纠纷 | 冻结待实现 | rating/dispute route family 与页面已登记 | 真实评分、纠纷工单、裁决闭环未进入当前主线 | 可挂入口 | `/exhibition/ratings/*`；`/exhibition/disputes/*` | Server | 订单、合同、治理 | 评价/纠纷主线打开 |
| EXH-014 | 展览楼 | 行业论坛 | 展览论坛 | 阻断中 | forum implementation unlock 已成立；forum 容器、`广场/本地/关注`、发布/草稿/搜索/我的论坛等页面已挂出 | current active 只见部分 `/api/app/forum/*` 路由；`post/detail`、`comments`、`search`、`me/index`、`author/*`、`interaction/inbox` 现为 `404` 漂移 | 是 | `/exhibition/forum*`；`/api/app/forum/*` | Server/Forum | forum current artifact、内容安全 | forum active artifact 与本地消费面对齐 |
| EXH-015 | 展览楼 | 行业工具 | 天气/定位/刷新 | 阻断中 | 天气卡片 UI、天气语义 V1、定位刷新规则历史文书已存在 | 依赖 `home*` path family；current `refresh/location/select` 在 `:80` 未 materialize | 是 | 展览首页顶部与天气卡片；`/api/app/exhibition/home/refresh|location/select` | BFF | 展览首页 current artifact、定位权限 | `home*` current runtime 恢复 |

### A3. 装修楼 / 商城楼

| 功能编号 | 楼栋/域 | 功能簇 | 功能项 | 当前状态 | 当前已完成 | 当前未完成 | 入口是否挂出 | 页面/路由 | 真相 owner | 当前依赖 | 下一开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REN-001 | 装修楼/商城楼 | 首页 | 分类首页 | 占位已挂出 | `renovation` 壳、路由、隐藏开关已真实存在；默认隐藏 | 分类、推荐、真实列表、交易链都未做 | 是/隐藏 | `/renovation` | BFF/Server | 商品/服务真源 | 商城主线打开 |
| REN-002 | 装修楼/商城楼 | 商家展示 | 商家列表 | 冻结待实现 | 仅保留楼栋承载面 | 商家资料、筛选、列表、详情未实现 | 可挂入口 | 后续新增 | Server | 商家真源 | 商家主线打开 |
| REN-003 | 装修楼/商城楼 | 商品服务 | 商品/服务详情 | 冻结待实现 | 仅保留楼栋承载面 | 图文详情、规格、咨询未实现 | 可挂入口 | 后续新增 | Server | 商品真源 | 商品主线打开 |
| REN-004 | 装修楼/商城楼 | 交易 | 购物车 | 冻结待实现 | 无 | 加购、删项、改数量未实现 | 可挂入口 | 后续新增 | BFF/Server | 商品真源 | 交易主线打开 |
| REN-005 | 装修楼/商城楼 | 交易 | 下单 | 冻结待实现 | 无 | 下单、地址、金额、支付未实现 | 可挂入口 | 后续新增 | Server | 支付、订单 | 交易主线打开 |
| REN-006 | 装修楼/商城楼 | 交易 | 订单 | 冻结待实现 | 无 | 订单状态、售后未实现 | 可挂入口 | 后续新增 | Server | 订单真源 | 订单主线打开 |
| REN-007 | 装修楼/商城楼 | 支付 | 支付承接 | 冻结待实现 | 可复用支付状态边界包 | 真支付闭环、结算、财务后台未实现 | 可挂入口 | 后续新增 | Server | 支付主线 | 支付 MVP 打开 |

### A4. 全屋定制楼

| 功能编号 | 楼栋/域 | 功能簇 | 功能项 | 当前状态 | 当前已完成 | 当前未完成 | 入口是否挂出 | 页面/路由 | 真相 owner | 当前依赖 | 下一开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CUS-001 | 全屋定制楼 | 首页 | 定制首页 | 占位已挂出 | `custom_furniture` 壳、路由、隐藏开关已真实存在；默认隐藏 | 聚合内容和业务真值未做 | 是/隐藏 | `/custom-furniture` | BFF/Server | 定制真源 | 定制主线打开 |
| CUS-002 | 全屋定制楼 | 需求 | 定制需求发布 | 冻结待实现 | 仅保留楼栋承载面 | 发布、图片、尺寸、预算未实现 | 可挂入口 | 后续新增 | Server | 身份、上传 | 需求主线打开 |
| CUS-003 | 全屋定制楼 | 供给 | 定制商家/工厂展示 | 冻结待实现 | 仅保留楼栋承载面 | 列表、详情、筛选未实现 | 可挂入口 | 后续新增 | Server | 企业真源 | 展示主线打开 |
| CUS-004 | 全屋定制楼 | 方案 | 方案沟通/报价 | 冻结待实现 | 无 | 方案、报价、确认未实现 | 可挂入口 | 后续新增 | Server | 消息、支付 | 报价主线打开 |
| CUS-005 | 全屋定制楼 | 订单 | 定制订单/履约 | 冻结待实现 | 无 | 订单、节点、验收未实现 | 可挂入口 | 后续新增 | Server | 合同、支付 | 履约主线打开 |

### A5. 消息楼

| 功能编号 | 楼栋/域 | 功能簇 | 功能项 | 当前状态 | 当前已完成 | 当前未完成 | 入口是否挂出 | 页面/路由 | 真相 owner | 当前依赖 | 下一开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MSG-001 | 消息楼 | 会话 | 消息楼首页 / 互动中心 | 阻断中 | `/messages` 页面与 building 已挂出；当前 UI 已按互动中心设计 | 当前 active `forum/interaction/inbox` 为 `404`；不是完整 messages 域 | 是 | `/messages` | BFF/Server | forum interaction inbox、消息主线 | current inbox path 在 `:80` 恢复 |
| MSG-002 | 消息楼 | 会话 | `message/index` 单一对象闭环 | 阻断中 | mobile consumer、entry registry、单一对象真相裁决文书已存在 | current `GET /api/app/message/index = 404`；没有 active runtime materialization | 是 | `/api/app/message/index` | Server | 阶段 4 message mainline | `message/index` 在 `:80` 成立 |
| MSG-003 | 消息楼 | 系统消息 | 系统通知 | 占位已挂出 | 消息楼入口已可见；系统通知已登记入消息域 | 无当前 active system-notification route family | 是 | `/messages` / 通知页预留 | Server | 通知体系 | 通知主线打开 |
| MSG-004 | 消息楼 | 项目消息 | 项目相关消息 | 冻结待实现 | 仅 routeTarget 和未来楼间 handoff 已登记 | 项目流消息、订单/履约消息未实现 | 可挂入口 | 会话页/项目页 | Server | 项目主线 | 项目消息主线打开 |
| MSG-005 | 消息楼 | 论坛互动 | 评论/回复/点赞/关注提醒 | 阻断中 | 互动中心页面已明确只承接 forum-originated inbox semantics | current active inbox path 未 materialize；不能说当前已真实可用 | 是 | `/messages`；历史设计指向 `/api/app/forum/interaction/inbox` | Server | forum 主线 | inbox path 恢复并通过 smoke |
| MSG-006 | 消息楼 | 安全治理 | 举报/拉黑/屏蔽 | 占位已挂出 | block relation status-only、my report、my appeal 等 bounded capability 已在平台别处成立 | 消息详情内的举报/拉黑/屏蔽没有独立闭环；私域互动屏蔽仍未做 | 是/部分 | 会话详情预留；治理入口散落于 `profile/forum` | Server | 内容安全、block P0-B | 消息安全主线打开 |
| MSG-007 | 消息楼 | 私域治理 | 陌生人消息控制 | 明确延期 | 已登记，不会丢 | 限制、放行、风控链未进入当前轮次 | 否 | 后续新增 | Server | 消息治理 | Message Safety P1 打开 |
| MSG-008 | 消息楼 | 私域治理 | 消息内容审核/预览治理 | 明确延期 | 已登记，不会丢 | 私信审核、预览治理未进入当前轮次 | 否 | 后续新增 | Server | 内容安全 | Message Safety P2 打开 |

### A6. 我的楼

| 功能编号 | 楼栋/域 | 功能簇 | 功能项 | 当前状态 | 当前已完成 | 当前未完成 | 入口是否挂出 | 页面/路由 | 真相 owner | 当前依赖 | 下一开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ME-001 | 我的楼 | 首页 Hub | 我的楼首页聚合 | 阻断中 | `/profile` 页面、compact hub boundary、`profile/index` route family 已存在 | `我的楼 Round 1` 当前 formal conclusion = `不通过`；核心 blocker 是 `certificationStatus` 语义漂移 | 是 | `/profile`；`/api/app/profile/index` | BFF/Profile | 账号、组织、认证、Round 1 修正 | Round 1 复签通过 |
| ME-002 | 我的楼 | 公司组织 | 我的公司 | 受控可用 | `company` 页面、organization mine/create/join/switch 已挂出并到 auth guard | 真实组织上下文 smoke、更多组织资料编辑与成员治理未闭环 | 是 | `/profile/company`；`/api/app/profile/organization/*` | Server/Organization | 组织真源 | 真实组织会话 smoke 通过 |
| ME-003 | 我的楼 | 认证 | 企业认证状态 | 受控可用 | `current/submit/resubmit` 页面与 route family 已存在；Admin Review P0 已有基座 | Round 1 certification semantics 修正仍待完成 | 是 | `/profile/certification/current|submit|resubmit` | Server/Profile | 审核台、组织上下文 | Round 1 认证语义修正通过 |
| ME-004 | 我的楼 | 成员 | 成员管理 | 阻断中 | members list route 和前端 member sheet 已存在 | `members/{memberId}/role`、`disable` 在 current `:80` 未 materialize；权限链未闭环 | 是/部分 | `我的公司成员面板`；`/api/app/profile/organization/members*` | Server/Organization | 权限体系、组织上下文 | member role/disable 对齐 |
| ME-005 | 我的楼 | 项目 | 我的项目 | 受控可用 | `my/projects` 页面与 route family 已存在；current runtime 已到 auth guard | 真实已登录项目列表/详情 smoke 仍待重签 | 是 | `/exhibition/my/projects*`；`/api/app/my/projects` | Server/Project | 项目真源 | 已登录 my-project smoke 通过 |
| ME-006 | 我的楼 | 资产 | 我的论坛 / 收藏 / 历史承接 | 占位已挂出 | `我的论坛` 入口和页面已挂出；私域 projection 已预留 | 通用收藏/最近浏览/历史没有统一真源；论坛个人资产 current active artifact 也未全量复签 | 是/部分 | `/profile/forum` | BFF/Server | forum 真源、私域 IA | forum personal assets 与通用资产主线打开 |
| ME-007 | 我的楼 | 治理 | 治理摘要与我的申诉记录 | 受控可用 | `governance/status`、`governance/appeals` list/detail path family 已存在；文书链有 bounded completion | current `POST /api/app/profile/governance/appeals` 提交未成立；只读治理摘要与申诉记录未做真实会话 smoke | 是 | `/profile/governance/appeals`；`/api/app/profile/governance/status|appeals*` | Server | 内容安全、申诉真源 | 提交写链与真实会话 smoke 通过 |
| ME-008 | 我的楼 | 会员 | 会员中心 | 受控可用 | `current/explanation/quota/upgrade-guide` bounded package 已有实现；current `:80` 全到 auth guard | 购买、续费、支付、账单不在本包；真实会员购买闭环未打开 | 是/部分 | 会员页卡片；`/api/app/profile/membership/*` | Server | 支付主线 | 支付 MVP 解锁 |
| ME-009 | 我的楼 | 信用保障 | 信用/保证金/交易保障状态 | 受控可用 | `status/explanation/handoff/dependency` bounded package 已存在；current `:80` 到 auth guard | 真保证金支付、真保障执行、交易资格链未打开 | 是/部分 | 状态页；`/api/app/profile/credit-and-constraints/*` | Server | 交易保障主线 | 阶段 7 execution 主线打开 |
| ME-010 | 我的楼 | 支付账单 | 支付与账单状态 | 受控可用 | `status/explanation/handoff/dependency` bounded package 已存在；current `:80` 到 auth guard | 真支付、结算、发票、财务后台未做 | 是 | 状态页；`/api/app/profile/payment-and-billing-status/*` | Server | 财务/支付主线 | 支付 MVP 解锁 |
| ME-011 | 我的楼 | 订单 | 订单中心 | 冻结待实现 | 状态页和 trade routeTarget 可预留 | 真订单中心、售后、交易闭环未进入当前轮次 | 可挂入口 | 后续新增 | Server | 交易主线 | 订单主线打开 |
| ME-012 | 我的楼 | 安全 | 身份与安全 | 受控可用 | 登录页、session center、`security/devices` 读链已存在并到 auth guard | 真实设备 revoke smoke、统一安全设置仍待复签 | 是 | `/profile/login`；`/profile/session`；`/api/app/profile/security/devices*` | Server/Auth | 会话、设备、安全主线 | 设备管理 smoke 通过 |
| ME-013 | 我的楼 | 资料 | 资料编辑 | 受控可用 | 个人资料页、头像、昵称、Profile Safety P0 已完成 | 更完整资料编辑与当前 active runtime 的已登录 smoke 仍待重签 | 是 | `/profile/me`；头像/昵称/资料子页 | Server/Profile | 内容安全、上传 | profile edit smoke 通过 |
| ME-014 | 我的楼 | 财务资料 | 发票与账单资料 | 冻结待实现 | 状态边界包可复用 | 发票抬头、税务资料、财务资料页未实现 | 可挂入口 | 后续新增 | Server/Finance | 支付主线 | 财务主线打开 |
| ME-015 | 我的楼 | 私域操作系统 | 私域操作系统整理 | 受控可用 | `regrouping / ordering / corridor / explanation / dependency-reference` bounded package 已通过；projection chain 已恢复 | 不等于 rewrite-ready、不等于治理台、不等于 integration/release-pass | 是/部分 | `profile/index` projection carriers | BFF/Profile | V2.3 bounded projection | 仅在后续 package judgment 中继续 |

### A7. Admin / 后台

| 功能编号 | 楼栋/域 | 功能簇 | 功能项 | 当前状态 | 当前已完成 | 当前未完成 | 入口是否挂出 | 页面/路由 | 真相 owner | 当前依赖 | 下一开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ADM-001 | Admin | 登录 | 管理员登录 | 占位已挂出 | `/login`、`/api/health`、Next runtime、health check 已存在 | 当前仍是 disabled placeholder；真实凭据、session、成功态 smoke 未完成 | 是 | `/login` | Admin/Server | 管理员凭据、session | reviewer/admin 真登录 smoke 通过 |
| ADM-002 | Admin | 审核台 | 内容安全审核台 | 阻断中 | `/review` 页面、review shell、queue/detail、approve/reject action、Server Admin API 已存在；历史 bounded completion 已有 | 当前 active artifact 被登录占位阻断；不能算当前可操作闭环 | 是 | `/review`；`/api/admin/reviews/*` | Server/Admin | Admin login、reviewer 会话 | Admin 真登录后重做 current smoke |
| ADM-003 | Admin | 认证审核 | 企业认证审核台 | 占位已挂出 | 组织认证 review path family 和 Admin surface 已冻结；review 模块已存在 | 独立的认证审核闭环未作为 current active workflow 重签 | 是/部分 | review 模块内承接；`/server/admin/reviews/organizations*` | Server/Admin | 认证主线、Admin login | 认证审核实操 smoke 通过 |
| ADM-004 | Admin | 项目审核 | 项目审核台 | 占位已挂出 | `/project_review` 页面已挂出；项目审核 surface 已在 Admin 矩阵登记 | 列表、详情、审核动作没有 current active verification | 是 | `/project_review` | Server/Admin | 项目主线、Admin login | project_review smoke 通过 |
| ADM-005 | Admin | 治理 | 处罚台 | 阻断中 | `/governance/penalties` 页面、penalty shell、Server Admin list/detail/apply、历史结果验证 PASS 已存在 | 当前 active artifact 仍被登录占位阻断；white/ban 不在本条范围 | 是 | `/governance`；`/governance/penalties*` | Server/Admin | Admin login、审计 | Admin 真登录后重做 penalty smoke |
| ADM-006 | Admin | 治理 | 申诉复核台 | 阻断中 | `/governance/appeals` 页面、appeal shell、Server Admin list/detail/decide、历史结果验证 PASS 已存在 | 当前 active artifact 仍被登录占位阻断；用户端提交写链也未在 current `:80` 成立 | 是 | `/governance`；`/governance/appeals*` | Server/Admin | Admin login、审计 | Admin 真登录后重做 appeal smoke |
| ADM-007 | Admin | 治理 | 白名单 / 永久封禁台 | 冻结待实现 | 已在治理主线中登记，不会丢 | 白名单、永久封禁、对应历史与申诉链未进入 current implementation | 可挂入口 | 治理页后续新增 | Server/Admin | 内容安全、权限、审计 | whitelist/ban 主线打开 |
| ADM-008 | Admin | 审计 | 审计台 | 占位已挂出 | `/audit` 页面与 shell 已挂出；审计底座已存在 | 查询、过滤、导出工作台未闭环；当前登录仍阻断 | 是 | `/audit` | Server/Admin | 审计日志、Admin login | 审计台 smoke 通过 |
| ADM-009 | Admin | 配置 | 模板配置台 | 占位已挂出 | `/template_config` 页面与 shell 已挂出；Admin matrix 已登记 | draft/publish/archive 模板治理没有 current active verification | 是 | `/template_config` | Server/Admin | 模板真源、Admin login | template_config smoke 通过 |
| ADM-010 | Admin | 工单 | 工单 / 案件路由台 | 占位已挂出 | `/ticketing` 页面与 shell 已挂出；Admin matrix 已登记 | 工单分类、路由、跟进、结案动作未在 current active runtime 重签 | 是 | `/ticketing` | Server/Admin | dispute/rating case truth、Admin login | ticketing smoke 通过 |

## B. 已完成功能清单

- `CORE-013` 平台预埋 `Live/Geo/Map` 底座
- `CORE-014` AI 审核服务统一接入层

## C. 受控可用功能清单

- `CORE-002` 组织/公司切换
- `CORE-004` 企业认证
- `CORE-005` 文件上传/图片上传
- `CORE-008` 内容安全治理
- `CORE-009` 支付/账单状态边界包
- `CORE-011` 审计日志
- `EXH-002` 优秀公司
- `EXH-003` 优秀工厂
- `EXH-004` 优秀供应商
- `EXH-006` 企业入驻申请/申请状态
- `EXH-007` 项目展示广场
- `EXH-008` 项目发布
- `ME-002` 我的公司
- `ME-003` 企业认证状态
- `ME-005` 我的项目
- `ME-007` 治理摘要与我的申诉记录
- `ME-008` 会员中心
- `ME-009` 信用/保证金/交易保障状态
- `ME-010` 支付与账单状态
- `ME-012` 身份与安全
- `ME-013` 资料编辑
- `ME-015` 私域操作系统整理

## D. 占位已挂出功能清单

- `CORE-006` 全局搜索与筛选
- `CORE-007` 系统通知
- `REN-001` 装修楼/商城楼分类首页
- `CUS-001` 全屋定制楼定制首页
- `MSG-003` 系统通知
- `MSG-006` 举报/拉黑/屏蔽
- `ME-006` 我的论坛 / 收藏 / 历史承接
- `ADM-001` 管理员登录
- `ADM-003` 企业认证审核台
- `ADM-004` 项目审核台
- `ADM-008` 审计台
- `ADM-009` 模板配置台
- `ADM-010` 工单 / 案件路由台

## E. 冻结待实现功能清单

- `CORE-010` 真实支付系统 MVP
- `CORE-012` 埋点/报表/运营统计
- `EXH-009` 报名/竞标/接单
- `EXH-010` 下单
- `EXH-012` 合同/履约执行命令
- `EXH-013` 评价/纠纷
- `REN-002` 商家列表
- `REN-003` 商品/服务详情
- `REN-004` 购物车
- `REN-005` 下单
- `REN-006` 订单
- `REN-007` 支付承接
- `CUS-002` 定制需求发布
- `CUS-003` 定制商家/工厂展示
- `CUS-004` 方案沟通/报价
- `CUS-005` 定制订单/履约
- `MSG-004` 项目相关消息
- `ME-011` 订单中心
- `ME-014` 发票与账单资料
- `ADM-007` 白名单 / 永久封禁台

## F. 明确延期功能清单

- `MSG-007` 陌生人消息控制
- `MSG-008` 消息内容审核/预览治理

## G. 当前主线与下一条候选主线

> 说明：本轮固定输出格式没有单独要求《阻断中功能清单》，因此所有 `阻断中` 功能已完整写在 A 表；下面只给当前主线收口和下一条候选主线。

| 项目 | 当前裁决 | 覆盖对象 | 为什么是它 |
| --- | --- | --- | --- |
| 当前主线 | `enterprise display full closure mainline` | `ME-006`、`EXH-001`、`EXH-002`、`EXH-003`、`EXH-004`、`EXH-005`、`EXH-006A`、`EXH-006`、`ADM-002`、`ADM-005` | 这条主线现在被正式定义为一条完整串行链：`我的楼入口 -> 企业展示工作台 -> application submit/status -> admin review/publish -> 优秀公司/工厂/供应商 list/detail/recommendation/home`。它不能再被拆成“workbench 一条”和“公域展示一条”两个半链。 |
| 下一条候选主线 | `Admin real login + generic governance closure` | `ADM-001`、`ADM-006`、`ADM-008`、`ADM-009`、`ADM-010` | enterprise-display 本线只允许带上 review/publish 所需的最小 admin 子集；更泛化的 Admin 登录/治理平台化要等这条线 closure 后再接。 |

当前唯一下一步不是继续扩表，而是：

- 先按 A 表中的 `阻断中` 项，输出并执行一张《active runtime drift closure dispatch sheet》
- 第一优先级按顺序固定为：
  - `ED-1 organization/certification upstream truth repair`
  - `ED-2 enterprise display workbench basic/profile/case/readiness closure`
  - `ED-3 application submit/status closure`
  - `ED-4 admin review/publish minimal ops closure`
  - `ED-5 public company/factory/supplier list/detail closure`
  - `ED-6 home card/recommendation closure`
  - `ED-7 full through-chain result verification`
