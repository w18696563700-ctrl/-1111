---
owner: Codex 总控
status: frozen
purpose: Freeze docs/03_bff 四包聚合边界，明确可聚合语义与严禁成为业务真相的范围，供 implementation 前统一复核。
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 docs/03_bff 四包聚合冻结清单

## 适用范围
- 当前对象：`docs/03_bff` 下四包 BFF Surface 级聚合冻结
- 结论定位：只冻结聚合边界，不解锁实现；属于阶段性上游真源文档。

## 四包定义与边界

- 当前状态：
  - `P1 账户与企业认证规则`：`已形成 package-level checkpoint`
  - `P2 假项目举报与裁决`：`已形成 package-level checkpoint`
  - `P3 合同归档与履约链`：`已形成 package-level checkpoint`
  - `P4 黑白名单与永久封禁`：`已形成 package-level checkpoint`

### P1 账户与企业认证
- 文件：`docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`
- scope：
  - `/api/app/auth/profile/overview`
  - `/api/app/profile/certification`
  - `/api/app/profile/organization`
  - `/api/app/profile/organization/members`
  - `/api/app/profile/organization/roles`
  - `/api/app/profile/organization/permissions`
  - shell/profile/exhibition 三大消费上下文的认证承接形态
- 相互边界：
  - 与 `fake_project` 包共享 `organizationId / actor / roleKeys / certificationStatus / shell context`，不共享业务逻辑。
  - 与 `contract` 包共享受限态 copy 样式，不共享合同状态真相。
- 仅聚合语义：
  - trace/requestId
  - actor 与 organization 归一化
  - 有/无权限文案映射
  - 空态/受限态 copy 的最小 shaping
- 严禁成为业务真相 owner：
  - `organization.*` 原始字段
  - `roleKeys` 源变更与决策
  - `certificationStatus` 真值
  - 认证审核结果持久化与生命周期

### P2 假项目举报与裁决
- 文件：`docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md`
- scope：
  - `/api/app/project/reports`
  - `/api/app/exhibition/reports`
  - 举报提交与受限态回显
  - shell 上的举报联动提示
- 相互边界：
  - 与 `contract` 包共享 `project` 识别键，不共享 `report` 审核生命周期。
  - 与 `blacklist` 包共享 `governance` 风险态提示字段，不共享 `penalty / appeal / ban` 真相。
- 仅聚合语义：
  - 举报提交 envelope 的统一包装
  - 仅 read-model 级别的展示片段（列表摘要/受限文案）
  - 请求透传的错误码归一（仅 BFF 负责外显）
- 严禁成为业务真相 owner：
  - 举报提交源（原始内容、证据）
  - 举报受理/裁决状态机
  - 风险等级与处罚落地

### P3 合同归档与履约链
- 文件：`docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md`
- scope：
  - `/api/app/project/contracts`
  - `/api/app/project/fulfillment`
  - `/api/app/project/daily`
  - `/api/app/project/acceptance`
  - `/api/app/project/dispute`
- 相互边界：
  - 与 `account` 包共享登录/组织上下文，避免重复鉴权逻辑。
  - 与 `blacklist` 包共享受限态 copy，不共享 `contract` 审批真相。
- 仅聚合语义：
  - contract/fulfillment/inspection/dispute 的列表入口与状态标签化显示
  - server-admin 结果的 error/blocked copy 映射
  - 只承载不可执行的前端可读投影
- 严禁成为业务真相 owner：
  - 合同版本、履约日志、验收结论
  - 计时与变更周期真值
  - 争议处理与处罚联动引擎

### P4 黑白名单与永久封禁
- 文件：`docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`
- scope：
  - `/api/app/profile/governance/status`
  - `/api/app/profile/governance/appeals`
  - shell/profile 下的治理摘要字段
- 相互边界：
  - 与 `account` 包共享基础 profile 上下文，不共享 admin 风控动作。
  - 与 `fake_project` 包共享举报触发风险态的显示语义，不共享 penalty/appeal lifecycle。
  - 与 `contract` 包共享项目受阻态文案，不共享合同/验收判决真相。
- 仅聚合语义：
  - profile 风控摘要（最小字段）
  - 申诉提交透传
  - 受限文案/不可见态 copy
  - 错误码映射（GOVERNANCE 前缀）
- 严禁成为业务真相 owner：
  - `governance_penalties`
  - `governance_appeal_cases`
  - `governance_whitelist_memberships`
  - `governance_permanent_bans`
  - admin 审批决定与处罚生效链

## 四包统一交叉边界（汇总）
- 统一禁止项（跨包）：
  - 决策权、审核权、状态机 owner 均不进 BFF；
  - 禁止裸化新路由（`/risk/*`、`/penalty/*`、`/appeal/*`、`/ban/*`）；
  - 禁止把 `/api/app/*` 列举视为后链可直接实现；
  - 禁止复用 `FileAsset` 外的文件真相（必须走 `init->upload->confirm` 与 `FileAsset`）。
- 统一接管项：
  - 统一 app-facing 的 trace/actor/organization 透传；
  - 统一 request-body envelope；
  - 统一 blocked/unavailable copy；
  - 统一 server/admin 错误向 app-facing 的受控映射。

## 当前冻结状态
- `docs/03_bff` 四包 freeze 清单已归档并形成四包 package-level checkpoint，属于 implementation 前基础边界；
- 当前阶段结论仍为：`No-Go for implementation / release-prep / release execution`，可继续做 implementation 前独立复核。
- 第一阶段 package-level 结论：
  - `P1 账户与企业认证规则`：已通过
  - `P2 假项目举报与裁决`：已通过
  - `P3 合同归档与履约链`：已通过
  - `P4 黑白名单与永久封禁`：已通过（进入 package-level 复核）
