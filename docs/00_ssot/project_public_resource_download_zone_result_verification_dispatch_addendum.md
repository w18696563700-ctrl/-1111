---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the independent verification dispatch for the public resource download
  zone after backend, BFF, and frontend receipts are all available for the
  current bounded implementation round.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_backend_execution_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_execution_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_frontend_execution_receipt_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《公共资源下载区结果校验派工单》

## 1. Scope

- 本派工单只适用于：
  - `公共资源下载区`
- 本派工单只复核：
  - backend / BFF / frontend 当前 bounded implementation round
- 本派工单不代表：
  - integration 放行
  - `release-prep` 放行
  - production release 放行

## 2. Receipt Gate

- 当前 receipt gate 已满足：
  - backend receipt：
    - [project_public_resource_download_zone_backend_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_public_resource_download_zone_backend_execution_receipt_addendum.md)
  - BFF receipt：
    - [project_public_resource_download_zone_bff_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_public_resource_download_zone_bff_execution_receipt_addendum.md)
  - frontend receipt：
    - [project_public_resource_download_zone_frontend_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_public_resource_download_zone_frontend_execution_receipt_addendum.md)

## 3. Current Verification Target

- 当前独立复核只回答 8 个问题：
  1. `apps/server` build 与资源目录定向测试是否独立通过
  2. `apps/bff` build 与 app-facing mapping 定向测试是否独立通过
  3. `apps/mobile` analyze 与两组直接相关 Flutter tests 是否独立通过
  4. `GET /server/projects/public-resources` 是否真实返回最小 catalog 字段且不泄露 `objectKey`
  5. `GET /api/app/project/public-resources` 是否真实命中上游并保持最小 shaping
  6. `我的项目详情` 是否真实显示 `公共资源下载区` 且位于 `项目详情文书区` 之后
  7. shared `file/access` 下载复用是否真实闭合
  8. 当前是否允许进入联动发布前门禁

## 4. Mandatory Verification Steps

1. 先核对三份回执是否存在且对象一致。
2. 独立重跑 Server build：
   - `npm run build --prefix apps/server`
3. 独立重跑 BFF build：
   - `npm run build --prefix apps/bff`
4. 独立重跑 Server 定向测试：
   - `node --test apps/server/test/project-public-resource-corridor.test.cjs`
5. 独立重跑 BFF 定向测试：
   - `node --test apps/bff/test/project-public-resource-service.test.cjs`
6. 独立重跑 Flutter analyze：
   - `cd apps/mobile && flutter analyze lib/features/exhibition/data/exhibition_consumer_layer.dart lib/features/exhibition/data/models/project_public_resource_read_models.dart lib/features/exhibition/data/services/exhibition_canonical_paths.dart lib/features/exhibition/data/services/exhibition_contract_mapper.dart lib/features/exhibition/data/services/exhibition_contract_validation.dart lib/features/exhibition/data/services/exhibition_load_service.dart lib/features/exhibition/data/services/project_public_resource_contract_mapper.dart lib/features/exhibition/data/services/project_public_resource_contract_validation.dart lib/features/exhibition/data/services/project_public_resource_load_service.dart lib/features/exhibition/data/services/project_public_resource_action_service.dart lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/pages/my_project_detail_page.dart lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart test/project_attachment_corridor_test.dart test/my_project_private_carry_test.dart`
7. 独立重跑 Flutter 定向测试：
   - `cd apps/mobile && flutter test test/project_attachment_corridor_test.dart`
   - `cd apps/mobile && flutter test test/my_project_private_carry_test.dart`
8. 独立核对 contract 与代码对齐：
   - `GET /server/projects/public-resources`
   - `GET /api/app/project/public-resources`
   - `GET /api/app/file/access?fileAssetId=<known-file-asset-id>&mode=download`
9. 独立核对 Flutter 页面边界：
   - `我的项目详情` 有 `公共资源下载区`
   - public `项目展示详情` 没有该区
   - workbench 没有该区

## 5. Hard Rules

- 不得把回执改写成通过
- 不得把 fake/demo transport 当成通过
- 不得把本地硬编码资源卡片写成通过
- 不得把 `objectKey` 泄露当成可接受偏差
- 如任一关键步骤失败，必须原样记录状态码、错误码、build 错误或 Flutter 断言失败
- 当前无论结果如何，都不得写成 `release-prep` 或 production release

## 6. Expected Output

- 结果校验输出必须至少回答：
  1. Server build / test 是否独立通过
  2. BFF build / test 是否独立通过
  3. Flutter analyze / tests 是否独立通过
  4. server catalog path 是否独立通过
  5. BFF app-facing mapping 是否独立通过
  6. owner-facing zone 与 shared download handling 是否独立通过
  7. 当前是否允许进入联动发布前门禁

## 7. Next Unique Action

- 下一步唯一动作：
  - 把本派工单对应的执行口令发给 `结果校验 Agent`
