---
title: Content Safety Subpackage Dispatch Preconditions
status: frozen
owner: Codex Control
scope: docs-only
created_at: 2026-04-07
---

# 内容安全子包派工前置条件单

## 1. Purpose

本文件冻结内容安全 P0 子包派工前置条件。

在这些前置条件满足前，不允许后端、BFF、前端、结果校验、联动发布进入执行。

## 2. Required Completed Documents Before Implementation

任何实施线程开工前，必须先完成并经总控复核：

1. 《内容安全治理母版 V1 控制包定位单》
2. 《内容安全 P0 docs-only bundle freeze》
3. 《内容安全 P0 实施顺序锁定单》
4. 《Profile Safety P0 状态机补充冻结单》
5. 《内容安全 P0 运行时依赖裁决单》
6. 《内容安全子包派工前置条件单》
7. 五份 P0 子包冻结单：
   - Profile Safety P0 冻结单
   - Forum Report P0 冻结单
   - Block P0 冻结单
   - Admin Review P0 冻结单
   - Safety Audit P0 冻结单

## 3. Role Preconditions

### 文书冻结线程

允许动作：

- 写 P0 五份子包冻结单。
- 对齐能力追踪总表编号。
- 写纳入 / 排除 / 延期 / 禁止越界项。

禁止动作：

- 写代码。
- 代替总控做实施放行。
- 直接宣称任一能力已完成。

### 后端线程

当前状态：暂不允许开工。

开工前必须等待：

- 对应子包冻结单完成。
- 总控复核通过。
- 后端执行口令单独发出。

### BFF 线程

当前状态：暂不允许开工。

开工前必须等待：

- Server truth 边界完成。
- 对应 BFF surface 边界冻结完成。
- 总控单独发出 BFF 执行口令。

### 前端线程

当前状态：暂不允许开工。

开工前必须等待：

- 对应 app-facing contract 或 BFF surface 边界完成。
- 前端 surface 冻结完成。
- 总控单独发出前端执行口令。

### 结果校验线程

当前只允许准备独立复核检查表。

不得执行：

- 代码验收。
- 发布判断。
- 用回执代替证据。

### 联动发布线程

当前不允许进入发布准备判断。

必须等待：

- 子包实现完成。
- 独立复核通过。
- 总控允许进入联动发布准备。

## 4. Required Subpackage Freeze Outputs

五份 P0 子包冻结单必须至少包含：

- 本包目标
- 输入文书
- 能力编号映射
- 明确纳入项
- 明确不纳入项
- 保留在母版中的延期项
- runtime 依赖
- 禁止越界项
- 上游依赖
- 下游交接对象
- 验收原则
- 独立复核要求

## 5. Veto Gates

直接 veto：

- 后端在五份子包冻结单完成前开工。
- BFF 在 Server truth / BFF surface 未冻结前开工。
- 前端在 app-facing surface 未冻结前开工。
- 结果校验把执行回执当最终验收。
- 联动发布跳过独立复核。
- 任一线程把 AI 写成 P0 runtime 依赖。
- 后端仅云端 / BFF 仅云端包在 execution-environment preflight 未通过前 author implementation prompt。
- 任一包 correction 超过一轮后仍未满足环境或证据要求，却继续重复发同类 correction prompt。

## 5A. Execution Environment Preflight And Correction Limit

后续所有内容安全包，只要执行角色为 `后端 Agent（仅云端）` 或 `BFF Agent（仅云端）`，必须先完成 execution-environment preflight。

preflight 通过前，不允许 author implementation prompt。

preflight 至少必须确认：

- `hostname`
- `pwd`
- current `cwd`
- `/srv/apps/.../current` 的真实路径
- `node` 版本
- `npm` 版本
- 当前执行位是否真的在云端工作区

每个包最多只允许一轮 correction。

若 correction 后仍不满足环境或证据要求，不得继续重复发同类纠偏口令，必须立刻升级为：

`execution-environment blocker disposition judgment`

## 6. Current Stage Decision

当前允许：

- Go for 文书冻结线程 authoring 五份 P0 子包冻结单。

当前不允许：

- No-Go for backend implementation。
- No-Go for BFF implementation。
- No-Go for frontend implementation。
- No-Go for Admin implementation。
- No-Go for result verification。
- No-Go for release-prep。

## 7. Next Unique Action

将 docs-only bundle freeze 与五份冻结单派给文书冻结线程先完成，在冻结单全部完成并经总控复核前，不允许任何实施线程开工。
