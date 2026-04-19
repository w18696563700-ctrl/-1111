---
owner: Codex 总控
status: frozen
purpose: Freeze the no-new-app-surface BFF boundary for CS-033 historical content rescan.
layer: L3 BFF
---

# CS-033 存量内容复扫 P2-A BFF Surface Addendum

## 1. 当前范围

本文件只冻结 `CS-033` 在 BFF 层的显式 no-new-surface 边界。

## 2. 当前 BFF 角色

`BFF` 当前只允许：

- 保持不新增任何 app-facing rescan route
- 保持不代理任何 `server/admin/governance/rescan-jobs*`
- 保持既有 package 的 bounded error normalization

`BFF` 不允许：

- 创建或持有 rescan truth
- 创建或持有第二套治理状态机
- 扩出 rescan center / governance center

## 3. 当前 route 边界

`CS-033 P2-A` 当前不新增任何：

- `/api/app/*` rescan route
- `/api/app/profile/*` rescan route
- `/api/app/governance/*` rescan route

## 4. 当前明确不纳入项

- user-side rescan history
- penalty / appeal full desk
- AI runtime gateway direct surface
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`

## 5. 当前 Formal Conclusion

`CS-033 P2-A` 的 BFF surface 已冻结：

- 当前明确为 no-new-app-surface
- 不得误开 user-side rescan center、AI runtime surface 或更大治理中心
