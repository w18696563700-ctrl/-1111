---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF app-facing repair scope for enterprise-display company/factory board separation, public-case route alignment, and media-map shaping only.
layer: L2.5 BFF
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/01_contracts/enterprise_display_company_factory_case_media_repair_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_backend_truth_scope_addendum.md
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts
  - apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.module.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.read-model.ts
---

# 《enterprise display company/factory 串板块与案例媒体回显 BFF surface scope》

## 1. Surface Objective

- 当前 BFF scope 只补：
  - `public-cases` app-facing route alignment
  - company / factory naming shaping alignment
  - `caseImageUrlMap` / `showcaseImageUrlMap` app-facing pass-through
  - route-level smoke coverage
- 当前不补：
  - 新 contract family
  - 新 page orchestration
  - 新业务状态机

## 2. Required Surface Rules

### 2.1 Route alignment

- `GET /api/app/exhibition/enterprise-hub/public-cases/{caseId}` 必须在当前 BFF release 中真实可达。
- controller / module / current release / gateway 不得再出现“源码有 route，线上 404”。

### 2.2 Read-model shaping

- factory list / recommendation / detail 的标题与辅助主体名必须保持一致。
- `caseImageUrlMap` 不得被 read-model 静默洗成空 carrier。
- `showcaseImageUrlMap` 不得在 workbench shaping 中丢失。

### 2.3 Error surface

- 当前不得把 route drift、carrier 丢失、或 upstream read failure 假装成成功返回。

## 3. Allowed Write Set

- 当前 BFF 允许：
  - `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.module.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.read-model.ts`
  - 与上述直接相关的 `test`

## 4. Required Tests

- 当前 BFF 至少必须补：
  - 真实 app-facing route smoke
  - public case detail 非空 `caseImageUrlMap` 透传测试
  - workbench case item 非空 `caseImageUrlMap` 透传测试
  - factory list / detail naming 一致性测试

## 5. Anti-revert

- 不得只保留 controller/service 直调测试，绕开真实 HTTP route 覆盖。
- 不得把 `caseImageUrlMap` 缺失继续默认成 `{}` 而无失败信号。
- 不得发明 `/bff/*` 产品 contract 家族替代 canonical app-facing path。

## 6. Formal Conclusion

- 当前 BFF scope 已冻结为：
  - route alignment
  - shaping alignment
  - smoke-test closure only

