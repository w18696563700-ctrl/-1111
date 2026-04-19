---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF shaping patch for stage-2 so the app-facing list/workbench surfaces expose company serviceItems and albumImageFileAssetIds without inventing second truth.
layer: L3 BFF
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/01_contracts/enterprise_display_stage2_public_card_and_album_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_stage2_public_card_and_album_backend_truth_addendum.md
  - apps/bff/src/routes/enterprise_hub/**
---

# 企业展示 Stage 2 公域卡片与画册补链 BFF Surface 冻结单

## 1. Scope

- 当前 BFF freeze 只补：
  - company list highlights `serviceItems` shaping
  - workbench basic `albumImageFileAssetIds` shaping
  - basic write payload forward
- 当前不补：
  - 新 path
  - 新信用真值
  - 详情页整页语义改造

## 2. Public List Shaping Rule

- BFF list/recommendation read-model 当前必须把 company highlights 至少整形为：
  - `exhibitionTypes`
  - `serviceItems`
- 当前不得用 frontend fallback 掩盖 upstream 缺口。

## 3. Workbench Basic Rule

- `toEnterpriseHubWorkbenchResponse(payload).basic` 当前必须透传：
  - `albumImageFileAssetIds`
- `normalizeBasicPayload(payload)` 当前必须透传：
  - `albumImageFileAssetIds`

## 4. Truth Boundary Rule

- BFF 当前只负责：
  - transport
  - shape normalization
  - file display URL shaping
- BFF 当前不得：
  - 发明第二套 company highlight 真值
  - 发明第二套 album 真值
  - 发明 `creditScore`

## 5. Formal Conclusion

- 当前 stage-2 BFF 职责固定为：
  - 让 app-facing company list cards 能拿到 `serviceItems`
  - 让 app-facing workbench basic 能拿到并写回 `albumImageFileAssetIds`
