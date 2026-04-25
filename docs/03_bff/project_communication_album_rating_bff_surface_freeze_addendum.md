---
owner: Codex 总控
status: frozen
purpose: Freeze L4 BFF surface for project communication, project album, and counterparty rating.
layer: L4 BFF
freeze_date_local: 2026-04-24
based_on:
  - docs/01_contracts/project_communication_album_rating_contract_freeze_addendum.md
---

# 《项目沟通 / 相册 / 互评 BFF surface freeze》

## 1. BFF Scope

- BFF may:
  - forward auth/session headers
  - normalize ids
  - shape read models
  - map Server errors to app-facing codes
- BFF may not:
  - create chat truth
  - persist album photos
  - compute rating state
  - compute credit score

## 2. Routes

- BFF must expose the app-facing routes listed in the route table.
- BFF must keep existing:
  - `/api/app/message/counterpart-conversation/detail`
  - `/api/app/project/name-access/thread/detail`
  - `/api/app/bid/thread/detail`

## 3. Visibility

- BFF may trim fields for unsupported clients.
- BFF may not leak hidden project names.
- BFF may not return album FileAsset access URLs unless Server/File access policy permits it.

## 4. Error Mapping

- Auth failures remain `AUTH_SESSION_INVALID`.
- Permission failures remain feature-specific `*_FORBIDDEN`.
- Missing anchors remain feature-specific `*_UNAVAILABLE`.
- Validation failures remain feature-specific `*_INVALID`.
