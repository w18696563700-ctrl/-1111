---
owner: Codex 总控
status: frozen
purpose: Freeze the docs-first controller-review spec bundle for stage3 package D, define the active template-config workbench object, and prevent stage3 from drifting into premature implementation or ticketing.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/stage3_admin_post_package_c_next_subpackage_ruling_addendum.md
  - docs/00_ssot/template_rule_snapshot_baseline_addendum.md
  - docs/05_admin/admin_ssot.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - docs/01_contracts/openapi.yaml
  - apps/admin/src/app/template_config/page.tsx
  - apps/admin/src/modules/template_config/template-config-shell.tsx
  - apps/admin/src/core/auth/route-guard.ts
---

# 《阶段3 package D template_config controller review spec bundle》

## 1. review 目标

- 本轮 review 目标固定为：
  - 锁定 `阶段3 package D` 的真实 active object
  - 锁定 `package D` 的第一 bounded package 边界
  - 判断 `package D` 当前是否允许进入 implementation dispatch
- 本轮只做：
  - docs-first controller review
  - active object ruling
  - bounded scope ruling
  - Go / No-Go ruling
- 本轮不做：
  - implementation
  - execution prompt
  - release
  - 把 `Admin` 扩成泛化配置中心

## 2. review 对象必须写死

- 当前 `package D` 的候选对象只能是：
  - `template_config 最小模板与规则快照治理台`
- 当前该对象在 Admin UI 上的承接座位只能是：
  - `/template_config`
- 当前 review 不得漂移成：
  - `ticketing`
  - 泛化 runtime config center
  - feature-flag center
  - generic CMS
  - 第二模板真源

## 3. review 对象范围

- 本轮 review 对象范围只允许覆盖：
  - `apps/admin` 的：
    - `/template_config`
    - `apps/admin/src/modules/template_config/**`
  - `apps/admin/src/core/auth/route-guard.ts` 中已纳入保护路由的 seat boundary
  - `docs/05_admin/admin_governance_surface_matrix.md` 中 `template_config` 模块边界
  - `docs/00_ssot/template_rule_snapshot_baseline_addendum.md` 中：
    - `Template`
    - `TemplateVersion`
    - `TemplateField`
    - `TemplateRule`
    - snapshot-bearing instance immutability
  - `docs/01_contracts/openapi.yaml` 中当前 package-D 对应 path family 缺口
- 本轮明确不得扩到：
  - `review`
  - `governance/penalties`
  - `governance/appeals`
  - `project_review`
  - `audit`
  - `ticketing`
  - `release-prep / launch`

## 4. 当前已知输入基线

- 当前 `Admin` 侧已有座位：
  - [template_config/page.tsx](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/app/template_config/page.tsx)
  - [template-config-shell.tsx](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/modules/template_config/template-config-shell.tsx)
- 当前 `Admin` route guard 已把 `/template_config` 视为受控后台路径：
  - [route-guard.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/core/auth/route-guard.ts)
- 当前 `Admin` matrix 已给出 `template_config` 的模块语义草案：
  - controlled template and rule configuration workbench
  - object family 倾向锁在：
    - `Template`
    - `TemplateVersion`
    - `TemplateField`
    - `TemplateRule`
    - controlled template grouping refs
- 当前 `L0` 已存在模板/规则/快照语义基线草案：
  - [template_rule_snapshot_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/template_rule_snapshot_baseline_addendum.md)

## 5. 当前已知主阻塞必须写死

- 当前 `/template_config` 仍是 placeholder shell，不是可用治理台。
- 当前 `docs/01_contracts/openapi.yaml` 未见冻结的：
  - `/server/admin/config/templates*` path family
  - 或同等 package-D contracts family
- 当前 `apps/server/src/**` 未见 package-D 对应的：
  - template truth family
  - version compare/read-model family
  - admin controller path family
- 当前 `template_rule_snapshot_baseline_addendum.md` 仍是 broad draft：
  - 它冻结的是上游模板/规则/快照语义
  - 但尚未冻结 package-D 的 backend truth boundary
- 当前 `admin_ssot.md` 与 `admin_governance_surface_matrix.md` 仍为 `draft`：
  - 不得被误读成 package-D 已获实现许可
- 因此当前真正要裁决的不是：
  - `template_config 要不要做`
- 而是：
  - `package D 的第一 bounded package 到底是什么`
  - `当前是否只允许进入 docs-first freeze`

## 6. review 必须显式判断

- 本轮 review 必须显式判断：
  - `package D` 的 active object 是否正式锁为：
    - `template and rule snapshot governance workbench`
  - `package D` 的第一 bounded package 是否正式锁为：
    - template list
    - version list/detail
    - schema/rule snapshot compare
    - draft authoring boundary
    - publish / archive / deprecate boundary
    - controlled grouping refs
  - `RuleVersion` 与 rule-assignment refs 是否必须进入 docs bundle
  - `Admin` 是否继续：
    - 直连 `Server`
    - 不经 `BFF`
  - package-D 的治理动作是否必须受以下 veto 约束：
    - 不得改写历史 snapshot-bearing instances
    - 不得越权成 runtime config center
    - 不得直接改 live business instance truth
  - `package D` 当前是否：
    - `Go for docs-first freeze`
    - `No-Go for implementation dispatch`

## 7. 第一 bounded package 的预期最小边界

- 本轮 review 必须倾向锁定的第一 bounded package 只允许解决：
  - 模板与版本队列
  - 模板 schema / field / rule set 的只读对比
  - draft template version authoring boundary
  - publish new template version
  - archive / deprecate template version
  - controlled template grouping refs
  - 与上述治理动作直接相关的最小 Admin / Server / contract docs bundle
- 本轮 review 必须显式排除：
  - retroactive rewrite of historical `Project` / `Order` / `Contract` /
    `Inspection` / `Rating` / `Dispute`
  - direct runtime config or feature-flag control
  - generic content management center
  - app-facing template consumption path
  - `ticketing`

## 8. review 输出必须至少包含

- 本轮 review 输出必须至少包含：
  - `package D` 真实 active object
  - `package D` 第一 bounded package 解决什么，不解决什么
  - 当前主阻塞
  - 当前第一执行 owner
  - `Go / No-Go`
  - 若 `No-Go`，implementation 被哪个 gate 卡住
  - 下一步唯一动作

## 9. 当前禁止进入

- 当前明确不得进入：
  - `package D implementation dispatch`
  - `ticketing implementation`
  - 泛化 config center implementation
  - 泛化 CMS implementation
  - `stage4`

## 10. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - `由总控依据本 spec 发起 stage3 package D controller review conclusion`

## 11. Formal Conclusion

- `阶段3 package D template_config controller review spec bundle` 已冻结。
- 当前正式口径已写死为：
  - `package D` 的候选对象只能是 `template_config 最小模板与规则快照治理台`
  - `package D` 当前只允许进入 docs-first controller review
  - `package D` 不得跳过 docs-first 直接进入 implementation
  - 在 controller review 结论形成前，不得进入 `package D` execution-dispatch
