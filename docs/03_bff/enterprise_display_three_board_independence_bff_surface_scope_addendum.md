---
owner: Codex 总控
status: frozen
purpose: Freeze the Day-1 BFF app-facing surface direction for enterprise-display three-board independence, including board-scoped private families, compatibility bridge rules, and upload error-shaping boundaries.
layer: L2.5 BFF
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_three_board_independence_backend_truth_scope_addendum.md
  - apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/bff/src/routes/file/app-file-upload.controller.ts
  - apps/bff/src/routes/file/file.service.ts
---

# 《企业展示三板块独立化 BFF surface scope》

## 1. Surface Objective

- 当前 BFF surface scope 只冻结：
  - 三板块私有 app-facing family 的方向
  - 共享 `enterprise-hub` family 的兼容桥规则
  - 案例上传 file kind 拆分后的 shaping / normalization 责任
  - error normalization 不伪装成功态
- 当前不冻结：
  - 新业务状态机
  - Admin-only surface
  - release choreography

## 2. Board-scoped Family Direction

- BFF 对 App 暴露的目标方向正式冻结为：
  - company private family
  - factory private family
  - supplier private family
- 三套 family 在 BFF surface 层必须具备清晰区分，不再继续把“共享 controller + `boardType` 参数”当最终形态。
- BFF 可以在迁移期内部复用已有 service，但对外 canonical identity 不得继续模糊。

## 3. Compatibility Bridge Rule

- 若迁移期保留共享 `enterprise-hub` family：
  - 只能作为 compatibility bridge
  - 不得承接新的 contract 语义
  - 不得阻碍三板块私有 family 建立
- compatibility bridge 必须保持：
  - `enterpriseId`
  - `boardType`
  - 当前 case / workbench / published-change identity
  不被静默裁掉。

## 4. Upload Surface Rule

- BFF 继续允许复用：
  - `/api/app/file/upload/init`
  - `/api/app/file/upload/confirm`
- 但对于企业展示案例上传，BFF 必须承接新的板块化 file kind 校验与错误整形：
  - `enterprise_company_case_media`
  - `enterprise_factory_case_media`
  - `enterprise_supplier_case_media`
  - `enterprise_factory_showcase`
- BFF 不得把 backend 返回的“非法 file kind / 非法 ownership / 非法 board binding”继续包装成成功上传态。

## 5. Error and Shaping Rule

- BFF 允许做：
  - actor / trace / auth normalization
  - error copy normalization
  - app-facing response shaping
- BFF 不允许做：
  - 第二套 case ownership truth
  - 第二套 board state machine
  - 为兼容旧路由而隐藏 board mismatch 或 media mismatch

## 6. Allowed Future Write Set

- 下一轮 BFF bounded implementation 允许写入：
  - `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.service.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.read-model.ts`
  - `apps/bff/src/routes/file/app-file-upload.controller.ts`
  - `apps/bff/src/routes/file/file.service.ts`
  - 与上述直接相关的 route / read-model / HTTP smoke tests

## 7. Anti-revert

- 不得继续把共享 `enterprise-hub` 路由组包装成“已经独立”。
- 不得把 upload file kind 拆分退化成仅改前端文案。
- 不得发明新的 `/api/app/bff/*` 产品 contract 家族。

## 8. Formal Conclusion

- 当前 BFF surface scope 已冻结为：
  - board-scoped app-facing family direction
  - compatibility bridge only where necessary
  - upload normalization for board-specific file kinds
  - no second truth, no second state machine
