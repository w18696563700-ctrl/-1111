---
owner: Codex 总控
status: frozen
purpose: Gate the bounded Flutter-only draftbox landing UX fix before implementation.
layer: L0 SSOT
---

# Project Create Draftbox Landing Stage Gate Checklist

## 1. Stage Object

Bounded object:

- project create success landing;
- owner-side draft stage selection;
- create button copy;
- edit-draft progress copy.

## 2. Passed Gates

- Formal UX truth is frozen in
  `docs/04_frontend/project_create_draftbox_landing_frontend_ux_freeze_addendum.md`.
- The route target is explicitly frozen as
  `/exhibition/my/projects?workspace=published&stage=draft&projectId={projectId}`.
- The red bold copy segment is explicitly frozen as `我的项目草稿箱`.
- The edit-page red note is explicitly frozen as
  `（本页仅做基础信息核对和修改）`.
- The progress step copy is explicitly frozen as
  `进入预发布列表 / 补齐五类资料`.

## 3. Failed Gates

- None for this bounded Flutter-only implementation.

## 4. Veto Gates

The next stage is blocked if implementation attempts any of the following:

- change BFF route shape;
- change Server truth or project lifecycle state;
- change contracts;
- deploy cloud services;
- introduce a standalone draftbox page;
- redesign the full prepublish material completion flow.

## 5. Next Stage Decision

Go for Flutter implementation only.

Allowed files or modules:

- Flutter create/edit project UI;
- Flutter my-project list route consumption;
- Flutter route helper and router query parsing;
- Flutter widget tests.

Not allowed:

- BFF;
- Server;
- contracts;
- cloud runtime;
- database data repair.
