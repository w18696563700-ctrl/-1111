---
owner: Codex 总控
status: frozen
purpose: Freeze the same-object post-publish owner-private materials supplement truth inside the current publish-workbench mainline, so the corridor may proceed into dedicated attachment contracts without drifting into a new board, public visibility, or upload-confirm pseudo truth.
layer: L0 SSOT
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/01_contracts/upload_contracts.yaml
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/server/src/modules/upload
  - apps/server/src/modules/project
---

# 《项目发布工作台 / 已发布项目资料补充走廊 V1 truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目发布工作台 / 已发布项目资料补充走廊 V1`
- 本冻结单只服务于：
  - same-object post-publish continuation 边界
  - owner-only / owner-private truth 边界
  - upload asset truth 与 project attachment truth 的分层
  - entry / handoff / visibility 边界
- 本冻结单不进入：
  - implementation
  - integration
  - `release-prep`
  - production release

## 2. Truth Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮正式冻结：
  - 当前能力属于 `项目发布工作台` 当前范围内的 post-publish continuation
  - 不是新业务主线
  - 不是独立 board
- 本轮正式冻结：
  - V1 只做：
    - exhibition 项目
    - owner-only
    - owner-private
    - post-publish materials supplement

## 3. Same-object Positioning Freeze

- 当前对象继续从属于：
  - `发布项目工作台及延伸功能全链`
  - `project_chain`
- 当前对象不是：
  - public showcase extension
  - order / contract / fulfillment continuation
  - enterprise display published-change corridor 的镜像复用
- 当前走廊的正确语义是：
  - 已发布项目成功后，owner 继续补充私域附件资料
  - 这些资料不自动进入 public project detail

## 4. Entry / Re-entry Freeze

- V1 入口固定如下：
  - create success 页保留入口
  - my-project detail 新增正式附件区，作为 owner 主重入入口
  - project edit 新增正式附件区
  - workbench 只加 handoff / summary，不做真值页
- 当前必须明确：
  - create success 页可以承接“继续补资料”动作
  - 但 create success 不是正式附件 truth owner
  - workbench 只承接 handoff，不承接正式附件列表 truth

## 5. Public / Private Visibility Freeze

- public project detail 在 V1 继续：
  - 不展示 owner-private 附件
- 当前 owner-private 附件只允许出现在：
  - owner continuation 面
  - create success handoff
  - my-project detail attachment zone
  - project edit attachment zone
- 当前不得把附件补充能力扩写成：
  - public gallery
  - public project materials extension
  - public attachment download family

## 6. Upload Truth Boundary Freeze

- 上传协议固定复用：
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- 当前必须明确：
  - `file_asset` 继续是上传资产真值
  - 但 `file_asset` 不是项目附件业务真值
  - upload confirm 只说明 FileAsset 已确认，不等于项目附件列表已形成
- 当前不得只靠 upload confirm 的本地记录假装形成正式附件列表

## 7. Project-owned Carrier Freeze

- V1 必须正式落独立 project-owned carrier：
  - `project_attachments`
- `project_attachments` 是当前走廊唯一合法项目附件业务真值 carrier。
- `project_attachments` 与 `file_asset` 的关系固定为：
  - `file_asset` = 上传资产真值
  - `project_attachments` = 项目附件业务真值
  - 二者不得互相替代

### 7.1 Canonical Fields

- `project_attachments` 最小 canonical 字段固定为：
  - `attachmentId`
  - `projectId`
  - `fileAssetId`
  - `fileName`
  - `attachmentKind`
  - `mimeType`
  - `visibility=owner_private`
  - `sortOrder`
  - `createdAt`
  - `createdBy`

## 8. Attachment Kind And MIME Freeze

- `attachmentKind` V1 固定为：
  - `effect_image`
  - `construction_doc`
  - `other_material`
- 允许文件类型固定为：
  - `image/png`
  - `image/jpeg`
  - `image/webp`
  - `application/pdf`
  - `application/msword`
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- `attachmentKind` 与 MIME 约束固定为：
  - `effect_image` 只能是 `image/*`
  - `construction_doc` 只能是 `pdf / doc / docx`
  - `other_material` 可接 `image` 或 `pdf / doc / docx`

## 9. Non-goals

- V1 不进入：
  - CAD / ZIP / 视频
  - admin 审核流
  - 公域附件展示
  - enterprise display published-change corridor 直接复用实现
  - order / contract / fulfillment 扩写
- 当前对象也不进入：
  - 第二状态机
  - 第二上传真值
  - 第二 project detail truth family

## 10. Next Unique Action

- 下一步唯一动作：
  - 输出《项目发布工作台 / 已发布项目资料补充走廊 V1 contract freeze》
