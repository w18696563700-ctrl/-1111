---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day2 frontend convergence verification, Day3 live cloud attachment
  chain evidence, and Day4 bounded BFF response-shape release for the edit-page
  supplement note and owner-private project document zone convergence.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/project_edit_supplement_and_document_zone_convergence_freeze_addendum.md
  - docs/00_ssot/project_attachment_edit_surface_day2_day4_stage_gate_checklist_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/02_backend/project_detail_document_zone_and_public_resource_download_backend_truth_addendum.md
  - docs/04_frontend/project_attachment_corridor_runtime_alignment_frontend_truth_note.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/data/models/project_attachment_read_models.dart
  - apps/mobile/lib/features/exhibition/data/services/project_attachment_contract_mapper.dart
  - apps/mobile/lib/features/exhibition/data/services/project_attachment_contract_validation.dart
  - apps/mobile/test/project_attachment_corridor_test.dart
  - apps/bff/src/routes/my_project/my-project-attachment.service.ts
  - apps/bff/src/routes/my_project/my-project-attachment.read-model.ts
---

# 《云上附件链路证据单与 BFF / Server 分段修复回执》

## 0A. 2026-04-27 Rerun Addendum

本轮继续派工已完成 Day3 / Day4 的补齐：

1. Day3 BFF 仍保持转发边界，不拥有签名逻辑。
2. Day3 只补 smoke 测试：
   - `file/access preview` 转发到 Server
   - `file/access download` 转发到 Server
   - owner-private attachment list 返回 `projectId + attachments[]`
3. Flutter 已把 `FILE_ACCESS_FAILED` 映射为中文兜底文案。
4. Day4 只发布 Server-only release：
   - Server current:
     `/srv/releases/server/20260427055505-file-access-owner-private-read`
   - BFF current 保持不动:
     `/srv/releases/bff/20260427034316-project-attachment-list-contract-shape/apps/bff`
5. 云上 app-facing `GET /api/app/file/access` 已恢复：
   - effect image preview access = 200
   - PDF download access = 200
   - 两个 signed OSS URL 读取均 = 200

本轮本地验证：

```text
apps/bff/test/file-access-forwarding.test.cjs = 3/3 passed
apps/server/test/project-attachment-corridor.test.cjs = 22/22 passed
apps/mobile/test/project_attachment_corridor_test.dart = 13/13 passed
```

本轮边界不变：

- BFF 不签 OSS URL，只转发 Server `/server/file/access`。
- Flutter 不拼 OSS URL，只消费 BFF 返回的 `accessUrl`。
- 上传、confirm、bind、list 逻辑不在 Day3 改动范围内。

## 0. Historical Day2-Day4 Result Before Server-only Rerun

以下为 Server-only release 之前的历史记录；当前正式判断以 `0A. 2026-04-27 Rerun Addendum`
为准。

Day2-Day4 本轮结论固定如下：

1. Day2 本地前端收敛已完成本轮相关回归与 macOS build。
2. Day3 云上真源已定位清楚，真实业务主链是单数表：
   `project / upload_session / file_asset / project_attachments`。
3. Day3 隔离测试项目完整跑通：
   `upload/init -> direct upload -> confirm -> bind -> list`。
4. Day4 只做 BFF response-shape 最小修复：
   App-facing list 从 live `items[]` 收口为冻结 contract 的
   `projectId + attachments[]`。
5. Server 未修改，DB schema 未修改，生命周期和状态机未修改。

当前更稳的方案：

- 只修查实的 BFF 返回形状漂移，不重做上传链路。

当前更省成本的方案：

- 复用现有 `FileAsset + project_attachments` 真相链，只切 BFF release。

当前阶段最适合的方案：

- 先让前端兼容读侧、再把云上 BFF 输出收回冻结 contract，避免页面继续被
  `items / attachments` 漂移拖住。

风险更大的方案：

- 在写链已证实可通的情况下继续大改 Server / OSS / DB，或把问题误判成需要新附件系统。

## 1. Day2 Frontend Result

本地前端已完成：

1. 编辑页标题 `补充说明与附件` -> `补充说明`。
2. 编辑页补充说明下方解释 copy 隐藏。
3. 编辑页 `资料补充` 技术说明段隐藏。
4. 编辑页 `项目详情文书区` 切到清爽态：
   - 隐藏顶部说明
   - 隐藏 `当前说明`
   - 隐藏资料类型解释段落
5. Flutter 项目文书列表兼容：
   - `attachments`
   - `items`
6. 正式列表卡片保留文件名和图片预览入口。

本地验证：

1. `flutter test test/project_attachment_corridor_test.dart test/china_region_catalog_test.dart`
   - passed
   - `15/15`
2. `flutter build macos`
   - passed
   - output: `apps/mobile/build/macos/Build/Products/Release/mobile.app`
3. `flutter test`
   - failed
   - result observed: `482 passed / 116 failed`
   - failure families are existing broad baseline failures:
     - profile page generic type cast
     - forum capture/golden files missing
     - shell/weather old copy assertions
     - standalone UTF-8 network probe connection refused
   - 本轮附件相关回归文件通过，不把全量失败伪装为通过。

## 2. Day3 Live Source Evidence

live runtime:

1. `exhibition-server`
   - active
   - current: `/srv/releases/server/20260427005045-forum-inbox-runtime-rebaseline`
   - ExecStart: `/usr/bin/node dist/main.js`
2. `exhibition-bff` before Day4
   - active
   - current: `/srv/releases/bff/20260427005045-forum-inbox-runtime-rebaseline/apps/bff`
   - ExecStart: `/usr/bin/node dist/apps/bff/src/main.js`

live DB:

```text
db_identity=exhibition_app|exhibition|127.0.0.1/32|5432
table_family=file_asset,file_assets,project,project_attachments,projects,upload_session,upload_sessions
single_chain_counts=project=2|project_attachments=0|file_asset=111|upload_session=99
legacy_counts=projects=0|file_assets=93|upload_sessions=126
```

正式判断：

- 当前 live 业务真相使用单数主链。
- 复数旧表存在，但不得作为本轮附件链路判断依据。

live bucket:

- bucket 通过 `UPLOAD_BUCKET` 配置读取。
- signed direct upload 成功。
- confirmed object `HEAD` 成功。

## 3. Day3 Chain Probe Evidence

隔离测试项目：

```text
trace=codex-day3-1777232431906
test_project_id=cfe5ae67-1493-454d-87fd-e7ac8f8f52ff
test_session_id=5ed1e56a-29cc-4c05-97d9-fdaea86ab3cf
test_organization_id=bdfb4523-aeb7-4b56-89a1-992170fb5d98
```

链路结果：

```text
upload_init_status=200
direct_upload_status=200
upload_confirm_status=200
attachment_bind_status=200
attachment_list_status=200
```

BFF / Server request log evidence:

```text
POST /server/uploads/init upstream_status=201 request_id=codex-day3-1777232431906-upload_init
POST /server/uploads/confirm upstream_status=201 request_id=codex-day3-1777232431906-upload_confirm
POST /server/projects/cfe5ae67-1493-454d-87fd-e7ac8f8f52ff/attachments upstream_status=202 request_id=codex-day3-1777232431906-attachment_bind
GET /server/projects/cfe5ae67-1493-454d-87fd-e7ac8f8f52ff/attachments upstream_status=200 request_id=codex-day3-1777232431906-attachment_list
```

DB evidence before cleanup:

```text
upload_session=1|file_asset=1|project_attachments=1
upload_session_id=6c5aa765-fcce-4a4c-84c1-e203839c3e34
file_asset_id=d408a2c7-e196-4800-86b2-20125a578e2f
project_attachment_id=bf7bc22c-5458-4e13-82fc-afcb5d77b195
file_name=codex-day3-effect.png
attachment_kind=effect_image
object_key=project/project_attachment/2026/04/7afa67dc1a4d44c28456e91dbee70c53.png
```

OSS evidence:

```text
oss_head_status=ok
contentLength=34
contentType=image/png
metadata.business-type=project
metadata.file-kind=project_attachment
metadata.upload-session-id=6c5aa765-fcce-4a4c-84c1-e203839c3e34
```

Day3 判断：

- 写链本身可通。
- 当前查实的云上 drift 是 BFF list 返回 `items[]`，不是冻结 contract 的
  `projectId + attachments[]`。

## 4. Day4 BFF Release

发布范围：

1. 只改 BFF。
2. Server 不动。
3. DB schema 不动。
4. OSS 不动。
5. lifecycle / state machine 不动。

local build:

```text
cd apps/bff && npm run build
result=passed
```

rollback anchors:

```text
prev_bff=/srv/releases/bff/20260427005045-forum-inbox-runtime-rebaseline/apps/bff
prev_server=/srv/releases/server/20260427005045-forum-inbox-runtime-rebaseline
```

new release:

```text
bff_release=/srv/releases/bff/20260427034316-project-attachment-list-contract-shape/apps/bff
server_release=unchanged
```

post-release health:

```text
server local health=200
bff local health=200
nginx bff health=200
nginx server health=200
tunnel 8080 bff health=200
tunnel 8080 server health=200
```

post-release contract smoke:

```text
GET /api/app/my/projects/cfe5ae67-1493-454d-87fd-e7ac8f8f52ff/attachments
status=200
response_shape=projectId + attachments[]
attachments[0].fileName=codex-day3-effect.png
```

request log:

```text
GET /server/projects/cfe5ae67-1493-454d-87fd-e7ac8f8f52ff/attachments upstream_status=200 request_id=codex-day4-list-shape-smoke
```

## 5. Test Data Cleanup

Day3 隔离测试数据已清理，避免污染真实 owner 项目列表。

清理对象：

```text
test_project_id=cfe5ae67-1493-454d-87fd-e7ac8f8f52ff
test_session_id=5ed1e56a-29cc-4c05-97d9-fdaea86ab3cf
upload_session_id=6c5aa765-fcce-4a4c-84c1-e203839c3e34
file_asset_id=d408a2c7-e196-4800-86b2-20125a578e2f
project_attachment_id=bf7bc22c-5458-4e13-82fc-afcb5d77b195
object_key=project/project_attachment/2026/04/7afa67dc1a4d44c28456e91dbee70c53.png
```

清理结果：

```text
oss_delete=ok
remaining=0|0|0|0|0
```

## 6. Current Minimal Closure

当前最小闭环成立：

1. Flutter 编辑页展示口径已收敛。
2. Flutter 可兼容旧 `items` 和新 `attachments`。
3. 云上附件写链已证实可通。
4. 云上 BFF list 已回到冻结 contract：
   - `projectId`
   - `attachments[]`
5. 正式附件卡片所需的 `fileName` 已在 app-facing payload 中返回。

## 7. Retained But Not Opened

本轮继续保留但不开通：

1. 新附件 truth family。
2. 新 attachment kind。
3. `prepublish` 新状态。
4. 草稿态正式附件写入面。
5. Server lifecycle 变更。
6. DB schema 变更。
7. 支付、询价、竞标工作台扩写。

## 8. Follow-up Slots

后续扩展位：

1. 单独清理旧复数表口径的历史文书误导。
2. 单独裁决 `施工图 / 其他资料` 是否改名为 `尺寸图 / 材质图`。
3. 单独补全全量 `flutter test` 基线修复。
4. 单独做 app 登录态下的人工 UI 上传联调。

## 9. Final Gate Status

- Day2 本轮相关前端回归：passed。
- Day2 `flutter build macos`：passed。
- Day2 full `flutter test`：failed due existing broad baseline failures.
- Day3 live truth source：passed。
- Day3 dedicated chain evidence：passed。
- Day4 BFF bounded fix：passed。
- Day4 Server / DB / state no-change：passed。
