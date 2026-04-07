---
owner: Codex 总控
status: frozen
purpose: 接管新工作流 V3，废止旧工作流在角色、派工链、回执链、阶段定义与主线优先级上的现行效力，同时保留旧资产为当前项目基线。
layer: L0 SSOT
freeze_date_local: 2026-04-05
supersedes:
  - docs/00_ssot/new_workflow_v2_takeover_declaration.md
  - docs/00_ssot/team_organization_freeze_round0.md
  - docs/00_ssot/current_active_implementation_candidate_inventory_addendum.md
  - docs/00_ssot/enterprise_hub_v1_primary_implementation_increment_dispatch_addendum.md
---

# 《新工作流 V3 接管声明》

## 1. 接管效力

- 自本文件冻结起，项目当前现行工作流改为：
  - `新工作流 V3｜我的楼主线版`
- 本接管只废止旧工作流在以下事项上的现行执行效力：
  - 固定角色数量
  - 派工链
  - 回执链
  - 验收链
  - 阶段定义
  - 主线优先级
- 本接管不废止旧工作流下已经形成且仍有效的项目资产。

## 2. 旧资产保留规则

- 下列旧资产继续作为当前项目基线的一部分保留：
  - 已完成且仍有效的代码
  - 已存在页面与路由
  - 已冻结接口与 contracts
  - 已存在数据库结构、状态机、脚本、部署配置
  - 已形成的门禁、回执、closure、review、索引文书
- 因旧流程过时，不得得出以下错误结论：
  - 旧代码无效
  - 旧页面作废
  - 旧接口必须推倒重写
  - 旧文书不得再引用
- 当前明确禁止：
  - 重复建设
  - 平行重做
  - 推倒重来
  - 以“流程更新”为由抹掉旧资产

## 3. 当前现行协作编制

- 本项目当前固定为 `7 角色工作流`：
  1. 总控
  2. 总控文书冻结
  3. 前端 Agent（仅本地）
  4. 后端 Agent（仅云端）
  5. BFF Agent（仅云端）
  6. 结果校验 Agent
  7. 联调发布 Agent
- `总控文书冻结` 自本文件起视为独立固定角色，不再按旧流程写成“总控内部辅助动作”。
- 任何旧文书中关于 `6 角色`、`总控内部代行文书冻结`、`Round 0 全员只盘点` 的口径，如与本文件冲突，一律不再作为现行依据。

## 4. 当前唯一主线

- 当前唯一主执行主线正式冻结为：
  - `我的楼专项开发主线`
- 当前主线含义写死如下：
  - `我的楼` 是 compact current-user hub
  - `我的楼` 是当前 profile building 下的唯一主推进对象
  - `我的楼 -> 我的项目` 是当前主线的一部分
  - `我的楼 -> 我的公司 / 认证与成员身份 / 我的论坛 / 设置` 是当前主线的受控组成
- 以下对象当前不得抢占主线：
  - 全项目总盘点
  - enterprise_hub 旧主派工链
  - 论坛之外扩容位
  - 任何未获总控单独解冻的并行包

## 5. 当前阶段定义

- 当前阶段不再是旧版：
  - `Round 0 全项目盘点轮`
- 当前阶段正式改为：
  - `我的楼主线推进阶段`
- 当前阶段固定顺序为：
  1. 总控冻结边界与主线唯一目标
  2. 总控文书冻结整编当前有效真源
  3. 总控输出母文件、总表、三栏裁决表、增量派工单
  4. 执行角色按主线施工
  5. 结果校验独立复核
  6. 联调发布在总控放行后介入

## 6. 当前不变基础

- formal truth 仍只在 `docs/`
- `docs/00_ssot -> docs/01_contracts -> docs/02_backend / 03_bff / 04_frontend / 05_admin -> apps/** -> packages/**` 的优先级不变
- `Flutter App -> BFF -> Server` 的架构边界不变
- visible buildings 仍只允许：
  - `exhibition`
  - `messages`
  - `profile`
- hidden buildings 仍保持：
  - `renovation`
  - `custom_furniture`
- 本地 / 云端拓扑不变：
  - 前端本地
  - BFF 与后端云端
  - 隧道只用于访问验证、联调验证、运行态取证

## 7. 当前明确 No-Go

- 本接管声明本身不代表：
  - 已放行实现
  - 已可直接上线
  - 无需再冻结
  - 已自动纳入全部 runtime
- 当前仍然明确禁止：
  - 把 docs-only freeze review 写成 implementation unlock
  - 把 formal surface 写成 runtime fully open
  - 把入口 owner 写成 truth owner
  - 让总控重新退化成纯搬运或纯归档角色

## 8. 旧文书保留但降级说明

- 以下旧文书继续保留为有效项目资产与历史裁决背景：
  - `docs/00_ssot/new_workflow_v2_takeover_declaration.md`
  - `docs/00_ssot/team_organization_freeze_round0.md`
  - `docs/00_ssot/current_active_implementation_candidate_inventory_addendum.md`
  - `docs/00_ssot/enterprise_hub_v1_primary_implementation_increment_dispatch_addendum.md`
- 但它们在以下事项上不再具有当前主导效力：
  - 角色数量
  - 当前阶段定义
  - 当前主线优先级
  - 下一轮默认派工对象

## 9. Formal Conclusion

- 当前正式结论如下：
  - `旧流程过时，但旧资产保留`
  - `当前现行工作流 = 新工作流 V3`
  - `当前固定角色数 = 7`
  - `当前唯一主线 = 我的楼专项开发主线`
  - `当前阶段 != 全项目总盘点轮`
  - `本文件只完成接管，不自动授予实现或上线许可`
