---
owner: Codex 总控
status: frozen
purpose: >
  Record the remote Server cloud-runtime alignment receipt for the public
  resource download zone, freezing that the active `47.108.180.198:3301`
  process, DB migration state, and catalog response have now been aligned even
  though the remote source snapshot remains behind.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_server_cloud_runtime_alignment_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_cloud_runtime_integration_validation_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_backend_execution_receipt_addendum.md
  - docs/02_backend/project_public_resource_download_zone_backend_truth_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 Server Cloud Runtime Alignment 回执单》

## 1. Current Scope

- 当前回执对象：
  - `公共资源下载区`
  - `remote Server cloud runtime alignment`
- 当前远端目标固定为：
  - host:
    - `47.108.180.198`
  - runtime root:
    - `/srv/workspaces/exhibition-infra-monorepo/apps/server`
  - active port:
    - `3301`

## 2. Exact Root Cause

- 当前根因固定为：
  - remote source snapshot 未收到 `project-public-resource` 特性文件
  - remote active process 先前绑定的是旧 nested dist
  - remote `current` 先前缺位
  - remote active DB 先前不存在 `project_public_resources`
  - remote login proof 在运行态还缺 legal-consent env，后补齐 `AUTH_USER_AGREEMENT_VERSION / AUTH_PRIVACY_POLICY_VERSION` 才能获得 proof token

## 3. Runtime Alignment Result

- 当前已对齐结果固定为：
  - remote active process 已切到：
    - `node current/main.js`
  - remote active pid 已对齐：
    - `481002`
  - remote health 已成立：
    - `GET /health/live = 200`
  - remote route 已映射：
    - `ProjectPublicResourceController {/server/projects/public-resources}`
    - `Mapped {/server/projects/public-resources, GET}`

## 4. Migration And DB Proof

- 当前 remote active DB 已成立：
  - `public.project_public_resources` exists
  - migration key:
    - `20260414_project_public_resource_download_zone_truth`
    - 已落入 `server_schema_migration`
  - current catalog row count:
    - `1`
- 当前 proof row 已存在：
  - `cloud-runtime-alignment-public-resource-20260414`
  - `other_resource`
  - `app_shared`

## 5. Response Proof

- 当前 remote active catalog response 已成立：
  - `GET http://127.0.0.1:3301/server/projects/public-resources = 200`
- 当前返回字段固定为最小集合：
  - `resourceId`
  - `resourceCategory`
  - `title`
  - `summary`
  - `fileAssetId`
  - `fileName`
  - `mimeType`
  - `visibility`
  - `sortOrder`
  - `publishedAt`
- 当前还已证明：
  - `visibility=app_shared`
  - `objectKey` 未泄露

## 6. Residual Caveat

- 当前仍保留一个残留说明：
  - remote source snapshot 仍落后于 active dist/current
  - 该残留不阻断当前 remote Server runtime receipt 成立
  - 但它不能被写成远端 source baseline 已完成整体对齐

## 7. Formal Receipt Conclusion

- 当前正式回执结论固定为：
  - `Server cloud runtime alignment = PASS`
  - `remote active 3301 catalog proof = PASS`
  - `remote active DB carrier proof = PASS`
- 当前允许含义：
  - 可以进入 `BFF cloud runtime alignment`
- 当前不允许含义：
  - 不允许跳到 `release-prep`
  - 不允许把远端 source snapshot 残留写成已解决

## 8. Next Unique Action

- 下一轮唯一动作：
  - 向 `BFF` 发出《公共资源下载区｜BFF cloud runtime alignment》执行口令
