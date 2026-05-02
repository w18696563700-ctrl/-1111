# 项目全量只读画像扫描报告：用于编写 AGENTS.md

生成时间：2026-05-02
扫描方式：总控只读预扫描 + 子代理分工扫描 + 总控合并裁决
扫描边界：未修改业务代码，未格式化，未安装依赖，未运行 migration，未写数据库，未提交 git，未部署，未重启云端服务。
子代理执行说明：本轮按要求开启 5 个子代理线程。A/B/C/D 返回有效回执；E 数据模型与测试验收线程超时，E2 补扫线程也超时，总控已关闭并用只读命令补证。报告不伪造未返回的子代理结论。

## 0. 总裁决

- 当前是否具备编写根目录 AGENTS.md 的条件：具备。现有根目录 `AGENTS.md` 已经有平台边界、技术栈、变更顺序、阶段门禁、Phase 0 guardrail 等基础规则，但缺少“云端 runtime 优先于本地 BFF/Server 源码”“哪些命令禁止默认执行”“mock/receipt/候选文书不得当真值”等更细的误判防护。
- 是否建议先写根 AGENTS.md：建议。根 AGENTS.md 是当前最省成本、最稳的收口点，可以先防止跨层误判、施工越界和命令误执行。
- 是否建议现在拆子目录 AGENTS.md：不建议立刻大拆。`apps/mobile/AGENTS.md`、`apps/bff/AGENTS.md`、`apps/server/AGENTS.md`、`apps/admin/AGENTS.md` 已存在，下一步应先更新根规则，等根规则稳定后再做子目录差异化补充。
- 最大风险：本地 `apps/bff` / `apps/server` 源码、SSOT 文书、OpenAPI/generated、云端 active runtime 四者容易被混为同一个真相；这会导致把未部署代码、候选文书、测试 mock 或历史回执误判为线上可用能力。
- 最优先写入 AGENTS.md 的规则：云端 active runtime 优先于本地 BFF/Server 源码；Flutter 只调 BFF；Admin 只调 Server Admin API；BFF 不拥有业务真值；Server 拥有状态机、审计、权限和数据库真值；危险命令不得默认执行。

当前最小闭环：先完善根 AGENTS.md 的长期边界与误判防护，保护 Flutter / Admin / BFF / Server / docs / contracts 的协作秩序。
需要保留但暂不开通：支付资金链、钱包、保证金、深度 Admin 运营、新 IM 主线、Forum 新玩法、装修楼、全屋定制楼、建材商城公开入口。
后续扩展位：在根规则稳定后，为 `apps/mobile`、`apps/bff`、`apps/server`、`apps/admin` 和 `docs` 分别补子目录 AGENTS.md。
哪个更稳：先写根 AGENTS.md。
哪个更省成本：先写根 AGENTS.md，不立刻重拆所有子目录。
哪个更适合当前阶段：根规则收口。
哪个风险更大：直接继续扩功能，尤其是支付、交易、Admin 写操作和消息楼扩张。

## 1. 仓库结构结论

- 项目根目录：`/Users/wangweiwei/Desktop/展览装修之家总控`
- 前端目录：`apps/mobile`
- Admin 目录：`apps/admin`
- BFF 目录：`apps/bff`
- Server 目录：`apps/server`
- contracts 目录：`docs/01_contracts`、`packages/contracts`
- docs 目录：`docs/00_ssot`、`docs/01_contracts`、`docs/02_backend`、`docs/03_bff`、`docs/04_frontend`、`docs/05_admin`
- 数据库 / migration 目录：`apps/server/src/core/migrations/migrations.ts`、`apps/server/src/core/server-migration-runner.service.ts`、`apps/server/src/modules/**/entities`
- 测试目录：`apps/mobile/test`、`apps/admin/test`、`apps/bff/test`、`apps/server/test`
- 关键配置文件：`AGENTS.md`、`pnpm-workspace.yaml`、`package.json`、`apps/mobile/pubspec.yaml`、`apps/admin/package.json`、`apps/bff/package.json`、`apps/server/package.json`、`docs/01_contracts/openapi.yaml`、`infra/docker-compose.yml`、`infra/nginx/cloud.conf`

仓库结构证据：

| 类别 | 证据 |
|---|---|
| 根目录 AGENTS | `AGENTS.md` |
| 子目录 AGENTS | `apps/mobile/AGENTS.md`、`apps/bff/AGENTS.md`、`apps/server/AGENTS.md`、`apps/admin/AGENTS.md` |
| monorepo workspace | `pnpm-workspace.yaml`、根目录 `package.json` |
| Flutter App | `apps/mobile/pubspec.yaml`、`apps/mobile/lib`、`apps/mobile/test` |
| Admin | `apps/admin/package.json`、`apps/admin/src/app`、`apps/admin/test` |
| BFF | `apps/bff/package.json`、`apps/bff/src/routes`、`apps/bff/test` |
| Server | `apps/server/package.json`、`apps/server/src/modules`、`apps/server/test` |
| contracts | `docs/01_contracts/openapi.yaml`、`packages/contracts/src/generated/app-api.types.ts` |
| migration | `apps/server/src/core/migrations/migrations.ts`、`apps/server/src/core/server-migration-runner.service.ts` |
| runtime / release 噪音 | `.tmp`、`artifacts`、`runtime` |

## 2. 技术栈与命令结论

| 层级 | 技术栈 | 目录 | 启动命令 | 测试命令 | 证据 |
|---|---|---|---|---|---|
| Root | pnpm workspace | `.` | `pnpm dc:up` 存在但不应默认执行 | `pnpm contracts:check` 存在但会触发生成链，非只读任务不应默认执行 | `package.json`、`pnpm-workspace.yaml` |
| Flutter App | Flutter / Dart | `apps/mobile` | `flutter run` 仅在明确联调时执行 | `flutter analyze`、`flutter test <target>` | `apps/mobile/pubspec.yaml`、`apps/mobile/test` |
| Admin | Next.js | `apps/admin` | `npm run dev`、`npm run dev:tunnel`、`npm run start` | `npm run lint`、`npm run test:admin-side`、`npm run build` | `apps/admin/package.json` |
| BFF | NestJS | `apps/bff` | `npm run start`、`npm run start:dev`、`npm run start:prod`，本地不应默认启动 | `npm run build`，单测文件在 `apps/bff/test` | `apps/bff/package.json`、`apps/bff/test` |
| Server | NestJS modular monolith | `apps/server` | `npm run start*` 可能触发启动迁移链，不应默认执行 | `npm run build`、`npm run test:upload-transport`、单测文件在 `apps/server/test` | `apps/server/package.json`、`apps/server/src/core/server-migration-runner.service.ts` |
| Runtime health | 云端 Nginx + BFF + Server | 云端 `/srv/apps/*/current` | 不启动，只读 curl | `curl http://127.0.0.1:8080/health/bff/live`、`curl http://127.0.0.1:8080/health/server/live` | 只读 health 返回 200 |

最可靠的默认检查命令：

- `git status --short`
- `find . -maxdepth 2 -type d`
- `rg -n "<keyword>" <path>`
- `curl -i http://127.0.0.1:8080/health/bff/live`
- `curl -i http://127.0.0.1:8080/health/server/live`
- Flutter 任务内可优先跑 scoped：`cd apps/mobile && flutter analyze lib/features/<scope>`、`cd apps/mobile && flutter test <target>`

需要谨慎执行的命令：

- `cd apps/admin && npm run build`
- `cd apps/bff && npm run build`
- `cd apps/server && npm run build`
- `pnpm contracts:check`
- `pnpm contracts:generate`
- 云端 SSH 只读检查

禁止默认执行的命令：

- `pnpm dc:up`、`pnpm dc:down`
- `cd apps/server && npm run start*`
- `cd apps/bff && npm run start*`
- `cd apps/admin && npm run start`
- 任意 migration / deploy / restart / nginx reload / database write
- `flutter pub get`、`npm install`、`pnpm install`
- `git reset`、`git clean`、`git stash`、`git checkout --`
- 任何会创建业务数据的 POST / PUT / PATCH / DELETE 联调命令

## 3. 文书与合同真源结论

| 模块 | 当前正式真源 | 合同位置 | 是否存在漂移 | 风险等级 | 备注 |
|---|---|---|---|---|---|
| Root rules / gate | `AGENTS.md`、`docs/00_ssot/source_of_truth_map.md`、`docs/00_ssot/gate_register_v1.md` | 无单独 OpenAPI | 存在：大量 addendum/receipt 容易被误当根规则 | P1 | 根 AGENTS 应只写长期规则，不写临时 release 口令 |
| Auth / OTP 登录 | `docs/00_ssot` 下 auth/profile 相关冻结文书 | `docs/01_contracts/openapi.yaml` `/api/app/auth/*` | 局部存在：测试与实际登录态需要 runtime 验证 | P1 | Server 持有 session / OTP / password truth |
| Profile / 我的 | `docs/00_ssot` profile / membership / credit 相关文书 | `docs/01_contracts/openapi.yaml` `/api/app/profile/*` | 存在：信用、支付、会员展示面超过 P0 上线主线 | P1 | Flutter 可展示，资金链不得扩张 |
| Exhibition Home | `docs/00_ssot` exhibition home 相关文书 | `docs/01_contracts/openapi.yaml` `/api/app/exhibition/home*` | 低漂移 | P2 | BFF 负责聚合，Server 负责天气/位置等真值 |
| Enterprise Hub | `docs/00_ssot` enterprise hub / supplier 分类文书 | `docs/01_contracts/openapi.yaml` `/api/app/exhibition/enterprise-hub/*` | 存在：workbench、public view、board-scoped、legacy bridge 容易混淆 | P1 | 左侧导航、工作台、列表筛选必须同源 |
| Project / 项目 | `docs/00_ssot` project publish / attachment / public resource 文书 | `docs/01_contracts/openapi.yaml` `/api/app/project/*`、`/api/app/my/projects/*` | 存在：项目发布、预发布、附件、公共资源链路多轮演进 | P1 | Server 持有 draft/submitted/published 等状态真值 |
| Bid / 竞标 | `docs/00_ssot` bid / bidder carry / bid thread 文书 | `docs/01_contracts/openapi.yaml` `/api/app/projects/{projectId}/bid*` | 存在：消息楼和交易触点容易扩大成通用聊天 | P1 | Phase 0 只允许 bounded trading exception |
| Order / Contract / Milestone / Inspection | `docs/00_ssot` read corridor / fulfillment 文书 | `docs/01_contracts/openapi.yaml` order/contract/milestone/inspection paths | 半闭环风险 | P1 | 当前更适合只读 corridor，不应扩交易主线 |
| Messages | `docs/00_ssot` messages interaction center 文书 | `docs/01_contracts/openapi.yaml` `/api/app/message/*` | 存在：项目沟通骨架与通用 IM 边界易漂移 | P1 | 不得扩大成泛聊天 |
| Membership | `docs/00_ssot` membership / payment-billing 文书 | `docs/01_contracts/openapi.yaml` `/api/app/profile/membership*` | 存在：展示/直购/支付能力边界需严控 | P0/P1 | 真实扣款不应进入 P0 |
| Payment / Credit | `docs/00_ssot` p0-pay / platform pricing 文书 | `docs/01_contracts/openapi.yaml` p0-pay/payment paths | 高漂移：旧 `trade-tasks`、settlement、refund、freeze-feedback 路径风险 | P0 | 不应在 AGENTS 写临时 no-freeze 例外为长期规则 |
| Admin / 审核后台 | `docs/05_admin`、Admin 相关 SSOT | `docs/01_contracts/openapi.yaml` `/server/admin/*` | 中等漂移：页面存在不等于运营闭环成熟 | P1 | Admin 只走 Server Admin API |
| Governance / 内容治理 | `docs/00_ssot` governance / content safety 文书 | `docs/01_contracts/openapi.yaml` admin/governance/forum paths | 存在：audit 查询面分裂 | P1 | 高风险动作必须可审计 |
| File Upload / OSS | 根 `AGENTS.md`、upload/file access 文书 | `docs/01_contracts/openapi.yaml` `/api/app/files/*`、`/api/app/file-access/*` | 低漂移但易误判 objectKey | P1 | `objectKey` 不是业务真值，`FileAsset` / `Evidence` 才是真值 |

AGENTS.md 应写入的长期规则：

- 正式真相优先级：`docs/00_ssot/source_of_truth_map.md`、冻结 SSOT、`docs/01_contracts/openapi.yaml`、generated contracts、代码、runtime smoke。
- 云端 active runtime 不能用本地 BFF/Server 源码推断。
- Flutter 只能消费 BFF `/api/app/*`。
- Admin 只能消费 Server Admin API，不经 BFF，不直连 DB。
- BFF 不持有业务真值，不创建第二状态机。
- Server 持有业务真值、状态机、权限、审计、review、risk、migration。
- 文件上传必须是 init -> direct upload -> confirm。
- mock、visual demo、测试 doubles、receipt、candidate、dispatch bundle 不得当正式 truth。
- 支付/钱包/保证金/服务费/结算必须单独冻结，不得顺手扩张。

不应写入 AGENTS.md 的临时规则：

- 具体 release id，例如 `20260502052616-sincerity-internal-no-freeze`
- 临时测试账号、样本项目 id、样本手机号
- 某一次 curl 结果作为长期规则
- 单次 no-freeze exception
- 临时 patch 文件、回执文件、垃圾清理计划
- `.tmp` 目录下的 release artifact 细节

需要另行冻结的模块：

- P0-Pay 正式支付、退款、结算、服务费扣款、钱包/余额/金币、保证金
- Admin 深度运营写操作
- 新 IM 主线
- Forum 新玩法
- 装修楼 / 全屋定制楼 / 建材商城公开入口
- 审计统一查询面

## 4. 模块边界结论

### Flutter / App

- 主要职责：移动端 UI、路由、状态呈现、BFF `/api/app/*` 消费、上传三步流的客户端承接、简体中文用户文案。
- 禁止越权：不得直连 Server；不得自造业务状态机；不得把 mock/fake/test transport 当 runtime；不得发明 OpenAPI 未冻结字段；不得吞掉 BFF 已归一的中文业务错误。
- 易错点：`apps/mobile/lib/core/api/app_api_client.dart` 存在 `FakeAppApiTransport`；`apps/mobile/lib/dev/visual_demo/visual_demo_app.dart` 存在视觉 demo fake handler；这些只能用于测试或演示，不能作为云端闭环证据。

### Admin

- 主要职责：最小运营控制台、审核、治理、审计、模板配置、会员等受控页面；通过 Server Admin API 访问后台能力。
- 禁止越权：不得经 BFF；不得直连数据库；不得绕过 Server role gate；不得把页面存在当作运营闭环成熟；不得把 `x-actor-*` header hint 当最终权限真值。
- 易错点：Admin dev 端口与云端 upstream 端口可能不同；`apps/admin/src/app/api/auth/mock-login/route.ts` 是 mock/login surface，不是生产认证依据。

### BFF

- 主要职责：App-facing 聚合、auth carrier 整合、upload signing/confirm 转接、响应整形、错误归一、轻量幂等、可见性裁剪。
- 禁止越权：不得拥有业务真值；不得创建第二状态机；不得落 DB；不得暴露 Admin API；不得把旧 internal/legacy path 当新 canonical path。
- 易错点：`apps/bff/src/routes/exhibition_p0_pay` 仍有旧 `trade-tasks`、settlement、refund、freeze-feedback 风险面；需在后续支付收口中强制 allow-list。

### Server

- 主要职责：业务真值、数据库、状态机、审计、review、risk、Admin API、权限、session、migration、FileAsset/Evidence 真值。
- 禁止越权：不得无 SSOT/contract 直接扩 app-facing 语义；不得把 BFF header hint 当权限真值；不得在启动时无门禁执行破坏性 migration；不得输出 secrets。
- 易错点：`apps/server/src/core/server-migration-runner.service.ts` 会在 Server 启动链路中 reconciliation migration；因此 `npm run start*` 不得作为默认检查命令。

## 5. 接口与 runtime 一致性结论

只读 runtime 结论：

- 本地 `127.0.0.1:3000` / `3001` / `3002` 未发现监听。
- 本地 `127.0.0.1:8080` 由 `ssh` 进程监听，符合隧道形态。
- `GET http://127.0.0.1:8080/health/bff/live` 返回 200，service 为 `exhibition-bff`，port 为 `3000`，timestamp 为 `2026-05-02T04:29:57.187Z`。
- `GET http://127.0.0.1:8080/health/server/live` 返回 200，service 为 `exhibition-server`，port 为 `3001`，timestamp 为 `2026-05-02T04:29:57.187Z`。
- 云端只读 SSH 证据显示 Nginx upstream：BFF -> `127.0.0.1:3000`，Server -> `127.0.0.1:3001`，Admin -> `127.0.0.1:3002`。
- 云端 active artifact 证据：`/srv/apps/bff/current` 指向 `/srv/releases/bff/20260502052616-sincerity-internal-no-freeze/apps/bff`；`/srv/apps/server/current` 指向 `/srv/releases/server/20260502052616-sincerity-internal-no-freeze`；`/srv/apps/admin/current` 指向 `/srv/releases/admin/20260501163752-admin-login-ui-standardization`。
- 子代理 D 在另一个时间窗报告 health 连接失败；总控以当前实测 health 与云端只读 SSH 证据为准，同时在 AGENTS 中应要求 runtime 结论必须附当前时间戳和来源。

| 接口 / 模块 | 文书是否存在 | 合同是否存在 | BFF 是否存在 | Server 是否存在 | runtime 是否可验证 | 裁决 |
|---|---|---|---|---|---|---|
| Health BFF | 是 | 不作为业务 contract | 是 | 不适用 | 已验证 200 | 可作为 runtime 存活证据 |
| Health Server | 是 | 不作为业务 contract | Nginx 转发 | 是 | 已验证 200 | 可作为 runtime 存活证据 |
| Auth / OTP | 是 | `openapi.yaml` `/api/app/auth/*` | 是 | 是 | 未逐项验证 | 可纳入 P0，但需登录链单独 smoke |
| Profile | 是 | `openapi.yaml` `/api/app/profile/*` | 是 | 是 | 未逐项验证 | 可纳入 P0，只限基础 profile |
| Exhibition Home | 是 | `openapi.yaml` `/api/app/exhibition/home*` | 是 | 是 | 未逐项验证 | 可纳入 P0 |
| Enterprise Hub | 是 | `openapi.yaml` enterprise-hub paths | 是 | 是 | supplier 曾联调，但本报告未重新写操作验证 | 可纳入 P0，只限展示和工作台已冻结面 |
| Project 发布 | 是 | `openapi.yaml` project save/submit/publish 等 | 是 | 是 | 未逐项验证 | 可纳入 P0，但状态链需 Server truth 验证 |
| Project 附件/文书区 | 是 | `openapi.yaml` my project attachments | 是 | 是 | 未逐项验证 | 可纳入 P0 owner 私域 |
| Public Resource 下载 | 是 | `openapi.yaml` public resources/file-access | 是 | 是 | 未逐项验证 | 可纳入 P0，但不得伪资源 |
| Messages interaction | 是 | `openapi.yaml` `/api/app/message/*` | 是 | 是 | 未逐项验证 | 可纳入 P0 最小提醒，不扩通用 IM |
| Bid / bounded trading | 是 | `openapi.yaml` bid paths | 是 | 是 | 未逐项验证 | 谨慎纳入，只限冻结例外 |
| Order/Contract/Milestone/Inspection read corridor | 有 | 有 | 有 | 有 | 未逐项验证 | 只读 corridor 可保留，写链暂缓 |
| P0-Pay / pricing | 有大量文书 | 有部分 contract | 有 | 有但存在路径漂移风险 | 未逐项验证 | 不建议纳入 P0 正式资金链 |
| Admin review/governance | 有 | `/server/admin/*` | 不经 BFF | 有 | health 仅证明 Server 活，不证明 Admin API 全链 | 可保留最小运营支撑，深度运营暂缓 |
| File upload/access | 是 | `openapi.yaml` files/file-access | 是 | 是 | 未逐项验证 | 可纳入 P0，但 objectKey 不是真值 |

高风险不一致项：

- 本地 BFF/Server 源码与云端 active release 不一定一致，必须通过 `/srv/apps/*/current`、进程启动路径、health、endpoint smoke 才能裁决。
- OpenAPI/generated 已存在的路径不等于云端 runtime 一定可用。
- 文书 addendum/receipt/dispatch bundle 不等于 implementation unlock。
- `apps/bff/src/routes/exhibition_p0_pay` 中旧资金路径与当前“服务费/支付不进入 P0 正式资金链”的边界存在冲突风险。

可以延后处理项：

- Admin 深度运营后台
- Forum 新玩法
- 新 IM 主线
- 装修楼 / 全屋定制楼 / 建材商城公开入口
- 支付/钱包/结算/保证金/正式服务费扣款

AGENTS.md 需要强制防止的误判：

- 不得把本地 controller 文件存在写成“云端可用”。
- 不得把 Flutter test pass 写成“云端闭环”。
- 不得把 `/api/app` 以外的 legacy/internal path 当 App 正式消费面。
- 不得把 Admin 页面存在写成“运营闭环完成”。

## 6. 数据模型与业务真值结论

| 业务域 | 主要实体 / 表 | 真值层 | 是否已落地 | 风险 |
|---|---|---|---|---|
| Identity/Auth | `apps/server/src/modules/identity/entities/user.entity.ts`、`session.entity.ts`、`login-otp-code.entity.ts`、`password-credential.entity.ts`、`apps/server/src/modules/auth/entities/auth-security-event.entity.ts` | Server | 已落地 | OTP/session runtime 需单独 smoke |
| Organization/Profile | `organization.entity.ts`、`organization-member.entity.ts`、`organization-certification.entity.ts`、`personal-certification.entity.ts`、`profile-safety-submission.entity.ts`、`user-block-relation.entity.ts` | Server | 已落地 | Profile 功能面较宽，P0 需裁剪 |
| Enterprise Hub | `enterprise-listing.entity.ts`、`enterprise-profile-company.entity.ts`、`enterprise-profile-factory.entity.ts`、`enterprise-profile-supplier.entity.ts`、`enterprise-application.entity.ts`、`enterprise-change-request.entity.ts`、`enterprise-case.entity.ts` | Server | 已落地 | workbench/public view/list/filter 真值需同源 |
| Project | `project.entity.ts`、`project-attachment.entity.ts`、`project-public-resource.entity.ts`、`project-exit-case.entity.ts` | Server | 已落地 | 发布状态链不得在 Flutter/BFF 伪造 |
| Bid | `bid.entity.ts`、`bid-seat.entity.ts`、`bid-participation-request.entity.ts` | Server | 已落地 | 容易被扩大成交易主线 |
| Messages / Trading IM | `project-communication-thread.entity.ts`、`project-communication-message.entity.ts`、`bid-private-thread.entity.ts`、`bid-thread-message.entity.ts`、`bid-thread-confirmation-card.entity.ts` | Server | 已落地 | 只允许 bounded interaction，不扩通用 IM |
| Order | `project-order.entity.ts` | Server | 已落地 | 订单写链与支付链需谨慎 |
| Contract / Milestone / Inspection | `apps/server/src/modules/contract`、`milestone`、`inspection` | Server | 有模块 | 读 corridor 可保留，完整履约闭环未确认 |
| Payment / P0 Pay | `payment-order.entity.ts`、`payment-transaction.entity.ts`、`platform-service-fee-authorization.entity.ts`、`platform-service-fee-charge.entity.ts`、`payment-callback-event.entity.ts`、`payment-idempotency-record.entity.ts` | Server | 已落地 | P0/P1 级风险，正式资金链不得无门禁开放 |
| Membership | `membership-order.entity.ts`、`organization-paid-membership.entity.ts`、`organization-membership-quota-snapshot.entity.ts` | Server | 已落地 | 展示/只读可保留，付费直购需冻结 |
| Credit | `organization-credit-constraint-posture.entity.ts`、`organization-deposit-posture.entity.ts`、`organization-transaction-guarantee-posture.entity.ts`、credit shadow entities | Server | 已落地 | 信用/保证金不要进入 P0 主线 |
| File Upload | `upload-session.entity.ts`、`file-asset.entity.ts` | Server | 已落地 | `objectKey` 容易被误当业务真值 |
| Governance / Audit | `governance-penalty.entity.ts`、`governance-appeal-case.entity.ts`、`content-safety-audit-log.entity.ts`、`apps/server/src/modules/audit` | Server | 已落地 | audit 查询面分裂，需后续统一 |
| Forum | `forum-post.entity.ts`、`forum-comment.entity.ts`、`forum-report-ticket.entity.ts`、like/bookmark/follow entities | Server | 已落地 | Phase 0 例外边界要防扩张 |

Server 必须保留的业务真值：

- 用户、session、组织、认证、会员、信用、项目、项目状态机、企业展示、竞标、订单、合同、里程碑、验收、文件资产、支付、审计、治理。

BFF 不得创造的业务真值：

- 项目状态、企业展示审核状态、供应商分类真值、订单/合同/里程碑/验收状态、支付状态、会员权益、信用评分、审计结论、治理处罚。

前端不得自造的业务真值：

- 登录态最终有效性、组织权限、发布资格、项目生命周期、附件归属、企业展示发布态、竞标资格、订单履约状态、支付状态、会员状态、审核结果、举报处理结果。

## 7. 测试与验收结论

| 层级 | 推荐检查命令 | 风险命令 | 是否适合默认执行 | 证据 |
|---|---|---|---|---|
| Root | `git status --short`、`rg -n`、`find` | `pnpm dc:up/down`、`pnpm install` | 只读命令适合 | `package.json`、`pnpm-workspace.yaml` |
| Flutter | `cd apps/mobile && flutter analyze <scope>`、`cd apps/mobile && flutter test <target>` | `flutter pub get`、`flutter run`、`flutter build`、视觉 smoke 脚本 | scoped analyze/test 适合任务相关执行 | `apps/mobile/pubspec.yaml`、`apps/mobile/test` |
| Admin | `cd apps/admin && npm run lint`、`npm run test:admin-side`、`npm run build` | `npm run dev`、`npm run start`、安装依赖 | lint/test 任务相关执行，build 谨慎 | `apps/admin/package.json`、`apps/admin/test` |
| BFF | `cd apps/bff && npm run build`、按需 `node --test test/<file>.cjs` | `npm run start*`、连接真实写接口 | build/test 任务相关执行 | `apps/bff/package.json`、`apps/bff/test` |
| Server | `cd apps/server && npm run build`、`npm run test:upload-transport`、按需 `node --test test/<file>.cjs` | `npm run start*`、migration、数据库写入 | build/test 任务相关执行；start 不适合默认执行 | `apps/server/package.json`、`apps/server/src/core/server-migration-runner.service.ts` |
| Contracts | 需要 contract 任务时执行 `pnpm contracts:generate` / `pnpm contracts:check` | 只读审计中执行生成链 | 不适合默认只读执行 | `package.json`、`packages/contracts/scripts` |
| Runtime | `curl -i http://127.0.0.1:8080/health/bff/live`、`curl -i http://127.0.0.1:8080/health/server/live` | POST/PUT/PATCH/DELETE 业务接口、部署/重启/nginx reload | health 适合默认只读验证 | SSH 隧道与 health 实测 |

每轮任务默认应跑哪些检查：

- 先跑 `git status --short`。
- 只读阶段用 `rg` / `find` / `sed` / `nl` 取证。
- 涉及 runtime 结论时必须跑 health，并记录时间戳。
- 涉及 Flutter 施工时跑 scoped `flutter analyze` 和相关 `flutter test`。

哪些检查需要任务相关才跑：

- BFF/Server build/test。
- Admin build/test。
- OpenAPI/generated contract generation。
- 云端 endpoint smoke。

哪些检查不能随便跑：

- 任何服务启动命令。
- 任意 migration。
- 任意云端部署、同步、重启。
- 任意会写数据库或创建业务数据的接口。
- 任意依赖安装。

## 8. Codex 误判风险清单

| 风险 | 具体表现 | 后果 | AGENTS.md 应写的约束 |
|---|---|---|---|
| 本地 BFF / Server 被误当云端 runtime | 看到 `apps/bff` controller 或 `apps/server` service 就认为线上已生效 | 错判功能完成，联调失败 | 云端结论必须来自 health、active symlink、进程路径或 endpoint smoke |
| 文书存在但 runtime 不存在 | addendum / dispatch / receipt 写了能力，但云端未部署或未验证 | 上线范围膨胀 | 文书不等于运行时；必须标注 SSOT / contract / code / runtime 四层状态 |
| 合同存在但代码未实现 | OpenAPI/generated 有路径，Server/BFF 未接或云端未生效 | Flutter 调用 404/500 | OpenAPI 只是合同，不能替代实现和 runtime smoke |
| 前端 mock 被当成真实功能 | `FakeAppApiTransport`、visual demo handler、test doubles 被当云端能力 | 产品误判、验收失真 | mock/fake/demo/test 只能作为本地测试证据 |
| BFF 自造业务真值 | BFF 维护状态机、审核状态、支付状态或企业展示 truth | 多真值、数据漂移 | BFF 只聚合整形和透传，不拥有业务状态 |
| Admin 绕过 Server 权限 | Admin 通过 BFF 或 DB 操作，或相信 header hint | 审计与权限失效 | Admin 只走 Server Admin API；权限由 Server 校验 |
| 支付 / 会员 / 信用未冻结就施工 | P0-Pay、钱包、保证金、会员直购、信用扣分顺手实现 | 合规与资金风险 | 支付/钱包/保证金/结算必须单独阶段门禁 |
| 消息楼被扩大成通用聊天 | 从互动提醒/项目沟通扩成泛 IM/群聊 | 主线失控 | Phase 0 messages 只做冻结范围内 interaction / bounded trading |
| 企业展示 workbench 与 public view 混淆 | 工作台字段、公开列表筛选、左侧导航不同源 | UI 与数据不一致 | 工作台、列表筛选、详情展示必须共享正式枚举与合同字段 |
| 文件上传 objectKey 与 FileAsset / Evidence 混淆 | 直接把 objectKey 写入业务实体当完成 | 文件权限与归属失真 | 上传真值必须是 FileAsset/Evidence，objectKey 只是存储定位 |
| 大范围格式化导致 diff 污染 | 只改小功能却格式化整个模块 | 难 review，回滚困难 | 禁止无关格式化；只动最小范围 |
| 未提交工作树被误认为本轮改动 | dirty worktree 中既有改动混入新任务 | 回滚误伤用户改动 | 每轮先 `git status --short`，不得 revert unrelated changes |

## 9. AGENTS.md 建议框架

建议写入根 AGENTS.md 的长期规则：

- 项目运行形态：本地主要是 Flutter / Admin 开发，BFF 与 Server 真实 runtime 在阿里云；本地默认通过 `http://127.0.0.1:8080` 隧道联调。
- 真相分层：SSOT / contracts / generated / local code / cloud runtime / test mock 必须分开表述。
- 所有实现前先过阶段门禁；门禁失败不得施工。
- Flutter 只允许访问 BFF `/api/app/*`。
- Admin 只允许访问 Server Admin API，不经 BFF。
- BFF 不落业务真值，不维护第二状态机。
- Server 是业务真值和数据库唯一拥有层。
- 上传真值是 `FileAsset` / `Evidence`，不是 `objectKey`。
- 不得默认运行危险命令。
- dirty worktree 必须被保护，不得重置用户改动。

不建议写入 AGENTS.md 的临时规则：

- 某个 release 的目录名、部署时间、回滚口令。
- 某一轮 addendum 的临时命名。
- 单次子代理回执。
- 测试样本数据。
- 临时 SQL / patch / cleanup TODO。

建议后续拆分子目录 AGENTS.md 的位置：

- `docs/AGENTS.md`：SSOT、contracts、addendum、receipt 的真源层级和冻结规则。
- `apps/mobile/AGENTS.md`：Flutter API 消费、UI 文案、测试、mock 禁令。
- `apps/admin/AGENTS.md`：Admin 权限、Server Admin API、运营面边界。
- `apps/bff/AGENTS.md`：BFF route、error mapping、upload、light idempotency、禁止 truth。
- `apps/server/AGENTS.md`：domain truth、migration、audit、review、risk、Admin API。
- `packages/contracts/AGENTS.md`：generated contracts 不手改、生成链门禁。

优先级最高的 10 条规则：

1. 云端 active runtime 优先于本地 BFF/Server 源码；runtime 结论必须附 health、active symlink、进程路径或 endpoint smoke 证据。
2. 每次施工前先过《阶段门禁核查表》，失败或 veto 直接停止。
3. Flutter App 只能调用 BFF `/api/app/*`，不得直连 Server、Admin API 或数据库。
4. Admin 只能调用 Server Admin API，不能经 BFF，不能直连 DB，不能把 header hint 当权限真值。
5. BFF 只能做 auth consolidation、aggregation、upload signing/confirm 转接、response shaping、error mapping、light idempotency、visibility trimming。
6. Server 是唯一业务真值层，拥有状态机、审计、review、risk、session、role gate、migration 和数据库。
7. OpenAPI/generated 是接口合同，但不能替代 runtime smoke；文书 addendum/receipt/candidate 也不能替代 implementation unlock。
8. mock、fake transport、visual demo、test doubles、`.tmp` artifact 不得作为真实功能完成证据。
9. 支付、钱包、余额、金币、保证金、服务费正式扣款、结算、退款、发票必须单独冻结，默认不进 P0。
10. 禁止默认执行安装依赖、启动 Server/BFF、migration、部署、重启、nginx reload、数据库写、全量格式化、git reset/clean/stash。

## 10. 下一步建议

1. 立刻要写进 AGENTS.md 的内容：把上面 10 条最高优先级规则固化到根目录 `AGENTS.md`，并补充“本地源码 / 云端 runtime / 文书 / contract / mock 不得混为一谈”的硬规则。
2. 暂时不写进 AGENTS.md、但应保留在报告里的内容：当前 release id、health 时间戳、子代理时间窗差异、具体模块漂移清单、临时 p0-pay no-freeze 风险、`.tmp` artifact 清理建议。
3. 需要后续单独冻结的模块：支付资金链、钱包、保证金、服务费扣款、退款、发票、Admin 深度运营、新 IM 主线、Forum 新玩法、审计统一查询面。
4. 建议新增的子目录 AGENTS.md：`docs/AGENTS.md`、`packages/contracts/AGENTS.md`，以及在现有 `apps/mobile`、`apps/bff`、`apps/server`、`apps/admin` AGENTS 中补充更细边界。
5. 当前不建议做的事情：不建议继续扩功能；不建议一口气重写所有子目录 AGENTS；不建议清理 `.tmp` 和 dirty worktree；不建议改 BFF/Server；不建议做支付/交易/钱包/保证金施工。

最终建议：下一轮可以开始编写根目录 AGENTS.md，但只写长期规则、边界规则、命令禁区和误判防护，不写临时文书、不写 release 细节、不写未验证 runtime 结论。
