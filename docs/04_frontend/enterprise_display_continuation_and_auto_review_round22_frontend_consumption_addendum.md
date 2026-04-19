---
owner: Codex 总控
status: frozen
purpose: Freeze frontend consumption behavior for enterprise display continuation after review results, published-change case continuation, and auto-review v1 display boundaries.
layer: L3 Frontend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/02_backend/enterprise_display_continuation_and_auto_review_round22_backend_truth_scope_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_application_status_support.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_truth_sections.dart
---

# Enterprise Display Continuation And Auto-Review Round22 Frontend Consumption

## 1. Consumption Objective

- 让未发布申请在出现正式审核结果后仍能继续进入新的测试轮次。
- 让已发布展示的修改与新增案例入口更明确地承接到 `published-change corridor`。
- 保持 auto-review 判断权仅在 `Server`。

## 2. Unpublished Continuation Rule

- 当最近申请状态是：
  - `approved`
  - `revision_required`
  - `rejected`
  前端必须允许用户显式执行：
  - `重新创建申请草稿`
- 该入口必须复用现有 `createApplication(...)`。
- 前端不得通过本地重置状态把旧申请伪装成 `draft`。

## 3. Published Change Rule

- 对已发布展示：
  - 保存基础资料
  - 保存联系人
  - 保存案例
  都只写入 `current change carrier`
- 前端文案必须明确：
  - 保存修改不会直接改线上展示
  - 新增案例进入的是当前变更内容
  - `approved` 不等于已上线
  - `applied` 才等于写入 live listing

## 4. Auto-Review Display Rule

- round22 前端不得本地推断 auto-review。
- 若当前 round 不新增 `reviewSource` 展示字段，则：
  - 继续只按 `applicationStatus` 展示
- 若后续 backend/bff 明确新增：
  - `reviewSource`
  前端才能补“系统自动通过 / 人工审核通过”的差异文案。

## 5. Allowed Write Set

- round22 frontend 优先允许：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_application_status_support.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_submit_sections.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_truth_sections.dart`
  - `apps/mobile/test/**`

## 6. Anti-revert

- 不得把 `approved` 直接展示成“已发布”。
- 不得把已发布展示页的保存修改伪装成已直接改 live。
- 不得在前端本地发明 auto-review 规则。

## 7. Formal Conclusion

- round22 frontend consumption 已冻结为：
  - `post-submit recreate-draft entry for unpublished continuation`
  - `clear published-change corridor entry and wording`
  - `server-owned auto-review display boundary`
