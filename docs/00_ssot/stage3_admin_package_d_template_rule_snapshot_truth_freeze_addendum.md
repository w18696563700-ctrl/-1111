---
owner: Codex 总控
status: frozen
purpose: Freeze the package-D-specific L0 truth for template/rule snapshot governance, so implementation dispatch may proceed without opening runtime-config, app-facing consumption, or historical rewrite semantics.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_d_controller_review_conclusion_addendum.md
  - docs/00_ssot/template_rule_snapshot_baseline_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/02_backend/stage3_admin_package_d_template_config_backend_truth_addendum.md
  - docs/05_admin/stage3_admin_package_d_template_config_admin_surface_addendum.md
---

# 《阶段3 package D template-rule snapshot truth freeze》

## 1. scope

- 本冻结单只覆盖：
  - `阶段3 package D｜template_config 最小模板与规则快照治理台`
- 本冻结单只服务于：
  - package-D 专属 `Template / TemplateVersion / TemplateField`
    语义
  - package-D 专属 `TemplateRule / RuleVersion / assignment refs`
    语义
  - snapshot-bearing instance 的继承边界
  - package-D 与 `project_chain / order_chain / fulfillment_chain`
    的不可回写边界
- 本冻结单不进入：
  - API implementation
  - persistence / migration
  - app-facing consumption
  - runtime-config
  - feature-flag
  - historical repair console

## 2. package-D 当前唯一真义

- `package D` 当前唯一允许进入 implementation dispatch 的对象正式锁定为：
  - `template_config minimal template and rule snapshot governance workbench`
- 该对象的唯一 seat meaning 继续固定为：
  - `模板 identity`
  - `模板版本`
  - `字段结构`
  - `规则版本`
  - `受控 assignment / grouping refs`
    的治理台
- 当前 package-D 明确不是：
  - runtime-config center
  - feature-flag center
  - generic CMS
  - 历史实例重写台
  - app-facing template delivery center

## 3. canonical truth family

- package-D 第一 bounded package 的最小 truth family 正式冻结为：
  - `Template`
  - `TemplateVersion`
  - `TemplateField`
  - `TemplateRule`
  - `RuleVersion`
  - controlled `assignmentRefs`
  - controlled `groupRef`
- 这些对象的最小语义固定为：
  - `Template` = 长期 template identity
  - `TemplateVersion` = immutable publishable version carrier
  - `TemplateField` = version-bound schema field carrier
  - `TemplateRule` = reusable rule identity
  - `RuleVersion` = immutable rule version carrier
  - `assignmentRefs / groupRef` = 受控分配与分组引用
- `Server` 继续是以上对象家族的唯一真源 owner。
- `Admin` 只允许消费和驱动受控 `Server Admin API`。
- `BFF` 继续不介入本包。

## 4. versioned immutability rule

- package-D 必须继承以下 immutable 规则：
  - published `TemplateVersion` 不得原地改写
  - published `RuleVersion` 不得原地改写
  - compare 只能表达版本差异，不得演化成 merge engine
- 允许的前进方式只有：
  - create template identity
  - create draft version
  - publish new version
  - archive / deprecate version
  - adjust controlled grouping refs
- 不允许的方式固定为：
  - edit published version in place
  - overwrite historical schema meaning
  - create second template truth for admin convenience

## 5. snapshot-bearing instance inheritance

- package-D 当前必须继承 snapshot-bearing instance 的历史不可回写规则。
- 当前相关实例集继续固定为：
  - `Project`
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
  - `Rating`
  - `ChangeOrder`
  - `Dispute`
- 对这些实例，package-D 只能影响：
  - 新创建
  - 新 materialize
    时的 template / rule 选择结果
- package-D 明确不得影响：
  - 已冻结 `Project`
  - 已冻结 `Order`
  - 已冻结 `Contract`
  - 已冻结 `Milestone`
  - 已冻结 `Inspection`
  - 已冻结 `Rating`
  - 已冻结 `ChangeOrder`
  - 已冻结 `Dispute`
    的历史 snapshot refs

## 6. boundary with publish / order / fulfillment chains

- `发布项目工作台及延伸功能全链`
  当前仍是 mixed-maturity object。
- `订单承接与履约承接主链`
  当前仍只是一条 subordinate continuation subchain。
- 以上两个事实当前不会阻断 package-D implementation dispatch authoring，
  原因正式写死为：
  - package-D 当前 author 的只是 template/rule governance bounded package
  - package-D 当前不 author historical instance rewrite path
  - package-D 当前不 author workbench / order / fulfillment runtime completion
- 因此当前 package-D 可以前进到 implementation dispatch，
  但前进条件必须固定为：
  - 只实现受控 template/rule governance
  - 不借机改写 `order_chain / fulfillment_chain`
  - 不把 `project publish workbench` 解释成 template runtime owner

## 7. relation with broad baseline draft

- [template_rule_snapshot_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/template_rule_snapshot_baseline_addendum.md)
  当前仍是 broader baseline draft。
- 但对 `stage3 package D` 而言，
  本冻结单已经正式收口了可执行的 package-D 专属子集真义。
- 因此从 package-D gate 角度，
  当前 authoritative L0 truth 固定为：
  - 本冻结单
  - 而不是等待 broader baseline 全量收口后再 author bounded execution prompt

## 8. explicit non-goals

- 不 author runtime-config truth
- 不 author feature-flag truth
- 不 author app-facing template transport
- 不 author historical instance rebind / rewrite
- 不 author generic CMS
- 不 author ticket routing

## 9. Formal Conclusion

- `stage3 package D` 的 package-specific `template / rule / snapshot`
  L0 truth 已冻结。
- 当前 package-D 正式允许基于该 truth 进入：
  - `implementation dispatch authoring`
- 当前 package-D 仍必须保持：
  - bounded template/rule governance
  - historical immutability
  - no runtime-config
  - no second truth
