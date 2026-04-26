---
owner: Codex 总控
status: frozen
purpose: >
  Freeze BFF handling for counterpart conversation project entry titles after
  separating exhibitionName from concrete project title.
layer: L3 BFF
recorded_at_local: 2026-04-26
based_on:
  - docs/00_ssot/counterpart_conversation_project_entry_title_truth_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_bff_surface_freeze_addendum.md
---

# 《消息楼项目入口标题 BFF Surface Addendum》

## 1. 结论

BFF 本轮不新增业务真值，不拼接项目标题。

冻结规则：

- BFF 继续从 Server 读取 `projectGroups[].projectDisplayTitle`。
- BFF 继续校验该字段为必填字符串。
- BFF 继续透传 `titleVisibility`。
- BFF 不根据 `exhibitionName / brandName / title` 自行重算标题。

## 2. 字段边界

`GET /api/app/message/counterpart-conversation/detail` 中：

- `projectGroups[].projectDisplayTitle`：
  - Server-owned display projection。
  - 已授权时应为具体项目名，例如 `西洽会 - 泸州`。
  - 未授权时可为遮罩标题。
- `projectGroups[].titleVisibility`：
  - `visible` 表示当前 viewer 可见真实项目名。
  - `masked` 表示当前 viewer 不可见真实项目名。

## 3. BFF 禁止项

BFF 不得：

- 拼接 `exhibitionName + brandName`。
- 从 `projectId` 推导标题。
- 把 `exhibitionName` 当具体项目标题。
- 绕过 Server 的名称查看权限投影。
- 新增第二套项目标题状态机。

## 4. 当前最小闭环

1. Server 生成标题投影。
2. BFF read-model 校验字段形态。
3. Flutter 消费 `projectDisplayTitle`。

## 5. 策略判断

- 更稳：BFF 只校验透传。
- 更省成本：无需改 BFF 业务代码。
- 更适合当前阶段：只让 Server 承担标题真值修正。
- 风险更大：BFF 重算标题，导致 Server/BFF 双真值。
