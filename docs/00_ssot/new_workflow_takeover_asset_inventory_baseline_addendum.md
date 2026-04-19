---
owner: Codex 总控
status: frozen
purpose: Freeze the active six-role workflow takeover baseline, current asset identification, topology and tunnel rules, incremental construction principles, and the next unique action.
layer: L0 SSOT
freeze_date_local: 2026-04-09
supersedes:
  - docs/00_ssot/new_workflow_v3_takeover_declaration.md
  - docs/00_ssot/seven_role_organization_freeze_v3.md
  - docs/00_ssot/project_topology_and_tunnel_rules_round0.md
  - docs/00_ssot/zh_incremental_construction_principles_round0.md
  - docs/00_ssot/round0_next_unique_action_round.md
evidence_basis:
  - AGENTS.md
  - apps/mobile/AGENTS.md
  - apps/bff/AGENTS.md
  - apps/server/AGENTS.md
  - apps/admin/AGENTS.md
  - apps/mobile/lib/core/api/app_api_client.dart
  - apps/mobile/lib/core/config/config_manifest.dart
  - apps/mobile/lib/shell/navigation/app_building.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/shell/shell_app.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/bff/src/core/http/server-client.service.ts
  - apps/server/src/app.module.ts
  - apps/server/src/core/runtime-config.service.ts
  - apps/admin/src/core/config/env.ts
  - infra/docker-compose.yml
  - infra/nginx/cloud.conf
  - infra/scripts/bootstrap_cloud_host.sh
  - infra/scripts/smoke.sh
  - docs/00_ssot/project_asset_register_v1.md
---

# 新工作流接管与现状资产识别基线补充单

## Scope

- 本文件自 `2026-04-09` 起作为当前现行接管基线。
- 旧工作流不再作为当前执行依据，但旧工作流下已经完成且仍有效的资产继续保留。
- 本文件只冻结工作流、资产识别、拓扑规则、增量原则与下一步唯一动作。
- 本文件不自动放行实施、联调、部署或发版。

## A. 《新工作流接管声明》

### A1. 现行效力

- 旧工作流废弃：
  - 旧角色分工口径废弃
  - 旧派工关系废弃
  - 旧状态管理方式废弃
  - 旧回执流转方式废弃
  - 旧阶段口令不再作为当前依据
- 旧资产保留：
  - 已有代码、接口、页面、迁移、配置、脚本、文档、部署资产继续属于当前项目资产
  - 禁止因为流程切换而推倒重来
  - 禁止重复建设
  - 禁止平行重做
- 当前采用固定六角色新工作流：
  1. 总控
  2. 前端 Agent
  3. 后端 Agent
  4. BFF Agent
  5. 结果校验 Agent
  6. 联调发布 Agent

### A2. 当前现行基础

- 项目拓扑不变：
  - 前端只在本地开发
  - BFF 与后端只在云端开发、运行、部署
  - Flutter App 只走 BFF
  - Admin 仍直连 Server Admin API，不走 BFF
- 建筑边界不变：
  - 五楼壳体保留
  - 首发可见仍只允许 `exhibition`、`messages`、`profile`
  - `renovation` 与 `custom_furniture` 保持真实预埋但隐藏
- 真源顺序不变：
  - `docs/00_ssot -> docs/01_contracts -> docs/02_backend / docs/03_bff / docs/04_frontend / docs/05_admin -> apps/**`

### A3. 当前降级为历史背景的旧文书

- 以下文书继续保留为历史资产，但不再是当前执行依据：
  - `docs/00_ssot/new_workflow_v3_takeover_declaration.md`
  - `docs/00_ssot/seven_role_organization_freeze_v3.md`
  - `docs/00_ssot/project_topology_and_tunnel_rules_round0.md`
  - `docs/00_ssot/zh_incremental_construction_principles_round0.md`
  - `docs/00_ssot/round0_next_unique_action_round.md`
- 降级原因：
  - 其口径包含 `7 角色` 或过期主线定义
  - 其部分隧道/阶段/派工描述不再匹配当前六角色接管口径

## B. 《项目现状资产识别单》

### B0. 识别方法与总判断

- 本轮盘点基于：
  - 当前本地 monorepo 快照
  - 当前未提交但已存在的工作区资产
  - 已冻结 SSOT 与历史资产台账
- 当前工作区是脏树：
  - 当前存在移动端、BFF、Server、docs 的未提交改动
  - 这些资产属于现有项目现场，不得当作“项目不存在”而重建
- 总判断：
  - 本项目不是空仓，也不是 skeleton-only 状态
  - 当前正确动作是沿用有效资产并做增量派工
  - 当前错误动作是重搭前端、重建 BFF、重建后端、重做同名模块

### B1. 已有前端资产

- `apps/mobile/lib` 当前有 `229` 个文件，`apps/mobile/test` 当前有 `53` 个文件。
- 五楼壳体真实存在：
  - `exhibition`
  - `renovation`
  - `custom_furniture`
  - `messages`
  - `profile`
- 可见性规则仍与冻结拓扑一致：
  - 底部导航只显式使用 `exhibition/messages/profile`
  - `renovation/custom_furniture` 通过 flag 预埋且默认隐藏
- 前端不是只剩壳：
  - 路由装配存在
  - Shell 存在
  - exhibition、forum、enterprise hub、messages、profile 等真实页面与消费层存在
  - 个人资料、身份、治理、会员、支付状态等 profile 资产存在
- Flutter App 默认 app-facing 基址仍是：
  - `http://127.0.0.1:8080/api/app`
- 当前可直接沿用：
  - `apps/mobile/lib/shell/**`
  - `apps/mobile/lib/features/exhibition/**`
  - `apps/mobile/lib/features/messages/**`
  - `apps/mobile/lib/features/profile/**`
  - `apps/mobile/lib/features/renovation/**`
  - `apps/mobile/lib/features/custom_furniture/**`
  - `apps/mobile/test/**`
- 当前需要补做：
  - 本地前端与云端现行 BFF 的联调证据
  - 当前轮前端增量边界冻结与回执模板
- 当前需要修正：
  - 多个 handwritten source 明显超过 `450` 行门禁，已进入治理清单，不得继续无计划扩张
  - 代表文件包括：
    - `profile_identity_access_pages.dart`
    - `project_create_page.dart`
    - `enterprise_hub_consumer_layer.dart`
    - `profile_identity_consumer_layer.dart`
    - `app_router.dart`
- 当前禁止重复：
  - 禁止重做五楼壳
  - 禁止重做 forum / exhibition / profile 已有页面体系
  - 禁止重做现有 `api/app` 消费层

### B2. 已有 BFF 资产

- `apps/bff/src/routes` 当前有 `98` 个文件，当前本地仓库中存在真实 Nest BFF 代码，不是文档占位。
- 当前已识别的 BFF 路由族包括：
  - `auth`
  - `shell`
  - `exhibition_home`
  - `exhibition_workbench`
  - `enterprise_hub`
  - `forum`
  - `file`
  - `my_project`
  - `project`
  - `profile`
  - `trading_read_corridor`
- 当前 `RoutesModule` 已纳入多条 app-facing 模块，不再是旧 Round 0 文书中描述的最小挂载面。
- 当前 BFF 具备以下既有基础：
  - `api/app/*` 控制器
  - `bff/*` 内部控制器
  - 到 Server 的统一 `ServerClientService`
  - 运行端口默认 `3000`
  - 上游 Server 基址默认 `http://127.0.0.1:3001`
- 当前可直接沿用：
  - `apps/bff/src/routes/**`
  - `apps/bff/src/core/**`
  - `docs/03_bff/**`
- 当前需要补做：
  - 云端运行态盘点
  - 当前 active release 与本地仓库快照是否一致的证据
  - 当前轮 BFF 增量边界冻结与回执模板
- 当前需要修正：
  - 旧资产台账中“本地 BFF 代码缺失”或“本地仅单模块挂载”的结论已不适用于当前快照
  - 仓库 `infra/nginx/cloud.conf` 只代表基线样例，不等于已验证的云端生效配置
- 当前禁止重复：
  - 禁止本地另搭一套平行 BFF
  - 禁止在 BFF 内维护第二套业务真相
  - 禁止因历史文书过时而重建同名路由族

### B3. 已有后端资产

- `apps/server/src/modules` 当前有 `205` 个文件，当前本地仓库中存在真实 Nest Server 代码，不是空目录。
- 当前 `AppModule` 已纳入真实模块，包括但不限于：
  - `auth`
  - `ai_review_gateway`
  - `content_safety`
  - `credit_constraints`
  - `exhibition_home`
  - `exhibition_workbench`
  - `enterprise_hub`
  - `forum`
  - `governance`
  - `membership`
  - `my_project`
  - `payment_billing`
  - `profile`
  - `project`
  - `review`
  - `shell`
  - `trading_read_corridor`
  - `upload`
- 当前 Server 已识别的控制器前缀覆盖：
  - `server/*`
  - `server/admin/*`
  - `health/*`
- 当前后端基础已存在：
  - PostgreSQL 运行配置
  - `synchronize: false`
  - upload 模块
  - forum 模块
  - 审计、治理、审核、会员、支付、内容安全等模块
  - 迁移文件总表
- 当前可直接沿用：
  - `apps/server/src/modules/**`
  - `apps/server/src/core/**`
  - `docs/02_backend/**`
- 当前需要补做：
  - 云端运行工作区、发布目录、迁移执行现状盘点
  - 当前轮 Server 增量边界冻结与回执模板
  - `server/admin/*` 对外访问闭环的现网证据
- 当前需要修正：
  - 旧 Round 0 文书中“forum / upload 在本地 Server 未闭环”的结论已不再适配当前代码快照
  - `infra/nginx/cloud.conf` 中 `/api/admin/*` 到 `/admin/*` 的样例转发，需与当前 `server/admin/*` 实际访问链做独立核对
- 当前禁止重复：
  - 禁止本地重建一套 Server
  - 禁止把状态机、审计、权限下沉到前端或 BFF
  - 禁止把 `objectKey` 当业务真相重构文件链

### B4. 已有 Admin、部署、配置、文档资产

- `apps/admin/src` 当前有 `33` 个文件，Admin 不是零资产。
- 当前 Admin 已有：
  - `login`
  - `review`
  - `project_review`
  - `template_config`
  - `ticketing`
  - `audit`
  - `governance`
- 当前 Admin 直连 Server Admin API：
  - 默认基址 `http://127.0.0.1:3001/server/admin`
  - 不走 BFF
- `infra/**` 当前已有部署与运行基座：
  - `docker-compose.yml`
  - `env/.env.example`
  - `nginx/cloud.conf`
  - `scripts/bootstrap_cloud_host.sh`
  - `scripts/smoke.sh`
- 当前基础设施基座已存在：
  - PostgreSQL
  - Redis
  - MinIO
  - Nginx
  - 云端 BFF `3000`
  - 云端 Server `3001`
- `docs/**` 已形成完整真源体系，`docs/00_ssot` 当前有 `604` 个文件。
- 当前可直接沿用：
  - `apps/admin/**`
  - `infra/**`
  - `docs/00_ssot/**`
  - `docs/01_contracts/**`
  - `docs/02_backend/**`
  - `docs/03_bff/**`
  - `docs/04_frontend/**`
  - `docs/05_admin/**`
- 当前需要补做：
  - 当前 active 云端 Nginx 生效配置证据
  - 当前 active release 目录与 systemd/进程证据
  - 当前联调与发布门禁清单
- 当前需要修正：
  - 历史文书中残留的旧隧道、旧主机、旧角色数量口径
  - 将仓库样例写成线上真相的风险表述
- 当前禁止重复：
  - 禁止重做 OpenAPI 与已有 SSOT
  - 禁止重做基础设施脚本
  - 禁止重做 Admin 已有壳与模块外壳

### B5. 现阶段统一裁决

- 可直接沿用：
  - 现有前端壳与五楼结构
  - 现有前端页面、消费层、测试
  - 现有 BFF 路由族与核心基础
  - 现有 Server 模块族与运行基础
  - 现有 Admin 控制台资产
  - 现有 SSOT、contracts、infra 基线
- 需要补做：
  - 云端 BFF 盘点
  - 云端 Server 盘点
  - 当前 active runtime / Nginx / release 证据
  - 当前轮阶段门禁核查表
  - 当前轮增量派工单
  - 当前轮标准回执模板
- 需要修正：
  - 旧 7 角色文书口径
  - 旧隧道口径
  - 旧资产台账中与当前代码快照冲突的结论
  - 超长文件治理计划
- 禁止重复：
  - 禁止推倒重写前端
  - 禁止重建 BFF
  - 禁止重建 Server
  - 禁止把已有同名模块当作空气重新搭架子

## C. 《团队组织冻结单》

### C1. 六角色职责

| 角色 | 职责 |
|---|---|
| 总控 | 盘点现有资产、冻结边界、裁决沿用/补做/修正、派工、阻断风险、组织结果校验、决定是否进入联调发布 |
| 前端 Agent | 只在本地施工前端页面、组件、交互、路由、状态消费，并通过隧道验证云端服务 |
| 后端 Agent | 只在云端施工领域模型、数据库、迁移、状态机、权限、审计、核心业务接口 |
| BFF Agent | 只在云端施工聚合接口、响应整形、错误归一、上下文拼装、上传签名与可见性裁剪 |
| 结果校验 Agent | 独立复核重复施工、越权施工、漏做、伪完成、资产冲突，并给出通过 / 有条件通过 / 不通过 |
| 联调发布 Agent | 基于本地前端 + 云端 BFF/后端 + 隧道访问做联调、门禁检查、回滚核验、发布准备 |

### C2. 六角色禁止事项

| 角色 | 禁止事项 |
|---|---|
| 总控 | 不得长期替代执行角色施工；不得跳过盘点直接重做；不得仅凭回执文字放行 |
| 前端 Agent | 不得在本地写 BFF / 后端代码；不得自创业务规则；不得误开放隐藏楼 |
| 后端 Agent | 不得本地施工后冒充云端成果；不得把状态机和关键判断下沉到前端或 BFF；不得重复建设已有后端模块 |
| BFF Agent | 不得在本地施工 BFF；不得持有第二套业务真相；不得重复建设已有 BFF 模块 |
| 结果校验 Agent | 不得替执行角色圆场；不得只看回执；不得跳过现有资产核对 |
| 联调发布 Agent | 不得把“代码已写”当作“可上线”；不得没有隧道与真实路径证据就放行；不得没有回滚方案就放行 |

### C3. 派工、回执、验收、放行链

- 派工链：
  - 总控 -> 前端 Agent
  - 总控 -> 后端 Agent
  - 总控 -> BFF Agent
  - 总控 -> 结果校验 Agent
  - 总控 -> 联调发布 Agent
- 回执链：
  - 前端 Agent -> 总控
  - 后端 Agent -> 总控
  - BFF Agent -> 总控
  - 结果校验 Agent -> 总控
  - 联调发布 Agent -> 总控
- 验收链：
  - 总控先审执行回执
  - 再移交结果校验 Agent 独立复核
  - 通过结果校验后才可移交联调发布 Agent
- 放行链：
  - 只有总控可以裁决是否进入下一轮
  - 只有总控可以裁决是否允许联调进入发布准备

## D. 《本项目拓扑与隧道使用规则》

### D1. 拓扑冻结

- 前端只在本地开发：
  - `apps/mobile/**`
- BFF 与后端只在云端开发、运行、部署：
  - `apps/bff/**`
  - `apps/server/**`
- Admin 仍使用 Server Admin API：
  - 不走 BFF
  - 默认归口后端 Agent

### D2. 当前统一隧道

- 当前团队统一本地验证隧道：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 当前统一本地验证入口：
  - `http://127.0.0.1:8080`

### D3. 哪些角色必须知道隧道

- 必须明确知道：
  - 总控
  - 前端 Agent
  - 结果校验 Agent
  - 联调发布 Agent
- 需知道但默认不在本地编码：
  - 后端 Agent
  - BFF Agent

### D4. 哪些角色在云端直接作业

- 后端 Agent
- BFF Agent
- 联调发布 Agent在发布门禁与云端证据收集阶段，需要直接面向云端运行态

### D5. 隧道用途冻结

- 隧道只用于：
  - 本地访问云端 `80`
  - 本地验证云端 BFF / Server 对外服务
  - 联调证据采集
- 隧道不等于：
  - 在本地写 BFF
  - 在本地写后端
  - 以访问成功替代云端编码或发布成功
- 密码规则：
  - 隧道命令可以写入文档
  - 密码禁止写入任何文档、日志、口令、回执
  - 必须由操作者手动输入

## E. 《增量施工原则》

- 一律先盘点，再施工。
- 一律先冻结边界，再发派工单。
- 一律只做增量，不做平行新版本。
- 一律先识别可沿用资产，再定义补做与修正项。
- 一律禁止把旧成果当空气。
- 一律禁止重做已有页面、接口、数据库结构、迁移、部署基线。
- 一律禁止在本地重建云端 BFF / 后端。
- 一律要求执行角色提交标准回执，不接受“差不多好了”。
- 一律先做结果校验，再决定是否进入联调发布。
- 没有真实拓扑证据、隧道验证证据、回滚方案、门禁检查，不得判定可上线。

## F. 《下一步唯一动作》

### F1. 唯一动作

- 下一步你只需要把：
  - `执行角色模板`
  - 发给我
- 这里的执行角色模板指：
  - 前端 Agent 模板
  - 后端 Agent 模板
  - BFF Agent 模板

### F2. 我收到后将输出

- 《阶段门禁核查表》
- 《本轮增量派工单》
- 三份执行角色派工口令：
  - 前端 Agent 本地盘点 / 增量施工口令
  - 后端 Agent 云端盘点 / 增量施工口令
  - BFF Agent 云端盘点 / 增量施工口令
- 《标准回执字段》

### F3. 当前明确不做

- 当前不直接进入编码
- 当前不直接进入联调
- 当前不直接进入发布
- 当前不把旧资产重写为新版本
