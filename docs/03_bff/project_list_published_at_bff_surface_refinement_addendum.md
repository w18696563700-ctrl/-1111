---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF surface rule for passing project publish time through
  `GET /api/app/project/list`.
layer: L4 BFF
freeze_date_local: 2026-04-30
---

# Project List PublishedAt BFF Surface Refinement

## 1. Allowed Responsibility

BFF `GET /api/app/project/list` 只允许：

1. 从 Server `/server/projects` 读取 `publishedAt`。
2. 校验 `publishedAt` 为非空字符串。
3. 透传到 app-facing list item。

本规则只约束公域项目列表。`project/detail` 与 `project/edit` 仍沿用既有详情 read-model，允许草稿或非公域项目的
`publishedAt` 为空，不因此污染创建/编辑链路。

## 2. Forbidden Responsibility

BFF 不得：

1. 用 `createdAt` 回填发布时间。
2. 从 `plannedStartAt` 推导发布时间。
3. 自行重排项目列表。
4. 新增第二套项目发布状态。

## 3. Failure Rule

若 Server list item 缺少 `publishedAt`，BFF read-model 必须 fail closed，避免首页显示伪造发布时间。
