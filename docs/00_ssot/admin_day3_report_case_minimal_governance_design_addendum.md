---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: Admin Day 3 Forum / Report 最小治理链路设计冻结
created_at: 2026-05-11
---

# Admin Day 3 Report Case 最小治理链路设计冻结

## 1. 总裁决

Day 3 目标是冻结 `P0-2 / P0-3` 的最小治理链路。

当前裁决：`PASS WITH OPEN IMPLEMENTATION`。

含义：

- `exhibition report-case` 本地 Server Admin API、Admin 案件台、contracts 路径已存在。
- `forum report` 本地用户提交、ticket、snapshot、audit、content-safety 列表/详情已存在。
- 当前缺口不是“没有举报提交”，而是 `forum report` 缺 Admin 处置动作。
- 本轮不得把 `forum report`、`exhibition report-case`、`project content report` 混成同一个业务真值。
- 本轮不得把 `/project_review` 扩成完整项目发布审核状态机或通用治理重系统。

云端 runtime 状态：`UNKNOWN`。

## 2. Report 来源分流冻结

| 来源 | 当前对象 | 当前代码状态 | Admin 承接方式 | 本轮裁决 |
| --- | --- | --- | --- | --- |
| Forum report | `ForumReportTicketEntity` | App submit、ticket、snapshot、audit 存在；content-safety review task 可读 | `/review` 内容安全任务可最小查看 | 需补 Admin 处置动作，不并入 exhibition report-case 真值 |
| Exhibition report-case | `ExhibitionReportCaseEntity` | App-facing submit、Admin list/detail/request/decide/escalate 本地代码存在 | `/project_review` 案件台承接 | 保留现有链路；后续做 runtime 核验 |
| Project content report | 目标可落到 exhibition report targetType = `project` | 通过 exhibition report-case 目标类型承接 | `/project_review` 按 targetType = `project` 过滤 | 仅做举报案件处理，不做项目发布审核台 |

## 3. 当前代码证据

| 能力 | 路径 | 结论 |
| --- | --- | --- |
| Forum report submit | `apps/server/src/modules/forum/forum-report.service.ts` | 创建 `ForumReportTicketEntity`、捕获 snapshot、写 `ContentSafetyAuditService` |
| Forum report mine list/detail | `apps/server/src/modules/forum/forum-report.query.service.ts` | 用户侧只读我的举报历史 |
| Forum report review task | `apps/server/src/modules/content_safety/content-safety-review-task.query.service.ts` | `submitted` 的 forum report ticket 会进入 review task list/detail |
| Forum report ticket entity | `apps/server/src/modules/forum/entities/forum-report-ticket.entity.ts` | 当前只有 `status` 和 snapshot 字段，缺 Admin decision 字段 |
| Exhibition report-case submit/admin | `apps/server/src/modules/exhibition_report_cases/exhibition-report-case.service.ts` | 支持 submit、list、detail、requestExplanation、decide、escalate |
| Exhibition report-case admin controller | `apps/server/src/modules/exhibition_report_cases/exhibition-report-case-admin.controller.ts` | 暴露 `/server/admin/exhibition/report-cases*` |
| Admin report-case UI | `apps/admin/src/modules/project_review/project-review-shell.tsx` | 当前只承接 exhibition report-case，不承接 forum report mutation |
| OpenAPI paths | `docs/01_contracts/openapi.yaml` | 已声明 `/api/app/forum/report/submit`、`/api/app/exhibition/report/submit`、`/server/admin/exhibition/report-cases*` |

## 4. P0 最小处置动作冻结

### 4.1 Forum report 最小动作

Forum report 只允许补以下最小 Admin 动作：

| 动作 | 语义 | 是否写业务真值 | 是否写 audit |
| --- | --- | --- | --- |
| `decide_not_established` | 举报不成立 | 写 forum report ticket decision | 是 |
| `decide_established` | 举报成立 | 写 forum report ticket decision | 是 |

本轮明确不把 forum report 处置扩成帖子/评论状态机或处罚系统。

| 延后动作 | 延后原因 | 后续条件 |
| --- | --- | --- |
| `hide_target` | 会写 Forum post/comment state，容易把举报裁决和内容状态机耦合 | 需单独冻结 Forum 内容处置状态机 |
| `restore_target` | 会写 Forum post/comment state，容易引入恢复、误处置、二次审计边界 | 需单独冻结 Forum 内容恢复边界 |
| `restrict_author` | 会进入处罚 / 限制 / 封禁系统，超出本轮 P0 | 需单独冻结 governance penalty 最小写链路 |

约束：

- 不做自动下架。
- 不直接隐藏或恢复帖子 / 评论。
- 不直接限制作者。
- 不做 AI 审核 runtime 必需项。
- 不做普通用户处理时间线。
- 不做完整申诉中心。
- 不做消息举报后台。
- 不把 content-safety review task 列表本身当成处置闭环。

### 4.2 Exhibition report-case 保留动作

Exhibition report-case 当前保留既有动作：

- `request-explanation`
- `decide`
- `escalate`

约束：

- `escalate` 只生成治理引用或临时限制状态，不等于完整 penalty 闭环。
- `decide` 不得直接修改项目业务状态机。
- `/project_review` 当前仍是举报案件台，不是项目发布审核台。

### 4.3 Project content report 边界

项目相关举报当前通过 exhibition report targetType 承接：

- `project`
- `project_profile`
- `bid`
- `contract`
- `inspection`

本轮只允许案件处理和证据查看，不允许新增：

- 项目发布审核状态机。
- 交易/履约后台。
- 资金/结算/合同操作后台。
- Admin 直接改项目业务真值。

## 5. 最小 API 增补清单

若进入实现，最小 API 只允许补 Forum report Admin 裁决命令，并复用现有 content-safety review task list/detail：

| Method | Path | 用途 |
| --- | --- | --- |
| `GET` | `/server/admin/content-safety/review-tasks` | 复用现有 Forum report queue |
| `GET` | `/server/admin/content-safety/review-tasks/{taskId}` | 复用现有 Forum report detail |
| `POST` | `/server/admin/content-safety/forum-reports/{ticketId}/decide` | 成立 / 不成立 / 关闭 |

本轮不加入 `hide-target`、`restore-target`、`restrict-author`。

原因：这些动作分别进入 Forum 内容状态机或治理处罚状态机，必须独立冻结，不能在 forum report P0 API 内实现。

## 6. Admin 页面最小改动清单

| 页面 | 最小改动 | 禁止扩张 |
| --- | --- | --- |
| `/review` | 对 `forum_report_ticket:*` 任务提供裁决入口 | 不做完整内容平台后台 |
| `/project_review` | 保持 exhibition report-case 台，不承接 forum report mutation | 不改名为通用项目审核台 |
| `/audit` | 后续可显示 forum report decision audit | 不允许 audit mutation |

## 7. Day 3 准入下一天裁决

Day 3 准入 Day 4 条件：

- forum report 与 exhibition report-case 已明确分流。
- 已确认 forum report 缺的是 Admin 处置动作。
- 已确认 exhibition report-case 不等于完整 penalty / project review 状态机。
- 每个允许动作都必须有 actor / reason / occurredAt / target / action。
- Forum report P0 只补案件裁决，不做帖子/评论隐藏恢复，不做作者处罚。
- 不把举报闭环扩成通用治理重系统。

当前裁决：`PASS`。
