---
owner: Codex 总控
status: active
purpose: Submit the stage gate checklist for the stage-1 trust-repair round so implementation can start only on the bounded workbench/public-list credibility fixes.
layer: L0 SSOT
freeze_date_local: 2026-04-17
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_drift_note_addendum.md
---

# 《企业展示工作台与公域列表可信度修复 stage-1 门禁核查表》

## 1. Stage Objective

- 当前 stage-1 目标固定为：
  - 修复已存在的 workbench / public-list 可信度问题
  - 不引入 founded-time filter 新能力
  - 不把云端运行态问题误报为本地已完成

## 2. Passed Gates

- passed gates:
  - 真源门禁
    - 当前 bounded object 已冻结
    - 当前 drift note 已明确记录
  - 架构边界门禁
    - Flutter 仍只消费 BFF
    - 当前 stage-1 不写云端 `Server` / `BFF` 代码
  - 阶段控制门禁
    - 当前对象单一
    - non-goals 已明确
    - allowed directories 已限定
  - 文件长度与职责门禁
    - 当前实施目标已收敛为最小 repair slice

## 3. Failed Gates

- failed gates:
  - contract-extension gate
    - founded-time filter 所需新 query contract 尚未冻结
  - cloud-implementation gate
    - 当前尚未证明必须改云端代码
  - release-prep gate
  - production-release gate

## 4. Veto Gates

- veto gates:
  - 若在 stage-1 里直接实现 founded-time filter，则 `No-Go`
  - 若把城市筛选继续保留为可点击死控件且无说明，则 `No-Go`
  - 若继续让 raw asset error 直出页面，则 `No-Go`
  - 若把 Logo-only 维护继续绑定联系人建档前置条件，则 `No-Go`
  - 若以本地通过替代云端运行态结论，则 `No-Go`

## 5. Whether The Next Stage Is Allowed

- whether the next stage is allowed:
  - `Allowed`

## 6. Allowed Role Set

- 当前允许进入的角色：
  - 总控
  - 总控文书冻结
  - 前端 Agent（仅本地）
  - 结果校验 Agent
- 当前待命角色：
  - 后端 Agent（仅云端）
  - BFF Agent（仅云端）
  - 联调发布 Agent

## 7. Next Unique Action

- 下一步唯一动作：
  - 冻结 frontend stage-1 repair surface
  - 派发本地 Flutter 实施
  - 对城市筛选与地址解析做运行态核查
