---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter consumption boundary for the post-publish owner-private materials supplement corridor, so the existing publish-workbench pages can add bounded attachment zones and handoff without creating a second truth owner or a public attachment surface.
layer: L5 Frontend
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_post_publish_materials_corridor_v1_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_post_publish_materials_corridor_v1_bff_surface_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
---

# 《项目发布工作台 / 已发布项目资料补充走廊 V1 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目发布工作台 / 已发布项目资料补充走廊 V1`
- Flutter 只承接：
  - create success 继续补资料入口
  - my-project detail 附件区
  - project edit 附件区
  - workbench handoff 卡片
  - owner-private attachment list / add / delete 的消费面
- 本冻结单不进入：
  - public attachment display
  - admin 治理台
  - 第二状态机

## 2. 页面骨架 Freeze

- create success 页继续保留：
  - `继续补充资料`
  - 受控 handoff
- `my-project detail` 新增正式附件区，作为 owner 主重入入口。
- `project edit` 新增正式附件区。
- `workbench` 只加 handoff / summary 卡片，不做附件真值页。
- `public project detail` 继续不展示 owner-private attachment。

## 3. Consumption Boundary Freeze

- `Flutter` 只消费：
  - `GET /api/app/my/projects/{projectId}/attachments`
  - `POST /api/app/my/projects/{projectId}/attachments`
  - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
- create success 与 project edit 共用同一 owner-private attachment family。
- `workbench` 只使用既有 project continuation context 做 handoff，不要求第二附件 contract family。

## 4. Attachment Kind / Copy Freeze

- 页面文案固定对齐：
  - `效果图`
  - `施工图`
  - `其他资料`
- `效果图` 文案必须与图片上传能力一致。
- 当前不得继续沿用“只支持 PDF / DOC / DOCX”文案作为 V1 正式能力描述。
- public project detail 继续只展示 public project materials，不展示 owner-private attachment intake 或管理项。

## 5. Controlled State Matrix Freeze

### 5.1 Shared Attachment Zone States

- empty
- loading
- content
- creating
- deleting
- controlled unavailable
- invalid kind / mime
- file asset not confirmed
- fallback
- timeout

### 5.2 Create-success Handoff State

- create success 只显示：
  - 当前项目已发布
  - 可以继续补资料
  - handoff into owner-private attachment zone
- create success 不成为正式附件 truth owner。

### 5.3 My-project Detail / Project Edit States

- `my-project detail`：
  - empty / loading / content / delete feedback / error
- `project edit`：
  - empty / loading / content / add feedback / delete feedback / error

## 6. Upload Reuse Boundary

- `Flutter` 继续复用：
  - `upload/init`
  - direct upload
  - `upload/confirm`
- 但页面必须明确：
  - upload confirm 成功 != 正式项目附件已形成
  - 正式附件列表以后端 `project_attachments` 结果为准
- 当前不得把 confirm local record 包装成正式附件列表。

## 7. Frontend Error Consumption Freeze

- app-facing 展示语义最小固定为：
  - 无正式附件
  - 当前文件类型不支持
  - 附件类型与文件类型不匹配
  - 当前附件确认结果未完成
  - 当前项目暂无该附件
  - 当前不可继续补充
  - 当前请求超时或稍后重试
- `Flutter` 不自行发明项目附件业务真值。

## 8. No-Go 边界

- 不得在 Flutter 持久化 project attachment truth
- 不得新增 public attachment 入口
- 不得把附件补充流程写成注册 flow
- 不得把 current attachment zone 写成完整 project attachment center
- 不得新增第三条 project attachment 主入口
- 不得把 workbench 写成附件真值页

## 9. 合规与发布门禁

- frontend surface freeze 完成前，不进入实现派工。
- 双区附件消费不得破坏已成立的 Round A publish / my-project 主链。
- public detail 继续 fail-closed，不得因 owner-private corridor 打开而扩大 public visibility。

## 10. 裁决

- `Round V1 frontend consumption freeze 是否可入库：是`
- `下一步唯一动作是什么：输出《项目发布工作台 / 已发布项目资料补充走廊 V1 docs-only freeze review conclusion》`
