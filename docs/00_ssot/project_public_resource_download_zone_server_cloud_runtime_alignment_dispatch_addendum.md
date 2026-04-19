---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the only allowed next action after the failed remote cloud-runtime
  integration validation for the public resource download zone, limiting work
  to active remote Server runtime alignment on `47.108.180.198`.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_cloud_runtime_integration_validation_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_backend_execution_receipt_addendum.md
  - docs/02_backend/project_public_resource_download_zone_backend_truth_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 Server Cloud Runtime Alignment 派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `公共资源下载区 Server cloud runtime alignment`
- 当前不是：
  - 新功能扩面
  - BFF 对齐
  - Flutter 联调
  - `release-prep`
  - production release

## 2. Dispatch Scope

- 当前只允许处理：
  - remote active `Server` runtime
  - remote active migration state
  - remote release / current / dist / restart / proof closure
- 当前远端目标固定为：
  - host:
    - `47.108.180.198`
  - runtime root:
    - `/srv/workspaces/exhibition-infra-monorepo/apps/server`
  - active port:
    - `3301`
  - canonical path:
    - `GET /server/projects/public-resources`

## 3. Strict Prohibitions

- 当前严格禁止：
  - 改 `BFF`
  - 改 `Flutter`
  - 改 `Admin`
  - 新增 route family
  - 新增第二 truth
  - 新增第二 state machine
  - 写任何 `release-prep / production release` 口径

## 4. Required Proof

- 本轮必须形成的证据固定为：
  - remote active `GET http://127.0.0.1:3301/server/projects/public-resources = 200`
  - response body includes frozen minimal catalog fields
  - remote active DB 上 `project_public_resources` relation exists
  - response body does not expose `objectKey`
  - proof must come from remote active runtime and remote active DB only
- 当前还必须同时解释：
  - 为什么 remote grep 未命中 `public-resources`
  - 为什么 remote active process 与源码 / dist / current 发生漂移

## 5. Receipt Format

- 回执只允许提交：
  - `server cloud runtime-alignment receipt`
  - `exact root cause`
  - `touched runtime paths`
  - `active release / current / restart evidence`
  - `migration execution evidence`
  - `direct /server/projects/public-resources response proof`
  - `blocked items`

## 6. Next Unique Action

- 下一轮唯一动作：
  - 只有在 `Server cloud runtime receipt` 提交且总控复核通过后，才允许向 `BFF` 发出 `BFF cloud runtime alignment` 派工单
