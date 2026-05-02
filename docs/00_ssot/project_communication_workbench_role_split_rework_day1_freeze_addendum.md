---
owner: Codex 总控
status: frozen
purpose: >
  Freeze Day 1 rework truth and boundary for splitting project communication
  workbench entries by publisher and bidder views.
layer: L0 SSOT
freeze_scope: Day 1 role-split rework boundary only
inputs_canonical:
  - docs/00_ssot/project_communication_five_material_confirmation_entry_min_loop_day1_freeze_addendum.md
  - docs/04_frontend/project_communication_five_material_confirmation_entry_day2_flutter_structure_addendum.md
  - docs/00_ssot/project_communication_five_material_confirmation_entry_day6_computer_use_visual_receipt_addendum.md
---

# 《项目沟通工作入口角色分流返工冻结单》

## 1. 总裁决

第 1 天裁决为 `Conditional Pass`。

允许进入第 2 天 Flutter UI 施工图，但不得直接把“发布方”和“竞标方”继续共用同一组五份资料入口。

当前错误冻结为：

- 发布方页面显示了五份资料入口。
- 竞标方页面也显示了五份资料入口。
- 这与产品口径不一致，必须返工为角色分流。

## 2. 当前最小闭环

本轮最小闭环只修正 `项目工作入口` 的展示分流：

- 发布方视角显示 3 个确认按钮。
- 竞标方视角显示 5 份资料入口。
- 底部聊天输入栏不恢复 `确认` 主入口。
- 不新增 BFF / Server 字段。
- 不新增后端状态机。
- 不修改云端。

## 3. 角色分流口径

页面分流以当前项目关系 `projectRelation` 为前端最小闭环判断依据：

| `projectRelation` | 当前视角 | 项目工作入口固定区 |
| --- | --- | --- |
| `my_published` | 发布方视角 | 3 个确认按钮 |
| `my_bid` | 竞标方视角 | 5 份资料入口 |
| 其他 / 缺失 | 未知视角 | 显示受控不可读提示，不猜测 |

该判断仅用于 Flutter 展示分流，不创建新的业务真值。

## 4. 发布方视角冻结

发布方视角不得展示五份资料入口。

发布方固定显示 3 个确认按钮：

- `报价确认`
- `排期确认`
- `工艺材质确认`

统一使用以上展示名，不再同时展示第二套名称：

- 不展示 `报价表确认`。
- 不展示 `进度安排确认`。
- 不展示 `项目理解确认`。

三项确认与资料含义的产品映射仅作为内部理解：

| 统一展示名 | 对应资料 |
| --- | --- |
| `报价确认` | 报价表 |
| `排期确认` | 进度安排 |
| `工艺材质确认` | 项目理解 |

## 5. 竞标方视角冻结

竞标方视角不得展示发布方三项确认。

竞标方固定显示 5 份资料入口：

- `效果图`
- `材质图`
- `尺寸图`
- `设备物料清单`
- `服务清单`

竞标方资料入口本轮不再统一加 `确认` 后缀，避免和发布方的三项确认混淆。

## 6. 聊天输入栏边界

本轮继续冻结：

- 确认主入口不得回到底部聊天输入栏。
- 底部输入栏只保留沟通输入能力：
  - `附件`
  - `图片`
  - 文本输入框
  - 发送按钮
- 历史 `confirmation_card` 只允许兼容读回，不作为本轮新主入口。

## 7. Contract / BFF / Server 结论

第 1 天结论：本轮返工不要求新增 contract 字段。

原因：

- 当前 Flutter 项目组模型已有 `projectRelation`，可区分 `my_published` 与 `my_bid`。
- 当前问题是前端展示分流错误，不是云端 active runtime 缺字段。
- 发布方三项确认的真实持久化状态当前未冻结，本轮不能由 Flutter 伪造为 Server 真值。

本轮不改：

- `docs/01_contracts/**`
- `packages/contracts/**`
- `apps/bff/**`
- `apps/server/**`
- 云端数据库、Nginx、systemd、release 指针

## 8. 需要保留但暂不开通

以下能力保留为后续扩展位，本轮暂不开通：

- 发布方三项确认的 Server 持久化。
- 确认人、确认时间、组织身份、审计。
- 竞标方五份资料逐项确认状态。
- 资料更新后自动失效并重新待确认。
- Admin 争议核验。
- BFF 聚合确认状态字段。

## 9. 后续扩展位

若后续要求“点击后变绿并长期有效”，必须另起 Gate 1，冻结：

- 发布方三项确认对象。
- 竞标方资料对象。
- `confirmationState` 枚举。
- `confirmedByOrganizationId` / `confirmedByUserId`。
- `confirmedAt`。
- 资料变更后的确认失效规则。
- Server 审计与争议读取边界。

## 10. 第 2 天准入

允许进入第 2 天 Flutter UI 施工图。

准入条件已满足：

- 现有 `projectRelation` 可作为 Flutter-only 最小分流依据。
- 发布方 / 竞标方展示边界已冻结。
- 本轮不需要立即改 BFF / Server / contracts。

第 2 天不得做：

- Flutter 代码实现。
- BFF / Server 修改。
- contracts 修改。
- 云端写操作。
- 数据库结构、迁移、部署、服务重启。

## 11. 风险点

已确认风险：

- `projectRelation` 是前端读模型字段，本轮仅用作展示分流，不可升级为完整业务状态机。
- 发布方三项确认当前缺少正式持久化状态，绿色 `已确认` 只能在后续合同真值存在后成为业务真值。
- 当前工作区存在本任务外 BFF / Server / messages / shell 脏改，本轮不归属、不回退、不清理。

## 12. 四类判断

- 最稳：冻结 contracts 后由 Server 持久化三项确认和五份资料确认状态。
- 最低成本：本轮只做 Flutter `projectRelation` 展示分流纠偏。
- 最适合当前阶段：先把发布方和竞标方页面显示错误修正，不扩大到后端状态机。
- 风险最大：继续让发布方/竞标方共用五份资料入口，或未经 contracts 冻结直接改 BFF / Server。
