---
owner: Codex 总控
status: frozen
purpose: Freeze the implementation-dispatch stage gate for the project showcase filter and project create form refactor object, deciding only whether bounded implementation dispatch authoring may begin while implementation execution, integration, release-prep, and production release remain blocked.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
---

# 《项目展示筛选与创建表单重构 implementation dispatch stage gate checklist》

## 1. Scope

- 本门禁核查表只服务于：
  - `项目展示筛选与创建表单重构`
  - bounded implementation dispatch authoring
- 本门禁核查表只回答：
  - 哪些门禁已通过
  - 哪些门禁未通过
  - 哪些是一票否决
  - 当前是否允许进入下一阶段
- 本门禁核查表不等于：
  - implementation execution
  - integration pass
  - release-prep pass
  - production release

## 2. Passed Gates

- 真源连续性门禁：
  - 通过
  - L0 / L2 / L3 / L4 / L5 文书链已连续存在并已登记到 `source_of_truth_map.md`
- 契约冻结门禁：
  - 通过
  - `project/list` 筛选 query、双字段 create、detail/list 字段承接与兼容规则已冻结
- backend truth 门禁：
  - 通过
  - `Server.project` 的持久化 carrier、list filter 真义、public expiry trimming 真义已冻结
- BFF surface 门禁：
  - 通过
  - 当前城市上下文承接、create/list/detail app-facing 整形边界已冻结
- frontend consumption 门禁：
  - 通过
  - 列表/详情/创建页的主消费顺序、empty/blocker 边界、过期展示边界已冻结
- 有界范围门禁：
  - 通过
  - 当前对象仍保持在：
    - 项目展示列表页
    - 项目展示详情页
    - 项目创建页
  - 未漂移到：
    - `workbench`
    - `my/projects` 新信息架构
    - 附件公开
    - 审核状态机
    - 交易后链

## 3. Failed Gates

- implementation receipt gate：
  - 未通过
  - 当前还没有 backend / BFF / frontend 的真实实现回执
- runtime verification gate：
  - 未通过
  - 当前还没有结果校验 Agent 的独立 runtime 复核
- integration gate：
  - 未通过
  - 当前还没有联调结论
- release-prep gate：
  - 未通过
- production release gate：
  - 未通过

## 4. Veto Gates

- 若把当前 `Go` 解释成 direct implementation，直接 veto
- 若把当前 `Go` 解释成 integration pass，直接 veto
- 若把当前 `Go` 解释成 release-ready，直接 veto
- 若扩到以下任一对象，直接 veto：
  - `workbench`
  - `my/projects` 新信息架构
  - 附件公开
  - 审核状态机
  - 交易后链
  - 企业所在地筛选
  - 地图 / 行政区联动
- 若删除 `title` 兼容承接，直接 veto
- 若把 `plannedEndAt` 改写成 persisted state machine，直接 veto

## 5. Dispatch Boundary

- 当前若进入真实实现派工 authoring，只允许围绕：
  - backend 最小 `project` dual-field + filter + expiry trimming truth binding
  - BFF 最小 `project/list`、`project/detail`、`project/create` app-facing shaping
  - frontend 最小项目展示列表 / 详情 / 创建页消费改造
- 当前 allowed directories 只允许写死为：
  - `apps/server/src/modules/project/**`
  - `apps/server/src/core/migrations/migrations.ts`
  - `apps/bff/src/routes/project/**`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
  - `apps/mobile/lib/features/exhibition/**` 中与上述页面直接相关的最小 consumer/supporting touch
- 当前不得放开：
  - `apps/server/src/modules/my_project/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_*`
  - 附件、审核、交易、地图相关目录

## 6. Stage Go / No-Go

- 当前阶段结论：
  - `Go` for bounded implementation dispatch authoring
  - `No-Go` for direct implementation
  - `No-Go` for integration
  - `No-Go` for release-prep
  - `No-Go` for production release

## 7. Current Meaning

- 当前允许含义：
  - 总控现在可以 author 有界实现派工
  - 但还不能把它解释成已经开工
- 当前不允许含义：
  - 不允许跳过后端先行顺序
  - 不允许跳过结果校验
  - 不允许把文书完成误写成实现完成

## 8. Next Unique Action

- 下一步唯一动作：
  - 输出《项目展示筛选与创建表单重构 bounded implementation dispatch bundle》
