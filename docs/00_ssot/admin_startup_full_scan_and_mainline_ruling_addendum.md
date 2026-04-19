---
owner: Codex 总控
status: frozen
purpose: Freeze the full pre-start Admin scan, classify the real current Admin state across docs/code/local/cloud, and lock the only allowed startup ruling, package order, and next unique action before any new Admin implementation dispatch.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/05_admin/admin_ssot.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - docs/00_ssot/post_enterprise_display_next_platform_mainline_ruling_addendum.md
  - docs/00_ssot/stage3_admin_package_a_result_verification_pass_addendum.md
  - docs/00_ssot/stage3_admin_package_b_result_verification_pass_addendum.md
  - docs/00_ssot/stage3_admin_package_c_result_verification_pass_addendum.md
  - docs/00_ssot/stage3_admin_package_d_controller_review_conclusion_addendum.md
  - docs/00_ssot/stage3_admin_package_d_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/05_admin/account_and_enterprise_certification_rules_v1_admin_surface_addendum.md
  - apps/admin/src/app/login/page.tsx
  - apps/admin/src/core/auth/route-guard.ts
  - apps/admin/src/core/auth/session-carrier-actions.ts
  - apps/admin/src/core/server/admin-api-runtime.ts
  - apps/admin/src/modules/review/review-shell.tsx
  - apps/admin/src/modules/governance/penalty-shell.tsx
  - apps/admin/src/modules/governance/appeal-shell.tsx
  - apps/admin/src/modules/project_review/project-review-shell.tsx
  - apps/admin/src/modules/audit/audit-shell.tsx
  - apps/admin/src/modules/template_config/template-config-shell.tsx
  - apps/admin/src/modules/ticketing/ticketing-shell.tsx
  - apps/admin/src/modules/published_change_review/published-change-review-shell.tsx
  - apps/server/src/app.module.ts
  - apps/server/src/modules/content_safety/content-safety-admin.controller.ts
  - apps/server/src/modules/review/organization-review.controller.ts
  - apps/server/src/modules/governance/governance-admin.controller.ts
  - apps/server/src/modules/governance/governance-appeal-admin.controller.ts
  - apps/server/src/modules/audit/audit-admin.controller.ts
  - apps/server/src/modules/exhibition_report_cases/exhibition-report-case-admin.controller.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts
  - apps/server/src/modules/template_config/template-config-admin.controller.ts
---

# 《后台启动前全量扫描与主线裁决》

## 1. 本轮唯一动作与证据边界

- 本轮只执行：
  - `后台启动前全量扫描与主线裁决`
- 本轮未执行：
  - backend implementation
  - admin frontend implementation
  - patch
  - migration
  - release-prep
  - launch
- 本轮证据来源只包括：
  - 当前真源文书
  - 当前 `apps/admin/**`
  - 当前 `apps/server/src/modules/**` 中 admin / review / governance / enterprise_hub / content-safety 相关资产
  - `2026-04-12` 本地最小复验
  - `2026-04-12` 云上 active runtime 与 release 复验

## 2. 后台对象范围扫描结论

### 2.1 当前纳入后台扫描对象

- `admin 登录`
- `企业认证审核`
- `企业入驻审核`
- `内容安全审核`
- `治理处罚`
- `申诉处理`
- `审计查看`
- `模板配置`
- `项目治理`
- `风险事件`

### 2.2 本轮额外发现但不并入首包的相关资产

- `review/change_requests`
  - 当前是 `enterprise_hub published change review/apply desk`
  - 它属于 enterprise_hub 已发布变更治理走廊，不等于本轮要求的 `企业入驻审核`
- `ticketing`
  - 当前仍是占位页
  - 只作为 docs/code scan 记录，不纳入当前首包

## 3. 后台当前真实状态总表

| 对象 | 当前代码/真源状态 | 云上 active runtime | 当前分层裁决 |
|---|---|---|---|
| Admin 登录 | `/login` 已是真页面；`admin_session` cookie、route guard、carrier probe 成立；但登录仍是“粘贴 Server 已签发 carrier”，不是完整 admin issuer flow | `/login=200`，受保护页匿名访问 `307 -> /login` | `部分成立` |
| 企业认证审核 | `server/admin/reviews/organizations*` 已存在，`s1-r04` 本地 `3/3 pass`；但 Admin 当前 `/review` 实际承接的是内容安全，不是企业认证审核台 | `/server/admin/reviews/organizations=401` | `部分成立` |
| 企业入驻审核 | `apps/server` 有 `enterprise-hub/applications*` review controller/service；但 Admin 无对应工作台；当前 GET read path 未稳定落到统一管理员权限边界 | `/server/admin/exhibition/enterprise-hub/applications=200` 未带管理员会话也可读 | `形式存在但内核未成立` |
| 内容安全审核 | `/review` 已是内容安全审核队列；`content-safety` admin controller 存在；本地 content-safety review 回归 `4/4 pass` | `/review=307 -> /login`；`/server/admin/content-safety/review-tasks=401` | `已真实成立` |
| 治理处罚 | Admin `penalties` 列表/详情/提交命令存在；Server controller/service 存在；本地 `CS-027` 回归 `4/4 pass` | `/governance/penalties=307 -> /login`；`/server/admin/governance/penalties=401` | `已真实成立` |
| 申诉处理 | Admin `appeals` 列表/详情/裁决命令存在；Server controller/service 存在；本地 `CS-028` 回归 `5/5 pass` | `/server/admin/governance/appeals=401` | `已真实成立` |
| 审计查看 | `/audit` 已是 read-only queue/filter/detail；Server audit controller 存在；本地 `audit` 回归 `3/3 pass` | `/audit=307 -> /login`；`/server/admin/audit/logs=401` | `已真实成立` |
| 模板配置 | 本地 `/template_config` 与 `config/templates*` 已存在，Admin `29/29 pass`、Server `template_config 3/3 pass`；但当前 store 仍是 bounded in-memory | nginx 下 `/template_config=404`；`/server/admin/config/templates=404`；admin:3002 可 `307 -> /login`；server release `dist/app.module.js` 未挂 `TemplateConfigModule` | `本地通过但云上未追平` |
| 项目治理 | `/project_review` 已是 report-case queue/detail/adjudication desk；Server controller 存在；本地 report-case 回归 `5/5 pass` | `/project_review=307 -> /login`；`/server/admin/exhibition/report-cases=401` | `已真实成立` |
| 风险事件 | 文书多处冻结 `security-events / risk attention context`，但当前未见 `server/admin/security-events` 实现，也未见独立 Admin 风险事件面 | 云上未见该路径 family | `docs-only` |

### 3.1 按状态分层归并

#### 已真实成立

- 内容安全审核
- 治理处罚
- 申诉处理
- 审计查看
- 项目治理

#### 部分成立

- Admin 登录
- 企业认证审核

#### 形式存在但内核未成立

- 企业入驻审核

#### 当前缺口

- `review` 主座位当前被内容安全审核占用，企业认证审核未进入当前 Admin 主工作台
- 风险事件/security-events 没有真实可用的 `Server Admin` path family 与 `Admin` read surface
- `ticketing` 仍是占位页
- 当前后台不能宣称“可支撑真实运营”

#### docs-only / 未执行

- 风险事件/security-events companion surface
- `ticketing`

#### 本地通过但云上未追平

- `template_config`
- enterprise_hub `published change review/apply corridor`
  - 本地 Admin route 与 Server test 均成立
  - 云上 `server/admin/exhibition/enterprise-hub/change-requests*` 仍为 `404`

## 4. 代码现状扫描结论

### 4.1 apps/admin 当前真实代码面

- 当前真实页面族：
  - `/login`
  - `/review`
  - `/review/change_requests`
  - `/governance/penalties`
  - `/governance/appeals`
  - `/project_review`
  - `/audit`
  - `/template_config`
  - `/ticketing`
- 当前真实模块语义：
  - `/review`
    - 当前不是企业认证审核台
    - 当前是 `content-safety review-tasks` 队列
  - `/review/change_requests`
    - 当前是 `enterprise_hub published change review/apply desk`
  - `/project_review`
    - 当前是举报案件台
  - `/audit`
    - 当前是只读审计工作台
  - `/template_config`
    - 当前是模板与规则快照治理台
  - `/ticketing`
    - 当前只是占位页
- 当前 Admin transport 边界成立：
  - 只直连 `Server Admin API`
  - 不经 `BFF`
  - `admin_session` 只作为 carrier，不是第二真源

### 4.2 apps/server 当前真实代码面

- 当前真实存在的 controller family：
  - `server/admin/content-safety/*`
  - `server/admin/reviews/organizations*`
  - `server/admin/governance/penalties*`
  - `server/admin/governance/appeals*`
  - `server/admin/audit/logs*`
  - `server/admin/exhibition/report-cases*`
  - `server/admin/exhibition/enterprise-hub/applications*`
  - `server/admin/exhibition/enterprise-hub/change-requests*`
  - `server/admin/config/templates*`
- 当前真实 extra finding：
  - `enterprise-hub applications` 与 `recommendation-slots` 的 GET read path 在本地源码中未统一接入 `RequestContext + verified reviewer`，管理权限边界不一致

## 5. 文书状态扫描结论

### 5.1 已执行且仍有效

- `post_enterprise_display_next_platform_mainline_ruling_addendum.md`
  - 其“平台下一条唯一主线 = 阶段3 Admin 最小运营与治理闭环”结论仍有效
- `stage3_admin_package_a_result_verification_pass_addendum.md`
  - package A 的本地 bounded closure 仍有效
- `stage3_admin_package_b_result_verification_pass_addendum.md`
  - package B 的本地 bounded closure 仍有效
- `stage3_admin_package_c_result_verification_pass_addendum.md`
  - package C 的本地 bounded closure 仍有效
- `s1-r04 certification minimal review ops` result verification
  - Server 侧企业认证审核最小链仍成立
- `s1-c03 admin content-safety review tasks` result verification
  - 内容安全审核最小链仍成立

### 5.2 已执行但代码/文书漂移

- `docs/05_admin/admin_ssot.md`
  - 仍是 `draft`
  - 不能作为当前 Admin 已闭环证据
- `docs/05_admin/admin_governance_surface_matrix.md`
  - 仍是 `draft`
  - 当前未完整反映 `governance` 模块与 `published_change_review` 的现实代码面
- `post_enterprise_display_next_platform_mainline_ruling_addendum.md`
  - 其中关于“`/login` 仍为占位页、`project_review/template_config/audit` 未对齐”的代码快照描述已漂移
  - 但其“下一条平台主线仍是 stage3 Admin”结论不漂移
- `stage3_admin_cloud_runtime_catchup_shortest_path_checklist_addendum.md`
  - package B/C 的 cloud catch-up 已完成
  - 该文书不再代表当前 cloud 差距全貌
- `stage3_admin_package_d_controller_review_conclusion_addendum.md`
  - 其中“package D implementation No-Go”已被后续本地实现状态与 gate 文书 supersede
  - 但其对象边界与 non-goals 仍有效

### 5.3 本地通过但云上未追平

- package D `template_config`
  - 本地 Admin/Server 测试已通过
  - 云上 nginx 与 Server active release 未对齐
- enterprise_hub `published change review/apply corridor`
  - 本地 source/test 成立
  - 云上 active `enterprise-hub-admin.controller.js` 缺失 `change-requests*` methods

### 5.4 docs-only / 未执行

- `account_and_enterprise_certification_rules_v1_admin_surface_addendum.md`
  - 仍是 `draft`
  - 企业认证审核 Admin 面尚未 materialize 为当前 `review` 真座位
- `risk/security-events` companion surface 相关文书
  - 当前未 materialize 为真实 `Server Admin` + `Admin` 面
- `ticketing` 相关工作台
  - 当前仍停留在占位层

## 6. 登录与权限扫描结论

### 6.1 Admin 登录是真登录还是占位

- 结论：
  - 不是账号密码占位页
  - 但也不是完整的 admin issuer flow
- 当前真实语义：
  - `Admin` 只接受 `Server` 已签发的管理员 session carrier
  - 本页负责：
    - probe 校验 carrier
    - 写入 `admin_session`
    - 进入受保护工作台
- 因此当前应判为：
  - `部分成立`
  - 不能直接写成“后台登录已完整闭环”

### 6.2 admin_session 是否真闭环

- 结论：
  - `admin_session` 本身已形成最小闭环
- 证据：
  - `route-guard` 对受保护路径生效
  - `session-carrier-actions` 先调用 `Server Admin API` probe 再写 cookie
  - 云上 `/review /project_review /audit` 匿名访问均为 `307 -> /login`

### 6.3 carrier 是否混用

- 结论：
  - 未见 `Admin -> BFF` carrier 混用
- 当前真实边界：
  - `Admin` 只直连 `Server`
  - `admin_session` 最终转为 `Authorization: Bearer ...`
  - 不经 `BFF`

### 6.4 管理员权限边界是否成立

- 对以下对象：
  - 内容安全审核
  - 企业认证审核
  - 治理处罚/申诉
  - 审计查看
  - 项目治理
- 当前权限边界基本成立：
  - 本地代码走 `verified current session + reviewer eligibility`
  - 云上匿名访问分别表现为 `401` 或 `307`
- 但当前不是全域成立：
  - `enterprise-hub applications` 与 `recommendation-slots` GET read path 现状未统一落入同一管理员权限边界
  - 云上复验表现为未带管理员会话也可 `200`

## 7. 审核与治理闭环扫描结论

### 7.1 当前已真实闭合的最小链

- 内容安全审核任务
  - queue / detail / approve / reject 成立
- 治理处罚
  - list / detail / apply 成立
- 治理申诉
  - list / detail / decide 成立
- 项目治理
  - report-case queue / detail / request-explanation / decide / escalate 成立
- 审计查看
  - append-only list / filter / detail 成立

### 7.2 当前只闭了 Server truth、没闭 Admin 消费面的链

- 企业认证审核
  - `Server` list/detail/approve/reject 成立
  - 当前 `Admin` 没有真实认证审核工作台
- 企业入驻审核
  - `Server` applications/review family 形式存在
  - `Admin` 无真实工作台
  - 权限边界也未稳定

### 7.3 证据链与审计留痕

- 当前证据链与审计最小承接成立于：
  - 内容安全审核
  - 项目治理
  - 治理处罚/申诉
  - 审计查看
- 当前未形成独立风险事件查看面：
  - `security-events` 文书有定义
  - 代码面未 materialize

## 8. 运营台最小可运行性扫描结论

### 8.1 当前后台能不能支撑真实运营

- 结论：
  - `不能`

### 8.2 为什么当前不能写成“可运营”

- 当前 Admin 登录仍依赖 out-of-band carrier 粘贴接入
- 企业认证审核没有进入当前真实 Admin 工作台
- 企业入驻审核没有真实消费面，且管理读路径权限边界不一致
- 风险事件/security-events 仍是 docs-only
- `template_config` 云上未追平
- `ticketing` 仍是占位页

### 8.3 当前 P0 最小可运行后台必须包含什么

- `Admin 登录闭环`
- `企业认证审核`
- `内容审核任务`
- `治理处罚/申诉`
- `项目治理`
- `审计查看`

## 9. 本地 / 云上追平扫描结论

### 9.1 本地已成立

- `apps/admin`
  - `npm run test:admin-side`
  - 当前结果：`29 pass / 0 fail`
- `apps/server`
  - `admin-review-p0-profile-safety-manual-review-role.test.cjs`
    - `4 pass / 0 fail`
  - `s1-r04-certification-minimal-review-ops-closure.test.cjs`
    - `3 pass / 0 fail`
  - `cs027-governance-penalty.test.cjs + cs028-governance-appeal.test.cjs`
    - `9 pass / 0 fail`
  - `exhibition-report-case-admin.test.cjs + audit-admin-read.test.cjs + template-config-admin.test.cjs`
    - `11 pass / 0 fail`
  - `enterprise-hub-published-change-governance.test.cjs`
    - `7 pass / 0 fail`

### 9.2 云上已追平

- `Admin`
  - `/login`
  - `/review`
  - `/governance/penalties`
  - `/project_review`
  - `/audit`
- `Server`
  - `/server/admin/content-safety/review-tasks`
  - `/server/admin/reviews/organizations`
  - `/server/admin/governance/penalties`
  - `/server/admin/governance/appeals`
  - `/server/admin/exhibition/report-cases`
  - `/server/admin/audit/logs`

### 9.3 云上未追平

- `Admin /template_config`
  - `127.0.0.1:3002/template_config = 307 -> /login`
  - `127.0.0.1/template_config = 404`
  - 原因：
    - nginx 当前未代理 `/template_config`
- `Admin /ticketing`
  - `127.0.0.1:3002/ticketing = 307 -> /login`
  - `127.0.0.1/ticketing = 404`
  - 原因：
    - nginx 当前未代理 `/ticketing`
- `Server /server/admin/config/templates`
  - 云上 `404`
  - 原因：
    - active release `dist/app.module.js` 未挂 `TemplateConfigModule`
- `Server /server/admin/exhibition/enterprise-hub/change-requests*`
  - 云上 `404`
  - 原因：
    - active release `enterprise-hub-admin.controller.js` 未包含 `change-requests*` methods

### 9.4 当前哪些差的是部署，哪些差的是实现

- 差的是部署 / release 组装：
  - `/template_config`
  - `/ticketing`
  - `/server/admin/config/templates`
  - `/server/admin/exhibition/enterprise-hub/change-requests*`
- 差的是实现：
  - 企业认证审核的真实 Admin 工作台
  - 企业入驻审核的真实 Admin 工作台
  - 风险事件/security-events
  - ticketing 内核
- 差的是权限边界收口：
  - `enterprise-hub applications/recommendation-slots` GET read path

## 10. 后台与主 App 边界扫描结论

### 10.1 只属于 Admin 的能力

- 企业认证审核
- 内容审核任务
- 治理处罚 / 申诉裁决
- 项目治理裁决
- 审计查看
- 模板配置治理
- 风险事件只读台
- ticket routing / follow-up

### 10.2 继续留在 App 的能力

- OTP 登录与用户会话获取
- 认证资料提交 / 重提
- 企业入驻申请提交
- 举报提交
- 用户侧申诉提交
- enterprise display 消费面

### 10.3 truth owner 不得被后台前端改写的对象

- 当前会话与权限真相
- 组织成员与角色真相
- 审核任务真相
- 处罚 / 申诉真相
- 案件真相
- 审计日志真相
- 模板 / 版本 / 规则真相
- 已冻结 `Project / Order / Contract / Milestone / Inspection / Rating / Dispute` snapshot refs

## 11. 后台最小可运行模块清单

### 11.1 P0 必做后台

- `Admin 登录闭环包`
- `企业认证审核包`
- `内容审核任务包`
- `治理处罚/申诉包`
- `项目治理包`
- `审计查看包`

### 11.2 P1 后台

- `企业入驻审核包`
- `模板配置包`
- `enterprise_hub 已发布变更治理包`

### 11.3 P2 后台

- `风险事件只读包`
- `ticketing / 案件分流包`
- `推荐位与 enterprise_hub 运营扩展包`

## 12. 后台当前最大 10 个阻塞点

1. 当前 `Admin` 登录仍是 out-of-band session carrier 接入，不是完整 operator issuer flow；这使后台不能写成“真实运营可用”。
2. `review` 主座位当前承接的是内容安全审核，不是企业认证审核；企业认证审核当前只有 Server truth，没有真实 Admin 消费面。
3. `enterprise-hub applications/recommendation-slots` 的管理 GET read path 当前权限边界不一致；云上复验已出现未带管理员会话直接 `200`。
4. 企业入驻审核当前没有真实 Admin 工作台；后端路径形式存在但消费面未接，且不能按“有 API”误写成“可运营”。
5. 风险事件/security-events 当前只有文书，没有真实 `Server Admin` path 与 `Admin` 面。
6. `template_config` 当前只在本地形成 bounded implementation；云上 nginx 缺路由、Server active release 缺模块装配，无法作为 active capability 记账。
7. `ticketing` 当前仍是占位页，不能承接 escalation / routing / follow-up 真流程。
8. enterprise_hub `published change review/apply corridor` 本地 source/test 成立，但云上 active backend 仍缺 `change-requests*` family。
9. `docs/05_admin/admin_ssot.md` 与 `admin_governance_surface_matrix.md` 仍是 `draft` 且与现实代码面存在漂移，当前 Admin 宪法层真源不够收口。
10. 后台能力成熟度明显不均匀：治理处罚、申诉、项目治理、审计、内容安全已经较实，但企业认证、企业入驻、风险事件仍未形成统一 P0 运营闭环。

## 13. 后台主线是否允许现在启动

### 13.1 裁决

- 当前裁决固定为：
  - `有条件允许`

### 13.2 为什么不是“不允许”

- 当前不是从零开始：
  - 内容安全审核、治理处罚、申诉、项目治理、审计查看已经有真实 code/runtime basis
  - `Admin` 登录最小 carrier 闭环已存在
  - `Server` 的企业认证审核最小 truth 已存在并经本地回归复验
- 因此当前不需要退回到“先补基础设施、不得启动后台主线”的判断

### 13.3 为什么也不是“无条件允许”

- 当前后台仍不能宣称可运营
- `review` 主座位对象冲突尚未被重新冻结
- 企业认证审核与企业入驻审核都未真正进入当前 Admin 主工作台
- 风险事件与 ticketing 尚未 materialize

### 13.4 当前启动条件

- 只允许按 bounded package 单线程推进
- 不得把全部 stage3 对象一次性并入当前主线
- 首包必须先收口 `review` 主座位与企业认证审核对象

## 14. 如果允许启动，第一包是什么

- 第一包固定为：
  - `企业认证审核包`

### 14.1 为什么不是其他包

- 不是 `内容审核任务包`
  - 因为内容安全审核当前已经有真实工作台与回归证据，不是当前最大启动缺口
- 不是 `治理处罚/申诉包`
  - 因为治理处罚/申诉当前已经形成更强的本地与云上成立证据
- 不是 `企业入驻审核包`
  - 因为企业入驻审核当前同时缺消费面与权限边界，前置混乱比企业认证更大，不宜先开
- 不是 `Admin 登录闭环包`
  - 因为当前 carrier-only 登录已足够支撑第一包 controller review；真正阻断当前主线秩序的是 `review` 主座位与企业认证审核未对齐

### 14.2 第一包派工条件

- 当前第一包只能做：
  - `企业认证审核包 controller review / docs-first`
- 当前第一包不得偷带：
  - 内容安全扩写
  - 企业入驻审核
  - 风险事件
  - ticketing
  - template_config

## 15. 当前唯一下一步动作

- 当前下一步唯一动作固定为：
  - `输出并冻结《企业认证审核包 controller review spec bundle》`

## 16. Formal Conclusion

- 当前后台主线可以启动，但只能以：
  - `有条件允许`
  - `单包单线程`
  - `企业认证审核包优先`
  的方式启动。
- 当前不得把：
  - 已有 API
  - 已有前端壳
  - 已有本地测试
  误写成：
  - 后台已可运营
- 当前后台真实状态应正式记为：
  - 内容安全审核、治理处罚、申诉、项目治理、审计查看已较实
  - Admin 登录、企业认证审核部分成立
  - 企业入驻审核形式存在但内核未成立
  - 风险事件 docs-only
  - 模板配置与 enterprise_hub published change 本地通过但云上未追平
- 因此当前后台启动后的第一包不得再犹豫，必须固定为：
  - `企业认证审核包`
