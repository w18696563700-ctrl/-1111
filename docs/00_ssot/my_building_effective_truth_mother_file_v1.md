---
owner: Codex 总控
status: frozen
purpose: 汇总“我的楼”主线当前现行文书链吸收后的有效真源口径，作为正式版母文件供后续 gate、派工、复核与联调引用。
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - docs/00_ssot/new_workflow_v3_takeover_declaration.md
  - docs/00_ssot/seven_role_organization_freeze_v3.md
  - docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md
  - docs/00_ssot/my_building_asset_route_page_truth_owner_stage_status_table_v1.md
  - docs/00_ssot/my_building_mainline_v1_three_column_ruling.md
  - docs/00_ssot/my_building_round1_increment_dispatch.md
  - docs/00_ssot/my_building_next_unique_action.md
---

# 《我的楼有效真源整编母文件 V1》

## 1. 文书定位

- 本母文件只服务于：
  - `我的楼专项开发主线`
- 本母文件只做：
  - 当前现行文书链收口
  - 当前有效真源整编
  - 当前引用口径统一
- 本母文件不做：
  - 新 scope 放行
  - 新 package authoring
  - implementation unlock
  - 三栏裁决改写
  - Round 1 派工边界改写

## 2. 当前现行依据

- 当前现行工作流与主线依据：
  - [new_workflow_v3_takeover_declaration.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/new_workflow_v3_takeover_declaration.md)
  - [seven_role_organization_freeze_v3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/seven_role_organization_freeze_v3.md)
- 当前基线裁决依据：
  - [my_building_effective_truth_baseline_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md)
- 当前主线收口依据：
  - [my_building_asset_route_page_truth_owner_stage_status_table_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_asset_route_page_truth_owner_stage_status_table_v1.md)
  - [my_building_mainline_v1_three_column_ruling.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_mainline_v1_three_column_ruling.md)
- 当前执行与时序依据：
  - [my_building_round1_increment_dispatch.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_round1_increment_dispatch.md)
  - [my_building_next_unique_action.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_next_unique_action.md)

## 3. 当前有效真源整编结论

### 3.1 当前主线与角色前提

- 当前现行工作流已经切换为：
  - `新工作流 V3｜我的楼主线版`
- 当前固定执行编制已经冻结为：
  - `7 角色`
- 当前唯一主线已经冻结为：
  - `我的楼专项开发主线`
- 因此当前不得再把以下对象写成现行主导依据：
  - V2 workflow
  - `Round 0 全项目盘点轮`
  - `enterprise_hub` 旧主派工链

### 3.2 `我的楼` 当前正式角色

- `我的楼` 当前正式角色是：
  - compact current-user hub
  - 当前 actor 的私域入口聚合面
- `我的楼` 当前首层入口家族是：
  - 顶部个人摘要 handoff
  - `我的公司`
  - `认证与成员身份`
  - `我的项目`
  - `我的论坛`
  - `设置`
- `设置` 当前必须保持：
  - 首层最底部入口家族
- `我的楼` 当前不是：
  - 第二论坛首页
  - 第二工作台 dashboard
  - public author homepage
  - generic IM container
  - 所有对象的 truth owner

### 3.3 Package 1 当前吸收口径

- Package 1 当前仍然是：
  - organization-centered identity / qualification system
- `Server` 当前仍然是以下对象的唯一 truth owner：
  - user
  - session
  - organization
  - certification
  - review
  - device-security truth
- `BFF` 当前仍然只做：
  - shaping
  - auth consolidation
  - blocked-state copy
  - controlled failure normalization
- Flutter 当前仍然只消费：
  - `/api/app/*`
- admin review 当前仍然只走：
  - `/server/admin/*`
- Package 1 当前正式状态仍然是：
  - docs-frozen
  - implementation No-Go
- 因此当前不得把 Package 1 写成：
  - runtime fully open
  - full submit/resubmit center 已全面开放
  - 当前已自动纳入 release-ready

### 3.4 `我的项目` 当前吸收口径

- `我的楼 -> 我的项目` 已成立。
- `我的项目` 当前正式真义是：
  - 当前组织 scope 下的私域项目资产入口
  - 单项目继续处理入口
- `项目工作台` 当前仍然只是：
  - 摘要页
  - 导流页
  - 最近项目上下文页
- `我的项目` 与 `项目工作台` 当前不得混同。
- `我的项目` 列表当前正式冻结为：
  - `进行中`
  - `历史项目`
- 单项目当前正式冻结为：
  - `publicProject`
  - `privateProgress`
- `plannedEndAt` 当前只代表：
  - 计划结束时间
- `plannedEndAt` 当前不代表：
  - 正式完结
  - `待评价`
  - `已评价`
- `待评价 / 已评价` 当前只允许挂在：
  - 正式完结之后

### 3.5 owner 口径

- `profile` 当前是：
  - `我的楼`
  - `我的公司`
  - `认证与成员身份`
  - `我的项目` 首层 handoff
  - `我的论坛`
  - `设置`
  的 entry-side building owner
- `profile` 当前不是：
  - project truth owner
  - forum public truth owner
  - order / contract / fulfillment truth owner
- `我的项目` 的 truth owner 当前仍在：
  - `Server.project`
  - order / contract / fulfillment / acceptance / dispute / rating 的既有 canonical truths
- `我的论坛` 的 truth owner 当前仍在：
  - `Server.forum`

### 3.6 当前阶段状态与执行关系

- `我的楼 compact hub` 当前状态是：
  - boundary 已冻结
  - frontend surface 已冻结
- Package 1 当前状态是：
  - docs-frozen
  - implementation No-Go
- `我的项目` 当前状态是：
  - truth freeze
  - contract freeze
  - persistence migration freeze
  - backend-BFF implementation freeze
  - frontend consumption freeze
- 上述 `我的项目` 结论当前只表示：
  - 该子链已经形成可被 Round 1 引用的实现边界
  - 不等于本母文件正在单独放行实现
- 当前真正可执行的边界仍然只以：
  - [my_building_round1_increment_dispatch.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_round1_increment_dispatch.md)
  为准
- 当前唯一动作与后续进入顺序仍然只以：
  - [my_building_next_unique_action.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_next_unique_action.md)
  为准

## 4. 当前只可按既有裁决引用的对象

### 4.1 本轮必做对象

- 以下对象当前只能按既有三栏裁决继续引用：
  - `我的楼` 首层 compact hub 语义对齐
  - `我的楼 -> 我的项目` 入口语义与 handoff
  - `我的项目` list/detail 的 owner 收口
  - `my-project` server presenter 语义补齐
  - `my-project` BFF shaping 与错误归一复核
  - `my/projects` projection drift 修复
  - `我的公司 / 认证 current / 登录入口` 与 `我的楼` 首层关系对齐
  - `我的论坛` 的 bounded me-assets 边界维持

### 4.2 本轮冻结占位对象

- 以下对象当前只允许继续按既有冻结占位裁决引用：
  - organization create / join / switch happy path
  - device list / revoke 真正 fully open
  - certification submit / resubmit 完整 happy path
  - `我的项目` 深层 CTA 矩阵
  - `我的项目` 正式附件列表
  - `profile/governance` 风控治理中心

### 4.3 战略保留对象

- 以下对象当前只允许继续按既有战略保留裁决引用：
  - `我的楼` public author homepage
  - `我的楼` 第二论坛首页化
  - `我的楼` 第二工作台 dashboard 化
  - person-first 第二套 identity / certification truth
  - hidden buildings visible 化
  - live / geo / map 深能力落地
  - `enterprise_hub` 抢回默认主线

## 5. 当前明确不代表的事项

- 本母文件不代表：
  - `我的楼` 已进入 runtime fully open
  - `我的楼` 已获得整体 implementation unlock
  - Package 1 已可直接实现
  - `我的项目` 已自动带出正式附件列表
  - `我的楼` 已取得 project/forum public truth ownership
  - hidden buildings 已开放
  - 三栏裁决已被重写
  - Round 1 派工边界已被重写

## 6. 当前阅读顺序

1. 先读 [new_workflow_v3_takeover_declaration.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/new_workflow_v3_takeover_declaration.md)。
2. 再读 [seven_role_organization_freeze_v3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/seven_role_organization_freeze_v3.md)。
3. 再读 [my_building_effective_truth_baseline_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md)。
4. 再读本母文件：[my_building_effective_truth_mother_file_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_effective_truth_mother_file_v1.md)。
5. 再读 [my_building_asset_route_page_truth_owner_stage_status_table_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_asset_route_page_truth_owner_stage_status_table_v1.md)。
6. 再读 [my_building_mainline_v1_three_column_ruling.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_mainline_v1_three_column_ruling.md)。
7. 再读 [my_building_round1_increment_dispatch.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_round1_increment_dispatch.md)。
8. 最后读 [my_building_next_unique_action.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_next_unique_action.md)。

## 7. Formal Conclusion

- 当前正式结论如下：
  - 本母文件现已完成正式版收口
  - 当前现行依据已经收束到 V3 takeover、七角色、基线裁决、总表、三栏裁决、Round 1 派工、next unique action 这条文书链
  - `我的楼`、Package 1、`我的项目` 的有效真源口径已统一
  - 本母文件只负责收口，不改写三栏裁决，不改写 Round 1 派工边界，也不授予 implementation unlock
