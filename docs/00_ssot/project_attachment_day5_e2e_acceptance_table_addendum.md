---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day5 end-to-end acceptance result for owner-private project
  attachment readback, covering UI, BFF, DB, and OSS evidence for effect-image
  and document attachments, and separating the recovered file-access API path
  from the remaining Flutter image-rendering issue.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/project_attachment_day5_1_flutter_image_preview_rendering_patch_freeze_addendum.md
  - docs/00_ssot/project_edit_supplement_and_document_zone_convergence_freeze_addendum.md
  - docs/00_ssot/project_attachment_cloud_chain_day3_day4_evidence_release_receipt_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/04_frontend/project_attachment_corridor_runtime_alignment_frontend_truth_note.md
  - apps/mobile/scripts/run_macos_formal.sh
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_preview_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/bff/src/routes/file/app-file-upload.controller.ts
  - apps/bff/src/routes/file/file.service.ts
---

# 《附件回显验收表》

## 0B. 2026-04-27 Day5.1 Flutter Image Preview Patch

Day5.1 复验结论更新为：`图片预览像素渲染已通过，Day5 附件回显闭环可放行`。

本轮只改 Flutter 图片预览承载：

1. 仍通过 `GET /api/app/file/access` 获取 Server 签名后的 `accessUrl`。
2. Flutter 不拼 OSS URL，不读取或外露 `objectKey`。
3. 正式效果图预览由 `Image.network(accessUrl)` 改为：
   `accessUrl bytes fetch -> Image.memory(bytes)`。
4. 下载 bytes 失败时显示中文错误，并保留系统外部打开兜底。
5. 上传、confirm、bind、list、BFF 转发、Server 签名和 owner 校验均未改。

本地验证：

```text
apps/mobile/test/project_attachment_corridor_test.dart = 14/14 passed
```

云上复验项目：

```text
project=4d5fcbe3-5720-406a-b041-d8819611b75b
server_current=/srv/releases/server/20260427055505-file-access-owner-private-read
bff_current=/srv/releases/bff/20260427034316-project-attachment-list-contract-shape/apps/bff
```

云上链路证据：

```text
list_shape=projectId+attachments
file=codex-image-preview-20260427061316-effect-32.png
file_asset_id=425363fc-34aa-4897-bbf3-27e916ce0e42
attachment_id=918e4f4c-67dd-4e25-9d77-06efabbe3081
file_access_preview=200
signed_oss=200|image/png|99 bytes
signed_sha256=c3d2aadfc27ff1d8bc99c488de7b37cfe289f352235fcc59d7b8b45449395f62
```

macOS UI 复验证据：

```text
route=/exhibition/projects/edit?projectId=4d5fcbe3-5720-406a-b041-d8819611b75b
formal_list_filename=codex-image-preview-20260427061316-effect-32.png
preview_dialog=图片预览
render_carrier=Image.memory
accessibility=image element present
visual_pixels=red 32x32 PNG rendered
error_copy_absent=当前图片暂时无法预览
```

Gate judgment：

```text
upload_to_list=PASS
ui_file_name_readback=PASS
document_view=PASS
file_access_api=PASS
db_truth=PASS
oss_object=PASS
image_preview_dialog=PASS
image_pixels_rendered=PASS
overall=PASS
```

## 0A. 2026-04-27 Rerun Addendum

Day5 复测结论更新为：`大部分通过，图片预览视觉渲染未满绿`。

已恢复：

1. Server-only release 已上线，BFF current 未动。
2. BFF list 返回 `projectId + attachments[]`。
3. `GET /api/app/file/access` 对 effect image preview 返回 200。
4. `GET /api/app/file/access` 对 PDF download 返回 200。
5. 两个 signed OSS URL 均可读取：
   - image/png = 200
   - application/pdf = 200
6. macOS UI 的项目详情文书区可显示两个文件名。
7. macOS UI 点击 `预览文书` 后显示 `已打开文书预览。`
8. macOS UI 点击 `预览图片` 后可打开 `图片预览` 弹窗。

仍未满绿：

1. `图片预览` 弹窗内 `Image.network(accessUrl)` 进入错误态：
   `当前图片暂时无法预览，请稍后再试`。
2. 该问题发生时 BFF / Server / signed OSS URL 均为 200，因此当前剩余风险不是
   `file/access` 路由缺失，也不是 DB / OSS 写链缺失，而是 Flutter 远程图片渲染承载风险。

本轮最终 API / DB / OSS 证据：

```text
bff_list_shape=projectId+attachments
bff_item=codex-codex-attach-20260427040737-effect.png|effect_image|image/png
bff_item=codex-codex-attach-20260427040737-document.pdf|other_material|application/pdf
file_access_effect=200|signed=200|image/png|99 bytes
file_access_document=200|signed=200|application/pdf|45 bytes
db_effect=effect_image|image/png|99|project/project_attachment/2026/04/21772b19a936464291572ff89e4d0139.png
db_document=other_material|application/pdf|45|project/project_attachment/2026/04/b41ba1d6c48b4e40bda739c30e8df811.pdf
```

Gate judgment：

```text
upload_to_list=PASS
ui_file_name_readback=PASS
document_view=PASS
file_access_api=PASS
db_truth=PASS
oss_object=PASS
image_preview_dialog=PASS
image_pixels_rendered=FAIL
overall=NO-GO_UNTIL_IMAGE_RENDER_FIX
```

## 0. Historical Day5 Result Before Server-only Rerun

以下为 Server-only release 之前的历史记录；当前正式判断以 `0A. 2026-04-27 Rerun Addendum`
为准。

Day5 端到端验收结论为：`部分通过，正式验收不放行`。

已通过：

1. 测试项目创建并进入 `submitted`。
2. 效果图上传链路通过：
   `upload/init -> direct upload -> confirm -> bind -> list`。
3. PDF 文档上传链路通过：
   `upload/init -> direct upload -> confirm -> bind -> list`。
4. BFF list 返回冻结 contract：
   `projectId + attachments[]`。
5. DB 写入与 OSS 对象存在均已核验。
6. macOS UI 中正式列表可回显文件名。

未通过：

1. 图片预览失败。
2. 文档查看失败。
3. 失败根因定位到当前 Server release 缺少 `/server/file/access` 路由；
   BFF `GET /api/app/file/access` 转发后收到 raw `404 Cannot GET /server/file/access`。

当前更稳的方案：

- 保持 Day4 BFF list-shape release 不回滚；把 `file/access` 缺失作为下一轮
  Server / BFF contract-runtime 对齐缺口处理。

当前更省成本的方案：

- 不重做上传链，不改 DB / OSS / 状态机，只补缺失的文件访问读路径与前端错误文案。

当前阶段最适合的方案：

- 记录 Day5 为 `list 回显通过、预览/查看阻断`，不要把失败扩大解释为附件写链失败。

风险更大的方案：

- 直接回滚 BFF current 指针，既不能修复 `/server/file/access`，还会让 list payload
  退回旧 `items[]` 风险。

## 1. Test Fixture

测试会话与项目均为本轮隔离数据，已在 Day6 清理。

```text
project_id=9d587b87-439b-4f34-97b0-388170ab7b8d
project_state=submitted
organization_id=bdfb4523-aeb7-4b56-89a1-992170fb5d98
session_id=99de8af9-f5ce-4416-b33a-f428ed08ccec
runtime_entry=http://127.0.0.1:8080/api/app
```

附件样本：

```text
effect_file_name=codex-day5-effect.png
effect_file_asset_id=04ddec82-a706-4d3d-81e0-345da251caf3
effect_attachment_id=2e2c7790-689c-47a0-bed6-c6018b01d88c
effect_object_key=project/project_attachment/2026/04/0dd9ebb7a6ba4098b4132007995b16e4.png

document_file_name=codex-day5-document.pdf
document_file_asset_id=d70e5351-f9b5-41b3-8da8-725e7c11a6e3
document_attachment_id=124244fa-43d8-4ffd-b381-37100a083f5a
document_object_key=project/project_attachment/2026/04/ff5d2ca25ccd4059b6d81881442704c7.pdf
```

## 2. Four-layer Acceptance Table

| 层级 | 验收项 | 结果 | 证据 |
|---|---|---:|---|
| UI | 正式列表显示效果图文件名 | PASS | macOS UI 显示 `codex-day5-effect.png` |
| UI | 正式列表显示文档文件名 | PASS | macOS UI 显示 `codex-day5-document.pdf` |
| UI | 图片点击预览 | FAIL | 点击 `预览图片` 后提示 `FILE_ACCESS_FAILED` |
| UI | 文档点击查看 | FAIL | 点击 `预览文书` 后提示 `FILE_ACCESS_FAILED` |
| BFF | 附件 list route | PASS | `GET /api/app/my/projects/{projectId}/attachments -> 200` |
| BFF | list response shape | PASS | 返回 `projectId + attachments[]` |
| BFF | 文件访问 route | FAIL | `GET /api/app/file/access?... -> 404 FILE_ACCESS_FAILED` |
| DB | `project_attachments` 写入 | PASS | 两条 attachment row，与 fileName / kind 对齐 |
| DB | `file_asset` 写入 | PASS | 两条 file asset row，与 businessType / businessId / fileKind 对齐 |
| OSS | 效果图对象存在 | PASS | `HEAD -> 200`, `Content-Type=image/png`, `Content-Length=68` |
| OSS | PDF 对象存在 | PASS | `HEAD -> 200`, `Content-Type=application/pdf`, `Content-Length=381` |

Day5 要求是“四层一致才算通过”。当前 UI / BFF / DB / OSS 的正式列表回显链一致，
但查看 / 预览链不一致，因此整体验收不得写 PASS。

## 3. Write Chain Evidence

效果图链路：

```text
POST /api/app/file/upload/init -> 200
direct upload -> 200
POST /api/app/file/upload/confirm -> 200
POST /api/app/my/projects/9d587b87-439b-4f34-97b0-388170ab7b8d/attachments -> 200
GET /api/app/my/projects/9d587b87-439b-4f34-97b0-388170ab7b8d/attachments -> 200
```

文档链路：

```text
POST /api/app/file/upload/init -> 200
direct upload -> 200
POST /api/app/file/upload/confirm -> 200
POST /api/app/my/projects/9d587b87-439b-4f34-97b0-388170ab7b8d/attachments -> 200
GET /api/app/my/projects/9d587b87-439b-4f34-97b0-388170ab7b8d/attachments -> 200
```

BFF upstream log：

```text
POST /server/uploads/init upstream_status=201
POST /server/uploads/confirm upstream_status=201
POST /server/projects/9d587b87-439b-4f34-97b0-388170ab7b8d/attachments upstream_status=202
GET /server/projects/9d587b87-439b-4f34-97b0-388170ab7b8d/attachments upstream_status=200
```

## 4. List Payload Evidence

正式 list payload 关键结构：

```text
projectId=9d587b87-439b-4f34-97b0-388170ab7b8d
attachments[0].fileName=codex-day5-effect.png
attachments[0].attachmentKind=effect_image
attachments[0].mimeType=image/png
attachments[1].fileName=codex-day5-document.pdf
attachments[1].attachmentKind=other_material
attachments[1].mimeType=application/pdf
```

## 5. File-access Failure Evidence

API 失败证据：

```text
GET /api/app/file/access?fileAssetId=04ddec82-a706-4d3d-81e0-345da251caf3&mode=preview
-> 404 FILE_ACCESS_FAILED

GET /api/app/file/access?fileAssetId=d70e5351-f9b5-41b3-8da8-725e7c11a6e3&mode=download
-> 404 FILE_ACCESS_FAILED
```

BFF upstream 失败证据：

```text
GET /server/file/access upstream_status=404
originalMessage=Cannot GET /server/file/access?fileAssetId=...&mode=preview
```

代码核查：

1. BFF 当前存在 app-facing route：
   `GET /api/app/file/access`。
2. BFF 当前转发到：
   `/server/file/access`。
3. 当前 Server source / active dist 只看到：
   `/server/uploads`。
4. 当前未看到 Server `GET /server/file/access` controller。

## 6. Current Minimal Closure

当前最小闭环成立部分：

1. 正式附件写链可通。
2. 正式附件列表可回显。
3. 页面正式卡片可显示文件名。
4. DB 与 OSS 真相对齐。

当前未闭环部分：

1. 图片预览。
2. 文档查看。
3. `file/access` contract-runtime 对齐。

## 7. Retained But Not Opened

本轮继续不开放：

1. 新附件 truth family。
2. 新 attachment kind。
3. DB schema 重做。
4. OSS 目录规则重做。
5. 创建页内第二附件工作台。

## 8. Follow-up Slots

下一轮 backlog 固定为：

1. 补齐 Server `GET /server/file/access` 或重新冻结 BFF 文件访问转发 truth。
2. Flutter 把 `FILE_ACCESS_FAILED` 映射为用户可读中文，不再显示
   `unrecognized error code ... canonical path`。
3. 继续保留 BFF list contract 为 `projectId + attachments[]`。
4. 单独冻结 `施工图 / 其他资料` 与 `材质图 / 尺寸图` 命名映射。

## 9. Gate Conclusion

Day5 gate status：

```text
upload_to_list=PASS
ui_file_name_readback=PASS
db_truth=PASS
oss_object=PASS
file_preview=FAIL
document_view=FAIL
overall=NO-GO
```
