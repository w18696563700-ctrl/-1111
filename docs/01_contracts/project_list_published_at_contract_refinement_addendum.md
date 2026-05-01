---
owner: Codex 总控
status: frozen
purpose: >
  Refine the `GET /api/app/project/list` contract so public project list items
  carry their canonical publish time for home-card display.
layer: L2 Contracts
freeze_date_local: 2026-04-30
---

# Project List PublishedAt Contract Refinement

## 1. Scope

本文件只补充 `GET /api/app/project/list.items[]`：

- `publishedAt: string`

## 2. Field Rule

`publishedAt`:

- app-facing 字段
- ISO date-time 字符串
- 真源为 Server `ProjectEntity.publishedAt`
- 仅表示项目进入公域公开列表的发布时间

## 3. Non-goals

不新增：

- `createdAt`
- 发布时间筛选
- 时间排序 contract
- 项目详情扩展工作台

## 4. Response Minimum

`ProjectShowcaseListItemReadModel` 在既有字段基础上补充：

```json
{
  "projectId": "string",
  "projectNo": "string",
  "title": "string",
  "publishedAt": "2026-04-30T08:15:00.000Z"
}
```
