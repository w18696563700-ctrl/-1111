---
owner: Codex 总控
status: active
purpose: Freeze BFF error surface for dual-capability organization project-create eligibility.
layer: L3 BFF
created_at: 2026-04-27
---

# 《both 主体创建项目资格 BFF surface》

## BFF Surface

- BFF 继续只透传和改写 Server 的创建命令结果。
- BFF 不拥有项目创建资格真相。
- 当 Server 返回 `organization_type_not_allowed` 时，BFF 应提示用户切换到可发布项目的主体。
- 当 Server 返回 `buyer_role_not_allowed` 时，BFF 仅用于 `demand/buyer` 主体缺少买方侧发布角色的场景。

## Boundary

- 不在 BFF 新增 `both` 主体资格计算。
- 不在 BFF 发明新的创建状态。
- 不把 P0-Pay 资金状态并入创建命令。
