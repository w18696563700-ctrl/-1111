---
owner: Codex 总控
status: active
purpose: Execution prompt for the Flutter package that wires direct enterprise display case-library continuation into the workbench.
layer: L0 SSOT
---

# 《enterprise display case library continuation Flutter execution prompt》

## 执行角色

- Frontend Agent

## 读取顺序

执行前必须强制阅读：

1. [enterprise_display_case_library_continuation_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_truth_freeze_addendum.md)
2. [enterprise_display_case_library_continuation_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md)
3. [enterprise_display_case_continuation_error_code_contract_sync_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_continuation_error_code_contract_sync_result_verification_conclusion_addendum.md)
4. [enterprise_display_case_library_continuation_flutter_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_flutter_stage_gate_checklist_addendum.md)
5. [docs/01_contracts/openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 唯一目标

你这轮只负责在 Flutter 工作台接入 direct case continuation。

当前唯一目标固定为：

1. 案例库每条案例提供：
   - `继续编辑`
2. 点击 `继续编辑` 后：
   - 通过 `GET /api/app/exhibition/enterprise-hub/cases/{caseId}` 读取完整 edit carrier
   - 回填当前案例编辑器
3. 案例编辑器进入 `编辑模式` 后：
   - 主动作从 `保存案例` 变成 `保存修改`
   - 保存走 `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
4. 保持 direct continuation 与 published corridor 分离：
   - 若命中 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
   - 只做受控提示
   - 不实现 `changes/current`

## 允许修改

- `apps/mobile/lib/features/exhibition/**`
- 与本轮最小 Flutter 闭环直接相关的最小测试文件

## 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不实现 `changes/current`
- 不恢复 `draft` 术语
- 不把案例库做成 `user-owned`

## 必须完成

1. consumer layer
- 补入：
  - `getCaseDetail(caseId)`
  - `updateCase(caseId, body)`
- canonical path 只允许走：
  - `/api/app/exhibition/enterprise-hub/cases/{caseId}`

2. workbench page
- 增加当前编辑中的 case 上下文：
  - `editingCaseId`
  - `isCaseEditing`
- 从案例库点击 `继续编辑` 后：
  - 拉取 detail
  - 回填标题、展会类型、城市、日期、摘要、图片、重点标记
- 编辑模式下主按钮文案改成：
  - `保存修改`
- 保存成功后：
  - 清空编辑上下文
  - 回到新建模式
  - 重新拉 workbench

3. case library card
- `EnterpriseWorkbenchCaseListCard` 必须补：
  - `onContinueEdit`
  - `继续编辑` 按钮
- 保留：
  - `删除案例`

4. error handling
- 若 direct case update 命中：
  - `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
- 只显示明确提示：
  - 当前案例已进入正式展示变更流程
  - 当前页不继续假装可直接编辑

## 最低测试要求

至少补齐：

1. 案例库卡片出现 `继续编辑`
2. 点击 `继续编辑` 后会加载 case detail 并回填编辑器
3. 编辑模式下按钮文案为 `保存修改`
4. `保存修改` 走 `PUT /cases/{caseId}`
5. `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED` 只做受控提示，不触发 fake continuation

## 完成标准

结果必须证明：

1. Flutter 已具备 direct case continuation UI 闭环
2. 前台继续不暴露 `draft jargon`
3. direct continuation 与 published corridor 仍然分离

如果只能闭合一部分：

- 必须逐条写出未闭合项
- 不得把整个 Flutter package 写成已完成
