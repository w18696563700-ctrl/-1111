---
owner: BFF Agent（云端）
status: round0_inventory
purpose: Round 0 仅盘点；登记 BFF 侧现状、证据层级与缺口；不替代云端 SSH/隧道实测。
layer: L0 SSOT
rubric: round0_inventory_review_rubric_and_checklist_draft.md §4、证据槽位表
---

# Round 0 盘点版文书 — BFF（云端）

## 0. 角色声明与证据边界

- **身份**：BFF Agent（七角色工作流中的云端角色之一）；职责边界以仓库根 `AGENTS.md`、`apps/bff/AGENTS.md` 为准。
- **Round 0 禁令**：不改业务逻辑、不改 Nginx 生产配置「为了验证」、不部署发版；**禁止将未实测写成已上线可用**。
- **本文书落盘位置**：monorepo 路径 `docs/00_ssot/round0_inventory_bff_agent_cloud.md`（供总控合并台账）。**云端 release 目录、生效 `nginx -T`、进程监听**等若未在下方标明「隧道实测 / 云端进程与配置」，则视为**未在本轮核验**。
- **隧道基址（团队冻结口径）**：`ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`，验证基址 `http://127.0.0.1:8080`。本文书编制过程中**未执行**该隧道上的 HTTP 探测；该项证据归属**联调发布 Agent** 与/或具备云端登录权限的角色回填。

---

## 1. 与复核总则（rubric §复核总则）的对齐说明

| 总则要点 | BFF 侧说明 |
|----------|------------|
| 仓库内存在 ≠ 线上可用 | `apps/bff` 源码与 `infra/nginx/cloud.conf` 仅构成**仅本地仓库**层证据；不推断云端已同构运行。 |
| 证据须标注层级 | 下文 §3 表与 **§7** 逐条标注；缺实测处显式 **缺口**。 |
| Round 0 零施工 | 本文书为登记物；不包含代码变更、配置变更、发布动作。 |

---

## 2. 与 rubric「路径/端口复核清单」的交叉引用（BFF 相关）

对照 rubric **§路径/端口复核清单** 中样例行：

| 对外 URL 前缀（经 8080） | 仓库样例 `cloud.conf` | 本文书结论（证据层级） |
|--------------------------|----------------------|-------------------------|
| `/health/bff/live` | 已出现 | **仅本地仓库**；隧道实测 **未测**。 |
| `/health/server/live` | 已出现 | **仅本地仓库**；隧道实测 **未测**（属 Server/Nginx 交界，BFF 仅列示）。 |
| `/api/app/...` | 已出现 | **仅本地仓库**；剥离关系见 **§7 E-BFF-02**；云端生效配置 **未测**。 |
| `/api/admin/...` | 已出现（直连 Server） | **仅本地仓库**；与 BFF 无转发关系；隧道实测 **未测**。 |

**样例未配置项（rubric 明确要求不得虚构）**：如 `/health/ready`、`/health/bff/ready`、`/health/server/ready` 在 `infra/nginx/cloud.conf` 中**未出现** → 记为 **N/A（本仓库样例未配置）**；若线上存在，须**云端配置证据**另槽位登记。

---

## 3. §4「BFF Agent（云端）」表 — 逐行填写

> 字段定义见 `round0_inventory_review_rubric_and_checklist_draft.md` §4。

| 字段 | 填写内容 |
|------|----------|
| **工作区路径** | **本轮缺口**：未通过 SSH 列举云端 `release/current`、systemd `WorkingDirectory` 或容器内工作目录。Monorepo 侧镜像路径为 `apps/bff/`（**仅本地仓库**）。总控合并台账时应要求**云端进程与配置**类证据或联调回执补齐 **BFF-CLOUD-WORKDIR**。 |
| **运行方式** | **本轮缺口**：未核验 systemd 单元名、pm2 配置、容器 entrypoint 等。代码入口为 Nest `main.ts` 监听 `0.0.0.0:${PORT}`（**仅本地仓库**）。 |
| **监听端口与 Nginx upstream 是否一致** | **不得宣称已一致**。仓库内：`RuntimeConfigService` 默认 `PORT=3000`（`apps/bff/src/core/runtime/runtime-config.service.ts`）；样例 Nginx `bff_upstream` 指向 `127.0.0.1:3000`（`infra/nginx/cloud.conf`）。二者在**样例层面**对齐，属 **仅本地仓库**。云端实际监听端口与**生效** upstream 是否一致 → **未测**，见 **§7 E-BFF-01**。 |
| **Nginx 挂载路径（对外前缀与上游 URI 映射）** | **以云端生效配置为准**（rubric 强制）；本轮仅有**仓库样例**摘录，见 **§7 E-BFF-02**。样例要点：`/api/app/` → `proxy_pass http://bff_upstream/`（带尾斜杠，URI 前缀剥离）；`/health/bff/live` → 显式 `proxy_pass .../health/live`。 |
| **与 Server 上游关系** | BFF 应用内通过 `SERVER_BASE_URL`（默认 `http://127.0.0.1:3001`）HTTP 调用 Server；超时 `SERVER_GET_TIMEOUT_MS` / `SERVER_POST_TIMEOUT_MS`（**仅本地仓库**）。错误体经 `ErrorNormalizerService` 映射为 `NormalizedErrorBody`。Nginx 层：`/api/admin/` 样例**不经 BFF**，直连 `server_upstream`（**仅本地仓库**）。云端 `SERVER_BASE_URL` 环境真值 **本轮未读**。 |
| **与仓库差异（若有）** | 见 **§5**；**不执行合并或重构**。 |

---

## 4. 当前 BFF 聚合面（仓库快照，非线上可用断言）

- **`RoutesModule` 挂载**：当前仅 `EnterpriseHubModule`（`apps/bff/src/routes/routes.module.ts`），注释说明为 enterprise_hub release-prep slice。
- **未挂载但存在于仓库**：`ForumModule`、`FileModule` 等源码树存在；与「仅 enterprise_hub 挂载」并存时，**不得**推断云端路由集合同构，除非有 **云端进程与配置** 或 **隧道实测** 证据。
- **健康检查**：Nest 路由 `GET /health/live`、`GET /health/ready`（`HealthController`）。是否与对外 `/health/bff/*` 一致取决于 Nginx；样例仅配 `live`。

---

## 5. 与 monorepo `apps/bff` 的关系说明（不执行合并）

| 关系类型 | 说明 |
|----------|------|
| **同构** | 在**未获云端构建 commit / 目录 diff** 的前提下，**不断言**云端与当前 monorepo commit 完全同构。 |
| **分支差异** | 若云端运行分支领先/落后本仓库，或存在未推送提交，属**正常缺口**，须由发布流程或云端 Agent 文字说明（无密钥）。 |
| **仅云补丁** | 若存在仅服务器上的配置文件、环境变量或未入库脚本，本文书**无法枚举**；记 **缺口**，不得写「无差异」。 |
| **登记原则** | 台账合并时以 **证据层级** 区分「仓库镜像」与「云端真相」；BFF Agent 本轮**不进行** git 合并、目录同步或重构。 |

---

## 6. Round 0 施工与配置变更声明（禁令回执）

- **未**修改 `apps/bff` 业务逻辑；**未**为验证目的变更生产或仓库样例外的 Nginx 生效配置；**未**执行部署、发版或迁移。
- rubric **§4「BFF Agent（云端）」表**对应本文 **§3**；rubric **待回填证据槽位** 中 E-BFF 行对应本文 **§7**。

---

## 7. 证据槽位回填 — E-BFF-01、E-BFF-02

> 对应 rubric **§待各角色回填的证据槽位**；可增行延续同一口径。

### E-BFF-01｜BFF 监听端口与 Nginx `bff_upstream` 是否一致

| 子项 | 内容 |
|------|------|
| **声称条目（一句话）** | 云端 BFF 进程监听端口与 Nginx 生效配置中 `bff_upstream` 指向端口一致，且请求可到达 BFF。 |
| **证据层级** | **仅本地仓库**（已具备）：默认端口与样例 upstream 见下。**隧道实测**、**云端进程与配置**：**未具备（未测）**。 |
| **证据摘要 / 指针** | 代码默认端口：`apps/bff/src/core/runtime/runtime-config.service.ts`（`PORT` 未设时 **3000**）。样例 upstream：`infra/nginx/cloud.conf` 中 `bff_upstream` → `127.0.0.1:3000`。 |
| **缺口 / 未测标记** | 缺：`ss`/`netstat`/进程参数脱敏摘录；缺：云端 `nginx -T` 或等价 **生效** 配置中与 `bff_upstream` 一致的片段；缺：`http://127.0.0.1:8080/health/bff/live` 的 curl 状态码（联调发布 Agent 槽位可合并）。**禁止**仅凭仓库样例写「已一致」。 |

### E-BFF-02｜对外前缀 `/api/app/` 与 `proxy_pass` 剥离关系

| 子项 | 内容 |
|------|------|
| **声称条目（一句话）** | 经隧道访问的对外路径 `http://127.0.0.1:8080/api/app/...` 在 Nginx 生效配置下被转发为 BFF 上游的 URI（前缀剥离规则与样例一致）。 |
| **证据层级** | **仅本地仓库**（样例脱敏摘录如下）。**云端进程与配置**、**隧道实测**：**未具备（未测）**。 |
| **证据摘要 / 指针** | 仓库样例 `infra/nginx/cloud.conf`：`location /api/app/` + `proxy_pass http://bff_upstream/;`（`proxy_pass` 带 URI 根 `/` 且尾斜杠与 location 尾斜杠配合时，常规模型为将匹配前缀后的剩余路径接到 `/`）。**具体以云端 `nginx -T` 为准**；若线上 `include` 与仓库分叉，以线上为真相并记差异为缺口。 |
| **缺口 / 未测标记** | 缺：云端生效配置脱敏摘录；缺：任选 `GET/POST http://127.0.0.1:8080/api/app/...` 与 BFF 控制器路径（如 `bff/...`）对照的 HTTP 证据。**禁止**将「仓库样例」写成「线上已验证剥离行为」。 |

#### 附：仓库样例配置摘录（无密钥；非生产断言）

```nginx
upstream bff_upstream {
    server 127.0.0.1:3000;
}

location /api/app/ {
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://bff_upstream/;
}
```

---

## 8. 修订记录

| 版本 | 说明 |
|------|------|
| v0.1 | Round 0 首版：填满 rubric §4 表与 E-BFF-01/E-BFF-02；显式区分仓库证据与未测项。 |

---

## 9. 违禁表述自检（rubric §明确禁止表述）

本文书未使用「已完成开发」「已上线」「已部署到生产」等断言描述本轮行为；对可用性均限定为证据层级或 **未测/缺口**。
