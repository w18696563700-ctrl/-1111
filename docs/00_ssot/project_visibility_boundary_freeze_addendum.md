---
title: 项目可见性边界冻结单
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-04-10
purpose: >
  围绕项目主线，正式冻结“公域展示 / 私域承接 / owner 分流 /
  未来隐藏下架预留位”的边界，不展开支付，不改代码。
inputs_canonical:
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_pre_freeze_addendum.md
  - docs/00_ssot/exhibition_workbench_summary_baseline_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
---

# 项目可见性边界冻结单

## 1. 正式冻结结论

本单正式冻结：

- `project/list` 与 `project/detail` 属于项目主线的公域展示面。
- `my/projects`、`my/projects/{id}`、`exhibition/workbench` 属于项目主线的私域承接面。
- `owner` 与 `non-owner` 可共享同一公域 `project/detail` 对象，但只能通过
  `viewerProjectRelation` 做最小分流，不得把公域详情膨胀成私域控制台。
- 当前项目主线不存在独立“下架 / 隐藏 / 冻结展示”真源。
- 当前只有：
  - `project.state` 负责项目生命周期
  - `publishedAt` 负责项目是否已物化进入公域展示面
- 未来若要承接支付 / 押金 / 佣金，不得继续借用 `state`、`summary`、
  `viewerProjectRelation` 或 workbench 布尔值伪装可见性治理，必须新增独立 carrier 并完成新一轮冻结。

## 2. 公域与私域的正式定义

### 2.1 公域

项目主线当前公域只包含两类对象：

- `GET /api/app/project/list`
- `GET /api/app/project/detail`

公域的正式含义是：

- 面向未登录与可选登录用户开放的项目展示面
- 目标是发现项目、查看项目最小共享详情、完成 owner-aware handoff
- 不承载私域项目资产、私域进度、项目管理矩阵、订单链、合同链、履约链

### 2.2 私域

项目主线当前私域只包含三类对象：

- `GET /api/app/my/projects`
- `GET /api/app/my/projects/{projectId}`
- `GET /api/app/exhibition/workbench`

私域的正式含义是：

- 仅面向已登录且命中当前组织 scope 的私域承接面
- 用于接住 owner 项目资产、私域项目进度、私域摘要入口
- 不回流定义公域展示 truth
- 不得反向成为 `project/detail` 的替代

## 3. owner / non-owner 在公域 detail 的冻结边界

### 3.1 owner 在公域 detail 里能看到什么

- 同一份 shared `ProjectReadModel`
- 最小 `viewerProjectRelation = owner` carrier
- 基于 owner relation 的 handoff 入口
- 当前项目的共享展示信息：
  - 标题
  - 预算
  - 地点
  - 状态
  - 摘要
  - 详情说明等 contract admitted fields

### 3.2 owner 在公域 detail 里不能看到什么

- raw `creator_user_id`
- raw `organization_id`
- `manageActions`
- `canDelete`
- 私域项目进度详情
- `my/projects` 列表信息
- `workbench` summary containers
- 订单 / 合同 / 履约 / 争议链 detail

owner 在公域详情里只能得到“这是你的项目”的最小 relation handoff，
不能把该页面解释成项目私域后台。

### 3.3 non-owner 在公域 detail 里能看到什么、能继续什么

- 同一份 shared `ProjectReadModel`
- 最小 `viewerProjectRelation = non_owner` carrier
- 当前公域展示字段
- 非 owner 继续路径：
  - 查看项目详情
  - 在当前边界下继续竞标或进入竞标提交链

### 3.4 non-owner 在公域 detail 里不能看到什么

- owner 专属管理入口
- 私域项目资产与私域进度
- 私域 workbench 摘要与私域 project chain
- raw ownership identifiers

## 4. `viewerProjectRelation` / `project/detail` / `my/projects` / `workbench` 的关系

- `viewerProjectRelation`
  - 只回答“当前 viewer 与当前项目的关系”
  - 只允许 `owner | non_owner`
  - 不是生命周期字段
  - 不是公私域可见性字段
  - 不是动作矩阵字段

- `project/detail`
  - 是共享公域详情面
  - 可选登录时允许 relation-aware handoff
  - 不是私域项目资产入口
  - 不是私域进度聚合器

- `my/projects`
  - 是当前组织 scope 下的私域项目资产列表
  - 正式承接 owner 项目的 ongoing / historical 分组
  - 不承担公域发现

- `workbench`
  - 是当前私域 continuation summary
  - 只承接最小摘要和路由入口
  - 不是项目真源
  - 不是第二项目工作台状态机
  - 不是 `my/projects` 的替代

## 5. 公域 / 私域 / owner 分流边界表

| 面 | 对象 | 当前可见对象 | 当前允许承接 | 当前明确禁止 |
|---|---|---|---|---|
| 公域 | `project/list` | 已进入公域展示面的项目列表项 | 发现项目、进入 detail | 私域资产、私域进度、管理矩阵 |
| 公域 | `project/detail` | shared `ProjectReadModel` + `viewerProjectRelation` | owner-aware handoff；non-owner 继续竞标 handoff | raw ownership ids、manageActions、私域进度、订单合同履约 detail |
| 公域中的 owner 分流 | `project/detail` with `viewerProjectRelation=owner` | 共享项目详情 + owner relation | 进入“管理当前”或进入私域承接面 | 把 detail 膨胀成私域控制台 |
| 公域中的 non-owner 分流 | `project/detail` with `viewerProjectRelation=non_owner` | 共享项目详情 + non-owner relation | 保持展示与继续竞标 | 访问 owner 管理入口或私域资产 |
| 私域 | `my/projects` | 当前组织 scope 的项目资产列表 | ongoing / historical 项目承接 | 公域发现、展示全量项目池 |
| 私域 | `my/projects/{id}` | `publicProject + privateProgress` | 单项目私域继续处理 | 变成公域 detail 替代 |
| 私域 | `exhibition/workbench` | 四个 summary container 中的最小 continuation carriers | 打开项目池、创建项目、进入后续链入口 | 真源化项目状态、列表/历史控制台、第二工作台状态机 |

## 6. 当前存在 / 当前不存在 / 未来预留

| 分类 | 内容 |
|---|---|
| 当前存在 | `project.state` 作为项目生命周期 carrier |
| 当前存在 | `publishedAt` 作为项目已进入公域展示面的物化 carrier |
| 当前存在 | `viewerProjectRelation` 作为 owner / non-owner 最小 relation carrier |
| 当前存在 | `my/projects` 作为私域项目资产面 |
| 当前存在 | `my/projects/{id}` 作为单项目私域承接面 |
| 当前存在 | `exhibition/workbench` 作为私域摘要 continuation 面 |
| 当前不存在 | 独立项目 `visibility` truth |
| 当前不存在 | 独立项目 `displayStatus` truth |
| 当前不存在 | 独立项目 `hidden / unpublished / delisted / frozen_display` carrier |
| 当前不存在 | 独立“下架箱 / 隐藏池 / 冻结展示池”真源 |
| 当前不存在 | 因支付 / 押金 / 佣金触发的项目展示冻结真源 |
| 未来预留 | 项目级 `visibility` carrier |
| 未来预留 | 项目级 `displayStatus` 或等效展示治理 carrier |
| 未来预留 | 面向资金与风控链的“可展示 / 仅私域 / 展示冻结 / 下架”治理字段 |

## 7. 当前是否存在“下架 / 隐藏 / 冻结展示”真源

本单正式结论：

- 当前不存在项目级“下架 / 隐藏 / 冻结展示”真源。

补充说明：

- 当前项目主线只有 `publishedAt`
  - 它只足以表达“已发布并进入公域展示面”
- 当前项目主线没有独立 `visibility`
- 当前项目主线没有独立 `displayStatus`
- contract 中出现的 `displayStatus` 现阶段属于其他对象族，不得误认成项目可见性 carrier

因此当前正式禁止：

- 把 `state` 解释成隐藏 / 下架真源
- 把 `summary.stateLabel` 解释成可见性真源
- 把 `workbench.canOpenProjectPool` 之类布尔值解释成项目可见性真源
- 把 owner relation 解释成可见性真源

## 8. 未来若接支付 / 押金 / 佣金，项目可见性最少还需要补什么 carrier

若未来进入支付 / 押金 / 佣金主线，项目可见性最少需要补以下独立 carrier：

- 一个项目级展示治理字段
  - 用于区分：
    - 仍可公域展示
    - 仅私域可见
    - 公域隐藏
    - 展示冻结
- 一个与生命周期解耦的可见性判断位
  - 明确与 `project.state` 分离
- 一个与资金 / 风控链对接的冻结原因 carrier
  - 至少要能表达：
    - 风控冻结展示
    - 成交后展示策略切换
    - 押金或佣金阶段导致的可见性限制

本单不指定字段名，但正式要求：

- 新 carrier 必须落在 Server truth
- 不得先在 BFF 或前端偷做伪状态
- 不得复用 `summary`、`relation`、`workbench` 布尔值代替

## 9. 最小后续补丁建议

### P0

- 在 SSOT / contract 层补一条明确说明：
  - 当前项目主线不存在独立 `visibility / displayStatus` 真源
  - `publishedAt` 只负责进入公域展示面的物化，不承担未来隐藏下架语义

### P0

- 在 project detail、my-project、workbench 三条线的消费者说明中补齐：
  - 公域 detail 只做共享详情与 relation handoff
  - 私域承接只能进入 `my/projects` 或 `workbench`

### P1

- 若后续确实要做“下架 / 隐藏 / 冻结展示”，先出独立冻结单：
  - 新增项目可见性 carrier
  - 明确与 `state` 的职责分工
  - 明确公域与私域切换规则

### P1

- 在 owner-aware 相关文案中继续避免把“管理当前”误写成：
  - 已进入私域后台
  - 已拥有完整管理动作矩阵

## 10. 最终冻结口径

当前项目主线的可见性边界正式冻结为：

- 公域只包含：
  - `project/list`
  - `project/detail`
- 私域只包含：
  - `my/projects`
  - `my/projects/{id}`
  - `exhibition/workbench`
- owner / non-owner 只在公域 `project/detail` 中做最小 relation handoff
- 当前不存在独立项目级隐藏 / 下架 / 冻结展示真源
- 未来若进入资金链，可见性治理必须新增独立 carrier 并完成新冻结，不得偷复用现有字段
