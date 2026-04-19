---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the stage gate for decoupling project-create eligibility from the
  retained workbench summary into the canonical shell-context projection,
  allowing the bounded docs, BFF/Server, and Flutter implementation round.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_ruling_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/core/boot/app_shell_context_consumer.dart
  - apps/server/src/modules/shell/shell-query.service.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
---

# 《项目创建资格 shell projection 脱钩阶段门禁核查表》

## 1. 当前轮范围

- 本轮只覆盖：
  - `project create eligibility` app-facing projection carrier
  - `shell/context` 新增最小资格投影
  - `ProjectCreatePage` 读取路径从 workbench summary 切换到 shell context
  - 保留 workbench fallback 兼容
- 本轮不覆盖：
  - workbench route 删除
  - my-project / prepublish / publish lifecycle 规则改写
  - 文书区与公共资源区

## 2. Passed Gates

- `真值唯一性门禁` 通过：
  - create eligibility 真值已明确属于 `CurrentActorEligibilityService.canPublishProjectInScope(scope)`。
- `去第二真源门禁` 通过：
  - 当前计划是 Server 出 projection，Flutter 只消费，不在前端重算业务真值。
- `兼容落地门禁` 通过：
  - 当前允许保留 workbench fallback，避免 active release 硬切。

## 3. Veto Gates

- `workbench 真值回流门禁` 未触发：
  - 本轮不把 create eligibility 真值继续锁死在 workbench summary。
- `前端硬算真值门禁` 未触发：
  - 本轮不允许 Flutter 仅凭 role/certification 自行最终裁决。
- `大范围拆路由门禁` 未触发：
  - 本轮不删 `/exhibition/workbench`。

## 4. Gate Conclusion

- 当前 veto gates 均未阻断。
- 当前轮结论固定为：
  - `Go for docs + contracts + backend + bff + frontend bounded implementation`

