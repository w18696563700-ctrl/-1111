---
owner: 总控文书冻结
status: frozen
purpose: Deliver a customer-safe delivery scheme and internal implementation-prep package for the exhibition trade-governance four-document set without overstating current runtime completion.
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 落地方案与实施准备包 V1

## 1. 方案定位

- 本文书是“落地方案与实施准备包”，不是“已完成上线说明”。
- 本文书只服务于：
  - 明日客户解释当前路线
  - 内部团队下一轮 bounded 施工准备
- 本文书不构成：
  - implementation unlock
  - release-prep
  - release execution
- 当前稳健口径必须固定为：
  - 上游冻结完成度高
  - 运行实现完成度低
  - 当前可交付的是“方案包”，不是“治理闭环已上线”
- 门禁依据见
  [exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md)
  与
  [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)。

## 2. 当前态总览

### 2.1 已冻结

- 四文书方向与 App 对齐已冻结：
  [exhibition_trade_governance_four_documents_mother_blueprint_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_mother_blueprint_v1.md)，
  [exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md)。
- 四份 contracts、四份 backend truth、四份 BFF surface 已冻结：
  [docs/01_contracts](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts)，
  [docs/02_backend](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend)，
  [docs/03_bff](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff)。

### 2.2 已注册 contract

- 当前 `openapi.yaml` 已注册：
  - 账户与企业认证：`/api/app/profile/*`、`/server/admin/reviews/organizations/*`
  - 假项目举报：`POST /api/app/exhibition/report/submit`、`/server/admin/exhibition/report-cases/*`
  - 合同与履约：`/api/app/contract/*`、`/api/app/milestone/*`、`/api/app/inspection/*`
  - 黑白名单与申诉：`/api/app/profile/governance/*`、`/server/admin/governance/*`
  证据见
  [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)。

### 2.3 已有前端承接

- Profile 当前只有 login / organization handoff / certification current /
  session center 最小承接，见
  [profile_identity_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart)，
  [profile_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_page.dart)，
  [profile_identity_access_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart)。
- Exhibition 当前已有 project / bid guard 与 contract / milestone /
  inspection 的最小 handoff 页，见
  [exhibition_canonical_paths.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart)，
  [bid_submit_guard_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart)，
  [contract_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart)，
  [milestone_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart)，
  [inspection_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart)。
- 这些前端承接页本身并不等于服务端闭环，`contract_confirm_page.dart` 已明确写明演示结果不代表真实接口已打通，见
  [contract_confirm_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_confirm_page.dart)。

### 2.4 已有 BFF 路由

- 当前 BFF 代码家族主要集中在 `forum / project / enterprise_hub / file`，见
  [apps/bff/src/routes](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes)。
- 本地 `RoutesModule` 当前只导入 `EnterpriseHubModule`、`ProjectModule`、
  `FileUploadModule`，见
  [routes.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/routes.module.ts)。
- 当前确有 `project`、`file`、`forum` controller 代码落点，见
  [project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project.controller.ts)，
  [file.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/file/file.controller.ts)，
  [forum.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/forum/forum.controller.ts)。

### 2.5 已有 Server 真值

- 当前 Server 主实现集中在 `project / upload / enterprise_hub / audit`，见
  [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)。
- 本地 `AppModule` 当前只导入 `EnterpriseHubModule`、`ProjectModule`、
  `UploadModule`，见
  [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)。
- 当前 truth controller / service 落点可见于
  [project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.controller.ts)，
  [upload.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload.controller.ts)，
  [enterprise-hub-truth.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts)，
  [project-publish-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit.service.ts)。

### 2.6 当前空白项

- `apps/admin` 当前基本空白，仅有
  [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/AGENTS.md)
  与
  [README.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/README.md)。
- 当前 migration 只覆盖 `enterpriseHubMigrations` 与
  `projectPublishCorridorMigrations`，未覆盖四文书全链对象族，见
  [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)。
- `forum report` 不能冒充 `exhibition fake-project report`：
  Mobile 当前 forum 举报 path 在
  [forum_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/forum_consumer_layer.dart)，
  fake-project report 的冻结 path 在
  [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)。

## 3. 四文书逐包落地状态

| 文书包 | 已有基础 | 部分承接 | 尚未进入运行实现 | 证据 |
|---|---|---|---|---|
| 账户与企业认证 | 母蓝图、contracts、backend truth、BFF surface 已冻结 | Profile 最小身份入口与 bid guard 已存在 | 当前 inspected BFF / Server 触点未见 dedicated profile identity/certification 运行族 | [profile_identity_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart), [bid_submit_guard_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart), [apps/bff/src/routes](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes), [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) |
| 假项目举报与裁决 | contracts / backend truth / BFF surface 已冻结 | 当前只有 forum report 代码链存在 | Mobile/BFF/Server 都未形成 exhibition report-case 运行链 | [fake_project_report_and_adjudication_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md), [forum_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/forum_consumer_layer.dart), [forum.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/forum/forum.controller.ts), [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) |
| 合同归档与履约入链 | contracts / backend truth / BFF surface 已冻结 | contract / milestone / inspection 页面有最小 handoff | BFF 未见对应 route family；Server 未见对应 truth modules；migration 未见对象族 | [contract_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart), [milestone_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart), [inspection_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart), [apps/bff/src/routes](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes), [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) |
| 黑白名单与永久封禁 | contracts / backend truth / BFF surface 已冻结 | 目前只到文书与 contract 层 | Mobile/BFF/Server/Admin 都未进入运行实现 | [blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md), [profile_identity_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart), [apps/bff/src/routes](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes), [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules), [apps/admin/README.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/README.md) |

## 4. 当前态 -> 目标态差距矩阵

| 维度 | 当前态 | 目标态 | 主要缺口 | 证据 |
|---|---|---|---|---|
| 页面 | Profile 只有 login / organization / certification / session；Exhibition 只有最小 handoff 页 | 我的页承接资格/风控/申诉；展览页承接举报/合同/履约/验收主链 | 运行页面缺失，当前多为承接页 | [profile_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_page.dart), [contract_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart) |
| canonical API | OpenAPI 已注册四文书 path | 每条 path 均有 consumer、BFF、Server | 当前大量 path 仍是“已冻结，未实现” | [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml) |
| BFF aggregation | 本地主线集中在 forum / project / enterprise_hub / file | 增补 profile governance、exhibition report、contract/fulfillment 聚合 | 治理相关 route family 缺失 | [routes.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/routes.module.ts), [apps/bff/src/routes](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes) |
| Server truth | 本地主线集中在 project / upload / enterprise_hub / audit | 增补 report-case、governance overlay、contract/milestone/inspection truth | 模块与状态族未落地 | [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts), [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) |
| persistence objects | 已落 enterprise_hub 与 project publish corridor | 落地 report-case、governance、contract/milestone/inspection 对象 | migration 未覆盖四文书全链 | [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) |
| admin workbenches | 只有 skeleton | 认证审核台、举报案件台、风控处罚台、申诉台、合同归档观察台 | `apps/admin` 仍空白 | [apps/admin/README.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/README.md) |
| audit / evidence / appeal | 局部已有 upload/file truth 与 project publish audit | 四文书对象都可追责、可留痕、可申诉 | 目前只有局部审计和上传链 | [upload.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload.controller.ts), [project-publish-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit.service.ts) |

## 5. 安全有序推进顺序

### D0 方案交付包

- 输入前提：docs-only 门禁已通过。
- 允许施工范围：`docs/00_ssot/**`。
- 禁止事项：改 `apps/**`、新增 migration、把方案写成 release note。
- 完成标志：形成客户可讲、团队可接的正式方案包。

### D1 真值补齐包

- 输入前提：D0 完成并经总控复核。
- 允许施工范围：`apps/server/**` 与必要 `docs/02_backend/**`。
- 禁止事项：把真值推给 BFF / Flutter；发明第二套 truth。
- 完成标志：report-case、governance overlays、contract/milestone/inspection 各有最小 Server truth owner。

### D2 BFF 聚合补齐包

- 输入前提：D1 已形成可调用 `Server` truth。
- 允许施工范围：`apps/bff/**` 与必要 `docs/03_bff/**`。
- 禁止事项：BFF 持有治理真值；新增裸 path。
- 完成标志：已冻结 app-facing path 均有受控 aggregation。

### D3 Flutter / Admin 消费补齐包

- 输入前提：D2 形成主要 app-facing path。
- 允许施工范围：`apps/mobile/**`、`apps/admin/**`。
- 禁止事项：Flutter 直连 Server；Admin 绕过 Server 真值；消费层本地造状态机。
- 完成标志：Profile 有资格/风控/申诉摘要入口；Exhibition 有举报/合同/履约消费面；Admin 有最小治理台席。

### D4 联调与验收准备包

- 输入前提：D1-D3 均有实现回执。
- 允许施工范围：联调清单、验收口径、回滚清单、审计/证据/申诉校核。
- 禁止事项：无回执直接宣称上线。
- 完成标志：形成可验证、可追责、可回滚的联调准备包。

## 6. 四文书执行主链

| 主链 | page entry | BFF path | Server truth owner | persistence family | admin seat | audit / evidence | appeal entry |
|---|---|---|---|---|---|---|---|
| 账户与企业认证 | `我的公司`、`认证与成员身份`、`session center`，见 [profile_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_page.dart) | `/api/app/profile/*`、`/api/app/auth/*`，见 [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md) | `users`、`sessions`、`organizations`、`organization_members`、`organization_certifications`，见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md) | 依附现有 identity / organization / certification 表族 | 认证审核台、组织审核台 | 认证提交、审批、组织切换都需审计；文件仍走 shared upload -> `FileAsset` | 当前不单独开放认证申诉 path；若进入处罚，统一回归治理申诉主线 |
| 假项目举报与裁决 | 应挂在 `exhibition` 对象页；当前不能借 forum 举报入口冒充，见 [forum_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/forum_consumer_layer.dart) | `POST /api/app/exhibition/report/submit`，见 [fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md) | `exhibition_report_cases`、temporary restriction、adjudication result，见 [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md) | `exhibition_report_cases` + `review_tasks` + `audit_logs` + `file_assets` + `evidences` | 举报案件台、解释台、裁决台、升级台 | 举报提交、限制、解释请求、裁决都需留痕 | 本包自身不单开 user-side appeal；若进入处罚，统一回到治理申诉主线 |
| 合同归档与履约入链 | `order/detail`、`contract/detail`、`milestone/list`、`inspection/detail` 等 continuation 页，见 [exhibition_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart) | `/api/app/contract/*`、`/api/app/milestone/*`、`/api/app/inspection/*`，见 [contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md) | `orders`、`contracts`、`milestones`、`inspections`，见 [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md) | `orders`、`contracts`、`contract_clauses`、`milestones`、`inspections`、`evidences`、`file_assets`、`audit_logs` | 合同归档观察台、履约观察台、审计台 | 合同确认、改单、里程碑、验收、复检都需留痕 | 对象异议入口仍是 `dispute/open`；治理处罚申诉统一回 `profile/governance/appeals` |
| 黑白名单与永久封禁 | 方向上应落在 `我的 > 风控与处罚摘要 > 申诉入口`，当前未有真实页，见 [profile_identity_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart) | `GET /api/app/profile/governance/status`、`POST /api/app/profile/governance/appeals`，见 [blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md) | `governance_penalties`、`governance_appeal_cases`、`governance_whitelist_memberships`、`governance_permanent_bans`，见 [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md) | governance overlay 依附 organization/member/review/audit/evidence 体系 | 处罚台、申诉复核台、白名单台、永久封禁台 | 处罚、封禁、申诉、撤销都必须留痕 | 当前唯一冻结的 user-side 申诉入口是 `POST /api/app/profile/governance/appeals` |

## 7. 客户口径说明

- 可以说“已具备基础承接”的部分：
  - 四文书规则与 canonical path 已冻结
  - Profile 已有最小身份入口
  - Exhibition 已有 project/bid guard 与合同/履约最小承接页
- 必须说“已冻结规则但未运行实现”的部分：
  - fake-project report
  - governance status / appeals
  - contract / milestone / inspection 服务端真值闭环
  - admin 治理台席
- 可以说“下一阶段优先补齐”的部分：
  - 认证与资格真值补齐
  - fake-project report case 与裁决主链
  - 合同归档与履约真值主链
  - 黑白名单 / 处罚 / 申诉 overlay 主链
- 不得说：
  - “平台治理链路已完整上线”
  - “后台治理工作台已具备”
  - “举报、处罚、申诉、归档、履约已全量跑通”

## 8. 风险与阻断

- 误把文档冻结当实现完成。
- fake-project report 与 forum report 混淆。
- profile 风控中心缺失。
- governance truth carriers 未落库。
- admin 台席缺失。
- contract / milestone / inspection 真值族未落地。
- 跳过申诉、审计、证据链会直接破坏“安全、有序、可追责”主线。

## 9. 明确 Non-goals

- 本轮不做：
  - `apps/**` 运行实现
  - migration 新增与执行
  - deploy
  - release-prep
  - release execution
  - 对外宣称完整上线
- 本轮也不做：
  - 第二套 identity / organization / permission / governance truth
  - 裸 path 家族扩容
  - 把 BFF 写成治理真值 owner
  - 把 `objectKey` 写成业务真相

## 10. 下一轮 bounded prompt bundle

- 以下四段仅是下一轮门禁复核后的口令草稿，不构成当前实现放行。

### 10.1 Backend Agent 口令

```text
你只负责 apps/server/** 与必要的 docs/02_backend/**。
目标：补齐 fake-project report、governance overlays、contract/milestone/inspection 的最小 Server truth。
禁止：修改 apps/bff/**、apps/mobile/**、apps/admin/**；发明第二套 truth；把 objectKey 当业务真相。
回执必须包含：文件路径、对象族清单、canonical route 对照、migration 清单、审计与申诉入口说明、未完成项与风险。
```

### 10.2 BFF Agent 口令

```text
你只负责 apps/bff/** 与必要的 docs/03_bff/**。
目标：补齐 profile/governance、exhibition/report、contract/milestone/inspection 的 app-facing aggregation corridor。
禁止：修改 apps/server/**、apps/mobile/**、apps/admin/**；新增裸 path；在 BFF 本地做资格、处罚、裁决决策。
回执必须包含：文件路径、app-facing canonical path 对照、downstream Server handoff 对照、response shaping 说明、风险。
```

### 10.3 Frontend Agent 口令

```text
你只负责 apps/mobile/**。
目标：补齐已冻结 contract 的消费页与 blocked-state copy，不在本地做治理真值判断。
禁止：直连 Server；本地发明状态机或错误码；伪造“后端已打通”的演示说明。
回执必须包含：文件路径、页面清单、路由清单、依赖 canonical path 清单、已消费字段/缺失字段/风险。
```

### 10.4 Admin / governance console 口令

```text
你只负责 apps/admin/**。
目标：规划认证审核台、举报案件台、处罚台、申诉复核台、白名单台、永久封禁台、合同归档观察台的最小结构。
禁止：越权直连非冻结 admin path；在台席层定义业务真值；宣称治理 console 已上线。
回执必须包含：文件路径、工作台清单、页面级/动作级/对象级权限表、与 /server/admin/* 对照表、风险与顺序。
```

## 11. 正式结论

- 明日可安全交付的是：
  - 一份不夸大现状的落地方案
  - 一份可直接继续施工的实施准备包
- 当前不能安全交付的是：
  - “治理闭环已上线”的结论
  - “Admin 治理工作台已具备”的结论
  - “假项目举报、处罚、申诉、履约入链已经跑通”的结论
- 当前最安全的继续顺序是：
  - D0 方案交付包
  - D1 真值补齐包
  - D2 BFF 聚合补齐包
  - D3 Flutter / Admin 消费补齐包
  - D4 联调与验收准备包
