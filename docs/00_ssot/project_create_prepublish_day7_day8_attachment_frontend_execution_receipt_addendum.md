---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day7-Day8 Flutter frontend execution and local verification
  result for prepublish-stage project attachment entry/copy convergence, while
  preserving the existing FileAsset and project_attachments truth chain.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - docs/00_ssot/project_create_prepublish_day7_day8_attachment_frontend_gate_checklist_addendum.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/00_ssot/project_prepublish_day4_confirmation_flow_brief_addendum.md
  - docs/00_ssot/project_create_prepublish_day5_day6_frontend_execution_receipt_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
---

# 《Day7-Day8 附件体验与本地验证执行回执》

## 0. 总结论

Day7-Day8 已完成 Flutter 前端附件入口与文案收敛，并完成本地验证。

当前更稳的结果：

- 预发布详情继续作为 `submitted = 预发布列表` 的正式补资料主面，明确开放 `效果图 / 施工图 / 其他资料`。

当前更省成本的结果：

- 未改附件接口、未改 BFF / Server / contracts，继续复用现有 `/api/app/my/projects/{projectId}/attachments*`。

当前阶段最适合的结果：

- 通过文案和入口让发布方知道“补项目详情文书后再确认发布”，不把创建页变成附件/交易总控台。

风险更大的路径已拦截：

- 未新增 `prepublish` 状态，未让 `draft` 进入正式附件走廊，未把 `objectKey` 当业务真值，未改 `init -> direct upload -> confirm -> bind`。

## 1. Flutter Changes

1. 创建页附件提示：
   - 明确 `进入预发布列表后即可补充效果图、施工图和其他资料`。
   - 草稿阶段继续只提示，不开放正式附件上传入口。

2. 我的项目详情摘要入口：
   - 对可补资料状态展示：
     - `项目详情文书：预发布阶段已开放效果图、施工图和其他资料。`
     - 主按钮 `补充项目详情文书`。

3. 预发布详情阶段动作：
   - 发布前确认文案改为先说明 `预发布阶段已开放项目详情文书区`。
   - 继续提示先补充 `效果图 / 施工图 / 其他资料`，再点击 `检查无误，确定发布`。

4. 项目详情文书区：
   - summary 收敛为 `预发布阶段已开放效果图、施工图和其他资料。补齐后再检查无误并正式发布。`
   - 空态收敛为 `当前还没有补充效果图、施工图或其他资料。`

## 2. Truth Chain Evidence

1. 附件类型仍为现有三类：
   - `effect_image`
   - `construction_doc`
   - `other_material`

2. 现有上传链路未改：
   - `init`
   - `direct upload`
   - `confirm`
   - `bind`

3. 业务真值未改：
   - `FileAsset` 仍只是上传资产真值。
   - bind 成功后的 `project_attachments` 仍是项目附件业务真值。

4. 状态边界未改：
   - `submitted / published / bidding_closed / awarded / converted_to_order` 可进入 owner 附件走廊。
   - `draft / archived` 不进入正式附件走廊。

5. BFF / Server 边界未改：
   - 未修改 `apps/bff/**`。
   - 未修改 `apps/server/**`。
   - 未修改 contracts / OpenAPI。

## 3. Local Verification

本地验证命令：

```text
dart format apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart apps/mobile/test/my_project_private_carry_test.dart apps/mobile/test/project_attachment_prepublish_and_bid_materials_test.dart apps/mobile/test/project_attachment_corridor_test.dart
flutter analyze lib/features/exhibition/presentation/pages/my_project_detail_page.dart lib/features/exhibition/presentation/pages/project_create_page.dart lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart test/my_project_private_carry_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart test/project_attachment_corridor_test.dart
flutter test test/project_showcase_filter_create_refactor_test.dart test/my_project_private_carry_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart test/project_attachment_corridor_test.dart test/project_publish_round_a_productization_test.dart
```

结果：

```text
flutter analyze: No issues found.
flutter test: 44 tests passed.
```

覆盖范围：

1. 创建页字段与预发布附件提示。
2. 创建页保存、草稿、提交到预发布列表。
3. 我的项目列表到预发布详情跳转。
4. 预发布详情附件入口。
5. 附件走廊的选择、上传、confirm、bind、删除、空态和失败提示。
6. bid-submit 只读附件投影展开后读取 `效果图 / 施工图`。

验证备注：

- 第一轮验证失败点仅为测试断言仍使用旧入口文案和旧滚动锚点。
- 修正范围仅限 Flutter 测试断言；未因失败回退或改动 BFF / Server。

## 4. Remaining Gates

1. Cloud tunnel route smoke：本轮未执行。
2. Computer Use 联调：本轮未执行。
3. BFF / Server release：本轮 No-Go。

下一步结论：

```text
Go for Day7-Day8 frontend closure.
No-Go for BFF / Server / contract changes.
No-Go for attachment truth-chain changes.
Conditional Go for later tunnel + Computer Use verification if product needs runtime screenshot evidence.
```
