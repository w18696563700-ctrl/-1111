---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum truth for showing public project publish time on the
  exhibition home project recommendation card.
layer: L0 SSOT
freeze_date_local: 2026-04-30
---

# Project List Published Time Home Card Truth Freeze Addendum

## 1. Current Minimum Closed Loop

本轮只把 `GET /api/app/project/list.items[]` 的项目发布时间投影到展览首页项目卡片。

最小闭环：

1. Server 继续以 `ProjectEntity.publishedAt` 作为公开项目发布时间真源。
2. Server list item 输出 `publishedAt`。
3. BFF 只校验并透传 `publishedAt`，不重算、不用 `createdAt` 代替。
4. Flutter 首页项目卡片在底部动作行左侧显示发布时间。

## 2. Explicit Non-goals

本轮不做：

1. 不新增项目排序规则；列表仍以后端既有排序为准。
2. 不新增筛选条件。
3. 不展示发布方身份、组织名或项目创建时间。
4. 不改项目详情、我的项目、竞标、支付或消息楼状态机。
5. 不把 `createdAt` 当作公开发布时间。

## 3. Display Rule

Flutter 首页显示文案：

- 有 `publishedAt`：`发布 M月D日 HH:mm`
- 无可用 `publishedAt`：隐藏该行，不本地伪造时间

## 4. Strategy Judgment

- 更稳：用 Server 已有 `publishedAt` 真源，BFF 只透传，Flutter 只显示。
- 更省成本：不新增接口、不新增状态、不改排序。
- 更适合当前阶段：首页补一个轻量信息点，不扩成项目工作台。
- 风险更大：用 `plannedStartAt` 或 `createdAt` 冒充发布时间。
