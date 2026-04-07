---
owner: 后端 Agent（云端）
status: round0_inventory
purpose: Round 0 唯一交付物（后端）；仅盘点登记，不执行迁移、不改表、不改生产配置、不发布。
layer: L0 SSOT
rubric_ref: docs/00_ssot/round0_inventory_review_rubric_and_checklist_draft.md §4、§7
evidence_note: 本文对「云端实况」未作 SSH/隧道实测；云端字段以「待核验」或联调角色证据槽位为准，避免将仓库推断等同线上。
---

# Round 0 盘点版文书 — 后端（云端）

## 1. 适用范围与证据层级声明

- **角色口径**：后端 Agent（七角色工作流中的云端角色之一）；正式施工与运行以**云服务器工作区**为准；本地 monorepo 仅作契约与实现快照参照。
- **Round 0 边界**：只登记、不施工；**未**执行迁移、**未**改生产配置、**未**发布。
- **证据层级**（见 rubric §复核总则）：本文中「仓库内可定位」标为 **仅本地仓库**；「云端路径/进程/Nginx 生效文件」若无附件命令或脱敏摘录则标为 **未测/待核验**，不宣称已验证。

---

## 2. 对照 rubric §4「后端 Agent（云端）」表（逐行填写）

> 说明：下列「继承 BFF 表」列与 rubric §「BFF Agent（云端）」一致；后端 Agent 增补 **迁移与 DB**、**真相边界指称**。

| 字段 | 填写内容 |
|------|----------|
| **工作区路径** | **云端（待核验）**：组织惯例多为 `release/current` 或等价部署目录；**仅本地仓库**：`apps/server/**`、`apps/server/src/core/migrations/migrations.ts`。二者是否一致未在 Round 0 内由本角色交叉验证。 |
| **运行方式** | **云端（待核验）**：常见为 systemd/pm2/容器等进程托管，具体以主机为准。**仅本地仓库**：NestJS `main.ts` 监听 `RuntimeConfigService.port`，无全局路由前缀声明。 |
| **监听端口** | **仓库样例**：`infra/nginx/cloud.conf` 中 `server_upstream` 指向 `127.0.0.1:3001`。**云端（待核验）**：是否与样例一致属云端配置证据，不得仅从仓库推断为已上线可用（rubric §路径规则）。 |
| **Nginx 挂载路径** | **仅本地仓库**：`cloud.conf` 中 `location /api/admin/` → `proxy_pass http://server_upstream/admin/`（剥离对外 `/api/admin/` 前缀后，上游 URI 形如 `/admin/...`）。**云端生效配置（待核验）**：须以主机实际 `nginx -T` 或等价脱敏摘录为准。 |
| **与 Server 上游关系** | **仅本地仓库**：BFF 经 `ServerClientService` 使用配置的 `serverBaseUrl` 直连 Server（与对外 Nginx 路径族独立）；超时等见 BFF `server-client.service.ts`。**云端（待核验）**：`SERVER_*` 环境变量或内网基址是否与仓库约定一致未测。 |
| **与仓库差异（若有）** | **已登记缺口**：见 §4「Admin 路径族与控制器前缀」、§7 证据槽位；不执行合并或补丁。 |
| **迁移与 DB** | **仅本地仓库**：`enterpriseHubMigrations`（键 `20260401_enterprise_hub_v1_truth`）在 `apps/server/src/core/migrations/migrations.ts` 中声明多表 DDL；`AppModule` 使用 TypeORM + PostgreSQL，`synchronize: false`。**未观测到**启动链路自动执行该迁移数组（`main.ts`/`CoreModule` 未引用）。**云端 DB（待核验）**：是否已手工/脚本落表、连接串与环境名未由本文书实测。**Round 0：不执行迁移。** |
| **状态机/审计等真相边界** | **与 AGENTS.md 对齐**：Server 应拥有域真源、状态机、审计；禁止在控制器堆叠状态迁移。**仅本地仓库现状**：Enterprise Hub 的申请/上架/推荐位等状态变更在 `enterprise-hub-write.service.ts`、`enterprise-hub-admin.service.ts` 等服务层；**未见**独立审计写入模块；论坛/上传等真源路径在 BFF 侧有上游调用，**本仓库 Server 无对应控制器**（缺口）。**SSOT**：`docs/00_ssot/enterprise_hub_v1_*`、`enterprise_hub_v1_fields_states_api_contract_addendum.md` 等需与实现逐条对照，Round 0 内未完成字段级闭合（登记为待总控派单）。 |

---

## 3. 路径复核（与 rubric §「路径/端口复核清单」对齐 — Server 相关）

| 对外 URL 前缀（经 8080） | 样例行为摘要 | 仓库样例 | 云端实测证据（本文书） |
|--------------------------|--------------|----------|-------------------------|
| `http://127.0.0.1:8080/health/server/live` | 反代至 Server `GET /health/live` | ✓ `infra/nginx/cloud.conf` | **未测**（待联调角色 E-REL-xx） |
| `http://127.0.0.1:8080/api/admin/...` | 反代至 Server 路径 `/admin/...` | ✓ `cloud.conf` | **未测**；与控制器前缀关系见 §4 |

`cloud.conf` **未**配置 `health/server/ready` 等项：记 **N/A（样例未出现）**，不虚构已配置。

---

## 4. Admin 路径族：`/api/admin/` 与仓库样例、代码注册路径对照

### 4.1 仓库样例 `infra/nginx/cloud.conf`（证据层级：**仅本地仓库**）

```31:37:infra/nginx/cloud.conf
    location /api/admin/ {
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://server_upstream/admin/;
    }
```

- 语义摘要：对外请求 `/api/admin/{suffix}` → 上游 `http://127.0.0.1:3001/admin/{suffix}`（`suffix` 为剥离前缀后的剩余路径）。

### 4.2 Server 控制器注册（证据层级：**仅本地仓库**）

- Admin：`@Controller('server/admin/exhibition/enterprise-hub')` → 完整 HTTP 路径段以 `/server/admin/exhibition/enterprise-hub` 为根（见 `enterprise-hub-admin.controller.ts`）。
- 与样例组合推断：若对外仅使用 `/api/admin/exhibition/enterprise-hub/...`，则上游为 `/admin/exhibition/enterprise-hub/...`，**与** Nest 注册的 `/server/admin/...` **缺少同一 `server` 前缀**，存在**路径不一致风险**。
- **例外可能（待核验，不替云端圆场）**：云端 Nginx 另有 `rewrite`、`server` 全局前缀、或 Admin 客户端实际调用 `/api/admin/server/admin/...` 等；**必须以云端生效配置 + 8080 实测为准**（rubric §规则）。

### 4.3 一致性结论（Round 0 登记）

| 项 | 结论 |
|----|------|
| 云端生效 Nginx 是否与 `cloud.conf` 逐字一致 | **待核验**（缺 SSH/脱敏 `nginx -T` 摘录） |
| 仓库样例与当前 Nest Admin 控制器路径 | **已登记潜在矛盾**（§4.2）；**缺口 ID**：路径族对齐验证（建议并入联调最小探测集） |

---

## 7. 待各角色回填的证据槽位（对照 rubric §7）

### 7.1 E-SRV-01、E-SRV-02 及增行（迁移与 DB：只描述现状，不执行迁移）

| 槽位 ID | 角色 | 声称条目（一句话） | 证据层级（四选一或多选） | 证据摘要/指针 | 缺口/未测标记 |
|---------|------|--------------------|--------------------------|----------------|----------------|
| **E-SRV-01** | 后端 | 仓库样例将 `/api/admin/` 代理为上游 `/admin/...`，而 Nest Admin 控制器注册在 `server/admin/...` 路径下，二者是否存在额外 rewrite 或调用约定未在 Round 0 验证。 | 仅本地仓库；云端进程与配置（待补齐） | `infra/nginx/cloud.conf` L31–37；`apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts` `@Controller('server/admin/...')` | **未测**：云端生效 Nginx；8080 下 Admin 探测 URL 与状态码 |
| **E-SRV-02** | 后端 | Enterprise Hub DDL 以 `enterpriseHubMigrations` 形式存在于仓库；TypeORM `synchronize: false`；启动代码未引用该迁移数组；云端 DB 是否已落表未测。 | 仅本地仓库 | `apps/server/src/core/migrations/migrations.ts`；`apps/server/src/app.module.ts`（TypeORM 配置）；`apps/server/src/main.ts` | **未测**：目标环境库表清单与迁移执行记录；**Round 0 不执行迁移** |
| E-SRV-03 | 后端（增行） | Server 侧论坛与上传真源接口在 BFF 上游路径中被调用，但本仓库 Server 无对应实现，与「BFF 不持有业务真相、Server 持有」的拓扑要求存在实现空缺或代码不同步。 | 仅本地仓库 | BFF：`apps/bff/src/routes/file/file.service.ts`（`/server/uploads/init` 等）；`apps/bff/src/routes/forum/forum.service.ts`（`/server/forum/*`）；Server：无 `forum`/`uploads` 控制器注册 | **缺口**：云端 Server 是否另有分支/补丁未入库；或联调失败根因 |

### 7.2 模块与 `AGENTS.md` / SSOT 对齐 — 矛盾与缺口（真相边界指称）

| 模块/能力 | 仓库内位置 | 与根目录 `AGENTS.md` / `apps/server/AGENTS.md` | 与 SSOT 文书 | 矛盾或缺口 |
|-----------|------------|-----------------------------------------------|--------------|------------|
| Core 健康检查 | `apps/server/src/core/health.controller.ts` | Server 负责进程可观测性；与「两进程两端口」拓扑兼容 | 未在本文逐条引用单份 SSOT | `cloud.conf` 样例未暴露 `ready` 对外 location（N/A） |
| Enterprise Hub Truth / Admin | `enterprise-hub-*.controller.ts`、`*-write.service.ts`、`*-admin.service.ts` | 真源在 Server；Admin API 在 Server；禁止控制器堆叠状态机（服务层承载迁移） | `docs/00_ssot/enterprise_hub_v1_*`、`enterprise_hub_v1_fields_states_api_contract_addendum.md` 等 | 案例/资质常量与字段存在，**服务层未见完整审核流**；身份依赖头上下文，**未见**与 AGENTS 宣称等级对等的独立审计模块 |
| Forum / Uploads / File | —（Server 侧） | Server 应持业务真相；BFF 仅聚合 | `forum_implementation_unlock_addendum.md` 等（论坛例外边界） | **本仓库 Server 无实现**；与 BFF 上游路径不对齐 → **拓扑/代码同步缺口** |
| 迁移 | `core/migrations/migrations.ts` | Server 拥有迁移 | 与 enterprise_hub 冻结文书应对照 | DDL **未绑定**应用启动执行链 |

**真相边界指称（汇总）**：Enterprise Hub 列表/详情/申请/上架等状态判断保留在 Server 服务层，符合「关键状态不下沉到 BFF」的架构意图；论坛与文件链路的真源若在缺失模块处由其他运行时补齐，则超出本仓库可指称范围，须由 **E-SRV-03** 与云端证据闭合。

---

## 8. 禁止事项与措辞自检（Round 0）

- 本文**未**使用 rubric §「明确禁止表述」中的「已完成开发」「已迁移」「已发布」等宣称。
- 对线上状态统一使用：**待核验**、**未测**、**缺口已登记**、**仓库内存在**。

---

## 9. 修订记录

- v0.1：后端 Agent 按 `round0_inventory_review_rubric_and_checklist_draft.md` §4 表与 §7 槽位起草；Admin 路径族对照 `infra/nginx/cloud.conf`；不执行迁移与配置变更。
- v0.2：§7 拆为 7.1 证据表与 7.2 模块/SSOT 对齐表；修正文内交叉引用。
