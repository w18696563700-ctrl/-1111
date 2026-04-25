---
owner: Codex 总控
status: active
purpose: >
  Submit the Day-1 stage gate checklist for `项目名称申请查看`, checking whether
  the repo may proceed from docs freeze into the next implementation-dispatch
  steps without violating the existing project and messages guardrails.
layer: L0 SSOT
updated_at: 2026-04-24
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/02_backend/project_name_access_request_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_name_access_request_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_name_access_request_frontend_consumption_freeze_addendum.md
---

# 《项目名称申请查看 Day-1 阶段门禁核查表》

## 1. Scope

- 当前对象：
  - `项目名称申请查看`
- 本门禁只服务于：
  - Day-1 文书冻结完成后的阶段裁决
- 本门禁不代表：
  - 直接上线
  - release-prep

## 2. Passed Gates

- 文书链完整性 gate：
  - passed
  - `L0/L2/L3/L4/L5` 五层 Day-1 文书已冻结
- 项目公域读面基础 gate：
  - passed
  - `project/list`、`project/detail` 已有真实运行基础
- 首页红框字段可用 gate：
  - passed
  - live probe 已确认 `cityName / areaSqm / plannedStartAt` 可从 list 读到
- 架构边界 gate：
  - passed
  - `Flutter -> BFF -> Server` 单通道不变
- 无第二项目可见性 carrier gate：
  - passed
  - Day-1 文书未新造 `visibility / displayStatus`

## 3. Failed Gates

- 公域真实项目名泄露 gate：
  - failed
  - live cloud `project/list` / `project/detail` 当前仍向未授权 non-owner 返回真实名称
- `message/index` 可复用 gate：
  - failed
  - live cloud 仍为 `404`
- messages bounded extension runtime gate：
  - failed
  - 当前 contracts/mainline 只正式承认 bid-thread 语义
- implementation completion gate：
  - failed
- integration gate：
  - failed

## 4. Veto Gates

- 不得以前端遮罩替代 Server/BFF 真遮罩
- 不得复用旧 `message/index`
- 不得发明第二套聊天状态机
- 不得把项目名称申请写成新的项目 visibility state
- 不得在真实名称仍下发时宣称功能成立

## 5. Stage Go / No-Go Decision

- `Go` for：
  - `Package A` Flutter-only 实现：
    - 首页红框 `城市 / 面积 / 进场时间`
  - `Package B` Server/BFF 实现 authoring：
    - 公域项目名遮罩
    - `ProjectNameAccessRequest`
    - 申请 / 审批命令面
- `No-Go` for：
  - 消息楼会话化承接的直接实现
  - 在未复签 bounded extension 前实现 `project_name_access_thread`
  - 前端先行完成整链功能
  - 直接联调上线
  - generic chat / generic DM 扩面

## 6. Current Gate Meaning

- 当前允许的真实含义：
  - 可以进入首页红框改版
  - 可以进入后端 / BFF 的项目名遮罩与申请真值实现
  - 可以继续做消息楼会话化承接的 bounded review
- 当前不允许的真实含义：
  - 不能只改 Flutter 就宣布项目名称已受控
  - 不能把会话化承接做成新聊天产品

## 7. Next Unique Action

- 下一步唯一动作集合：
  - 前端落首页红框
  - Server 落 `ProjectNameAccessRequest`
  - BFF 落公域遮罩与命令面
  - 之后再进入消息楼 bounded extension 复签
