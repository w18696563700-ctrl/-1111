---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day6 cloud observation, cleanup result, rollback judgment, and
  backlog closure for the owner-private project attachment readback acceptance
  round after the Server-only file/access release recovered the API path while
  Flutter image rendering still needs a follow-up fix.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/project_attachment_day5_e2e_acceptance_table_addendum.md
  - docs/00_ssot/project_attachment_cloud_chain_day3_day4_evidence_release_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/file/app-file-upload.controller.ts
  - apps/bff/src/routes/file/file.service.ts
  - apps/server/src/modules/upload/upload.controller.ts
---

# 《上线观察与收口单》

## 0A. 2026-04-27 Rerun Addendum

Day6 复测收口结论更新为：`不回滚，测试数据已清理，下一轮只补 Flutter 图片预览渲染`。

当前云上锚点：

```text
Server current=/srv/releases/server/20260427055505-file-access-owner-private-read
BFF current=/srv/releases/bff/20260427034316-project-attachment-list-contract-shape/apps/bff
exhibition-server=active
exhibition-bff=active
nginx /health/server/live=200
nginx /health/bff/live=200
```

本轮清理对象：

```text
project=f520a89c-fcd7-4b87-960f-c0268f941d0c
effect_file_asset=9c373bae-a499-4260-97af-fd98ee1dbe53
document_file_asset=b9940013-0d4c-4241-be60-26465c3a8600
effect_object=project/project_attachment/2026/04/21772b19a936464291572ff89e4d0139.png
document_object=project/project_attachment/2026/04/b41ba1d6c48b4e40bda739c30e8df811.pdf
```

清理结果：

```text
effect_object before=200 after=404
document_object before=200 after=404
db_project=0
db_project_attachments=0
db_file_asset=0
db_upload_session=0
db_codex_sessions=0
```

观察结果：

1. 服务 health 仍为 200。
2. 未观察到附件相关 Nginx 5xx。
3. 清理前 file/access 对两份测试附件均为 200。
4. 清理后出现的少量 `file/access 403/404` 来自测试项目删除后仍在运行的本地 UI 会话请求，
   本地 macOS app 已关闭并杀掉 Flutter run 进程；停止后 30 秒窗口内无新增附件请求。

Rollback judgment：

```text
rollback=NOT_EXECUTED
reason=Server/BFF health ok; file/access API recovered; remaining issue is Flutter image preview rendering, rollback cannot repair it.
```

## 0. Historical Day6 Result Before Server-only Rerun

以下为 Server-only release 之前的历史记录；当前正式判断以 `0A. 2026-04-27 Rerun Addendum`
为准。

Day6 收口结论为：`不回滚 BFF current，清理测试数据，下一轮补 file/access`。

当前更稳的方案：

- 不执行 BFF-only 回滚。当前异常不由 Day4 list-shape BFF release 引入，回滚只会让
  `attachments[]` 退回旧口径风险，不能恢复 `/server/file/access`。

当前更省成本的方案：

- 保持 Server / DB / OSS / Nginx 不动，仅记录缺失路由并进入下一轮定点修复。

当前阶段最适合的方案：

- Day6 以观察和收口为主：保留通过证据，明确阻断项，清理测试数据，锁定 backlog。

风险更大的方案：

- 因 `file/access` 404 直接回滚整栈或重做上传体系，会破坏已经验证通过的写链和 list 链。

## 1. Runtime Observation

当前云上锚点：

```text
BFF current=/srv/releases/bff/20260427034316-project-attachment-list-contract-shape/apps/bff
Server current=/srv/releases/server/20260427005045-forum-inbox-runtime-rebaseline
exhibition-bff=active
exhibition-server=active
nginx /health/bff/live=200
nginx /health/server/live=200
tunnel 127.0.0.1:8080 /health/bff/live=200
```

## 2. 4xx / 5xx Observation

本轮观察到的附件相关请求：

```text
POST /api/app/file/upload/init -> 200
POST /api/app/file/upload/confirm -> 200
POST /api/app/my/projects/{projectId}/attachments -> 200
GET /api/app/my/projects/{projectId}/attachments -> 200
GET /api/app/file/access?fileAssetId=...&mode=preview -> 404
GET /api/app/file/access?fileAssetId=...&mode=download -> 404
```

BFF upstream：

```text
POST /server/uploads/init upstream_status=201
POST /server/uploads/confirm upstream_status=201
POST /server/projects/{projectId}/attachments upstream_status=202
GET /server/projects/{projectId}/attachments upstream_status=200
GET /server/file/access upstream_status=404
```

Nginx error log：

```text
no attachment-related 502 / 503 / 504 observed in the checked window
```

正式判断：

1. 附件写链无 5xx。
2. 附件 list 链无 5xx。
3. 当前唯一阻断是文件访问读路径 `404`。

## 3. Cleanup Result

经用户确认后，已清理本轮隔离测试数据。

清理对象：

```text
project=9d587b87-439b-4f34-97b0-388170ab7b8d
project_attachments=2e2c7790-689c-47a0-bed6-c6018b01d88c,124244fa-43d8-4ffd-b381-37100a083f5a
file_asset=04ddec82-a706-4d3d-81e0-345da251caf3,d70e5351-f9b5-41b3-8da8-725e7c11a6e3
upload_session=d73e9023-20ef-4b93-93fe-ec8b597e2691,031fa5db-d5f6-4bdb-998d-51922937aafe
session=99de8af9-f5ce-4416-b33a-f428ed08ccec
```

OSS 清理结果：

```text
project/project_attachment/2026/04/0dd9ebb7a6ba4098b4132007995b16e4.png
before=200
delete=204
after=404

project/project_attachment/2026/04/ff5d2ca25ccd4059b6d81881442704c7.pdf
before=200
delete=204
after=404
```

DB 清理结果：

```text
project=0
project_attachments=0
file_asset=0
upload_session=0
sessions=0
```

## 4. Rollback Judgment

本轮不执行回滚。

原因：

1. Day4 BFF release 只修 list shape：
   `items[] -> projectId + attachments[]`。
2. Day5 验证证明 list shape 当前是健康状态。
3. 失败点是 BFF 转发到 Server `/server/file/access` 后 Server raw 404。
4. 当前 Server release 未被 Day4 修改。
5. BFF-only 回滚不会生成 Server route，反而可能让 list payload 回到旧口径。

因此当前异常应进入下一轮定点修复，不作为 Day4 BFF release 回滚触发条件。

## 5. Current Minimal Closure

当前最小闭环：

1. Day5 / Day6 证据已经分离：
   - 写链与回显链通过
   - 预览与查看链失败
2. 测试数据已清理。
3. 云上服务仍 active。
4. Nginx 未观察到附件相关 502 / 503 / 504。
5. 下一轮修复对象已明确。

## 6. Retained But Not Opened

继续保留但本轮不开通：

1. Server / DB / OSS 重构。
2. 第二附件 truth family。
3. BFF contract 大改。
4. 公开下载区扩写。
5. 创建页交易化或附件总控台化。

## 7. Backlog

下一轮 backlog 固定为：

1. `P0` 补齐文件访问运行时：
   - 优先补 Server `GET /server/file/access`
   - 或重新冻结并实现 BFF 到现有 Server 能力的合法转发
2. `P0` Flutter 错误提示收敛：
   - `FILE_ACCESS_FAILED` 映射为中文提示
   - 不再展示 `unrecognized error code ... canonical path`
3. `P1` 文档查看承载方式冻结：
   - 外部浏览器
   - WebView
   - 系统下载/打开
4. `P1` 附件命名冻结：
   - `effect_image / construction_doc / other_material`
   - `效果图 / 材质图 / 尺寸图`
5. `P1` BFF contract 统一：
   - 正式返回保持 `projectId + attachments[]`
   - `items[]` 仅作为 Flutter rollback-compatible read fallback

## 8. Final Closure

Day6 closure status：

```text
service_health=PASS
attachment_write_observation=PASS
attachment_list_observation=PASS
file_access_observation=FAIL
test_data_cleanup=PASS
rollback=NOT_EXECUTED_BY_JUDGMENT
next_stage=BLOCKED_ON_FILE_ACCESS_FIX
```
