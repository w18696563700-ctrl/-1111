---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Flutter consumption boundary for CS-032 user violation score within the existing governance-status summary surface.
layer: L4 Frontend
---

# CS-032 用户违规累计分 P1-A Frontend Surface Addendum

## 1. 当前范围

本文件只冻结 Flutter 对以下 app-facing path 的消费：

- `GET /api/app/profile/governance/status`

## 2. 当前页面边界

当前只允许：

- 在既有治理状态摘要页内显示最小累计分信息
- 以 read-only 方式展示累计分快照与更新时间

当前不允许：

- penalty history center
- 申诉中心扩写
- 自动处罚说明中心
- whitelist / permanent-ban history center
- 独立治理总控台

## 3. 当前交互规则

- 累计分只允许依附既有治理摘要 surface 展示
- 当前不允许点击进入独立 score history
- 无数据时进入受控 hidden / unavailable state
- 不得伪造 score timeline 或补造历史记录

## 4. 当前展示边界

当前只允许展示最小字段：

- `violationScoreSnapshot`
- `violationScoreUpdatedAt`

展示 copy 只允许表达：

- 这是基于已生效处罚记录生成的累计分快照

展示 copy 不得表达：

- 自动处罚已经触发
- 申诉中心已开放
- 治理整体已完成

## 5. 当前明确不纳入项

- 自动处罚 UI
- penalty history center UI
- appeal center 扩写 UI
- `CS-019`
- `CS-033`
- `CS-034`
- release-prep / launch approval copy

## 6. 当前 Formal Conclusion

`CS-032 P1-A` 的 Flutter consumption boundary 已冻结。

后续实现只允许围绕当前 bounded score snapshot read-only surface 开工。
