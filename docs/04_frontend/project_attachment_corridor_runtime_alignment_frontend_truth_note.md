---
owner: Codex 总控
status: active
purpose: >
  Record the latest Flutter-side owner-private project attachment corridor
  behavior, edit-page re-entry surface, and active cloud runtime observations,
  so later threads do not treat preview support, queue intake, compact detail
  surface, list-shape compatibility, or runtime partition checks as accidental
  drift and revert them silently.
layer: L5 Frontend
decision_date_local: 2026-04-27
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/04_frontend/project_publish_workbench_post_publish_materials_corridor_v1_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/project_detail_document_zone_and_public_resource_download_frontend_consumption_addendum.md
  - docs/04_frontend/my_project_detail_compact_materials_surface_frontend_addendum.md
  - docs/00_ssot/project_edit_supplement_and_document_zone_convergence_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
  - apps/mobile/lib/features/exhibition/data/services/project_attachment_action_service.dart
  - apps/mobile/lib/features/exhibition/data/services/project_attachment_contract_mapper.dart
  - apps/mobile/lib/features/exhibition/data/services/project_attachment_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/models/project_attachment_read_models.dart
  - apps/mobile/test/my_project_private_carry_test.dart
  - apps/mobile/test/project_attachment_corridor_test.dart
---

# 项目附件走廊 runtime alignment frontend truth note

## 1. Scope

- 本说明只覆盖当前以下前端口径：
  - `我的项目详情 -> 项目详情文书区`
  - `项目编辑页 -> 项目详情文书区` re-entry
  - owner-private 文书补充
  - 已发布态补资料 handoff
  - 效果图 / 施工图预览
  - 连续添加与批量形成正式附件
  - `items / attachments` 双返回形状兼容
- 本说明不改写：
  - backend truth ownership
  - contract 冻结文本
  - OSS / database schema 设计本身

## 2. 当前前端现行口径

- 当前方案已确认：
  - 效果图在“已选择待上传”阶段支持本地预览
  - 已形成正式附件的效果图 / 施工图支持通过 `file/access` 预览
  - bind 失败时，前端优先展示后端返回的中文业务原因
  - 不再退化回笼统的“正式附件绑定未完成”提示
  - `ProjectAttachmentReadModel.createdBy` 当前按可选字段承接
  - 若 live cloud bind/list payload 缺少 `createdBy`，前端不得把 `200` 成功响应判为 contract drift
  - 附件区支持：
    - 效果图页签下使用 `选择项目图片`
    - 施工图 / 其他资料页签下继续使用 `选择项目附件`
    - `继续添加`
    - 一次 `上传并形成正式附件`
  - 附件待上传区允许保留多份草稿，再顺序完成 upload / confirm / bind
  - 附件列表当前兼容：
    - `attachments`
    - `items`
  - `2026-04-27` Day4 云上最小修复后，active BFF 已将项目文书列表收回
    `projectId + attachments[]` contract；Flutter 继续保留 `items` 兼容，
    用于覆盖旧 release / 回滚窗口。
- 当前格式边界固定为：
  - `效果图` = `PNG / JPEG / WEBP`
  - `施工图` = `PDF / DOC / DOCX`
  - `其他资料` 继续走既有文书附件能力

## 3. 清爽文书区口径

- `项目编辑` 页当前已收口为：
  - `补充说明` 独立
  - 不再显示 `补充说明与附件`
  - 隐藏补充说明下方解释 copy
  - 隐藏 `资料补充` 提示段
  - `项目详情文书区` 使用紧凑态：
    - 隐藏顶部总说明
    - 隐藏 `当前说明`
    - 隐藏资料类型提示卡中的解释性段落
- `已发布` 详情页不再展示单独的 `当前阶段动作` 卡片。
- `补充资料` 入口已迁移到：
  - `已保存的项目基础信息摘要` 卡片
  - 文案固定为 `继续补充资料`
- `项目详情文书区` 当前故意保持低噪音：
  - 隐藏顶部总说明
  - 隐藏 `当前说明`
  - 隐藏资料类型提示卡中的解释性段落
  - 保留必要的类型标题、支持格式、预览、继续添加、上传、刷新和正式列表

## 4. 当前云端核查记录

- 当前云上联调入口固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- `2026-04-14` active cloud runtime 实测记录：
  - PostgreSQL 中存在独立的 `project_attachments` 与 `file_assets` 表
  - 当前看到的是独立业务表，不是 PostgreSQL 原生 partition table
  - OSS bucket 中存在业务前缀分区：
    - `project_attachment/`
    - `project/`
    - `forum_draft_attachment/`
  - cloud current `Server` release 已包含 `ProjectAttachmentController` 编译产物
  - 首次排查时，旧 release `20260414010700` 未包含 `MyProjectAttachmentController` 编译产物
  - 后续继续核查确认，真实 active `BFF` release 曾漂移到：
    - `20260414171252`
  - 该 active release 的真实运行时路径是：
    - `dist/apps/bff/src/routes/my_project`
  - 同日修复后，active `BFF` release 已切换到：
    - `20260414174134`
  - 当前 active `BFF` release 已包含：
    - `GET /api/app/my/projects/:projectId/attachments`
    - `POST /api/app/my/projects/:projectId/attachments`
    - `DELETE /api/app/my/projects/:projectId/attachments/:attachmentId`
  - `2026-04-14` live cloud 实测：
    - `POST /api/app/my/projects/{projectId}/attachments` 返回 `200`
    - payload 当前缺少 `createdBy`
    - 该字段缺失不再视为前端阻断级 contract drift
  - 当前 release 已额外补齐：
    - `dist/main.js -> dist/apps/bff/src/main.js`
  - 否则 `systemd` 重启后会因 `ExecStart=/usr/bin/node dist/main.js` 报 `MODULE_NOT_FOUND`
  - 当前 cloud ingress `:80` 与 tunnel `:8080` 对该路由的未鉴权探测结果已从 `404` 变为 `401`
  - 因此先前 “BFF app-facing 附件路由未部署完成” 结论已关闭，不应继续沿用为当前 live truth
- 当前需要保留的运行时认知：
  - 云端对象 key 现状已观察到 `project_attachment/{projectId}/{uuid}/...` 形态
  - 本地 repo 中的 key 生成 source 与云上现状不完全一致
  - 因此前端 / 联调线程不得把本地 repo 的 object key 规则直接当成 live truth

## 5. Anti-revert Rule

- 后续线程当前不得把以下行为当成“误改”直接回退：
  - 把编辑页 `补充说明` 改回 `补充说明与附件`
  - 恢复编辑页补充说明下方解释 copy
  - 恢复编辑页 `资料补充` 提示段
  - 删除效果图本地预览
  - 删除施工图正式预览
  - 把 bind 失败提示退化回泛化 fallback
  - 把附件区改回单文件单次选择
  - 恢复 `当前阶段动作` 卡片
  - 恢复文书区顶部解释文案
  - 删除 `items / attachments` 双口径兼容
- 这些都是当前用户明确确认过的现行方案，不是临时视觉漂移。

## 6. 回写要求

- 若后续线程需要修改这一组行为，必须同步更新：
  - 本说明
  - `docs/00_ssot/latest_user_confirmed_change_ledger.md`
  - 对应 Flutter 回归测试

## 7. Formal Conclusion

- 当前项目附件走廊现行口径正式记为：
  - `preview-first`
  - `queue-based continue add`
  - `precise bind failure messaging`
  - `compact edit re-entry surface`
  - `compact published detail surface`
  - `attachments contract shape with retained items compatibility`
  - `cloud runtime observations override local assumptions when they conflict`
