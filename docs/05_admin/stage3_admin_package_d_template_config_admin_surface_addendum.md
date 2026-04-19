---
owner: Codex 总控
status: frozen
purpose: Freeze the stage3 package D admin surface for the template-config seat, defining the bounded template/version/rule governance workbench semantics without opening runtime-config, generic CMS, or historical rewrite consoles.
layer: L3 Admin
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_d_controller_review_conclusion_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/02_backend/stage3_admin_package_d_template_config_backend_truth_addendum.md
  - docs/05_admin/admin_ssot.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - apps/admin/src/app/template_config/page.tsx
  - apps/admin/src/modules/template_config/template-config-shell.tsx
---

# 《阶段3 package D template_config admin surface addendum》

## 1. seat meaning

- `Admin /template_config` 的 seat meaning 正式锁定为：
  - `template and rule snapshot governance workbench`
- 它不是：
  - runtime config center
  - feature-flag center
  - generic CMS
  - historical rewrite console

## 2. page semantics

`/template_config` 第一 bounded package 只允许承接：
- template queue/list
- version queue/list
- version detail
- schema / field / rule compare
- draft authoring
- publish / archive / deprecate
- controlled grouping refs

当前 package-D 不允许承接：
- runtime value editing
- feature toggle editing
- downstream business object rewrite
- app-facing preview center
- ticket handoff center

## 3. section boundary

第一 bounded package 的最小页面结构固定为：

1. template queue/list section
2. template version list/detail section
3. schema / field / rule compare section
4. draft authoring section
5. publish / archive / grouping section

当前 package-D 不冻结：
- dashboard summary cards
- app-facing preview panel
- full CMS asset center
- cross-module ticket panel

## 4. list and filter surface

前端只允许提供以下 filter surface：
- `status`
- `groupRef`
- `keyword`
- `page`
- `pageSize`

规则：
- 这些字段必须一一对齐 package-D contract family。
- 不得额外发明本地 filter state machine。

## 5. detail and compare minimum

`/template_config` detail / compare 面最小只允许承接：
- `templateId`
- `templateKey`
- `templateName`
- `templateVersionId`
- `versionNo`
- `templateRuleId`
- `ruleVersionId`
- `groupRef`
- `status`
- `schema`
- `fields`
- `assignmentRefs`
- `fieldDiff`
- `ruleDiff`
- `groupingDiff`
- `publishedAt`
- `archivedAt`
- `updatedAt`

规则：
- 若某些字段为空，前端只能做 controlled empty rendering。
- 不得补造缺失语义。

## 6. mutation surface boundary

当前 package-D 第一 bounded package 只允许开放以下 CTA：
- create template
- create draft version
- publish version
- archive / deprecate version
- adjust grouping refs

当前 package-D 不允许开放：
- rewrite historical instances
- generic config save
- feature-flag publish
- delete immutable published history

## 7. transport boundary

- `Admin` 继续：
  - 直连 `Server Admin API`
  - 不经 `BFF`
- 当前 package-D 的 transport family 只能对齐：
  - `config/templates` bounded path family

## 8. copy boundary

首页文案和模块文案必须明确表达：
- 模板
- 版本
- 规则
- 快照
- 历史不可回写

不得暗示：
- 改完模板会自动改历史项目
- 可通过该台直接修改 live 业务对象
- 这里是泛化配置中心

## 9. explicit non-goals

- 不做 runtime-config CTA
- 不做 feature-flag CTA
- 不做 app-facing preview CTA
- 不做 historical rewrite CTA
- 不做 second-truth local cache

## 10. Formal Conclusion

- `stage3 package D` 的 admin surface 已冻结为：
  - `/template_config` = template/version/rule snapshot governance workbench
- 当前 `/template_config` 不得扩写成：
  - runtime config center
  - feature-flag center
  - generic CMS
- 后续若 author implementation dispatch，只能在本 surface 边界内继续展开。
