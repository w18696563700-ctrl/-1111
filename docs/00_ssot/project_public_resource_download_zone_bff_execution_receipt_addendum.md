---
owner: Codex 总控
status: frozen
purpose: >
  Record the bounded BFF execution receipt for the public resource download
  zone after landing the canonical app-facing mapping, minimum shaping,
  controlled error normalization, and directly associated tests.
layer: execution receipt
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bff_implementation_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_backend_execution_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bounded_implementation_dispatch_bundle_addendum.md
  - docs/03_bff/project_public_resource_download_zone_bff_surface_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《公共资源下载区 BFF execution receipt》

## 1. 当前 execution 状态

- 当前 execution 状态必须固定为：
  - `公共资源下载区 backend execution 完成`
  - `公共资源下载区 BFF execution 完成`
  - `公共资源下载区 frontend execution 尚未开始`
  - `公共资源下载区 result verification 尚未完成`

## 2. changed files

- 本轮 changed files 固定为：
  - [app-project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/app-project.controller.ts)
  - [project.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project.module.ts)
  - [project-public-resource.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project-public-resource.read-model.ts)
  - [project-public-resource.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project-public-resource.service.ts)
  - [project-public-resource-service.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/test/project-public-resource-service.test.cjs)

## 3. path mapping summary

- `GET /api/app/project/public-resources` 已通过
  [app-project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/app-project.controller.ts#L114)
  落地。
- 当前 app-facing path 已通过
  [project-public-resource.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project-public-resource.service.ts#L28)
  映射到：
  - `GET /server/projects/public-resources`
- `ProjectModule` 已注册 `ProjectPublicResourceService`，
  当前 route 不依赖第二模块或临时代理。

## 4. shaping summary

- BFF 当前只输出 contract freeze 允许的最小字段：
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
- `summary` 空白字符串已归一为：
  - `null`
- `sortOrder` 字符串数值已归一为：
  - number
- `resourceCategory` 只接受：
  - `contract_template`
  - `process_guide`
  - `other_resource`
- `visibility` 只接受：
  - `app_shared`

## 5. error normalization summary

- `401 AUTH_SESSION_INVALID` 已受控归一为：
  - `当前登录态不可用，请重新登录或刷新后再试。`
- `403 AUTH_PERMISSION_INSUFFICIENT` 已受控归一为：
  - `当前账号暂不可访问公共资源目录。`
- upstream raw `404` 或 route drift，
  例如 `Cannot GET /server/projects/public-resources`，
  已 fail-close 归一为：
  - code = `AUTH_RESOURCE_UNAVAILABLE`
  - message = `当前公共资源目录暂不可用，请稍后再试。`
- 其他 transport / schema drift 继续走现有受控 fallback，
  不裸透 raw path 或 stack。

## 6. file-access boundary summary

- 当前 BFF 没有为本对象新增任何下载 path。
- 实际下载继续固定复用：
  - `GET /api/app/file/access`
    with `mode=download`
- 当前 BFF 未改：
  - `apps/bff/src/routes/file/**`
- 当前 BFF 也没有把自己写成：
  - 资源目录真值 owner
  - 第二下载系统 owner

## 7. build and test

- `npm run build --prefix apps/bff` = PASS
- `node --test apps/bff/test/project-public-resource-service.test.cjs` = PASS `3/3`

## 8. bounded smoke

- app-facing path mapping = PASS
- minimum shaping = PASS
- `401 AUTH_SESSION_INVALID` 归一 = PASS
- raw upstream `404` fail-close 归一 = PASS
- shared file-access reuse boundary retained = PASS

## 9. forbidden-scope confirmation

- 未改 `apps/server/**`
- 未改 `apps/mobile/**`
- 未改 `apps/admin/**`
- 未新增：
  - `/api/app/project/public-resources/download`
  - `/api/app/public/resources`
  - 任意 template-config proxy path
- 未把 BFF 写成目录真值 owner
- 未新开第二下载系统

## 10. blockers

- `none`

## 11. Formal Conclusion

- `公共资源下载区 BFF execution` receipt 已冻结。
- 当前正式口径已写死为：
  - BFF dispatch objective 已完成
  - app-facing mapping、minimum shaping、controlled error normalization 已成立
  - build / targeted tests / bounded smoke 当前均为 `PASS`
  - 当前允许进入 `公共资源下载区｜前端执行轮`
  - 当前仍不得进入 `result verification / integration / release-prep / production release`
