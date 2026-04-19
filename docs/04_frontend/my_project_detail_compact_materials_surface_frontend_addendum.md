---
owner: Codex 总控
status: frozen
purpose: >
  Record the latest Flutter-side compact surface decision for the published
  my-project detail page, so the materials handoff placement and the
  de-explained document zone are not mistaken for accidental regressions and
  reverted by parallel threads.
layer: L5 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/04_frontend/project_publish_workbench_post_publish_materials_corridor_v1_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/project_detail_document_zone_and_public_resource_download_frontend_consumption_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/mobile/test/my_project_private_carry_test.dart
  - apps/mobile/test/project_attachment_corridor_test.dart
---

# 《我的项目详情 compact materials surface frontend addendum》

## 1. Scope

- 本记录只覆盖：
  - `我的项目详情` 已发布态详情页
  - `项目详情文书区` 的 owner-private 附件展示层
- 本记录不进入：
  - contract 变更
  - backend truth 变更
  - OSS / database schema 变更

## 2. Published Detail Surface Decision

- `已发布` 状态下，`当前阶段动作` 卡片不再展示。
- 原 `补充资料` handoff 入口迁移到：
  - `已保存的项目基础信息摘要` 卡片内部
  - 位置固定为卡片底部右侧
- 该入口文案固定为：
  - `继续补充资料`
- 当前 published 详情页不再同时展示：
  - `继续补充资料`
  - `下架关闭`
  - 第二张重复动作卡

## 3. Document Zone Compact Decision

- `项目详情文书区` 保留：
  - `资料类型` 选择
  - 已选附件队列
  - 预览 / 继续添加 / 上传 / 刷新
  - 正式文书列表
- `项目详情文书区` 隐藏：
  - 顶部 summary 说明文案
  - `当前说明` 解释卡
  - 各资料类型提示卡中的解释型段落
- 类型提示卡当前只保留最小必要信息：
  - 类型标题
  - `支持文件`

## 4. UX Rationale Freeze

- 已发布态详情页当前遵循：
  - 单主入口
  - 少解释文案
  - 不重复展示同一 handoff
- 文书区当前遵循：
  - 操作优先
  - 低噪音
  - 用户无需阅读额外说明即可完成补资料

## 5. Regression Lock

- 以下回归必须长期保留：
  - published 详情页不再出现 `当前阶段动作`
  - published 摘要卡出现 `继续补充资料`
  - 文书区不再出现顶部说明型 copy
  - 文书区继续支持附件预览与连续添加
- 当前仓库锁定点：
  - `apps/mobile/test/my_project_private_carry_test.dart`
  - `apps/mobile/test/project_attachment_corridor_test.dart`

## 6. Reversion Policy

- 后续线程若要恢复 `当前阶段动作` 卡片、恢复文书区说明文案、或把入口移回旧位置：
  - 不得视为自动修复
  - 必须先显式更新本记录
  - 必须同步更新对应回归测试

## 7. Conclusion

- 当前 compact surface 决策已正式入库。
- 后续并行线程应将该 UI 视为：
  - `intentional`
  - `latest approved frontend surface`
  - `not an accidental deletion`
