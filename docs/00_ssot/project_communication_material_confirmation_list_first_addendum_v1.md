---
owner: Codex 总控
status: frozen
purpose: Freeze the list-first interaction for project communication material confirmations.
layer: L0 SSOT
freeze_scope: Project communication material confirmation entry UX only
---

# 《项目沟通资料确认清单优先交互 Addendum V1》

## 1. 总裁决

资料确认入口必须先展示资料确认清单，不得直接跳转到第一条 `pending_review` 明细。

本 Addendum 只 supersede 既有 Flutter 入口中的“资料确认按钮直达第一条待确认资料”交互；不推翻项目沟通工作台 10 入口、5 个发布方报价依据资料、3 个竞标资料、BidAward、Order / Contract seed、最终合同金额、支付或预授权门禁口径。

## 2. 当前最小闭环

工厂方 / 竞标方在项目沟通中点击 `资料确认` 后，必须先看到发布方上传的 5 项资料清单：

| 顺序 | entryKey | 展示名 | 真值来源 | 默认状态 |
|---:|---|---|---|---|
| 1 | `publisher_effect_image_review` | 效果图确认 | Server `FileAsset` / `ProjectAttachment` | 待确认 / 已确认 / 需补充 / 未提交 |
| 2 | `publisher_construction_doc_review` | 尺寸图 / 施工图确认 | Server `FileAsset` / `ProjectAttachment` | 待确认 / 已确认 / 需补充 / 未提交 |
| 3 | `publisher_material_sample_review` | 材质图 / 材料样板确认 | Server `FileAsset` / `ProjectAttachment` | 待确认 / 已确认 / 需补充 / 未提交 |
| 4 | `publisher_equipment_material_list_review` | 设备物料清单确认 | Server `FileAsset` / `ProjectAttachment` | 待确认 / 已确认 / 需补充 / 未提交 |
| 5 | `publisher_service_list_review` | 服务清单确认 | Server `FileAsset` / `ProjectAttachment` | 待确认 / 已确认 / 需补充 / 未提交 |

用户在清单中选择某一项后，才能进入对应确认页进行 App 内预览、审阅、确认无误或要求补充。

## 3. 状态与颜色

| 状态 | 展示文案 | 颜色 | 含义 |
|---|---|---|---|
| `pending_review` | 待确认 | 黄色 / 提醒色 | 文件已存在，等待当前角色审阅确认。 |
| `confirmed` | 已确认 | 绿色 | Server 已持久化确认结果。 |
| `needs_supplement` | 需补充 | 红色 | Server 已持久化补充反馈。 |
| `unsubmitted` | 未提交 | 灰色 | 对应资料尚未提交或当前不可读。 |

`confirmed` 只能来自 Server / BFF projection，不得由 Flutter 根据“文件存在”或本地点击直接伪造。

## 4. 点击与确认规则

1. `资料确认` 入口只负责打开资料清单。
2. 清单中的单项资料负责打开确认详情页。
3. 确认详情页必须先提供资料预览入口。
4. 未完成预览前，`确认无误` 必须禁用或弱化。
5. 提交确认成功后，清单状态必须刷新，并以 Server 返回结果变绿。
6. 要求补充成功后，清单状态必须刷新，并以 Server 返回结果变红。
7. 未提交资料可展示但不可被当作已确认。

## 5. 分层边界

| 层级 | 本 Addendum 裁决 |
|---|---|
| Server | 继续作为资料、确认状态、反馈结果的业务真值 owner。 |
| BFF | 继续透出 workbench entries、routeTarget、sourceFiles、reviewState，不创造业务状态。 |
| Flutter | 只做清单展示、预览、点击跳转、提交动作和刷新展示。 |
| OpenAPI | 本轮不新增字段或路径。 |
| generated | 本轮不生成。 |
| 云端 | 本轮不部署；真机只消费当前云端 BFF / Server runtime。 |

## 6. No-Go

本轮不得：

- 把资料确认清单做成新的 IM。
- 用聊天内容替代资料确认。
- 用资料确认替代最终合同金额确认。
- 让 Flutter 本地保存确认真值。
- 让 BFF 根据文件名、中文标题或本地状态推断 `confirmed`。
- 改支付、预授权、服务费、保证金、结算、发票、钱包。

## 7. 四类判断

| 判断项 | 裁决 |
|---|---|
| 最稳 | Server 继续持有资料确认真值，Flutter 只改清单优先和详情展示。 |
| 最省成本 | 不改 OpenAPI / generated / BFF / Server，只修 Flutter 入口和 UI。 |
| 最适合当前阶段 | 小 SSOT 冻结后做 Flutter 最小闭环，再用真机 UAT 验证。 |
| 风险最大 | 继续直达第一条 pending 或在 Flutter 本地伪造绿色已确认。 |
