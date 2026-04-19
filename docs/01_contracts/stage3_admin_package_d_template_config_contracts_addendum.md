---
owner: Codex 总控
status: frozen
purpose: Freeze the stage3 package D template-config contract family for the bounded template/rule snapshot governance workbench without opening runtime-config, app-facing consumption, or historical rewrite semantics.
layer: L2 Contracts
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_d_controller_review_conclusion_addendum.md
  - docs/00_ssot/template_rule_snapshot_baseline_addendum.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - docs/01_contracts/openapi.yaml
  - apps/admin/src/app/template_config/page.tsx
  - apps/admin/src/modules/template_config/template-config-shell.tsx
---

# 《阶段3 package D template_config contracts addendum》

## 1. contract family 目标

- 本轮只冻结 `package D` 的最小 template-config admin path family。
- 本轮只允许：
  - template queue/list
  - version list/detail
  - version compare
  - draft authoring
  - publish
  - archive / deprecate
  - controlled grouping refs
- 本轮不允许：
  - runtime config
  - feature-flag control
  - app-facing template consumption
  - retroactive historical rewrite

## 2. canonical path family

- `GET /server/admin/config/templates`
- `GET /server/admin/config/templates/{templateId}`
- `GET /server/admin/config/templates/{templateId}/versions`
- `GET /server/admin/config/templates/{templateId}/versions/{templateVersionId}`
- `GET /server/admin/config/templates/{templateId}/versions/compare`
- `POST /server/admin/config/templates`
- `POST /server/admin/config/templates/{templateId}/versions`
- `POST /server/admin/config/templates/{templateId}/versions/{templateVersionId}/publish`
- `POST /server/admin/config/templates/{templateId}/versions/{templateVersionId}/archive`
- `POST /server/admin/config/templates/{templateId}/grouping`

当前 package-D 不冻结：
- `DELETE /server/admin/config/templates/*`
- `PATCH /server/admin/config/runtime/*`
- `POST /server/admin/config/flags/*`
- 任意 app-facing `/api/app/template*`

## 3. list query params

`GET /server/admin/config/templates` 允许的最小 query family 固定为：

- `status`
  - allowed:
    - `draft`
    - `published`
    - `archived`
    - `deprecated`
- `groupRef`
- `keyword`
- `page`
- `pageSize`

当前 package-D 不冻结：
- arbitrary sort field
- full-text body search
- saved filter
- export token

## 4. template list response shape

`GET /server/admin/config/templates` 的最小 response shape 固定为：

- `items[]`
  - `templateId`
  - `templateKey`
  - `templateName`
  - `groupRef`
  - `activeVersionId`
  - `status`
  - `updatedAt`
- `pagination`
  - `page`
  - `pageSize`
  - `total`

规则：
- 这是 governance projection，不是第二模板真源。
- `activeVersionId` 只表示当前受控发布版本引用，不得暗示历史实例自动重绑。

## 5. template detail response shape

`GET /server/admin/config/templates/{templateId}` 的最小 response shape 固定为：

- `templateId`
- `templateKey`
- `templateName`
- `description`
- `groupRef`
- `status`
- `activeVersionId`
- `publishedVersionCount`
- `updatedAt`

## 6. version list and detail response shape

`GET /server/admin/config/templates/{templateId}/versions` 的最小 response shape 固定为：

- `items[]`
  - `templateVersionId`
  - `versionNo`
  - `status`
  - `ruleVersionId`
  - `publishedAt`
  - `archivedAt`
  - `createdAt`
- `pagination`
  - `page`
  - `pageSize`
  - `total`

`GET /server/admin/config/templates/{templateId}/versions/{templateVersionId}` 的最小 response shape 固定为：

- `templateVersionId`
- `templateId`
- `versionNo`
- `status`
- `schema`
- `fields[]`
  - `fieldKey`
  - `fieldType`
  - `required`
  - `defaultValue`
  - `displayOrder`
- `rule`
  - `templateRuleId`
  - `ruleVersionId`
  - `assignmentRefs[]`
- `publishedAt`
- `archivedAt`
- `createdAt`

规则：
- `schema` / `fields[]` / `rule` 只表达该版本快照。
- 不得把 detail 响应写回为第二真源。

## 7. compare response shape

`GET /server/admin/config/templates/{templateId}/versions/compare` 的最小 query family 固定为：

- `baseVersionId`
- `targetVersionId`

最小 response shape 固定为：

- `baseVersion`
  - `templateVersionId`
  - `versionNo`
- `targetVersion`
  - `templateVersionId`
  - `versionNo`
- `fieldDiff`
- `ruleDiff`
- `groupingDiff`

规则：
- compare 结果是只读 diff projection。
- 不得扩写成 merge engine。

## 8. mutation payload boundary

`POST /server/admin/config/templates` 的最小 payload 只允许：
- `templateKey`
- `templateName`
- `description`
- `groupRef`

`POST /server/admin/config/templates/{templateId}/versions` 的最小 payload 只允许：
- `schema`
- `fields[]`
- `rule`
  - `templateRuleId`
  - `ruleVersionId`
  - `assignmentRefs[]`

`POST /server/admin/config/templates/{templateId}/versions/{templateVersionId}/publish`
的最小 payload 只允许：
- `publishNote`

`POST /server/admin/config/templates/{templateId}/versions/{templateVersionId}/archive`
的最小 payload 只允许：
- `archiveReason`

`POST /server/admin/config/templates/{templateId}/grouping` 的最小 payload 只允许：
- `groupRef`

当前 package-D 不冻结：
- bulk publish
- bulk archive
- historical instance rebind
- direct mutation of existing `Project` / `Order` / `Contract` / `Inspection`

## 9. auth and transport boundary

- `Admin` 继续直连 `Server Admin API`
- 不经 `BFF`
- 继续受当前 `server_session_carrier_only` 管理员会话载体保护

## 10. explicit non-goals

- 不冻结 runtime config path
- 不冻结 feature-flag path
- 不冻结 app-facing path
- 不冻结 historical rewrite path
- 不冻结 generic CMS path
- 不冻结 ticketing path

## 11. Formal Conclusion

- `stage3 package D` 的最小 contracts family 已冻结为：
  - `config/templates` bounded path family
- 当前 package-D contract 只允许模板/版本/规则快照治理。
- 在后续 execution-dispatch author 之前，不得自行扩展为 runtime-config、feature-flag 或历史重写 family。
