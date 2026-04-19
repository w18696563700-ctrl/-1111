---
owner: Codex 总控
status: frozen
purpose: >
  Record the remote Server shared file-access cloud-runtime alignment receipt
  for the public resource download zone, freezing that the actual shared
  download reuse is now closed on `47.108.180.198` and that remote cloud
  integration validation may be rerun.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_server_file_access_cloud_runtime_alignment_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_cloud_runtime_alignment_receipt_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 Server Shared File-Access Cloud Runtime Alignment 回执单》

## 1. Current Scope

- 当前回执对象：
  - `公共资源下载区`
  - `remote Server shared file-access cloud runtime alignment`
- 当前远端目标固定为：
  - host:
    - `47.108.180.198`
  - runtime root:
    - `/srv/workspaces/exhibition-infra-monorepo/apps/server`
  - active port:
    - `3301`

## 2. Exact Root Cause

- 当前根因固定为：
  - remote active `3301` 的 `current/app.module.js` 先前未注册任何 `server/file` controller
  - 因此 `GET /server/file/access` 先前命中的是 Express raw `404 Cannot GET`
  - 旧 file-access 实现虽然存在于远端 `modules/evidence/*`，但该实现绑定 forum/evidence 家族，不能直接闭合当前 `project_public_resources.file_asset_id -> file_asset.id` 的 shared public-resource download
  - 本轮实际收口方式固定为：
    - 将 shared `file/access` 挂入当前 active graph 中的 `ProjectModule`
    - 只消费当前 `project_public_resources + file_asset` truth family

## 3. Runtime Alignment Result

- 当前已对齐结果固定为：
  - remote active process 仍为：
    - `node current/main.js`
  - active pid 已切到：
    - `485625`
  - 启动日志已映射：
    - `ProjectSharedFileAccessController {/server/file}`
    - `Mapped {/server/file/access, GET}`
- 当前这也解释了：
  - 为什么此前 active route graph 不含该 path
  - 为什么当前 route graph 现已含该 path

## 4. Response Proof

- 当前 no-auth smoke 已成立：
  - `GET http://127.0.0.1:3301/server/file/access?fileAssetId=test&mode=download = 401 AUTH_SESSION_INVALID`
  - `GET http://127.0.0.1:3201/api/app/file/access?fileAssetId=test&mode=download = 401 AUTH_SESSION_INVALID`
  - 两条都已不再是 raw `404`
- 当前 authenticated proof 已成立：
  - direct server:
    - `GET http://127.0.0.1:3301/server/file/access?... = 200`
  - via BFF shared reuse:
    - `GET http://127.0.0.1:3201/api/app/file/access?... = 200`
- 当前返回已证明：
  - same `fileAssetId`
  - same `mode=download`
  - same `fileName`
  - same `mimeType`
  - same signed `accessUrl`
  - signed URL 指向：
    - `zhanlanzhuangxiuzhijia.s3.oss-cn-chengdu.aliyuncs.com`

## 5. Blocked Items

- 当前 scope 内无阻断项。
- 当前仍保留一个残留说明：
  - remote `src` snapshot 仍落后于 active `dist/current`
  - 该残留不阻断当前 `file/access` cloud runtime receipt 成立

## 6. Formal Receipt Conclusion

- 当前正式回执结论固定为：
  - `Server shared file-access cloud runtime alignment = PASS`
  - `remote active /server/file/access = PASS`
  - `remote active /api/app/file/access = PASS`
  - `shared file/access actual download reuse closure = PASS`
- 当前不等于：
  - source baseline 全面对齐
  - `release-prep`
  - production release

## 7. Next Unique Action

- 下一轮唯一动作：
  - 重做《公共资源下载区 remote cloud runtime integration validation》
