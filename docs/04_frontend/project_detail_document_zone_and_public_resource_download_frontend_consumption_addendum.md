---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-side consumption boundary for the project-detail document
  zone and the public-resource download zone, fixing the existing owner-private
  attachment section as the only active document carrier while explicitly
  keeping the public-resource zone out of active Flutter capability for now.
layer: L5 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/04_frontend/project_publish_workbench_post_publish_materials_corridor_v1_frontend_consumption_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
---

# 《项目详情文书区与公共资源下载区 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `我的项目详情` 中的 `项目详情文书区`
  - 当前不存在的 `公共资源下载区` 的 Flutter 边界
- 本冻结单不进入：
  - implementation
  - 新页面
  - 新下载按钮 family

## 2. 项目详情文书区 Flutter Authority

- 当前 Flutter 中，`项目详情文书区` 的 canonical owner-facing 载体固定为：
  - `我的项目详情` 中的正式附件区
- 当前次级 re-entry 继续固定为：
  - create success handoff
  - project edit attachment zone
- 当前 `workbench` 继续只承接：
  - summary / handoff
  - 不承接文书区真值

## 3. 文书区用户侧文案 Freeze

- 当前文书区最小用户可见分类固定为：
  - `效果图`
  - `施工图`
  - `其他资料`
- `其他资料` 当前允许承接的解释文案固定包括：
  - `展馆和展位图`
  - `展商手册`
  - 其他 owner-private 资料
- 当前不得把上述解释文案扩写成新的 Flutter raw type 或独立筛选桶。

## 4. Public Detail Boundary

- public `项目展示详情` 当前继续不展示：
  - owner-private 文书区
  - owner-private 附件列表
  - owner-private 删除/补充动作

## 5. 公共资源下载区 Flutter Boundary

- 当前 Flutter 不得把 `公共资源下载区` 做成以下任一 active capability：
  - 可点击下载列表
  - 假静态合同模板区
  - 伪流程图下载区
  - 本地硬编码资源中心
- 当前若后续要在详情页展示该区，
  也只能在未来单独 truth chain 冻结后 author；
  本轮不授予 active UI authority。

## 6. Consumption Boundary

- 当前 Flutter 只允许消费：
  - 既有 owner-private attachment family
- 当前 Flutter 不允许消费：
  - `template_config` Admin 数据
  - 未冻结的资源目录 path
  - 未冻结的公共下载按钮 family

## 7. Formal Conclusion

- 当前 `项目详情文书区` 的 Flutter authority 继续沿用既有
  owner-private attachment section。
- 当前 `公共资源下载区` 的 Flutter authority 结论固定为：
  - `not active in current repo`
  - `must stay absent until a later dedicated freeze admits it`
