---
owner: Codex 总控
status: active
purpose: Freeze the frontend repair surface for the enterprise-display workbench and public-list trust-repair round so current blockers are fixed without expanding into new contracts.
layer: L4 Frontend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_stage1_gate_checklist_addendum.md
  - docs/04_frontend/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
  - docs/04_frontend/enterprise_display_stage2_public_card_and_album_frontend_consumption_addendum.md
---

# 《企业展示工作台与公域列表可信度修复 stage-1 frontend surface freeze》

## 1. Scope

- 当前 frontend freeze 只补：
  - workbench truth-derived 字段显示与阻断解释
  - Logo-only 维护路径
  - 地址解析失败态与 asset 失败态兜底
  - company 公域列表 Logo 呈现
  - company 公域列表城市筛选可用性
- 当前不补：
  - founded-time filter
  - 详情页整体重排
  - 新信用系统

## 2. Workbench Truth Rule

- `公司名称`
  - 继续是只读 truth-derived 字段
  - 当前不得回退为手填字段
- `公司位置`
  - 继续只显示省市
  - 当前若上游真值缺失，必须明确告诉用户去哪里补
- 当前不得：
  - 只显示空 placeholder 而不给上游修复路径

## 3. Logo Maintenance Rule

- `展示标识 / Logo` 的维护当前必须独立可达。
- 当前不得因为联系人缺失而让用户连 Logo 都无法维护。
- 若当前实现仍依赖建档 carrier：
  - 前端必须给出与当前动作相匹配的受控行为
  - 不得继续把“上传 Logo”解释成“必须先补联系人”

## 4. Location Failure Rule

- `解析文字地址` 当前失败态至少要区分：
  - 位置输入不完整
  - provider 暂不可用
  - provider 配置缺失
  - 通用失败
- 当前 asset / region catalog 失败时：
  - 不得把 raw `Unable to load asset` 直接暴露给用户作为主要解释
  - 必须进入受控失败文案

## 5. Submit Explanation Rule

- `提交入驻申请` 按钮置灰时：
  - 必须同屏展示明确的未完成项
  - 不得只保留灰按钮本身
- 当前若进入异常失败路径：
  - 仍必须优先给出“为什么不能提交”的说明，而不是只露出技术错误

## 6. Public List Rule

- company 公域列表卡片当前必须优先消费：
  - `logoUrl`
  - 缺失时才回退首字占位
- 城市筛选当前必须满足二选一：
  - 可用且点击后有实际效果
  - 或明确禁用并告诉用户当前不可用
- 当前不得继续保留“看起来可点但无反应”的城市筛选控件。

## 7. Non-goals

- 不新增 founded-time query
- 不新增公司名筛选字段
- 不改写既有 `serviceItems + 信用评分建设中` 的 stage-2 company 卡片裁决

## 8. Anti-revert

- 不得把 company 公域卡片退回只用首字占位
- 不得把城市筛选死控件继续留在可点击态
- 不得把 workbench 阻断说明继续藏在模糊文案里
- 不得把 raw asset error 当作正式用户提示
- 不得借修复之名恢复 company 的旧主编辑字段
