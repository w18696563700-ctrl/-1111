---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 contract conclusion for the prepublish relabel and publish
  confirmation round, explicitly keeping canonical state/path unchanged while
  binding the user-facing `预发布列表` wording to the existing `submitted`
  carrier only.
layer: L2 Contract
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/server/src/modules/project/project.controller.ts
---

# 《项目发布对象簇｜预发布列表命名与发布确认重排 L2 contract freeze》

## 1. Contract Delta Conclusion

- 本轮 contract 结论固定为：
  - `No canonical path delta`
  - `No schema delta`
  - `No enum delta`
- 当前 user-facing `预发布列表`
  只允许建立在既有 canonical state `submitted` 之上。

## 2. Canonical Path Freeze

- 当前继续沿用：
  - `POST /api/app/project/save`
  - `POST /api/app/project/submit`
  - `POST /api/app/project/publish`
  - `POST /api/app/project/withdraw`
  - `POST /api/app/project/archive`
- 当前正式禁止新增：
  - `POST /api/app/project/save-to-prepublish`
  - `POST /api/app/project/confirm-publish`
  - 任意 `prepublish*` path family

## 3. State Freeze

- `ProjectState` 当前继续只承认：
  - `draft`
  - `submitted`
  - `published`
  - `bidding_closed`
  - `awarded`
  - `converted_to_order`
  - `archived`
- 当前正式禁止新增：
  - `prepublish`
  - `prepublished`
  - `publish_review`

## 4. Request / Response Freeze

- `submitProject` accepted response 的 `state`
  继续固定为：
  - `submitted`
- `publishProject` accepted response 的 `state`
  继续固定为：
  - `published`
- 当前正式禁止：
  - 在 action response 中返回
    `userStageLabel`
  - 返回
    `isPrepublish`
  - 返回
    `confirmPublishLabel`

## 5. Contract Meaning Freeze

- 当前 contract 只冻结 canonical meaning：
  - `submit` = `draft -> submitted`
  - `publish` = `submitted -> published`
- `预发布列表`
  只是 owner-facing consumption wording，
  不是 contract truth value。
