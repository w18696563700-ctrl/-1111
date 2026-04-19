---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded BFF app-facing shaping boundary for CS-032 user violation score within the existing governance-status summary family.
layer: L3 BFF
---

# CS-032 用户违规累计分 P1-A BFF Surface Addendum

## 1. 当前范围

本文件只冻结：

- `GET /api/app/profile/governance/status`

## 2. 当前 BFF 角色

`BFF` 只允许：

- 转发 current actor governance-status summary 请求
- 整形 app-facing envelope
- 透传 bounded score snapshot 字段
- 保留受控 unavailable / auth 错误

`BFF` 不允许：

- 创建或持有 violation score 真相
- 创建或持有第二套 governance status machine
- 维护自动处罚规则
- 新增更大治理中心聚合

## 3. 当前上游依赖

`BFF` 只允许调用现有 bounded governance-summary 上游承接。

当前 `CS-032` 不新增新的 app-facing 或 server-facing route family。

## 4. 当前 shaping 边界

在既有 `governance status` payload 上，当前只允许额外整形：

- `violationScoreSnapshot`
- `violationScoreUpdatedAt`

当前 app-facing shaping 不允许升格为：

- full trust-score model
- penalty history center
- appeal center
- user governance dashboard

## 5. 当前明确不纳入项

- 自动处罚透传
- penalty history center
- appeal center 扩写
- whitelist / permanent-ban history
- 存量复扫
- AI 审核统一接入层
- `CS-019`
- `CS-033`
- `CS-034`

## 6. 当前 Formal Conclusion

`CS-032 P1-A` 的 BFF surface 已冻结：

- 只允许 bounded score snapshot shaping
- 不得持有第二真相
- 不得误开 penalty history、appeal center、自动处罚或 full governance center
