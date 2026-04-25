---
owner: Codex 总控
status: active
purpose: Submit Day-1 stage gate checklist for project communication, project album, and counterparty rating.
layer: L0 SSOT
updated_at: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_field_table_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
  - docs/01_contracts/project_communication_album_rating_contract_freeze_addendum.md
  - docs/02_backend/project_communication_album_rating_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_communication_album_rating_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_communication_album_rating_frontend_consumption_freeze_addendum.md
---

# 《项目沟通 / 相册 / 互评 Day-1 阶段门禁核查表》

## 1. Passed Gates

- L0-L5 文书链：
  - passed
- 字段表：
  - passed
- 路由表：
  - passed
- Server truth owner：
  - passed
- BFF no-truth-owner：
  - passed
- Flutter only talks to BFF：
  - passed
- 三对象分离：
  - passed
- `projectId` 强制锚定：
  - passed

## 2. Failed Gates

- Server implementation gate：
  - failed
  - 尚未实现新表、新 service、新 controller。
- BFF implementation gate：
  - failed
  - 尚未实现新 app-facing route。
- Flutter implementation gate：
  - failed
  - 尚未改造项目沟通页和相册/互评 UI。
- cloud integration gate：
  - failed
  - 尚未针对新对象联调。

## 3. Veto Gates

- 不得无 `projectId` 创建聊天、相册、评价。
- 不得把项目相册复用为 owner-private `project_attachments`。
- 不得把互评复用为单向买方评价而丢失 `rater/ratee`。
- 不得把信用分由 Flutter 或 BFF 计算。
- 不得跳过 50 张上限的 Server 校验。

## 4. Stage Decision

- `Go` for：
  - Day-2 Server skeleton implementation。
  - Day-3 Server read/write implementation。
- `No-Go` for：
  - BFF / Flutter 提前伪造新对象。
  - 生产切主入口。
  - 实时推送扩面。

## 5. Next Stage Allowed

- 是否允许下一阶段：
  - `Yes, Server implementation only within frozen boundary`
