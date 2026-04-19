# Enterprise Workbench Live Public Surface And Draft Preview Separation Truth Ruling Addendum

## Date
- 2026-04-19

## Scope
- `apps/mobile`
- exhibition enterprise hub published-change workbench top surface only

## Truth Ruling
- 已进入 `published-change` 的企业展示工作台，首屏公开展示真值只认 `live / approved public detail`。
- `current change` 只作为待发布变更稿存在，不得继续伪装成与展览楼公开详情同一版本。
- 工作台顶部必须把两种真值拆开：
  - `线上公开展示`
  - `当前变更稿预览`
- `线上公开展示` 的案例图片、案例状态和展览楼公开详情必须对齐。
- `当前变更稿预览` 默认折叠，只在用户主动展开时显示。

## Non Goals
- 不改 server / bff 公开详情真值。
- 不改案例提交流程。
- 不把 `draft` 自动推到公开详情。
