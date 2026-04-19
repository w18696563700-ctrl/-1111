---
owner: Codex 总控
status: active
purpose: Freeze the frontend execution prompt for correcting the semantics and display conditions of the upstream-truth block and certification-summary block on the enterprise-display workbench.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_stage_gate_checklist_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/test/enterprise_hub_routes_test.dart
---

# 《enterprise display workbench upstream truth and certification summary semantics frontend execution prompt》

## 当前阶段

- 主线：
  - `enterprise display workbench`
- 子阶段：
  - `upstream truth / certification summary semantic correction`
- 当前执行 owner：
  - `Frontend Agent`

## 唯一目标

- 只修正 workbench 页面里：
  - `上游真值`
  - `认证摘要`
  这两个区块的显示条件与字段语义。

## 只允许修改的范围

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- 与本轮语义纠偏直接相关的最小测试文件

## 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不改 contract
- 不借机扩到 submit/status、recommendation、public list/detail
- 不重做工作台整页信息架构

## 你必须完成

1. `上游真值区` 改成条件显示：
   - 只在上游字段缺失或当前保存/提交确实被上游真值阻断时显示
   - 正常完整态下不显示整块卡
2. `认证摘要` 改成异常态显示：
   - `certificationStatus != approved` 时显示
   - 存在 `rejectReason` 时显示
   - 已认证且无异常时不显示整块卡
3. 前端废止 `注册城市` 这一字段名：
   - 当前工作台中不得再出现该标签
   - 替换成不暗示法定注册地的名称，例如 `组织所在城市`
4. 保持：
   - `企业名称 / 成立日期` 的上游来源说明仍可用
   - 当前页不可修改的语义仍清楚
   - 去 `我的公司` / `企业认证` 修复的指引仍存在
5. 不得误删当前真实阻断说明

## 你必须补的测试

至少补齐以下覆盖：

1. 上游字段齐全且认证已通过时：
   - `上游真值` 不显示
   - `认证摘要` 不显示
2. 组织城市或成立日期缺失时：
   - `上游真值` 显示
   - 且不再出现 `注册城市` 文案
3. 认证未通过或被驳回时：
   - `认证摘要` 显示
4. 正常态下：
   - 去修复来源的提示不应无差别常驻

## 完成标准

- 结果必须证明：
  1. 页面不再把不同来源的 truth 拼成常驻“企业法定真相”大卡
  2. `上游真值` 只在有解释价值时出现
  3. `认证摘要` 只在异常态或未完成态出现
  4. `注册城市` 误导性命名已从当前页移除

## 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_frontend_execution_receipt_addendum.md`
- 回执至少包含：
  1. 修改文件清单
  2. 条件显示规则说明
  3. `注册城市` 命名移除说明
  4. 新增或更新的测试清单
  5. analyze / test 结果
  6. 当前剩余未闭合项

## 输出禁令

- 不要写“应该可以”
- 不要继续把 `注册城市` 用作当前字段名
- 不要把 `认证摘要` 留成正常态常驻卡
- 不要借机去碰 backend truth
- 只给真实语义纠偏、真实测试、真实剩余风险
