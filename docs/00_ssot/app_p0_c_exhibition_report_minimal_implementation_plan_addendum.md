---
owner: 总控 Agent
status: frozen
purpose: Freeze the minimal P0-C exhibition report submit implementation package.
layer: L0 SSOT
freeze_date_local: 2026-05-01
depends_on:
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md
  - apps/server/src/modules/exhibition_report_cases/**
  - apps/bff/src/routes/**
  - apps/mobile/lib/features/exhibition/**
  - apps/admin/src/modules/project_review/**
---

# 《P0-C exhibition report submit 最小实现方案》

## 1. 总裁决

P0-C 选择：`补通最小 submit 链路`，不移出 P0。

最小闭环定义为：

`Flutter 项目详情举报入口 -> BFF /api/app/exhibition/report/submit -> Server /server/exhibition/report/submit -> exhibition_report_cases 写入 -> Admin /project_review 队列承接`

本包只做 report-case input，不做举报历史中心、不做处罚状态机、不做用户侧申诉提交、不做消息证据重系统、不做自动下架、不做支付/信用/会员/订单/合同/履约扩写。

## 2. 当前事实

| 层 | 当前状态 | 缺口 | 依据类型 |
| --- | --- | --- | --- |
| contracts | `POST /api/app/exhibition/report/submit` 与 `/server/admin/exhibition/report-cases*` 已声明 | app-facing submit 有合同但运行代码未闭合 | contracts |
| Server | `exhibition_report_cases` entity、migration、Admin queue/detail/request-explanation/decide/escalate 已存在 | 缺 `/server/exhibition/report/submit` app-facing submit controller/service method | 代码 |
| BFF | 现有 `forum/report/submit`，未见 `exhibition/report/submit` route | 缺 BFF aggregation path，不能混用 forum report | 代码 |
| Flutter | 现有 forum report UI/consumer；项目详情无 exhibition report submit 接线 | 缺项目详情最小举报入口和 data action | 代码 |
| Admin | `/project_review` 已消费 Server Admin report-cases queue | 可承接 submit 生成的 case，但需 runtime 验证 | 代码 / runtime 待复核 |

## 3. Server 最小实现边界

允许新增 / 修改：

- `apps/server/src/modules/exhibition_report_cases/exhibition-report-case-app.controller.ts`
- `apps/server/src/modules/exhibition_report_cases/exhibition-report-case.service.ts`
- `apps/server/src/modules/exhibition_report_cases/exhibition-report-case.command-reader.ts`
- `apps/server/src/modules/exhibition_report_cases/exhibition-report-case.module.ts`
- `apps/server/test/exhibition-report-case-submit.test.cjs`

Server submit 规则：

- path 固定为 `POST /server/exhibition/report/submit`。
- 必须先验证当前 App session；未登录返回 `401 AUTH_SESSION_INVALID`。
- 必须要求 authenticated actor 与 current organization scope。
- request body 只接受 `targetType`、`targetId`、`reasonCode`、`reasonDetail?`、`evidenceFileAssetIds?`。
- `targetType`、`reasonCode` 复用 `exhibition-report-case.constants.ts` 冻结枚举。
- 写入唯一真值表 `exhibition_report_cases`。
- 同一 reporter + targetType + targetId + reasonCode 的 active case 返回 `acceptMode=existing_active`。
- 新 case 返回 `acceptMode=created`。
- `metadata` 只存最小 reporter actor、source 和 submit trace，不存消息聊天内容或资金/履约状态。
- 记录 `content_safety_audit` manual audit，subjectType 固定 `exhibition_report_case`。

暂不做：

- 不校验项目/竞标/合同/验收对象全量状态机。
- 不创建 review_task 另一套真值。
- 不创建治理 ticket，除非后续 Admin escalate。
- 不写处罚、封禁、信用扣分、支付冻结。

## 4. BFF 最小实现边界

允许新增 / 修改：

- `apps/bff/src/routes/exhibition_report/app-exhibition-report.controller.ts`
- `apps/bff/src/routes/exhibition_report/exhibition-report.service.ts`
- `apps/bff/src/routes/exhibition_report/exhibition-report.module.ts`
- `apps/bff/src/routes/routes.module.ts`
- `apps/bff/test/exhibition-report-submit-transport.test.cjs`

BFF 规则：

- path 固定为 `POST /api/app/exhibition/report/submit`。
- 只转发到 `/server/exhibition/report/submit`。
- 必须使用 App auth transport；未登录由 BFF 或 Server 返回 `401 AUTH_SESSION_INVALID`。
- 只做协议转发、错误归一和 response shaping，不拥有案件状态。
- 不透传任何 Admin route。
- 不复用 `/api/app/forum/report/submit`。

## 5. Flutter 最小实现边界

允许新增 / 修改：

- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_actions_support.dart`
- `apps/mobile/test/exhibition_report_submit_test.dart`

Flutter 规则：

- 项目详情页仅增加一个克制的“举报该项目”入口。
- 默认 reasonCode 固定为 `fabricated_project` 或由最小 sheet 选择冻结枚举；本轮不做举报历史中心。
- 提交成功只提示“举报已提交，平台将进入人工复核”，不展示内部 Admin case 操作。
- 未登录展示受控登录提示，不伪造成功。
- 不复用 forum report consumer，不把 forum report ticket 当 exhibition report case。

## 6. Admin 承接边界

Admin 现有 `/project_review` 继续作为 `exhibition_report_cases` 队列和裁决台。

本轮不新增 Admin 接口，不改 Admin 真值，不新增项目审核状态机。

验收只要求：Server 生成的 `exhibition_report_cases` 能被现有 `/server/admin/exhibition/report-cases` list/detail 读取。

## 7. 第 4 天验收标准

- Server 单测证明：未登录 401、非法 body 400、新建 case `created`、重复 active case `existing_active`、audit 记录存在。
- BFF transport 测试证明：`POST /api/app/exhibition/report/submit` 转发 `/server/exhibition/report/submit`，且不触碰 forum report。
- Flutter 测试证明：项目详情“举报该项目”触发 `POST /api/app/exhibition/report/submit`，body 使用 exhibition target/reason；未登录或失败态不显示成功。
- 本地 build/test 通过。
- 不新增处罚、申诉、消息证据、支付、信用、会员、工单或 settings 能力。

## 8. 门禁结论

第 3 天 `P0-C Exhibition Report 最小闭环设计`：`Pass`。

允许进入第 4 天 `P0-C 最小代码实现与本地验证`。
