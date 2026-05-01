---
owner: Codex 总控
status: accepted
purpose: Record the execution and local verification result for the Flutter-only draftbox landing UX fix.
layer: L0 SSOT
---

# Project Create Draftbox Landing Execution Receipt

## 1. Scope Executed

Completed the bounded Flutter-only UX fix frozen by:

- `docs/04_frontend/project_create_draftbox_landing_frontend_ux_freeze_addendum.md`
- `docs/00_ssot/project_create_draftbox_landing_stage_gate_checklist_addendum.md`

Implemented surfaces:

- project create submit button copy and rich label;
- create success landing to owner-side draft stage;
- `MyProjectListPage` route-stage selection and optional card highlight;
- draft edit progress red note;
- publish progress second-step copy.

## 2. Explicit Non-changes

This execution did not change:

- BFF routes;
- Server truth or lifecycle state;
- contracts;
- cloud runtime;
- database data;
- five-material upload flow;
- standalone draftbox page structure.

## 3. Local Verification

Command:

```bash
cd apps/mobile
flutter test test/project_publish_round_a_productization_test.dart test/my_project_private_carry_test.dart test/shell_app_test.dart --name "(create submit button highlights draftbox landing copy|create success lands in my project draftbox and highlights item|我的项目路由可以直接钉到草稿阶段并高亮项目|project create local validation stays user-facing|Round A validation shows unified message|Round A validation keeps scope summary optional|Round A create page keeps selector)"
```

Result:

- `7/7` targeted tests passed.

Covered acceptance points:

- create button copy is `保存并跳转至我的项目草稿箱`;
- `我的项目草稿箱` is rendered as a red bold span;
- create success navigates to draft stage with `projectId`;
- the draft item can be highlighted after landing;
- explicit `stage=draft` is not overridden by payload-preferred stage;
- publish progress shows `（本页仅做基础信息核对和修改）`;
- second progress step shows `进入预发布列表 / 补齐五类资料`;
- old local validation behavior remains user-facing.

## 4. Residual Risk

- This receipt is local Flutter verification only. It does not prove cloud
  create latency or real-account data visibility.
- If cloud list refresh is delayed, the page can still land in the correct
  draft stage before the newly created card appears.

## 5. Final Gate Decision

The bounded Flutter UX fix is locally accepted.

Next stage is allowed only for optional real-device or 8080 tunnel smoke test.
No backend, BFF, contract, or cloud change is authorized by this receipt.
