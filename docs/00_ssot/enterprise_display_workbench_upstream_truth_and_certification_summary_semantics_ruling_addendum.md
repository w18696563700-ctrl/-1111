---
owner: Codex 总控
status: active
purpose: Freeze the semantic ruling for the enterprise-display workbench upstream-truth block and certification-summary block after runtime evidence shows the current always-on presentation is both redundant and semantically misleading.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_information_architecture_frontend_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_workbench_information_architecture_frontend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_workbench_truth_fields_ux_closure_frontend_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_workbench_truth_fields_ux_closure_frontend_result_verification_conclusion_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/test/enterprise_hub_routes_test.dart
---

# 《enterprise display workbench upstream truth and certification summary semantics ruling》

## 1. 当前问题裁决

- 当前问题不是单纯“页面信息多不多”，而是：
  - `上游真值` 区被做成了长期常驻大块只读卡
  - `认证摘要` 区也被做成了长期常驻摘要卡
  - 两块连在一起后，会把不同来源的字段误读成同一套法定企业真相

## 2. 已证实的语义错误

### 2.1 `注册城市` 当前不是法定注册地真相

- workbench presenter 当前给前端的城市来源是：
  - `listing.provinceName`
  - `listing.cityName`
- 这条链当前不是营业执照法定注册地专属 truth carrier。
- 因此前端把该字段标成 `注册城市` 会制造错误语义。

### 2.2 `认证摘要` 当前信息重复度过高

- `认证摘要` 当前展示：
  - 认证状态
  - 企业名称
  - 统一社会信用代码
- 这些内容在工作台主任务流里不是当前用户动作的核心输入，且在 `已认证且无异常` 情况下不会提供新的决策价值。

### 2.3 `上游真值区` 的职责被放大了

- 该区的真实职责应该是：
  - 解释为什么当前页不能改
  - 解释缺值时该去哪里修
- 它不应该在真值完整、当前无阻断时长期常驻占据大块空间。

## 3. 正式裁决

### 3.1 `上游真值区` 不是常驻信息块

- `上游真值区` 正式降级为：
  - `条件显示的阻断解释区`
- 只在以下任一条件成立时显示：
  1. 上游字段缺失
  2. 当前保存或提交仍被上游真值阻断
  3. 当前需要明确告诉用户“去我的公司 / 企业认证修复”

在上述条件都不成立时：

- 不显示整块 `上游真值` 卡

### 3.2 `认证摘要` 不是常驻信息块

- `认证摘要` 正式降级为：
  - `异常态或非完成态提示区`
- 只在以下任一条件成立时显示：
  1. `certificationStatus != approved`
  2. 存在 `rejectReason`
  3. 当前确实需要向用户解释认证状态为何影响提交流转

当认证已通过且无异常时：

- 不显示单独的 `认证摘要` 区块

### 3.3 前端立即废止 `注册城市` 这一显示命名

- 在 dedicated legal-registration-location truth 尚未冻结前：
  - 前端不得再把当前字段命名为 `注册城市`
- 当前前端允许的临时命名只允许使用：
  - `组织所在城市`
  - 或等价且不暗示法定注册地的名称

### 3.4 本轮不重写后端 truth

- 本轮裁决只修正前端显示语义与显示条件。
- 本轮不新增：
  - legal registration location truth
  - 第二套 organization truth
  - 第二套 certification truth

## 4. 前端执行边界

- 当前允许的动作：
  - workbench 页面显示条件收口
  - 标签命名纠偏
  - 异常态 / 阻断态 copy 收口
- 当前不允许的动作：
  - 改 `Server` presenter truth
  - 改 `BFF`
  - 改 contract
  - 借机扩写新的认证详情面

## 5. Formal Conclusion

- `上游真值区`：
  - 正式角色 = `条件显示的阻断解释区`
  - 常驻展示 = `No-Go`
- `认证摘要`：
  - 正式角色 = `异常态或非完成态提示区`
  - 常驻展示 = `No-Go`
- `注册城市` 命名：
  - 当前前端继续使用 = `No-Go`
