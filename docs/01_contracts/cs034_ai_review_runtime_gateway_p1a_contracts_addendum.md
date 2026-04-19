---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded normalized gateway contract family for CS-034 AI review runtime gateway without opening any app-facing AI route or implementation unlock.
layer: L2 Contracts
---

# CS-034 AI 审核服务统一接入层 P1-A Contracts Addendum

## 1. 范围

本文件只冻结 `CS-034` 当前最小 normalized gateway contract family。

本包不冻结新的 app-facing 或 BFF-facing HTTP route。

## 2. 当前包角色

- `Server` 是唯一 AI gateway truth owner
- `BFF` 不得消费 raw gateway result
- `Flutter` 不得消费 raw gateway result

## 3. 当前最小 request envelope

当前 normalized gateway request 只允许包含：

- `engineType`
- `providerKey`
- `reviewObjectType`
- `objectId`
- `policyProfile`
- `reviewPayload`
- `traceId`

## 4. 当前最小 response envelope

当前 normalized gateway response 只允许包含：

- `decision`
- `riskScore`
- `riskLabels`
- `providerResponseRef`
- `traceId`

## 5. 当前 contract 边界

- 当前 contract 只服务 `Server` 内部 AI gateway normalization
- 当前 contract 不得变成 public app API
- 当前 contract 不得要求 `BFF` 或 Flutter 直连 provider
- 当前 contract 不得暴露 raw secret / raw prompt / raw provider response

## 6. 当前明确不纳入项

- implementation unlock contract
- app-facing AI route contract
- penalty / appeal full desk contract
- 自动处罚 contract
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`
- release-prep / launch approval

## 7. Formal Conclusion

当前 `CS-034 P1-A` contract 已冻结。

该冻结只允许后续进入 bounded implementation-unlock judgment authoring，不等于 AI runtime 已放开。
