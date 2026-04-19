---
owner: Codex 总控
status: active
purpose: Freeze the stage gate before the enterprise display case-continuation and published-change contract patch.
layer: L0 SSOT
---

# 《enterprise display case continuation and published change contract patch stage gate checklist》

## 当前阶段目标

本阶段只允许：

1. 补 `case detail / case update` app-facing contract
2. 补 `published change corridor` app-facing contract
3. 重新生成 `packages/contracts`

本阶段不允许：

- 直接发 `Server / BFF / Flutter` 实现包
- 直接把已发布展示修改实现成线上即改
- 把 `case continuation` 再做成 `user-owned`

## 门禁核查

### 1. 真源门禁

- passed
- 依据：
  - [enterprise_display_case_library_continuation_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_truth_freeze_addendum.md)
  - [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)

### 2. 契约门禁

- passed for `openapi patch`
- failed for `implementation dispatch`
- 原因：
  - 当前 contract 仍未落到 runtime implementation
  - `published change corridor` 仍未补 Admin / 治理承接 contract

### 3. 架构边界门禁

- passed
- 依据：
  - 本阶段只补 app-facing contract
  - 不新增前台直连主链
  - `Flutter -> BFF -> Server` 主链不漂移

### 4. 状态机门禁

- passed for `contract patch`
- veto for `published corridor implementation`
- 原因：
  - `change request` 虽已进入 app contract，但 Admin review / apply contract 尚未冻结

### 5. 一票否决门禁

- active veto gates:
  - 不得把 `PUT /cases/{caseId}` 扩成 published 直改线上后门
  - 不得让 `changes/current` save path 直接覆盖 live listing
  - 不得把 `published corridor` 伪装成已实现

## 结论

- allowed now:
  - `openapi + generated contract patch`
- not allowed now:
  - `published change corridor implementation dispatch`

## 下一步唯一动作

当前 contract patch 完成后，只允许进入二选一排序：

1. `case continuation` implementation planning
2. `published corridor admin-governance contract freeze`

在上述下一步完成前：

- `published corridor implementation` = `No-Go`
