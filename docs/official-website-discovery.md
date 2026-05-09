---
owner: Codex 官网施工代理
status: stage-1-discovery
purpose: Freeze the repository discovery result for the first official website before any blueprint or implementation work.
layer: Website / Discovery
updated_at: 2026-05-08
---

# 官方网站 Stage 1 Discovery

## 0. 总裁决

`Stage 1 = PASS WITH BOUNDARY`。

当前仓库没有独立官方网站实现，也没有官网 sitemap、SEO、robots、公开落地页或官网文案中心。第一版官网更稳的方向是新增隔离的轻量官网包，后续只承接已冻结的 App 定位、首发可见能力和边界，不进入 App 核心业务逻辑、BFF、Server、Admin 权限体系或云端部署改造。

本阶段只允许输出本文件。不得改代码，不得新增官网包，不得新增依赖，不得修改 `pnpm-workspace.yaml`，不得调整 Admin、Flutter、BFF、Server 或 Nginx。

## 1. Stage 1 Gate 0

| Gate item | Result |
| --- | --- |
| 当前任务 | 为现有 App 生成第一版官方网站的阶段 1 仓库发现报告 |
| 本阶段允许输出 | `docs/official-website-discovery.md` |
| 本阶段禁止输出 | 代码、官网包、sitemap 成品、blueprint、build spec、依赖、运行服务 |
| 工作区状态 | 已有大量非本轮脏改，集中在 `apps/bff`、`apps/mobile`、`apps/server`、`infra/env/formal_cloud_target.env` 和若干 `docs/00_ssot` 文件 |
| 是否触碰既有脏改 | 否 |
| 是否需要 runtime | 否；本阶段为仓库扫描，不声明云端可用 |
| 是否允许进入实现 | No-Go；必须等 Stage 2 文档和用户确认蓝图后再进入 Stage 3 |
| 是否允许进入 Stage 2 | Go for docs-only blueprint/spec authoring |

## 2. 扫描范围

### 2.1 已扫描

- 根规则：`AGENTS.md`
- Workspace 与脚本：`package.json`、`pnpm-workspace.yaml`
- Admin 前端：`apps/admin/package.json`、`apps/admin/next.config.ts`、`apps/admin/src/app/**`、`apps/admin/AGENTS.md`
- Flutter App：`apps/mobile/pubspec.yaml`、`apps/mobile/lib/shell/navigation/app_building.dart`、`apps/mobile/lib/shell/shell_page.dart`、`apps/mobile/lib/features/**`
- 合同与生成物：`docs/01_contracts/openapi.yaml`、`packages/contracts/src/generated/app-api.types.ts`
- 关键 SSOT：`docs/00_ssot/current_truth_index.md`、`docs/00_ssot/release_scope_four_layer_alignment_20260503.md`、`docs/00_ssot/app_home_first_screen_minimal_experience_optimization_truth_freeze_addendum.md`、`docs/00_ssot/company_display_workbench_to_public_detail_ui_chain_truth_freeze_addendum.md`、`docs/00_ssot/message_building_business_transit_and_deal_confirmation_v1_truth_freeze_addendum.md`、`docs/00_ssot/project_communication_four_entry_full_closure_truth_freeze_addendum.md`、`docs/00_ssot/forum_module_closure_lock_addendum.md`
- 法务与主体信息：`docs/legal/user_agreement.md`、`docs/legal/privacy_policy.md`
- Infra baseline：`infra/README.md`、`infra/nginx/cloud.conf`
- 资产：`apps/mobile/assets/**`、`docs/04_frontend/screenshots/**`

### 2.2 未扫描或未验证

- 未做云端 runtime health / smoke。
- 未 SSH 云服务器。
- 未检查数据库、对象存储、真实业务数据。
- 未运行 build、lint、test。
- 未打开或使用任何密钥、环境变量详情。

结论：本报告只证明仓库内可发现的文档、合同、源码和资产现状，不证明官网或 App 云端正式可用。

## 3. 当前仓库结论

### 3.1 当前没有官网

| Evidence | Finding |
| --- | --- |
| `pnpm-workspace.yaml` | workspace 只包含 `apps/admin`、`apps/bff`、`apps/server`、`packages/*`，没有 `apps/website` 或 `apps/web` |
| `package.json` | 根脚本没有 website dev/build/start |
| `apps/admin/src/app/layout.tsx` | 元数据和导航均为管理后台 |
| `apps/admin/src/app/page.tsx` | 根路径跳转 `/login`，不是公开首页 |
| `find`/`rg` 结果 | 未发现官网 sitemap、robots、独立公开 landing page 或官网文案中心 |

### 3.2 当前已有可复用技术基础

- `apps/admin` 已有 Next.js 16、React 19、TypeScript、ESLint 依赖链，可证明仓库能承载 Web 前端技术栈。
- 但 Admin 是受控运营后台，只能调用 Server Admin API，不应承载公开官网。
- Flutter App 是移动端主客户端，不适合承载 SEO 官网。
- BFF / Server 是接口和业务真值层，不适合承载官网页面。

### 3.3 官网推荐落点

| 方案 | 裁决 | 说明 |
| --- | --- | --- |
| 新增独立 `apps/website` | 更稳；更适合当前阶段 | 官网代码、路由、SEO、公开文案与 Admin/App 业务隔离；后续可独立部署 |
| 复用 `apps/admin` | 更省初始成本；风险更大 | 会混入登录、Admin middleware、Server Admin API 环境和后台导航边界 |
| Flutter Web 官网 | 不适合当前阶段 | SEO、静态部署、官网信息架构都不是现有 Flutter App 的主职责 |
| 放进 BFF / Server | 风险最大 | 会污染接口层和业务真值层，违反层职责 |

阶段 2 应以 `apps/website` 作为默认设计假设，但 Stage 2 仍只写文档，不创建目录。

## 4. 产品真相发现

### 4.1 平台定位

当前平台定位来自根规则：`展览装修之家 / 展览定制之家` 是平台级 App 项目，不是 demo、纯前端原型或一次性脚本仓库。

官网第一版可将对外定位收敛为：

> 面向展览装修与展览定制场景的项目展示、企业展示、项目沟通与资料协作平台。

该定位更稳，因为它不承诺全交易、全支付、全履约，也不把隐藏楼提前公开。

### 4.2 首发可见楼

根规则和 Flutter shell 均指向同一结构：

- 一个 shell。
- 五个 building：`exhibition`、`renovation`、`custom_furniture`、`messages`、`profile`。
- 首发只公开：`exhibition`、`messages`、`profile`。
- `renovation`、`custom_furniture` 为预埋隐藏，不进入官网第一版公开主导航或主卖点。

官网第一版只能把装修、全屋定制写入“后续扩展位”，不能写成已开放业务。

### 4.3 当前可公开表达的能力

| 官网可说能力 | 可说到什么程度 | 真源依据 |
| --- | --- | --- |
| 展览首页 / 推荐频道 | 展览场景的入口、项目展示、企业展示、论坛入口等有界入口 | `AGENTS.md`、`docs/04_frontend/flutter_screen_map.md`、`docs/01_contracts/openapi.yaml` |
| 项目展示 | 可浏览项目列表和项目详情，作为展览项目展示与协作入口 | `GET /api/app/project/list`、`GET /api/app/project/detail` |
| 企业展示 | 公司、工厂、供应商公开展示和资料工作台分离；公开详情只展示 public live detail | `enterprise_hub` 相关 SSOT 与 OpenAPI |
| 项目沟通 | 项目级沟通、资料确认、业务待办入口；Server owns truth | `message_building_business_transit_and_deal_confirmation_v1_truth_freeze_addendum.md`、`project_communication_four_entry_full_closure_truth_freeze_addendum.md` |
| 消息楼 | 项目沟通与论坛互动分 lane，不是泛聊天系统 | `GET /api/app/message/interactions`、消息楼 SSOT |
| 我的楼 | 当前用户身份、组织、认证、会员状态、项目与论坛资产的紧凑入口 | `profile_my_building_compact_hub_boundary_addendum.md`、`GET /api/app/profile/index` |
| 论坛 | 当前已收口为 maintenance-only 的内容交流基础闭环，可轻量提及，不做官网主承诺 | `forum_module_closure_lock_addendum.md` |
| 上传 | 只能说平台采用受控文件流程；不能说当前官网或云端已验证全链路 | 根规则与上传合同 |

### 4.4 当前最小闭环

官网第一版的最小闭环应只覆盖：

1. 一屏讲清平台定位。
2. 说明首发三楼：展览、消息、我的。
3. 表达展览项目展示、企业展示、项目沟通、资料确认、我的楼聚合这些当前有真相依据的能力。
4. 提供轻 CTA：下载 App、预约试用、联系平台、查看隐私/协议。
5. 不触发业务写操作，不接入真实登录，不做后台，不做 CMS。

## 5. 禁止外推的承诺

官网文案不得出现以下承诺：

| 禁止承诺 | 原因 |
| --- | --- |
| 云上正式可用、生产已上线、全链路稳定运行 | 本阶段未做 runtime smoke；本地/合同/代码不能证明云端可用 |
| 全交易闭环、自动成交、在线签约、履约验收全流程 | 当前多个下游对象仍有阶段边界或 Reserved 状态 |
| 支付、真实扣费、钱包、余额、保证金、结算、退款、发票 | 根规则和服务费测试授权文档均明确不得外推 |
| 泛聊天、私聊、群聊、新 IM 主线 | 消息楼只承接项目沟通和互动入口 |
| 装修楼、全屋定制楼、建材市场公开入口 | 当前为隐藏预埋或保留非目标 |
| 地图找厂、直播、实时定位正式能力 | live / geo / map 仍为预埋，默认 flag-off |
| AI 推荐、智能派单、榜单排名、虚拟热度 | 缺少当前正式真源，且容易形成无根据营销承诺 |
| 假案例、假资质、假评价、假联系人、假数据看板 | 企业展示真相要求 public live detail 和真实返回字段 |
| CMS、博客系统、复杂后台、复杂动画 | 用户硬性边界禁止，当前阶段也无必要 |

## 6. 官网信息架构发现输入

Stage 2 可以基于以下输入做 sitemap 和首页结构，但不得在 Stage 1 固化 UI 方案。

### 6.1 建议 sitemap 输入

- `/`
  - 轻量 landing page。
- `/privacy`
  - 从 `docs/legal/privacy_policy.md` 派生或链接，不复制散落。
- `/terms`
  - 从 `docs/legal/user_agreement.md` 派生或链接，不复制散落。
- `/contact`
  - 可作为首页区块或独立页；客服邮箱当前有法务文本依据，客服电话为暂未公示。

第一版不建议开：

- `/blog`
- `/cms`
- `/admin`
- `/pricing`
- `/renovation`
- `/custom-furniture`
- `/marketplace`
- `/payment`
- `/case-studies`，除非后续有真实案例素材和公开授权。

### 6.2 建议首页内容输入

Stage 2 可围绕以下模块拆首页：

1. Hero：平台定位 + 一个主要 CTA + 一个次要 CTA。
2. 首发三楼：展览、消息、我的。
3. 核心场景：找项目 / 展示企业 / 沟通资料 / 维护身份与资产。
4. 平台边界：Server owns truth、文件受控、资料确认不等于成交、支付暂不公开承诺。
5. 适用对象：项目发布方、竞标/承接方、展示企业、平台运营侧。
6. CTA：下载/预约/联系。
7. 法务页入口。

### 6.3 可用资产输入

| Asset | 用途建议 | 边界 |
| --- | --- | --- |
| `apps/mobile/assets/app_icon/exhibition_custom_home_icon_source.png` | favicon / app icon 候选 | Stage 2 再确认尺寸和权属 |
| `apps/mobile/assets/images/exhibition/default_project_cover.jpg` | 项目展示氛围图候选 | 不得暗示真实客户案例 |
| `apps/mobile/assets/exhibition/project_examples/*.png` | 展位面积示意图候选 | 只能作为示意，不当作真实项目效果 |
| `docs/04_frontend/screenshots/*.png` | 内部审查截图 | 官网公开使用前需确认是否包含测试数据或敏感信息 |

## 7. 文案集中管理发现

官网公开文案必须集中管理。Stage 2 建议冻结以下原则：

- 官网营销文案集中在未来 `apps/website/src/content/**` 或文档指定的内容源，不散落在组件里。
- 法务文本以 `docs/legal/**` 为正式源，不在官网页面中手写第二份长期真相。
- CTA、SEO title、description、OG 文案、FAQ、能力边界文案均进入集中 content 文件。
- 不把接口名、技术字段、内部状态、测试授权、云端回执写进用户可见主文案。

## 8. 技术与部署发现

### 8.1 当前技术栈

- Monorepo package manager：`pnpm@10.8.0`。
- Admin：Next.js 16 / React 19 / TypeScript。
- Mobile：Flutter。
- BFF / Server：NestJS。
- Cloud baseline：Nginx 反代 BFF、Server、Admin。

### 8.2 官网部署缺口

当前 Nginx baseline 没有官网 upstream，也没有 `/` 官网路由、`robots.txt`、`sitemap.xml`、`/_next/` 静态资源规则。

Stage 3 之后如果实现官网 MVP，仍只能称为本地官网实现。若要称为云上官网可用，必须另过部署和 runtime verification。

### 8.3 依赖策略

第一版官网不需要大型依赖。若 Stage 3 使用 Next.js，应优先复用 Next / React / TypeScript / CSS 能力，不引入 CMS、动画库、UI 大包或数据层依赖。

## 9. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 新增独立 `apps/website`，静态/半静态官网，与 App、Admin、BFF、Server 隔离 |
| 哪个更省成本 | 复用仓库已有 Next.js 技术经验和依赖版本，但不要把官网塞进 Admin |
| 哪个更适合当前阶段 | 先完成 Stage 1 discovery，再做 Stage 2 blueprint/spec，等用户确认后才实现 |
| 哪个风险更大 | 直接改 Admin、Flutter、BFF、Server，或把未验证 runtime / 支付 / 全交易能力写成官网承诺 |

## 10. Stage 2 输入清单

Stage 2 应输出：

1. `docs/official-website-blueprint.md`
2. `docs/official-website-build-spec.md`

Stage 2 必须包含：

- sitemap
- 首页结构图
- 转化路径图
- 组件拆分
- 验收标准
- 文案集中管理方案
- 官网与 App / Admin / BFF / Server 隔离方案
- 不可公开承诺清单
- Stage 3 实现门禁

## 11. Stage 2 No-Go

Stage 2 仍不得：

- 创建或修改 `apps/website`
- 修改 `apps/admin`
- 修改 `apps/mobile`
- 修改 `apps/bff`
- 修改 `apps/server`
- 修改 `pnpm-workspace.yaml`
- 安装依赖
- 启动 dev server
- 改 Nginx / deploy / runtime
- 编造公开产品能力

## 12. 执行回执

本阶段新增文件：

- `docs/official-website-discovery.md`

本阶段未新增、未修改、未删除任何官网代码、App 代码、Admin 代码、BFF 代码、Server 代码、合同、生成物、Nginx 或依赖配置。

本阶段结论：

- `Go` for Stage 2 docs-only blueprint/spec.
- `No-Go` for Stage 3 implementation until blueprint is reviewed and confirmed by user.
