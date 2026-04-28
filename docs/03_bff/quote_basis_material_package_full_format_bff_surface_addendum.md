---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF impact of Quote Basis Material Package V1 full-format files.
layer: L4 BFF
freeze_date_local: 2026-04-28
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_full_format_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_full_format_contract_addendum.md
  - docs/03_bff/quote_basis_material_package_v1_bff_surface_addendum.md
---

# 《报价依据资料包 V1 全格式 BFF surface addendum》

## 1. Conclusion

BFF 不新增接口、不新增第二附件 family。BFF 继续透传 upload init / confirm / attachment bind / bid-materials / file access。

## 2. Boundary

- BFF 不持有 MIME 白名单真相。
- BFF 不用 MIME 推断 `attachmentKind`。
- BFF 可继续保留后端错误归一，但不主动制造按类型 MIME 拦截。

## 3. Option Judgment

- 更稳：BFF 保持 app-facing 转发和错误归一职责。
- 更省成本：无需新增 BFF 路由或 DTO。
- 更适合当前阶段：Server 和 Flutter 对齐即可。
- 风险更大：在 BFF 重新做一套 MIME-kind 白名单，会形成第二业务规则源。
