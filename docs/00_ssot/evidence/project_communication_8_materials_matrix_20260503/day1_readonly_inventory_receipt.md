---
owner: Codex 总控
status: accepted
layer: L0 SSOT / read-only inventory
recorded_at_local: 2026-05-03
scope: Project communication 8 material items matrix and UI matrix Day 1 read-only gate
---

# 项目沟通 8 个资料项 Matrix + UI Matrix Day 1 只读盘点回执

## 1. 总裁决

Day 1 裁决为 `Conditional Pass`。

允许进入第 2 天资料项 matrix 冻结。当前缺口只限 SSOT / UI matrix 和 Flutter 最小 UI 收敛；未发现必须新增 BFF / Server / contracts 才能表达 8 项资料真值。

本轮不进入支付、扣费、支付回调、真实合同确认、最终成交金额确认、文件上传三步流、云端部署、migration、服务重启或 current 切换。

## 2. 工作区状态

| Item | Result |
| --- | --- |
| `git status --short --branch` | `## main...origin/main`，工作区干净。 |
| 本轮是否已有脏改 | 否。 |
| 本轮是否触碰云端 | 否。 |

## 3. SSOT / Contracts 只读核对

| Surface | Current finding | Verdict |
| --- | --- | --- |
| 10 entry workbench | `ProjectCommunicationWorkbenchEntryKey` 已包含 5 个发布方资料、3 个竞标资料、2 个成交确认入口。 | `Current` |
| 8 material review entries | `ProjectCommunicationMaterialReviewEntryKey` 只包含前 8 个资料项，不包含成交确认。 | `Current` |
| Workbench read path | `GET /api/app/message/project-communication/workbench` 已入 `openapi.yaml` 和 generated types。 | `Current` |
| Material review command | `POST /api/app/message/project-communication/workbench/material-review` 已入 `openapi.yaml` 和 generated types，只允许 8 项资料。 | `Current` |
| Deal entries | `contract_confirmation`、`final_confirmed_amount_confirmation` 只作为 `deal_confirmation` group 的入口枚举。 | `Reserved / next gate` |
| Message send | `POST /api/app/message/project-communication/messages` 代码存在，但不属于本轮 Current。 | `Reserved / next gate` |

## 4. Flutter 只读核对

| Item | Current finding | Verdict |
| --- | --- | --- |
| 页面入口 | `CounterpartConversationPage` 已加载 workbench read-model。 | `Current` |
| Workbench UI | 当前 `_ProjectCommunicationWorkbenchSection` 在工作入口内直接显示 3 个 group 卡，并支持展开显示资料项。 | `Needs UI alignment` |
| 详情页 | `_ProjectCommunicationMaterialReviewDetailPage` 已能读取 `sourceFiles`，并可按发布资料 / 竞标资料回退加载文件。 | `Current` |
| Material review action | Flutter 已通过 `submitProjectCommunicationMaterialReview` 发起 `confirm` / `request_supplement`。 | `Current` |
| Deal entries | `_openWorkbenchEntry` 对 `deal_confirmation` 只弹提示，不触发扣费或真实合同动作。 | `Reserved honored` |
| UI 缺口 | 当前不是“顶部 3 个轻量按钮 + bottom sheet”，而是工作入口内 3 个 group 卡。 | `Flutter minimal adjustment needed` |

## 5. BFF 只读核对

| Route | Current finding | Verdict |
| --- | --- | --- |
| `GET /api/app/message/project-communication/workbench` | BFF route 存在，并转发 Server `/server/project-communication/workbench`。 | `Current` |
| `POST /api/app/message/project-communication/workbench/material-review` | BFF route 存在，并转发 Server `/server/project-communication/workbench/material-review`。 | `Current` |
| `POST /api/app/message/project-communication/read-cursor` | BFF route 存在，属于已读游标能力，不是资料 matrix 主体。 | `Current` |
| BFF truth ownership | 未发现 BFF 持有 material review business truth；BFF 只做 route/read-model/transport。 | `Pass` |

## 6. Server 只读核对

| Item | Current finding | Verdict |
| --- | --- | --- |
| Workbench truth owner | Server project communication module 是 workbench 和 material review 状态 owner。 | `Current` |
| 8 material entries | Server tests 覆盖 10 fixed entries、确认、反馈、越权和 stale token。 | `Current` |
| Source files | Workbench entry 暴露 `sourceFiles`，详情页可按 `truthAnchor.materialKind` / `bidMaterialSlot` 取资料。 | `Current` |
| Deal entries | 成交确认入口不属于 material-review command。 | `Reserved / next gate` |

## 7. 当前缺口清单

| Gap | Layer | Severity | Treatment |
| --- | --- | --- | --- |
| 8 个资料项 matrix 未单独冻结成当前施工表 | SSOT | Medium | Day 2 冻结。 |
| 顶部 3 入口 + bottom sheet UI 方案未落地 | Flutter | Medium | Day 3 冻结 UI matrix，Day 4 最小调整。 |
| 当前 workbench group 卡长期显示在工作入口内 | Flutter | Medium | 收敛为轻量入口，不污染聊天流。 |
| broader `counterpart_conversation_chat_test.dart` 已知旧失败 | Flutter test | Low for this round | 记录为 Flutter Release Gate 后续项，不作为本轮 matrix 阻断。 |

## 8. 禁止项确认

Day 1 未混入：

- 支付。
- 扣费。
- 支付回调。
- 真实合同确认。
- 最终成交金额确认。
- 文件上传三步流上线。
- BFF / Server / contracts 修改。
- 云端部署、migration、服务重启。

## 9. 是否允许进入第 2 天

`允许`。

条件：第 2 天只允许冻结 8 个资料项 matrix；不得把 `contract_confirmation`、`final_confirmed_amount_confirmation`、`POST messages`、支付或上传三步流写成 Current。
