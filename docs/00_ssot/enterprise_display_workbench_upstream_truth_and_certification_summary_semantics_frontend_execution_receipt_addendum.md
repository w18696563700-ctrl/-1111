# enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_frontend_execution_receipt_addendum

## 1. 修改文件清单

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - 收口 workbench 中“上游真值”“认证摘要”两块的条件显示语义
  - 移除当前页可见文案里的“注册城市”命名
  - 增加前端纯规则函数，供当前页渲染与最小测试共用
- `apps/mobile/test/enterprise_hub_routes_test.dart`
  - 更新正常态 widget 用例
  - 新增最小语义规则测试

## 2. 条件显示规则说明

### 2.1 上游真值

当前改为条件显示，不再常驻：

- `enterpriseWorkbenchShouldShowUpstreamTruthSection(...) == true` 时显示
- 判定条件只看当前 workbench 真正需要解释的上游字段：
  - `enterpriseNameTruth` 缺失
  - `organizationCityTruth` 缺失
  - `foundedAtTruth` 缺失
- 只有在 workbench 读链为 `content` 时才参与渲染

正常完整态下：

- 上游真值整块不显示
- 去我的公司 / 企业认证修复来源的提示不常驻

缺值态下：

- 上游真值整块显示
- 企业名称 / 组织所在城市 / 成立日期 仍保留只读来源说明
- 去我的公司 / 企业认证修复的指引仍保留

### 2.2 认证摘要

当前改为异常态显示，不再常驻：

- `enterpriseWorkbenchShouldShowCertificationSummary(...) == true` 时显示
- 判定条件：
  - `certificationStatus` 不是已通过态
  - 或存在 `rejectReason`
- 当前前端将 `approved / verified` 视为已通过态
- 只有在 workbench 读链为 `content` 时才参与渲染

已认证且无异常时：

- 认证摘要整块不显示

未通过、待补齐、审核中、驳回有原因时：

- 认证摘要整块显示

## 3. “注册城市”命名移除说明

当前 workbench 可见文案已废止“注册城市”字段名，统一改为：

- `组织所在城市`

本轮已同步调整的可见 copy：

- 上游真值字段标签
- 缺值 placeholder
- 去我的公司修复提示
- 详细地址辅助说明
- 普通保存缺值提示

当前页保留的修复说明仍然明确：

- 企业名称 / 成立日期：去企业认证修复
- 组织所在城市：去我的公司修复

## 4. 新增或更新的测试清单

- `enterprise apply route hides upstream truth and certification summary in normal state`
  - widget 测试
  - 验证正常态下：
    - 上游真值不显示
    - 认证摘要不显示
    - 去修复来源提示不常驻
    - 当前页不再出现“注册城市”
- `enterprise workbench upstream truth semantics show only when organization city or founded date truth is missing`
  - 纯规则测试
  - 验证：
    - 正常完整态不显示
    - 组织所在城市缺失时显示
    - 成立日期缺失时显示
    - 字段命名与缺值提示不再包含“注册城市”
- `enterprise workbench certification summary semantics show only in abnormal states`
  - 纯规则测试
  - 验证：
    - `approved / verified` 不显示
    - `submitted` 显示
    - 有 `rejectReason` 时显示

## 5. analyze / test 结果

### 5.1 Analyze

执行：

```bash
cd apps/mobile
flutter analyze \
  lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart \
  test/enterprise_hub_routes_test.dart
```

结果：

- `No issues found!`

### 5.2 Tests

执行：

```bash
cd apps/mobile
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise apply route hides upstream truth and certification summary in normal state"
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise workbench upstream truth semantics show only when organization city or founded date truth is missing"
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise workbench certification summary semantics show only in abnormal states"
```

结果：

- 3 / 3 passed

## 6. 当前剩余未闭合项

当前前端本轮目标范围内，无剩余未闭合项。

本轮未涉及且保持不变：

- `apps/server/**`
- `apps/bff/**`
- `apps/admin/**`
- contract
- submit / status
- recommendation
- public list / detail
- 工作台整页信息架构
