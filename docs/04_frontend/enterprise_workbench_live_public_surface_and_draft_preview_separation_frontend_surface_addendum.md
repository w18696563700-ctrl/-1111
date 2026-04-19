# Enterprise Workbench Live Public Surface And Draft Preview Separation Frontend Surface Addendum

## Date
- 2026-04-19

## Frontend Surface Rule
- 顶部顺序：
  - `已发布展示变更`
  - `线上公开展示`
  - `当前变更稿预览`
- `线上公开展示` 使用 public detail surface，案例图片与展览楼详情一致。
- `当前变更稿预览` 继续使用 published-change projection，但默认折叠。
- `案例库` 继续回读当前展示档下已保存案例，不承担公开详情预览职责。

## UX Intent
- 首屏只暴露一条公开真值。
- draft 仍可核对，但不能继续和公开详情混成同一层。
