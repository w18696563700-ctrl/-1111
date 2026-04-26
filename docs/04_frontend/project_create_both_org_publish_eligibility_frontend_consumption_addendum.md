---
owner: Codex 总控
status: active
purpose: Freeze Flutter consumption for dual-capability organization project-create eligibility.
layer: L4 Frontend
created_at: 2026-04-27
---

# 《both 主体创建项目资格 Flutter consumption》

## Frontend Consumption

- Flutter 继续消费 `GET /api/app/shell/context.projectCreateEligibility.canCreateProject` 作为 app-facing 创建资格投影。
- Flutter 不把当前页面本地表单校验当成最终创建资格。
- 若创建命令仍被 Server 拦截，页面展示 BFF 改写后的具体原因。

## Boundary

- 创建页只负责基础信息、草稿保存、保存到预发布列表。
- 明价 / 询价只作为预算旁意向选择。
- 附件与补充说明在草稿 / 预发布详情承接，创建首屏不直接承载正式发布确认。
