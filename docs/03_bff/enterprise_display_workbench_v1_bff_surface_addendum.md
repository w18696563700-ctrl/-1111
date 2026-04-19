---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF aggregation surface for the enterprise display workbench V1, including the app-facing workbench read path and the normalization rule for existing write paths.
layer: L2.5 BFF
freeze_date_local: 2026-04-10
inputs_canonical:
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_workbench_v1_backend_truth_addendum.md
  - apps/bff/src/routes/enterprise_hub/**
---

# 企业展示工作台 V1 BFF Surface 冻结单

## 1. Scope

- 当前 BFF freeze 只覆盖：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - enterprise-hub 既有 write family 的继续归一
  - shared upload path 对 enterprise-display 的继续透传

## 2. Workbench Path Rule

- `BFF` 必须新增：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
- 它必须只做：
  - auth/session 透传
  - organization-scope forward
  - response normalization
- 它不得做：
  - submit-readiness 本地判断
  - 第二套草稿状态机
  - certification truth 派生

## 3. Existing Write Rule

- `BFF` 当前继续承接：
  - shared upload init / confirm
  - create application
  - update basic
  - update profiles
  - create case
  - submit application
  - get application status
- `BFF` 必须继续拦截：
  - display URL 冒充 file truth
  - 非法 boardType
  - 缺失必要 body 字段
- `BFF` 当前必须额外承接：
  - `showcaseImageFileAssetIds` 归一
  - case media 数量边界透传
  - `caseCoverFileAssetId` 可空时的合法归一

## 4. Formal Conclusion

- 当前 BFF 正式职责固定为：
  - 新增一条 workbench read aggregation
  - 继续透传 enterprise-display 共享上传
  - 继续维持 enterprise-hub command normalization
