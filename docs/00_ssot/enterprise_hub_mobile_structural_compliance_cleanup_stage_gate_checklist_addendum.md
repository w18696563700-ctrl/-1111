---
owner: Codex 总控
status: active
purpose: Freeze the stage gate before dispatch authoring for the enterprise_hub mobile structural compliance cleanup.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_result_verification_conclusion_addendum.md
---

# 《enterprise_hub mobile structural compliance cleanup stage gate checklist》

## 当前阶段目标

本阶段只允许：

1. 派发 `enterprise_hub mobile structural compliance cleanup`
2. 在 `Flutter` 侧落实：
   - 非行为性拆分
   - 单一职责收口
   - 超长文件拆分
   - published-change workbench 既有行为保持不变
3. 把 corridor 当前的结构治理风险收口到 `AGENTS.md` 文件长度与职责门禁内

本阶段不允许：

- 把结构整改写成业务 reopen
- 借拆分顺手改业务语义
- 先登记豁免再不拆
- 提前把 corridor 推进到总体验收

## 门禁核查

### 1. 功能实现基础门禁

- passed
- 依据：
  - [enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_execution_receipt_addendum.md)
- 原因：
  - published-change workbench / status / submit flow 已有真实执行回执
  - 本轮不需要重开功能真相，只需要处理结构合规风险

### 2. 独立校验风险门禁

- passed for `structural cleanup dispatch authoring`
- failed for `corridor 总体验收`
- 依据：
  - [enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_result_verification_conclusion_addendum.md)
- 原因：
  - 当前独立结论已写死：
    - `Package D = PASS WITH RISK`
    - `published change corridor` 不能进入总体验收判断
  - 风险来源不是业务未达成，而是结构门禁未闭合

### 3. AGENTS 结构门禁

- passed for `结构治理整改`
- failed for `总体验收`
- 依据：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- 当前风险文件：
  - `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart`
    - `674` 行
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
    - `4917` 行
- 对应硬门禁：
  - 默认手写业务源码上限：
    - `450` 行
  - warning line：
    - `400`
  - 单文件只允许一个主职责

### 4. 一票否决门禁

- active veto gates:
  - 不接受“先登记豁免再不拆”
  - 不接受借结构整改顺手改业务语义
  - `enterprise_hub_published_change_consumer_layer.dart` 不得继续作为单文件承载 published-change 全量消费逻辑
  - `enterprise_hub_workbench_pages.dart` 不得继续承载 workbench shell、snapshot、case editor、published-change status 等混合职责
  - 拆分后仍须通过现有 published-change/workbench 相关测试

## 结论

- `结构治理整改 = Go`
- `总体验收 = No-Go`

原因固定为：

1. 当前问题是结构合规风险，不是业务真相缺口
2. 只有先完成 `Flutter` 侧非行为性拆分整改，才可能重新判断 corridor 总体验收
3. 本轮 authoring 不是 implementation unlock，也不是业务 reopen

## 下一步唯一动作

下一步只允许发：

- `enterprise_hub mobile structural compliance cleanup`
