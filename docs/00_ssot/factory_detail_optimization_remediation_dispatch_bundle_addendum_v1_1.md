---
owner: Codex 总控
status: active
purpose: Freeze the bounded dispatch order, role split, receipt expectations, and topology guardrails for the current factory-detail remediation round.
layer: L0 SSOT
freeze_date_local: 2026-04-18
based_on:
  - docs/00_ssot/factory_detail_optimization_remediation_bounded_object_ruling_addendum_v1_1.md
  - docs/00_ssot/factory_detail_optimization_remediation_stage_gate_checklist_addendum_v1_1.md
  - docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
  - docs/02_backend/factory_detail_optimization_remediation_backend_truth_addendum_v1_1.md
  - docs/03_bff/factory_detail_optimization_remediation_bff_surface_addendum_v1_1.md
  - docs/04_frontend/factory_detail_optimization_remediation_frontend_surface_addendum_v1_1.md
---

# 工厂详情优化修复 A/B 双轨派工单 V1.1

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 闭合工厂详情的结构去重、地区真值收口、`formal-info` 链路成立、案例状态语义纠偏

## B. 当前轮拓扑冻结

- 前端仅本地开发：
  - `apps/mobile/**`
- `BFF` 仅云端开发：
  - `apps/bff/**`
- `Server` 仅云端开发：
  - `apps/server/**`
- 当前唯一正式 app-facing 验证隧道固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 隧道只用于验证，不把云端开发伪装成本地开发。

## C. 当前轮 package split

### C1. Package A | 前端结构去重包

- owner：
  - `前端 Agent`
- unique goal：
  - 工厂 Hero 去重
  - 正文企业画册隐藏
  - `月产能` 移除
  - 核心能力双列与设备清单硬规则
  - 资质 / 案例文案纠偏

### C2. Package B1 | Backend 真值收口包

- owner：
  - `后端 Agent`
- unique goal：
  - 地区 / 名称 / 地址真值收口
  - `formal-info` 真值链成立
  - `showcase` 展示型 carrier 补齐

### C3. Package B2 | BFF app-facing 收口包

- owner：
  - `BFF Agent`
- unique goal：
  - `formal-info` app-facing path 打通
  - `showcase` URL shaping
  - 案例状态与地区 / 名称字段 app-facing 收口

### C4. Package C | 结果校验包

- owner：
  - `结果校验 Agent`
- unique goal：
  - 逐条复核 A / B 的冻结规则是否成立

### C5. Package D | 联调发布包

- owner：
  - `联调发布 Agent`
- unique goal：
  - 通过隧道完成本地前端与云端 app-facing 的 smoke 与 release-prep 结论

## D. 当前轮执行顺序

1. 总控完成 docs-first freeze。
2. 总控发出 A / B 派工单。
3. `A` 与 `B` 可串行或并行实施。
4. `A` 完成后可先做本地展示验收。
5. `B` 完成后做云端链路验收。
6. `A` 与 `B` 均通过后，转入结果校验。
7. 结果校验通过后，联调发布 Agent 才允许进入隧道验证。

## E. 当前轮回执最低要求

前端 / BFF / 后端回执至少包含：

1. 当前对象是否完成
2. 修改文件清单
3. 已完成项
4. 未完成项
5. 证据点
6. 风险与阻塞
7. 是否建议继续下一轮
8. 若继续，下一轮唯一目标是什么

## F. 当前轮 Formal Conclusion

- 当前唯一合法推进路径固定为：
  - `docs-first freeze -> A/B implementation dispatch -> result verification -> integration/release-prep`
- 未经 A/B 双通过，不得宣称当前轮已收口。
