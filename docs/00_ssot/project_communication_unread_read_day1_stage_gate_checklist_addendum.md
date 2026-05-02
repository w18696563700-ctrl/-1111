---
owner: Codex 总控
status: frozen
purpose: Record Day 1 stage gate decision for project communication unread/read semantics.
layer: L0 SSOT
---

# Project Communication Unread And Read Day1 Stage Gate Checklist

## 1. 总裁决

`Conditional Pass`.

Day 1 文书冻结已完成，允许在产品确认后进入 Day 2 Server 派生实现。未获得确认前，不得进入代码实现、不得改云端、不得声称系统通知/震动已支持。

## 2. 本轮目标

冻结站内多层未读与已读真相：

- 消息真值：`ProjectCommunicationMessage`。
- 已读真值：`ProjectCommunicationReadCursor`。
- 未读计数：未读消息条数。
- 清除边界：进入具体项目沟通框并 mark read 成功。
- 系统通知：APNs/FCM/震动暂不开通。

## 3. 本轮范围

| Layer | Scope | Decision |
| --- | --- | --- |
| SSOT | Day 1 truth freeze | Done |
| Contracts | additive field table | Done |
| BFF | route/read-model table | Done |
| Frontend | Flutter page structure table | Done |
| Server code | not in Day 1 | Blocked until confirmation |
| BFF code | not in Day 1 | Blocked until confirmation |
| Flutter code | not in Day 1 | Blocked until confirmation |
| Cloud runtime | not in Day 1 | No runtime mutation |

## 4. 本轮非目标

- 不实现 APNs。
- 不实现 FCM。
- 不实现手机震动。
- 不改 Nginx / systemd / 云配置。
- 不改数据库结构。
- 不改消息业务状态机。
- 不做 generic IM。
- 不把 `app_notifications.readAt` 与 read cursor 合并。

## 5. 子代理派工表

| Role | Day 1 assignment | Actual dispatch |
| --- | --- | --- |
| 总控 Agent | 只读核对、裁决冲突、冻结文书 | Completed by main controller |
| 后端 Agent | 审核 Server truth/read cursor 口径 | Covered by docs; no code dispatch |
| BFF Agent | 审核 app-facing shaping 边界 | Covered by docs; no code dispatch |
| 前端 Agent | 审核 UI 层级和本地状态边界 | Covered by docs; no code dispatch |
| 结果校验 Agent | 检查产物和门禁 | Completed by doc/path verification |

Day 1 未实际开启独立子代理，因为本轮只做文书冻结，拆代理会增加回执噪音；后续 Day 2+ 实现可按 Server/BFF/Flutter 并行派工。

## 6. 执行顺序

1. Gate 0 只读扫描：仓库状态、既有消息/未读文书、现有代码关键词。
2. 冲突裁决：旧口径允许 thread 级 0/1；本轮升级为未读消息条数。
3. Gate 1 文书冻结：新增 L0、L2、L3、L4、门禁表。
4. 不进入 Gate 2 实现。

## 7. 风险点

| Risk | Decision |
| --- | --- |
| 未读消息条数和旧 thread 级计数冲突 | 以本 Day 1 addendum 作为后续实现准入真相；旧 runtime 只能算兼容退化。 |
| 通知中心 readAt 与项目沟通 read cursor 混淆 | 明确二者不是同一真值。 |
| Flutter 本地造红点 | 明确禁止，本轮所有红点源自 Server 派生字段。 |
| 多端登录导致未读被另一端提前清掉 | Day 7 验收必须控制账号窗口并记录。 |
| 系统通知/震动被误认为本轮完成 | 明确 APNs/FCM/震动 No-Go，二阶段另冻。 |

## 8. 验收标准

Day 1 通过标准：

- 明确本轮只做站内多层未读闭环。
- 明确 APNs/FCM/震动暂不开通。
- 明确每个未读字段来源于 read cursor 派生。
- 明确不新增统一业务状态机。
- 明确 `projectId/threadId/organizationId` 必带。
- 明确未读计数口径为未读消息条数。
- 明确 `app_notifications.readAt` 不等于项目沟通 read cursor。

## 9. 实际产出物清单

| Deliverable | Path |
| --- | --- |
| SSOT addendum | `docs/00_ssot/project_communication_unread_read_truth_day1_freeze_addendum.md` |
| contracts 字段表 | `docs/01_contracts/project_communication_unread_read_contract_field_table_day1_addendum.md` |
| BFF route/read-model 表 | `docs/03_bff/project_communication_unread_read_bff_route_read_model_day1_addendum.md` |
| Flutter 页面结构表 | `docs/04_frontend/project_communication_unread_read_flutter_page_structure_day1_addendum.md` |
| 阶段门禁表 | `docs/00_ssot/project_communication_unread_read_day1_stage_gate_checklist_addendum.md` |

## 10. 未完成项与阻塞项

未完成：

- 未改 Server unread projection。
- 未改 BFF read-model。
- 未改 Flutter UI。
- 未做云上探针。
- 未做 Computer Use 双账号验收。
- 未做 APNs/FCM/震动。

阻塞：

- 需要产品确认本 Day 1 字段、状态、边界后，才能进入 Day 2。
- 如果要求本轮必须包含真实手机系统通知和震动，当前 Day 2 计划必须暂停，先补二阶段 APNs/FCM 真相冻结。

## 11. 下一轮建议

建议进入 Day 2 Server 实现，但只允许做：

- `ProjectCommunicationUnreadQueryService` 从 thread 级升级为未读消息条数。
- project/relation/conversation/shell 四层聚合字段。
- read cursor `lastReadMessageId` 校验。
- targeted tests。

不得做：

- APNs/FCM。
- 震动。
- 系统通知权限。
- 新消息状态机。
- 云端部署。
