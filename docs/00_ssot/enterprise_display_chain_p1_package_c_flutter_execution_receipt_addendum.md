---
owner: Frontend Agent
status: active
purpose: Record the Flutter package C execution result for enterprise display chain P1 contact basic-save closure.
layer: L0 SSOT receipt
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_b_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_c_flutter_execution_prompt_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/test/enterprise_hub_routes_test.dart
---

# 《enterprise display chain P1 package C Flutter execution receipt》

## 1. 修改文件清单

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - 对应冻结事实：
    - 事实 1：普通保存当前走 `updateBasic`
    - 事实 2：正式 contract 已允许 `contactName / contactMobile`
    - 事实 4：当前剩余阻断只在 Flutter 请求体未发出这两个字段
- `apps/mobile/test/enterprise_hub_routes_test.dart`
  - 对应冻结事实：
    - 事实 2：contract 已允许两个字段
    - 事实 4：Flutter 不能再吞掉这两个字段
- `docs/00_ssot/enterprise_display_chain_p1_package_c_flutter_execution_receipt_addendum.md`
  - 本回执落盘

## 2. 每个修改点对应的冻结事实编号

### 2.1 workbench 普通保存发包补齐

- 代码位置：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart:503-521`
- 实际修改：
  - `_saveBasic()` 继续走既有 `EnterpriseHubConsumerLayer.instance.updateBasic(...)`
  - 仅把 body 组装改为调用 `enterpriseWorkbenchBasicUpdateBody(...)`
  - body 现已补齐：
    - `contactName`
    - `contactMobile`
- 对应冻结事实：
  - 事实 1
  - 事实 2
  - 事实 4

### 2.2 普通保存 body 组装收口

- 代码位置：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart:2353-2387`
- 实际修改：
  - 新增 `enterpriseWorkbenchBasicUpdateBody(...)`
  - 该 helper 直接生成 `_saveBasic()` 传给 `updateBasic` 的最终 body
  - `contactName / contactMobile` 统一走现有 `_emptyToNull(...)` 空值规范
- 对应冻结事实：
  - 事实 1
  - 事实 2
  - 事实 4

### 2.3 最小测试补齐

- 代码位置：
  - `apps/mobile/test/enterprise_hub_routes_test.dart:1430-1492`
- 实际修改：
  - 新增两条最小断言，直接锁定 `_saveBasic()` 实际传给 `updateBasic` 的 body 组装结果
- 对应冻结事实：
  - 事实 2
  - 事实 4

## 3. contactName / contactMobile 发包说明

- `contactName`
  - 来源：当前 workbench 联系人输入框 `_applicantNameController.text`
  - 发包位置：`enterpriseWorkbenchBasicUpdateBody(...)`
  - 归一化：`_emptyToNull(contactNameText)`
- `contactMobile`
  - 来源：当前 workbench 联系人输入框 `_applicantMobileController.text`
  - 发包位置：`enterpriseWorkbenchBasicUpdateBody(...)`
  - 归一化：`_emptyToNull(contactMobileText)`

当前发包结论：

- Flutter 普通保存不再吞掉 `contactName`
- Flutter 普通保存不再吞掉 `contactMobile`
- 当输入为非空时，body 发出真实字符串值
- 当输入为空字符串或仅空白时，body 保持键存在，但值按现有规范归一为 `null`

## 4. 未扩写其他 contact 字段的边界说明

- 本轮未新增：
  - `wechat`
  - `phone`
  - `email`
  - `position`
- `enterpriseWorkbenchBasicUpdateBody(...)` 的签名和返回体均未引入上述字段
- 普通保存链仍只有一条：
  - `_saveBasic()` -> `updateBasic`
- 本轮未新增第二条联系人保存链

## 5. 新增或更新的测试清单

- `enterprise workbench basic update body sends contactName and contactMobile`
  - 验证：
    - body 包含 `contactName`
    - body 包含 `contactMobile`
    - 不包含 `wechat / phone / email / position`
- `enterprise workbench basic update body normalizes empty contact fields without widening payload`
  - 验证：
    - 空字符串按现有规范归一为 `null`
    - 现有 basic save 关键字段仍保留：
      - `name`
      - `provinceCode`
      - `provinceName`
      - `cityCode`
      - `cityName`
    - 不包含 `wechat / phone / email / position`

## 6. analyze / test 结果

### 6.1 analyze

- 命令：
  - `cd apps/mobile && flutter analyze lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart test/enterprise_hub_routes_test.dart`
- 结果：
  - `No issues found!`

### 6.2 tests

- 命令：
  - `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise workbench basic update body sends contactName and contactMobile"`
  - `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise workbench basic update body normalizes empty contact fields without widening payload"`
- 结果：
  - `2 / 2 passed`

## 7. 当前剩余未闭合项

- Flutter package C / 本轮目标范围内：
  - 无剩余未闭合项
- 本轮未扩写、未重修：
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - submit disposition
  - recommendation
  - list
  - detail
  - image logic

## 8. 是否已达到联系人普通保存链 closure

- 结论：
  - `YES`

依据如下：

- Flutter `_saveBasic()` 现在会把 `contactName / contactMobile` 放进 `updateBasic` body
- 这两个字段直接取自当前 workbench 联系人输入框真实值
- 空值处理继续沿用当前 Flutter 规范
- 未顺手扩写其他 contact 字段
- `package B / BFF` 已有正式 `PASS` 结论，冻结事实 3 已成立

当前正式结论：

- 当前联系人普通保存链在 Flutter 层的剩余阻断已闭合
- 结合已冻结 contract 与 package B PASS 结论，`contactName / contactMobile` 的普通保存链已不再被 Flutter 截断
