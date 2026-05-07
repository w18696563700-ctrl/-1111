---
owner: Codex 总控
status: frozen
purpose: Freeze bidder-side quote-basis material confirmation sync between bid submit page and message hub.
layer: L0 SSOT
freeze_scope: Bid submit quote-basis material confirmation UX and gate only
---

# 《竞标提交页报价依据资料确认与消息楼同步 Addendum V1》

## 1. 总裁决

竞标方在提交竞标前，必须先审阅并处理发布方上传的 5 项报价依据资料。

竞标提交页的 `查看报价依据资料` 是真实业务页入口；消息楼 `资料确认` 是快速处理入口。两者必须消费同一套 Server `project_communication` / `material review` 真值，不得各自维护状态。

本 Addendum 只冻结竞标提交页与消息楼之间的资料确认同步口径；不修改项目创建到发布主链路，不修改上传三步流，不扩展支付、预授权、BidAward、Order / Contract seed、最终合同金额确认。

## 2. 5 项资料范围

| 顺序 | entryKey | attachmentKind | 展示名 | 真值 owner |
|---:|---|---|---|---|
| 1 | `publisher_effect_image_review` | `effect_image` | 效果图 | Server |
| 2 | `publisher_construction_doc_review` | `construction_doc` | 尺寸图 / 施工图 | Server |
| 3 | `publisher_material_sample_review` | `material_sample` | 材质图 / 材料样板 | Server |
| 4 | `publisher_equipment_material_list_review` | `equipment_material_list` | 设备物料清单 | Server |
| 5 | `publisher_service_list_review` | `service_list` | 服务清单 | Server |

## 3. 竞标提交前置门禁

竞标提交前置门禁只覆盖“发布方已提交且当前账号可读”的报价依据资料。

| 状态 | 是否阻断竞标提交 | 说明 |
|---|---:|---|
| `pending_review` | 是 | 竞标方必须先进入确认页预览并确认无误，或要求发布方补充。 |
| `confirmed` | 否 | Server 已持久化确认结果，可继续提交竞标。 |
| `needs_supplement` | 是 | 当前资料仍需发布方补充，不能继续提交竞标。 |
| `unsubmitted` | 否 | 不在本 Addendum 中补改上游发布必传规则；是否必传由既有发布门禁决定。 |
| `unavailable` | 是 | 当前不可读时不能让 Flutter 本地放行。 |

本门禁不替代报价字段合法性、竞标方参与资格、项目可竞标、三份竞标附件 confirmed、权限和重复提交保护等 Server 校验。

## 4. 交互规则

1. `查看报价依据资料` 区域必须展示 5 项资料的确认状态。
2. 点击单项资料必须进入同一套资料确认详情页，预览后才能确认。
3. 确认成功后，竞标提交页与消息楼对应项都必须以 Server 返回状态变绿。
4. 预览失败不得显示为已预览，不得开放确认按钮。
5. Flutter 不得根据文件存在、本地点击或本地缓存把资料伪造成 `confirmed`。
6. 若缺少 `projectId` / `threadId` / `entryKey` / `sourceVersionToken` 等 Server review 上下文，必须提示入口暂不可用并阻断提交，不得本地绕过。

## 5. 分层边界

| 层级 | 裁决 |
|---|---|
| Server | 持有资料、确认状态、补充反馈、提交门禁的业务真值。 |
| BFF | 透出 workbench entries、routeTarget、sourceFiles、reviewState，不创造确认状态。 |
| Flutter | 展示、预览、跳转、提交动作、刷新状态；不持有确认真值。 |
| OpenAPI | 本轮优先不新增字段或路径。 |
| generated | OpenAPI 不变时不生成。 |
| 云端 | 本轮优先不部署；若发现 BFF / Server runtime 缺字段，再单独申请。 |

## 6. No-Go

本轮不得：

- 把竞标提交页 5 项确认做成 Flutter 本地状态。
- 用消息楼聊天内容替代资料确认。
- 因资料确认引入支付、钱包、服务费扣费、保证金、结算或发票。
- 改项目创建页、草稿编辑页、预发布补资料页、发布确认页。
- 改 FileAsset / Evidence / ProjectAttachment 真值归属。
- 改最终合同金额确认主路径。

## 7. 四类判断

| 判断项 | 裁决 |
|---|---|
| 最稳 | 竞标提交页复用消息楼 workbench material review 真值与命令。 |
| 最省成本 | 不扩 OpenAPI，不改 Server / BFF，只在 Flutter 增加读取、展示和调用。 |
| 最适合当前阶段 | 先关闭“没确认报价依据也能报价”的 P0 漏洞，再用真机验证。 |
| 风险最大 | Flutter 本地确认、竞标提交绕过 Server review 真值，导致消息楼和真实业务页状态漂移。 |
