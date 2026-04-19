---
owner: 总控文书冻结
status: frozen
purpose: Freeze the single bundled spec for the S1-R01 workspace attribution cleanup strategy, so the dirty working tree may be attribution-layered non-destructively before any later stage decision is reconsidered.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_execution_receipt_addendum.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_r01_limited_diff_baseline_check_spec_bundle_addendum.md
  - docs/00_ssot/s1_r01_limited_diff_baseline_check_result_verification_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R01 workspace attribution cleanup strategy spec bundle》

## 1. 目标

- 本轮动作目标固定为：
  - 关闭“工作区归因边界不清”风险
  - 在不破坏现有工作区的前提下，把当前 dirty tree 明确分层
  - 为总控后续判断 `S1-R02` 是否可进入提供单一证据基础
- 本轮动作必须被理解为：
  - 非破坏性归因清洗策略
- 本轮动作不得被理解为：
  - 代码清理
  - git 清仓
  - implementation
  - `S1-R02` 放行
- 本轮动作不得触发：
  - 任何 implementation
  - 任何 `apps/**` 代码修改

## 2. 清洗对象范围

- 本轮清洗对象范围固定覆盖：
  - 当前整个 working tree
- 至少必须覆盖：
  - `apps/**`
  - `docs/**`
  - `S1-R01 allowed scope` 两文件
  - 其余 tracked 修改
  - 其余 untracked 文件
- 当前必须明确：
  - 本轮不是只看 `S1-R01` 两文件
  - 本轮也必须把 working tree 中其余并发改动一并归位

## 3. 归因分层规则

- 本轮归因结果必须强制拆成以下四栏：

### A. `S1-R01 allowed scope`

- 只允许放入：
  - `apps/server/src/modules/auth/auth-anti-abuse.service.ts`
  - `apps/server/test/auth-public-login-opening.test.cjs`
- 本栏唯一含义：
  - 当前最接近 `S1-R01 execution` 的允许范围

### B. `已冻结但非 S1-R01 当前 execution 的文书/历史轨迹`

- 只允许放入：
  - 已冻结的 `docs/**` 文书
  - 已冻结但不属于 `S1-R01 current execution` 的历史口径链
  - 已存在但当前只具备历史轨迹意义的真源增补件
- 本栏唯一含义：
  - 可识别来源，但不应被当作 `S1-R01 execution` 本体

### C. `并行历史改动或其他阶段候选改动`

- 只允许放入：
  - 与 `S1-R02+`、`阶段2`、其他 package、其他对象相关的 tracked / untracked 并发改动
  - 当前已能看出阶段归属或主题归属，但不属于 `S1-R01` 的项
- 本栏唯一含义：
  - 不是噪音黑箱，但也不是 `S1-R01`

### D. `当前无法归因、必须继续阻断的残留项`

- 只允许放入：
  - 当前无法稳定归入 `A/B/C` 的 tracked / untracked 项
  - 当前会持续污染平台级归因边界的残留项
- 本栏唯一含义：
  - 只要此栏仍大量存在，就继续阻断 strict isolated pass 口径

## 4. 允许使用的证据命令

- 本轮只允许使用非破坏性证据命令。
- 明确允许：
  - `git status --short`
  - `git diff --name-only HEAD -- ...`
  - `git diff --stat HEAD -- ...`
  - `git ls-files --others --exclude-standard`
  - 按目录聚合统计命令
  - `git show --name-only --oneline <base>`
  - `git rev-parse --verify <base>`
  - `git diff --name-only <base> -- ...`
  - `git diff --stat <base> -- ...`
- 明确禁止任何会改动 working tree 状态的命令，包括但不限于：
  - `git reset --hard`
  - `git checkout --`
  - `git clean -fd`
  - 任何覆盖用户现有改动的 destructive 操作

## 5. 证据组织格式

- result receipt 至少必须给出以下证据块：

### 5.1 working tree 总览

```bash
git status --short
git ls-files --others --exclude-standard
```

- 必须回答：
  - 当前 tracked 修改总览
  - 当前 untracked 总览

### 5.2 `S1-R01 allowed scope` 证据

```bash
git diff --name-only HEAD -- \
  apps/server/src/modules/auth/auth-anti-abuse.service.ts \
  apps/server/test/auth-public-login-opening.test.cjs

git diff --stat HEAD -- \
  apps/server/src/modules/auth/auth-anti-abuse.service.ts \
  apps/server/test/auth-public-login-opening.test.cjs
```

- 必须回答：
  - `A` 栏当前有哪些项
  - 两文件是 tracked、untracked，还是混合状态

### 5.3 按目录聚合证据

```bash
git status --short | awk '{print $2}' | cut -d/ -f1-2 | sort | uniq -c
git status --short | awk '{print $2}' | cut -d/ -f1 | sort | uniq -c
```

- 必须回答：
  - `apps/**` 与 `docs/**` 当前大致噪音分布
  - 哪些目录明显属于 `B`
  - 哪些目录明显属于 `C`
  - 哪些目录只能留在 `D`

### 5.4 compare base 辅助证据

```bash
git rev-parse --verify <base>
git show --name-only --oneline <base>
```

- 必须回答：
  - 当前引用的 base 是否真实可解析
  - 该 base 仅用于辅助归因，不得偷换成“工作区已被清理”

## 6. 结果判定标准

### 6.1 `ATTRIBUTION CLEAN PASS`

- 只有当以下条件同时满足，才允许写成：
  - `ATTRIBUTION CLEAN PASS`
  - 当前 dirty tree 可以被稳定分层到 `A/B/C/D`
  - `S1-R01` 与其他并发改动的边界可被清楚描述
  - `D` 栏只剩极少量、且不再阻断平台级归因判断
- 上述结论只表示：
  - 当前 working tree attribution 已足以支持总控继续做单独 stage decision

### 6.2 `ATTRIBUTION CLEAN PASS WITH RISK`

- 满足以下任一情况时，必须写成：
  - `ATTRIBUTION CLEAN PASS WITH RISK`
  - 当前 dirty tree 基本可分层，但 `D` 栏仍有少量不可完全关闭的残留项
  - `S1-R01` 边界基本清楚，但仍有少量描述性、不完全隔离的归因风险
- 上述结论只表示：
  - attribution 风险被显著缩小，但未完全关闭

### 6.3 `ATTRIBUTION CLEAN FAIL`

- 满足以下任一情况时，必须写成：
  - `ATTRIBUTION CLEAN FAIL`
  - 当前 dirty tree 无法稳定分层
  - `S1-R01` 与其他并发改动边界仍无法清楚描述
  - `D` 栏仍大量存在，且继续阻断平台级归因判断
- 上述结论只表示：
  - 当前 working tree attribution cleanup strategy 未能关闭阻断性归因风险

## 7. 对 S1-R02 的门禁影响

- 本文书必须写死：
  - 即使 `ATTRIBUTION CLEAN PASS`，也不自动打开 `S1-R02`
  - 只能回到总控做单独 stage decision
  - 若结果为 `ATTRIBUTION CLEAN PASS WITH RISK` 或 `ATTRIBUTION CLEAN FAIL`，`S1-R02` 持续 `No-Go`

## 8. 唯一 receipt 路径

- 本轮唯一正式 receipt 路径必须写死为：
  - [s1_r01_workspace_attribution_cleanup_strategy_result_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r01_workspace_attribution_cleanup_strategy_result_receipt_addendum.md)
- 不允许拆出：
  - judgment
  - checklist
  - dispatch
  - execution receipt
  的其他文书

## 9. 下一步唯一动作

- 当前下一步唯一动作必须写成：
  - 由总控决定是否向 `结果校验 Agent` 发出 `S1-R01 workspace attribution cleanup execution` 口令；
  - 在 receipt 返回前，`S1-R02` 持续 `No-Go`。

## 10. Formal Conclusion

- `S1-R01 workspace attribution cleanup strategy` 的 bundled spec 已一次性冻结完成。
- 当前正式口径已写死为：
  - 本动作是非破坏性归因清洗策略，不是代码清理，不是 git 清仓
  - 本动作不得触发任何 implementation
  - 本动作不得放行 `S1-R02`
  - 本动作不得修改 `apps/**` 代码
  - 本动作不得要求任何 destructive git 操作
