---
owner: Codex 总控
status: active
purpose: >
  Submit the formal stage gate checklist for the current `项目发布对象簇`
  prepublish relabel and publish-confirmation relayout round, covering only
  the existing `draft -> submitted -> published` chain, the owner-facing
  naming/action relayout, and the cross-layer no-new-state boundary.
layer: L0 SSOT
freeze_date_local: 2026-04-13
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
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

# 《项目发布对象簇｜预发布列表命名与发布确认重排阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - 把用户侧 `submitted` 的主命名从 `已递交` 收口为 `预发布列表`
  - 把 `draft -> submitted -> published` 讲成人能直接理解的三段式流程
  - 把 `检查无误，确定发布` 正式补成 `submitted` 的 owner-facing 主动作
  - 同时锁住 `Frontend / BFF / Server` 的不变边界
- 当前明确非目标：
  - 不新增 project state
  - 不新增 contract path
  - 不新增 migration
  - 不改 Admin
  - 不进入 integration / release-prep / production release

## 2. Passed Gates

- `同对象门禁` 通过：
  - 本轮仍然只在当前 `项目发布对象簇` 内收口
  - 只涉及 `project create/edit` 与 `my project` 两个 owner-facing continuation 面
- `真值门禁` 通过：
  - 当前 repo 已明确存在 canonical truth：
    - `draft -> submitted`
    - `submitted -> published`
    - `submitted -> draft`
    - `submitted -> archived`
    - `published -> archived`
- `跨层一致性门禁` 通过：
  - `Server` 当前仍是唯一 lifecycle truth owner
  - `BFF` 当前仍只做 app-facing mapping / payload shaping / error normalization
  - Flutter 当前仍只是 owner-facing consumption layer
- `无新状态门禁` 通过：
  - 当前 user-facing `预发布列表` 可建立在既有 canonical state `submitted` 之上
  - 不需要引入 `prepublish / prepublished`
- `无新接口门禁` 通过：
  - 当前 repo 已存在：
    - `POST /api/app/project/submit`
    - `POST /api/app/project/publish`
  - 本轮不需要新增 `save-to-prepublish` 类 path

## 3. Failed Gates

- `用户心智门禁` 当前失败：
  - 编辑页当前同时暴露 `保存项目` 与 `提交项目 / 发布项目`
  - 用户容易把“保存”和“进入预发布承接”混成同一件事
- `阶段命名门禁` 当前失败：
  - `已递交` 对普通用户的含义过弱
  - 不能直接表达“已经进入发布前检查列表，但尚未公开”
- `发布确认面门禁` 当前失败：
  - 当前 `submitted` 详情页虽然已有 `撤回 / 归档`
  - 但缺少 owner-facing `检查无误，确定发布`

## 4. Veto Gates

- 当前未发现阻断 docs-only freeze authoring 的 veto gate。
- 当前 retained veto：
  - 不得把 `预发布列表` 写成新的 persisted state
  - 不得新增 `save-to-prepublish`、`prepublish/confirm` 第二命令家族
  - 不得把 `BFF` 写成阶段命名真值 owner
  - 不得让编辑页和我的项目详情页各自维护不同发布状态机

## 5. Stage Decision

- `Go`：
  - docs-only freeze authoring
  - 允许一次性补齐：
    - `L0 ruling`
    - `L2 contract freeze`
    - `L3 backend truth freeze`
    - `L4 BFF surface freeze`
    - `L5 frontend consumption freeze`
    - `source_of_truth_map` 更新
- `No-Go`：
  - direct implementation before freeze
  - contract path creation
  - migration
  - release execution
