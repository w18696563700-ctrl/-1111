---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the only allowed next action after Server and BFF runtime alignment
  receipts both pass for the public resource download zone, limiting work to a
  bounded result-verification rerun only.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_result_verification_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_frontend_execution_receipt_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区结果校验重跑派工单》

## 1. Current Action

- 当前唯一执行动作：
  - `公共资源下载区 result verification rerun`
- 当前不是：
  - 新功能扩面
  - integration gate signoff
  - `release-prep`
  - production release

## 2. Dispatch Scope

- 当前只允许重跑：
  - Server build / test
  - BFF build / test
  - Flutter analyze / tests
  - active runtime `/server/*` and `/api/app/*` proof
  - owner-facing detail placement proof
- 当前不允许：
  - 再次做实现改动
  - 再次写 runtime alignment 之外的新修复

## 3. Mandatory Questions

- 当前重跑只回答：
  1. Server build / test 是否仍通过
  2. BFF build / test 是否仍通过
  3. Flutter analyze / tests 是否仍通过
  4. `GET /server/projects/public-resources` 是否在 active runtime 返回冻结最小 catalog
  5. `GET /api/app/project/public-resources` 是否在 active runtime 返回冻结最小 shaping
  6. `我的项目详情` 的 `公共资源下载区` 是否仍位于 `项目详情文书区` 之后
  7. 当前是否允许进入联动发布前门禁

## 4. Hard Rules

- 不得把之前失败的结论静默覆盖
- 不得把 fake/demo transport 当成通过
- 不得跳过 active runtime proof
- 如 rerun 仍失败，必须继续保持：
  - `integration gate = No-Go`
  - `release-prep = No-Go`
  - `production release = No-Go`

## 5. Next Unique Action

- 下一轮唯一动作：
  - 由结果校验负责人重跑本对象校验，并只在 `PASS` 后申请 `联动发布前门禁`
