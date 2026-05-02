---
owner: Codex 总控
status: active
purpose: Freeze the backend execution prompt for enterprise display chain P1 package D so Server closes the remaining contact persistence gap on the formal basic-save chain.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_c_result_verification_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/enterprise_hub/**
---

# 《enterprise display chain P1 package D backend execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display chain`
- 子阶段：
  - `P1 minimal closure`
- 当前包：
  - `package D / backend`

## 2. 唯一目标

- 你这轮只关闭联系人普通保存链在 Server 这一层的剩余阻断。
- 当前唯一目标固定为：
  - 让 `updateBasic()` 真正接住 `contactName / contactMobile`
  - 并把它们写入当前 contact persistence truth

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_c_result_verification_conclusion_addendum.md`
- `docs/01_contracts/openapi.yaml`

## 4. 只允许修改的范围

- `apps/server/src/modules/enterprise_hub/**`
- 与本轮最小 persistence 闭环直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/mobile/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不新增新的 path family
- 不新增第二条 contact update family
- 不顺手扩到 `wechat / phone / email / position`
- 不新增第二 contact truth
- 不顺手扩到 list / detail / recommendation / submit gating

## 6. 当前已冻结事实

1. `updateBasic` 的正式 contract 已允许：
   - `contactName`
   - `contactMobile`
2. Flutter 当前已发出这两个字段
3. BFF 当前已透传这两个字段
4. 当前剩余阻断只在：
   - Server `updateBasic()` 仍未持久化 contact truth

## 7. 你必须完成

1. 在 `updateBasic()` 中接住：
   - `contactName`
   - `contactMobile`
2. 保持联系人真相仍写入当前 contact persistence owner
3. 不顺手扩写其他联系人字段
4. 保持 workbench readback 与 `readiness.hasContact` 继续只认持久化结果

## 8. 你必须补的测试

至少补齐以下覆盖：

1. `updateBasic()` 收到 `contactName / contactMobile` 后能真实持久化
2. 持久化后 workbench readback 可读回
3. `readiness.hasContact` 与持久化结果一致
4. 不会顺手开始接受 `wechat / phone / email / position`

## 9. 完成标准

- 结果必须能证明：
  1. 联系人普通保存链已真正从 Flutter -> BFF -> Server 打通
  2. 持久化与 readback 一致
  3. `hasContact` 与持久化 truth 一致
- 如果只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 `package D / backend` 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_chain_p1_package_d_backend_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 每个修改点对应的冻结事实编号
  3. `contactName / contactMobile` persistence 说明
  4. readback / readiness 一致性说明
  5. 新增或更新的测试清单
  6. build / test 结果
  7. 当前剩余未闭合项
  8. 是否已达到联系人普通保存链 closure

## 11. 输出禁令

- 不要写“应该可以”
- 不要再把问题甩回 Flutter 或 BFF
- 不要顺手扩字段
- 不要给 contact truth 新开第二 owner
- 只给真实持久化、真实测试、真实剩余风险
