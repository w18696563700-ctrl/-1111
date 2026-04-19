---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the app-facing and server-facing contract boundary for approved
  organization certification correction.
layer: L2 Contracts
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_revalidation_entry_ruling_addendum.md
---

# 《认证资料更正 Contracts 补充冻结》

## 1. Approved Path Family

- 当前轮正式新增：
  - `POST /api/app/profile/certification/revalidate`
  - `POST /server/profile/certification/revalidate`

## 2. Command Purpose

- 该命令仅用于：
  - 已认证通过组织的资料更正
- 该命令不是：
  - 初次提交认证
  - rejected/expired 的重新提交

## 3. Request Shape

- 请求体最小字段冻结为：
  - `organizationId`
  - `legalName`
  - `uscc`
  - `licenseFileId`
  - `correctionNote` optional

## 4. Success Shape

- 成功响应继续复用认证 accepted view：
  - `organizationId`
  - `certificationStatus`
  - `submittedAt`
  - `traceId`

## 5. Runtime Rule

- `approved` 组织可发起 `revalidate`
- 命令成功时：
  - `certificationStatus` 仍为 `approved`
- 命令失败时：
  - 返回受控错误
  - 不改变当前正式认证 truth

## 6. Explicit Non-scope

- 当前不新增：
  - `certification/revalidate/current`
  - `revalidation list`
  - `revalidation detail`
  - `revalidation review`
  - 新认证状态字段

## 7. Current Read Clarification

- `GET /api/app/profile/certification/current` 继续以当前正式认证 truth 为主。
- 由于当前轮不引入待审核 shadow truth：
  - 本轮不存在必须新增的 `pending revalidation` read object
  - Flutter 如需说明“当前是否处于待审核更正中”，必须按冻结口径展示：
    - 当前轮没有独立待审核更正状态
