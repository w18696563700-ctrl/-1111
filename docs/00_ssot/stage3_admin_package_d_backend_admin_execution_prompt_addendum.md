---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded execution prompt for stage3 package D, authoring only the minimal template/rule snapshot governance workbench across Server and Admin.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_d_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/stage3_admin_package_d_template_rule_snapshot_truth_freeze_addendum.md
  - docs/00_ssot/stage3_admin_package_d_controller_review_conclusion_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/02_backend/stage3_admin_package_d_template_config_backend_truth_addendum.md
  - docs/05_admin/stage3_admin_package_d_template_config_admin_surface_addendum.md
---

# 《阶段3 package D backend/admin execution prompt》

```text
你现在是：
- 阶段 3｜Admin 最小运营与治理闭环
- package D backend/admin owner

你的唯一目标是：
- 在 /template_config 座位上收口模板与规则快照治理的最小工作台
- 让 Admin 直连 Server Admin API 形成：
  - template queue/list
  - version list/detail
  - schema / field / rule compare
  - draft authoring
  - publish / archive / grouping
  的最小闭环

本轮只允许做：
- Server Admin config/templates path family 最小实现
- Admin /template_config 消费与治理最小闭环
- admin-config-api-client 与相关 transport 的最小补齐
- 与上述对象直接相关的最小测试

本轮明确不做：
- runtime-config
- feature-flag control
- app-facing template delivery
- historical instance rewrite / rebind
- generic CMS
- ticketing
- BFF 介入 Admin
- release / deploy

只允许修改：
- apps/admin/src/app/template_config/**
- apps/admin/src/modules/template_config/**
- apps/admin/src/core/server/**
- 与上述对象直接相关的最小 apps/admin tests
- apps/server/src/modules/template_config/**
- 如确有必要，可做最小 app.module / module wiring / controller wiring / test wiring

不允许修改：
- apps/mobile/**
- apps/bff/**
- apps/admin/src/modules/ticketing/**
- apps/admin/src/modules/audit/**
- apps/admin/src/modules/project_review/**
- 与本轮无关的 apps/server 业务域
- apps/server/src/core/runtime-config.service.ts

你必须完成：
1. Server 必须 materialize 以下 admin path family：
   - GET /server/admin/config/templates
   - GET /server/admin/config/templates/{templateId}
   - GET /server/admin/config/templates/{templateId}/versions
   - GET /server/admin/config/templates/{templateId}/versions/{templateVersionId}
   - GET /server/admin/config/templates/{templateId}/versions/compare
   - POST /server/admin/config/templates
   - POST /server/admin/config/templates/{templateId}/versions
   - POST /server/admin/config/templates/{templateId}/versions/{templateVersionId}/publish
   - POST /server/admin/config/templates/{templateId}/versions/{templateVersionId}/archive
   - POST /server/admin/config/templates/{templateId}/grouping
2. 这组 path family 只允许承接 package-D 已冻结的 query / payload family。
3. Server truth 只允许围绕以下已冻结对象家族展开：
   - Template
   - TemplateVersion
   - TemplateField
   - TemplateRule
   - RuleVersion
   - assignmentRefs
   - groupRef
4. Server 必须严格遵守：
   - published version immutable
   - historical snapshot-bearing instances not rewritten
   - compare = read-only diff projection
5. Admin /template_config 必须消费并驱动以上 path family。
6. /template_config 页面语义必须明确为：
   - template and rule snapshot governance workbench
   - 不得继续停留在 placeholder
   - 也不得扩成 runtime-config / CMS / rewrite console
7. 所有调用仍必须：
   - 直连 Server
   - 不经 BFF
   - 继续受现有 session carrier 保护

你必须遵守：
1. 不得创建第二 template/rule 真源。
2. 不得让已发布版本原地可变。
3. 不得把 later publish 解释成历史实例自动重绑。
4. 不得顺手加入 runtime-config 或 feature-flag 路径。
5. 不得把 ticketing / audit / project_review 偷带进本轮。

最小测试要求：
1. Server 侧至少覆盖：
   - template queue/list
   - version list/detail
   - compare
   - publish / archive / grouping 的最小命令边界
   - 历史实例不可回写 guard
2. Admin 侧至少覆盖：
   - /template_config route guard under the existing session carrier
   - admin-config transport
   - minimal queue/detail/compare/mutation consumption

完成标准：
- /template_config 不再只是 placeholder。
- Server 与 Admin 在同一 config/templates path family 上形成最小治理闭环。
- 当前 package-D 仍保持：
  - bounded
  - 不经 BFF
  - 不偷扩成 runtime-config / CMS / rewrite console

交付回执要求：
1. 修改文件清单
2. 为什么 /template_config 当前只能被理解为 template/rule snapshot governance workbench
3. 当前如何把 /template_config 收口成 list/detail/compare/draft/publish/archive/grouping desk
4. Server 和 Admin 各自的最小闭环证据
5. 新增或更新的测试结果
6. 仍未覆盖的非目标清单
```
