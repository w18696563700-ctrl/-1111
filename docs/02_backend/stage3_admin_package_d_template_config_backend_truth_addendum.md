---
owner: Codex 总控
status: frozen
purpose: Freeze the stage3 package D backend truth boundary for the template-config workbench, including template/rule ownership, versioned snapshot semantics, and the prohibition on historical rewrite or second template truth.
layer: L3 Backend
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_d_controller_review_conclusion_addendum.md
  - docs/00_ssot/template_rule_snapshot_baseline_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - docs/02_backend/service_boundaries.md
---

# 《阶段3 package D template_config backend truth addendum》

## 1. package-D backend truth 目标

- 本轮只冻结 `package D` 的 template/rule governance truth boundary。
- 本轮只允许：
  - template family ownership
  - versioned rule ownership
  - snapshot-aware governance read/write boundary
  - controlled publish / archive semantics
- 本轮不允许：
  - runtime config truth
  - feature-flag truth
  - historical instance rewrite
  - second template persistence

## 2. canonical truth ownership

- `Server` 继续是唯一 template/rule truth owner。
- `Admin` 只能消费并驱动受控 `Server Admin API`。
- `BFF` 不介入本包。

## 3. approved object family

当前 package-D 第一 bounded package 只允许收口以下 truth family：

- `Template`
  - long-lived template identity
- `TemplateVersion`
  - immutable publishable version carrier
- `TemplateField`
  - version-bound field structure
- `TemplateRule`
  - reusable rule identity
- `RuleVersion`
  - immutable versioned rule carrier
- controlled template/rule assignment refs
- controlled template grouping refs

当前 package-D 明确不允许：
- 新建第二模板真源，只为给 Admin 查询方便
- 在 `Admin` 本地持有模板/规则状态机
- 把 compare/read-model projection 回写为业务真源

## 4. versioned truth rule

- `Template` 只标识长期身份，不承载历史实例的可变解释。
- `TemplateVersion` 与 `RuleVersion` 必须是 immutable carrier。
- 新发布动作只能产生新的版本引用，不得原地改写历史版本。
- `TemplateField` 只能挂在具体 `TemplateVersion` 上，不得脱离版本独立漂移。

## 5. snapshot-bearing immutability inheritance

- package-D 必须继承：
  - [template_rule_snapshot_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/template_rule_snapshot_baseline_addendum.md)
  中的 historical immutability 规则。
- 因此 package-D 的 publish / archive / deprecate 动作只允许影响：
  - 新创建
  - 新 materialize
  的实例选择结果。
- package-D 明确不允许：
  - retroactive rewrite of frozen `Project`
  - retroactive rewrite of frozen `Order`
  - retroactive rewrite of frozen `Contract`
  - retroactive rewrite of frozen `Inspection`
  - retroactive rewrite of frozen `Rating`
  - retroactive rewrite of frozen `Dispute`

## 6. read-model truth rule

- package-D 允许在 `Server Admin` query 层构造统一治理 read-model。
- 该 read-model 的性质只能是：
  - transient projection
  - query-time compare / normalization
- 它不是：
  - new persistence truth
  - merge engine
  - runtime config center

## 7. minimum truth anchors

package-D 第一 bounded package 的最小治理锚点固定为：

- `templateId`
- `templateKey`
- `templateName`
- `templateVersionId`
- `versionNo`
- `templateRuleId`
- `ruleVersionId`
- `groupRef`
- `status`
- `publishedAt`
- `archivedAt`
- `updatedAt`

detail/compare 层补充字段固定为：
- `schema`
- `fields`
- `assignmentRefs`
- `fieldDiff`
- `ruleDiff`
- `groupingDiff`

规则：
- compare 层只能表达 versioned diff。
- 不得在 query 层推断未冻结的业务语义。

## 8. mutation boundary

当前 package-D 只允许以下受控治理动作：

- create template identity
- create draft template version
- publish template version
- archive / deprecate template version
- adjust controlled grouping refs

当前 package-D 不允许：

- editing an already published immutable version in place
- rebinding historical instance snapshot refs
- direct mutation of live business instances through template_config
- generic runtime-config write path

## 9. boundary with service truth

- `docs/02_backend/service_boundaries.md` 继续拥有：
  - domain service ownership
  - backend single-truth discipline
- 本文只冻结：
  - package-D template/rule governance truth boundary
  - versioned immutability boundary
  - compare/read-model boundary
- 当前 package-D 不改写：
  - downstream object lifecycle ownership
  - app-facing consumption ownership

## 10. explicit non-goals

- 不新增泛化配置平台
- 不新增 feature-flag carrier
- 不新增历史实例修复命令
- 不新增 `Admin` 本地模板真源
- 不把 ticket routing 与 template governance 混成一个对象家族

## 11. Formal Conclusion

- `stage3 package D` 的 backend truth 已冻结为：
  - `Server` owns template/rule/version truth
  - `Admin` only consumes controlled governance projections and commands
  - historical snapshot-bearing instances remain immutable against later template/rule change
- 当前 package-D 明确禁止：
  - 第二模板真源
  - runtime-config drift
  - 任何通过 Admin 触发的历史实例重写
