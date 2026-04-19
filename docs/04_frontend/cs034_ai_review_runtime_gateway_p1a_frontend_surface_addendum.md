---
owner: Codex 总控
status: frozen
purpose: Freeze the no-direct-gateway Flutter boundary for CS-034 AI review runtime gateway.
layer: L4 Frontend
---

# CS-034 AI 审核服务统一接入层 P1-A Frontend Surface Addendum

## 1. 当前范围

本文件只冻结 `CS-034` 在 Flutter 层的 no-direct-gateway 边界。

## 2. 当前页面边界

当前只允许：

- 继续消费各业务包已 materialize 的 bounded final decision
- 不新增 AI runtime gateway page
- 不新增 AI review service center

当前不允许：

- raw model output page
- provider debug page
- AI runtime dashboard
- governance overall completion page

## 3. 当前交互规则

- Flutter 不得直连 AI gateway
- Flutter 不得展示 raw prompt / raw payload / raw provider response
- Flutter 不得把 AI unavailable 表述成公共上线已完成

## 4. 当前明确不纳入项

- public AI review center UI
- penalty / appeal full desk UI
- 自动处罚 UI
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`
- release-prep / launch approval copy

## 5. 当前 Formal Conclusion

`CS-034 P1-A` 的 Flutter consumption boundary 已冻结：

- 当前明确为 no-direct-gateway UI surface
- 不得误开 AI console、raw output UI、自动处罚 UI 或更大治理中心
