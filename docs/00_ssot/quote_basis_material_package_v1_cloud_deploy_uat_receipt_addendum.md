---
owner: Codex 总控
status: frozen
purpose: Record the Aliyun BFF / Server deployment, restart, 8080 route revalidation, and real-account UAT handoff state for Quote Basis Material Package V1.
layer: L0 SSOT
freeze_date_local: 2026-04-27
---

# 《报价依据资料包 V1 云端部署 / 8080 复验 / 真实账号链路回执》

## 1. Scope

本回执只覆盖 `报价依据资料包 V1` 的云端运行态对齐：

- Server release artifact 制备、切换、重启。
- BFF release artifact 制备、切换、重启。
- 8080 隧道路由复验。
- 本地 Flutter 最新代码运行态检查。
- 真实账号链路的当前阻塞点记录。

本回执不扩展：

- 工程量清单。
- 无资格下载。
- 通用 owner-private file/access 放开。
- Nginx 配置修改或重启。

## 2. Release Record

| 项 | 值 |
|---|---|
| Server new current | `/srv/releases/server/20260427205352-quote-basis-material-v1` |
| BFF new current | `/srv/releases/bff/20260427205352-quote-basis-material-v1/apps/bff` |
| Server previous current | `/srv/releases/server/20260427055505-file-access-owner-private-read` |
| BFF previous current | `/srv/releases/bff/20260427034316-project-attachment-list-contract-shape/apps/bff` |
| Server restart | `systemctl restart exhibition-server` |
| BFF restart | `systemctl restart exhibition-bff` |
| Nginx | 未修改、未重启 |

Rollback target 已在云端记录：

- `/srv/shared/rollback-server-before-20260427205352-quote-basis-material-v1.txt`
- `/srv/shared/rollback-bff-before-20260427205352-quote-basis-material-v1.txt`

## 3. Cloud Runtime Verification

| 项 | 结果 | 说明 |
|---|---|---|
| `systemctl is-active exhibition-server` | Pass | `active` |
| `systemctl is-active exhibition-bff` | Pass | `active` |
| Server current pointer | Pass | 指向新 Server release |
| BFF current pointer | Pass | 指向新 BFF release |
| Server migration | Pass | 启动日志显示已应用 `20260427_quote_basis_material_package_v1_attachment_kind_constraint` |
| Server route mount | Pass | 启动日志显示 `/server/projects/:projectId/bid-materials` 与 `/server/file/access` 已挂载 |
| BFF route mount | Pass | 启动日志显示 `/api/app/file/access` 已挂载 |

## 4. 8080 Tunnel Revalidation

| Probe | Result | Judgment |
|---|---|---|
| `GET /api/app/project/bid-materials?projectId=probe` | `404 AUTH_RESOURCE_UNAVAILABLE`, message `当前项目材料清单暂不可读，请稍后再试。` | Pass. 旧 `项目附件` 文案已消失，云上 BFF / Server 已对齐本轮新文案。 |
| `GET /api/app/file/access?fileAssetId=probe&mode=download&projectId=probe&accessScope=bid_material` | `401 AUTH_SESSION_INVALID` | Pass. Route mounted; unauthenticated request is stopped before file access. |
| `GET /api/app/project/bid-materials` | `400 AUTH_RESOURCE_UNAVAILABLE`, message `当前项目不可用。` | Pass. Missing `projectId` is controlled by BFF. |

## 5. Local Flutter Runtime Check

本地 macOS Flutter app 已按当前代码重新 build 并启动：

- build target: `apps/mobile/lib/main.dart`
- base URL: `http://127.0.0.1:8080/api/app`
- runtime entry mode: `ssh_tunnel`

Computer Use 检查结果：

- 首页可打开并读取云上项目列表。
- 项目详情可进入。
- 点击 `立即参与竞标` 后进入登录入口。
- 当前本机没有可直接复用的真实接单方登录态。

因此真实账号完整点击链路当前状态为：

- `Blocked by login handoff`
- 不是 Server / BFF route blocker。
- 不是 Flutter build blocker。
- 需要用户在当前打开的 app 中完成真实账号登录后继续验收。

## 6. Gate Judgment

| Gate | Result |
|---|---|
| Cloud BFF / Server runtime aligned | Pass |
| 8080 route-level UAT | Pass |
| DB migration applied | Pass |
| No owner capability leak at route level | Pass by local tests + route guard |
| Real-account full click UAT | Pending user login |

阶段判断：

- 当前云端路由层已从 No-Go 修正为 Go。
- 当前真实账号完整点击链路仍不能宣布完成，原因是缺真实登录态。
- 用户完成登录后，继续验证 `项目核对 -> 查看报价依据资料 -> 填写报价与服务费确认 -> 上传文档和方案说明 -> 提交竞标`。

## 7. Risk Notes

- 更稳：保留 `bid_material` 专用 access，不放宽通用 owner-private file/access。
- 更省成本：本轮只发布 Server / BFF 当前补丁，不改 Nginx，不迁移 Docker runtime。
- 更适合当前阶段：工程量清单仍留作后续独立阶段。
- 风险更大：在真实账号未登录验证前声称完整业务链路已完成。
