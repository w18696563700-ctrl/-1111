---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the only allowed next action after the failed result verification for
  the public resource download zone, limiting work to active Server runtime
  alignment on the canonical catalog truth path.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_result_verification_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_backend_execution_receipt_addendum.md
  - docs/02_backend/project_public_resource_download_zone_backend_truth_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 Server runtime alignment 派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `公共资源下载区 Server runtime alignment`
- 当前不是：
  - 新功能扩面
  - integration verification rerun
  - `release-prep`
  - production release
  - closure

## 2. Dispatch Scope

- 当前只允许处理：
  - active `Server` runtime
  - active migration state
  - active release / current / dist / restart / proof closure
- 当前允许范围固定为：
  - `GET /server/projects/public-resources`
  - `project_public_resources` carrier migration
  - directly associated systemd / release evidence
- 当前允许改动边界：
  - local repo:
    - [apps/server/src/modules/project/**](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project)
    - [apps/server/src/core/migrations/**](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations)
  - active runtime:
    - `/srv/apps/server/current`
    - `/srv/releases/server/**`

## 3. Strict Prohibitions

- 当前严格禁止：
  - 改 `BFF`
  - 改 `Flutter`
  - 改 `Admin`
  - 新增 route family
  - 新增第二 truth
  - 新增第二 state machine
  - 写任何 `integration gate passed / release-prep / production release` 口径

## 4. Required Proof

- 本轮必须形成的证据固定为：
  - active runtime `GET /server/projects/public-resources = 200`
  - response body includes frozen minimal catalog fields
  - `project_public_resources` relation exists in active DB
  - response body does not expose `objectKey`
  - proof must come from active runtime and active DB only
- 当前还必须保持：
  - contract freeze 字段不扩写
  - `template_config` 不被偷换成 App catalog truth

## 5. Receipt Format

- 回执只允许提交：
  - `server runtime-alignment correction receipt`
  - `exact root cause`
  - `active release and migration evidence`
  - `direct /server/* response proof`
  - `blocked items`

## 6. Next Unique Action

- 下一轮唯一动作：
  - 只有在 Server runtime alignment receipt 提交且总控复核通过后，才允许向 `BFF Agent` 发出 `BFF runtime alignment` 派工单
