---
owner: 后端 Agent（云端｜配合）
status: draft
purpose: Round 1 R1-01 只读配合联调发布；不执行迁移、不改表、不发版、不实现 R1-02。
layer: L1 配合文书（可与联调证据文书交叉引用；真源位置由总控裁定）
cross_ref: docs/00_ssot/round1_r1_01_r1_03_evidence_release_integration.md
---

# Round 1 R1-01 — 后端配合说明（只读）

## 1. 硬约束（本包）

- **未**执行 DDL / 迁移；**未**擅自变更生产 Nginx 或 Server 配置；**未**发版；**未**实现 R1-02。
- 本文件在 **Cursor 工作区** 内撰写：对云主机的 `ss` / `systemd` **未由本 Agent 在本机直接执行**；端口与 upstream 一致性优先引用 **联调发布证据包** 中已登记的环回探活结果（见 §2）。

---

## 2. Server 监听端口与 `server_upstream`（只读结论）

### 2.1 仓库样例（仅本地仓库）

`infra/nginx/cloud.conf` 中：

```5:7:infra/nginx/cloud.conf
upstream server_upstream {
    server 127.0.0.1:3001;
}
```

### 2.2 联调侧探测（证据层级：云端进程与配置 + HTTP 环回）

依据 `round1_r1_01_r1_03_evidence_release_integration.md` §1.1、§2：

- 生效 Nginx 中 `server_upstream` 与仓库样例 **逐字一致**（`127.0.0.1:3001`）。
- `GET http://127.0.0.1:80/health/server/live`（隧道下等价 `8080`）响应体含 **`"port":3001`** 且 `service` 为 exhibition-server。

**摘要对照**：在单次采样下，**Server 自报监听端口与 `server_upstream` 目标端口一致**；未发现与 upstream 声明冲突的脱敏证据。

### 2.3 若具备 SSH 只读权限时可补充的脱敏形态（非本包已执行）

以下仅供总控或持有主机权限的角色 **只读** 归档，**非**本仓库自动产出：

- `ss -lntp` 或 `ss -lnup` 摘要一行：确认 `3001` 监听进程名（打码 PID/用户如需）。
- `systemctl status <server-unit>` 或等价：`Active:` / `Main PID` 一行摘要（无环境变量全文）。

---

## 3. E-SRV-01：Admin 控制器前缀 — 只读事实确认

**事实（不修改代码、不修改 Nginx）**

- 文件：`apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`
- 装饰器：`@Controller('server/admin/exhibition/enterprise-hub')`
- 应用入口：`apps/server/src/main.ts` **未**调用 `setGlobalPrefix`。

因此，在默认 Nest 路由规则下，Admin 列表接口注册路径为：

**`/server/admin/exhibition/enterprise-hub/applications`**（示例方法 `@Get('applications')`）。

契约侧同路径指称见联调文书引用：`docs/01_contracts/openapi.yaml` 与 `enterprise_hub_v1_fields_states_api_contract_addendum.md`（联调证据文书 §3 已列）。

---

## 4. 联调探测结果 vs 本地认知 — 一致 / 矛盾 / 待解释

**一致**：仓库 `infra/nginx/cloud.conf` 中 `server_upstream` → `127.0.0.1:3001` 与联调摘录的 **生效 Nginx** 一致；`health/server/live` 返回的 **port=3001** 与 upstream 目标一致。本地对「Server 使用 3001、与样例 upstream 对齐」的认知与联调侧 **一致**。

**矛盾**：本地已知的 **对外 Admin 映射**（`location /api/admin/` → 上游 URI 前缀 `/admin/`）与 **控制器根路径**（`/server/admin/...`）组合后，无法在不额外约定的情况下自然得到契约路径；联调文书 E-SRV-01 单 URL 探测得到 **404** 及 message 中与 **`/admin/server/admin/...`** 叠前缀一致的现象，与「仅使用 `/api/admin/` 直拼契约后缀」的朴素预期 **矛盾**。

**待解释**：对外 Admin 的 **规范 URL**（是否应在 `/api/admin/` 后保留 `server/admin/...`、或是否应由 Nginx `rewrite`、或是否调整 Server 全局前缀）属于 **契约 / 网关 / 总控** 裁决项；本配合包 **不** 选定方案、**不** 落地 R1-02。

---

## 5. 与联调真源的关系

- 详细 HTTP 表、Nginx 全文摘录、E-SRV-01 单 URL 原文：以 **`round1_r1_01_r1_03_evidence_release_integration.md`** 为准。
- 本文建议作为 **R1-01 后端只读配合** 的 SSOT 指针；若总控合并为「联调文书附录」，可将 §2–§4 整体迁入该附录并保留交叉引用。

---

## 6. 修订记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-04-01 | 首次：端口/upstream 引用联调证据；E-SRV-01 事实确认；一致/矛盾/待解释三段。 |
