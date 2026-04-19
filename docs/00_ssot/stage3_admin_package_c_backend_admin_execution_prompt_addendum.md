---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded execution prompt for stage3 package C, authoring only the minimal read-only audit queue/filter/detail workbench across Server and Admin.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_c_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/stage3_admin_package_c_controller_review_conclusion_addendum.md
  - docs/01_contracts/stage3_admin_package_c_audit_contracts_addendum.md
  - docs/02_backend/stage3_admin_package_c_audit_backend_truth_addendum.md
  - docs/05_admin/stage3_admin_package_c_audit_admin_surface_addendum.md
---

# 《阶段3 package C backend/admin execution prompt》

```text
你现在是：
- 阶段 3｜Admin 最小运营与治理闭环
- package C backend/admin owner

你的唯一目标是：
- 在 /audit 座位上收口 append-only audit 的最小只读检索与核验工作台
- 让 Admin 直连 Server Admin API 形成：
  - queue/list
  - filter
  - detail inspect
  的最小闭环

本轮只允许做：
- Server Admin audit read-only path family 最小实现
- Admin /audit 消费与只读检索最小闭环
- admin-api-client 对 audit/logs* 的最小 transport
- 与上述对象直接相关的最小测试

本轮明确不做：
- audit export
- audit mutation
- audit repair
- template_config
- ticketing
- generic observability console
- BFF 介入 Admin
- release / deploy

只允许修改：
- apps/admin/src/app/audit/**
- apps/admin/src/modules/audit/**
- apps/admin/src/core/server/**
- 与上述对象直接相关的最小 apps/admin tests
- apps/server/src/modules/audit/**
- 如确有必要，可做最小 app.module / module wiring / controller wiring / test wiring

不允许修改：
- apps/mobile/**
- apps/bff/**
- apps/admin/src/modules/template_config/**
- apps/admin/src/modules/ticketing/**
- 与本轮无关的 apps/server 业务域

你必须完成：
1. Server 必须 materialize 以下 admin path family：
   - GET /server/admin/audit/logs
   - GET /server/admin/audit/logs/{auditLogId}
2. 这组 path family 只允许承接 package-C 已冻结的 query family：
   - sourceFamily
   - objectType
   - objectId
   - objectNo
   - actorId
   - requestId
   - traceId
   - action
   - occurredFrom
   - occurredTo
   - page
   - pageSize
3. Server read-model 只允许重用当前已冻结 carriers：
   - audit_logs
   - project_publish_audit_log
4. Server read-model 必须按已冻结 normalization 输出：
   - auditLogId
   - sourceFamily
   - objectType
   - objectId
   - objectNo
   - action
   - actorId
   - actorRole
   - requestId
   - traceId
   - occurredAt
   - beforeState
   - afterState
   - reason
   - payload
5. Admin /audit 必须消费并驱动以上 path family。
6. /audit 页面语义必须明确为：
   - append-only audit queue/filter/detail workbench
   - 不得继续停留在 placeholder
   - 也不得扩成 export / write / repair console
7. 所有调用仍必须：
   - 直连 Server
   - 不经 BFF
   - 继续受现有 session carrier 保护

你必须遵守：
1. 不得创建第二审计真源。
2. 不得把 package-C 扩成 generic audit platform。
3. 不得顺手加入 export 路径。
4. 不得顺手加入 mutation 路径。
5. 不得把 ticketing / template_config 偷带进本轮。

最小测试要求：
1. Server 侧至少覆盖：
   - audit queue/list
   - filter by sourceFamily / objectType / requestId 或 traceId
   - detail inspect
2. Admin 侧至少覆盖：
   - /audit route guard under the existing session carrier
   - admin-api-client audit/logs transport
   - minimal queue/detail/filter consumption

完成标准：
- /audit 不再只是 placeholder。
- Server 与 Admin 在同一 audit/logs path family 上形成最小 read-only 闭环。
- 当前 package-C 仍保持：
  - bounded
  - 不经 BFF
  - 不偷扩成 export / write / repair console

交付回执要求：
1. 修改文件清单
2. 为什么 /audit 当前只能被理解为 read-only workbench
3. 当前如何把 /audit 收口成 append-only audit queue/filter/detail desk
4. Server 和 Admin 各自的最小闭环证据
5. 新增或更新的测试结果
6. 仍未覆盖的非目标清单
```
