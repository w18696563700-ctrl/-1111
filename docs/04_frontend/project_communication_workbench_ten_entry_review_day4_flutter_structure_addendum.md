---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter construction plan for the project communication workbench 10-entry review surface and 8 material detail pages.
layer: L5 Frontend
freeze_scope: Flutter UI construction plan only; no Flutter code, BFF code, Server code, contract mutation, or cloud change in this day.
inputs_canonical:
  - docs/00_ssot/project_communication_workbench_ten_entry_review_day1_freeze_addendum.md
  - docs/01_contracts/project_communication_workbench_ten_entry_review_contract_field_table_day2_addendum.md
  - docs/02_backend/project_communication_workbench_ten_entry_review_server_truth_day3_addendum.md
  - docs/03_bff/project_communication_workbench_ten_entry_review_bff_route_read_model_day2_addendum.md
---

# Project Communication Workbench 10 Entry Review Day4 Flutter Structure Addendum

## 1. 总裁决

`Conditional Pass` for Day 4 Flutter UI 施工图。

本施工图冻结 Flutter 侧怎么呈现 10 个入口、8 个资料详情页、确认按钮和反馈表单。Day 4 不写代码，不改接口，不改 Server/BFF，不动云端。

允许进入 Day 5 Server 实现的条件：

- Flutter UI 明确消费 BFF read-model，不造状态真值。
- 10 个入口固定、分组清晰、双角色都可见。
- 8 个资料详情页能承接真实附件预览、确认、反馈。
- 旧聊天确认入口不恢复。
- 不继续把大段新逻辑堆进既有超长页面文件。

## 2. Current Frontend Finding

当前 Flutter 已有旧口径实现：

- 发布方视角只显示 3 个旧确认：`报价确认 / 排期确认 / 工艺材质确认`。
- 竞标方视角只显示 5 个资料：`效果图 / 材质图 / 尺寸图 / 设备物料清单 / 服务清单`。
- 现有点击以页面内提示 / 局部状态为主，不能作为 Server 真值。
- `counterpart_conversation_page.dart`、`counterpart_conversation_widgets.dart`、`counterpart_conversation_chat_widgets.dart` 已明显超长，Day 7 不允许继续在这些文件内堆大块业务逻辑。

Day 7 必须从旧 3+5 角色分流，改成双角色都看 10 入口、详情页按角色分流。

## 3. Workbench Group Layout

项目工作入口保留原有功能：

- `返回项目列表`
- `进入审核`
- `后续承接状态`
- `项目相册`

工作入口介绍文字压缩为一句：

```text
围绕当前项目完成资料审阅、合同与成交金额确认。
```

新增 10 入口固定区，分为三组：

| Group | Entries | Layout |
| --- | --- | --- |
| `发布方资料` | 5 个发布方报价依据资料确认 | 两列网格；长项可跨整行。 |
| `竞标资料` | 3 个竞标提交资料确认 | 两列网格；窄屏单列兜底。 |
| `成交确认` | 合同确认、最终成交金额确认 | 两列网格；风险状态明显区分。 |

双角色展示规则：

- 发布方和竞标方都显示 10 个入口。
- 入口名称、顺序、状态颜色完全一致。
- 点击进入后的页面动作按 `viewerRole + subjectOwnerRole + actionState` 分流。

## 4. Entry Order And Labels

Flutter 必须使用 BFF read-model 的 `entryKey` 和 canonical `label`，不得继续使用旧中文常量兜底。

固定顺序：

| Order | entryKey | Flutter label |
| --- | --- | --- |
| 1 | `publisher_effect_image_review` | `效果图确认` |
| 2 | `publisher_construction_doc_review` | `尺寸图 / 施工图确认` |
| 3 | `publisher_material_sample_review` | `材质图 / 材料样板确认` |
| 4 | `publisher_equipment_material_list_review` | `设备物料清单确认` |
| 5 | `publisher_service_list_review` | `服务清单确认` |
| 6 | `bid_project_understanding_review` | `项目理解确认` |
| 7 | `bid_quote_sheet_review` | `报价表确认` |
| 8 | `bid_schedule_plan_review` | `进度安排确认` |
| 9 | `contract_confirmation` | `合同确认` |
| 10 | `final_confirmed_amount_confirmation` | `最终成交金额确认` |

必须废止的正式入口名：

- `报价确认`
- `排期确认`
- `工艺材质确认`

这些旧文案只允许出现在历史消息或兼容测试说明中，不得作为新工作台入口。

## 5. State Visuals

入口状态由 BFF/Server read-model 透出，Flutter 只渲染。

| reviewState / availability | Chinese | Color | Click behavior |
| --- | --- | --- | --- |
| `unsubmitted` | `未提交` | gray | 进入详情页只读，显示缺失说明；不能确认。 |
| `pending_review` | `待确认` | orange | 进入详情页，可查看资料；有权限者可确认或反馈。 |
| `confirmed` | `已确认` | green | 进入只读或可复核详情；不重复造本地绿色态。 |
| `needs_supplement` | `需补充` | red | 进入详情页展示反馈；资料拥有方看到补充提示。 |
| `unavailable` / `blocked` | `暂不可读` | neutral gray | 展示受控不可用提示。 |

视觉规则：

- 绿色只代表 Server 已确认。
- 鲜红只代表 Server 已持久化 `needs_supplement`。
- `attachmentCount > 0` 只能影响附件数量展示，不能变成 `已确认`。
- 状态切换后必须刷新 workbench read-model。

## 6. Material Detail Pages

8 个资料入口复用同一个详情页骨架：

```text
ProjectCommunicationMaterialReviewDetailPage
```

详情页结构：

- 顶部：返回、资料确认标题、状态 pill。
- 资料区：真实附件列表 / 预览入口 / 文件名 / 文件类型 / 更新时间或提交时间。
- 审阅说明区：显示当前资料来源和双方角色。
- 操作区：
  - `确认无误`
  - `需要补充`
  - 反馈原因快捷项
  - 反馈文本框
  - 提交反馈
- 历史结果区：最近确认时间、最近反馈文案、处理组织。

Role-specific behavior:

| Viewer relation | Subject owner | Page behavior |
| --- | --- | --- |
| 竞标方查看发布方 5 资料 | 发布方 | 可确认 / 可反馈。 |
| 发布方查看发布方 5 资料 | 发布方 | 只读资料和对方审阅结果；可引导去资料补充入口。 |
| 发布方查看竞标方 3 资料 | 竞标方 | 可确认 / 可反馈。 |
| 竞标方查看竞标方 3 资料 | 竞标方 | 只读资料和对方审阅结果；可引导去竞标资料补充或重新提交入口。 |

Unsubmitted behavior:

- 显示 `当前资料尚未提交`。
- 不展示确认按钮。
- 对资料拥有方显示补充入口提示。
- 对审阅方显示等待对方补齐提示。

Needs supplement behavior:

- 红色状态条显示最近反馈。
- 资料拥有方看到 `对方反馈需要补充`。
- 审阅方可以在资料更新后重新确认或继续反馈。

## 7. Existing Preview Reuse

Day 7 实现优先复用现有能力：

| Source | Existing reusable surface |
| --- | --- |
| 发布方 5 资料 | `project_attachments` / 报价依据资料读取和文件预览能力。 |
| 竞标方 3 资料 | bid submission snapshot attachments / 竞标附件读取能力。 |
| 聊天附件预览 | 仅复用文件预览组件或 access model，不复用聊天消息作为资料真值。 |

Fallback:

- 图片：使用现有图片预览。
- PDF/Office/ZIP：如已有在线预览能力则进入预览；否则展示文件卡、类型、大小和受控提示。
- 不允许用 raw OSS URL 直接展示。

## 8. Component Split

Day 7 建议新增或改造的 Flutter 文件：

| File | Responsibility |
| --- | --- |
| `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_communication_workbench_support.dart` | Workbench read-model enum/status parsing and safe DTO mapping. |
| `apps/mobile/lib/features/exhibition/presentation/pages/project_communication_workbench_section.dart` | 10 入口分组和 tile 渲染。 |
| `apps/mobile/lib/features/exhibition/presentation/pages/project_communication_material_review_detail_page.dart` | 8 资料详情页骨架。 |
| `apps/mobile/lib/features/exhibition/presentation/pages/project_communication_material_review_detail_widgets.dart` | 附件区、反馈表单、状态条拆分组件。 |
| `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart` | 只保留接线和导航调用，禁止新增大块 UI。 |
| `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart` | 只保留原工作入口容器最小接线。 |

File-length rule:

- 新增 handwritten Flutter 文件默认控制在 450 行以内。
- 单个 widget build method 不承载完整页面业务。
- 不再向已超过 1000 行的现有文件加入大段新 UI。

## 9. Data Consumption

Flutter target repository flow:

```text
Counterpart conversation page
  -> BFF GET /api/app/message/project-communication/workbench
  -> render ProjectCommunicationWorkbenchView
  -> material detail page
  -> BFF POST /api/app/message/project-communication/workbench/material-review
  -> refresh workbench + detail
```

Rules:

- Flutter only calls BFF.
- Flutter does not call Server directly.
- Flutter does not persist review state locally.
- Optimistic UI is allowed only as loading affordance; final green/red must wait for BFF response.
- Unknown `entryKey` or state must show controlled unavailable state and log parser drift in tests.

## 10. Composer Boundary

底部聊天输入栏继续只保留：

- `附件`
- `图片`
- 文本输入框
- 发送按钮

不得恢复：

- `确认`
- `发送确认事项`
- `发送确认卡`
- 10 入口中的任一主操作

聊天记录可以展示历史资料沟通消息，但不能作为确认主入口。

## 11. Test Plan

Day 7 Flutter widget tests must cover:

1. Workbench:
   - 同一页面显示 10 个入口。
   - 不出现旧正式入口名 `报价确认 / 排期确认 / 工艺材质确认`。
   - 入口按 `发布方资料 / 竞标资料 / 成交确认` 分组。
2. State:
   - `pending_review` 橙色 `待确认`。
   - `confirmed` 绿色 `已确认`。
   - `needs_supplement` 红色 `需补充`。
   - `unsubmitted` 灰色 `未提交`。
3. Detail page:
   - 竞标方打开发布方效果图确认页可看到附件区、确认按钮、反馈入口。
   - 发布方打开竞标方报价表确认页可看到附件区、确认按钮、反馈入口。
   - 资料拥有方打开自己资料页不能确认自己的资料。
4. Commands:
   - 点击确认调用 BFF material-review command。
   - 提交反馈调用 BFF material-review command，并携带反馈文本。
   - `unsubmitted` 不发确认命令。
5. Composer:
   - 底部输入栏无确认主入口。
   - 点击 workbench 入口不创建聊天消息。
6. Layout:
   - 375px 宽度无文字溢出。
   - 长文案入口换行后按钮高度稳定。

## 12. Computer Use Acceptance For Day 12

最终视觉验收至少需要：

- 发布方账号截图：10 个入口可见；打开竞标方 3 资料之一可确认/反馈。
- 竞标方账号截图：10 个入口可见；打开发布方 5 资料之一可确认/反馈。
- 反馈后双方对应入口显示红色 `需补充`。
- 确认后双方对应入口显示绿色 `已确认`。
- 合同确认 / 最终成交金额确认入口不触发真实扣费。

## 13. Day 5 Handoff

`Conditional Go` for Day 5 Server implementation, with one caveat:

- Day 5 may implement only the 8 material review Server truth.
- Day 5 must not implement Flutter UI early.
- Day 5 must not wire合同确认 or最终成交金额写入.
- Day 5 migration is additive but still must be reviewed before cloud execution.
