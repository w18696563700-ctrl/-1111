---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF app-facing transport correction for enterprise display case and album upload init so organization scope is forwarded on the existing upload-init path.
layer: L2.5 BFF
freeze_date_local: 2026-04-17
inputs_canonical:
  - apps/bff/src/routes/file/file.service.ts
  - apps/server/src/modules/upload/upload-enterprise-display-binding.service.ts
  - docs/03_bff/enterprise_display_workbench_v1_bff_surface_addendum.md
---

# Enterprise Display Case Upload Init Scope Fix BFF Surface

## 1. Surface Objective

- 修正 `enterprise_display` 图片上传初始化在 `BFF` 层遗漏组织作用域的问题。
- 保持 app-facing upload-init contract 不变，不新增第二套上传入口。

## 2. Existing Surface Retained

- 继续使用既有 route：
  - `POST /api/app/file/upload/init`
- request shape 不扩：
  - `businessType`
  - `businessId`
  - `fileKind`
  - `mimeType`
  - `size`
  - `checksum`
- response shape 不扩：
  - `uploadSessionId`
  - `directUpload`
  - `confirm`

## 3. Transport Correction

- 当 `businessType === enterprise_display` 时：
  - `BFF` 必须像 forum command transport 一样转发 command headers
  - 必须携带组织作用域，例如 `x-organization-id`
- 当前不允许：
  - 继续走仅 auth-forward headers
  - 让 `enterprise_display` 上传初始化在缺组织作用域的情况下落到 `Server`

## 4. Error Surface

- 当前 round 只修 transport scope，不扩新 error code family。
- 允许保留既有 `enterprise_display` 中文错误映射。
- 当前不 author：
  - Flutter 端新文案发布
  - 新增 app-facing upload error contract

## 5. Allowed Write Set

- 当前 round `BFF` 只允许：
  - `apps/bff/src/routes/file/file.service.ts`
  - `apps/bff/test/file-enterprise-display-upload-init.test.cjs`

## 6. Anti-revert

- 不得把 `enterprise_display` 回退成仅 auth-forward headers。
- 不得为这个对象新增第二条专用 upload-init route。
- 不得借本轮顺手扩写 project/profile/forum upload 语义。

## 7. Formal Conclusion

- 当前 round `BFF` surface 已冻结为：
  - `existing upload-init route`
  - `enterprise_display command-header forwarding correction only`
