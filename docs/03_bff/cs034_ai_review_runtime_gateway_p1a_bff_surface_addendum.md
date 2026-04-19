---
owner: Codex 总控
status: frozen
purpose: Freeze the no-direct-gateway BFF boundary for CS-034 AI review runtime gateway.
layer: L3 BFF
---

# CS-034 AI 审核服务统一接入层 P1-A BFF Surface Addendum

## 1. 当前范围

本文件只冻结 `CS-034` 在 BFF 层的 no-direct-gateway 边界。

## 2. 当前 BFF 角色

`BFF` 当前只允许：

- 继续消费各业务包由 `Server` materialize 的最终业务结果
- 不直接代理 AI gateway request/result
- 不暴露 raw model output

`BFF` 不允许：

- 创建或持有 AI gateway truth
- 直接调用 provider 并自判结果
- 新增 app-facing AI console route

## 3. 当前 route 边界

`CS-034 P1-A` 当前不新增任何：

- `/api/app/*` AI runtime route
- `/api/app/*` AI review center route
- `/api/app/*` provider debug route

## 4. 当前明确不纳入项

- public AI console
- penalty / appeal full desk
- 自动处罚透传
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`

## 5. 当前 Formal Conclusion

`CS-034 P1-A` 的 BFF surface 已冻结：

- 当前明确为 no-direct-gateway surface
- 不得误开 AI console、raw output surface、自动处罚 surface 或更大治理中心
