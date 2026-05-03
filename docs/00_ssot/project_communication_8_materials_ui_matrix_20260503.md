---
owner: Codex 总控
status: frozen
layer: L0 SSOT / Flutter UI matrix
recorded_at_local: 2026-05-03
scope: Project communication 3 entry buttons and bottom sheet UI for 8 material review entries
---

# 项目沟通 8 个资料项 UI Matrix 20260503

## 1. 总裁决

本 UI matrix 裁决为 `PASS`。

允许进入 Flutter 最小 UI 对齐：把项目沟通页工作入口中的资料区收敛为顶部 3 个轻量入口，点击后用 bottom sheet 展示资料项列表。不得把资料主入口放回聊天输入框，不得让 8 个资料项长期平铺污染消息流。

## 2. UI 最小闭环

项目沟通页工作入口保留原有三个业务按钮：

- `进入审核`
- `后续承接状态`
- `项目相册`

资料入口改为 3 个轻量按钮：

- `发布方资料`
- `中间方成交确认`
- `竞标资料`

点击任一入口后打开 bottom sheet，bottom sheet 内只展示当前 `projectId + threadId + bidId` 对应的 entries。

## 3. 三入口映射

| 顶部入口 | 映射 group | entries | 展示方式 | 动作边界 |
| --- | --- | --- | --- | --- |
| `发布方资料` | `publisher_materials` | 5 个发布方资料审阅项 | bottom sheet 列表 | reviewer 可确认/反馈；subject owner 只读 |
| `中间方成交确认` | `deal_confirmation` | `contract_confirmation`、`final_confirmed_amount_confirmation` | bottom sheet 只读列表 | `Reserved / next gate`，不触发真实合同、最终金额或扣费 |
| `竞标资料` | `bid_materials` | 3 个竞标资料审阅项 | bottom sheet 列表 | reviewer 可确认/反馈；subject owner 只读 |

顺序固定为：`发布方资料`、`中间方成交确认`、`竞标资料`。

## 4. Bottom Sheet 结构

每个 bottom sheet 固定展示：

1. 入口标题。
2. 状态标签：按 group 聚合状态显示。
3. 简短说明。
4. 资料项列表。
5. 空态 / 锁态 / 错误态提示。

资料项列表每项展示：

| UI field | 来源 | 规则 |
| --- | --- | --- |
| 名称 | `entry.label` | 不用本地中文重命名覆盖 Server label；本地只做 fallback。 |
| 状态标签 | `reviewState ?? availabilityState` | 使用 matrix 状态映射。 |
| 附件数 | `attachmentCount` / `sourceFiles.length` | 仅展示，不作为确认真值。 |
| 最近反馈 | `latestFeedbackText` | 有则展示；不能作为最新状态唯一来源。 |
| 是否可进入详情 | `availabilityState != unavailable` 或详情可展示空态 | deal entries 只提示 Reserved。 |
| 是否可操作 | `entry.canSubmitReview` | 只由 existing model 派生，不本地创造权限。 |

## 5. 状态展示

| 状态 | 标签 | 颜色 | 说明 |
| --- | --- | --- | --- |
| `unsubmitted` | 未提交 | 灰色 | 不允许确认，不允许反馈。 |
| `pending_review` | 待确认 | 橙色 | 可审阅资料，若当前 viewer 是 reviewer 且 enabled，可动作。 |
| `confirmed` | 已确认 | 绿色 | Server 持久化确认结果。 |
| `needs_supplement` | 需补充 | 鲜红色 | Server 持久化反馈结果。 |
| `unavailable` | 暂不可用 | 灰色 | 不允许动作。 |
| `blocked` | 锁定 | 灰色 | 不允许动作。 |
| `readonly` | 只读 | 灰色 | 可看不可动。 |

## 6. 空态 / 锁态 / 错误态文案

| 场景 | 文案 | 行为 |
| --- | --- | --- |
| workbench loading | `资料入口加载中...` | 禁用 3 个入口。 |
| workbench error | `资料入口暂不可读` | 显示只读错误态，不补假 entry。 |
| group entries 为空 | `当前分组暂无可展示资料` | 不允许动作。 |
| 资料未提交 | `当前资料尚未提交` | 可进入详情空态或直接提示，不允许 confirm / feedback。 |
| 成交确认入口 | `合同确认和最终成交金额确认暂未进入本轮门禁` | 不触发真实动作。 |

## 7. Owner / Counterpart 分支

| Viewer | 发布方资料 | 竞标资料 | 成交确认 |
| --- | --- | --- | --- |
| 发布方 owner | 查看自己资料和对方反馈；不得替竞标方确认。 | 查看竞标方资料；可按 Server 权限确认 / 要求补充。 | 只读 Reserved。 |
| 竞标方 counterpart | 查看发布方资料；可按 Server 权限确认 / 要求补充。 | 查看自己资料和对方反馈；不得替发布方确认。 | 只读 Reserved。 |
| unknown | 只读或不可用 | 只读或不可用 | 只读 Reserved。 |

Flutter 不自行判断谁可确认；只使用 `actionState`、`availabilityState` 和 Server 返回的 entry。

## 8. 聊天区边界

禁止：

- 在聊天输入栏增加资料确认主入口。
- 把 8 项资料卡作为消息流新卡片刷屏。
- 通过聊天 `confirmation_card` 决定资料审阅状态。

允许：

- 历史确认卡继续按历史消息展示。
- 聊天区提示关键资料请在项目工作入口处理。

## 9. Flutter 最小施工范围

允许修改：

- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart`
- 必要时少量调整 `counterpart_conversation_workbench_fold_support.dart`
- 对应 Flutter widget test。

原则上不修改：

- BFF。
- Server。
- Admin。
- contracts / generated types。

如 Flutter 需要新增接口或字段，立即 No-Go。

## 10. 是否允许进入 Flutter 最小 UI 对齐

`允许`。

前提：Flutter 只消费既有 workbench read-model；成交确认入口继续 Reserved；不做部署、重启、migration、写 smoke。
