---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the only allowed next action after the remote Server cloud-runtime
  alignment passes for the public resource download zone, limiting work to the
  active remote BFF runtime on `47.108.180.198`.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_server_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_cloud_runtime_integration_validation_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_execution_receipt_addendum.md
  - docs/03_bff/project_public_resource_download_zone_bff_surface_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 BFF Cloud Runtime Alignment 派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `公共资源下载区 BFF cloud runtime alignment`
- 当前不是：
  - 新功能扩面
  - Server 对齐
  - Flutter 联调
  - `release-prep`
  - production release

## 2. Dispatch Scope

- 当前只允许处理：
  - remote active `BFF` runtime
  - remote current / dist / restart / proof closure
- 当前远端目标固定为：
  - host:
    - `47.108.180.198`
  - runtime root:
    - `/srv/workspaces/exhibition-infra-monorepo/apps/bff`
  - active port:
    - `3201`
  - canonical path:
    - `GET /api/app/project/public-resources`

## 3. Strict Prohibitions

- 当前严格禁止：
  - 改 `Server`
  - 改 `Flutter`
  - 改 `Admin`
  - 新增 `/download` 或 `/access` 别名 path
  - 新增 template-config proxy
  - 把 `BFF` 写成 truth owner
  - 写任何 `release-prep / production release` 口径

## 4. Required Proof

- 本轮必须形成的证据固定为：
  - remote active `GET http://127.0.0.1:3201/api/app/project/public-resources = 200`
  - 未带 token 时应返回受控 `401`，不再是 raw `Cannot GET`
  - response body matches frozen minimum shaping
  - actual upstream 命中：
    - `GET /server/projects/public-resources`
  - shared `file/access` reuse 保持不变
- 当前还必须同时解释：
  - 为什么 remote `POST /api/app/auth/otp/login` 曾 raw `404`
  - 为什么 remote active BFF process 与 dist / current / pid 发生漂移

## 5. Receipt Format

- 回执只允许提交：
  - `bff cloud runtime-alignment receipt`
  - `exact root cause`
  - `touched runtime paths`
  - `active dist / current / restart evidence`
  - `direct /api/app/project/public-resources response proof`
  - `blocked items`

## 6. Next Unique Action

- 下一轮唯一动作：
  - 只有在 `BFF cloud runtime receipt` 提交且总控复核通过后，才允许重做远端 `cloud runtime integration validation`
