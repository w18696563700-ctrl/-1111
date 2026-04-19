---
owner: 总控文书冻结
status: frozen
purpose: Freeze the single bundled spec for the S1-R01 limited diff baseline check, so the current snapshot-pollution risk may be evaluated without changing the stage route, opening S1-R02, or authoring any implementation prompt.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_execution_receipt_addendum.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_result_verification_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R01 受限 diff 基线核对 spec bundle》

## 1. 核对对象

- 本轮核对对象只限：
  - `S1-R01`
  - `P0-1a public login opening backend repair`
  - limited diff baseline check
- 本轮目的必须固定写成：
  - 关闭“快照污染导致的可追责边界不清”
- 本轮不做：
  - 路线图改写
  - `S1-R02` 放行
  - implementation prompt
  - execution receipt
  - 任何 `apps/**` 代码改动

## 2. compare base 的选取原则

- compare base 必须满足以下条件：
  1. 必须是当前本地仓库内可被 `git rev-parse --verify` 解析的真实 git 基线。
  2. 必须早于 `S1-R01` backend execution 的 reported changed files 成形时点。
  3. 必须是当前最接近 `S1-R01` execution 之前、且可重复引用的单一 commit-ish。
  4. 不允许使用：
     - working tree 当前快照
     - 临时 patch 文件
     - 云端镜像描述
     - 人工口述时点
  5. 若无法唯一定位“精确执行前基线”，只能退而选择：
     - 最近可验证的前序基线
     - 并在 result receipt 中显式写明该风险
- compare base 的正式目标不是：
  - 证明仓库全局干净
  - 重建完整历史
  - 推翻 execution receipt
- compare base 的正式目标只限：
  - 在可重复 git 基线上，受限核对 `S1-R01` 的目标 diff 是否仍可被压缩到允许范围内

## 3. 允许纳入 diff 的文件范围

- 本轮 allowed diff scope 固定只允许包括以下文件：
  - [auth-anti-abuse.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-anti-abuse.service.ts)
  - [auth-public-login-opening.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/auth-public-login-opening.test.cjs)
- allowed diff scope 的唯一允许含义：
  - 核对 `S1-R01 execution receipt` 报告的两文件边界是否仍可被受限定位
- 本轮不得把以下对象纳入 `S1-R01` 允许 diff：
  - `apps/bff/**`
  - `apps/mobile/**`
  - `apps/admin/**`
  - `packages/**`
  - `docs/**`
  - `apps/server/src/modules/profile/**`
  - `apps/server/src/modules/organization/**`
  - `apps/server/src/modules/review/**`
  - `apps/server/src/modules/project/**`
  - 任何 `S1-R02+` 或 `阶段2` 对象

## 4. 必须排除的非 S1-R01 噪音范围

- 以下对象必须被视为 non-S1-R01 noise scope，并在 receipt 中单独列出、单独排除：
  - 当前 working tree 中所有不属于上文两文件的已修改条目
  - 当前 working tree 中所有不属于上文两文件的未跟踪条目
  - 所有与 forum / governance / profile / admin / frontend / BFF / contracts / docs 相关的并行改动
  - 所有与 `S1-R02`、`S1-R03`、`S1-R04`、`S1-R05`、`S1-R06`、`S1-C01`、`S1-C02`、`S1-C03` 有关的条目
- 当前必须明确：
  - non-S1-R01 noise 的存在本身不是本轮核对对象
  - 但 non-S1-R01 noise 会影响“本轮仅改两文件”的严格归因能力
- 当前不得把 noise scope 写成：
  - 已被清理
  - 已被认可为 `S1-R01` 一部分
  - 可以忽略不记

## 5. 核对命令与证据格式

- result receipt 至少必须包含以下命令与原始结果摘要：

### 5.1 compare base 确认

```bash
git rev-parse --verify <compare-base>
git show --no-patch --oneline <compare-base>
```

- 证据格式必须包含：
  - `compare-base` 原值
  - 解析后的 commit SHA
  - 一行 commit 摘要

### 5.2 受限 diff 核对

```bash
git diff --name-status <compare-base> -- \
  apps/server/src/modules/auth/auth-anti-abuse.service.ts \
  apps/server/test/auth-public-login-opening.test.cjs

git diff --stat <compare-base> -- \
  apps/server/src/modules/auth/auth-anti-abuse.service.ts \
  apps/server/test/auth-public-login-opening.test.cjs
```

- 证据格式必须包含：
  - name-status 结果
  - diff stat 结果
  - 是否只落在两文件内

### 5.3 受限外噪音清点

```bash
git diff --name-only <compare-base> -- . \
  ':(exclude)apps/server/src/modules/auth/auth-anti-abuse.service.ts' \
  ':(exclude)apps/server/test/auth-public-login-opening.test.cjs'

git ls-files --others --exclude-standard
git status --short
```

- 证据格式必须包含：
  - compare-base 到当前状态的 outside-allowed-scope 文件清单
  - 当前 untracked 文件清单摘要
  - 当前 `git status --short` 摘要

### 5.4 结论段最小格式

- result receipt 结论段必须固定回答：
  - compare base 是否唯一且可复验
  - allowed diff 是否仍可受限到两文件
  - outside-allowed-scope 噪音是否仍大规模存在
  - 本轮是否足以关闭“本轮仅改两文件”的归因风险

## 6. 结果判定标准

### 6.1 PASS

- 只有同时满足以下条件，才允许写成 `PASS`：
  - compare base 唯一、稳定、可重复解析
  - 受限 diff 仅落在两文件内
  - compare-base 到当前状态的 outside-allowed-scope 噪音可以被清楚分层，不再阻断“本轮仅改两文件”的严格归因
  - result receipt 能给出明确、可复核的排除链，而不是口头判断
- `PASS` 的唯一允许含义只限：
  - 当前“快照污染导致的可追责边界不清”风险已被关闭
- `PASS` 不表示：
  - `S1-R02` 自动打开
  - `阶段2` 打开
  - `release-prep / launch` 打开

### 6.2 PASS WITH RISK

- 满足以下任一情况时，必须写成 `PASS WITH RISK`：
  - 受限 diff 基本匹配两文件，但 compare base 不是唯一精确执行前基线
  - 受限 diff 可成立，但 outside-allowed-scope 噪音仍较大，导致严格归因仍有残留不确定性
  - 证据能支持“高概率只落在两文件”，但不能支持“严格、无保留地只落在两文件”
- `PASS WITH RISK` 的唯一允许含义只限：
  - 当前风险被缩小，但未被彻底关闭

### 6.3 FAIL

- 满足以下任一情况时，必须写成 `FAIL`：
  - compare base 无法唯一确定
  - 受限 diff 实际落在两文件之外
  - 证据链缺失，无法复核
  - result receipt 不能把 allowed diff 与 noise scope 分开表达
- `FAIL` 的唯一允许含义只限：
  - 当前快照污染风险未关闭，且 `S1-R01` 的严格可追责边界仍不清

## 7. 通过后是否允许打开 S1-R02

- 本 bundled spec 必须写死：
  - 在基线核对完成前，`S1-R02` 持续 `No-Go`
- 即使基线核对结果为 `PASS`，也只表示：
  - 当前快照污染风险可被重新提交给总控做单独 stage decision
- 基线核对 `PASS` 不自动表示：
  - `S1-R02` 已打开
- 基线核对结果为 `PASS WITH RISK` 或 `FAIL` 时：
  - `S1-R02` 继续 `No-Go`

## 8. 唯一 receipt 路径

- 本轮唯一正式 receipt 路径必须写死为：
  - [s1_r01_limited_diff_baseline_check_result_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r01_limited_diff_baseline_check_result_receipt_addendum.md)
- 不允许拆出：
  - judgment
  - checklist
  - dispatch
  - execution receipt
  的其他文书

## 9. 下一步唯一动作

- 当前下一步唯一动作固定为：
  - 由总控决定是否向 `结果校验 Agent` 发出 `S1-R01 limited diff baseline check` 核对口令，并将结果冻结到唯一 receipt 路径
- 在该 receipt 完成前：
  - `S1-R02` 持续 `No-Go`

## 10. Formal Conclusion

- `S1-R01 limited diff baseline check` 的 bundled spec 已一次性冻结完成。
- 当前正式目标已写死为：
  - 关闭“快照污染导致的可追责边界不清”
- 当前正式约束已写死为：
  - 在基线核对完成前，`S1-R02` 持续 `No-Go`
