---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the rerun dispatch for remote cloud-runtime integration validation of
  the public resource download zone after remote Server catalog, remote BFF
  catalog, and remote shared file-access have all aligned.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_server_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_file_access_cloud_runtime_alignment_receipt_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《公共资源下载区 Remote Cloud Runtime 联调重跑派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `公共资源下载区 remote cloud runtime integration validation rerun`
- 当前不是：
  - 新功能扩面
  - 代码修改
  - `release-prep`
  - production release

## 2. Validation Scope

- 当前联调对象只限：
  - remote active Server runtime:
    - `47.108.180.198:3301`
  - remote active BFF runtime:
    - `47.108.180.198:3201`
  - remote shared `file/access` reuse
  - current Flutter local consumption proof
  - `我的项目详情` 内的 `公共资源下载区`

## 3. Must-run Steps

- 必须执行：
  - `GET http://127.0.0.1:3301/health/live`
  - `GET http://127.0.0.1:3201/health/live`
  - `POST http://127.0.0.1:3201/api/app/auth/otp/login`
  - `GET http://127.0.0.1:3301/server/projects/public-resources`
    - no-token
    - with-token
  - `GET http://127.0.0.1:3201/api/app/project/public-resources`
    - no-token
    - with-token
  - 从 `resources[0].fileAssetId` 取样本后执行：
    - `GET http://127.0.0.1:3301/server/file/access?fileAssetId=<sample>&mode=download`
    - `GET http://127.0.0.1:3201/api/app/file/access?fileAssetId=<sample>&mode=download`
  - Flutter 最小辅证：
    - `flutter test test/project_attachment_corridor_test.dart`
    - `flutter test test/my_project_private_carry_test.dart`

## 4. Required Questions

- 本轮必须独立回答：
  - remote Server health 是否通过
  - remote BFF health 是否通过
  - remote server catalog path 是否通过
  - remote BFF catalog path 是否通过
  - remote shared file-access actual download reuse 是否通过
  - `公共资源下载区` 与 `项目详情文书区` 的分区是否仍成立
  - 当前是否允许进入 `release-prep gate`

## 5. Hard Rules

- 当前严格禁止：
  - 修改代码
  - 重写 receipt
  - 把 local isolated runtime 结果冒充 remote rerun 结果
  - 把 rerun `PASS` 直接写成 `release-prep PASS`
- 如任一步失败：
  - 必须原样回传状态码、错误码、响应体或 Flutter 断言失败

## 6. Next Unique Action

- 下一轮唯一动作：
  - 只有在 remote cloud runtime integration rerun 结论为 `PASS` 后，才允许申请 `release-prep gate`
