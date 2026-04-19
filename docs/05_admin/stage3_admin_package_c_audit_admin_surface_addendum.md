---
owner: Codex 总控
status: frozen
purpose: Freeze the stage3 package C admin surface for the audit seat, defining the bounded read-only queue/filter/detail workbench semantics without opening write or export consoles.
layer: L3 Admin
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_c_controller_review_conclusion_addendum.md
  - docs/01_contracts/stage3_admin_package_c_audit_contracts_addendum.md
  - docs/02_backend/stage3_admin_package_c_audit_backend_truth_addendum.md
  - docs/05_admin/admin_ssot.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - apps/admin/src/app/audit/page.tsx
  - apps/admin/src/modules/audit/audit-shell.tsx
---

# 《阶段3 package C audit admin surface addendum》

## 1. seat meaning

- `Admin /audit` 的 seat meaning 正式锁定为：
  - `append-only audit read-only search and verification workbench`
- 它不是：
  - 审计写入台
  - 审计修复台
  - 泛化 observability console
  - 泛化 export center

## 2. page semantics

`/audit` 第一 bounded package 只允许承接：
- queue/list
- filter
- detail inspect
- append-only verification

当前 package-C 不允许承接：
- row edit
- row delete
- bulk replay
- direct business-state action
- standalone export console

## 3. section boundary

第一 bounded package 的最小页面结构固定为：

1. queue/list section
2. filter section
3. detail inspect section

当前 package-C 不冻结：
- dashboard summary cards
- saved search center
- export modal
- cross-module ticket handoff panel

## 4. filter surface

前端只允许提供以下 filter surface：
- `sourceFamily`
- `objectType`
- `objectId`
- `objectNo`
- `actorId`
- `requestId`
- `traceId`
- `action`
- `occurredFrom`
- `occurredTo`

规则：
- 这些字段必须一一对齐 package-C contract family。
- 不得额外发明本地 filter state machine。

## 5. detail inspect minimum

`/audit` detail 面最小只允许承接：
- `auditLogId`
- `sourceFamily`
- `objectType`
- `objectId`
- `objectNo`
- `action`
- `actorId`
- `actorRole`
- `requestId`
- `traceId`
- `occurredAt`
- `beforeState`
- `afterState`
- `reason`
- `payload`

规则：
- 若某些字段为空，前端只能做 controlled empty rendering。
- 不得补造缺失语义。

## 6. transport boundary

- `Admin` 继续：
  - 直连 `Server Admin API`
  - 不经 `BFF`
- 当前 package-C 的 transport family 只能对齐：
  - `GET /server/admin/audit/logs`
  - `GET /server/admin/audit/logs/{auditLogId}`

## 7. copy boundary

首页文案和模块文案必须明确表达：
- 只读
- 追踪
- 核验

不得暗示：
- 可更改审计记录
- 可通过审计台直接处理业务对象
- 可在这里“修复问题数据”

## 8. explicit non-goals

- 不做 export CTA
- 不做 write CTA
- 不做 escalation CTA
- 不做 ticket routing CTA
- 不做 second-truth local cache

## 9. Formal Conclusion

- `stage3 package C` 的 admin surface 已冻结为：
  - `/audit` = read-only queue/filter/detail workbench
- 当前 `/audit` 不得扩写成：
  - write console
  - export console
  - generic admin search center
- 后续若 author implementation dispatch，只能在本 surface 边界内继续展开。
