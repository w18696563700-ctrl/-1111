---
owner: Codex 总控
status: draft
purpose: Freeze the mandatory receipt-filing rule for enterprise_hub V1 implementation so result verification starts only after role-specific execution evidence has been archived as documents.
layer: L0 SSOT
---

# 展链库 V1 实现回执落盘规则

## 1. Scope
- 本规则只适用于：
  - `enterprise_hub V1`
- 本规则只解决：
  - 实现结果校验前置证据缺失
  - 实现回执未落盘导致的独立复核失败
- 本规则不代表：
  - implementation unlock 新增放行
  - release-prep 放行
  - release execution 放行

## 2. Current Problem
- 当前已出现的正式失败原因是：
  - `implementation evidence incomplete`
- 具体缺口是：
  - 缺少后端 Agent 回执
  - 缺少 BFF Agent 回执
  - 缺少前端 Agent 回执
- 因此当前必须冻结一条刚性规则：
  - 每一次执行轮结束后，必须先回执落盘，再进入结果校验
- 同时必须修正一条已暴露的拓扑错配：
  - 后端与 BFF 在云端执行
  - 不能再默认要求后端与 BFF 回执必须先出现在本地仓库 `docs/00_ssot/`

## 3. Mandatory Filing Rule
- 从本规则生效起，`enterprise_hub V1` 的每一轮实现执行都必须满足：
  1. 后端 Agent 必须提交并落盘回执文档
  2. BFF Agent 必须提交并落盘回执文档
  3. 前端 Agent 必须提交并落盘回执文档
- 当前落盘口径固定如下：
  - 后端 Agent 回执：
    - 允许落盘在云端工作区
    - 允许额外同步到当前仓库 `docs/00_ssot/`
    - 结果校验至少必须拿到一条可读的云端绝对路径
  - BFF Agent 回执：
    - 允许落盘在云端工作区
    - 允许额外同步到当前仓库 `docs/00_ssot/`
    - 结果校验至少必须拿到一条可读的云端绝对路径
  - 前端 Agent 回执：
    - 仍以当前仓库 `docs/00_ssot/` 为准
- 三份回执缺任一项时：
  - 结果校验不得启动
  - 已启动的结果校验应直接判定：
    - `FAIL`
    - reason = `implementation evidence incomplete`

## 4. Required Receipt Content
- 每份回执至少必须包含：
  1. 当前对象
  2. 修改文件清单
  3. 路径/页面/状态机/数据落地情况
  4. build / start / health / 最小验证结果
  5. 当前剩余阻断项
  6. 是否可移交下一角色
- 不允许只写：
  - “已完成”
  - “已接通”
  - “应该可以”
  - “代码已在仓库中”

## 5. Verification Gate Meaning
- 结果校验 Agent 当前只在以下条件全部满足后才能启动：
  - 后端回执已落盘，且已提供可读的云端绝对路径或本地同步件
  - BFF 回执已落盘，且已提供可读的云端绝对路径或本地同步件
  - 前端回执已落盘于当前仓库 `docs/00_ssot/`
- 上述三项满足后：
  - 才允许进入 `implementation result verification`
- 即使三项满足：
  - 也不代表 release-prep 自动放行
  - 也不代表 release 自动放行

## 5.1 Receipt-source Alignment
- 当前 receipt gate 与项目拓扑的正式对齐如下：
  - `apps/server` 在云端执行，因此 backend receipt 可先存在于云端
  - `apps/bff` 在云端执行，因此 BFF receipt 可先存在于云端
  - `apps/mobile` 在本地执行，因此 frontend receipt 继续以本地仓库为准
- 当前结果校验不得再把以下两件事混为一谈：
  1. `云端存在`
  2. `当前仓库 docs/00_ssot/ 存在`
- 当前正确做法是：
  - backend / BFF：先查云端只读证据路径，必要时再查本地同步件
  - frontend：查当前仓库 `docs/00_ssot/`

## 6. Current Formal Conclusion
- 当前正式结论如下：
  - `enterprise_hub V1` 后续每一轮实现执行均必须先回执落盘
  - backend / BFF 回执允许以云端只读证据文件作为第一段门禁来源
  - frontend 回执继续以当前仓库 `docs/00_ssot/` 为第一段门禁来源
  - 无三份回执，不启动结果校验
  - `release-prep / release` 仍然 `No-Go`

## 7. Next Unique Action
- 下一步唯一动作：
  - 让后端 Agent、BFF Agent、前端 Agent 按当前派工边界分别提交并落盘各自实现回执
  - 三份回执齐备后，再重新发起 `enterprise_hub V1` 实现结果独立复核
