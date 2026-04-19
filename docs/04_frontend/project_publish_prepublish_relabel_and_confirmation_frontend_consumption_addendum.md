---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L5 frontend consumption for relabeling `submitted` as
  `预发布列表`, reordering draft-page actions, and moving canonical publish
  confirmation to the owner-private prepublish detail surface.
layer: L5 Frontend
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/03_bff/project_publish_prepublish_relabel_and_confirmation_bff_surface_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
---

# 《项目发布对象簇｜预发布列表命名与发布确认重排 L5 frontend consumption freeze》

## 1. Frontend Freeze Conclusion

- 当前 owner-facing 三段式正式冻结为：
  - `草稿`
  - `预发布列表`
  - `已发布`
- `进行中` 与 `已归档` 继续保留既有承接，不在本轮改写。

## 2. Project Edit Page Carrier Rule

- `project_create_page.dart`
  在 `draft` 态的主次动作当前正式固定为：
  - 主按钮：`保存到预发布列表`
    - 绑定：`submitProject`
  - 次按钮：`仅保存草稿`
    - 绑定：`saveProject`
- `draft` 态不再推荐继续用
  `保存项目 / 提交项目`
  作为无解释并列主按钮文案。

## 3. Submitted / Prepublish Carrier Rule

- `submitted` 在 `我的项目` 顶部第二分栏的正式标题固定为：
  - `预发布列表`
- `submitted` 列表卡片与详情页的正式主动作固定为：
  - `检查无误，确定发布`
    - 绑定：`publishProject`
- `submitted` 的次动作固定为：
  - `返回草稿继续编辑`
    - 绑定：`withdraw`
  - `作废归档`
    - 绑定：`archive`

## 4. Canonical Publish Confirmation Surface

- 当前 Flutter canonical 发布确认面固定为：
  - `MyProjectListPage` 的 `预发布列表` 分栏
  - `MyProjectDetailPage` 中的 `submitted` 详情动作区
- `ProjectCreatePage`
  在 `submitted` 态不再是最终发布确认主面。
- `ProjectCreatePage`
  在 `submitted` 态应承接为：
  - 返回预发布详情
  - 继续修改
  - 不再把 `发布项目` 当作首个确认动作直出

## 5. Copy Freeze

- 当前正式用户文案优先级固定为：
  - `预发布列表`
  - `保存到预发布列表`
  - `检查无误，确定发布`
  - `返回草稿继续编辑`
- `已递交`
  当前正式降级为历史旧文案，不再拥有：
  - 顶部分栏标题权
  - `submitted` 阶段主按钮命名权

## 6. Current Excluded Family

- 当前正式禁止：
  - 新增第五个顶部分栏
  - 在前端本地发明 `prepublish` raw state
  - 让编辑页和我的项目详情页同时成为互相竞争的最终发布确认面
