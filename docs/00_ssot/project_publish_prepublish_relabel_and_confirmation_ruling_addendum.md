---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L0 ruling for relabeling `submitted` as `预发布列表` on the
  owner-facing publish chain, reordering draft/edit actions, and fixing the
  canonical publish-confirmation surface without changing canonical state,
  path, or truth ownership.
layer: L0 SSOT
freeze_date_local: 2026-04-13
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md
  - docs/00_ssot/my_project_lifecycle_correction_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/server/src/modules/project/project-write.service.ts
---

# 《项目发布对象簇｜预发布列表命名与发布确认重排总裁决补充单》

## 1. Scope

- 本冻结单只覆盖：
  - `project create / edit` owner-facing 编辑页
  - `我的项目` owner-facing 分栏、卡片、详情动作
  - 当前既有 `submit / publish / withdraw / archive` 动作的用户侧命名与承接顺序
- 本冻结单不进入：
  - 新状态
  - 新 path
  - 新 migration
  - `order / fulfillment / rating / dispute` 对象重写

## 2. 总冻结结论

- 当前 canonical truth 不变：
  - `draft -> submitted -> published`
- 当前 user-facing 命名正式重排为：
  - `draft` => `草稿`
  - `submitted` => `预发布列表`
  - `published` => `已发布`
  - `awarded / converted_to_order` => `进行中`
- `已递交` 当前正式降级为历史过渡文案：
  - 可作为内部状态解释语句存在
  - 不再拥有首层分栏标题权
  - 不再拥有 `submitted` 主体验名权

## 3. 三段式动作重排

### 3.1 草稿阶段

- `draft` 的编辑页当前正式区分两类动作：
  - 主动作：`保存到预发布列表`
    - 语义：当前项目从 `draft` 进入 `submitted`
    - 绑定：现有 `submitProject`
  - 次动作：`仅保存草稿`
    - 语义：继续停留在 `draft`
    - 绑定：现有 `saveProject`
- 当前正式禁止把这两个动作继续写成同级无解释的
  `保存项目 / 提交项目` 混合对。

### 3.2 预发布列表阶段

- `submitted` 的 owner-facing 主体验名当前正式固定为：
  - `预发布列表`
- `submitted` 的 owner-facing主动作当前正式固定为：
  - `检查无误，确定发布`
    - 语义：从 `submitted` 进入 `published`
    - 绑定：现有 `publishProject`
- `submitted` 的 owner-facing 次动作当前正式固定为：
  - `返回草稿继续编辑`
    - 绑定：现有 `withdraw`
  - `作废归档`
    - 绑定：现有 `archive`

### 3.3 已发布阶段

- `published` 的 owner-facing主动作继续固定为：
  - `查看详情`
  - `补充资料`
  - `下架关闭`
- 本轮不改写：
  - `published -> archived`
    的既有 canonical truth

## 4. Canonical 发布确认面

- 当前正式发布确认面固定为：
  - `我的项目 -> 预发布列表 -> 单项目详情`
- 当前编辑页在 `submitted` 态不再承担最终发布确认主面职责。
- 当前编辑页在 `submitted` 态应承接为：
  - 返回预发布详情
  - 继续核对当前内容
  - 不再把 `发布项目` 作为编辑页主按钮直接顶在第一优先级

## 5. Cross-layer 不变边界

### 5.1 Contract

- `submitted` 继续是唯一 canonical state
- 本轮不新增：
  - `prepublish`
  - `prepublished`
  - `saveToPrepublish`
  - `confirmPublish`

### 5.2 BFF

- `BFF` 继续只保留既有 app-facing transport：
  - `submit`
  - `publish`
  - `withdraw`
  - `archive`
- `BFF` 不得产生：
  - `预发布列表` 作为第二状态机真值
  - 新的命令别名 path

### 5.3 Server

- `Server` 继续只拥有 canonical lifecycle truth：
  - `draft`
  - `submitted`
  - `published`
  - `archived`
- `Server` 不得把 user-facing `预发布列表` 写成新的 persisted state。

## 6. 正式降级项

- [my_project_four_stage_smooth_flow_rule_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md)
  中关于 `submitted` 首层标题固定为 `已递交` 的条款，
  当前正式降级为旧用户侧命名基线。
- [my_project_four_stage_smooth_flow_rule_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md)
  中 `已递交` 阶段仅承接 `查看详情 / 撤回到草稿 / 作废归档`、
  未登记 `检查无误，确定发布` 的条款，
  当前正式降级为不完整旧动作口径。
- [my_project_lifecycle_correction_ruling_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_project_lifecycle_correction_ruling_addendum.md)
  继续作为 lifecycle truth authority 保留，
  但不再单独决定 `submitted` 的 owner-facing命名和第一确认面。

## 7. 当前唯一优先级

- 只要问题落在：
  - `submitted` 的用户可见命名
  - `draft` 页面的主次按钮重排
  - `publish` 的 owner-facing 确认入口
  - `预发布列表` 与编辑页的分工
- 当前唯一最高优先级文书固定为：
  - `docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md`
