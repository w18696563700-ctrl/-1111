---
owner: 总控文书冻结
status: frozen
purpose: Freeze the final bundled spec for S1-R01 evidence chain normalization and filing closure, so the last two residual evidence risks may be tested non-destructively before total control makes a separate controller decision.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_execution_receipt_addendum.md
  - docs/00_ssot/s1_r01_limited_diff_baseline_check_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_r01_workspace_attribution_cleanup_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_r01_isolated_scope_filing_and_evidence_sealing_result_verification_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R01 evidence chain normalization and filing closure strategy spec bundle》

## 1. 目标

- 本轮动作是最后一轮 `evidence normalization / filing closure` 策略。
- 本轮动作目标固定为：
  - 尽可能关闭 `S1-R01` 仅剩的两条证据链残留
  - 判断当前问题到底还能否通过非破坏性证据归一化解决
  - 若不能，则把问题显式定性为 `policy gap`，停止无限文书递进
- 当前剩余风险必须固定为且只剩两条：
  - execution receipt 中的 smoke 命令是省略写法，不能字面可复用
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/auth-public-login-opening.test.cjs` 仍为 untracked
- 本轮动作不得被理解为：
  - 代码修改
  - git 清理
  - `commit / push / reset / clean`
  - implementation
  - `S1-R02` 放行
- 本轮动作不得触发：
  - 任何 implementation
  - 任何 `apps/**` 代码修改
  - 任何直接 `commit / push / reset / clean`
- 如果本轮之后剩余问题仍然只是 `policy gap`，而不是 `evidence gap`，总控不得继续无限追加文书加固，而必须做单独 controller decision。

## 2. closure 对象范围

- 本轮 closure 对象范围只允许围绕以下对象：
  - execution receipt 中的 smoke evidence 归一化
  - `A scope` test 文件的 filing / sealing 归一化
  - 与上述二者直接相关的非破坏性证据
- 当前不得扩展到：
  - 其他模块
  - 其他阶段
  - 其他文件
  - 任何超出上述两条残留项的额外加固对象

## 3. smoke normalization rule

### 3.1 归一化目标

- 本轮必须把以下两种 smoke 口径区分清楚：
  - `字面 smoke`
  - `等价 smoke`

### 3.2 `字面 smoke`

- `字面 smoke` 只在以下条件同时满足时成立：
  - 能从 execution receipt 中还原出完整、可直接复制执行的 smoke 命令
  - 当前实际运行命令与 execution receipt 所记载的 smoke 主张逐字面可复用
  - 输出可稳定复现 receipt 中的同一主张

### 3.3 `等价 smoke`

- `等价 smoke` 只在以下条件同时满足时成立：
  - execution receipt 原始 smoke 仍是省略写法
  - 当前可构造一个非破坏性、最小化、可复跑的 smoke 命令
  - 该命令支持与 execution receipt 相同的核心行为主张
  - 输出在语义上与 receipt 中的 smoke result 等价
- `等价 smoke` 不得被偷换成：
  - `字面 smoke`
  - “原 receipt 已完全规范化”

### 3.4 smoke normalized 判定

- 只有在以下条件同时满足时，才允许写成 `smoke normalized PASS`：
  - `字面 smoke` 已被完整还原或被正式补全为可字面复用命令
  - 当前输出可稳定复演，且不再新增解释空间
- 满足以下任一情况时，必须写成 `smoke normalized PASS WITH RISK`：
  - 只能建立 `等价 smoke`
  - 当前可证明核心行为主张，但 execution receipt 原始写法仍不能追溯成字面可复用命令
  - 当前剩余问题已经更接近口径接受问题，而不是取证缺失问题
- 满足以下任一情况时，必须写成 `smoke normalized FAIL`：
  - 既不能建立 `字面 smoke`，也不能稳定建立 `等价 smoke`
  - 当前输出与 execution receipt 的核心主张不一致
  - 归一化后仍然新增重大解释空间

## 4. untracked test filing rule

### 4.1 filing 证据组成

- 本轮必须使用以下证据共同形成 test filing evidence：
  - file state
  - content snapshot
  - sha256
  - test pass
  - path 固定性

### 4.2 `test filing PASS`

- 只有在以下条件同时满足时，才允许写成 `test filing PASS`：
  - test 文件路径稳定且唯一
  - 文件内容快照稳定
  - sha256 固定且可复核
  - `node --test test/auth-public-login-opening.test.cjs` 稳定通过
  - 当前 file state 已不再构成实质归因歧义

### 4.3 `test filing PASS WITH RISK`

- 满足以下任一情况时，必须写成 `test filing PASS WITH RISK`：
  - 文件路径、内容快照、sha256、test pass 都已稳定
  - 但 test 文件仍为 untracked
  - 当前 filing evidence 已足以证明“这是哪一个文件、其内容是什么、其测试结果如何”
  - 但仍不能把 untracked 状态写成已被彻底消化的零风险事实

### 4.4 `test filing FAIL`

- 满足以下任一情况时，必须写成 `test filing FAIL`：
  - file state 不稳定
  - content snapshot 不稳定
  - sha256 无法稳定复核
  - test pass 不稳定
  - 路径固定性不足

## 5. 总 verdict 规则

### 5.1 `EVIDENCE CHAIN CLOSURE PASS`

- 只有当以下条件同时满足，才允许写成：
  - `EVIDENCE CHAIN CLOSURE PASS`
  - smoke normalization 与 untracked test filing 两条都达到可接受闭环
  - 当前不会再新增实质解释空间
  - 当前剩余问题不再构成 evidence gap
- 即使如此：
  - 也不自动打开 `S1-R02`
  - 只能回到总控做单独 stage decision

### 5.2 `EVIDENCE CHAIN CLOSURE PASS WITH POLICY GAP`

- 满足以下任一情况时，必须写成：
  - `EVIDENCE CHAIN CLOSURE PASS WITH POLICY GAP`
  - 当前证据已基本闭合
  - 剩余问题本质上是 `policy acceptance`，而不是继续取证能解决的问题
  - 继续追加文书不会实质缩小解释空间，只会重复文书加固
- 若结果为 `PASS WITH POLICY GAP`，总控下一步必须在以下两项之间二选一：
  - 接受带记录例外放行
  - 要求真实 git-state / receipt 归一化后再验
- 在此口径下：
  - 总控不得继续无休止加文书

### 5.3 `EVIDENCE CHAIN CLOSURE FAIL`

- 满足以下任一情况时，必须写成：
  - `EVIDENCE CHAIN CLOSURE FAIL`
  - smoke normalization 未形成可接受闭环
  - untracked test filing 未形成可接受闭环
  - 关键证据仍不足以支持总控进行下一层判断

## 6. 对 S1-R02 的门禁影响

- 本文书必须写死：
  - 即使 `EVIDENCE CHAIN CLOSURE PASS`，也不自动打开 `S1-R02`
  - 只能回到总控做单独 stage decision
  - 若为 `PASS WITH POLICY GAP` 或 `FAIL`，`S1-R02` 持续 `No-Go`
  - 若结果为 `PASS WITH POLICY GAP`，总控下一步必须在“接受带记录例外放行”与“要求真实 git-state/receipt 归一化后再验”之间二选一，不得继续无休止加文书

## 7. 允许使用的证据命令

- 本轮只允许使用非破坏性证据命令。
- 明确允许：
  - `git status --short -- <A_files>`
  - `git ls-files --others --exclude-standard -- <A_file>`
  - `git diff --name-status HEAD -- <A_files>`
  - `git diff --stat HEAD -- <A_files>`
  - `nl -ba <file>`
  - `sed -n`
  - `shasum -a 256 <file>`
  - `corepack pnpm build`
  - `node --test test/auth-public-login-opening.test.cjs`
  - 最小 smoke 命令
  - 等价 smoke 命令
- 明确禁止任何会改动 working tree 状态的命令，包括但不限于：
  - `git reset --hard`
  - `git checkout --`
  - `git clean -fd`
  - `git commit`
  - `git push`
  - 任何覆盖用户现有改动的 destructive 操作

## 8. 唯一 receipt 路径

- 本轮唯一正式 receipt 路径必须写死为：
  - [s1_r01_evidence_chain_normalization_and_filing_closure_strategy_result_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r01_evidence_chain_normalization_and_filing_closure_strategy_result_receipt_addendum.md)
- 不允许拆出：
  - judgment
  - checklist
  - dispatch
  - execution receipt
  的其他文书

## 9. 下一步唯一动作

- 当前下一步唯一动作必须写成：
  - 由总控决定是否向 `结果校验 Agent` 发出 `S1-R01 evidence chain normalization and filing closure execution` 口令；
  - 在 receipt 返回前，`S1-R02` 持续 `No-Go`。

## 10. Formal Conclusion

- `S1-R01 evidence chain normalization and filing closure strategy` 的 bundled spec 已一次性冻结完成。
- 当前正式口径已写死为：
  - 本动作是最后一轮 evidence normalization / filing closure 策略
  - 本动作不是代码修改
  - 本动作不是 git 清理
  - 本动作不是 `commit / push / reset / clean`
  - 本动作不得触发任何 implementation
  - 本动作不得直接放行 `S1-R02`
  - 若本轮之后剩余问题仍然只是 `policy gap`，总控不得继续无限追加文书加固，而必须做单独 controller decision
