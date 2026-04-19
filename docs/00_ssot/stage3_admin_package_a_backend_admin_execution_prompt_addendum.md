---
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-dispatch prompt for stage-3 package A, limited to server-session-carrier-only Admin entry plus review and governance minimal workbench closure.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_minimal_operation_governance_controller_review_conclusion_addendum.md
  - docs/00_ssot/stage_dispatch_routing_matrix_v1.md
  - docs/00_ssot/s1_c03_admin_content_safety_review_tasks_minimal_interface_closure_result_verification_conclusion_addendum.md
  - docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md
  - docs/05_admin/admin_ssot.md
  - docs/05_admin/admin_governance_surface_matrix.md
---

# 《阶段3 package A backend/admin execution prompt》

## 1. 角色与目标

- 你现在是：
  - `阶段 3｜Admin 最小运营与治理闭环`
  - `package A backend/admin owner`
- 你的唯一目标是：
  - 收掉 `Admin` 当前“登录占位 + review/governance 只半通不闭环”的最小主阻塞
  - 让 `Admin` 在不引入第二真源、不引入 BFF 的前提下，形成可验证的最小治理工作台闭环

## 2. 本轮只做

- 本轮只允许做：
  - `server_session_carrier_only` 最小管理员会话载体收口
  - `review` workbench 最小闭环
  - `governance/penalties` 最小闭环
  - `governance/appeals` 最小闭环
  - 与上述闭环直接相关的最小测试

## 3. 本轮不做

- 本轮明确不做：
  - `project_review`
  - `template_config`
  - `audit`
  - `ticketing`
  - `BFF` 介入 `Admin`
  - 全量账号密码 + 二次校验登录体系
  - `enterprise-display` 已 closure 链的重开
  - `release / deploy`

## 4. 允许修改范围

- 只允许修改：
  - `apps/admin/src/app/login/page.tsx`
  - `apps/admin/src/core/auth/**`
  - `apps/admin/src/core/server/admin-api-client.ts`
  - `apps/admin/src/modules/review/**`
  - `apps/admin/src/modules/governance/**`
  - `apps/admin/src/app/review/**`
  - `apps/admin/src/app/governance/**`
  - 与以上对象直接相关的最小 `apps/admin` route handlers / tests
  - `apps/server/src/modules/content_safety/**`
  - `apps/server/src/modules/governance/**`
  - 如最小管理员会话载体确需服务端支撑，可做与 `admin_session` 直接相关的最小 `apps/server` 会话 carrier
- 不允许修改：
  - `apps/mobile/**`
  - `apps/bff/**`
  - `apps/admin/src/modules/project_review/**`
  - `apps/admin/src/modules/template_config/**`
  - `apps/admin/src/modules/audit/**`
  - `apps/admin/src/modules/ticketing/**`
  - 与本轮无关的 `apps/server` 业务域

## 5. 你必须完成

1. 让 `Admin` 的 active 登录模式收口到：
   - `server_session_carrier_only`
2. `login` 页不得继续伪装成待确认的账号密码页。
3. `review` workbench 必须形成最小可用闭环：
   - list
   - detail
   - approve
   - reject
4. `governance/penalties` workbench 必须形成最小可用闭环：
   - list
   - detail
   - apply
5. `governance/appeals` workbench 必须形成最小可用闭环：
   - list
   - detail
   - decide
6. 以上所有动作都必须继续：
   - 直连 `Server` Admin API
   - 受控审计归因
   - 不经 `BFF`
7. 补最小测试，至少覆盖：
   - session carrier 缺失与存在时的保护路由行为
   - review list/detail/action
   - penalties list/detail/apply
   - appeals list/detail/decide

## 6. 你必须遵守

1. 不得发明第二套管理员状态机。
2. 不得让 `Admin` 经由 `BFF` 访问 truth。
3. 不得把 `project_review / template_config / audit / ticketing` 偷带进本轮。
4. 不得把 `server_session_carrier_only` 偷换成假登录成功。
5. 不得绕过审计。

## 7. 完成标准

- `Admin` 当前不再停留在纯占位登录态。
- `review / governance/penalties / governance/appeals` 三条工作台链在同一最小会话载体下形成真实可验证闭环。
- `Admin` 仍保持：
  - 直连 `Server`
  - 不经 `BFF`
  - 不持有第二真源

## 8. 交付回执要求

1. 修改文件清单
2. 为什么之前 `Admin` 仍停在占位态
3. `server_session_carrier_only` 如何落地
4. `review / penalties / appeals` 三条链各自的闭环证据
5. 新增或更新的测试结果
6. 仍未覆盖的非目标清单
