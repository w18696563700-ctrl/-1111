# Enterprise Workbench Live Public Surface And Draft Preview Separation Contract Compatibility Addendum

## Date
- 2026-04-19

## App Facing Contract Freeze
- published-change workbench 可以额外读取公开详情接口：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType={boardType}`
- published-change workbench 顶部 surface contract 分成两块：
  - `线上公开展示` 读取 public detail
  - `当前变更稿预览` 读取 current-change projection
- `当前变更稿预览` 继续允许复用 detail layout，但必须带清晰 draft 语义，且默认折叠。

## Compatibility
- 不新增后端字段。
- 不修改 existing published-change canonical path。
- 仅调整 mobile 侧如何组合与展示现有 app-facing surface。
