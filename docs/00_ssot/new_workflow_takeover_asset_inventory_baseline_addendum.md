---
owner: Codex 总控
status: draft
purpose: Freeze the new six-role workflow takeover baseline, current asset inventory, topology rules, and the next unique dispatch action.
layer: L0 SSOT
---

# 新工作流接管与现状资产识别基线补充单

## Scope
- This addendum takes over the project workflow baseline from `2026-03-27`
  forward.
- Old workflow, old role-routing, old handoff chain, old status management,
  and old tunnel records are no longer the active execution basis.
- Old valid assets remain project assets and must be reused instead of rebuilt.
- This file freezes the new six-role workflow only; it does not unlock code
  implementation by itself.

## A. 新工作流接管声明
- 旧工作流废弃：
  - 旧角色流转方式废弃
  - 旧派工关系废弃
  - 旧状态管理方式废弃
  - 旧隧道信息废弃
- 旧资产保留：
  - 旧工作流下已经完成且仍然有效的代码、页面、接口、数据库、配置、
    部署、文档、脚本、环境资产，全部保留为当前项目资产
  - 禁止重复建设
  - 禁止平行重做
  - 禁止推倒重来
- 当前采用六角色新工作流：
  - 总控
  - 前端 Agent
  - 后端 Agent
  - BFF Agent
  - 结果校验 Agent
  - 联调发布 Agent
- 当前唯一有效隧道命令：
  - `ssh -N -L 28790:127.0.0.1:8443 root@47.108.140.84`
- 当前唯一本地访问地址：
  - `http://127.0.0.1:28790`
- 冻结映射关系：
  - 本地 `127.0.0.1:28790`
  - 映射云端 `127.0.0.1:8443`

## B. 项目现状资产识别单

### B1. 已有前端资产
- 本地仓库已存在 `Flutter App` 实体资产，不是空壳：
  - `apps/mobile/lib/**` 现有 `112` 个源码文件
  - `apps/mobile/test/**` 现有 `14` 个测试文件
- 已有壳层与楼层资产：
  - `shell`
  - `exhibition`
  - `messages`
  - `profile`
  - `renovation`
  - `custom_furniture`
- 已有可见楼层仍与冻结拓扑一致：
  - 首发可见：`exhibition`、`messages`、`profile`
  - 预埋隐藏：`renovation`、`custom_furniture`
- 已有页面与消费层资产已经覆盖多类真实消费面：
  - `exhibition` 双入口、工作台、项目、投标、订单、合同、里程碑、
    验收、评分/纠纷、论坛
  - `messages` 实例待办消费
  - `profile` 个人与组织信息消费
- 已有本地接云配置已经固化到代码和脚本：
  - `apps/mobile/lib/core/api/app_api_client.dart`
  - `apps/mobile/scripts/run_macos_formal.sh`
  - 默认地址都指向 `http://127.0.0.1:28790/api/app`

### B2. 已有 BFF 资产
- 本地仓库内已存在 BFF 真源与投影资产：
  - `docs/03_bff/bff_ssot.md`
  - `docs/03_bff/bff_routes.md`
  - `docs/01_contracts/openapi.yaml`
  - `packages/contracts/src/generated/**`
- 已有 BFF 云上入口与反向代理基线：
  - `infra/nginx/cloud.conf`
  - `infra/README.md`
  - `infra/scripts/smoke.sh`
- 本地仓库未见可施工的 BFF 业务源码：
  - `apps/bff/src/**` 当前无有效手写业务实现
- 当前判断：
  - 本地仓库中的 BFF 资产以真源文档、契约投影、部署基线为主
  - 云端 BFF 实际代码资产需要在云端工作区单独盘点
  - 禁止因为本地 `apps/bff` 代码缺失就重建一套本地 BFF

### B3. 已有后端资产
- 本地仓库内已存在后端真源与持久化规范资产：
  - `docs/00_ssot/domain_model.md`
  - `docs/00_ssot/lifecycle_state_machine.md`
  - `docs/00_ssot/permission_matrix.md`
  - `docs/02_backend/backend_ssot.md`
  - `docs/02_backend/service_boundaries.md`
  - `docs/02_backend/db_schema.md`
  - `docs/02_backend/audit_log_spec.md`
- 已有后端部署与发布基线：
  - `infra/nginx/cloud.conf`
  - `infra/scripts/bootstrap_cloud_host.sh`
  - `packages/tooling/governance_release_signoff_check.sh`
- 本地仓库未见可施工的后端业务源码：
  - `apps/server/src/**` 当前无有效手写业务实现
- 当前判断：
  - 本地仓库中的后端资产以业务真源、数据库规范、审计规范、
    发布门禁脚本为主
  - 云端 Server 实际代码、迁移、运行目录、发布目录需要在云端工作区
    单独盘点
  - 禁止因为本地 `apps/server` 代码缺失就重建一套本地后端

### B4. 已有部署 / 配置 / 文档 / 脚本资产
- 文档资产：
  - `docs/**` 当前共 `64` 个正式文档文件
  - `docs/00_ssot`、`docs/01_contracts`、`docs/02_backend`、
    `docs/03_bff`、`docs/04_frontend`、`docs/05_admin` 已成体系
- 契约与投影资产：
  - `packages/contracts/contracts-manifest.json`
  - `packages/contracts/openapi/openapi.bundle.json`
  - `packages/contracts/src/generated/**` 共 `3` 个生成文件
- 工具与治理资产：
  - `packages/tooling/**` 共 `5` 个治理脚本
  - 已覆盖仓库洁癖、测试门禁、发布签收等检查
- 部署与基础设施资产：
  - `infra/docker-compose.yml`
  - `infra/env/.env.example`
  - `infra/nginx/cloud.conf`
  - `infra/scripts/bootstrap_cloud_host.sh`
  - `infra/scripts/smoke.sh`
- 当前部署拓扑基线已明确：
  - 本地基础设施：PostgreSQL / Redis / MinIO
  - 云端入口：Nginx
  - 云端运行端口：BFF `3000`，Server `3001`

### B5. 可直接沿用
- `docs/**` 现有 SSOT、契约、后端、BFF、前端、Admin 文档体系
- `packages/contracts/**` 契约投影与生成脚本
- `apps/mobile/**` 现有 Flutter 页面、消费层、路由、测试资产
- `infra/**` 现有 Docker、Nginx、引导脚本、冒烟脚本
- `packages/tooling/**` 现有治理与发布门禁脚本

### B6. 需要补做
- 云端 BFF 工作区现状盘点：
  - 现有模块
  - 现有接口
  - 现有部署目录
  - 现有发布方式
  - 现有健康检查
- 云端后端工作区现状盘点：
  - 现有领域模块
  - 现有数据库迁移
  - 现有运行配置
  - 现有发布目录
  - 现有审计与状态机实现证据
- 本地前端对云端服务的隧道联通证据
- 当前轮正式《增量派工单》
- 当前轮标准回执模板
- 当前轮独立复核清单

### B7. 需要修正
- `apps/mobile/README.md`
- `apps/bff/README.md`
- `apps/server/README.md`
- 上述 README 仍保留明显的 `Phase 0 Skeleton` 叙述，不能再单独作为
  当前施工范围判断依据，后续应与真实资产规模重新对齐
- 当前会话的隧道可达性证据尚未建立：
  - `curl -I --max-time 5 http://127.0.0.1:28790` 超时
  - 这说明“唯一有效隧道规则”已冻结，但“本机当前隧道已建立”尚无证据
  - 在拿到新一轮联调或发布结论前，不能把隧道当成已验证通过

### B8. 禁止重复
- 禁止本地新建一套 BFF
- 禁止本地新建一套后端
- 禁止重做已有 Flutter 页面、路由、消费层、测试
- 禁止重做已有 OpenAPI、错误码、上传契约、响应包络契约
- 禁止重做已有 Nginx、Docker、引导脚本、发布门禁脚本
- 禁止绕开现有 `docs/**` 另起一套真源

## C. 团队组织冻结单

### C1. 六角色职责
| 角色 | 职责 |
|---|---|
| 总控 | 盘点现有资产、冻结边界、判断沿用/补做/修正、派工、风险阻断、组织校验、裁决是否进入联调发布、发布下一轮唯一动作 |
| 前端 Agent | 本地页面、组件、路由、交互、样式、页面状态消费、本地通过隧道接入云端服务 |
| 后端 Agent | 云端领域模型、数据库、迁移、状态机、权限、审计、核心业务接口 |
| BFF Agent | 云端聚合接口、响应整形、错误归一、上下文拼装、上传签名与中转链路 |
| 结果校验 Agent | 独立复核、识别重复施工/越权施工/漏做/冲突/伪完成、给出通过结论 |
| 联调发布 Agent | 用真实拓扑完成联调、检查环境、门禁、回滚、上线准备 |

### C2. 六角色禁止事项
| 角色 | 禁止事项 |
|---|---|
| 总控 | 不得长期替代执行角色施工；不得跳过盘点直接重做；不得“看起来差不多”就放行 |
| 前端 Agent | 不得本地写 BFF/后端；不得自创业务规则；不得误开放隐藏楼；不得把 mock 当完成 |
| 后端 Agent | 不得本地施工后冒充云端成果；不得把关键状态判断下沉到前端或 BFF；不得重复建设已有后端资产 |
| BFF Agent | 不得在本地施工 BFF；不得维护第二套业务真相；不得重复建设已有 BFF 资产 |
| 结果校验 Agent | 不得替执行角色圆场；不得只看回执；不得不核对现有资产就放行 |
| 联调发布 Agent | 不得把“代码已写”当成“可上线”；不得无隧道验证证据放行；不得无回滚方案放行 |

### C3. 派工 / 回执 / 验收 / 放行链
- 总控只向以下角色派工：
  - 前端 Agent
  - 后端 Agent
  - BFF Agent
  - 结果校验 Agent
  - 联调发布 Agent
- 执行角色统一向总控回执：
  - 前端 Agent -> 总控
  - 后端 Agent -> 总控
  - BFF Agent -> 总控
- 结果校验链：
  - 总控 -> 结果校验 Agent
  - 结果校验 Agent -> 总控
- 联调发布链：
  - 只有通过结果校验的成果，才能由总控移交联调发布 Agent
  - 联调发布 Agent -> 总控
- 最终放行：
  - 只有总控有权裁决是否进入下一轮、是否允许联调、是否具备上线准备

## D. 项目拓扑与隧道使用规则
- 前端只在本地开发
- BFF 与后端只在云端开发、运行、部署
- 本地不写 BFF
- 本地不写后端
- 唯一有效隧道命令：
  - `ssh -N -L 28790:127.0.0.1:8443 root@47.108.140.84`
- 唯一本地访问地址：
  - `http://127.0.0.1:28790`
- 角色知晓要求：
  - 总控必须知道
  - 前端 Agent 必须知道
  - 结果校验 Agent 必须知道
  - 联调发布 Agent 必须知道
  - 后端 Agent 与 BFF Agent 需知道该映射用于本地验证，但其编码默认在云端
- 云端直接作业角色：
  - 后端 Agent
  - BFF Agent
- 隧道用途冻结：
  - 仅用于本地访问云端服务
  - 仅用于本地验证云端服务接入效果
  - 不等于远程编码本身
  - 不得把隧道访问误写成“本地开发了 BFF / 后端”
- 密码规则冻结：
  - 隧道命令允许写入文档和流程
  - 密码禁止写入任何文档、日志、脚本、回执
  - 必须由操作者手动输入

## E. 增量施工原则
- 一律先盘点，再施工
- 一律只做增量，不做平行重建
- 一律先识别可沿用资产，再定义补做范围
- 一律禁止忽略旧资产
- 一律禁止重做已有页面、接口、数据库结构、部署基线
- 一律禁止在本地重建云端 BFF / 后端
- 一律先冻结边界，再发执行角色任务
- 一律要求标准回执，不接受口头“差不多好了”
- 一律先独立校验，再进入联调发布
- 没有联调证据、隧道验证证据、回滚方案、门禁检查，不得判定可上线

## F. 下一步唯一动作
- 下一步唯一动作：
  - 发送“后端 Agent 模板”
- 我收到后将输出：
  - 《后端 Agent 云端现状盘点派工单》
  - 《标准回执格式》
  - 《结果校验 Agent 复核关注点》
- 该下一轮只允许做：
  - 云端后端现有资产盘点
  - 云端后端已有有效实现识别
  - 云端后端缺口识别
- 该下一轮不允许做：
  - 新增开发
  - 本地补写后端
  - 跳过盘点直接进入联调

## 附：阶段门禁核查表（接管轮）
- 阶段目标：
  - 完成新工作流接管
  - 冻结唯一拓扑与隧道规则
  - 建立盘点优先的增量派工基线
- 已通过门禁：
  - 真源门禁
  - 架构边界门禁
  - 阶段控制门禁
  - 文件长度与职责门禁
- 未通过门禁：
  - 云上运行门禁
  - 原因：当前会话尚无云端 BFF / Server 发布目录、健康检查、隧道联通证据
- 一票否决项当前状态：
  - 联调发布：否决
  - 上线放行：否决
- 下一阶段是否允许：
  - 允许进入“云端后端资产盘点阶段”
  - 不允许进入“联调发布阶段”
  - 不允许进入“上线判定阶段”
