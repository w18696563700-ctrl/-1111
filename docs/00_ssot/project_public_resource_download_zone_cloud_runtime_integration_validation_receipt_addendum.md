---
owner: Codex 总控
status: frozen
purpose: >
  Record the remote cloud-runtime integration validation receipt for the public
  resource download zone, freezing that the already-passed local isolated
  runtime does not automatically prove the remote `/srv` runtime and that the
  current remote chain is still not aligned.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_integration_gate_checklist_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_result_verification_rerun_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_frontend_execution_receipt_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《公共资源下载区远端 Cloud Runtime 联调回执单》

## 1. Current Validation Target

- 当前联调对象：
  - `公共资源下载区`
  - `remote cloud runtime integration validation`
- 当前远端运行根固定为：
  - `47.108.180.198`
  - `/srv/workspaces/exhibition-infra-monorepo`
  - active `BFF :3201`
  - active `Server :3301`

## 2. What Passed

- 当前远端 health 仅证明：
  - `GET /health/live` on `3301` = `200`
  - `GET /health/live` on `3201` = `200`
- 当前 Flutter local consumption proof 仍成立：
  - `project_attachment_corridor_test.dart = PASS`
  - `my_project_private_carry_test.dart = PASS`

## 3. What Failed

- 当前远端 auth login 未成立：
  - `POST /api/app/auth/otp/login` = raw `404 Cannot POST`
  - 未能取得有效 `accessToken`
- 当前远端 Server catalog path 未成立：
  - `GET /server/projects/public-resources` = `404 AUTH_RESOURCE_UNAVAILABLE`
- 当前远端 BFF app-facing path 未成立：
  - `GET /api/app/project/public-resources` = raw `404 Cannot GET`
- 当前 shared file-access reuse 未成立：
  - `GET /api/app/file/access?...` = raw `404 Cannot GET`
  - 因 catalog 未返回 `resources[0].fileAssetId`，当前不存在 sample-based download pass

## 4. Drift Evidence

- 当前远端进程证据显示：
  - active `3201` listener:
    - `cwd=/srv/workspaces/exhibition-infra-monorepo/apps/bff`
    - `cmd=node dist/main`
  - active `3301` listener:
    - `cwd=/srv/workspaces/exhibition-infra-monorepo/apps/server`
    - `cmd=node dist/apps/server/src/main.js`
- 当前远端源码与 dist 额外取证显示：
  - `/srv/workspaces/exhibition-infra-monorepo/apps/server/dist` 下未检到 `public-resources`
  - `/srv/workspaces/exhibition-infra-monorepo/apps/bff/dist` 下未检到 `public-resources`
  - `/srv/workspaces/exhibition-infra-monorepo/apps/server/src` 下未检到 `public-resources`
  - `/srv/workspaces/exhibition-infra-monorepo/apps/bff/src` 下未检到 `public-resources`
- 当前远端 BFF 还存在 runtime 漂移迹象：
  - `cmdline=node dist/main`
  - 但 `/srv/workspaces/exhibition-infra-monorepo/apps/bff/dist/main.js` 不存在

## 5. Formal Receipt Conclusion

- 当前正式回执结论固定为：
  - `remote cloud runtime integration validation = NO-GO`
  - `local isolated runtime pass != remote cloud runtime pass`
  - 当前远端失败性质是：
    - runtime drift
    - not frontend consumption drift
    - not contract-authoring drift

## 6. Next Unique Action

- 下一步唯一动作：
  - 先进入 `公共资源下载区 Server cloud runtime alignment`
  - 在 `Server cloud runtime receipt` 通过前：
    - 不允许发 `BFF cloud runtime alignment`
    - 不允许重提 `release-prep`
