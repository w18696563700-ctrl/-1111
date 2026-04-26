---
owner: Codex 总控
status: active
purpose: Freeze the project-create eligibility correction for dual-capability organizations.
layer: L0 SSOT
created_at: 2026-04-27
---

# 《both 主体创建项目资格修正规则》

## 1. 当前最小闭环

- 创建项目资格仍由 `Server` 的 `CurrentActorEligibilityService` 统一判断。
- 企业认证 `approved` 仍是创建项目硬门槛。
- `organizationType=demand/buyer` 继续要求当前成员角色属于买方侧发布角色：
  - `buyer_admin`
  - `buyer_member(scoped)`
- `organizationType=both` 表示当前主体同时具备发布方与承接方能力：
  - 已认证 `both` 主体可创建项目；
  - 不再因为当前 app-facing 成员角色显示为 `supplier_admin` 或 `supplier_member(scoped)` 被 `buyer_role_not_allowed` 前置硬拦截。
- `organizationType=supplier/platform` 仍不可创建项目。

## 2. 需要保留但暂不开通

- 不开放“任意组织均可发布”。
- 不开放未认证主体创建项目。
- 不开放纯供应商主体创建项目。
- 不把创建页改成交易总控台，不把 P0-Pay 作为创建命令的提交前置。
- 不新增 `prepublish/prepublished` 状态；预发布列表继续复用 `submitted`。

## 3. 后续扩展位

- 后续如需更细的成员级权限，可在 `both` 主体内补充“发布席位 / 承接席位 / 项目范围授权”，但不得回到仅凭当前显示角色误拦截主体能力。
- P0-Pay 继续作为明价 / 询价意向后的资金与服务费扩展位，不并入创建资格真源。

## 4. 风险判断

- 更稳：以 `Server` 的主体类型、企业认证、当前 membership 共同判断，保持单一真源。
- 更省成本：复用现有 `organizationType=both`、`certificationStatus`、`projectCreateEligibility.canCreateProject`，不新增接口和状态。
- 更适合当前阶段：只修正双能力主体被角色文案误挡的问题，保证创建页能保存到草稿 / 预发布链路。
- 风险更大：仅改 Flutter 放行或仅改 BFF 文案会继续被 Server 拦截；把所有 supplier 角色都放开会扩大纯供应商主体发布权限。
