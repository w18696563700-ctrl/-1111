---
owner: Codex 总控
status: frozen
purpose: >
  Record and close the bid-submit upload-init invalid-parameter defect caused by
  missing Server upload file-kind support for bid required attachments.
layer: L3 Backend Truth
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
  - docs/04_frontend/exhibition_bid_submit_template_download_and_uniform_attachment_cards_frontend_surface_addendum.md
  - docs/00_ssot/gate_register_v1.md
---

# 《竞标提交附件 upload init fileKind 修复 backend truth addendum》

## 1. Defect

- 用户在竞标提交页上传 `项目理解` 时，前端卡片显示：
  - `当前上传初始化参数无效，请稍后再试。`
- 前端实际组包为：
  - `businessType = project`
  - `fileKind = bid_project_understanding`
  - `businessId = projectId`
  - `mimeType / size / checksum` 来自本地选中文件

## 2. Root Cause

- Flutter App 的 bid submit 附件 `fileKind` 是正确的。
- BFF 只做 app-facing upload init 转发与错误归一。
- Server `UploadWriteService.ensureSupportedUploadBinding()` 仍只允许：
  - `project/evidence`
  - `project/project_attachment`
  - profile 与 enterprise_display 若干上传类型
- Server 没有把竞标提交三类必传附件加入 upload init 白名单：
  - `bid_project_understanding`
  - `bid_quote_sheet`
  - `bid_schedule_plan`
- 因此 Server 返回 `FILE_UPLOAD_INIT_INVALID`，Flutter App 最终展示为上传初始化参数无效。

## 3. Repair

- Server upload init 对 `businessType=project` 新增竞标附件白名单：
  - `bid_project_understanding`
  - `bid_quote_sheet`
  - `bid_schedule_plan`
- MIME 规则冻结为：
  - `项目理解`：PNG / JPEG / WEBP / PDF / DOC / DOCX
  - `报价表`：XLS / XLSX / PDF / DOC / DOCX
  - `进度安排`：PDF / DOC / DOCX / XLS / XLSX
- Flutter App 同步修正本地 MIME 前置判断：
  - `项目理解` 不再把 XLS / XLSX 当成可上传类型。

## 4. Validation

```bash
cd apps/server
npm run build
node --test test/upload-transport.test.cjs
```

- Result:
  - build passed
  - upload transport `8/8` passed

```bash
cd apps/mobile
flutter test test/shell_app_test.dart --plain-name "bid submit"
```

- Result:
  - bid submit `16/16` passed

## 5. Formal Conclusion

- 当前缺陷不是 submit 页排版引起。
- 当前缺陷根因是 Server upload init 支持矩阵漏登记 bid required attachment fileKind。
- 修复后 bid submit 三类必传附件可以进入标准三段上传链：
  - init
  - direct upload
  - confirm
