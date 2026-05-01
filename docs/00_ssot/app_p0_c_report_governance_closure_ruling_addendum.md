---
owner: 总控 Agent
status: frozen
purpose: Freeze Day 6 P0-C report/governance closure rulings and the bounded implementation package boundary.
layer: L0 SSOT
freeze_date_local: 2026-05-01
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/app_p0_b_contracts_runtime_drift_ruling_addendum.md
  - docs/00_ssot/forum_report_p0_completion_filing_addendum.md
  - docs/00_ssot/content_safety_capability_tracking_table_v1.md
  - docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md
  - docs/01_contracts/forum_content_governance_and_report_contracts_addendum.md
  - docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md
  - docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md
  - docs/04_frontend/forum_content_governance_and_report_frontend_surface_addendum.md
  - apps/server/src/modules/forum/**
  - apps/server/src/modules/exhibition_report_cases/**
  - apps/server/src/modules/governance/**
  - apps/server/src/modules/profile/**
  - apps/bff/src/routes/forum/**
  - apps/bff/src/routes/profile/**
  - apps/mobile/lib/features/exhibition/**
  - apps/mobile/lib/features/profile/**
---

# 《P0-C 举报与治理最小闭环裁决》

## 1. 总裁决

P0-C 当前结论固定为：`Conditional Go for bounded implementation package`。

本轮不把举报治理写成 full pass。当前已经闭合的最小链路和仍未闭合的 P0 缺口必须拆开：

- `forum report`：保留为论坛内容举报链。源码层已具备 submit、ticket、snapshot、audit、我的举报只读；但 primary OpenAPI/generated 对 `forum/report/submit` 与 `forum/reports/mine` 仍存在同步缺口，runtime 本轮未主动复核。
- `exhibition report submit`：合同已声明 `POST /api/app/exhibition/report/submit`，Admin report-case 台已存在；但 App/BFF/Server app-facing submit 链未闭合，必须作为 P0-C bounded patch 补通，不能用 forum report 冒充。
- `profile/governance/appeals`：当前只承认 `GET list/detail` 只读链路。`POST submit` 从当前 P0 active 降级为 reserved / future，不在本轮硬补。
- `penalty / appeal / report-cases admin`：Admin 侧最小处理台可作为治理输入，但不得扩写成用户侧处罚中心、申诉提交中心或通用工单系统。

## 2. 举报治理闭环裁决表

| 项 | 文书依据 | contracts 依据 | 代码依据 | runtime 依据 | 裁决 | 推荐下一步 |
| --- | --- | --- | --- | --- | --- | --- |
| Forum post/comment report submit | Forum Report P0 completion filing 与 content-safety tracking 标记 CS-010/011/012 在当前边界完成 | addendum 冻结 `POST /api/app/forum/report/submit`，但 primary OpenAPI/generated 未收录 | BFF `app-forum.controller.ts` 暴露 `report/submit`；Server `forum.controller.ts` 与 `ForumReportService` 写 ticket/snapshot/audit；Flutter forum detail/comment 调用举报 sheet | 本轮未主动访问 runtime；历史文书有 active ingress 通过记录 | `兼容保留`：论坛内容举报链成立，但不能扩大到项目举报 | 后续 clean contract window 补 primary OpenAPI/generated 或明确仅 addendum contract；Day9 由用户提供 runtime |
| Forum my reports list/detail | CS029 文书为 conditional pass / 只读历史 | primary OpenAPI/generated 未收录 | BFF `reports/mine` list/detail；Flutter 我的举报记录只读页面 | 本轮未主动复核 | `兼容只读`：不得当全局举报中心 | 若继续保留，补 SSOT/contracts；不新增处理动作 |
| Exhibition fake-project report submit | fake-project report 文书冻结 `POST /api/app/exhibition/report/submit` | primary OpenAPI/generated 已收录 | 未见 BFF route；未见 Server app-facing submit；未见 Flutter consumer/UI；只见 Server Admin `exhibition_report_cases` 台 | 本轮未主动复核；历史口径存在 404 风险 | `补通`：进入 P0-C 最小 patch 草案，但今天不施工 | 最小实现仅限 submit -> Server report case input -> admin case queue；不得复用 forum report |
| Exhibition report Admin case desk | stage3 Admin package B / fake-project report 文书 | primary OpenAPI 已收录 `/server/admin/exhibition/report-cases*` | Server Admin list/detail/request-explanation/decide/escalate 存在，并写 audit | 本轮未主动复核 | `兼容保留`：作为 P0-C admin处理输入 | 继续要求 reviewer/session fail-close；Day9 人工复核 |
| Profile governance status | CS032 文书冻结只读累计分/状态摘要 | primary OpenAPI/generated 已收录 `GET /api/app/profile/governance/status` | BFF/Server/Flutter GET 只读链路存在 | 本轮未主动复核 | `兼容只读` | 保持，不扩成处罚历史中心 |
| Profile appeals list/detail | CS030 文书冻结 current-actor list/detail | primary OpenAPI/generated 已收录 GET list/detail | BFF/Server/Flutter GET 只读链路存在 | 本轮未主动复核 | `兼容只读` | 保持，不开放提交、补材料、聊天 |
| Profile appeals submit | blacklist/whitelist addendum 与 primary OpenAPI 曾声明 POST | primary OpenAPI 有 POST claim | BFF command、Server profile controller、Flutter 均未闭合 submit | 用户既有口径指向 POST 404；本轮待人工复核 | `降级`：移出当前 P0 active，保留 future | clean contract window 中决定删除/标 reserved/另包补通 |
| Admin penalty / appeal decide | Admin governance 文书与 OpenAPI 有路径 | primary OpenAPI 已收录 `/server/admin/governance/*` | Server Admin penalty apply/list/detail、appeal list/detail/decide 存在并写 audit | 本轮未主动复核 | `保留为 Admin 治理面` | 不向 App 暴露处罚中心，不让 Admin 成为第二业务真值 |
| security-events / whitelist / permanent-ban | 多份治理增强文书存在 | 部分 Admin contracts 存在 | 非本轮 App P0 主线 | 本轮未主动复核 | `降级 P2` | 不进入 P0-C |

## 3. P0-C 最小补通包草案

仅当进入实现日时，P0-C 允许的最小补通范围固定为：

1. `POST /api/app/exhibition/report/submit` BFF app-facing route。
2. `POST /server/exhibition/report/submit` 或等价 Server app-facing route，唯一职责是创建/复用 `exhibition_report_cases`。
3. App 项目详情或项目相关对象页的“举报项目”最小入口。
4. 最小 submit body：`targetType`、`targetId`、`reasonCode`、`reasonDetail?`、`evidenceFileAssetIds?`。
5. 最小 response：`reportCaseId`、`targetType`、`targetId`、`status`、`acceptMode`、`traceId`。
6. Server 必须写 append-only audit，并且 `BFF` 不持有 report-case 状态机。
7. 只允许把 submit 结果送入既有 Admin report-case queue，不新增用户侧举报中心。

## 4. 当前禁止进入

- 不做 `profile/governance/appeals` 用户侧提交。
- 不做处罚历史中心。
- 不做全局举报中心。
- 不做 forum report 与 exhibition report 互相复用。
- 不做 report processing timeline 给普通用户。
- 不做 security-events、whitelist、permanent-ban history。
- 不做自动处罚、自动下架、AI/OCR/QR runtime。
- 不做消息举报重后台。
- 不做工单系统。
- 不做 payment、credit、membership 扩写。

## 5. 门禁影响

| gate | 状态 | 说明 |
| --- | --- | --- |
| forum report P0 | `Conditional Pass` | 源码链路成立；formal primary contracts 和本轮 runtime 待补证。 |
| exhibition report P0 | `No-Go until bounded patch` | 合同与 Admin case desk 有，但用户侧 submit 链缺失。 |
| appeal submit | `No-Go / Deferred` | 当前降级为 future，不阻塞 P0-C 最小项目举报闭环。 |
| 进入第 7 天 | `ALLOW` | 上架合规补齐可并行推进；P0-C 实现留给后续 bounded patch 日。 |
| P0 full Go | `BLOCKED` | 直到 exhibition report submit 补通或正式移出 P0，并完成人工 runtime 复核。 |

## 6. 第 6 天验收结论

第 6 天验收状态固定为：`PASS WITH P0-C OPEN PATCH`。

通过理由：

- `forum report`、`exhibition report`、`appeal submit` 已拆成三条不同链路。
- 已确认不能用 forum report 冒充 exhibition fake-project report。
- 已确认 `appeal submit` 不在当前 P0 最小闭环中硬补。
- 已形成 P0-C 最小补通包草案，且未扩大为治理重系统。

下一步进入第 7 天：只做上架合规最低入口复核与补齐，不触碰支付、信用、会员、工单或 settings/flags center。
