---
owner: Codex 总控
status: draft
purpose: 为《账户与企业认证规则 V1》第一包下发 L2 contracts freeze 收口轮的唯一派工口令，限定为 docs-only，不解锁实现。
layer: L0 SSOT
---

# 《账户与企业认证规则 V1》第一包 L2 Contracts Freeze 收口派工单

## A. 当前团队名册
1. 总控
2. 前端 Agent（仅本地）
3. 后端 Agent（仅云端）
4. BFF Agent（仅云端）
5. 结果校验 Agent
6. 联调发布 Agent

## B. 当前轮次唯一目标
- 当前轮次目标仅为：
  - `账户与企业认证规则 V1`
  - 第一包
  - `L2 contracts freeze` 收口冻结
- 本轮不是：
  - backend 实现轮
  - BFF 实现轮
  - frontend 实现轮
  - admin 实现轮
  - release-prep
  - release execution

## C. 当前阶段裁决
- 当前裁决保持：
  - `Go for docs-only L2 contracts freeze`
  - `No-Go for implementation / release`
- 任何实现类动作均不在本轮许可范围内。

## D. 本轮派工归属
- 本轮任务归属：
  - `总控内部动作`
- 原因：
  - `docs/01_contracts/**` 属于正式契约真源层
  - 该层按照顶层门禁和真源规则，由总控主导冻结
  - 当前六角色编制内，不存在独立“文书冻结 Agent”

## E. 本轮必须收口的对象
- 以下对象必须一起收口，不得只冻结 addendum 而跳过 formal contract：
  1. `docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md`
  2. `docs/01_contracts/openapi.yaml`
  3. `docs/01_contracts/error_codes.yaml`
  4. `packages/contracts/**` 对应 generated outputs（如本轮 contract 变更触发生成）

## F. 本轮收口要求

### 1. addendum 收口
- 必须明确：
  - path family
  - object family
  - state responsibility
  - app-facing 与 admin-facing 边界
  - explicit non-goals
  - no implementation unlock

### 2. openapi 收口
- 必须核对并落齐：
  - `/api/app/auth/*`
  - `/api/app/shell/context`
  - `/api/app/profile/organization/*`
  - `/api/app/profile/certification/*`
  - `/api/app/profile/security/devices*`
  - `/server/admin/reviews/organizations*`
  - `/server/admin/security-events`
- 不得出现：
  - 裸 `/auth/*`
  - 裸 `/orgs/*`
  - 裸 `/me/*`
  - 非当前 constitution 的第二套路由族

### 3. error_codes 收口
- 必须核对并收口第一包最小错误码族：
  - `AUTH`
  - `ORG`
  - `CERTIFICATION`
  - `SECURITY`
  - `REVIEW`
- 必须确认：
  - 语义与 addendum 一致
  - owner 不漂移
  - 不把 BFF 错写成 truth owner

### 4. generated contracts
- 若 `openapi.yaml` 或 `error_codes.yaml` 发生有效改动：
  - 必须重新生成 contracts projection
- 若未发生有效变更：
  - 必须在回执中明确说明“本轮无需生成”的依据

## G. 交付物
- 本轮交付物固定为：
  1. `L2 contracts freeze 收口回执`
  2. 变更后的 contracts 真源文件列表
  3. 是否触发 generated contracts 的说明
  4. 与 `L0` 冻结稿一致性核对结论

## H. 验收标准
- 通过标准：
  - 第一包 addendum、openapi、error_codes 三者语义一致
  - path family 无漂移
  - error family 无漂移
  - 没有越权放开实现
  - 明确保留 `No-Go for implementation / release`
- 阻断标准：
  - 只改 addendum 不改 formal contract
  - openapi 与 addendum 冲突
  - error_codes 与 addendum 冲突
  - 借收口轮夹带实现意图

## I. 结果校验 Agent 下一轮职责
- 在本轮 docs-only 收口完成后，结果校验 Agent 只复核：
  - addendum / openapi / error_codes / generated projection 是否一致
- 不复核实现，因为本轮没有实现许可。

## J. 总控本轮自限
- 本轮总控只允许：
  - 真源收口
  - 契约冻结
  - 一致性核对
  - 派工与裁决
- 本轮总控不允许：
  - 替后端写实现
  - 替 BFF 写实现
  - 替前端写实现
  - 发起联调发布

## K. 下一步唯一动作
- 下一步唯一动作：
  - 由总控执行第一包 `L2 contracts freeze` 收口
  - 收口完成后，将结果移交结果校验 Agent 做独立复核
