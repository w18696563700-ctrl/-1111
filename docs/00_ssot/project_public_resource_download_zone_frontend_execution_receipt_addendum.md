---
owner: Codex 总控
status: frozen
purpose: >
  Record the bounded frontend execution receipt for the public resource
  download zone after landing my-project-detail consumption, controlled
  states, shared file-access download handling, and directly associated tests.
layer: execution receipt
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_frontend_implementation_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_execution_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bounded_implementation_dispatch_bundle_addendum.md
  - docs/04_frontend/project_public_resource_download_zone_frontend_consumption_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《公共资源下载区 frontend execution receipt》

## 1. 当前 execution 状态

- 当前 execution 状态必须固定为：
  - `公共资源下载区 backend execution 完成`
  - `公共资源下载区 BFF execution 完成`
  - `公共资源下载区 frontend execution 完成`
  - `公共资源下载区 result verification 尚未完成`

## 2. changed files

- 本轮 changed files 固定为：
  - [exhibition_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart)
  - [project_public_resource_read_models.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/models/project_public_resource_read_models.dart)
  - [exhibition_canonical_paths.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart)
  - [exhibition_contract_mapper.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart)
  - [exhibition_contract_validation.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart)
  - [exhibition_load_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart)
  - [project_public_resource_action_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/project_public_resource_action_service.dart)
  - [project_public_resource_contract_mapper.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/project_public_resource_contract_mapper.dart)
  - [project_public_resource_contract_validation.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/project_public_resource_contract_validation.dart)
  - [project_public_resource_load_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/project_public_resource_load_service.dart)
  - [exhibition_trade_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart)
  - [my_project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart)
  - [project_public_resource_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart)
  - [project_public_resource_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart)
  - [project_attachment_corridor_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/project_attachment_corridor_test.dart)
  - [my_project_private_carry_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/my_project_private_carry_test.dart)

## 3. owner-facing placement summary

- `公共资源下载区` 当前只落在：
  - `我的项目详情`
- 当前 zone 固定位于：
  - `项目详情文书区` 之后
- 当前 zone 没有回流到：
  - `发布项目工作台`
  - `项目创建页`
  - public `项目展示详情`

## 4. user-facing copy summary

- 当前用户可见标题固定为：
  - `公共资源下载区`
- 当前摘要固定为：
  - `这里提供平台共享参考资料，用于帮助项目发布与续接过程理解规则和流程，不替代私域项目文书区。`
- 当前说明固定为：
  - `这里用于集中下载平台共享参考资料，帮助理解项目发布与续接规则和流程；当前不提供上传、删除或编辑，也不替代项目详情文书区。`
- 当前分类中文固定为：
  - `合同模板`
  - `流程图与说明`
  - `公共资料`

## 5. controlled state summary

- 当前最小受控状态已成立：
  - `loading`
  - `empty`
  - `content`
  - `controlled unavailable`
  - `timeout`
- 当前受控文案固定为：
  - loading：`正在读取公共资源目录`
  - empty：`当前暂无可下载的公共资源`
  - unavailable：`当前公共资源下载区暂不可用`
  - timeout：`当前公共资源目录读取超时`

## 6. download action summary

- 当前主动作固定为：
  - `下载资料`
- 点击后当前固定走：
  - `ExhibitionConsumerLayer.requestProjectPublicResourceDownload(...)`
  - shared `GET /api/app/file/access?fileAssetId=...&mode=download`
- 当前不本地硬编码资源 URL。
- 当前不新增下载 path。
- 当前若成功打开链接，提示固定为：
  - `已开始下载资料。`
- 当前若链接生成但设备未能直接打开，提示固定为：
  - `下载链接已生成，但当前设备未能直接打开，请稍后重试。`
- 当前失败提示优先展示 BFF 已归一中文；否则回退到：
  - `当前资料暂不可下载，请稍后再试。`

## 7. build and test

- `flutter analyze ...` = PASS
- `flutter test test/project_attachment_corridor_test.dart` = PASS `7/7`
- `flutter test test/my_project_private_carry_test.dart` = PASS `12/12`

## 8. bounded smoke

- owner-facing detail zone render = PASS
- `项目详情文书区` 与 `公共资源下载区` 分区 = PASS
- empty state = PASS
- controlled unavailable state = PASS
- timeout state = PASS
- shared file-access download handling = PASS
- public detail absence retained = PASS

## 9. forbidden-scope confirmation

- 未改 `apps/server/**`
- 未改 `apps/bff/**`
- 未改 `apps/admin/**`
- 未改 workbench
- 未改 public `项目展示详情`
- 未新增：
  - 上传按钮
  - 删除按钮
  - template-config 直出文案
  - 伪资源卡

## 10. blockers

- `none`

## 11. Formal Conclusion

- `公共资源下载区 frontend execution` receipt 已冻结。
- 当前正式口径已写死为：
  - frontend dispatch objective 已完成
  - owner-facing zone、controlled states、shared download handling 已成立
  - analyze / targeted tests / bounded smoke 当前均为 `PASS`
  - 当前允许进入 `公共资源下载区 result verification`
  - 当前仍不得进入 `integration / release-prep / production release`
