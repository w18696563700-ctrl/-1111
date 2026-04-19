---
owner: Codex 总控
status: active
purpose: Freeze the backend execution prompt for enterprise display chain P1 package A so Server closes the first minimal-closure truth gaps before any BFF or Flutter follow-up implementation is allowed.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/**
---

# 《enterprise display chain P1 package A backend execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display chain`
- 子阶段：
  - `P1 minimal closure`
- 当前包：
  - `package A / backend`

## 2. 唯一目标

- 你这轮只负责关闭 `Server truth` 的第一批最小闭环阻断。
- 这轮只允许解决四件事：
  1. 联系人真实保存闭环
  2. 公域案例口径统一
  3. 图片展示投影闭环
  4. 公域 `published + visible` 读取规则统一核落

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md`
- `docs/01_contracts/openapi.yaml`
- `docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md`

## 4. 只允许修改的范围

- `apps/server/src/modules/enterprise_hub/**`
- 与本轮最小闭环直接相关的最小测试文件
- 如确有 contract 漏项，必须先由总控补文书与 OpenAPI，后端不得自行猜字段

## 5. 禁止事项

- 不改 `apps/mobile/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不新增新的 `/api/app/*` path family
- 不新增第二套企业 truth
- 不新增第二状态机
- 不把 `applicationStatus` 伪装成公域可见性 truth
- 不允许前端自己拼图片 URL
- 不扩到推荐位策略、排序策略、详情深化、入口扩张

## 6. 当前已冻结的事实

1. 联系人当前是假可编辑：
   - 页面可编辑
   - 普通保存不真实落库
   - readiness 又只认持久化结果
2. 案例公域口径当前不一致：
   - 详情只读 `approved`
   - 列表 `caseCount` 统计全部案例
3. 图片当前存储真相是 `fileAssetId`
   - 但公域 presenter 仍未给出稳定展示投影
4. 公域列表、详情、首页推荐位必须统一只读：
   - `enterpriseStatus = published`
   - `displayStatus = visible`

## 7. 你必须完成

### 7.1 联系人真实保存闭环

- 你必须让 workbench 联系人字段满足：
  - 普通保存后真实持久化
  - refresh 后读回持久化值
  - readiness 的 `hasContact` 与持久化 truth 一致
- 不允许继续把联系人 upsert 只绑在 `createApplication()`

### 7.2 公域案例口径统一

- 你必须让以下三处统一到当前冻结口径：
  - 公域列表 `caseCount`
  - 公域详情案例区
  - 任何公域摘要里的案例数字
- 当前冻结口径固定为：
  - `caseStatus = approved`
- 不允许继续出现：
  - 列表显示有案例
  - 详情却没有任何公域可见案例

### 7.3 图片展示投影闭环

- 你必须保持存储真相仍为：
  - `logoFileAssetId`
  - `coverFileAssetId`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
- 你必须在 server-owned read model / presenter 上补齐展示投影。
- 不允许通过“让 Flutter 自己猜 URL”来规避服务端闭环。

### 7.4 公域可见性统一核落

- 你必须独立核对并收口：
  - 公域列表
  - 公域详情
  - 首页推荐位企业读取
- 三者都必须建立在同一 listing 可见性规则上：
  - `published + visible`
- 不允许某一处绕过 publish/display gating。

## 8. 你必须补的测试

至少补齐以下覆盖：

1. 联系人普通保存后可持久化读回
2. readiness 的 `hasContact` 与持久化联系人一致
3. 公域列表 `caseCount` 只统计 `approved` 案例
4. 公域详情只返回 `approved` 案例
5. 公域列表 / 详情 / 推荐位都共同遵守 `published + visible` listing 读取边界
6. 图片展示投影在 read model 中可稳定返回，不再长期为空

## 9. 完成标准

- 结果必须能证明：
  1. 联系人不再是假可编辑
  2. 公域案例数字与案例内容口径一致
  3. 图片展示投影由 server 真正闭环
  4. 首页 / 列表 / 详情不再各自解释可见性规则
- 如果你只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 `package A backend` 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_chain_p1_package_a_backend_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 每个修改点对应的冻结事实编号
  3. 联系人真实保存的实现说明
  4. 案例口径统一的实现说明
  5. 图片展示投影闭环的实现说明
  6. `published + visible` 统一核落的实现说明
  7. 新增或更新的测试清单
  8. build / test 结果
  9. 当前剩余未闭合项
  10. 是否可移交 `BFF package B`

## 11. 输出禁令

- 不要写“应该可以”
- 不要只给代码阅读结论
- 不要把非 `approved` 案例继续塞进公域数字
- 不要把图片空值留给前端猜
- 不要把 publish/display gating 漂成页面层判断
- 只给真实实现、真实测试、真实剩余风险

