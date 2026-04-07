---
owner: 后端 Agent（云端）
status: repaired_not_released
purpose: Record the Server-only repair result for the remaining presigned-URL versus returned-header contract blocker in the project publish minimum corridor upload chain.
layer: L0 SSOT 配套文书
repair_date_local: 2026-04-02
inputs_canonical:
  - docs/00_ssot/project_publish_minimum_corridor_upload_presign_contract_blocker_ruling_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_presign_contract_repair_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_revalidation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_repair_receipt.md
execution_scope:
  - apps/server/src/modules/upload/**
  - apps/server/test/**
  - no BFF change
  - no Flutter change
  - no Admin change
  - no release
---

# 项目发布最小走廊 Server upload presign-contract 修复回执

## 1. 实现范围

本轮只修复一个 Server-only 契约缺口：

1. `upload init` 返回的 `directUpload.headers` 必须与 presigned `PUT` URL 的真实签名契约一致。
2. 保持 `confirm` 的 transport truth gate 不退化，继续拦住 skipped PUT / failed PUT。

本轮未触碰：

- `apps/bff/**`
- `apps/mobile/**`
- `apps/admin/**`
- `infra/**`
- 发布动作

## 2. 改动文件清单

- `apps/server/src/modules/upload/upload-storage.service.ts`
- `apps/server/test/upload-transport.test.cjs`

## 3. 选择的修复方案

本轮采用：

- `方案 A`

即：

- 返回给调用方的必需 headers 必须真实被 presigned URL 签入
- 调用方按返回 contract 发 `PUT` 时，不再因为 `HeadersNotSigned: X-AMZ-META-*` 被 OSS 拒绝

### 3.1 为什么选择方案 A

方案 A 比方案 B 更适合当前最小走廊，因为它：

- 保留了 metadata-based transport truth
- 不需要削弱 `confirm` 侧对 checksum / session / business binding 的验证
- 不需要重新设计 `FileAsset` 形成前的 transport binding truth

如果改走方案 B，就必须去掉 metadata headers，并同步降低 `confirm` 侧验证强度或重造另一套 binding 机制。那会扩大修复面，也会让当前最小走廊的 truth 更弱。

## 4. presign / headers 契约修复说明

### 4.1 修复前问题

修复前：

- `PutObjectCommand` 里带了 metadata
- presigner 默认把 `x-amz-meta-*` hoist 到 query string
- 返回给调用方的却仍是 `x-amz-meta-*` request headers

结果就是：

- URL 的 `X-Amz-SignedHeaders` 只有 `host`
- 调用方一旦按返回 headers 发 `PUT`
- OSS 报 `403 SignatureDoesNotMatch`
- 并提示 `HeadersNotSigned: X-AMZ-META-*`

### 4.2 修复后行为

当前实现把“返回给调用方的 header 集”变成了单一 truth source，并同时用于：

- `directUpload.headers`
- `getSignedUrl(...)` 的 `signableHeaders`
- `getSignedUrl(...)` 的 `unhoistableHeaders`

因此修复后：

- `Content-Type` 会出现在 `X-Amz-SignedHeaders`
- `x-amz-meta-business-type`
- `x-amz-meta-checksum-sha256`
- `x-amz-meta-file-kind`
- `x-amz-meta-upload-session-id`

也都会出现在 `X-Amz-SignedHeaders`

同时这些 metadata headers 不再被 hoist 到 query string。

### 4.3 修复后调用方应发送的 headers

调用方当前应按 `upload init` 返回值发送：

- `Content-Type`
- `x-amz-meta-business-type`
- `x-amz-meta-checksum-sha256`
- `x-amz-meta-file-kind`
- `x-amz-meta-upload-session-id`

这组 headers 现在与 presigned URL 的 signed-header contract 一致。

## 5. confirm truth 是否调整及原因

本轮没有调整 `confirm` 的 truth 判定代码。

原因是：

- 当前问题不是 `confirm` 逻辑错误
- 而是 metadata headers 没有真正进入 signed upload contract

在方案 A 下，metadata headers 现在可以被真实上传，因此既有的 transport verification 继续成立：

- object exists
- `ContentLength == session.size`
- `ContentType == session.mimeType`
- metadata checksum 匹配
- metadata upload-session-id 匹配
- metadata business binding 匹配

因此 `confirm` 不需要同步降级或改弱。

## 6. 新增回归测试说明

本轮升级了 `apps/server/test/upload-transport.test.cjs`。

新增/升级覆盖点：

1. 直接解析 generated presigned URL 的 `X-Amz-SignedHeaders`
2. 断言返回给调用方的 headers 与 signed-header contract 一致
3. 断言 `x-amz-meta-*` 不再出现在 query string
4. 保留 confirm negative-path：
   - 未上传时 `confirm` 仍失败
   - 不创建 `FileAsset`

这条测试就是本轮的 presign-contract regression lock。

## 7. build / test 结果

### 7.1 build

- 命令：
  - `cd apps/server && npm run build`
- 结果：
  - 通过

### 7.2 upload transport tests

- 命令：
  - `cd apps/server && npm run test:upload-transport`
- 结果：
  - `3 passed / 0 failed`

关键测试项：

1. `upload storage service keeps returned headers aligned with presigned PUT contract`
2. `upload storage service rejects loopback public endpoint`
3. `confirm upload fails without transport truth and does not create FileAsset`

### 7.3 额外代码级诊断

在本地 build 后追加读取了一次生成结果，得到：

- `signedHeaders=content-type;host;x-amz-meta-business-type;x-amz-meta-checksum-sha256;x-amz-meta-file-kind;x-amz-meta-upload-session-id`
- `metaInQuery=false`

这说明 metadata headers 已从“query-hoisted but not caller-safe”变成“真实 signed request headers”。

## 8. 仍待联调发布阶段处理的事项

1. 将本轮源码修复部署到开发态 Server runtime
2. 在同一 active runtime 上重跑：
   - `POST /api/app/file/upload/init`
   - direct upload `PUT`
   - `POST /api/app/file/upload/confirm`
3. 记录真实云端结果：
   - 按返回 headers 发 `PUT` 是否 `200`
   - 成功 `PUT` 后 `confirm` 是否返回 `200 + fileAssetId`
   - skipped PUT / failed PUT 后 `confirm` 是否仍稳定 `409`

本轮不宣称：

- 联调完成
- 发布完成

## 9. 修订记录

| 版本 | 日期 | 说明 |
| --- | --- | --- |
| v0.1 | 2026-04-02 | 首版。采用方案 A，使 `directUpload.headers` 与 presigned PUT signed-header contract 同源；新增 presign-contract regression test；保留 confirm negative-path gate；未改 BFF、未改 Flutter、未发布。 |
