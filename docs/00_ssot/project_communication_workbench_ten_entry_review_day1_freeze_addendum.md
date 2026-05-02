---
owner: Codex 总控
status: frozen
purpose: Freeze Day 1 truth and boundary for the project communication workbench 10-entry review and confirmation surface.
layer: L0 SSOT
freeze_scope: Day 1 read-only discovery and boundary freeze only
---

# 《项目沟通工作台 10 入口审阅确认摸底冻结单》

## 1. 总裁决

第 1 天裁决为 `Conditional Pass`。

允许进入第 2 天 contracts / Server truth 模型冻结；不得进入 Flutter、BFF、Server 代码实现，不得改云端，不得做合同确认或最终成交金额写 smoke。

Day 1 已确认：

- 10 个入口必须统一进入项目沟通工作台。
- 发布方和竞标方都显示 10 个入口，但点击后进入的页面和可执行动作不同。
- 5 个发布资料、3 个竞标资料、合同确认、最终成交金额确认必须分别引用既有业务真值，不允许 Flutter 或 BFF 造第二状态机。
- 消息震动、APNs、FCM、本轮不开通。

## 2. 当前最小闭环

本轮最小闭环是项目沟通工作台的 10 个固定入口和真值边界：

| 分组 | 入口 | 数量 | 说明 |
| --- | --- | ---: | --- |
| 发布资料确认 | 发布方报价依据资料 | 5 | 发布方上传，竞标方审阅；发布方查看反馈并补充。 |
| 竞标资料确认 | 竞标方提交资料 | 3 | 竞标方上传，发布方审阅；竞标方查看反馈并补充。 |
| 成交确认 | 合同确认、最终成交金额确认 | 2 | Server 持有交易真值，BFF/Flutter 只做入口和展示。 |

工作台入口不回到聊天输入框；聊天区只保留沟通、附件、图片、历史消息和兼容读回。

## 3. 10 个入口正式命名

### 3.1 发布资料确认 5 个

正式命名以报价依据资料包 V1 为准：

| entryKey | 展示名 | 真值来源 | 既有枚举 / 字段 |
| --- | --- | --- | --- |
| `publisher_effect_image_review` | `效果图确认` | Server `project_attachments` / confirmed `FileAsset` | `effect_image` |
| `publisher_construction_doc_review` | `尺寸图 / 施工图确认` | Server `project_attachments` / confirmed `FileAsset` | `construction_doc` |
| `publisher_material_sample_review` | `材质图 / 材料样板确认` | Server `project_attachments` / confirmed `FileAsset` | `material_sample` |
| `publisher_equipment_material_list_review` | `设备物料清单确认` | Server `project_attachments` / confirmed `FileAsset` | `equipment_material_list` |
| `publisher_service_list_review` | `服务清单确认` | Server `project_attachments` / confirmed `FileAsset` | `service_list` |

证据：

- `docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md`
- `docs/02_backend/quote_basis_material_package_v1_backend_truth_addendum.md`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`

### 3.2 竞标资料确认 3 个

正式命名以竞标提交页和 Server bid attachment slots 为准：

| entryKey | 展示名 | 真值来源 | 既有字段 / 槽位 |
| --- | --- | --- | --- |
| `bid_project_understanding_review` | `项目理解确认` | Server `bids` / confirmed `FileAsset` | `projectUnderstandingFileAssetId` |
| `bid_quote_sheet_review` | `报价表确认` | Server `bids` / confirmed `FileAsset` | `quoteSheetFileAssetId` |
| `bid_schedule_plan_review` | `进度安排确认` | Server `bids` / confirmed `FileAsset` | `schedulePlanFileAssetId` |

旧展示名收敛：

| 旧名 | 新统一名 |
| --- | --- |
| `报价确认` | `报价表确认` |
| `排期确认` | `进度安排确认` |
| `工艺材质确认` | `项目理解确认` |

证据：

- `docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md`
- `apps/server/src/modules/bid/bid-submission-attachment.support.ts`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_attachment_support.dart`

### 3.3 成交确认 2 个

| entryKey | 展示名 | 真值来源 | 边界 |
| --- | --- | --- | --- |
| `contract_confirmation` | `合同确认` | Server contract / P0-Pay deal confirmation truth | 只允许进入已冻结合同确认链路，不得在 Flutter/BFF 自行确认合同。 |
| `final_confirmed_amount_confirmation` | `最终成交金额确认` | Server `ContractConfirmation.finalConfirmedAmount` / deal confirmation | 这是平台服务费收费基准，不得命名为普通“最终价格”，不得由 Flutter/BFF 计算或持久化。 |

Day 1 裁决：

- 最终成交金额口径明确：`finalConfirmedAmount` 是平台服务费唯一收费金额真值。
- 合同确认生效后可能进入平台服务费扣费链路，因此本轮不得做真实写 smoke。
- Day 2 必须在 contracts 层裁决 app-facing canonical route；旧 `/api/app/contract/confirm` 不承接最终成交金额，不得当作最终成交金额确认入口。

证据：

- `docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md`
- `docs/01_contracts/openapi.yaml`
- `apps/server/src/modules/p0_pay/entities/contract-confirmation.entity.ts`
- `apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts`

## 4. 双角色页面差异

10 个入口在发布方和竞标方均可见，但详情页能力必须按角色分流：

| 入口类型 | 发布方进入后 | 竞标方进入后 |
| --- | --- | --- |
| 发布资料 5 个 | 查看自己上传的资料、查看竞标方反馈、按既有上传链补充资料。不得替竞标方确认。 | 查看发布方真实上传资料，提交 `已确认` 或 `需补充` 反馈。 |
| 竞标资料 3 个 | 查看竞标方真实提交资料，提交 `已确认` 或 `需补充` 反馈。 | 查看自己提交资料、查看发布方反馈、按既有竞标资料链补充资料。不得替发布方确认。 |
| 合同确认 | 进入发布方合同确认视角。 | 进入竞标方 / 工厂合同确认视角。 |
| 最终成交金额确认 | 进入发布方最终成交金额确认视角。 | 进入竞标方 / 工厂最终成交金额确认视角。 |

## 5. 状态口径

资料类 8 个入口的目标状态冻结为：

| 状态 | 颜色 | 含义 |
| --- | --- | --- |
| `unsubmitted` / `未提交` | 灰色 | 对应资料真值不存在或当前角色不可读取。 |
| `pending_review` / `待确认` | 橙色 | 对应资料存在，等待对方审阅确认。 |
| `confirmed` / `已确认` | 绿色 | 对方组织已对该资料确认，且 Server 持久化。 |
| `needs_supplement` / `需补充` | 鲜红色 | 对方组织提出补充反馈，且 Server 持久化。 |

Day 1 边界：

- 当前没有 8 个资料确认/反馈持久化 contract。
- 当前 Flutter 的本地变色不得升级为业务真值。
- 当前聊天 `confirmation_card` 不得作为资料审阅确认真值。

## 6. 可复用能力摸底

| 能力 | 当前存在 | 复用结论 |
| --- | --- | --- |
| 发布方 5 资料上传 / owner 管理 | 是 | 复用 `my projects attachments` / `project_attachments`。 |
| 竞标方读取发布资料 | 是 | 复用 `GET /api/app/project/bid-materials`。 |
| 竞标方 3 资料上传 | 是 | 复用竞标提交页 3 个 confirmed `FileAsset` 槽位。 |
| 竞标方 3 资料提交后回读 | 部分存在 | 可从 bid submission snapshot / my bid read-model 继续核对，Day 2 contracts 需冻结清楚。 |
| 8 资料确认/反馈持久化 | 否 | 需要 Day 2 contracts + Server truth freeze，Day 4 可能需要 additive migration。 |
| 合同确认 | 是 | 存在多套口径，Day 2 必须裁决 canonical route。 |
| 最终成交金额确认 | 是 | Server truth 存在，但写入可能触发扣费链路，必须高风险门禁。 |
| 10 入口统一 read-model | 否 | Day 2 需要冻结 `ProjectCommunicationWorkbenchEntry`。 |

## 7. 子代理派工回执

| 子代理 | 结论 |
| --- | --- |
| SSOT Agent | 5+3+资金边界已有分散冻结；10 入口母冻结和 8 资料确认/反馈真值不存在。 |
| Contracts Agent | 5 类发布资料已有；3 个竞标附件文书/BFF 已有但 `openapi.yaml` 存在漂移；无资料审阅确认/反馈 contract。 |
| Frontend Explorer | 当前 Flutter 是“发布方 3 / 竞标方 5”角色分流，不是 10 入口；已有资料上传链可复用，文件长度和窄屏风险高。 |
| BFF Explorer | 已有发布资料读取面、竞标提交 snapshot、合同/金额相关 route；无 10 入口 read-model，无 8 资料确认/反馈 route。 |
| Server Explorer | 发布 5 资料和竞标 3 附件有真值载体；8 资料审阅状态没有持久化；合同确认当前可能进入扣费链路。 |

## 8. No-Go 清单

以下事项在 Day 1 后仍为 No-Go：

1. 直接改 Flutter，把 10 个入口用本地状态变绿 / 变红。
2. 直接复用聊天 `confirmation_card` 作为 8 资料审阅状态。
3. BFF 根据文件存在、中文标题或旧确认卡推断 `confirmed`。
4. Flutter 或 BFF 计算、保存最终成交金额。
5. 未经支付门禁做合同确认 / 最终成交金额真实写 smoke。
6. 把 `/api/app/contract/confirm` 当成最终成交金额确认入口。
7. 在未冻结 migration 前实现 8 资料审阅持久化。
8. 本轮接入 APNs / FCM / 震动。
9. 清理或回退当前脏工作区中的非本轮改动。

## 9. 分层影响

| Layer | Day 1 是否涉及 | Day 1 裁决 |
| --- | --- | --- |
| SSOT | 是 | 本文件冻结 10 入口和边界。 |
| Contracts | 只读核对 | Day 2 必须 additive freeze，不在 Day 1 修改 `openapi.yaml`。 |
| Server | 只读核对 | 8 资料审阅状态需 Server truth；Day 1 不改。 |
| BFF | 只读核对 | 未来只做 app-facing read-model / command forwarder；Day 1 不改。 |
| Flutter | 只读核对 | 未来做 10 入口和详情页；Day 1 不改。 |
| 云端联调 | 否 | Day 1 不做 runtime 写操作，不做发版。 |

## 10. Day 2 准入条件

允许进入 Day 2：`Conditional Go`。

进入 Day 2 只允许做：

- contracts 字段表 / route 表 / Server truth 文书冻结。
- `ProjectCommunicationWorkbenchEntry` 读模型草案。
- 8 资料审阅对象、状态、反馈字段、权限边界冻结。
- 最终成交金额 canonical app-facing route 裁决。
- `BidSubmitRequest` 与 3 个竞标附件字段的 OpenAPI 漂移登记与修复方案。

Day 2 不允许做：

- Flutter / BFF / Server 代码实现。
- 数据库 migration。
- 云端发布或服务重启。
- 合同确认 / 最终成交金额写 smoke。
- 真实扣费。

## 11. 四类判断

| 判断项 | 裁决 |
| --- | --- |
| 哪个方案最稳 | 先冻结 10 入口 read-model、8 资料审阅 Server truth、最终成交金额 route，再分层实现。 |
| 哪个方案最低成本 | 只做 10 入口展示并复用既有资料读取，但不能满足真实确认/反馈。 |
| 哪个方案最适合当前阶段 | Day 1 只冻结边界；Day 2 做 additive contracts / Server truth，不碰实现。 |
| 哪个方案风险最大 | Flutter/BFF 本地拼状态，或把合同确认和最终成交金额写入与扣费链路一起贸然开通。 |

## 12. 总控建议

推荐采用“10 入口母冻结 -> contracts / Server truth -> Flutter UI 施工图 -> Server/BFF/Flutter 分层实现”的路径。

理由：

- 你的目标已经是平台交易闭环，不是按钮 UI。
- 5+3 资料可以少写代码复用现有上传/读取链路。
- 8 资料确认/反馈必须新增正式持久化，否则绿色/红色都是假状态。
- 最终成交金额涉及平台服务费，必须保持 Server truth 和支付门禁。
- 消息震动继续后置，不进入当前最小闭环。
