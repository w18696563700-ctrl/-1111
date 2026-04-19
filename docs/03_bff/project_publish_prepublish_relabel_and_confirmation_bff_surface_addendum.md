---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L4 BFF surface boundary for the prepublish relabel and publish
  confirmation round, keeping existing app-facing submit/publish transport
  unchanged while forbidding any BFF-owned prepublish truth.
layer: L4 BFF
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/01_contracts/project_publish_prepublish_relabel_and_confirmation_contract_freeze_addendum.md
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/project/project-lifecycle.service.ts
---

# 《项目发布对象簇｜预发布列表命名与发布确认重排 L4 BFF surface freeze》

## 1. Surface Conclusion

- `BFF` 当前继续只暴露既有 app-facing path family：
  - `save`
  - `submit`
  - `publish`
  - `withdraw`
  - `archive`
- 当前正式禁止新增任何 `prepublish` alias path。

## 2. Mapping Rule

- `保存到预发布列表`
  在 `BFF` 层仍然只对应：
  - `POST /api/app/project/submit`
- `检查无误，确定发布`
  在 `BFF` 层仍然只对应：
  - `POST /api/app/project/publish`
- `BFF` 不得把 user-facing label 改写为新的 canonical command family。

## 3. Response / Error Boundary

- accepted response 当前继续只返回：
  - `projectId`
  - `state`
- `BFF` 不新增：
  - `displayStage`
  - `nextPrimaryAction`
  - `isPrepublish`
- `BFF` 继续只做：
  - request normalization
  - payload shaping
  - error normalization

## 4. Forbidden Drift

- 当前正式禁止：
  - `BFF` 自行宣布 `submitted = prepublish truth`
  - `BFF` 自行决定最终发布确认面
  - `BFF` 根据前端文案新增第二状态机
