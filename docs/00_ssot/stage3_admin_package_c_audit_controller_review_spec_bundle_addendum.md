---
owner: Codex 总控
status: frozen
purpose: Freeze the docs-first controller-review spec bundle for stage3 package C, define the active audit workbench object, and prevent stage3 from drifting into premature audit implementation or parallel admin subpackages.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/stage3_admin_post_package_b_next_subpackage_ruling_addendum.md
  - docs/05_admin/admin_ssot.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - docs/02_backend/audit_log_spec.md
  - docs/01_contracts/openapi.yaml
  - apps/admin/src/app/audit/page.tsx
  - apps/admin/src/modules/audit/audit-shell.tsx
  - apps/server/src/modules/audit/identity-audit-log.entity.ts
  - apps/server/src/modules/audit/identity-audit.service.ts
  - apps/server/src/modules/audit/project-publish-audit-log.entity.ts
  - apps/server/src/modules/audit/project-publish-audit.service.ts
---

# 《阶段3 package C audit controller review spec bundle》

## 1. review 目标

- 本轮 review 目标固定为：
  - 锁定 `阶段3 package C` 的真实 active object
  - 锁定 `package C` 的第一 bounded package 边界
  - 判断 `package C` 当前是否允许进入 implementation dispatch
- 本轮只做：
  - docs-first controller review
  - active object ruling
  - bounded scope ruling
  - Go / No-Go ruling
- 本轮不做：
  - implementation
  - execution prompt
  - release
  - 把 `Admin` 扩成全量审计平台

## 2. review 对象必须写死

- 当前 `package C` 的候选对象只能是：
  - `audit 最小只读检索与核验工作台`
- 当前该对象在 Admin UI 上的承接座位只能是：
  - `/audit`
- 当前 review 不得漂移成：
  - `template_config`
  - `ticketing`
  - 泛化后台检索中心
  - 审计导出平台
  - 审计写入或审计修复台

## 3. review 对象范围

- 本轮 review 对象范围只允许覆盖：
  - `apps/admin` 的：
    - `/audit`
    - `apps/admin/src/modules/audit/**`
    - `apps/admin/src/core/server/**` 中未来 audit transport 预留边界
  - `apps/server` 当前已存在的：
    - `apps/server/src/modules/audit/**`
  - `docs/02_backend/audit_log_spec.md` 中 append-only audit 规则
  - `docs/05_admin/admin_governance_surface_matrix.md` 中 audit 模块边界
  - `docs/01_contracts/openapi.yaml` 中当前 audit admin path 缺口
- 本轮明确不得扩到：
  - `review`
  - `governance/penalties`
  - `governance/appeals`
  - `project_review`
  - `template_config`
  - `ticketing`
  - `release-prep / launch`

## 4. 当前已知输入基线

- 当前 `Admin` 侧已有座位：
  - [apps/admin/src/app/audit/page.tsx](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/app/audit/page.tsx)
  - [apps/admin/src/modules/audit/audit-shell.tsx](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/modules/audit/audit-shell.tsx)
- 当前 `Admin` matrix 已冻结 audit surface 边界：
  - search / filter / inspect append-only audit records
  - read audit detail for object / actor / request / trace correlation
  - controlled read-only export 只有在 `Server` 已显式暴露时才允许承接
- 当前 `Server` 侧已有 audit truth carrier 基线：
  - [identity-audit-log.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/identity-audit-log.entity.ts)
  - [identity-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/identity-audit.service.ts)
  - [project-publish-audit-log.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit-log.entity.ts)
  - [project-publish-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit.service.ts)
- 当前 `backend truth` 已冻结 append-only audit required fields 与 must-audit rules：
  - [audit_log_spec.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/audit_log_spec.md)

## 5. 当前已知主阻塞必须写死

- 当前 `Admin /audit` 仍是只读 placeholder shell，不是可用工作台。
- 当前 `docs/01_contracts/openapi.yaml` 未见冻结的：
  - `/server/admin/audit*` path family
- 当前 `apps/server/src/modules/audit/**` 已有 writer / carrier 基线，但未见 package-C 对应的：
  - read-model query surface
  - admin controller path family
  - bounded detail contract family
- 当前 `docs/02_backend/audit_log_spec.md` 仍是 broad draft：
  - 它冻结了 append-only rules
  - 但尚未冻结 package-C 的 read-only query boundary
- 因此当前真正要裁决的不是：
  - `audit 要不要做`
- 而是：
  - `package C 的第一 bounded package 到底是什么`
  - `当前是否允许进入 implementation`

## 6. review 必须显式判断

- 本轮 review 必须显式判断：
  - `package C` 的 active object 是否正式锁为：
    - `audit minimal read-only search and verification workbench`
  - `package C` 的第一 bounded package 是否正式锁为：
    - `queue/list + filter + detail`
    - 仅围绕 append-only audit records 的 read-only consumption
  - `controlled export` 是否进入第一包
  - `object_type / object_id / object_no / actor_id / request_id / trace_id`
    是否构成第一包的最小检索锚点
  - `Admin` 是否继续：
    - 直连 `Server`
    - 不经 `BFF`
  - `package C` 当前是否：
    - `Go for docs-first freeze`
    - `No-Go for implementation dispatch`

## 7. 第一 bounded package 的预期最小边界

- 本轮 review 必须倾向锁定的第一 bounded package 只允许解决：
  - audit queue/list
  - filter by:
    - `object_type`
    - `object_id`
    - `object_no`
    - `actor_id`
    - `request_id`
    - `trace_id`
    - `action`
    - `occurred_at` time window
  - audit detail inspect
  - append-only audit verification
  - 与上述 read-only flow 直接相关的最小 Admin / Server 闭环
- 本轮 review 必须显式排除：
  - edit/delete audit rows
  - second audit store
  - business-state mutation through audit
  - generic export center
  - generic observability console
  - generic ticket routing console

## 8. review 输出必须至少包含

- 本轮 review 输出必须至少包含：
  - `package C` 真实 active object
  - `package C` 第一 bounded package 解决什么，不解决什么
  - 当前主阻塞
  - 当前第一执行 owner
  - `Go / No-Go`
  - 若 `No-Go`，implementation 被哪个 gate 卡住
  - 下一步唯一动作

## 9. 当前禁止进入

- 当前明确不得进入：
  - `package C implementation dispatch`
  - `template_config implementation`
  - `ticketing implementation`
  - 审计导出中心
  - 审计写入 / 修复台
  - `stage4`

## 10. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - `由总控依据本 spec 发起 stage3 package C controller review conclusion`

## 11. Formal Conclusion

- `阶段3 package C audit controller review spec bundle` 已冻结。
- 当前正式口径已写死为：
  - `package C` 的候选对象只能是 `audit 最小只读检索与核验工作台`
  - `package C` 的第一 bounded package 必须保持 read-only
  - `package C` 当前不得跳过 docs-first review 直接进入 implementation
  - 在 controller review 结论形成前，不得进入 `package C` execution-dispatch
