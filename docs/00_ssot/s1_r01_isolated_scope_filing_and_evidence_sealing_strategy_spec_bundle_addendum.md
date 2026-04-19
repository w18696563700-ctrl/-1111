---
owner: 总控文书冻结
status: frozen
purpose: Freeze the single bundled spec for the S1-R01 isolated scope filing and evidence sealing strategy, so A-scope evidence may be sealed into a reproducible isolated chain without changing code, cleaning git state, or opening S1-R02.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_execution_receipt_addendum.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_r01_limited_diff_baseline_check_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_r01_workspace_attribution_cleanup_result_verification_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R01 isolated scope filing and evidence sealing strategy spec bundle》

## 1. 目标

- 本轮动作目标固定为：
  - 为 `S1-R01` 的 `A scope` 形成单独、可封存、可复演的 isolated evidence chain
  - 缩小“快照污染”对 `S1-R01` 归因的解释空间
  - 为总控后续判断 `S1-R02` 是否可进入提供更强证据
- 本轮动作必须被理解为：
  - 证据封存策略
- 本轮动作不得被理解为：
  - 代码修改
  - git 清理
  - 提交动作
  - implementation
  - `S1-R02` 放行
- 本轮动作不得触发：
  - 任何 implementation
  - 任何 `apps/**` 代码修改
  - 任何直接 `commit / push / reset / clean`

## 2. 封存对象范围

- 本轮封存对象范围只允许围绕 `A scope` 两文件与必要证据展开：
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-anti-abuse.service.ts`
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/auth-public-login-opening.test.cjs`
- 以及与上述两文件直接相关的非破坏性证据输出。
- 本轮不得扩展到：
  - `A scope` 外业务代码
  - 全仓清理动作
  - 其他阶段对象
  - 任何超出证据封存所需的变更动作

## 3. evidence chain 组成

- 本轮 isolated evidence chain 至少必须包含以下组成部分：

### 3.1 compare base 识别证据

- 必须说明：
  - 当前引用的 compare base 是什么
  - 该 base 是否真实可解析
  - 该 base 只是证据链起点，不得被偷换成 execution 前已打标签的强结论

### 3.2 A scope 文件状态证据

- 必须说明：
  - 两文件当前分别是 tracked、modified，还是 untracked
  - 当前 file state 是否与前序 limited diff / attribution cleanup 结论一致

### 3.3 A scope diff 证据

- 必须说明：
  - 相对于 compare base，`A scope` 当前可见 diff 范围
  - 哪些变化落在 service 文件
  - 哪些变化落在 test 文件
  - 是否存在 name-status、stat、full diff 三层一致性

### 3.4 A scope 文件内容快照证据

- 必须说明：
  - 两文件的关键内容快照引用
  - 快照引用应可复演定位到稳定行号或稳定片段
  - 快照引用只服务于证据封存，不得被误写成新的 implementation 说明

### 3.5 A scope 测试执行证据

- 必须说明：
  - `auth-public-login-opening.test.cjs` 的执行结果
  - 测试是否在当前 `A scope` 快照下可复演通过

### 3.6 A scope smoke 证据

- 必须说明：
  - 最小 smoke 命令
  - 最小 smoke 输出
  - smoke 是否支持 `public login opening` 当前主张

### 3.7 A scope 与外部噪音隔离说明

- 必须说明：
  - 当前 receipt 只封存 `A scope`
  - `A scope` 之外的噪音为何不被纳入本轮证据链主体
  - 该隔离说明如何支撑“更强证据”，但仍不等于自动放行 `S1-R02`

## 4. 允许使用的证据命令

- 本轮只允许使用非破坏性证据命令。
- 明确允许：
  - `git rev-parse --verify HEAD`
  - `git show --no-patch --oneline HEAD`
  - `git rev-parse --verify <base>`
  - `git show --name-only --oneline <base>`
  - `git diff --name-status HEAD -- <A_files>`
  - `git diff --stat HEAD -- <A_files>`
  - `git diff HEAD -- <A_files>`
  - `git ls-files --others --exclude-standard -- <A_file>`
  - `git status --short -- <A_files>`
  - `nl -ba <file>`
  - `sed -n`
  - `shasum -a 256 <file>`
  - `corepack pnpm build`
  - `node --test test/auth-public-login-opening.test.cjs`
  - 最小 smoke 命令
- 明确禁止任何会改动 working tree 状态的命令，包括但不限于：
  - `git reset --hard`
  - `git checkout --`
  - `git clean -fd`
  - `git commit`
  - `git push`
  - 任何覆盖用户现有改动的 destructive 操作

## 5. 封存输出格式

- 本轮 execution receipt 至少必须包含以下证据块：

### 5.1 compare base

- 必须给出：
  - 当前 compare base 标识
  - `HEAD` 标识
  - compare base 可解析性说明

### 5.2 A scope file state

- 必须给出：
  - 两文件当前 `git status` 结果
  - 若 test 文件仍为 untracked，必须显式写明

### 5.3 A scope diff summary

- 必须给出：
  - `name-status`
  - `stat`
  - 必要时的受限 full diff 结论摘要

### 5.4 A scope content snapshot references

- 必须给出：
  - service 文件关键行引用
  - test 文件关键行引用
  - 两文件 sha256

### 5.5 build / test / smoke result

- 必须给出：
  - `corepack pnpm build` 结果
  - `node --test test/auth-public-login-opening.test.cjs` 结果
  - 最小 smoke 结果

### 5.6 sha256 evidence

- 必须给出：
  - 两文件的 `sha256`
  - 该 hash 只表示当前封存快照，不代表仓库 clean

### 5.7 isolation note

- 必须给出：
  - `A scope` 与外部噪音的隔离说明
  - 当前证据链为何只封存 `A scope`
  - 当前证据链仍然不能直接升级为 stage pass 的边界说明

### 5.8 verdict

- 必须给出：
  - `ISOLATED EVIDENCE PASS`
  - 或 `ISOLATED EVIDENCE PASS WITH RISK`
  - 或 `ISOLATED EVIDENCE FAIL`

## 6. verdict rule

### 6.1 `ISOLATED EVIDENCE PASS`

- 只有当以下条件同时满足，才允许写成：
  - `ISOLATED EVIDENCE PASS`
  - `A scope` 的文件状态、diff、内容快照、测试、smoke、sha256 证据能稳定闭合
  - `A scope` 与外部噪音的隔离说明充分且可复演
  - 当前证据链足以把 `A scope` 固定成单独、可封存的证据包
- 上述结论只表示：
  - 当前 isolated evidence sealing 已达到强证据水平
- 即使如此：
  - 也不自动打开 `S1-R02`
  - 只能回到总控做单独 stage decision

### 6.2 `ISOLATED EVIDENCE PASS WITH RISK`

- 满足以下任一情况时，必须写成：
  - `ISOLATED EVIDENCE PASS WITH RISK`
  - 关键证据基本闭合，但 compare base 仍不够强
  - `A scope` 证据已可封存，但 test 文件的 untracked 属性仍保留解释风险
  - 隔离说明基本充分，但仍残留少量平台级解释空间
- 上述结论只表示：
  - 当前 isolated evidence chain 已显著增强，但未完全关闭解释风险

### 6.3 `ISOLATED EVIDENCE FAIL`

- 满足以下任一情况时，必须写成：
  - `ISOLATED EVIDENCE FAIL`
  - 关键证据缺失
  - 内容快照不稳定
  - 无法说明 `A scope` 与外部噪音边界
  - 测试或 smoke 无法在当前 `A scope` 快照下提供稳定支持
- 上述结论只表示：
  - 当前 isolated scope filing and evidence sealing 未形成可用强证据链

## 7. 对 S1-R02 的门禁影响

- 本文书必须写死：
  - 即使 `ISOLATED EVIDENCE PASS`，也不自动打开 `S1-R02`
  - 只能回到总控做单独 stage decision
  - 若结果为 `ISOLATED EVIDENCE PASS WITH RISK` 或 `ISOLATED EVIDENCE FAIL`，`S1-R02` 持续 `No-Go`

## 8. 唯一 receipt 路径

- 本轮唯一正式 receipt 路径必须写死为：
  - [s1_r01_isolated_scope_filing_and_evidence_sealing_strategy_result_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r01_isolated_scope_filing_and_evidence_sealing_strategy_result_receipt_addendum.md)
- 不允许拆出：
  - judgment
  - checklist
  - dispatch
  - execution receipt
  的其他文书

## 9. 下一步唯一动作

- 当前下一步唯一动作必须写成：
  - 由总控决定是否向 `结果校验 Agent` 发出 `S1-R01 isolated scope filing and evidence sealing execution` 口令；
  - 在 receipt 返回前，`S1-R02` 持续 `No-Go`。

## 10. Formal Conclusion

- `S1-R01 isolated scope filing and evidence sealing strategy` 的 bundled spec 已一次性冻结完成。
- 当前正式口径已写死为：
  - 本动作是证据封存策略，不是代码修改，不是 git 清理，不是提交动作
  - 本动作不得触发任何 implementation
  - 本动作不得放行 `S1-R02`
  - 本动作不得修改 `apps/**` 代码
  - 本动作不得要求任何 destructive git 操作
  - 本动作不得要求直接 `commit / push / reset / clean`
