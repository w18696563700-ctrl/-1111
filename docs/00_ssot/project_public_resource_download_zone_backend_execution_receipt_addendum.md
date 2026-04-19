---
owner: Codex 总控
status: frozen
purpose: >
  Record the bounded backend execution receipt for the public resource download
  zone after landing the canonical Server catalog route, the dedicated read
  truth carrier, and the directly associated tests.
layer: execution receipt
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bounded_implementation_dispatch_bundle_addendum.md
  - docs/02_backend/project_public_resource_download_zone_backend_truth_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《公共资源下载区 backend execution receipt》

## 1. 当前 execution 状态

- 当前 execution 状态必须固定为：
  - `公共资源下载区 backend execution 完成`
  - `公共资源下载区 BFF execution 尚未开始`
  - `公共资源下载区 frontend execution 尚未开始`
  - `公共资源下载区 result verification 尚未完成`

## 2. changed files

- 本轮 changed files 固定为：
  - [project-public-resource.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-public-resource.controller.ts)
  - [project-public-resource.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-public-resource.service.ts)
  - [project-public-resource.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-public-resource.presenter.ts)
  - [project-public-resource.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/entities/project-public-resource.entity.ts)
  - [project.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.module.ts)
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)
  - [project-public-resource-corridor.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/project-public-resource-corridor.test.cjs)

## 3. route landing summary

- `GET /server/projects/public-resources` 已通过
  [project-public-resource.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-public-resource.controller.ts#L6)
  落地到 `ProjectPublicResourceService.list(...)`。
- `ProjectModule` 已注册：
  - `ProjectPublicResourceController`
  - `ProjectPublicResourceService`
  - `ProjectPublicResourcePresenter`
  - `ProjectPublicResourceEntity`
- 当前 route landing 只服务：
  - read-only catalog
  - app-shared shared resources
  - BFF downstream mapping

## 4. truth carrier summary

- `project_public_resources` 已作为当前唯一目录 truth carrier 落地。
- 最小字段与 contract freeze 对齐：
  - `resource_id`
  - `resource_category`
  - `title`
  - `summary`
  - `file_asset_id`
  - `file_name`
  - `mime_type`
  - `visibility`
  - `sort_order`
  - `published_at`
  - `published_by`
- `visibility` 当前固定为：
  - `app_shared`
- 目录 truth 与文件 truth 已分层：
  - `project_public_resources` 持有目录语义
  - `file_asset` 持有下载锚点

## 5. response boundary summary

- presenter 当前返回的最小字段固定为：
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
- 当前明确不返回：
  - `objectKey`
  - binary 内容
  - template-config 原始 row
- 下载语义仍固定复用 shared file-access family，
  当前 route 只返回目录 truth。

## 6. migration summary

- 当前 backend execution 同时落地了：
  - `project_public_resources` table
  - catalog order index
  - file-asset anchor index
- migration key 固定为：
  - `20260414_project_public_resource_download_zone_truth`
- 当前 migration 只服务于目录 truth carrier，不引入第二状态机。

## 7. build and test

- `npm run build --prefix apps/server` = PASS
- `node --test apps/server/test/project-public-resource-corridor.test.cjs` = PASS `2/2`
- `node --test apps/server/test/project-publish-eligibility.test.cjs` = PASS `26/26`

## 8. bounded smoke

- `GET /server/projects/public-resources` route landing = PASS
- `app_shared` only filtering = PASS
- invalid mime filtering = PASS
- missing anchored file_asset filtering = PASS
- `objectKey` not exposed = PASS
- verified current session required = PASS

## 9. forbidden-scope confirmation

- 未改 `apps/bff/**`
- 未改 `apps/mobile/**`
- 未改 `apps/admin/**`
- 未改 `apps/server/src/modules/template_config/**`
- 未为当前对象新增：
  - upload
  - delete
  - archive
  - anonymous public read

## 10. blockers

- `none`

## 11. Formal Conclusion

- `公共资源下载区 backend execution` receipt 已冻结。
- 当前正式口径已写死为：
  - backend dispatch objective 已完成
  - canonical Server catalog route 已成立
  - `project_public_resources` truth carrier 已成立
  - build / targeted tests / bounded smoke 当前均为 `PASS`
  - 当前允许进入 `公共资源下载区｜BFF 执行轮`
  - 当前仍不得进入 `result verification / integration / release-prep / production release`
