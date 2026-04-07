---
owner: Codex 总控
status: frozen
purpose: Freeze the only allowed next action after the failed integration verification for `我的楼 Round 1`, limiting work to active BFF runtime alignment on the app-facing my-project detail carrier.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_round1_integration_verification_review_conclusion_addendum.md
  - docs/00_ssot/my_building_round1_integration_verification_independent_review_addendum.md
  - docs/00_ssot/my_building_round1_increment_dispatch.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/my_project/my-project.service.ts
  - apps/bff/src/routes/my_project/my-project.read-model.ts
---

# 《我的楼 Round 1 BFF runtime alignment 派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `我的楼 Round 1 viewerProjectRelation app-facing runtime alignment`
- 当前不是：
  - 新功能扩面
  - release-prep
  - launch approval
  - closure

## 2. Dispatch Scope

- 当前只允许处理：
  - active BFF runtime on the app-facing `my-project detail` chain
- 当前允许范围固定为：
  - `GET /api/app/my/projects/{projectId}`
  - `publicProject.viewerProjectRelation` carrier retention
  - 相关 active release / dist / restart / proof closure
- 当前允许改动边界：
  - local repo:
    - [apps/bff/src/routes/my_project/**](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/my_project)
  - active runtime:
    - `/srv/apps/bff/current`
    - `/srv/releases/bff/20260404160902/apps/bff`
- 如 route wiring truly required：
  - only minimal wiring touch

## 3. Strict Prohibitions

- 当前严格禁止：
  - 改 `Server`
  - 改 `Flutter`
  - 新增 route family
  - 新增 second truth
  - 新增 second state machine
  - 新增 package
  - 新增 scope
  - 把 `BFF` 写成 truth owner
  - 写任何 release-prep / launch / closure 口径

## 4. Required Proof

- 本轮必须形成的证据固定为：
  - active app-facing `GET /api/app/my/projects/{projectId} = 200`
  - response body includes:
    - `publicProject.viewerProjectRelation`
  - proof must come from:
    - `http://127.0.0.1:8080`
    - or host-local `:80 /api/app/*`
  - not from:
    - direct `/server/*` only
- 当前还必须保持：
  - grouped list 结构不变
  - `401` / `404` 错误归一不变
  - owner manage shell 仍只是 surface，不是 action execution

## 5. Receipt Format

- 回执只允许提交：
  - `runtime-alignment correction receipt`
  - `inspected runtime paths`
  - `exact root cause`
  - `touched paths`
  - `rebuild / restart evidence`
  - `direct /api/app/* response proof`
  - `blocked items`

## 6. Next Unique Action

- 下一轮唯一动作：
  - 只有在 BFF runtime alignment receipt 提交且总控复核通过后，才允许重做 `development-stage integration verification`
