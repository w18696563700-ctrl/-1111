---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-side consumption boundary for the public resource download
  zone, fixing its owner-facing position on my-project detail and its
  download-only first behavior without reopening workbench, create page, or
  public showcase detail.
layer: L5 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/04_frontend/project_detail_document_zone_and_public_resource_download_frontend_consumption_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
---

# 《公共资源下载区 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `我的项目详情` 中的 `公共资源下载区`
- 本冻结单不进入：
  - workbench
  - create success
  - public `项目展示详情`
  - implementation

## 2. Flutter Entry Freeze

- 当前 zone 的唯一合法 Flutter 入口固定为：
  - `我的项目详情`
- 当前 zone 在页面层级上的位置固定为：
  - `项目详情文书区` 之后
- 当前 zone 不进入：
  - `发布项目工作台`
  - `项目创建页`
  - public `项目展示详情`

## 3. User-facing Copy Freeze

- 当前 zone 标题固定为：
  - `公共资源下载区`
- 当前分类中文固定为：
  - `合同模板`
  - `流程图与说明`
  - `公共资料`
- 当前 zone 摘要语义固定为：
  - 这是平台提供的共享参考资料
  - 用于帮助项目发布与续接过程理解规则和流程
  - 不替代私域项目文书区

## 4. CTA Freeze

- 当前 zone 的最小主动作固定为：
  - `下载资料`
- 当前不 author：
  - 上传资料
  - 删除资料
  - 编辑资料
  - workbench handoff CTA
- 当前若后续需要 preview，
  必须在 later round 单独 author；本轮固定 `download-only first`。

## 5. Empty / Failure Boundary

- 当前 zone 的最小受控状态固定包括：
  - loading
  - empty
  - content
  - controlled unavailable
  - timeout
- 当前 empty 只表示：
  - 当前未承接可下载共享资源
  - 不得被解释成文书区为空

## 6. No-Go Boundary

- 当前 Flutter 不得把 `公共资源下载区` 做成：
  - 本地硬编码合同模板墙
  - 伪静态流程图下载区
  - `template_config` 透传面板
- 当前 Flutter 不得把 `公共资源下载区` 和 `项目详情文书区` 混成一个区。

## 7. Formal Conclusion

- 当前 `公共资源下载区` 的 Flutter authority 正式冻结为：
  - owner-facing my-project detail bounded zone
  - download-only first
  - shared app resource copy only
