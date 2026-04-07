---
owner: 联调发布 Agent
status: active
purpose: Record the Server-only deploy/restart and upload sub-chain rerun evidence for the project publish minimum corridor upload presign-contract revalidation rerun.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_revalidation_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_presign_contract_repair_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_revalidation_receipt.md
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊 upload 子链重验证回执

## 1. 执行范围

- 当前执行轮次：
  - `项目发布最小走廊 / upload sub-chain revalidation round`
- 当前执行主机：
  - `47.108.180.198`
- 当前验收主链：
  - `systemd + /srv/releases/**`
  - `80 -> 3000/3001`
- 当前本地 tunnel：
  - 回收失活旧转发后，重建
  - `ssh -fN -L 8080:127.0.0.1:80 root@47.108.180.198`
- 当前严格限定动作：
  - 仅更新 `Server` active runtime
  - 仅复跑 upload 子链：
    - `POST /api/app/file/upload/init`
    - direct upload `PUT`
    - `POST /api/app/file/upload/confirm`
  - 仅补一条负路径：
    - skipped `PUT` 后 `confirm` 必须 `409`
- 当前明确未做：
  - `BFF` release 替换
  - Flutter 源码改动
  - project create/detail 复跑
  - 发布
  - pm2 / `127.0.0.1:18080` 验收

## 2. Server deploy / restart 记录

### 2.1 本地 build / test 复核

- `cd apps/server && npm run build`
  - 成功
- `cd apps/server && npm run test:upload-transport`
  - 成功
  - `3 passed / 0 failed`
- 本轮本地源码已包含 presign-contract repair：
  - `directUpload.headers` 与 presigned PUT signed-header contract 同源
  - regression test 明确校验 `X-Amz-SignedHeaders` 覆盖：
    - `content-type`
    - `host`
    - `x-amz-meta-business-type`
    - `x-amz-meta-checksum-sha256`
    - `x-amz-meta-file-kind`
    - `x-amz-meta-upload-session-id`

### 2.2 upload transport env 注入/核验

- `EnvironmentFile` 位置：
  - `/srv/apps/server/.env`
- 当前已核验为已注入的 upload transport keys：
  - `UPLOAD_S3_PUBLIC_ENDPOINT`
  - `UPLOAD_S3_ENDPOINT`
  - `UPLOAD_BUCKET`
  - `UPLOAD_S3_ACCESS_KEY_ID`
  - `UPLOAD_S3_SECRET_ACCESS_KEY`
  - `UPLOAD_S3_REGION`
  - `UPLOAD_S3_FORCE_PATH_STYLE`
  - `UPLOAD_SIGNED_URL_EXPIRES_SECONDS`
- 当前仅登记非敏感摘要：
  - `UPLOAD_BUCKET=zhanlanzhuangxiuzhijia`
  - `UPLOAD_S3_ENDPOINT=https://s3.oss-cn-chengdu.aliyuncs.com`
  - `UPLOAD_S3_PUBLIC_ENDPOINT=https://s3.oss-cn-chengdu.aliyuncs.com`
  - `UPLOAD_S3_REGION=oss-cn-chengdu`
  - `UPLOAD_S3_FORCE_PATH_STYLE=false`
  - `UPLOAD_SIGNED_URL_EXPIRES_SECONDS=900`
- secret 键状态：
  - `UPLOAD_S3_ACCESS_KEY_ID=present`
  - `UPLOAD_S3_SECRET_ACCESS_KEY=present`
- secrets 未写入本文书或聊天。

### 2.3 受控 release 更新

| 项 | 记录 |
| --- | --- |
| 旧 active Server release | `/srv/releases/server/20260402135217` |
| 新 Server release | `/srv/releases/server/20260402141539` |
| release 制备方式 | 复制旧 active Server release 作为 Linux `node_modules` 基座，再覆盖本地 `apps/server` 最新源码 |
| 云端 build | 在 `/srv/releases/server/20260402141539` 内 `npm run build` 成功 |
| active 切换 | `/srv/apps/server/current -> /srv/releases/server/20260402141539` |
| restart | `systemctl restart exhibition-server` |
| restart 后状态 | `systemctl is-active exhibition-server = active` |

### 2.4 BFF 未变更声明

- 当前 `BFF` active release 仍为：
  - `/srv/releases/bff/20260331195903/apps/bff`
- 本轮未主动执行：
  - `BFF build`
  - `BFF deploy`
  - `BFF release 切换`

## 3. Active Runtime 证据

- `readlink -f /srv/apps/server/current`
  - `/srv/releases/server/20260402141539`
- `systemctl show exhibition-server -p WorkingDirectory -p ExecStart -p FragmentPath -p ActiveEnterTimestamp`
  - `WorkingDirectory=/srv/apps/server/current`
  - `ExecStart=/usr/bin/node dist/main.js`
  - `FragmentPath=/etc/systemd/system/exhibition-server.service`
  - `ActiveEnterTimestamp=Thu 2026-04-02 14:17:27 CST`
- `systemctl is-active exhibition-server`
  - `active`
- 云端直连健康：
  - `GET http://127.0.0.1:3001/health/live -> 200`
  - `GET http://127.0.0.1/health/server/live -> 200`
- tunnel 健康复验：
  - `GET http://127.0.0.1:8080/health/bff/live -> 200`
  - `GET http://127.0.0.1:8080/health/server/live -> 200`

## 4. upload 子链正路径结果

### 4.1 绑定对象与样本

- 本轮未重开 project create/detail。
- upload binding 直接复用现存 project truth：
  - `projectId=51098be3-d1c5-4c24-b318-cd79c83b3048`
- 本轮真实上传样本：
  - `mimeType=application/pdf`
  - `size=77`
  - `checksum=68d3dbe223d4659eb030429ecc280a437eb6e9b042a59797cbbd9e16f56c1d56`

### 4.2 `POST /api/app/file/upload/init`

| 项 | 结果 |
| --- | --- |
| 请求 | `POST http://127.0.0.1:8080/api/app/file/upload/init` |
| 状态码 | `200` |
| `uploadSessionId` | `b1da992d-b987-4518-b168-bfc8409d9e8d` |
| `directUpload.method` | `PUT` |
| `confirm.endpoint` | `/api/app/file/upload/confirm` |
| `confirm.endpoint == /api/app/file/upload/confirm` | `true` |
| `directUpload.url` 是否 loopback host | `false` |
| `X-Amz-SignedHeaders` 摘要 | `content-type;host;x-amz-meta-business-type;x-amz-meta-checksum-sha256;x-amz-meta-file-kind;x-amz-meta-upload-session-id` |

`directUpload.url`：

```text
[REDACTED_EXPIRED_PRESIGNED_OSS_UPLOAD_URL]
```

`directUpload.headers`：

```json
{
  "Content-Type": "application/pdf",
  "x-amz-meta-file-kind": "evidence",
  "x-amz-meta-business-type": "project",
  "x-amz-meta-checksum-sha256": "68d3dbe223d4659eb030429ecc280a437eb6e9b042a59797cbbd9e16f56c1d56",
  "x-amz-meta-upload-session-id": "b1da992d-b987-4518-b168-bfc8409d9e8d"
}
```

判定：

- `directUpload.headers` 已与 `X-Amz-SignedHeaders` 对齐。
- 上一轮的 presign/header mismatch 阻断本轮不再出现。

### 4.3 direct upload `PUT`

按 `upload init` 返回的 `directUpload.method + directUpload.headers` 原样发送真实 PUT：

| 项 | 结果 |
| --- | --- |
| 请求 | `PUT <directUpload.url>` |
| 发送 headers | 与 `directUpload.headers` 完全一致 |
| 状态码 | `200` |
| 是否真实写入成功 | `是` |

成功摘要：

- `Server: AliyunOSS`
- `ETag: "E4FAF65291C537AD6B6FF43FFE557798"`
- `x-amz-request-id: 69CE0B086FA3423838D5D044`
- `x-oss-server-time: 4`

### 4.4 `POST /api/app/file/upload/confirm`

| 项 | 结果 |
| --- | --- |
| 请求 | `POST http://127.0.0.1:8080/api/app/file/upload/confirm` |
| body | `{"uploadSessionId":"b1da992d-b987-4518-b168-bfc8409d9e8d"}` |
| 状态码 | `200` |
| `fileAssetId` | `d311613e-ae0c-49c7-a9a0-0f9fb8561058` |

说明：

- 这是在真实 `PUT -> 200` 之后拿到的 `200 + fileAssetId`。

### 4.5 正路径判定

- 当前正路径：
  - `通过`

闭环：

- `upload init -> 200`
- direct upload `PUT -> 200`
- `upload confirm -> 200 + fileAssetId`

## 5. upload 子链负路径结果

### 5.1 skipped PUT -> confirm

新开一个 upload session，但不执行 PUT，直接 confirm：

| 项 | 结果 |
| --- | --- |
| `upload init` 状态码 | `200` |
| `uploadSessionId` | `b4223ff6-590c-4d9d-bf5c-35757ead7ff9` |
| `confirm.endpoint` | `/api/app/file/upload/confirm` |
| `confirm` 状态码 | `409` |
| `confirm` 错误码 | `FILE_UPLOAD_CONFIRM_REQUIRED` |
| 是否返回 `fileAssetId` | `否` |

响应摘要：

- `message=当前附件上传尚未确认完成，请重新上传后再试。`
- `details.originalMessage=Upload transport object does not exist for upload confirm.`

### 5.2 负路径判定

- 当前负路径：
  - `通过`

说明：

- skipped `PUT` 后 `confirm` 仍被稳定拦截在 `409`
- confirm-side transport truth gate 仍然有效

## 6. 当前 public upload endpoint 摘要

- 当前环境配置的 public upload endpoint：
  - `UPLOAD_S3_PUBLIC_ENDPOINT=https://s3.oss-cn-chengdu.aliyuncs.com`
- 当前 `upload init` 实际返回的 direct host：
  - `zhanlanzhuangxiuzhijia.s3.oss-cn-chengdu.aliyuncs.com`
- 当前 public endpoint 性质：
  - 外部可达
  - 非 loopback
  - 通过本轮真实 `PUT -> 200` 已证成可写入
- 当前 signed-header contract 摘要：
  - `content-type;host;x-amz-meta-business-type;x-amz-meta-checksum-sha256;x-amz-meta-file-kind;x-amz-meta-upload-session-id`
- 当前 contract 状态：
  - `directUpload.headers` 已与 presigned PUT signed headers 对齐
  - 正路径不再出现 `SignatureDoesNotMatch`

## 7. 当前结论

- 当前结论：
  - `通过`

原因：

- 开发态主链 `Server` 已切到本轮最新 presign-contract 修复 release，并完成受控 restart
- `POST /api/app/file/upload/init` 返回了非 loopback、外部可写的 signed PUT URL
- 按返回的 `directUpload.headers` 原样发送真实 `PUT` 已成功
- 随后的 `POST /api/app/file/upload/confirm` 已返回 `200 + fileAssetId`
- skipped `PUT` 的负路径仍被 `409` 正确拦截，且未误发 `fileAssetId`

边界声明：

- 本结论只覆盖 `upload sub-chain revalidation round`
- 这不是发布结论，也不构成 corridor 发布放行

## 8. 修订记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v0.1 | 2026-04-02 | 首版回执。记录上一轮 transport rerun：public endpoint 已切离 loopback，但 presign/header contract 不一致，导致正路径 `PUT 403`、`confirm 409`；负路径 `409` 通过。 |
| v0.2 | 2026-04-02 | 依据 presign-contract repair 复跑。Server-only release 切换到 `/srv/releases/server/20260402141539` 并重启；正路径完成 `200 -> 200 -> 200 + fileAssetId` 闭环；skipped-PUT 负路径保持 `409`；当前结论修订为 `通过`。 |
