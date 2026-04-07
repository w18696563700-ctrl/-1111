---
owner: 联调发布 Agent
status: active
purpose: Record the development-stage runtime migration, controlled Server release update, tunnel validation, and continuation evidence for the project publish minimum corridor only.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_debug_entry_override_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_source_implementation_validation_signoff.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_bff_implementation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_frontend_consumption_receipt.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊联调验证回执

## 1. 执行范围

- 当前执行轮次：
  - `项目发布最小走廊 / development-stage integration validation round`
- 当前执行主机：
  - `47.108.180.198`
- 当前本地 tunnel：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 当前验收主链：
  - `80 -> 3000/3001`
  - `systemd + /srv/releases/**`
- 当前实际执行动作：
  - 执行最小走廊唯一允许 migration：
    - `20260402_project_publish_minimum_corridor_truth`
  - 受控更新 `Server` active release
  - 复核 `BFF` active release 行为，但**未**重建/替换 `BFF`
  - 使用当前 Flutter login 页 debug-only `测试通道直接进入` 作为
    development-stage route-entry override 辅证
  - 通过本地 `http://127.0.0.1:8080` 实测：
    - `GET /health/bff/live`
    - `GET /health/server/live`
    - `POST /api/app/project/create`
    - `GET /api/app/project/detail?projectId=...`
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
- 当前明确未做：
  - production / staging 发布
  - Nginx 配置修改
  - pm2 / `3100/3101` / `127.0.0.1:18080` 验收
  - bid / order / contract / milestone / inspection / rating / dispute 扩展
  - 把 debug test channel 记为正式 auth / shell / workbench 完成证据

## 2. Migration 执行记录

### 2.1 执行前证据

- `schema_migrations` 中未找到：
  - `20260402_project_publish_minimum_corridor_truth`
- `public` schema 下未找到：
  - `project`
  - `upload_session`
  - `file_asset`
  - `project_publish_audit_log`

### 2.2 执行动作

- 执行位置：
  - 新建 release `/srv/releases/server/20260402124447`
- 执行方式：
  - 使用新 release 编译后的 `dist/core/migrations/migrations.js`
  - 只提取并执行 key：
    - `20260402_project_publish_minimum_corridor_truth`
  - 事务内逐条执行该 key 自带 `7` 条 SQL
  - 成功后向 `schema_migrations` 仅插入该 key
- 执行结果摘要：
  - `applied 20260402_project_publish_minimum_corridor_truth statements 7`

### 2.3 执行后证据

- `schema_migrations` 新增记账：
  - `20260402_project_publish_minimum_corridor_truth | 2026-04-02 12:46:28.895968+08`
- `public` schema 已存在：
  - `project`
  - `upload_session`
  - `file_asset`
  - `project_publish_audit_log`

## 3. Build / Deploy / Restart 记录

### 3.1 Server

| 项 | 记录 |
| --- | --- |
| 本地 build | `cd apps/server && npm run build` 成功 |
| 新 release | `/srv/releases/server/20260402124447` |
| release 基座 | 先复制原 active Server release，以保留 Linux `node_modules` / `pnpm-lock.yaml` |
| 源码覆盖 | 仅覆盖 `apps/server` 当前最小走廊源码包；未写入 secrets |
| 云端 build | 在 `/srv/releases/server/20260402124447` 内 `npm run build` 成功 |
| `AppModule` | 新 release 已 import `ProjectModule` 与 `UploadModule` |
| active 切换 | `/srv/apps/server/current -> /srv/releases/server/20260402124447` |
| restart | `systemctl restart exhibition-server` |
| restart 后状态 | `systemctl is-active exhibition-server = active` |

### 3.2 BFF

| 项 | 记录 |
| --- | --- |
| active runtime 行为 | 当前 `BFF` 主链已可承接 `project/create`、`project/detail`、`file/upload/init`、`file/upload/confirm` |
| 当前 active release | `/srv/releases/bff/20260331195903/apps/bff` |
| 本轮动作 | **未主动执行 build / deploy / release 切换**；active `BFF` release 保持不变 |
| 运行态观察 | `exhibition-bff` 与 `exhibition-server` 的 `ActiveEnterTimestamp` 同为 `2026-04-02 12:47:01 CST`，说明 BFF 在本轮窗口内重新进入了 active，但并未切到新 release |
| 原因 | 本轮最小走廊阻断点集中在 `Server` truth 缺失；active `BFF` 已满足 corridor mapping 与 `confirm.endpoint` 收口，故避免非必要重建 |

## 4. Active Runtime 证据

- `systemctl is-active exhibition-bff exhibition-server nginx`
  - 均为 `active`
- `readlink -f /srv/apps/bff/current`
  - `/srv/releases/bff/20260331195903/apps/bff`
- `readlink -f /srv/apps/server/current`
  - `/srv/releases/server/20260402124447`
- `systemctl show -p WorkingDirectory -p ExecStart exhibition-bff exhibition-server`
  - `BFF`
    - `WorkingDirectory=/srv/apps/bff/current`
    - `ExecStart=/usr/bin/node dist/main.js`
  - `Server`
    - `WorkingDirectory=/srv/apps/server/current`
    - `ExecStart=/usr/bin/node dist/main.js`
- `ss -ltnp`
  - `0.0.0.0:80` -> `nginx`
  - `0.0.0.0:3000` -> `node`
  - `0.0.0.0:3001` -> `node`

## 5. Tunnel Evidence

- 本地 `8080` 先前未监听；本轮重新建立既定 tunnel：
  - `ssh -fN -L 8080:127.0.0.1:80 root@47.108.180.198`
- 本地监听证据：
  - `ssh` PID `25819`
  - `127.0.0.1:8080 (LISTEN)`
  - `[::1]:8080 (LISTEN)`
- tunnel 下健康检查：
  - `GET /health/bff/live -> 200`
  - `GET /health/server/live -> 200`

## 6. 四条 Corridor Path 联调结果表

### 6.1 Tunnel 主链结果

| 路径 | 命令摘要 | 结果 | 关键响应摘要 | 判定 |
| --- | --- | --- | --- | --- |
| `GET /health/bff/live` | `GET http://127.0.0.1:8080/health/bff/live` | `200` | `{"status":"ok","service":"exhibition-bff","port":3000,...}` | 通过 |
| `GET /health/server/live` | `GET http://127.0.0.1:8080/health/server/live` | `200` | `{"status":"ok","service":"exhibition-server","port":3001,...}` | 通过 |
| `POST /api/app/project/create` | 带 `x-actor-id/x-organization-id` 与最小 body 调用 | `202` | `{"projectId":"3babe68d-4727-4929-a9bd-ed23138f6989"}` | 通过 |
| `GET /api/app/project/detail?projectId=<fresh>` | 使用 fresh `projectId=3babe68d-4727-4929-a9bd-ed23138f6989` | `200` | 返回 `projectNo/title/buildingType/budgetAmount/state/summary`，并能命中 fresh project | 通过 |
| `POST /api/app/file/upload/init` | `businessType=project`、`businessId=<fresh>`、`fileKind=evidence`、`mimeType=application/pdf`、`size=25`、`checksum=<sha256>` | `200` | `uploadSessionId=16256fae-dd38-4a30-b677-a08567dd916a`；`directUpload.method=PUT`；`directUpload.url=http://127.0.0.1:9000/...pdf`；`confirm.endpoint=/api/app/file/upload/confirm` | 通过 |
| direct upload | `PUT directUpload.url` with `Content-Type: application/pdf` and 25-byte sample | `ERR` | 本地命中 `URLError(ConnectionRefusedError(61, 'Connection refused'))` | 失败 |
| `POST /api/app/file/upload/confirm` | `{"uploadSessionId":"16256fae-dd38-4a30-b677-a08567dd916a"}` | `200` | `{"fileAssetId":"4dd80061-a862-485e-92b2-8d8ad92713ba"}` | 通过 |

### 6.2 direct upload 失败定位补证

- tunnel 下对 `directUpload.url` 的真实 PUT：
  - 命中 URL：
    - `http://127.0.0.1:9000/exhibition-uploads/project/evidence/2026/04/7da35a1c8a13402fbfb6dcfd937e0a5f.pdf`
  - 本地结果：
    - `Connection refused`
  - 结论：
    - 返回给前端的直传地址当前是**云端 loopback host 字面量**，对本地 tunnel 场景不可用
- 云端本机对同一 URL 的只读补证 PUT：
  - 结果：
    - `403 AccessDenied`
  - 结论：
    - 当前直传 URL 还存在**签名/授权不足**问题，不只是 host 指向问题

## 7. Continuation Evidence

- fresh `projectId` continuation 已被 tunnel live 证实：
  - `POST /api/app/project/create -> 202 + projectId`
  - `GET /api/app/project/detail?projectId=<same>` -> `200`
- `upload init` 返回的 `confirm.endpoint` 已实测为：
  - `/api/app/file/upload/confirm`
- 因此当前前端不会因为 confirm endpoint 漂移到 internal `/server/uploads/confirm` 而 fail-closed。

### 7.1 Flutter debug 测试通道 route-entry override 辅证

- 当前新增门禁依据：
  - `docs/00_ssot/project_publish_minimum_corridor_integration_validation_debug_entry_override_addendum.md`
- 已执行：
  - `cd apps/mobile && flutter test test/shell_app_test.dart --plain-name "debug test channel enters project create without auth or workbench requests"`
  - 结果：
    - `All tests passed!`
- 该测试已证明：
  - login 页存在 `测试通道直接进入`
  - 触发该入口后可进入项目发布入口继续面
  - 不会发起：
    - `POST /api/app/auth/otp/send`
    - `POST /api/app/auth/otp/login`
    - `GET /api/app/exhibition/workbench`
- 当前只允许把该结果登记为：
  - development-stage route-entry override evidence
- 当前**不允许**把该结果登记为：
  - 正式登录成功证据
  - 正式 shell bootstrap 完成证据
  - 正式 workbench 完成证据

### 7.2 Flutter 侧最小辅证

- `cd apps/mobile && flutter test test/shell_app_test.dart --plain-name "project create success carries real projectId to detail"`
  - `All tests passed!`
- `cd apps/mobile && flutter test test/shell_app_test.dart --plain-name "project create page reuses upload init-direct-confirm chain after success"`
  - `All tests passed!`

说明：

- 上述 Flutter 结果只作为本地消费层 continuation 辅证。
- 当前联调主证据仍以 `127.0.0.1:8080` tunnel live 实测为准。

### 7.3 debug entry 覆盖依据下的主链复测

- 本轮在 debug entry override 口径下追加 tunnel 复测，结果如下：
  - `POST /api/app/project/create -> 202`
    - `projectId=51098be3-d1c5-4c24-b318-cd79c83b3048`
  - `GET /api/app/project/detail?projectId=51098be3-d1c5-4c24-b318-cd79c83b3048 -> 200`
  - `POST /api/app/file/upload/init -> 200`
    - `uploadSessionId=7e199c7d-867c-452f-babe-b58ed99ec12b`
    - `confirm.endpoint=/api/app/file/upload/confirm`
  - direct upload:
    - 仍命中 `Connection refused`
  - `POST /api/app/file/upload/confirm -> 200`
    - `fileAssetId=09bf1e4e-268d-4623-8d78-41f2800d7fa6`

## 8. 失败项或保留风险

### 8.1 当前失败项

- direct upload 未闭环：
  - 返回给前端的 `directUpload.url` 当前为 `http://127.0.0.1:9000/...`
  - 在本地 tunnel 场景下会指向**调用方本机**，因此真实 PUT 失败

### 8.2 当前保留风险

- 存储直传签名/授权风险：
  - 云端本机 PUT 同一 URL 返回 `403 AccessDenied`
  - 表明当前 upload init 生成的直传 URL 还不是可直接使用的 signed direct upload URL
- confirm 真相与 transport 真相脱钩：
  - 在 direct upload 失败的情况下，`POST /api/app/file/upload/confirm` 仍返回 `200 + fileAssetId`
  - 当前 confirm 仅依赖 session / binding truth，未校验 object transport 已真实落桶
- BFF 本地源码包未来重建存在回归风险：
  - 本轮未重建 `BFF`
  - active `BFF` 当前已满足 corridor mapping，但后续若要重建 `BFF`，必须先重新核验其 build 打包面与 active runtime 行为一致

## 9. 当前结论

- 当前结论：
  - `不通过`

原因：

- `project/create`
- `project/detail`
- `file/upload/init`
- `file/upload/confirm`

以上四条 app-facing corridor path 已在 tunnel 主链通过。

但 direct upload 是当前最小走廊的强制组成部分，当前真实结果为：

- 本地直传失败：`Connection refused`
- 云端本机同 URL 直传失败：`403 AccessDenied`

因此本轮只能确认：

- `Server` truth 已部署到 development active runtime
- `BFF -> Server` corridor 主链已闭环到 create/detail/init/confirm
- `confirm.endpoint` 与前端 fail-closed 规则保持一致

不能确认：

- `upload init -> direct upload -> confirm` 整体 transport chain 已真正闭环

### 9.1 建议裁决

- 建议总控裁决：
  - `No-Go` for corridor closeout
  - 保持当前轮次为 development-stage integration validation evidence only
- 下一步唯一动作建议：
  - 仅针对 `directUpload.url` 的 host / signing 生成规则做最小修正，并在同一 development 主链上重跑 upload 子链验证

## 10. 修订记录

| 版本 | 日期 | 修订内容 |
| --- | --- | --- |
| v0.1 | 2026-04-02 | 首版落地开发态最小走廊联调验证回执；补入单 key migration 执行记录、Server 主链 release 切换、tunnel live 结果、Flutter continuation 辅证，以及 direct upload 失败定位。 |
| v0.2 | 2026-04-02 | 按 debug entry override 升版：补入 `测试通道直接进入` 的 route-entry 辅证、auth/workbench 非目标边界说明，以及该覆盖依据下的 tunnel 主链复测结果。 |
