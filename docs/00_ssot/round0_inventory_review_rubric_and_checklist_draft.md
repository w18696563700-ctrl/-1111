---
owner: 结果校验 Agent
status: draft
purpose: Round 0 盘点复核口径与检查单（草案），用于合并各角色盘点回执与总控《项目资产总台账 V1》。
layer: L0 SSOT 配套文书
---

# Round 0 盘点复核口径与检查单（草案）

## 复核总则

1. **仓库内「存在」≠ 线上「可用」**  
   任何资产断言必须标注证据层级（可多选）：  
   - [ ] **仅本地仓库**：路径/文件/模块在 monorepo 中可定位  
   - [ ] **仅文档声称**：仅在 SSOT/回执中出现，未与仓库或线上交叉验证  
   - [ ] **隧道实测**：在 `http://127.0.0.1:8080`（经既定 SSH 隧道）下可复现的 HTTP/行为证据  
   - [ ] **云端进程与配置**：SSH/发布目录/Nginx 生效配置/systemd（或等价）与进程监听的可复核描述或脱敏摘录  

2. **禁止替执行角色圆场**  
   缺口、矛盾、未测项必须显式登记；不得用「应该没问题」「历史已做过」替代证据。

3. **禁止仅凭文字回执放行**  
   总控《项目资产总台账 V1》合并时，每条关键条目应能指回：**证据类型 + 引用位置**（文书段落、命令摘要、脱敏截图说明）。

4. **Round 0 范围内**  
   本检查单只服务「盘点与复核闭合」，不要求、不授权在本轮修复代码、改生产逻辑、迁移、部署或「顺手修复」。

---

## 与总控 Round 0 文书的对照检查项（逐条可勾选）

> 参照文书：`new_workflow_v2_takeover_declaration_round0.md`、`project_status_asset_inventory_round0.md`、`team_organization_freeze_round0.md`、`project_topology_and_tunnel_rules_round0.md`、`zh_incremental_construction_principles_round0.md`、`port_path_mapping_rules_round0_draft.md`、`round0_next_unique_action_round.md`；以及仓库根目录 `AGENTS.md`。

### 新工作流 V2 与 Round 0 边界

- [ ] 已理解：旧工作流范式废弃，但**旧资产保留**，不得重复施工、不得平行重做。
- [ ] 已理解：固定**七角色**编制，其中 `总控文书冻结` 只负责文书收口，不替代总控裁决。
- [ ] 已理解：Round 0 **仅盘点**，**零施工**（不写/改业务代码、不改生产逻辑、不迁移、不部署发布、不顺手修复）；问题**只登记**。
- [ ] 各角色回执中**未**使用下文「明确禁止表述」中的违禁措辞描述 Round 0 行为。

### 拓扑与隧道

- [ ] 已对齐：前端工程**仅本地**（如 `apps/mobile/**`）；BFF 与 Server **仅云端**开发/运行/部署口径与回执一致。
- [ ] 已对齐：本地验证统一经隧道  
  `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`  
  验证基址：`http://127.0.0.1:8080`。
- [ ] 已确认：**密码、密钥、令牌**未写入任何盘点回执、台账字段或本仓库产出物（仅手动输入）。
- [ ] 已强调：隧道用途为访问/验证链路，**不等于**远程编码通道，**不等于**以本地仓库代替云端执行结果。

### 增量原则

- [ ] 已对齐：**先盘点后施工**；仅增量、可追溯；禁止无盘点即实现。
- [ ] 已对齐：边界优先（App-facing 与 Admin 路径族、BFF 不持有业务真相、Server 持有真相）在回执中与 `AGENTS.md` 无未解释的冲突。

### 文书与台账合并就绪度

- [ ] 《项目资产总台账 V1》拟合并字段能对应到：**资产名、所在侧（本地/云）、证据层级、责任人角色、缺口 ID**。
- [ ] 若存在多份历史 SSOT 与当前隧道/主机口径并存，回执中已**显式列出矛盾点**并标记为缺口（不要求 Round 0 改文书修复，但必须登记）。

---

## 路径/端口复核清单（证据型）

**对照样例**：仓库 `infra/nginx/cloud.conf`（监听 `80`，上游 `127.0.0.1:3000` BFF、`127.0.0.1:3001` Server）。

### 样例中已出现的对外 location（应在「隧道 + 云端实际 Nginx」下核验）

| 对外 URL 前缀（经 8080） | 样例行为摘要 | 仓库样例 | 云端实测证据 |
|--------------------------|--------------|----------|--------------|
| `http://127.0.0.1:8080/health/bff/live` | 反代至 BFF `GET /health/live` | ✓ `cloud.conf` | 由各角色回填 |
| `http://127.0.0.1:8080/health/server/live` | 反代至 Server `GET /health/live` | ✓ `cloud.conf` | 由各角色回填 |
| `http://127.0.0.1:8080/api/app/...` | 反代至 BFF；`proxy_pass` 带尾斜杠，上游路径与对外前缀的剥离关系以**云端生效配置**为准 | ✓ `cloud.conf` | 由各角色回填 |
| `http://127.0.0.1:8080/api/admin/...` | 反代至 Server 路径 `/admin/...` | ✓ `cloud.conf` | 由各角色回填 |

### 规则（必读）

- **若历史文书中的路径命名与 `cloud.conf` 不一致**（例如文书中出现的 `/server/admin/*` 与样例中 `/api/admin/`）：  
  - **不以仓库样例单独覆盖线上**，也**不以旧文书单独覆盖线上**；  
  - **以云端实际生效的 Nginx 配置 + `8080` 实测**为准，将差异记为**缺口**或**已对齐说明**（附证据）。
- **`cloud.conf` 样例中未出现的项**（例如 `/health/ready`、`/health/bff/ready`、`/health/server/ready` 等）：  
  - 只能记为 **缺口** 或 **N/A（本环境未配置样例）**，**禁止**虚构为「已在样例中配置」。
- **BFF/Server 监听端口**（样例为 3000/3001）：线上是否一致属于**云端配置证据**，不得仅从仓库推断为已上线可用。

---

## 各角色《盘点版文书 / 收口文书》最低必填字段

### 总控文书冻结

| 字段 | 说明 |
|------|------|
| 工作范围 | 接管声明、组织冻结单、阶段门禁核查表、增量派工单、标准回执模板、阅读顺序、索引与 supersedes 链整理 |
| 允许动作 | 只做现行文书收口、引用链修订、正式版定稿与历史文书降级说明 |
| 禁止动作 | 不新增业务 scope、不独立放行实施/联调/发布、不替代总控做 Go / No-Go |
| 输出物 | 正式版文书包、当前有效文书链、沿用/废止/降级说明 |

### 前端 Agent（仅本地）

| 字段 | Round 0 回填（前端 Agent） |
|------|----------------------------|
| 本地路径范围 | **`apps/mobile/**`**（含 `lib/`、`test/`、`scripts/`、`dev/visual_demo/`）。本轮盘点**不**包含 `apps/bff`、`apps/server`、`apps/admin`；**未**对前述目录做任何代码改动。全文展开见 `docs/00_ssot/round0_inventory_frontend_agent.md`。 |
| 已存在模块/页面清单 | **楼级**：展览 / 消息 / 我的（底栏）；装修、全屋定制为骨架占位（manifest 默认不可见）。**路由注册**：`lib/shell/navigation/app_router.dart`；路径常量 `exhibition_routes.dart`、`profile_routes.dart`、`profile_identity_routes.dart`。**主要 feature**：Shell、`ExhibitionHomePage` + 工作台、交易多页（项目/订单/合同/里程碑/验收/评价/争议）、企业黄页、论坛全链路、`MessagesPage`、`Profile*` 与身份/组织页。索引与表格见 `round0_inventory_frontend_agent.md`。 |
| 与 BFF 基址约定 | **默认**：`http://127.0.0.1:8080/api/app`（`apps/mobile/lib/core/api/app_api_client.dart` 中 `AppApiConfig.defaultBaseUrl`）。**隧道验证基址**：`http://127.0.0.1:8080`（与 `ssh -N -L 8080:127.0.0.1:80 ...` 对齐；对外 `/api/app/...` 经 Nginx 反代至 BFF，以云端生效配置为准）。**覆盖**：环境变量 `APP_BFF_BASE_URL` 或 `--dart-define=APP_BFF_BASE_URL`；可选 `APP_BFF_ACTOR_ID` / `APP_BFF_USER_ID`。 |
| 已知风险（仅列示） | （1）代码内路由与页面体量大于「首期开放」时需总控裁剪入口，避免深链进入未就绪流程。（2）`MessagesPage` 依赖论坛 interaction inbox，与独立「消息域」产品定义可能冲突。（3）dev/文案中直连 IP 与统一隧道口径需后续收敛（Round 0 不施工）。（4）`FakeAppApiTransport` 仅测/演示，**不得**等同生产接入。 |

### BFF Agent（云端）

| 字段 | 说明 |
|------|------|
| 工作区路径 | 云端 release/current 或约定工作目录（只描述） |
| 运行方式 | 进程管理形态（只描述） |
| 监听端口 | 与 Nginx upstream 是否一致 |
| Nginx 挂载路径 | 对外前缀与上游 URI 映射（以**生效配置**为准） |
| 与 Server 上游关系 | 地址、超时、错误传递口径（只描述） |
| 与仓库差异（若有） | 分支/未合并/仅云补丁等，**不执行合并** |

### 后端 Agent（云端）

| 字段 | 说明 |
|------|------|
| （包含 BFF 表全部列） | 同上 |
| 迁移与 DB | 迁移文件存在性、DB 连接方式、环境名（**只描述，不执行迁移**） |
| 状态机/审计等真相边界 | 与 `AGENTS.md` / SSOT 一致的模块级指称 |

### 联调发布 Agent

| 字段 | 说明 |
|------|------|
| 隧道命令是否可复现 | 使用既定命令；不可复现时记缺口 |
| `8080` 下最小探测 URL 列表 | 建议至少覆盖上表「样例已出现」四项中的可访问子路径 |
| 预期 vs 实际 | 每行：**预期状态码/含义** + **实际（未测则写「未测」）** |
| 证据形式 | curl 摘要、HTTP 头/状态（敏感打码）、或等效说明 |

**联调侧建议提供的证据类型（结果校验侧不要求本 Agent 代登录服务器）**

- 脱敏后的 **curl 一行命令 + 状态码 + 响应体前若干字符**（不含密钥）。  
- **Nginx 生效配置**中与 `location`、`proxy_pass`、`upstream` 相关的片段（打码证书路径等）。  
- **current 指向**或 release 目录结构文字说明（无敏感信息）。  
- 截图仅作辅助时，须说明**截取场景**（URL、时间、环境），敏感信息打码。

---

## 判定规则（结果校验 Agent 后续签收用）

| 结论 | 条件 |
|------|------|
| **通过** | 口径闭合；与冻结 Round 0 文书、拓扑、隧道、增量原则无**未登记**的重大矛盾；缺口已显式列出且**不要求** Round 0 内修复。 |
| **有条件通过** | 存在缺口或待补证据，但已**全部登记**且总控可将补齐项**派单至 Round 1**；**未**把未验证当作已验证。 |
| **不通过** | 关键矛盾未解决；或**未验证宣称已验证**；或回执中出现**越权施工**（Round 0 写代码、改生产、迁移、发布等）；或违禁表述污染台账。 |

---

## 明确禁止表述

以下用语**不得**用于描述 Round 0 本轮行为或签收结论（避免与「零施工」冲突）：

- 「已完成开发」「已改动」「已修复」「已上线」「已迁移」「已发布」「已部署到生产」等。  
- 可接受的替代表述示例：「仓库内存在某路径」「文书声称某状态」「隧道下未测」「云端配置待核验」「缺口已登记」。

---

## 待各角色回填的证据槽位

> 合并进《项目资产总台账 V1》前，由总控督促各角色填写；敏感信息打码。

| 槽位 ID | 角色 | 声称条目（一句话） | 证据层级（四选一或多选） | 证据摘要/指针 | 缺口/未测标记 |
|---------|------|--------------------|--------------------------|----------------|----------------|
| E-FE-01 | 前端 | Flutter 客户端在仓库内存在集中路由注册（展览含论坛/企业/交易子链、Profile 子链、楼级 Shell）。 | 仅本地仓库 | 路由：`apps/mobile/lib/shell/navigation/app_router.dart`。路径常量：`apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`、`profile_routes.dart`、`profile_identity_routes.dart`。楼枚举与可见性：`apps/mobile/lib/shell/navigation/app_building.dart`。 | **隧道实测**、**云端进程与配置**：未在本轮由前端角色执行；深链与线上可用性未验证。 |
| E-FE-02 | 前端 | 客户端默认以 `http://127.0.0.1:8080/api/app` 为 BFF 基址，并支持环境/dart-define 覆盖。 | 仅本地仓库 | `apps/mobile/lib/core/api/app_api_client.dart`：`defaultBaseUrl`、`AppApiConfig.fromEnvironment()`、`resolveCanonicalPath`。隧道基址与总控文书一致：`http://127.0.0.1:8080`（见 `project_topology_and_tunnel_rules_round0.md` 等）。不含密钥。 | **隧道实测**：未登记 curl/状态码；**云端 Nginx 剥离规则**是否与本地假设一致待联调角色核验。 |
| E-FE-03 | 前端 | 装修楼与全屋定制楼在代码中存在但默认不可见；首屏底栏仅展览/消息/我的。 | 仅本地仓库 | `apps/mobile/lib/core/config/config_manifest.dart`（`buildingRenovationVisible` / `buildingCustomFurnitureVisible` 默认 `false`）；`app_building.dart` 中 `showsInBottomNavigation`。占位页：`renovation_page.dart`、`custom_furniture_page.dart`。 | **云端 shell/context** 若未来动态改 manifest，与 bootstrap 默认的合并规则未测。 |
| E-FE-04 | 前端 | 论坛、企业黄页、展览交易等通过 `AppApiClient` 调用 `/api/app/...` canonical 路径（非直连 Server Admin）。 | 仅本地仓库 | `forum_consumer_layer.dart`（`/api/app/forum/*` 等）；`enterprise_hub_consumer_layer.dart`（`/api/app/exhibition/enterprise-hub/*`）；`exhibition_consumer_layer.dart` + part `exhibition_canonical_paths.dart`（`project/list` 等）。 | **仅文档声称/隧道实测/云端**：未验证线上响应与契约一致；测试用 `FakeAppApiTransport` 不得记为已接入。 |
| E-DOC-01 | 总控文书冻结 | 当前工作流已收口到七角色，且 `总控文书冻结` 的职责、禁止项、派工链与回执链已正式写入现行文书。 | 仅本地仓库；仅文档声称 | 接管声明、组织冻结单、下一步唯一动作、阶段门禁核查表或等价正式文书中的对应章节。 | 若仍有六角色现行口径未降级，必须显式登记为缺口。 |
| E-BFF-01 | BFF | | | | |
| E-BFF-02 | BFF | | | | |
| E-SRV-01 | 后端 | | | | |
| E-SRV-02 | 后端 | | | | |
| E-REL-01 | 联调发布 | | | | |
| E-REL-02 | 联调发布 | | | | |
| E-CTL-01 | 总控 | 台账合并裁决引用 | | | |

（行数不足可自行复制表格行追加。）

---

## 修订记录

- v0.1 草案：结果校验 Agent 首次拟定，待总控与各角色回填后升版。
- v0.1.1：前端 Agent 回填 §4「前端 Agent」全表与 §7 槽位 E-FE-01～E-FE-04；独立文书见 `round0_inventory_frontend_agent.md`。
