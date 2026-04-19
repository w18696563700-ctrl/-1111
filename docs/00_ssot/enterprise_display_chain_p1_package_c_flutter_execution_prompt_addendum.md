---
owner: Codex 总控
status: active
purpose: Freeze the Flutter execution prompt for enterprise display chain P1 package C so the workbench basic save request closes the remaining contact write-path gap without widening scope.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_b_result_verification_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/**
---

# 《enterprise display chain P1 package C Flutter execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display chain`
- 子阶段：
  - `P1 minimal closure`
- 当前包：
  - `package C / Flutter`

## 2. 唯一目标

- 你这轮只关闭联系人普通保存链在 Flutter 这一层的剩余阻断。
- 当前唯一目标固定为：
  - 让 workbench 普通保存把 `contactName / contactMobile` 真正发进 `updateBasic` 请求体

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_b_result_verification_conclusion_addendum.md`
- `docs/01_contracts/openapi.yaml`

## 4. 只允许修改的范围

- `apps/mobile/lib/features/exhibition/**`
- 与本轮最小请求闭环直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不新增新的路由
- 不新增第二条联系人保存链
- 不顺手扩到 `wechat / phone / email / position`
- 不改 submit disposition、推荐位、列表、详情、图片逻辑

## 6. 当前已冻结事实

1. 普通保存当前走：
   - `updateBasic`
2. 正式 contract 已允许：
   - `contactName`
   - `contactMobile`
3. `BFF` 当前已可透传这两个字段
4. 当前剩余阻断只在 Flutter 请求体未发出这两个字段

## 7. 你必须完成

1. 在 workbench `_saveBasic()` 的 `updateBasic` body 中补齐：
   - `contactName`
   - `contactMobile`
2. 两个字段必须取自当前 workbench 联系人输入框的真实值
3. 保持行为最小：
   - 提供时发出
   - 空字符串按现有空值规范处理
4. 不得顺手把其他联系人字段塞进普通保存链

## 8. 你必须补的测试

至少补齐以下覆盖：

1. 普通保存请求体包含 `contactName`
2. 普通保存请求体包含 `contactMobile`
3. 空值处理不破坏现有 basic save 行为
4. 不会顺手把其他未开放联系人字段塞入请求体

## 9. 完成标准

- 结果必须能证明：
  1. Flutter 不再吞掉联系人普通保存字段
  2. 联系人普通保存链已从 Flutter -> BFF -> Server 完整打通
  3. 当前联系人普通保存阻断已闭合
- 如果只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 `package C / Flutter` 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_chain_p1_package_c_flutter_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 每个修改点对应的冻结事实编号
  3. `contactName / contactMobile` 发包说明
  4. 未扩写其他 contact 字段的边界说明
  5. 新增或更新的测试清单
  6. analyze / test 结果
  7. 当前剩余未闭合项
  8. 是否已达到联系人普通保存链 closure

## 11. 输出禁令

- 不要写“应该可以”
- 不要把 contract 或 BFF 问题再拉回重修
- 不要顺手扩字段
- 不要把本轮改动扩到 submit / list / detail / recommendation
- 只给真实发包、真实测试、真实剩余风险

