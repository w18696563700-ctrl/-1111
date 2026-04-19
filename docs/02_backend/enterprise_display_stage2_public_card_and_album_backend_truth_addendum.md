---
owner: Codex 总控
status: frozen
purpose: Freeze the backend truth patch for stage-2 so Server closes the remaining album persistence/read gap and emits company serviceItems on public list highlights without inventing new credit truth.
layer: L2 Backend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_stage2_public_card_and_album_cloud_alignment_bounded_object_ruling_addendum.md
  - docs/01_contracts/enterprise_display_stage2_public_card_and_album_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_album_and_target_enterprise_info_backend_truth_addendum.md
  - apps/server/src/modules/enterprise_hub/**
  - apps/server/src/modules/upload/**
---

# 企业展示 Stage 2 公域卡片与画册补链 Backend Truth 冻结单

## 1. Scope

- 当前 backend freeze 只补：
  - company 公域列表 `serviceItems` 输出
  - `albumImageFileAssetIds` persistence / read / write 闭环
  - `enterprise_album` upload binding 接入
- 当前不补：
  - 新信用分计算
  - 公域详情结构重排
  - Admin 面

## 2. Public Company Highlights Truth

- `Server` 在公域列表/recommendation presenter 输出 company highlights 时，
  当前至少必须承接：
  - `exhibitionTypes`
  - `serviceItems`
- 当前 `serviceCities` 可保留为兼容字段，
  但不得成为 stage-2 唯一 company highlight。

## 3. Enterprise Album Truth Closure

- `enterprise_listing.album_image_file_asset_ids` 的既有真值冻结继续有效。
- 当前 stage-2 必须把该真值真正接入 source implementation，包括：
  - entity read/write
  - basic update write path
  - workbench presenter read path
  - published-change snapshot / live-write continuity
- 当前数量上限继续固定为：
  - `6`

## 4. Upload Binding Truth

- `upload-write.service` 当前 enterprise display image binding 必须额外接受：
  - `fileKind = enterprise_album`
- 当前不得跳过 shared upload confirm。

## 5. Non-goals

- 不新增 `creditScore` 持久化字段
- 不把评论均分改名为信用分
- 不引入第二套 album 真值 carrier

## 6. Formal Conclusion

- 当前 backend stage-2 正式职责固定为：
  - 让 company list highlights 真正返回 `serviceItems`
  - 让 `albumImageFileAssetIds` 形成真实可回读闭环
  - 让 `enterprise_album` 进入既有 upload binding 白名单
