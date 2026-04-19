---
owner: Codex 总控
status: frozen
purpose: Freeze the no-new-Flutter-surface boundary for CS-033 historical content rescan.
layer: L4 Frontend
---

# CS-033 存量内容复扫 P2-A Frontend Surface Addendum

## 1. 当前范围

本文件只冻结 `CS-033` 在 Flutter 层的显式 no-new-surface 边界。

## 2. 当前页面边界

当前只允许：

- 保持无新的 user-side rescan page
- 保持无新的 rescan history center
- 保持无新的 rescan detail center

当前不允许：

- 用户侧 penalty / appeal center
- 用户侧治理总控台
- rescan 命中通知中心

## 3. 当前交互规则

- Flutter 不得发起 rescan job
- Flutter 不得消费 rescan job/detail
- Flutter 不得展示“治理整体已完成”或“自动处罚已执行”类文案

## 4. 当前明确不纳入项

- user-side rescan history UI
- user-side governance center UI
- AI runtime gateway UI
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`
- release-prep / launch approval copy

## 5. 当前 Formal Conclusion

`CS-033 P2-A` 的 Flutter consumption boundary 已冻结：

- 当前明确为 no-new-user-surface
- 不得误开 user-side rescan center、AI runtime UI 或更大治理中心
