---
owner: Codex 总控
status: active
purpose: Submit the stage gate checklist for the enterprise-display company/factory board-separation and case-media repair round so implementation can start only on the bounded repair package.
layer: L0 SSOT
freeze_date_local: 2026-04-19
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_hub_v1_reentry_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_company_workbench_and_exhibition_surface_current_state_protection_record_addendum.md
  - docs/00_ssot/enterprise_display_factory_workbench_and_exhibition_surface_addendum.md
---

# 《企业展示 company/factory 串板块与案例媒体回显维修阶段门禁核查表》

## 1. Stage Objective

- 当前维修阶段唯一目标固定为：
  - 纠正 company / factory 命名与 case board 混用
  - 修复 case continuation 图片回显链
  - 对齐 `public-cases` app-facing route 与 live 部署
  - 补齐最小回归测试与 runtime smoke
- 当前阶段不允许：
  - 新能力扩面
  - 新业务流程
  - production release judgment

## 2. Passed Gates

- passed gates:
  - 真源门禁
    - 当前 bounded object 已冻结
    - 问题族已在正式文书内收敛
  - 架构边界门禁
    - Flutter 仍只消费 `BFF`
    - `BFF` 仍只做 aggregation / shaping
    - `Server` 仍为唯一 truth owner
  - 阶段控制门禁
    - 当前对象单一
    - non-goals 已明确
    - allowed directories 已明确
  - 文件长度与职责门禁
    - 当前实施目标按 `Server / BFF / Flutter / data repair` 已拆分

## 3. Failed Gates

- failed gates:
  - live-deployment-consistency gate
    - `public-cases` 仓库已存在但 live tunnel 返回 `404`
  - result-verification gate
    - 当前 mixed-board case、caseImageUrlMap、真实 route smoke 尚未有闭环通过记录
  - release-prep gate
  - production-release gate

## 4. Veto Gates

- veto gates:
  - 若只修 Flutter 而不修 `Server` 的 `enterpriseId` 裸收口 case 读取，则 `No-Go`
  - 若在合同未冻结前直接做线上数据修复，则 `No-Go`
  - 若把 `public-cases 404` 视为非阻断问题，则 `No-Go`
  - 若继续允许 `caseImageUrlMap` 被静默裁成 `{}` 而无测试拦截，则 `No-Go`
  - 若 mixed-board case 隔离测试未补齐就进入 release 讨论，则 `No-Go`

## 5. Whether The Next Stage Is Allowed

- whether the next stage is allowed:
  - `Allowed`

## 6. Allowed Role Set

- 当前允许进入的角色：
  - Codex 总控
  - Backend Agent
  - BFF Agent
  - Frontend Agent
  - Runtime verification / smoke Agent
- 当前待命角色：
  - 数据修复执行角色
  - 发布角色

## 7. Stage Go / No-Go Decision

- `Go` for:
  - docs freeze
  - backend truth repair
  - BFF surface repair
  - Flutter consumption repair
  - bounded data-repair preparation
- `No-Go` for:
  - release-prep
  - production release
  - non-enterprise_hub scope expansion

## 8. Next Unique Action

- 下一步唯一动作：
  - 冻结 contract / backend / BFF / frontend 四层维修范围
  - 输出正式维修任务单
  - 然后才能进入实现派工

