---
owner: Backend Agent
status: completed
purpose: Record the real Package B Admin review/apply surface implementation result for the enterprise display published change corridor.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_prompt_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display published change corridor Package B admin review-apply surface execution receipt》

## 1. 修改文件清单

- `apps/admin/src/core/server/admin-api-client.ts`
- `apps/admin/src/core/server/admin-enterprise-hub-change-api-client.ts`
- `apps/admin/src/modules/published_change_review/published-change-review-state.ts`
- `apps/admin/src/modules/published_change_review/published-change-review-form.ts`
- `apps/admin/src/modules/published_change_review/published-change-review-actions.ts`
- `apps/admin/src/modules/published_change_review/published-change-review-shell.tsx`
- `apps/admin/src/app/review/change_requests/page.tsx`
- `apps/admin/src/app/review/change_requests/[changeRequestId]/page.tsx`
- `apps/admin/src/app/layout.tsx`
- `apps/admin/test/admin-route-guard.test.cjs`
- `apps/admin/test/admin-api-client.test.cjs`
- `apps/admin/test/admin-published-change-review.test.cjs`
- `apps/admin/package.json`
- `apps/admin/tsconfig.admin-tests.json`
- `docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md`

## 2. queue 实现说明

- 新增 Admin transport：
  - `GET /server/admin/exhibition/enterprise-hub/change-requests`
  - 落在 `admin-enterprise-hub-change-api-client.ts`
- 新增 queue 页面：
  - `/review/change_requests`
- queue 只读取 Server Admin canonical queue，不本地定义第二治理真相。
- queue 最小承接：
  - `changeRequestId`
  - `enterpriseId`
  - `enterpriseName`
  - `boardType`
  - `changeStatus`
  - `submittedAt / reviewedAt / appliedAt`
- queue item 点击后进入 detail 页面：
  - `/review/change_requests/{changeRequestId}`

## 3. detail 实现说明

- 新增 detail transport：
  - `GET /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}`
- detail 页面同时展示：
  - `changeRequest` 当前状态
  - `enterprise` 摘要
  - `liveSnapshot`
  - `basic`
  - `boardProfile`
  - `primaryContact`
  - `cases`
- detail 页面单独显示：
  - 当前治理状态说明
  - 当前允许动作
  - `liveSnapshot` 与 `change snapshot` 的分离
- 页面语义明确写成：
  - 只消费 Server Admin canonical carrier
  - 不是治理真相 owner

## 4. review action 实现说明

- 新增 review transport：
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
- surface 把三种 review 决策拆成三个独立动作：
  - `approved`
  - `revision_required`
  - `rejected`
- `revision_required` / `rejected` 在 Admin form 层强制要求 `reviewNote`。
- `approved` 允许可选 `reviewNote`。
- action 失败时统一回到 detail 页，并以 `error=` 展示服务端错误，不会伪装成 success notice。

## 5. apply action 实现说明

- 新增 apply transport：
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`
- apply 按页面状态约束为独立动作：
  - 只有 `approved` 状态时才显示 apply form
  - `submitted / under_review / revision_required / rejected / applied` 都不显示 apply
- apply 成功后的 notice 明确写成：
  - 已向服务端提交 apply 动作，当前应以 live listing 新真值为准

## 6. `approved / applied` 分离说明

- surface 状态摘要明确区分：
  - `approved = 已审核通过，待 apply`
  - `applied = 已 apply 到 live listing`
- detail 页状态说明明确写出：
  - `approved` 仅代表审核通过，尚未 apply 到 live listing
  - `apply` 才是写入 live listing 的独立动作
- apply 按钮只在 `approved` 时暴露。
- `applied` 后页面只显示已写入 live listing 的结果说明，不再开放 apply。

## 7. 新增或更新的测试清单

- `apps/admin/test/admin-route-guard.test.cjs`
  - 新增 `/review/change_requests` 在现有 session carrier 缺失/存在时的保护行为断言
- `apps/admin/test/admin-api-client.test.cjs`
  - 新增 published-change `change-requests` list/detail/review/apply transport 断言
- `apps/admin/test/admin-published-change-review.test.cjs`
  - queue 读取并默认选中第一条 change request
  - detail 同时承接 change snapshot 与 live snapshot
  - review 三种决策 payload 正确构建
  - `revision_required / rejected` 必须有 reason
  - `approved != applied` 的页面状态摘要明确分离
  - invalid transition 错误会转成页面错误文案，不伪装成 success

## 8. build / test 结果

- `cd apps/admin && npm run test:admin-side`
  - 结果：通过，29 passed / 0 failed
- `cd apps/admin && ./node_modules/.bin/tsc --noEmit`
  - 结果：通过
- `cd apps/admin && ./node_modules/.bin/eslint src/core/server/*.ts src/modules/published_change_review/*.ts test/admin-route-guard.test.cjs test/admin-api-client.test.cjs test/admin-published-change-review.test.cjs`
  - 结果：通过
- `cd apps/admin && npm run build`
  - 结果：通过
  - 当前仍有既存非阻塞警告：
    - `next.config.js` 选项告警
    - `middleware` 约定弃用告警

## 9. 当前剩余未闭合项

- 本轮 Package B 范围内未发现剩余未闭合项
- 当前仍未实现且保持 `No-Go` 的内容：
  - Package C / BFF published-corridor surface
  - Package D / Flutter published-change workbench
  - 频次治理

## 10. 是否允许进入 Package C dispatch

- 允许
- 依据：
  - Admin 已具备 published change corridor 的 review / apply surface
  - Admin surface 只消费 Server canonical carrier，没有反向定义治理真相
  - `approved != applied` 已在用户可见层明确成立
  - Package B 完成后，Package C 的上游依赖已满足
