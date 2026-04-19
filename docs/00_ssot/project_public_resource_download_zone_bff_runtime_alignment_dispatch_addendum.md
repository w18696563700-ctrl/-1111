---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the only allowed next action after the Server runtime-alignment pass
  for the public resource download zone, limiting work to active BFF runtime
  alignment on the app-facing catalog path.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_result_verification_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_execution_receipt_addendum.md
  - docs/03_bff/project_public_resource_download_zone_bff_surface_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 BFF runtime alignment 派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `公共资源下载区 BFF runtime alignment`
- 当前不是：
  - 新功能扩面
  - integration verification rerun
  - `release-prep`
  - production release
  - closure

## 2. Dispatch Scope

- 当前只允许处理：
  - active `BFF` runtime
  - active release / current / dist / restart / proof closure
- 当前允许范围固定为：
  - `GET /api/app/project/public-resources`
  - app-facing path mapping to `/server/projects/public-resources`
  - controlled error normalization
  - directly associated active runtime evidence
- 当前允许改动边界：
  - local repo:
    - [apps/bff/src/routes/project/**](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project)
  - active runtime:
    - [runtime/package1-isolated](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated)
    - [runtime/package1-isolated/bin/start-bff.sh](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bin/start-bff.sh)
    - [runtime/package1-isolated/logs/bff-3201.log](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/logs/bff-3201.log)
    - [runtime/package1-isolated/bff.pid](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bff.pid)
    - [apps/bff/dist/apps/bff/src/main.js](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/dist/apps/bff/src/main.js)

## 3. Strict Prohibitions

- 当前严格禁止：
  - 改 `Server`
  - 改 `Flutter`
  - 改 `Admin`
  - 新增第二下载 path
  - 新增 template-config proxy
  - 把 `BFF` 写成 truth owner
  - 写任何 `integration gate passed / release-prep / production release` 口径

## 4. Required Proof

- 本轮必须形成的证据固定为：
  - active runtime `GET http://127.0.0.1:3201/api/app/project/public-resources = 200`
  - response body matches frozen minimum shaping
  - route no longer returns raw `Cannot GET`
  - proof must come from active app-facing runtime only
- 当前还必须保持：
  - shared `file/access` reuse 不变
  - 不新增 `/download` 或 `/access` 别名 path

## 5. Receipt Format

- 回执只允许提交：
  - `bff runtime-alignment correction receipt`
  - `exact root cause`
  - `active release and restart evidence`
  - `direct /api/app/* response proof`
  - `blocked items`

## 6. Next Unique Action

- 下一轮唯一动作：
  - 只有在 BFF runtime alignment receipt 提交且总控复核通过后，才允许重做 `公共资源下载区 result verification`
