---
owner: Codex 总控
status: frozen
purpose: >
  Record the active Server runtime-alignment receipt for the public resource
  download zone after fixing the stale process, materializing the dedicated
  carrier in the active DB, and proving the canonical catalog route on the
  live runtime.
layer: execution receipt
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_server_runtime_alignment_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_result_verification_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_backend_execution_receipt_addendum.md
  - docs/02_backend/project_public_resource_download_zone_backend_truth_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 Server runtime alignment receipt》

## 1. 当前 runtime-alignment 状态

- 当前 execution 状态必须固定为：
  - `公共资源下载区 Server runtime alignment 完成`
  - `公共资源下载区 BFF runtime alignment 尚未开始`
  - `公共资源下载区 result verification 仍为 No-Go`

## 2. exact root cause

- active runtime 之前实际跑的是旧进程，不是当前已包含 `ProjectPublicResourceController` 的有效 runtime。
- 旧进程收到 `GET /server/projects/public-resources` 时落到了：
  - `/server/projects/:projectId`
  动态路由，
  返回：
  - `404 AUTH_RESOURCE_UNAVAILABLE`
- active DB 当时也还没有执行：
  - `20260414_project_public_resource_download_zone_truth`
  所以 `public.project_public_resources` 不存在。
- restart 后还暴露出运行态指针对齐问题：
  - `server.pid=5779`
  但对应进程已退出
  - 当前 active 存活进程收口为：
    - `7536`

## 3. touched runtime paths

- [runtime/package1-isolated/.env.local](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/.env.local)
- [runtime/package1-isolated/bin/start-server.sh](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bin/start-server.sh)
- [runtime/package1-isolated/logs/server.log](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/logs/server.log)
- [runtime/package1-isolated/server.pid](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/server.pid)
- [apps/server/dist/main.js](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/dist/main.js)

## 4. active release / current / restart evidence

- 当前环境没有 `/srv/...` release root。
- active runtime 根位于：
  - [runtime/package1-isolated](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated)
  - [apps/server/dist/main.js](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/dist/main.js)
- [server.log](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/logs/server.log)
  已记录：
  - `Mapped {/server/projects/public-resources, GET}`
  - `applied migration 20260414_project_public_resource_download_zone_truth`
- 当前 active 进程证据固定为：
  - `pid = 7536`
  - `node apps/server/dist/main.js`
  - `*:3301 (LISTEN)`
  - `GET /health/live = 200`
- 当前 pid 指针已对齐：
  - [server.pid](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/server.pid)
    = `7536`

## 5. migration execution evidence

- active DB 直接查询结论固定为：
  - `to_regclass('public.project_public_resources') = project_public_resources`
  - `server_schema_migration` 中存在：
    - `20260414_project_public_resource_download_zone_truth`
- [server.log](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/logs/server.log)
  已记录：
  - `applied migration 20260414_project_public_resource_download_zone_truth`
  - `migration reconciliation complete`
- active DB 已写入最小 proof catalog 行：
  - `runtime-alignment-public-resource-20260414`

## 6. direct response proof

- direct active runtime proof 固定为：
  - `GET http://127.0.0.1:3301/server/projects/public-resources`
  - `HTTP/1.1 200 OK`
- 当前返回 body 已收口为：
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
- 当前返回未泄露：
  - `objectKey`
- `visibility` 当前固定为：
  - `app_shared`

## 7. blockers

- 当前仅保留一个运行态 caveat：
  - [start-server.sh](/Users/wangweiwei/Desktop/展览装修之家总控/runtime/package1-isolated/bin/start-server.sh)
    曾写出失效 `server.pid`
  - 但本轮已通过对齐真实活进程修复当前 active 状态
- 除上述 caveat 外，
  当前没有剩余业务 blocker。

## 8. Formal Conclusion

- `公共资源下载区 Server runtime alignment` receipt 已冻结。
- 当前正式口径已写死为：
  - active runtime 已对齐
  - active DB 已对齐
  - `GET /server/projects/public-resources = 200`
  - 最小字段与 `app_shared` 可见性成立
  - `objectKey` 未泄露
  - 当前允许进入 `公共资源下载区 BFF runtime alignment`
