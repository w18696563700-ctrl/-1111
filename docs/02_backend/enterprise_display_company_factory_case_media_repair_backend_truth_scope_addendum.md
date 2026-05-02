---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded backend truth-repair scope for enterprise-display company/factory board separation, case isolation, media projection stability, and published-change repair only.
layer: L2 Backend
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_bounded_object_ruling_addendum.md
  - docs/01_contracts/enterprise_display_company_factory_case_media_repair_contract_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-media-projection.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts
---

# 《enterprise display company/factory 串板块与案例媒体回显 backend truth scope》

## 1. Backend Objective

- 当前 backend scope 只负责：
  - case board isolation
  - canonical display-name unification
  - media projection carrier stabilization
  - published-change snapshot / apply closure
- 当前 backend scope 不负责：
  - 新筛选能力
  - 新 map truth
  - 新 admin flow

## 2. Required Truth Repair

### 2.1 Case isolation

- 所有 enterprise case read / repair / promotion / snapshot / apply 路径必须按：
  - `enterpriseId + boardType`
  收口。
- 当前不得继续保留：
  - `enterpriseId` 裸 case 聚合

### 2.2 Naming unification

- factory 命名必须走统一 canonical policy。
- 当前 public list / detail / workbench / published-change presenter 不得再分别决策标题。

### 2.3 Media projection

- `caseImageUrlMap` / `showcaseImageUrlMap` 必须作为稳定 carrier 继续输出。
- 若 URL projection 不完整：
  - backend 必须保留 canonical fileAssetId truth
  - 不得静默把问题伪装成“空图片成功态”

### 2.4 Published-change closure

- live snapshot 与 apply 只处理当前板块 case。
- 当前不得删除、覆盖、提升异板块 case。

## 3. Allowed Write Set

- 当前 backend 允许：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-media-projection.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts`
  - 与上述直接相关的 `support` 与 `test`

## 4. Required Tests

- 当前 backend 至少必须补：
  - mixed-board case 读取隔离测试
  - approved promotion 隔离测试
  - published-change snapshot / apply 隔离测试
  - display-name priority 锁定测试
  - media projection 缺 URL 行为测试

## 5. Anti-revert

- 不得借修复之名引入第二套 case state machine。
- 不得让 `BFF` 或 Flutter 再次承担 backend truth correction。
- 不得继续把 mixed-board case 当作“数据修复后自然消失”的可接受前提。

## 6. Formal Conclusion

- 当前 backend scope 已冻结为：
  - truth repair only
  - no new capability
  - no new state machine
