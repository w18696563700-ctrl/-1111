---
owner: Codex 总控
status: frozen
purpose: >
  Freeze Day 2 Flutter construction plan for splitting project communication
  workbench entries by publisher and bidder views.
layer: L5 Frontend
freeze_scope: Day 2 structure plan only
inputs_canonical:
  - docs/00_ssot/project_communication_workbench_role_split_rework_day1_freeze_addendum.md
---

# 《项目沟通工作入口角色分流返工 Day 2 Flutter 施工图》

## 1. 总裁决

第 2 天裁决为 `Conditional Pass`。

允许进入第 3 天 Flutter-only 最小纠偏实现。

实施边界：

- 只修正项目工作入口的角色分流和点击反馈。
- 不改 BFF / Server / contracts / 云端。
- 不把确认主入口放回聊天输入栏。
- 不把 Flutter 本地绿色态写成 Server 业务真值。

## 2. 当前错误实现定位

当前错误位于 `项目工作入口` 总容器：

- `_SelectedProjectBusinessEntrypoints` 无条件渲染 `_ProjectMaterialConfirmationSection`。
- `_ProjectMaterialConfirmationSection` 固定展示五份资料。
- 因此 `my_published` 发布方和 `my_bid` 竞标方都显示五份资料。

第 3 天必须拆除该通用渲染，改为按 `group.projectRelation` 分流。

## 3. 新组件分流

第 3 天组件结构冻结为：

- `_SelectedProjectBusinessEntrypoints`
  - 继续作为项目工作入口总容器。
  - 保留 `返回项目列表`。
  - 保留 `进入审核 / 后续承接状态 / 项目相册`。
  - 根据 `group.projectRelation` 决定渲染哪个固定区。
- `_PublisherConfirmationSection`
  - 仅用于 `my_published` 发布方视角。
  - 显示 3 个确认按钮。
- `_BidderMaterialSection`
  - 仅用于 `my_bid` 竞标方视角。
  - 显示 5 份资料入口。
- `_WorkbenchStatusTile`
  - 可复用单个按钮 / 资料入口视觉。
  - 支持状态小标签和绿色确认态。

命名说明：

- 组件内部可用英文职责名。
- 面向用户的 UI 不得出现 `PublisherConfirmationSection` 或 `BidderMaterialSection`。

## 4. 发布方视角 UI

触发条件：

- `group.projectRelation.trim() == 'my_published'`

展示标题：

- `确认事项`

固定按钮：

- `报价确认`
- `排期确认`
- `工艺材质确认`

按钮状态：

| 状态 | 展示 | 触发来源 |
| --- | --- | --- |
| `待确认` | 主色 / 提醒色 | 初始默认态 |
| `已确认` | 绿色 | 本轮 Flutter 本地点击后的页面内状态 |
| `暂不可读` | 灰色弱化 | 当前项目关系未知或页面状态不可判断 |

点击行为：

- 点击 `待确认`：当前页面内切换为 `已确认`，按钮变绿色，并提示 `已确认。`
- 点击 `已确认`：保持绿色，并提示 `已确认。`
- 点击 `暂不可读`：提示 `当前确认状态暂不可读。`

重要边界：

- 本轮绿色 `已确认` 是 Flutter 页面内反馈态。
- 页面重载、切换项目或重新进入后不保证保持。
- 不写入 BFF / Server，不生成审计，不作为业务真值。

## 5. 竞标方视角 UI

触发条件：

- `group.projectRelation.trim() == 'my_bid'`

展示标题：

- `资料`

固定入口：

- `效果图`
- `材质图`
- `尺寸图`
- `设备物料清单`
- `服务清单`

状态口径：

| 状态 | 展示 | 来源 |
| --- | --- | --- |
| `未提交` | 灰色弱化 | 对应 `attachmentKind` 缺失 |
| `待查看` | 主色 / 提醒色 | 对应 `attachmentKind` 存在 |
| `暂不可读` | 灰色弱化 | 读取失败、权限不足、接口不可解析 |

本轮竞标方资料入口不用 `确认` 后缀，避免和发布方三项确认混淆。

点击行为：

- `未提交`：提示 `当前资料暂未提交。`
- `待查看`：提示 `当前仅支持核对资料，正式确认状态待后续合同冻结。`
- `暂不可读`：提示 `资料状态暂不可读。`

## 6. 未知视角 UI

触发条件：

- `group.projectRelation` 既不是 `my_published`，也不是 `my_bid`。

展示：

- 保留原有三个入口。
- 固定区显示受控提示：`当前项目工作入口暂不可读`
- 不展示三项确认。
- 不展示五份资料。

## 7. 布局规则

通用规则：

- 仍在 `项目工作入口` 内展示。
- 工作台大段介绍文案继续压缩。
- 不新增卡片套卡片。
- 按钮高度稳定，状态切换不引发布局跳动。
- 窄屏下允许单列或两列自适应。

发布方三项：

- 两列布局可用时，前两个并排，第三个可跨整行或单独成行。
- 文案必须完整可读。

竞标方五项：

- 两列布局可用时，短项并排，`设备物料清单` 可跨整行。
- 文案必须完整可读。

## 8. 底部输入栏

底部输入栏继续只保留：

- `附件`
- `图片`
- 文本输入框
- 发送按钮

不得恢复：

- `确认`
- `发送确认卡`
- 五份资料或三项确认的聊天输入入口

## 9. 测试点清单

第 3 天必须补充或改造 widget test：

1. 发布方视角：
   - `projectRelation = my_published`
   - 显示 `报价确认 / 排期确认 / 工艺材质确认`
   - 不显示 `效果图 / 材质图 / 尺寸图 / 设备物料清单 / 服务清单`
   - 点击 `报价确认` 后出现 `已确认`
2. 竞标方视角：
   - `projectRelation = my_bid`
   - 显示 `效果图 / 材质图 / 尺寸图 / 设备物料清单 / 服务清单`
   - 不显示 `报价确认 / 排期确认 / 工艺材质确认`
3. 聊天输入栏：
   - 不显示底部 `确认` 按钮。
   - 不显示 `发送确认卡`。
   - 点击固定区不产生 project-communication message POST。
4. 窄屏：
   - 发布方三项无布局异常。
   - 竞标方五项无布局异常。

## 10. 允许触碰文件

第 3 天允许触碰：

- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_material_confirmation_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/counterpart_conversation_material_confirmation_support.dart`
- `apps/mobile/test/project_communication_five_material_confirmation_entry_test.dart`

第 3 天默认不触碰：

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- `packages/contracts/**`

## 11. 第 3 天准入

允许进入第 3 天。

准入条件已满足：

- 分流字段存在：`projectRelation`。
- 发布方与竞标方 UI 名称已冻结。
- 本轮不要求真实持久化 `已确认`。
- 本轮不需要新增云端字段。

第 3 天若发现必须新增 BFF / Server 字段才能完成基本分流，应立即停机并输出 `No-Go`。
