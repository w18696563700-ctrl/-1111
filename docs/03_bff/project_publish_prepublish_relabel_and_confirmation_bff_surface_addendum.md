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

## Pricing Override Note

当前 `publish` 的 app-facing path、命名与主体 request shape 继续沿用本文件。

但自 [platform_pricing_bff_surface_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/platform_pricing_bff_surface_master_v1.md) 生效后，本文件不再拥有收费 gate authority。

当前正式补充冻结如下：

1. `POST /api/app/project/publish` 仍是 canonical publish path
2. 若 `Server` 判定当前项目必须先完成 `200 元项目真实性诚意金`，`BFF` 必须 fail closed
3. `BFF` 不得把收费 gate 错误伪装成普通 publish 成功或普通文案切换问题
4. publish 前的收费前置动作由 `pricing-summary + authenticity-sincerity orders` 家族承接，不在本文件内另起第二条 publish 语义

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
