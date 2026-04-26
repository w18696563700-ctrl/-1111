---
owner: Codex 总控
status: active
purpose: Freeze backend truth for dual-capability organization project-create eligibility.
layer: L2 Backend
created_at: 2026-04-27
---

# 《both 主体创建项目资格 backend truth》

## Backend Truth

- `CurrentActorEligibilityService.requireProjectPublishEligibility(...)` 仍是项目创建资格真源。
- 发布资格最小判断顺序：
  1. 当前 session 有 active organization scope；
  2. 当前主体类型属于 `demand`、历史兼容 `buyer` 或 `both`；
  3. `demand/buyer` 主体需要买方侧 role；
  4. `both` 主体不再因当前成员 role 是供应商侧 role 被硬拦截；
  5. 企业认证必须为 `approved`。

## No New State

- 不新增 `prepublish` 状态。
- 不新增 BFF 侧二次资格状态机。
- 不新增 Flutter 本地最终资格判断。

## Risk

- 更稳：资格真源仍在 Server。
- 更省成本：复用现有 `organizationType` 与 `certificationStatus`。
- 当前阶段最适合：解决已认证 `both` 主体无法保存创建项目的问题。
- 风险更大：只改前端 guard 会继续被 Server 命令层拒绝。
