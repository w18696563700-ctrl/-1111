---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the only allowed next action after the remote BFF cloud-runtime
  alignment receipt for the public resource download zone, limiting work to the
  shared file-access upstream on remote Server because actual download proof is
  still blocked there.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bff_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_cloud_runtime_integration_validation_review_conclusion_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 Server Shared File-Access Cloud Runtime Alignment 派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `公共资源下载区 Server shared file-access cloud runtime alignment`
- 当前不是：
  - 新功能扩面
  - BFF 再次对齐
  - Flutter 联调
  - `release-prep`
  - production release

## 2. Dispatch Scope

- 当前只允许处理：
  - remote active `Server` shared file-access runtime
  - remote current / dist / restart / proof closure
- 当前远端目标固定为：
  - host:
    - `47.108.180.198`
  - runtime root:
    - `/srv/workspaces/exhibition-infra-monorepo/apps/server`
  - active port:
    - `3301`
  - canonical path:
    - `GET /server/file/access`

## 3. Strict Prohibitions

- 当前严格禁止：
  - 改 `BFF`
  - 改 `Flutter`
  - 改 `Admin`
  - 新增第二下载协议
  - 新增 project-resource 自有 `/download` path
  - 写任何 `release-prep / production release` 口径

## 4. Required Proof

- 本轮必须形成的证据固定为：
  - remote active `GET http://127.0.0.1:3301/server/file/access?... = 200` 或 contract-consistent受控下载响应
  - remote active `GET http://127.0.0.1:3201/api/app/file/access?... = contract-consistent`，且不再因 upstream 缺失而失败
  - 证明 shared `file/access` 实际下载复用闭合
  - proof must come from remote active runtime only
- 当前还必须同时解释：
  - 为什么 remote `GET /server/file/access` 曾 raw `404`
  - 为什么当前 active Server dist / current / route graph 未包含该 path

## 5. Receipt Format

- 回执只允许提交：
  - `server shared file-access cloud runtime receipt`
  - `exact root cause`
  - `touched runtime paths`
  - `active release / current / restart evidence`
  - `direct /server/file/access and /api/app/file/access response proof`
  - `blocked items`

## 6. Next Unique Action

- 下一轮唯一动作：
  - 只有在 `Server shared file-access cloud runtime receipt` 提交且总控复核通过后，才允许重做远端 `cloud runtime integration validation`
