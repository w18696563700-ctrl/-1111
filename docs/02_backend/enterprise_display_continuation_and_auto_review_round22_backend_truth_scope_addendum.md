---
owner: Codex 总控
status: frozen
purpose: Freeze the server-side truth boundary for enterprise display continuation after post-submit results and for auto-review v1.
layer: L2 Backend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/02_backend/enterprise_display_workbench_v1_backend_truth_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-application-review-admin.write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-app.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-support.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts
---

# Enterprise Display Continuation And Auto-Review Round22 Backend Truth Scope

## 1. Truth Objective

- 正式拆清三条链：
  - 未发布申请在 post-submit 结果后的继续测试链
  - 已发布展示的正式变更链
  - `Server auto-review v1`

## 2. Unpublished Continuation Truth

- 当前 `createApplication()` 已是唯一允许的新建或复用 `draft` application truth entry。
- round22 正式冻结：
  - 当最近申请处于 `approved / revision_required / rejected / submitted / under_review` 之一时，
  - 若用户要继续准备新的提交轮次，
  - 允许重新调用 `createApplication()` 创建新的 `draft`
  - 不得通过覆盖旧申请状态来伪装“继续编辑”
- round22 不新增新的 unpublished continuation route。

## 3. Published Change Corridor Truth

- 对 `enterpriseStatus = published` 的 listing：
  - 基础资料修改
  - 板块画像修改
  - 主联系人修改
  - 案例新增 / 编辑 / 删除
  必须只走 `published-change corridor`
- `createCurrentCase()` 当前正式承接“已发布展示新增案例”真值。
- `updateCurrentCase()` 当前正式承接“已发布展示编辑案例”真值。
- `approved` 仅代表变更审核通过，不得等价为已写入 live listing。
- `applied` 才代表当前变更已写入 live listing。

## 4. Auto-Review V1 Truth

- `auto-review v1` 只能落在 `Server`。
- 当前正式冻结为：
  - `自动审核`
  - `不自动发布`
- `submitApplication()` 在现有 minimum gate 通过后，允许接入：
  - `AutoReviewService.evaluate(...)`
- 当前 evaluation 只允许输出：
  - `approved`
  - `revision_required`
  - `manual_review_required`
- 状态写入规则固定为：
  - `approved` -> `applicationStatus = approved`
  - `revision_required` -> `applicationStatus = revision_required`
  - `manual_review_required` -> 保持 `submitted` 或显式进入 `under_review`

## 5. Review Governance Rule

- round22 `auto-review v1` 不得替代 Admin review。
- Admin review write chain 必须保留 override 权。
- `publishListing()` 仍必须单独要求：
  - 已存在 `approved` application
- `auto-review v1` 不得直接触发：
  - `publishListing()`
  - `enterpriseStatus = published`
  - `displayStatus = visible`

## 6. Audit Rule

- 最小可落地版允许复用现有字段：
  - `applicationStatus`
  - `reviewedAt`
  - `reviewerId`
  - `reviewNote`
- 允许系统自动结果写为：
  - `reviewerId = system:auto-review`
  - `reviewNote = auto-review rule v1`
- 正式审计版建议新增但本轮不强制：
  - `reviewSource`
  - `reviewRuleVersion`
  - `reviewDecisionSnapshot`

## 7. Rule Boundary

- 允许自动通过的项只限客观可判定条件，例如：
  - 企业认证已通过
  - 基础资料完整
  - 联系人完整
  - 至少 1 个有效案例
  - 省市真值完整
  - 板块画像最小项齐全
- 不允许在 round22 直接把主观项交给自动通过，例如：
  - 案例质量判断
  - 文案夸大
  - 违规词争议
  - 推荐位资格

## 8. Allowed Write Set

- round22 backend 优先允许：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-application-review-admin.write.service.ts`
  - `apps/server/src/modules/enterprise_hub/entities/enterprise-application.entity.ts` 仅在决定走正式审计版字段时
  - `apps/server/src/modules/enterprise_hub/*auto-review*.service.ts`
  - `apps/server/test/**`

## 9. Anti-revert

- 不得在 `BFF` 或 Flutter 本地猜测 auto-review 结果。
- 不得把 `approved` 误写成 `published`。
- 不得绕开 `published-change corridor` 直接改 live listing 的案例或基础资料。

## 10. Formal Conclusion

- round22 backend 真值边界已冻结为：
  - `recreate draft for unpublished continuation`
  - `published-change corridor for published listing edits`
  - `server-only auto-review v1 without auto-publish`
