---
owner: 联调发布 Agent
status: draft
purpose: Round 0 盘点 + 只读补证文书；基于本地隧道实测与云端只读核验登记联调发布真实资产；零施工、零部署、零发版。
layer: L0 SSOT 配套文书
rubric_ref: docs/00_ssot/round0_inventory_review_rubric_and_checklist_draft.md
evidence_time_utc: 2026-04-01T18:50:17Z
---

# Round 0 盘点版文书 — 联调发布（只读补证版）

本文书仅执行 **Round 0 真实拓扑只读补证**。本轮已实际使用：

- **本地隧道实测**：`127.0.0.1:8080 -> 47.108.180.198:80`
- **云端进程与配置**：开发主机 `47.108.180.198` 只读 SSH
- **仅本地仓库**：用于对照 BFF / Server controller 前缀与仓库样例
- **仅文档声称**：仅用于环境/回滚基线口径，不替代实测

**本轮未执行且明确禁止：**

- 不修改 `apps/bff`、`apps/server`、`infra/nginx`、`env`、数据库、systemd、pm2、docker
- 不 reload Nginx，不 restart 服务，不 deploy，不发版
- 不把仓库样例写成云端已生效

---

## 1. 本轮实际执行范围

### 1.1 本地执行范围

- 识别本地 `8080` 监听占用
- 复用既有隧道进程，不强杀未知进程
- 通过 `http://127.0.0.1:8080` 执行 HTTP 只读探测
- 将结果回写本地正式文书 `docs/00_ssot/round0_inventory_release_integration_agent.md`

### 1.2 云端执行范围

- 只读 SSH 进入 `47.108.180.198`
- 只读查看：
  - `/etc/nginx/conf.d/*.conf`
  - `/srv/apps/*/current`
  - `systemd` unit、active 状态、WorkingDirectory、ExecStart
  - 监听端口
  - 云端本机 `curl http://127.0.0.1:80/...`
  - 云端本机 `curl http://127.0.0.1:3000/...`、`3001/...`

### 1.3 执行过程中的失败登记

- 一次云端批量直探命令因本地转义组装错误未产出有效结果。
- 处理方式：未修改云端任何内容，改用更保守的 shell 循环命令重跑。
- 影响：**无最终证据缺失**；本轮 required 直探已补齐。

---

## 2. 证据层级说明

| 层级 | 本文含义 |
|------|----------|
| **仅本地仓库** | 仓库内源码、样例配置、controller 前缀、脚本存在性；不代表云端已生效 |
| **隧道实测** | 本机通过 `127.0.0.1:8080` 访问云端 `80` 的真实 HTTP 结果 |
| **云端进程与配置** | 云端只读 SSH 获得的 Nginx、生效目录、systemd、监听端口、云端本机 HTTP 结果 |
| **仅文档声称** | SSOT 中的环境/回滚/基线说明；不替代实时配置与运行证据 |

---

## 3. 本地隧道证据

### 3.1 隧道状态

| 项 | 证据层级 | 结果 |
|----|----------|------|
| `8080` 是否被占用 | **隧道实测** | 已占用 |
| 占用进程类型 | **隧道实测** | `ssh` |
| 是否新建隧道 | **隧道实测** | **否**，复用既有进程 |
| 是否强杀占用进程 | — | **否** |

### 3.2 隧道进程摘录

本地只读核验结果：

```text
lsof -nP -iTCP:8080 -sTCP:LISTEN
ssh  PID 82714  127.0.0.1:8080 / [::1]:8080 (LISTEN)

ps -p 82714 -o pid=,ppid=,state=,command=
82714     1 Ss   ssh -fN -L 8080:127.0.0.1:80 root@47.108.180.198
```

### 3.3 隧道结论

- 本地 `8080` 当前 **不是新建成功**，而是 **复用成功**。
- 复用对象与冻结命令完全一致：`ssh -fN -L 8080:127.0.0.1:80 root@47.108.180.198`
- 隧道后续 HTTP 探测均返回可解析响应，故本轮可登记为 **隧道实测已成立**。

---

## 4. 云端生效 Nginx 证据

### 4.1 云端 conf.d 文件清单

**证据层级：云端进程与配置**

```text
/etc/nginx/conf.d/
- exhibition.conf
- exhibition-staging-smoke.conf
- exhibition.conf.bak.20260322144156
- exhibition.conf.bak.20260328042948
```

### 4.2 主联调链：`exhibition.conf`

**证据层级：云端进程与配置**

云端生效文件摘录（脱敏）：

```nginx
1  upstream bff_upstream {
2      server 127.0.0.1:3000;
5  upstream server_upstream {
6      server 127.0.0.1:3001;
10     listen 80 default_server;
11     server_name _;
14     location /health/bff/live {
15         proxy_pass http://bff_upstream/health/live;
18     location /health/bff/ready {
19         proxy_pass http://bff_upstream/health/ready;
22     location /health/server/live {
23         proxy_pass http://server_upstream/health/live;
26     location /health/server/ready {
27         proxy_pass http://server_upstream/health/ready;
31     location = /api/app/exhibition/workbench {
37         rewrite ^/api/app/exhibition/workbench$ /bff/exhibition/workbench break;
38         proxy_pass http://bff_upstream;
41     location ^~ /api/app/forum/ {
47         rewrite ^/api/app/(.*)$ /bff/$1 break;
48         proxy_pass http://bff_upstream;
61     location ~ ^/api/app/(auth|shell|workbench|exhibition|forum|project|bid|order|milestone|file|message|profile|platform|contract|inspection|rating|dispute)(/.*)?$ {
67         rewrite ^/api/app/(.*)$ /bff/$1 break;
68         proxy_pass http://bff_upstream;
81     location /api/admin/ {
87         proxy_pass http://server_upstream/admin/;
```

### 4.3 旁路 smoke 链：`exhibition-staging-smoke.conf`

**证据层级：云端进程与配置**

云端另有一套本机 smoke 链，不在当前 `80 -> 3000/3001` 主联调链上：

```nginx
1  upstream bff_staging_smoke_upstream { server 127.0.0.1:3100; }
5  upstream server_staging_smoke_upstream { server 127.0.0.1:3101; }
10 listen 127.0.0.1:18080;
30 location ^~ /api/app/forum/ { ... rewrite ^/api/app/(.*)$ /bff/$1 break; proxy_pass http://bff_staging_smoke_upstream; }
58 location ~ ^/api/app/(shell|workbench|forum|project|bid|order|milestone|file|message|profile|platform|contract|inspection|rating|dispute)(/.*)?$ { ... proxy_pass http://bff_staging_smoke_upstream; }
```

### 4.4 Nginx 结论

- `80` 后确有 Nginx 主链，且 upstream 真实指向：
  - `127.0.0.1:3000`
  - `127.0.0.1:3001`
- `/api/app/*` **不是**仓库样例中的单块 `proxy_pass http://bff_upstream/;`
- 当前真实闭环依赖 **云端额外 rewrite**：`/api/app/(.*)` -> `/bff/$1`
- `/api/admin/` 当前真实写法仍是：`proxy_pass http://server_upstream/admin/;`
- 当前发现的不是“80 后没挂服务”，而是“80 后已挂服务，但 `/api/admin/` 外部路径与 Server controller 前缀不闭环”

---

## 5. 云端 current / release / 进程监听证据

### 5.1 `current` 与 `release`

**证据层级：云端进程与配置**

```text
readlink -f /srv/apps/bff/current
/srv/releases/bff/20260331195903/apps/bff

readlink -f /srv/apps/server/current
/srv/releases/server/20260401023418

ls -ld /srv/apps/bff/current /srv/apps/server/current
/srv/apps/bff/current -> /srv/releases/bff/20260331195903/apps/bff
/srv/apps/server/current -> /srv/releases/server/20260401023418
```

**结论：**

- 当前 `3000/3001` 主联调链满足 **非 workspace 源码目录运行** 门禁。
- `bff` 当前 release 路径虽嵌套到 `.../apps/bff`，但仍位于 `/srv/releases/**`，不是 `/srv/workspaces/**`。

### 5.2 systemd 与监听端口

**证据层级：云端进程与配置**

```text
systemctl is-active exhibition-bff      -> active
systemctl is-active exhibition-server   -> active
systemctl is-active nginx               -> active

systemctl show exhibition-bff
WorkingDirectory=/srv/apps/bff/current
ExecStart=/usr/bin/node dist/main.js
FragmentPath=/etc/systemd/system/exhibition-bff.service

systemctl show exhibition-server
WorkingDirectory=/srv/apps/server/current
ExecStart=/usr/bin/node dist/main.js
FragmentPath=/etc/systemd/system/exhibition-server.service

ss -ltnp
0.0.0.0:80    -> nginx
0.0.0.0:3000  -> node pid=518369
0.0.0.0:3001  -> node pid=518368
```

### 5.3 pm2 并存情况

**证据层级：云端进程与配置**

```text
pm2 ls
- bff-staging     pid 351218 online
- server-staging  pid 351200 online

ps -ww -fp 351200,351218
351200  node /srv/workspaces/exhibition-infra-monorepo/apps/server/dist/...
351218  node /srv/workspaces/exhibition-infra-monorepo/apps/bff/dist/app...

ss -ltnp | egrep "351200|351218"
0.0.0.0:3100 -> pid 351218
0.0.0.0:3101 -> pid 351200
```

### 5.4 运行形态结论

- 当前 **主联调链** 运行形态是：`systemd` 拉起的 `node dist/main.js` + Nginx
- 当前云端 **同时存在** 一套 `pm2` 管理的 workspace-based smoke 栈：
  - BFF `3100`
  - Server `3101`
  - Nginx 本机入口 `127.0.0.1:18080`
- 该 smoke 栈 **不是**本轮 `8080 -> 80` 联调主链，但属于运行态并存风险

---

## 6. HTTP 探测结果表

### 6.1 本地隧道入口探测

**命令摘要**：`curl -sS -o body -w '%{http_code}' http://127.0.0.1:8080<path>`

| URL | 证据层级 | HTTP | 响应体前缀 / 核心结论 |
|-----|----------|------|------------------------|
| `/health/bff/live` | **隧道实测** | `200` | `{"status":"ok","service":"exhibition-bff","port":3000,...}` |
| `/health/server/live` | **隧道实测** | `200` | `{"status":"ok","service":"exhibition-server","port":3001,...}` |
| `/api/app/exhibition/home` | **隧道实测** | `200` | `{"currentLocation":{"displayName":"重庆",...}}` |
| `/api/app/exhibition/enterprise-hub/recommendations?boardType=company` | **隧道实测** | `200` | `{"boardType":"company","items":[]}` |
| `/api/app/file/index` | **隧道实测** | `200` | `{"group":"file","status":"skeleton_only","truthOwner":"Server.evidence",...}` |

### 6.2 Admin 路径错位核验

**命令摘要**：`curl -sS -o body -w '%{http_code}' http://127.0.0.1:8080<path>`

| 外部探测 URL | 证据层级 | HTTP | 响应体前缀 / 结论 |
|--------------|----------|------|-------------------|
| `/api/admin/exhibition/enterprise-hub/applications?page=1&pageSize=1` | **隧道实测** | `404` | `Cannot GET /admin/exhibition/enterprise-hub/applications...` |
| `/api/admin/server/admin/exhibition/enterprise-hub/applications?page=1&pageSize=1` | **隧道实测** | `404` | `Cannot GET /admin/server/admin/exhibition/enterprise-hub/applications...` |
| `/api/admin/` | **云端进程与配置** | `404` | `Cannot GET /admin/`，表明请求已到 Server，但根路径无路由 |

### 6.3 云端本机 upstream 直探

**命令摘要**：云端执行 `curl -sS -o body -w '%{http_code}' http://127.0.0.1:<port><path>`

| URL | 证据层级 | HTTP | 响应体前缀 / 结论 |
|-----|----------|------|-------------------|
| `http://127.0.0.1:3000/bff/exhibition/enterprise-hub/recommendations?boardType=company` | **云端进程与配置** | `200` | `{"boardType":"company","items":[]}` |
| `http://127.0.0.1:3001/server/exhibition/enterprise-hub/recommendations?boardType=company` | **云端进程与配置** | `200` | `{"boardType":"company","items":[]}` |
| `http://127.0.0.1:3001/server/admin/exhibition/enterprise-hub/applications?page=1&pageSize=1` | **云端进程与配置** | `403` | `ENTERPRISE_HUB_PERMISSION_DENIED`，证明 Server Admin controller 实际存在于 `/server/admin/...` |
| `http://127.0.0.1:3000/bff/forum/feed` | **云端进程与配置** | `401` | `AUTH_SESSION_INVALID`，证明 BFF `forum` 路由已挂载 |
| `http://127.0.0.1:3000/bff/file/index` | **云端进程与配置** | `200` | `{"group":"file","status":"skeleton_only",...}`，证明 BFF `file` 路由已挂载但为 skeleton |
| `http://127.0.0.1:3000/bff/file/access?fileAssetId=test&mode=view` | **云端进程与配置** | `401` | 鉴权失败，进一步证明 BFF `file access` 路由存在 |
| `http://127.0.0.1:3001/server/forum/feed` | **云端进程与配置** | `404` | `Cannot GET /server/forum/feed`，当前 Server forum truth 未挂载 |
| `http://127.0.0.1:3001/server/uploads/init` | **云端进程与配置** | `404` | `Cannot GET /server/uploads/init`，当前 Server uploads truth 未挂载 |

---

## 7. Admin 路径错位结论

### 7.1 仓库 controller 前缀对照

**证据层级：仅本地仓库**

- BFF Enterprise Hub controller：`@Controller('bff/exhibition/enterprise-hub')`
- BFF Forum controller：`@Controller('bff/forum')`
- BFF File controller：`@Controller('bff/file')`
- Server truth controller：`@Controller('server/exhibition/enterprise-hub')`
- Server admin controller：`@Controller('server/admin/exhibition/enterprise-hub')`

### 7.2 错位判定

- 当前对外 `/api/admin/` 的 Nginx 写法是：
  - `proxy_pass http://server_upstream/admin/;`
- 因而：
  - `/api/admin/exhibition/...` -> `/admin/exhibition/...`
  - `/api/admin/server/admin/...` -> `/admin/server/admin/...`
- 但当前 Server Admin controller 实际前缀是：
  - `/server/admin/exhibition/enterprise-hub/...`

### 7.3 明确裁决

- **当前 `/api/admin/*` 与 Server controller 前缀不闭环。**
- 证据链已经足够：
  - 隧道入口两类外部候选路径均 `404`
  - 云端直探正确 controller 前缀 `/server/admin/...` 返回 `403`，不是 `404`
- 因此当前问题性质是：
  - **Nginx 外部路径前缀错位**
  - **不是**“Server Admin controller 根本不存在”
  - **不是**“80 后没挂服务”

---

## 8. `/api/app` 与 BFF 前缀闭环结论

### 8.1 明确裁决

- **当前 `/api/app/*` 与 BFF controller 前缀真实闭环。**
- 但该闭环 **依赖云端额外 rewrite**，不是仓库样例 `infra/nginx/cloud.conf` 的单块直转模型。

### 8.2 证据链

- 隧道实测：
  - `/api/app/exhibition/home` -> `200`
  - `/api/app/exhibition/enterprise-hub/recommendations?...` -> `200`
  - `/api/app/file/index` -> `200`
- 云端 Nginx：
  - `rewrite ^/api/app/(.*)$ /bff/$1 break;`
  - `proxy_pass http://bff_upstream;`
- 云端 upstream 直探：
  - `3000/bff/exhibition/enterprise-hub/recommendations?...` -> `200`

### 8.3 Enterprise Hub 判定

- **当前 enterprise_hub 属于“云端有额外 rewrite/配置闭环”，不是“仓库样例闭环”。**
- 若只看仓库样例 `infra/nginx/cloud.conf`，会低估当前线上 `/api/app/*` 的真实 rewrite 规则。

---

## 9. forum / file 当前挂载状态结论

### 9.1 forum

- **BFF forum 已真实挂载。**
- 证据：
  - `3000/bff/forum/feed` -> `401 AUTH_SESSION_INVALID`
- **Server forum 当前未挂载。**
- 证据：
  - `3001/server/forum/feed` -> `404`

### 9.2 file

- **BFF file 已真实挂载。**
- 证据：
  - `3000/bff/file/index` -> `200 skeleton_only`
  - `3000/bff/file/access?...` -> `401`
  - `8080/api/app/file/index` -> `200 skeleton_only`
- **Server uploads/file truth 当前未挂载。**
- 证据：
  - `3001/server/uploads/init` -> `404`

### 9.3 结论

- `forum / file` 当前 **不是**“只有源码存在”。
- 但其真实状态是：
  - **BFF 已挂载**
  - **Server forum/uploads 真相链未挂载或未暴露**
  - `file` 当前 BFF 对外语义仍是 `skeleton_only`

---

## 10. Round 0 阻断项清单

| 阻断项 | 证据层级 | 结论 |
|--------|----------|------|
| `/api/admin/*` 外部路径不闭环 | **隧道实测** + **云端进程与配置** + **仅本地仓库** | **Round 0 阻断项**；只能登记，不能跳过 |
| 仓库样例 `infra/nginx/cloud.conf` 与云端 `/api/app/*` 生效规则不一致 | **云端进程与配置** + **仅本地仓库** | **Round 0 阻断项**；后续不得再以仓库样例替代线上真相 |
| 主链 systemd release 栈与 smoke pm2 workspace 栈并存 | **云端进程与配置** | **Round 0 阻断项**；虽不阻断当前 `80 -> 3000/3001` 探测，但阻断“环境单一性”判断 |
| Server forum/uploads 真相链未挂载 | **云端进程与配置** | **Round 0 阻断项**；只允许登记，不允许本轮顺手补实现 |

---

## 11. 建议裁决

### 11.1 已被“隧道实测”证实的项

- 本地 `8080` 已真实映射到云端 `80`
- `/health/bff/live`、`/health/server/live` 经隧道均为 `200`
- `/api/app/exhibition/home` 经隧道为 `200`
- `/api/app/exhibition/enterprise-hub/recommendations?...` 经隧道为 `200`
- `/api/app/file/index` 经隧道为 `200`
- `/api/admin/...` 两类候选路径经隧道均为 `404`

### 11.2 目前只到“云端进程与配置”证据的项

- 生效 Nginx 文件与真实 rewrite 规则
- `current` 与 `release` 指向
- `systemd` unit、WorkingDirectory、ExecStart
- `3000/3001/80` 监听归属
- `pm2` smoke 栈及 `3100/3101/18080` 并存关系
- `3000/3001` 上游直探结果

### 11.3 仍然只是“仓库样例 / 仓库快照”的项

- controller 前缀命名本身：
  - `bff/exhibition/enterprise-hub`
  - `bff/forum`
  - `bff/file`
  - `server/exhibition/enterprise-hub`
  - `server/admin/exhibition/enterprise-hub`
- `infra/nginx/cloud.conf` 样例内容
- 各类治理/回滚/观察脚本存在性

### 11.4 仍属于“仅文档声称”的项

- 环境分层基线
- 回滚矩阵
- 观测/备份/容灾基线

### 11.5 Round 0 总结性判定句

- **当前未发现“云端服务其实未挂到 80 后”的问题。**
- **当前已证实：`80 -> Nginx -> 3000/3001` 主链存在并可响应。**
- **当前已证实：`/api/app/*` 真实闭环，但依赖云端 rewrite，不是仓库样例闭环。**
- **当前已证实：`/api/admin/*` 不闭环，属于真实路径错位。**
- **当前已证实：forum / file 在 BFF 侧已挂载；Server forum/uploads 未挂载。**
- **当前已证实：主联调链使用 `/srv/releases/**`，满足“非 workspace 源码目录运行”门禁；但并存的 smoke pm2 栈仍指向 `/srv/workspaces/**`，需单列风险。**

### 11.6 是否允许进入结果校验 Agent 签收

- **建议：允许总控将本文书送交结果校验 Agent 签收。**
- 前提说明：
  - 本轮要求的只读补证已完成
  - 阻断项已登记
  - 未把未验证写成已验证
- 同时明确：
  - **建议 No-Go for 联调发布动作**
  - **建议 No-Go for 修复/部署/发版动作**
  - 当前只允许进入 **结果校验与门禁裁决**

---

## 12. 修订记录

| 版本 | 时间 | 说明 |
|------|------|------|
| v0.1 | — | 初版盘点；仅登记仓库与文书，不含隧道实测与云端只读补证 |
| v0.2 | 2026-04-01T18:50:17Z | 完成 Round 0 只读补证：复用本地隧道、补齐 `8080` 实测、读取云端生效 Nginx、核验 current/release、systemd、监听端口、补齐 Admin 路径错位与 `/api/app` rewrite 闭环结论 |

