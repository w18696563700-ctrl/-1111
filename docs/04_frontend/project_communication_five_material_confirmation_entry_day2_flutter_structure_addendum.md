---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day 2 Flutter page-structure construction plan for the five
  quote-basis material confirmation entries in the project communication page.
layer: L5 Frontend
freeze_scope: Day 2 structure plan only
inputs_canonical:
  - docs/00_ssot/project_communication_five_material_confirmation_entry_min_loop_day1_freeze_addendum.md
  - docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md
  - docs/04_frontend/quote_basis_material_package_v1_frontend_surface_addendum.md
---

# 《项目沟通五类资料确认入口 Day 2 Flutter 施工图》

## 1. 总裁决

Day 2 裁决为 `Conditional Pass`。

允许进入第 3 天 Flutter 最小闭环实现的前提是：

- 只实现页面固定入口、状态展示、点击反馈和只读资料入口。
- 不把 `已上传` 冒充 `已确认`。
- 不在 Flutter 发明五类资料确认真值。
- 不修改 BFF / Server / contracts / 云端。

若第 3 天目标要求“点击确认后云端持久变绿”，则 Day 3 必须 `No-Go`，先回到 contracts / BFF / Server 阶段冻结和实现五类资料确认真值。

## 2. 本轮目标

把项目沟通页的 `项目工作入口` 从说明型入口改成更明确的工作区：

1. 原有能力继续保留。
2. 新增 `资料确认` 固定按钮区。
3. 聊天区只承接沟通记录，不再把五类资料确认作为底部输入栏主操作。

## 3. 页面结构

选中具体项目后的页面顺序固定为：

1. `当前项目沟通` 卡片。
2. `项目工作入口` 卡片。
3. 平台倡议提示条。
4. `项目沟通记录`。
5. 底部输入栏。

`项目工作入口` 内部顺序固定为：

1. 低强调 `返回项目列表`。
2. 原有三个业务入口：
   - `进入审核`
   - `后续承接状态`
   - `项目相册`
3. `资料确认` 固定区。
4. 必要的状态说明，不超过一行。

原 `项目工作入口` 说明文字需要压缩：

- 有参与竞标申请时：保留申请主体摘要。
- 无参与竞标申请时：不再显示大段说明，只保留必要空态。

## 4. 资料确认按钮

按钮展示名固定为：

- `效果图确认`
- `材质图确认`
- `尺寸图确认`
- `设备物料清单确认`
- `服务清单确认`

按钮对应资料枚举固定为：

| 展示名 | attachmentKind |
| --- | --- |
| `效果图确认` | `effect_image` |
| `材质图确认` | `material_sample` |
| `尺寸图确认` | `construction_doc` |
| `设备物料清单确认` | `equipment_material_list` |
| `服务清单确认` | `service_list` |

前台不得展示第二套名称：

- 不展示 `材质图 / 材料样板确认`。
- 不展示 `尺寸图 / 施工图确认`。
- 不展示 `报价依据资料确认` 作为第六个按钮。

## 5. 布局规则

`资料确认` 区建议采用响应式按钮网格：

- 宽度足够时使用两列。
- 窄屏时允许单列。
- `设备物料清单确认` 允许跨两列或单独成行，优先保证文字完整。
- 按钮高度固定，避免状态变化导致布局跳动。
- 每个按钮包含：
  - 左侧图标。
  - 主标题。
  - 状态小标签。

不得使用大面积说明卡片、营销式文案或装饰性背景。

## 6. 状态口径

按钮状态只允许以下三种：

| 状态 | 展示 | 来源规则 |
| --- | --- | --- |
| `未提交` | 中性灰 / 禁用弱化 | 对应 `attachmentKind` 没有可读资料 |
| `待确认` | 主色或提醒色 | 对应 `attachmentKind` 有可读资料，但没有正式已确认真值 |
| `已确认` | 绿色 | 仅来自已冻结合同字段或既有读模型明确返回的已确认语义 |

当前 contracts 没有五类资料逐项确认状态字段，因此第 3 天 Flutter 最小实现默认只能稳定表达：

- `未提交`
- `待确认`

`已确认` 视觉样式可以先完成，但不得在生产逻辑中由 Flutter 自行写入。

## 7. 点击行为

`未提交`：

- 不进入确认。
- Toast / Snack 文案：`当前资料暂未提交。`

`待确认`：

- 进入该类型资料的只读详情或现有受控预览入口。
- 若当前只读资料入口不可用，Toast / Snack 文案：`当前资料暂不可查看，请稍后再试。`
- 不得在无 Server 真值时点击后直接改为绿色。

`已确认`：

- 进入该类型资料的只读详情。
- 若后续合同提供确认记录，可展示确认人和确认时间。

## 8. 数据来源施工图

第 3 天前端最小闭环可选择以下只读来源，不新增接口：

### 8.1 当前用户为接单方 / 竞标方

优先读取：

- `GET /api/app/project/bid-materials?projectId={projectId}`

用途：

- 根据返回的 `attachments[].attachmentKind` 判断五类资料是否存在。
- 存在则显示 `待确认`。
- 缺失则显示 `未提交`。

### 8.2 当前用户为发布方

仅在现有 Flutter consumer 已有 owner 私域附件读取能力时读取：

- `GET /api/app/my/projects/{projectId}/attachments`

用途：

- 根据 owner 私域附件列表判断五类资料是否存在。
- 存在则显示 `待确认`。
- 缺失则显示 `未提交`。

如果第 3 天无法在不新增 contracts / BFF / Server 的前提下安全接入 owner 私域附件读取，则发布方视角必须显示区级提示 `资料状态暂不可读`，不得复用竞标方 `bid-materials` 权限错误结果冒充资料缺失。

### 8.3 无法读取时

如果当前项目关系、权限或接口状态无法判断：

- 保留五个按钮。
- 展示区级提示 `资料状态暂不可读`。
- 五个按钮进入弱化不可办理态。
- 不允许把错误吞掉后显示 `已确认`。
- 不允许把 403 / 404 / parse drift / 旧运行时缺字段统一降级成 `未提交`。

## 9. 组件拆分

第 3 天推荐最小组件拆分：

- `_SelectedProjectBusinessEntrypoints`
  - 保留为项目工作入口总容器。
- `_ProjectMaterialConfirmationGrid`
  - 新增资料确认按钮区。
- `_ProjectMaterialConfirmationButton`
  - 新增单个按钮。
- `_ProjectMaterialConfirmationItem`
  - 新增页面内展示模型，仅用于 Flutter 展示。

展示模型建议字段：

```dart
final class ProjectMaterialConfirmationItem {
  const ProjectMaterialConfirmationItem({
    required this.attachmentKind,
    required this.label,
    required this.state,
    required this.enabled,
  });

  final String attachmentKind;
  final String label;
  final String state; // unsubmitted | pending | confirmed
  final bool enabled;
}
```

该模型只用于 Flutter 页面展示，不得写成合同真值。

实现落点建议：

- 新增 `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_material_confirmation_widgets.dart`，只放资料确认 UI。
- 新增 `apps/mobile/lib/features/exhibition/presentation/presentation_support/counterpart_conversation_material_confirmation_support.dart`，只放五类资料定义、状态 mapper 和按 `attachmentKind` 分组逻辑。
- 在 `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart` 注册新增 `part`。
- 避免继续把大量新 UI 塞进已有超长 `counterpart_conversation_widgets.dart`。

## 10. 底部输入栏收敛

底部输入栏继续保留：

- `附件`
- `图片`
- 文本输入
- 发送按钮

第 3 天最小闭环应移除或隐藏底部 `确认` 主按钮。

旧 `confirmation_card` 历史消息仍可读回和展示，但不得作为五类资料确认的主入口。

`项目沟通记录` summary 建议改为：

> 消息与附件继续锚定当前项目，关键资料确认请在项目工作入口处理。

空态文案建议改为：

> 可以从底部输入框发送第一条项目沟通消息。

## 11. 涉及文件范围

Day 3 允许触碰的 Flutter 文件范围：

- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_material_confirmation_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/counterpart_conversation_material_confirmation_support.dart`
- `apps/mobile/test/project_communication_five_material_confirmation_entry_test.dart`
- `apps/mobile/test/project_communication_five_material_confirmation_boundary_test.dart`

若第 3 天需要接入只读资料列表，还允许在总控确认后触碰：

- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/project_bid_material_load_service.dart`

第 3 天默认不建议触碰：

- `apps/mobile/lib/features/messages/data/counterpart_conversation_models.dart`
- `apps/mobile/lib/features/messages/data/counterpart_conversation_parser.dart`
- `apps/mobile/lib/features/messages/data/messages_interaction_models.dart`
- `apps/mobile/lib/features/messages/data/messages_interaction_parser.dart`

Day 3 默认不得触碰：

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- `packages/contracts/**`

## 12. 验收标准

页面结构验收：

- 五个按钮固定可见。
- 原有 `进入审核`、`后续承接状态`、`项目相册` 不丢失。
- `项目工作入口` 介绍文字明显减少。
- `资料确认` 在聊天记录之前。
- 底部输入栏不再作为五类资料确认主入口。

状态验收：

- 无资料显示 `未提交`。
- 有资料但无确认真值显示 `待确认`。
- 只有正式真值存在时才显示 `已确认` 绿色。

边界验收：

- Flutter 不调用 Server 直连。
- 不新增 DTO 合同字段。
- 不改 BFF / Server。
- 不把本地 BFF / Server 当云端 active runtime。

## 13. 风险点

- 当前工作区已有既存脏改，且覆盖 Day 3 可能要改的 Flutter 文件。
- 当前合同没有五类资料独立确认状态，不能实现真实持久 `已确认`。
- 复用 bid-materials 只读接口时，发布方和接单方的权限边界不同，必须按 `projectRelation` 区分。
- 如果继续保留底部 `确认` 主按钮，会和本次固定入口口径冲突。

## 14. 是否允许进入第 3 天

允许进入第 3 天的条件：

- 用户确认采用“Flutter 最小闭环，不做真实持久确认状态”。
- Day 3 实现只做固定入口、资料存在性状态和底部输入栏收敛。
- 先隔离或确认当前脏改归属。

不允许进入第 3 天的条件：

- 要求点击后真实持久变绿。
- 要求记录确认人、确认时间、确认历史。
- 要求确认状态跨端同步。

上述任一需求出现时，必须先进入 contracts / BFF / Server 阶段。

## 15. 四类判断

- 更稳：新增 Server-owned 五类资料确认真值，再由 BFF 聚合给 Flutter。
- 更省成本：第 3 天只做 Flutter 固定入口和 `未提交 / 待确认` 展示。
- 更适合当前阶段：先完成固定入口和聊天输入区收敛，避免继续把资料确认塞进聊天操作。
- 风险更大：让 Flutter 点击后本地改绿，或把 `已上传` 当作 `已确认`。
