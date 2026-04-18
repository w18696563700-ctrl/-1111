---
owner: Codex 总控
status: active
purpose: Freeze the stage-gate checklist for the current factory-detail remediation round so dispatch may proceed only after the bounded freeze chain, topology freeze, and A/B split have been formally accepted.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/factory_detail_optimization_remediation_bounded_object_ruling_addendum_v1_1.md
  - docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
  - docs/02_backend/factory_detail_optimization_remediation_backend_truth_addendum_v1_1.md
  - docs/03_bff/factory_detail_optimization_remediation_bff_surface_addendum_v1_1.md
  - docs/04_frontend/factory_detail_optimization_remediation_frontend_surface_addendum_v1_1.md
---

# 《工厂详情优化修复 Stage Gate Checklist V1.1》

## 1. 当前目标包

- 当前目标包固定为：
  - 工厂详情结构去重
  - 工厂详情地区与名称口径收口
  - `formal-info` app-facing 链路成立
  - 案例展示状态语义纠偏
- 当前明确不包含：
  - 公司详情 / 供应商详情同步大改
  - 企业详情系统整体重构
  - 企业身份真值系统重做
  - 与当前对象无关的整站视觉翻修

## 2. passed gates

- `真源门禁`：PASS
  - 当前对象已在本地 `docs/` 中冻结，不以云端口头描述代替正式真源。
- `架构边界门禁`：PASS
  - 当前仍保持：
    - 前端仅本地
    - `BFF` / `Server` 仅云端
    - `Flutter App -> BFF -> Server` 单链路不变
- `契约门禁`：PASS
  - 当前轮已补入独立 contracts freeze，不再以前端局部文案代替契约定义。
- `阶段控制门禁`：PASS
  - 当前目标、非目标、A/B 边界、拓扑和验收规则均已冻结。
- `前端体验门禁`：PASS
  - 当前已明确禁止 fake success、fake route completion、前端遮丑式地区修补。

## 3. failed gates

- 当前 failed gates 固定为：
  - 工厂详情旧代码入库态仍保留图下白卡主信息结构，尚未与目标首屏形态对齐。
  - 云端工厂公开详情仍存在地区 / 地址 / 名称口径冲突。
  - `formal-info` 云端 app-facing 路由当前仍未成立到可用态。
  - 案例展示当前缺少“无数据 / 未接通”清晰区分。

## 4. veto gates

- 不得把前端本地文本改写当成地区真值修复。
- 不得把 `formal-info` 弹层 UI 当成链路已通。
- 不得在未冻结图源优先级前直接隐藏正文企业画册。
- 不得让前端直接把 `fileAssetId` 当图片 URL。
- 不得把 `cases=[]` 一律写成“暂未接通”。
- 不得跳过：
  - `SSOT -> contracts -> backend truth -> BFF -> frontend`
- 不得在未提交《阶段门禁核查表》前发出实现派工。

## 5. stage go / no-go decision

- 当前 gate decision 正式固定为：
  - `Go for docs-first freeze`
  - `Go for A/B dispatch authoring`
  - `Go for bounded frontend implementation dispatch`
  - `Go for bounded backend/BFF implementation dispatch`
  - `No-Go for full detail-system rewrite`
  - `No-Go for cloud truth compensation in frontend`

## 6. 当前下一步唯一动作

- 当前下一步唯一动作固定为：
  - `由总控发出 A/B 派工单，并按 A / B 两单持续收回执直到 Gate 4 收口`

## 7. Formal Conclusion

- 当前 passed gates、failed gates、veto gates 已明确。
- 当前没有 failed veto gate，因此：
  - 当前阶段结论为 `Go`
- 但正式 Go 只覆盖：
  - 当前对象的 bounded dispatch
  - A/B 分轨实施
  - 结果校验与联调准备
- 当前不授予：
  - 无边界范围扩写
  - 与当前对象无关的系统重构许可
