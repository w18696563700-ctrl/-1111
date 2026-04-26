---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day9 regression checklist and Day10 auditable delivery result for
  the create-page, prepublish-detail, attachment-entry, and factory bid-materials
  convergence round.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_create_prepublish_day9_day10_regression_audit_gate_checklist_addendum.md
  - docs/00_ssot/project_create_prepublish_day5_day6_frontend_execution_receipt_addendum.md
  - docs/00_ssot/project_create_prepublish_day7_day8_attachment_frontend_execution_receipt_addendum.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
---

# Day9-Day10《回归清单与可审核交付稿》

## 1. Audit Conclusion

- Day9 回归检查：通过。
- Day10 审核交付：通过，可进入人工审核。
- 后端阶段：No-Go。未获得新的后端阶段门禁前，不进入 BFF / Server / contracts / cloud release。

本轮更稳的结论是：继续把创建页和预发布详情收敛限定在 Flutter 前端与 L0 文书层，不重开 BFF / Server。

本轮更省成本的结论是：复用既有 `submitted = 预发布列表`、`project_attachments`、`/api/app/project/bid-materials`、`/api/app/bid/submit` 与既有 Flutter 页面，不新增状态或第二套附件真值。

本轮更适合当前阶段的结论是：以项目列表、公域项目详情、我的项目/预发布详情、竞标提交只读材料为回归面，验证 Day5-Day8 没有误伤工厂接单侧。

本轮风险更大的方向是：把 owner 预发布附件区和工厂竞标只读材料区混成一个可写区，或把 `other_material` 投影给工厂侧。

## 2. Current Minimum Loop

1. 发布方创建项目，保存草稿或保存到预发布列表。
2. `submitted` 继续作为用户文案 `预发布列表`，不是新状态。
3. 发布方从我的项目进入预发布详情，补充项目详情文书。
4. owner 在 `submitted-or-later` 可管理 `效果图 / 施工图 / 其他资料`。
5. 发布方检查无误后走既有 `publish` 动作。
6. 工厂从公域项目详情进入竞标提交。
7. 工厂先核对项目，再只读读取 `effect_image / construction_doc`，再填写报价方案并上传 3 份竞标必选文档。

## 3. Day9 Regression Checklist

- 项目列表：通过。公开列表仍是公域只读展示，核心项目字段保留；未出现 owner 附件上传、删除或绑定动作。
- 公域项目详情：通过。owner 视角继续回到我的项目；non-owner published 项目继续进入竞标。
- 我的项目/预发布详情：通过。`submitted` 继续承接 `补资料后确认发布` 与项目详情文书入口。
- owner 附件区：通过。`效果图 / 施工图 / 其他资料` 继续只在 owner 私域项目详情文书区可写。
- 工厂竞标提交页：通过。首屏只显示核对项目；点击 `继续竞标` 后才显示项目附件、报价方案和 3 份必传文档。
- 工厂只读材料：通过。只读区只允许 `effect_image / construction_doc`，不展示 `other_material`，也不出现 `选择项目附件`、`上传并形成正式附件`、`删除当前文书`。
- 普通创建接口：通过。创建/保存/提交请求体仍按既有字段走 `/api/app/project/*`，预算旁明价/询价仅是意向 UI，不写入请求体。

## 4. Day10 Delivery Scope

### 4.1 Production Frontend Changes From This Round

- 创建页：
  - 预算旁新增 `明价意向 / 询价意向`。
  - 意向选择只停留在页面状态，不进入请求体。
  - 创建页 P0-Pay 技术区块继续隐藏，不作为交易总控台。
- 我的项目 / 预发布详情：
  - `预发布列表` 主动作收敛为 `补资料后确认发布`。
  - 最终发布确认主面放在我的项目详情/预发布详情。
  - 不新增 Server 状态机。
- 附件入口：
  - `submitted = 预发布列表` 阶段明确开放 `效果图 / 施工图 / 其他资料`。
  - owner 附件继续走 `init -> direct upload -> confirm -> bind`。
  - 工厂侧只读项目材料继续使用 bid-materials 投影，不写 owner 附件。

### 4.2 Day9-Day10 Test-Only Changes

- `project_attachment_prepublish_and_bid_materials_test.dart`：
  - 增加 `other_material` drift 负向用例。
  - 增加工厂只读材料区无选择、上传、删除入口断言。
- `exhibition_mainline_flow_test.dart`：
  - 对齐当前首页频道、项目列表卡片和竞标 staged reveal。
  - 主线竞标提交补齐 3 份 confirmed FileAsset 后再提交。

## 5. Verification Evidence

本地 Flutter 验证均在 `apps/mobile` 下执行。

- `flutter analyze lib/features/exhibition/presentation/pages/project_detail_page.dart lib/features/exhibition/presentation/pages/my_project_detail_page.dart lib/features/exhibition/presentation/pages/my_project_list_page.dart lib/features/exhibition/presentation/pages/project_create_page.dart lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart lib/features/exhibition/presentation/presentation_support/bid_submit_materials_support.dart test/project_attachment_prepublish_and_bid_materials_test.dart test/exhibition_mainline_flow_test.dart`
  - 结果：通过，No issues found。
- `flutter test test/project_attachment_prepublish_and_bid_materials_test.dart`
  - 结果：通过，3 tests passed。
- `flutter test test/exhibition_mainline_flow_test.dart`
  - 结果：通过，12 tests passed。
- `flutter test test/project_showcase_filter_create_refactor_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart test/project_attachment_corridor_test.dart test/my_project_private_carry_test.dart test/exhibition_mainline_flow_test.dart`
  - 结果：通过，52 tests passed。
- `flutter test test/shell_app_test.dart --name "bid submit blocks owner route from executable mainline"`
  - 结果：通过，1 test passed。
- `flutter test test/shell_app_test.dart --name "bid submit blocks project that is no longer bid-open"`
  - 结果：通过，1 test passed。

## 6. Retained Non-Goals

- 不新建 `prepublish` / `prepublished` 状态或路径。
- 不修改 BFF / Server / contracts。
- 不开放通用钱包、余额、支付中心、结算、发票、履约保证金。
- 不开放泛私信、群聊、完整 compare board、loser board、完整 post-award 工作台。
- 不把 `renovation` / `custom_furniture` 放进本轮主流程。
- 不开放工厂侧 owner 附件上传、删除、绑定能力。
- 不把 `other_material` 投影到工厂竞标提交页。

## 7. Risks And Follow-Ups

- 云端 BFF / Server 未在本阶段重新部署或修改；本交付只声明本地 Flutter 回归通过。
- 若后续要开放更多 owner 材料给工厂，必须先冻结 L0/L2 可见性、脱敏、权限和错误语义，再改 BFF / Server 投影，最后改 Flutter。
- P0-Pay 仍只作为后续扩展位；创建页不得直接提交交易任务或拉起支付。
- Computer Use / 隧道联调未作为本阶段通过依据；如进入云端验收，需要另开云上运行门禁，并以新项目链路做 smoke。

## 8. Final Gate Decision

- Day9-Day10 前端回归与审核交付：Pass。
- 后端阶段：No-Go until explicitly re-gated.
