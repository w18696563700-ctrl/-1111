---
owner: 联调发布 Agent
status: draft
purpose: Round 1 证据包：闭合 R1-01 / R1-03 中「探测与配置」；含生效 Nginx 脱敏片段、8080 等价探活、E-SRV-01（Admin 路径错位）单 URL 验证。
layer: L1 证据文书（非真源改写）
evidence_time_utc: 2026-04-01T04:10:04Z（以探活响应内时间戳为准，单次采样）
---

# Round 1 证据文书 — R1-01 / R1-03（联调发布）

**硬约束遵守**：本文书不含口令/密钥；本包**未**执行 R1-02 相关代码修改。

**证据层级（本包自标注）**

| 类型 | 本包是否具备 |
|------|----------------|
| **隧道实测**（本机 `127.0.0.1:8080`） | **否**：执行时本机未建立 SSH 隧道，`8080` 拒绝连接。 |
| **云端进程与配置** | **是**：经已配置的 **SSH 公钥** 登录开发主机 `47.108.180.198`，执行 `nginx -T` 与 `curl http://127.0.0.1:80/...`。 |
| **HTTP 探活等价性** | 隧道命令将远端 **`127.0.0.1:80`** 映到本机 `8080`，故云上 **`curl http://127.0.0.1:80/同一路径`** 与「本机隧道建立后 curl」在**路径与 Nginx 入口**上等价；差异仅在于源 IP 与是否经 SSH 转发。 |

**与 Round 0 对比**：`round0_inventory_release_integration_agent.md` 中 §3 四项 **实际** 均为 **未测**；本包对上述四项及 E-SRV-01 **已完成**云端环回探活，并摘录**线上生效** Nginx（非仅仓库样例）。

---

## 1. 生效 Nginx（线上，脱敏片段）

**来源**：`nginx -T`（含 `# configuration file /etc/nginx/conf.d/exhibition.conf:`）。**脱敏**：未包含证书路径、`server_name` 仍为 `_`（与样例一致）；无密钥。

### 1.1 `upstream bff_upstream` / `server_upstream`

与仓库 `infra/nginx/cloud.conf` **逐字一致**（节选）：

```nginx
upstream bff_upstream {
    server 127.0.0.1:3000;
}

upstream server_upstream {
    server 127.0.0.1:3001;
}
```

### 1.2 `location /health/bff/live`、`location /health/server/live`

与仓库 **一致**（节选）：

```nginx
    location /health/bff/live {
        proxy_pass http://bff_upstream/health/live;
    }

    location /health/server/live {
        proxy_pass http://server_upstream/health/live;
    }
```

**线上多出（仓库 `cloud.conf` 未包含）**：`location /health/bff/ready`、`location /health/server/ready`，分别 `proxy_pass` 至对应 `/health/ready`。——记为 **线上扩展**，非逐字一致项。

### 1.3 `location /api/app/`

**仓库**：单一前缀块，`proxy_pass http://bff_upstream/;`（无前缀改写）。

**线上**：**无**与仓库同构的单一 `location /api/app/ { ... proxy_pass http://bff_upstream/; }`。存在 **多块**（节选，逻辑摘要）：

- `location = /api/app/exhibition/workbench`：`rewrite` → `/bff/exhibition/workbench`，`proxy_pass http://bff_upstream;`
- `location ^~ /api/app/forum/`：`rewrite ^/api/app/(.*)$ /bff/$1 break`，`proxy_pass http://bff_upstream;`
- `location ^~ /api/app/bff/forum/`：类似改写至 `/bff/...`
- `location ~ ^/api/app/(auth|shell|workbench|exhibition|forum|project|...)(/.*)?$`：`rewrite ^/api/app/(.*)$ /bff/$1 break`，`proxy_pass http://bff_upstream;`
- 另有一块针对 `^/api/app/bff/(auth|...)` 的并行正则规则。

**结论**：**不以仓库 `cloud.conf` 代表线上**；**以线上为准**。差异类型：**线上对 `/api/app/*` 增加 BFF 侧 `/bff/` 前缀改写与多 `location` 优先级**，与仓库样例 **非逐字一致**。

### 1.4 `location /api/admin/`

与仓库 **一致**（节选）：

```nginx
    location /api/admin/ {
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://server_upstream/admin/;
    }
```

---

## 2. 8080 最小探测（等价：云上 `127.0.0.1:80`）

**命令形态**（云上执行）：`curl -sS -o body -w '%{http_code}' 'http://127.0.0.1:80<path>'`；响应体取 **前 ≤200 字符**（换行压平，**无密钥**）。

| # | URL（隧道建立后与本机等价） | HTTP | 响应体前缀（≤200 字符，打码：无敏感字段可打码，原样截断） |
|---|-----------------------------|------|-----------------------------------------------------------|
| 1 | `http://127.0.0.1:8080/health/bff/live` | **200** | `{"status":"ok","service":"exhibition-bff","port":3000,"timestamp":"2026-04-01T04:10:04.843Z"}` |
| 2 | `http://127.0.0.1:8080/health/server/live` | **200** | `{"status":"ok","service":"exhibition-server","port":3001,"timestamp":"2026-04-01T04:10:04.852Z"}` |
| 3 | `http://127.0.0.1:8080/api/app/exhibition/home` | **200** | `{"currentLocation":{"displayName":"重庆","provinceCode":null,"provinceName":"重庆","cityName":null,"districtName":null,"latitude":29.56301,"longitude":106.55156,"source":"system_default","persiste`（截断于 200 字符） |
| 4 | `http://127.0.0.1:8080/api/admin/` | **404** | `{"message":"Cannot GET /admin/","error":"Not Found","statusCode":404}` |

**说明**：第 4 项为前缀探测；**404** 表示反代已到达 Server，但 **GET `/admin/` 根** 无路由（非 401/403 鉴权语义）。未再换用其他 Admin 子路径作为主表项，避免与 E-SRV-01 单 URL 要求混淆。

**404 备用路径**：第 3 项已为 **200**，无需再试其他 GET。

---

## 3. E-SRV-01（Admin 路径错位）— 单 URL 探测

**依据（不臆测）**

- 控制器：`apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`  
  - `@Controller('server/admin/exhibition/enterprise-hub')`  
  - `@Get('applications')`  
  → Nest 注册路径为 **`/server/admin/exhibition/enterprise-hub/applications`**（无全局 `setGlobalPrefix`，见 `apps/server/src/main.ts`）。
- 契约：`docs/01_contracts/openapi.yaml` 与 `enterprise_hub_v1_fields_states_api_contract_addendum.md` 中 Admin 列表为 **`GET /server/admin/exhibition/enterprise-hub/applications`**。
- 线上 Nginx：`location /api/admin/` + `proxy_pass http://server_upstream/admin/;` → 对外路径中 **`/api/admin/` 后段** 拼接为上游 **`/admin/<后段>`**。

**单条探测 URL（对外）**

`http://127.0.0.1:8080/api/admin/server/admin/exhibition/enterprise-hub/applications`  
（云上实测：`http://127.0.0.1:80/...`）

**实际到达 Server 的路径（由 Nginx 规则推导，与响应 message 一致）**

`/admin/server/admin/exhibition/enterprise-hub/applications`

| 项 | 内容 |
|----|------|
| **HTTP** | **404** |
| **响应体摘要** | `{"message":"Cannot GET /admin/server/admin/exhibition/enterprise-hub/applications","error":"Not Found","statusCode":404}` |

**结论（三选一）**：**证实 404 或路由错误**  

**理由**：Server 实际匹配路径为 `/admin/server/admin/...`，与控制器/契约要求的 **`/server/admin/exhibition/enterprise-hub/applications`** 不一致；属 **Nginx `/admin/` 前缀与控制器路径中 `server/admin/...` 叠床架屋** 导致的错位（本包仅取证，不修配置）。

---

## 4. 仓库 `infra/nginx/cloud.conf` vs 线上一致性汇总

| 片段 | 与线上一致性 |
|------|----------------|
| `upstream` 两段 | **逐字一致** |
| `/health/bff/live`、`/health/server/live` | **一致** |
| `/health/*/ready` | 仓库样例 **无**；线上 **有** |
| `/api/app/` | **不一致**（仓库单块直转；线上多块 + `rewrite` 至 `/bff/`） |
| `/api/admin/` | **一致**（与错位问题并存：块文本一致，与 Server 路由组合后仍错位） |

---

## 5. 修订记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-04-01 | 首次采集：线上 `exhibition.conf` 摘录、环回 HTTP 探活、E-SRV-01 单 URL 404 结论；本机隧道未开，证据层级已标注。 |
