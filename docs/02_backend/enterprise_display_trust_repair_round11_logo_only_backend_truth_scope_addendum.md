---
owner: Codex 总控
status: frozen
purpose: Freeze the server-side truth boundary for Logo-only shell/application decoupling.
layer: L2 Backend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round9_logo_only_contract_truth_ruling_addendum.md
  - docs/02_backend/enterprise_display_trust_repair_round6_backend_truth_scope_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-application.entity.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-listing.entity.ts
---

# Enterprise Display Trust Repair Round 11 Logo-only Backend Truth Scope

## 1. Truth Objective

- 正式拆开：
  - `enterprise_listing` = shell carrier
  - `enterprise_application` = application carrier

## 2. Shell Truth

- `Server` 必须新增或抽取一条受控 truth entry：
  - `ensureOwnedListingShell(boardType, context)`
- 它必须只做：
  - 在当前 organization + boardType scope 下查找 listing
  - 不存在时创建 listing shell
  - 创建缺失的 review summary shell
  - 对 shell 执行已有的 certification / organization snapshot sync
- 它不得做：
  - 创建 application
  - upsert primary contact
  - 伪造 applicant fields

## 3. Application Truth

- `createApplication` 在 round-11 后正式只承担：
  - 基于已存在或可 ensure 的 shell 创建/刷新 draft application
  - 写入 `applicantName / applicantMobile`
  - 在该时点 upsert primary contact
- `enterprise_application.applicantName / applicantMobile` 本轮不改 nullable。
- 本轮不新增 migration。

## 4. Submit And Readiness Truth

- submit minimum 继续要求：
  - listing minimum
  - primary contact minimum
  - profile minimum
  - case minimum
  - certification minimum
- readiness family 必须与新 carrier 边界对齐：
  - `hasApplication = false` 不再被解释为“还没 enterprise shell”
  - 无 shell、已有 shell 但无 application、已有 application 三种状态必须可区分
- 当前至少需要修正文案语义：
  - 不得继续把“上传图片完成自动建档”等同于“已创建 application draft”

## 5. Error Truth

- 新 truth family 允许增加：
  - `ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE`
- 它只用于：
  - shell acquisition 路径不可完成
- 不得复用为：
  - application submit fail
  - contact missing
  - listing minimum incomplete

## 6. Allowed Write Set

- 当前 round-11 backend 优先允许：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-errors.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`
- 若需要抽取辅助 truth service，允许新增：
  - `apps/server/src/modules/enterprise_hub/*shell*.service.ts`
  - 但不得顺手扩写第二状态机

## 7. Anti-revert

- 不得继续让 `createApplication` 同时兼任：
  - shell creation
  - contact persistence
  - application draft creation
- 不得把 `enterprise_application` 当成基础资料草稿总 carrier。
- 不得通过放宽 `application` persistence 非空约束来伪装“Logo-only 已修复”。

## 8. Formal Conclusion

- `Server` round-11 真值边界已冻结为：
  - `shell ensure`
  - `application create/refresh`
  两条分离写链。
- 旧的混合 carrier 方案正式判定为 `No-Go`。
