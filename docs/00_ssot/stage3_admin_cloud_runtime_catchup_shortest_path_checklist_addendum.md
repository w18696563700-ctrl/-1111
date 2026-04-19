---
owner: Codex 总控
status: frozen
purpose: Freeze the shortest cloud catch-up path for stage3 Admin so active runtime catches up with the already-passed local package A/B/C implementation before any further stage3 implementation advances.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_a_result_verification_pass_addendum.md
  - docs/00_ssot/stage3_admin_package_b_result_verification_pass_addendum.md
  - docs/00_ssot/stage3_admin_package_c_result_verification_pass_addendum.md
  - docs/00_ssot/stage3_admin_post_package_c_next_subpackage_ruling_addendum.md
  - apps/admin/src/app/project_review/page.tsx
  - apps/admin/src/app/audit/page.tsx
  - apps/server/src/modules/exhibition_report_cases/exhibition-report-case-admin.controller.ts
  - apps/server/src/modules/audit/audit-admin.controller.ts
---

# 《stage3 云上追平本地最短补齐清单》

## 1. 当前裁决

- 当前 `stage3` 的本地推进不是落后。
- 当前真正落后的是：
  - `云上 active runtime`
- 也就是说：
  - `package A/B/C` 的本地 truth、实现、最小验证已经成立
  - 但云上 active 仍未追平 `package B / package C`

## 2. 当前已核实的云上状态

### 2.1 本地隧道经由 nginx 的可见结果

- `GET /login`
  - `200`
- `GET /review`
  - `307 -> /login?next=/review`
- `GET /governance/penalties`
  - `307 -> /login?next=/governance/penalties`
- `GET /project_review`
  - `404`
- `GET /audit`
  - `404`

### 2.2 云上 current 指向

- `Admin current`
  - 当前指向：
    - `/srv/workspaces/exhibition-infra-monorepo/apps/admin`
- `Server current`
  - 当前仍在 release current 上

### 2.3 云上代码面差异

- 云上 `Admin` 当前仍可读到旧 placeholder：
  - `project_review` 仍是占位语义
  - `audit` 仍是占位语义
- 云上 `Server current` 当前未见：
  - `exhibition-report-case-admin.controller.ts`
  - `audit-admin.controller.ts`

## 3. 结论为什么是“云上落后”

- `package A` 的云上活跃面已经成立：
  - `/login`
  - `/review`
  - `/governance/penalties`
- 但 `package B / C` 的云上活跃面尚未成立：
  - `/project_review`
  - `/audit`
- 因此当前不能把：
  - 本地 `A/B/C pass`
  误判成：
  - 云上 `A/B/C 已追平`

## 4. 当前唯一正确策略

- 当前不得继续把精力投到：
  - `package D implementation`
  - `ticketing`
  - 任意新的 stage3 运行态实现
- 当前唯一正确策略只能是：
  - 先把云上 active runtime 追平到本地已通过的 `package B / C`

## 5. 最短补齐路径

### Step 1. 追平 Admin active runtime

必须交付：
- 云上 `Admin` 不再指向 workspace current
- 云上 `Admin` 必须切到正式 release artifact

通过信号：
- `/project_review`
  - 不再 `404`
- `/audit`
  - 不再 `404`

### Step 2. 追平 Server active runtime

必须交付：
- 云上 `Server current` 包含：
  - `exhibition_report_cases` admin path family
  - `audit/logs` admin path family

通过信号：
- 代码层：
  - `exhibition-report-case-admin.controller.ts` 已在 active release 中
  - `audit-admin.controller.ts` 已在 active release 中

### Step 3. 追平 package B 页面承接

必须交付：
- `/project_review`
  - 进入 route guard / login redirect 或真实页面承接
  - 不再是 nginx 404

通过信号：
- 未登录时：
  - `/project_review -> 307 /login?next=/project_review`
- 已登录时：
  - `/project_review` 可进入 report-cases desk

### Step 4. 追平 package C 页面承接

必须交付：
- `/audit`
  - 进入 route guard / login redirect 或真实页面承接
  - 不再是 nginx 404

通过信号：
- 未登录时：
  - `/audit -> 307 /login?next=/audit`
- 已登录时：
  - `/audit` 可进入 audit queue/filter/detail seat

### Step 5. 追平 package B server runtime

必须交付：
- 云上 `Server` 能承接：
  - `GET /server/admin/exhibition/report-cases`
  - `GET /server/admin/exhibition/report-cases/{reportCaseId}`
  - 以及 package B 三个动作 path

通过信号：
- 结果校验能够对 active runtime 给出 package-B runtime evidence

### Step 6. 追平 package C server runtime

必须交付：
- 云上 `Server` 能承接：
  - `GET /server/admin/audit/logs`
  - `GET /server/admin/audit/logs/{auditLogId}`

通过信号：
- 不再出现：
  - `404 /server/admin/audit/logs`

## 6. 最短补齐后的重新判定点

只有当以下 4 条同时成立时，才允许说云上已追平本地：

1. `/project_review` 不再 404
2. `/audit` 不再 404
3. 云上 `Server` 已包含 package-B controller family
4. 云上 `Server` 已包含 package-C controller family

## 7. 当前唯一下一步动作

- 当前下一步唯一动作固定为：
  - `云上追平本地的 release/runtime correction`

## 8. Formal Conclusion

- 当前 `stage3` 的真实问题不是本地 package 推进慢。
- 当前真实问题是：
  - 云上 active runtime 落后于本地已通过的 `package B / C`
- 当前最短补齐路径不是新开包，而是：
  - 先把云上 `Admin + Server` 追平到本地 `package B / C`
