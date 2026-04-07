---
owner: Codex 总控
status: frozen
purpose: 定义“我的楼”主线 Round 1 的增量派工边界、角色任务、允许目录、非目标与联调进入条件，作为下一轮执行线程唯一派工依据。
layer: L0 SSOT
freeze_date_local: 2026-04-05
---

# 《我的楼 Round 1 增量派工单》

## 1. 派工效力

- 本派工单只服务于：
  - `我的楼专项开发主线`
- 本派工单是：
  - 下一轮执行线程的唯一派工依据
- 本派工单不是：
  - release approval
  - implementation unlock 的无限外延许可
  - 其他板块并行扩 scope 的理由

## 2. Round 1 唯一目标

- Round 1 唯一目标冻结为：
  - 在不推倒重来的前提下，基于现有真源与现有资产，把 `我的楼 -> 我的项目 -> Package 1 bounded consumption` 收束成一条 owner 清晰、边界清晰、可被独立复核的主线闭环

## 3. 上游输入

- 执行角色必须带着以下上游文书进入施工：
  - `docs/00_ssot/new_workflow_v3_takeover_declaration.md`
  - `docs/00_ssot/seven_role_organization_freeze_v3.md`
  - `docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md`
  - `docs/00_ssot/my_building_effective_truth_mother_file_v1.md`
  - `docs/00_ssot/my_building_asset_route_page_truth_owner_stage_status_table_v1.md`
  - `docs/00_ssot/my_building_mainline_v1_three_column_ruling.md`
  - Package 1、`我的项目`、`flutter_screen_map`、`source_of_truth_map` 的现有上游真源

## 4. 总控文书冻结任务

- 当前只允许输出：
  - 母文件正式版收口
  - 总表正式版收口
  - 阅读顺序
  - 索引与真源挂图
  - 引用链修订清单
- 当前不允许输出：
  - 新 scope
  - 新 implementation unlock
  - 对三栏裁决表的越权改写
  - 对派工边界的越权改写

## 5. 前端 Agent 任务

### 5.1 环境

- 只允许在本地执行
- 只允许改动：
  - `apps/mobile/**`
  - 如确有必要，允许 very small mechanical touch 到本地主消费投影引用点

### 5.2 当前必须完成

- 对齐 `我的楼` 首层 compact hub 语义、入口顺序与 copy
- 确认 `我的公司 / 认证与成员身份 / 我的项目 / 我的论坛 / 设置` 的首层关系与 handoff 不漂移
- 继续沿用 `ExhibitionRoutes.myProjectList` 与 `ExhibitionRoutes.myProjectDetail`
- 对齐 `我的项目` list/detail 的页面语义：
  - `进行中 / 历史项目`
  - `publicProject + privateProgress`
  - `plannedEndAt != 正式完结`
- 保持 `组织 create / join` 与 `会话与设备` 的受控占位口径
- 隧道联调时只通过：
  - `http://127.0.0.1:8080`

### 5.3 当前禁止

- 禁止在本地写 `apps/bff/**` 或 `apps/server/**`
- 禁止把 `我的项目` 改成 `项目工作台`
- 禁止把 `我的楼` 做成第二论坛首页或第二 dashboard
- 禁止把占位页文案改成“已开放完成”

## 6. 后端 Agent 任务

### 6.1 环境

- 只允许在云端执行
- 允许改动面冻结为：
  - `apps/server/src/modules/my_project/**`
  - 如为读时聚合接线所必需，允许 minimal touch 到既有只读 query / presenter wiring

### 6.2 当前必须完成

- 审核并沿用现有 `apps/server/src/modules/my_project/**` 资产
- 保持 `current organization scope` 过滤
- 将 `MyProjectPresenter` 从默认 `privateProgress` 占位补齐为读时聚合既有真相
- 保持 `publicProject` 继续复用既有公域项目 read model
- 保持不新增：
  - my-project-only table
  - my-project-only snapshot
  - second state machine
  - migration

### 6.3 当前禁止

- 禁止新建第二套 `my-project` truth
- 禁止把 `plannedEndAt` 直接当正式完结
- 禁止把评价状态自动化推导成已评价
- 禁止把 admin review、governance 或 Package 1 truth 混入 `my-project`

## 7. BFF Agent 任务

### 7.1 环境

- 只允许在云端执行
- 允许改动面冻结为：
  - `apps/bff/src/routes/my_project/**`
  - 如为 route registry 必需，允许 minimal wiring touch

### 7.2 当前必须完成

- 审核并沿用现有 `apps/bff/src/routes/my_project/**` 资产
- 保持 `GET /api/app/my/projects` 与 `GET /api/app/my/projects/{projectId}` 只做 app-facing shaping
- 与 `openapi.yaml`、`MyProjectListResponse`、`MyProjectDetailReadModel` 对齐
- 统一 `401 / 403 / 404` 的 app-facing 错误归一
- 修复依赖 generated projection 时对 `my/projects` path family 的滞后问题，但不得改写上位 truth

### 7.3 当前禁止

- 禁止把 `BFF` 写成 `my-project` truth owner
- 禁止新增 business tags、第二套状态名、第二套进度真相
- 禁止借由 `my-project` 扩到 admin review 或其他板块

## 8. 结果校验 Agent 任务

- 必须独立复核以下事项：
  - 是否重复建设已有页面 / 路由 / 源码模块
  - 是否把 `我的楼`、`我的项目`、`项目工作台` 混同
  - 是否把 formal surface / docs-frozen / runtime fully open 混写
  - 是否把入口 owner 写成 truth owner
  - 是否把 `plannedEndAt` 当正式完结
  - 是否把 Package 1 docs-only freeze 写成 implementation unlock
  - 是否把 `BFF` 写成 truth owner
- 只允许输出：
  - `通过`
  - `有条件通过`
  - `不通过`

## 9. 联调发布 Agent 介入条件

- 以下条件未同时满足前，不得介入：
  - 总控明确放行
  - 结果校验通过
  - 本地前端 + 云端 BFF/后端 的真实拓扑证据齐全
  - 隧道与运行态访问证据齐全
  - 回滚方案齐全
- 联调发布当前只允许验证：
  - 主线闭环
  - 运行态证据
  - 门禁状态
- 当前不允许：
  - 借联调发布新增 scope
  - 没有复核就抢先出发布口径

## 10. 非目标

- 不做 hidden buildings visible 化
- 不做 `我的楼` public author homepage
- 不做 `我的楼` 第二 dashboard
- 不做组织 create/join/switch 完整办理闭环
- 不做 device-security 完整 fully open
- 不做 `我的项目` 正式附件列表
- 不做 Package 4 治理中心扩张
- 不做 enterprise_hub 抢回主线

## 11. Formal Conclusion

- 当前正式结论如下：
  - `前端` 负责本地 `我的楼` 与 `我的项目` 消费面对齐
  - `后端` 负责云端 `my-project` read truth 补齐
  - `BFF` 负责云端 `my-project` app-facing shaping 与 projection drift 修复
  - `总控文书冻结` 先收紧文书，不扩 scope
  - `结果校验` 独立复核后，`联调发布` 才可能介入
  - 本派工单不自动等于 release 或无限 implementation unlock
