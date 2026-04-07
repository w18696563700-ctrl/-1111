---
owner: 后端 Agent（云端）
status: repaired_not_released
purpose: Record the Server-only upload transport repair result for the project publish minimum corridor, limited to signed direct-upload generation and confirm-side transport truth verification.
layer: L0 SSOT 配套文书
repair_date_local: 2026-04-02
inputs_canonical:
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_blocker_ruling_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_repair_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
execution_scope:
  - apps/server/src/modules/upload/**
  - apps/server/src/core/runtime-config.service.ts
  - apps/server/package.json
  - apps/server/test/**
  - no BFF change
  - no Flutter change
  - no Admin change
  - no release
---

# 项目发布最小走廊 Server upload transport 修复回执

## 1. 实现范围

本轮只修复 upload 子链的两个同源问题：

1. `upload init` 的 `directUpload.url` 不再返回 loopback/bare object URL，而是生成开发态外部可达、带签名的 S3-compatible `PUT` URL。
2. `upload confirm` 只有在 transport object 已被 `HEAD` 验证为真实存在且绑定信息一致后，才允许创建 `FileAsset` truth。

本轮未触碰：

- `apps/bff/**`
- `apps/mobile/**`
- `apps/admin/**`
- `docs/**` 以外的实现文书
- `infra/nginx/**`
- 任何无关模块

## 2. 改动文件清单

- `apps/server/package.json`
- `apps/server/src/core/runtime-config.service.ts`
- `apps/server/src/modules/upload/upload-storage.service.ts`
- `apps/server/src/modules/upload/upload-write.service.ts`
- `apps/server/test/upload-transport.test.cjs`

## 3. direct-upload generation 修复说明

### 3.1 修复内容

当前实现已从“字符串拼接 object URL”切换为“真正的 presigned PUT URL”：

- 新增 S3-compatible SDK 依赖：
  - `@aws-sdk/client-s3`
  - `@aws-sdk/s3-request-presigner`
- `upload init` 现在使用 `PutObjectCommand + getSignedUrl(...)` 生成 presigned `PUT` URL
- `directUpload.headers` 现在显式携带：
  - `Content-Type`
  - `x-amz-meta-checksum-sha256`
  - `x-amz-meta-upload-session-id`
  - `x-amz-meta-business-type`
  - `x-amz-meta-file-kind`

### 3.2 采用的外部 upload endpoint 形态

本轮采用的形态是：

- `开放 :9000` 或同等的外部可达 S3-compatible endpoint
- 通过 `UPLOAD_S3_PUBLIC_ENDPOINT` 注入给 presign client

同时保留一个独立的 server-side transport verification endpoint：

- `UPLOAD_S3_ENDPOINT`

其含义是：

- `UPLOAD_S3_PUBLIC_ENDPOINT`
  - 给本地测试操作者/前端 `PUT` 使用
  - 必须是开发态外部可达 endpoint
- `UPLOAD_S3_ENDPOINT`
  - 给 Server 自己做 `HEAD object` 校验使用
  - 可与 public endpoint 相同，也可走云端本机/内网 endpoint

### 3.3 为什么这是当前开发态最小修正

这是当前最小修正，因为它：

- 保持修复完全在 `Server` 内完成
- 不需要改 BFF path family
- 不需要改 Flutter upload flow
- 不需要改 Nginx / ingress
- 只要求开发态注入外部可达的 S3-compatible public endpoint

换句话说，本轮不去改代理层，而是让 `Server` 直接为“真实外部可用的对象存储入口”签名，这比重开 ingress 更窄。

### 3.4 127.0.0.1 防退化

当前实现已加显式防退化：

- 若 `UPLOAD_S3_PUBLIC_ENDPOINT` 缺失
  - `upload init` 直接 controlled fail
- 若 `UPLOAD_S3_PUBLIC_ENDPOINT` 指向：
  - `127.0.0.1`
  - `localhost`
  - `::1`
  - `upload init` 直接 controlled fail

因此当前不会再把 `127.0.0.1` 作为 `directUpload.url` 返回给外部调用方。

## 4. confirm truth 修复说明

### 4.1 修复前问题

修复前：

- `confirm` 只依赖 upload session/binding truth
- 即使真实 `PUT` 未成功，也可能返回 `200 + fileAssetId`

### 4.2 修复后行为

修复后，`POST /server/uploads/confirm` 在创建 `FileAsset` 前，必须先通过 transport truth verification：

- `HEAD object`
- 校验 object 存在
- 校验 `ContentLength == upload_session.size`
- 校验 `ContentType == upload_session.mimeType`
- 校验 metadata:
  - `checksum-sha256`
  - `upload-session-id`
  - `business-type`
  - `file-kind`

只要其中任一项不成立：

- `confirm` 直接 controlled fail
- 不创建 `FileAsset`
- 不写回 `session.fileAssetId`
- 不记录 success audit

### 4.3 负路径如何证明不再误发 `fileAssetId`

本轮新增测试已证明：

- 当 storage verifier 报告 “transport object does not exist”
- `confirm` 会抛出 controlled failure
- `fileAssetRepository.save` 不会被调用
- `uploadSessionRepository.save` 不会被调用
- success audit 不会被记录

这说明当前 `confirm` 不再能在 skipped PUT / failed PUT 条件下误发 `200 + fileAssetId`。

## 5. runtime config 需求说明

本轮新增的最小 runtime config keys：

- `UPLOAD_S3_ENDPOINT`
  - Server 做 `HEAD object` 验证时使用的 S3-compatible endpoint
- `UPLOAD_S3_PUBLIC_ENDPOINT`
  - 返回给操作者/前端的 presigned public upload endpoint
- `UPLOAD_S3_REGION`
- `UPLOAD_S3_ACCESS_KEY_ID`
- `UPLOAD_S3_SECRET_ACCESS_KEY`
- `UPLOAD_S3_FORCE_PATH_STYLE`
- `UPLOAD_SIGNED_URL_EXPIRES_SECONDS`
- `UPLOAD_BUCKET`

说明：

- secrets 只从 env 读取
- 未写入 repo 常量
- 未写入 docs 真源之外的任何源码常量表

## 6. build / 测试结果

### 6.1 build

- 命令：
  - `cd apps/server && npm run build`
- 结果：
  - 通过

### 6.2 upload transport tests

- 命令：
  - `cd apps/server && npm run test:upload-transport`
- 结果：
  - `3 passed / 0 failed`

覆盖项：

1. signed URL generation
   - 证明生成结果 host 来自外部 public endpoint
   - 证明 URL 含 `X-Amz-Signature`
2. loopback public endpoint rejection
   - 证明不会再返回 `127.0.0.1`
3. confirm negative path
   - 证明未上传时 confirm 失败
   - 证明不会创建 `FileAsset`

### 6.3 本轮未做的验证

- 未做 BFF 联调复测
- 未做 Flutter 侧复测
- 未做开发态 Server deploy/restart
- 未做云端 live PUT / HEAD / confirm 实测

因此本轮结论只能是：

- source repair completed
- build/test completed
- not yet integration-complete
- not released

## 7. 仍待联调发布阶段处理的事项

1. 在开发态注入真实可用的：
   - `UPLOAD_S3_PUBLIC_ENDPOINT`
   - `UPLOAD_S3_ENDPOINT`
   - bucket / access key / secret / region / path-style
2. 受控重启 Server，使新 upload transport logic 生效
3. 重跑最小 upload 子链：
   - `POST /api/app/file/upload/init`
   - direct upload `PUT`
   - `POST /api/app/file/upload/confirm`
4. 记录真实云端结果：
   - public upload endpoint 是否可达
   - real PUT 是否成功
   - skipped PUT / failed PUT 时 confirm 是否稳定失败

## 8. 修订记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v0.1 | 2026-04-02 | 首版。完成 presigned PUT URL generation、loopback public endpoint rejection、confirm-side transport truth verification、最小 runtime config 注入位与 `node:test` 级验证；未改 BFF、未改 Flutter、未发布。 |
