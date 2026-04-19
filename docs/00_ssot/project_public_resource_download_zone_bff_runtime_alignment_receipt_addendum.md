---
owner: Codex 总控
status: frozen
purpose: >
  Record the active BFF runtime-alignment receipt for the public resource
  download zone after fixing the stale listener, aligning the active app-facing
  process with the current dist, and proving the canonical app-facing catalog
  route on the live runtime.
layer: execution receipt
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bff_runtime_alignment_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_execution_receipt_addendum.md
  - docs/03_bff/project_public_resource_download_zone_bff_surface_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 BFF runtime alignment receipt》

## 1. 当前 runtime-alignment 状态

- 当前 execution 状态必须固定为：
  - `公共资源下载区 Server runtime alignment 完成`
  - `公共资源下载区 BFF runtime alignment 完成`
  - `公共资源下载区 result verification 可重跑`

## 2. exact root cause

- active `3201` 在对齐前实际跑的是陈旧手工 PTY 进程：
  - `pid=97296`
  - `node apps/bff/dist/apps/bff/src/main.js`
- 当前 dist 已包含 `project-public-resource` 编译产物，
  但旧活跃进程从未重启到新 dist，
  所以 active runtime 上：
  - `GET /api/app/project/public-resources`
  仍缺失并返回 raw `404 Cannot GET ...`
- runtime 指针也曾漂移：
  - [bff.pid](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bff.pid) 为空
  - [bff-3201.log](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/logs/bff-3201.log) 只记录旧 pid `93850/94610`
- 当前 Codex 执行环境还存在 detached 子进程在命令返回后会被回收的 caveat，
  因此本轮 active proof 依赖持有中的活进程。

## 3. touched runtime paths

- [start-bff.sh](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bin/start-bff.sh)
- [bff-3201.log](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/logs/bff-3201.log)
- [bff.pid](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bff.pid)
- [main.js](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/dist/apps/bff/src/main.js)

## 4. active dist / restart evidence

- 当前 active dist 证据固定为：
  - [main.js](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/dist/apps/bff/src/main.js)
  已包含 `project-public-resource` 编译产物。
- 旧活跃进程证据固定为：
  - `pid=97296`
  - route 当时返回 raw `Cannot GET`
- 当前已完成：
  - kill 旧进程 `97296`
  - 重置 [bff.pid](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bff.pid)
- 当前 active 进程证据固定为：
  - `pid=41937`
  - `node apps/bff/dist/apps/bff/src/main.js`
  - `*:3201 (LISTEN)`
  - [bff.pid](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bff.pid) = `41937`
- [bff-3201.log](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/logs/bff-3201.log)
  已记录：
  - `Mapped {/api/app/project/public-resources, GET}`
  - `GET /server/projects/public-resources upstream_status=200`

## 5. direct response proof

- 未带 token 打 active runtime：
  - `GET http://127.0.0.1:3201/api/app/project/public-resources`
  - `401 AUTH_SESSION_INVALID`
- 这说明 route 已存在，已不再是 raw `Cannot GET`
- 带 active bearer token 打 active runtime：
  - `GET http://127.0.0.1:3201/api/app/project/public-resources`
  - `200`
- 当前 response body 已匹配 frozen minimum shaping：
  - top-level only `resources`
  - item 字段固定为：
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
- `visibility` 当前固定为：
  - `app_shared`

## 6. retained boundary summary

- shared `file/access` 复用边界保持不变。
- 本轮未新增：
  - `/download`
  - `/access`
  - template-config proxy
- 本轮也未把 BFF 写成：
  - 目录真值 owner
  - 第二下载系统 owner

## 7. blockers

- 当前只保留一个执行环境 caveat：
  - [start-bff.sh](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bin/start-bff.sh)
    在当前 Codex 环境里拉起的 detached 子进程不会稳定常驻
  - 所以当前 active proof 依赖持有中的 `pid=41937`
- 除上述 helper persistence caveat 外，
  当前没有剩余业务 blocker。

## 8. Formal Conclusion

- `公共资源下载区 BFF runtime alignment` receipt 已冻结。
- 当前正式口径已写死为：
  - active `3201` 已对齐到当前 BFF dist
  - `GET /api/app/project/public-resources` 已在 active runtime 成立
  - route 已不再返回 raw `Cannot GET`
  - frozen minimum shaping 成立
  - shared `file/access` 复用边界保持不变
  - 当前允许重做 `公共资源下载区 result verification`
