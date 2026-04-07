---
owner: Codex 总控
status: frozen
purpose: Freeze the Round B contract admission for project publish only, limited to the three admitted richer fields and without entering persistence, migration, or implementation.
layer: L0 SSOT
inputs_canonical:
  - docs/00_ssot/project_publish_round_b_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 项目发布 Round B contract 冻结单

## 1. Scope

- 本冻结单只覆盖 `项目发布 Round B contract freeze`。
- 本冻结单只允许冻结以下 3 项：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- 本冻结单不冻结：
  - `预算区间`
  - `奖励金额`
  - `创建前附件主表单化`
- 本冻结单不进入：
  - persistence freeze
  - migration freeze
  - 业务代码实现
  - 其他板块 contract 扩面

## 2. Shared Contract Principle

- 这 3 个字段都进入：
  - `ProjectCreateRequest`
  - `ProjectReadModel`
- create 与 detail 命名必须完全一致。
- `GET /api/app/project/detail` 与 `GET /server/projects/{projectId}` 必须在字段已提交且已存储时回读同名值。
- `project/list` 与 workbench 当前不承担这 3 个字段的 projection 义务；继续允许 omitted / `null`。

## 3. `areaSqm` Contract Freeze

- 字段名：
  - `areaSqm`
- 真义：
  - 项目面积
- 进入 `ProjectCreateRequest`：
  - 是
- 进入 `ProjectReadModel`：
  - 是
- create 承载规则：
  - 当前为选填
  - omitted / `null` 表示当前未单独提供面积真值
  - 若提供，必须是 canonical `sqm` 数值
- detail 回读规则：
  - `project/detail` 必须在值已存储时回读 `areaSqm`
  - 当前 `project/list` / workbench 可 omitted / `null`
- 类型与精度规则：
  - `number`
  - 单位固定 `sqm`
  - 最多两位小数
  - 必须为正数
- 兼容说明：
  - 不新增单位字段
  - 不允许把“㎡”“平方米”作为真值载体写入 contract

## 4. `buildingTypeRemark` Contract Freeze

- 字段名：
  - `buildingTypeRemark`
- 真义：
  - 项目类型备注
- 进入 `ProjectCreateRequest`：
  - 是
- 进入 `ProjectReadModel`：
  - 是
- create 承载规则：
  - 当前为选填
  - omitted / `null` 表示当前没有额外类型备注
  - 空字符串不应被视为有意义真值；消费与实现后续应按空值处理
- detail 回读规则：
  - `project/detail` 必须在值已存储时回读 `buildingTypeRemark`
  - 当前 `project/list` / workbench 可 omitted / `null`
- 文本规则：
  - `string`
  - 最大长度 `100`
- 兼容说明：
  - 它只补充说明既有 `buildingType`
  - 它不替代 `buildingType`
  - 它不创造第二套项目类型真相

## 5. `scheduleDetail` Contract Freeze

- 字段名：
  - `scheduleDetail`
- 真义：
  - 详细时间补充文本
- 进入 `ProjectCreateRequest`：
  - 是
- 进入 `ProjectReadModel`：
  - 是
- create 承载规则：
  - 当前为选填
  - omitted / `null` 表示当前没有额外排期补充说明
- detail 回读规则：
  - `project/detail` 必须在值已存储时回读 `scheduleDetail`
  - 当前 `project/list` / workbench 可 omitted / `null`
- 文本规则：
  - `string`
  - 最大长度 `200`
- 强边界：
  - 它不是完整 schedule object
  - 不得扩成时间段数组
  - 不得替代 `plannedStartAt` / `plannedEndAt`

## 6. Path And Schema Freeze Result

- app-facing paths 继续只通过既有 schema 引用承载这 3 项：
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
- server-facing paths 继续只通过既有 schema 引用承载这 3 项：
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
- shared schemas 更新为：
  - `ProjectCreateRequest`
  - `ProjectReadModel`

## 7. Explicit Non-goals

- 本轮不引入：
  - `预算区间`
  - `奖励金额`
  - `创建前附件主表单化`
- 本轮不 author：
  - persistence column
  - migration file
  - BFF / Server / Flutter 实现
- 本轮不改变：
  - `project/list`
  - workbench
  - upload binding truth

## 8. Stage Conclusion

- 本轮 contract freeze 结论是：
  - `areaSqm`、`buildingTypeRemark`、`scheduleDetail` 已具备进入后续 persistence freeze 的 contract 输入条件
  - `预算区间`、`奖励金额`、`创建前附件主表单化` 继续被挡在本轮之外

## 9. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目发布 Round B contract`。
  - 只放行 `areaSqm`、`buildingTypeRemark`、`scheduleDetail`。
  - 明确 `project/list` / workbench 当前不承担这 3 项 richer projection。
