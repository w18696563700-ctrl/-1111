---
owner: Codex 总控
status: frozen
purpose: Freeze the backend truth ownership, persistence patch, visual-gallery assembly inputs, and dual-cert hard-gate rule for enterprise detail album layout and target-enterprise formal-info read.
layer: L2 Backend
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/00_ssot/enterprise_display_album_layout_and_target_enterprise_info_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_workbench_v1_backend_truth_addendum.md
  - docs/04_frontend/profile_dual_certification_bid_guard_frontend_truth_note.md
  - apps/server/src/modules/enterprise_hub/**
  - apps/server/src/modules/profile/**
  - apps/server/src/modules/organization/**
---

# 企业展示详情画册化与目标企业信息查看 Backend Truth 冻结单

## 1. Scope

- 当前 backend freeze 只覆盖：
  - 企业展示统一画册真值
  - 公域企业详情 `visualGallery` 组装输入
  - 目标企业正式信息读取真值
  - 双重认证硬门禁
- 当前不覆盖：
  - 筛选真值扩面
  - Admin 审核面扩面
  - 证照图片公开查看

## 2. Brand-assets Truth

- `enterprise_listing` 当前必须新增并持有：
  - `album_image_file_asset_ids`
- 当前 `album_image_file_asset_ids` 真值上限固定为：
  - `6`

正式裁决：

- `album_image_file_asset_ids` 是跨三类企业统一企业画册真值。
- 历史 `cover_file_asset_id` 当前仅允许作为旧库兼容修复输入；
  runtime 组装与 app-facing 输出不得继续把它当成独立画册字段。
- factory 既有：
  - `enterprise_profile_factory.showcase_image_file_asset_ids`
  继续保留为工厂实景/履约证明真值，
  不得被静默重命名为统一企业画册。

## 3. Public Detail Visual-gallery Input Truth

- `Server` 组装公域企业详情时，必须额外提供：
  - `albumImageFileAssetIds`
  - `gallerySource`

- `gallerySource` 当前只允许以下枚举：
  - `enterprise_album`
  - `empty`

当前组装顺序固定为：

1. `album_image_file_asset_ids` 非空时：
   - `gallerySource = enterprise_album`
2. 否则：
   - `gallerySource = empty`

## 4. Target-enterprise Formal-info Read Truth

- `Server` 必须新增：
  - `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

- 该 path 读取对象固定为：
  - 目标 `enterpriseId` 所属组织的正式认证 current truth
- 该 path 不得读取：
  - 当前查看者自己的 `certification/current`
  - 目标企业 OCR preview 缓存
  - 证照图片公开文件对象

## 5. Formal-info Field Truth

- 当前 formal-info read 只允许暴露：
  - `legalName`
  - `uscc`
  - `legalPerson`
  - `businessType`
  - `address`
  - `registeredCapital`
  - `establishedAt`
  - `businessTerm`
  - `businessScope`
  - `certificationStatus`

正式裁决：

- `licenseFileId` 是正式认证内部文件真值，但不是当前公开详情 formal-info read 输出字段。
- 若目标企业当前不存在正式可公开认证 current：
  - 不得返回伪造部分字段
  - 必须返回受控失败

## 6. Dual-cert Hard Gate

- 当前 `formal-info` read 必须经过后端硬门禁。
- 当前硬门禁不得由前端本地猜测替代。

当前服务端准入语义固定为：

- 有有效 session
- 有有效当前 actor / organization scope
- 当前 actor 满足既有双重认证合格真值

当前后端必须直接复用既有当前 actor 资格真值，
不得为本包发明第二套 `dual-cert` 判定图。

## 7. Upload Binding Truth

- 企业画册继续复用 shared upload corridor。
- 当前新增/继续承接的 business upload binding 固定为：
  - `businessType = enterprise_display`
  - `fileKind = enterprise_logo`
  - `fileKind = enterprise_album`
  - `fileKind = enterprise_factory_showcase`
  - `fileKind = enterprise_case_media`

## 8. Non-goals

- 不在本轮公开营业执照图片
- 不在本轮新增第二条目标企业私域读取链
- 不在本轮改写筛选 persistence

## 9. Formal Conclusion

- 当前 backend 真值正式固定为：
  - `enterprise_listing.album_image_file_asset_ids`
  - 一条目标企业 `formal-info` 读取 path
  - 一条基于既有当前 actor 资格真值的双重认证硬门禁
  - 一套 `visualGallery` 输入组装顺序
