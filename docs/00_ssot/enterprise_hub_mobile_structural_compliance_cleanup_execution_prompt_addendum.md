---
owner: Codex 总控
status: active
purpose: Execution prompt for the enterprise_hub mobile structural compliance cleanup.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_hub_mobile_structural_compliance_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_result_verification_conclusion_addendum.md
---

# 《enterprise_hub mobile structural compliance cleanup execution prompt》

## 1. 执行角色

- `Frontend Agent`

## 2. 唯一目标

你这轮只负责落实 `enterprise_hub mobile structural compliance cleanup`。

当前唯一目标固定为：

1. 非行为性拆分
2. 单一职责收口
3. 超长文件拆分
4. published-change workbench 既有行为保持不变

## 3. 强制阅读

1. [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
2. [enterprise_hub_mobile_structural_compliance_cleanup_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_mobile_structural_compliance_cleanup_stage_gate_checklist_addendum.md)
3. [enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_execution_receipt_addendum.md)
4. [enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_result_verification_conclusion_addendum.md)

## 4. 只允许修改的范围

- `apps/mobile/lib/features/exhibition/data/**`
- `apps/mobile/lib/features/exhibition/presentation/**`
- 与拆分直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/mobile` 之外的任何代码
- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不改 `docs/01_contracts/**`
- 不做新功能
- 不做 contract 变更
- 不做文案语义重设计
- 不做频次治理
- 不把“补豁免”当默认解法
- 不借拆分顺手改业务语义

## 6. 你必须完成

1. 非行为性拆分
- 把超长文件拆成单一职责组件/consumer/supporting unit
- 保持 published-change workbench 既有行为不变

2. 单一职责收口
- `enterprise_hub_published_change_consumer_layer.dart`
  不得继续作为单文件承载 published-change 全量消费逻辑
- `enterprise_hub_workbench_pages.dart`
  不得继续承载：
  - workbench shell
  - snapshot
  - case editor
  - published-change status
  等混合职责

3. 文件长度硬门禁
- 必须把 `AGENTS.md` 文件长度门禁作为硬验收条件：
  - 默认手写业务源码上限：
    - `450` 行
  - warning line：
    - `400`
  - 单文件只允许一个主职责
- 不接受：
  - 先登记豁免再不拆

## 7. 非目标

当前明确不做：

- 新功能
- 业务重构
- contract 变更
- `Server / BFF / Admin` 改动
- 文案语义重设计
- 频次治理

## 8. 最低验证要求

至少证明：

1. 两个超长风险文件已被拆解
2. 拆分后的职责边界清晰且单一
3. published-change/workbench 既有行为保持不变
4. 拆分后仍通过现有 published-change/workbench 相关测试
5. 不依赖豁免作为默认收口手段

## 9. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_hub_mobile_structural_compliance_cleanup_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 拆分后的职责分布
  3. 哪些超长文件已被拆解
  4. 哪些行为明确保持不变
  5. analyze / test 结果
  6. 当前是否允许进入 corridor 总体验收判断

## 10. 输出禁令

- 不要写“应该可以”
- 不要把结构整改写成功能开发
- 不要把豁免当默认解法
- 不要提前宣布 corridor 可总体验收
- 只给真实实现、真实测试、真实剩余风险
