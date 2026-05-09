# 官方网站 Stage 4 独立审查与验收

> 适用阶段：Stage 2 蓝图与施工说明、Stage 3 官网 MVP 实现、Stage 4 独立审查。
> 第一真源：`docs/official-website-discovery.md`。
> 审查结论日期：2026-05-08。

## 1. 总裁决

PASS。

- Stage 2：PASS，已输出官网蓝图和施工说明，未发现阻断 Stage 3 的 P0/P1 边界风险。
- Stage 3：PASS，已新增独立 `apps/website` 官网包，未修改 App / Admin / BFF / Server 核心业务逻辑。
- Stage 4：PASS，lint、typecheck、build 已通过，公开文案边界已复核。

当前更稳的方案是新增独立 `apps/website`；更省成本的方案是复用仓库已有 Next.js / React / TypeScript 技术经验；更适合当前阶段的是单页官网 MVP；风险更大的是直接改 Admin / Flutter / BFF / Server 或直接改云端 Nginx。

## 2. 本轮变更摘要

本轮把官网第一版冻结为一个轻量、可构建、可部署预备的 Next.js landing page。官网只公开表达展览项目展示、企业展示、项目沟通、资料协作、消息楼、我的楼和首发三楼，不宣传支付、全交易闭环、真实案例、隐藏楼公开开放或内部运行状态。

## 3. 新增文件列表

- `docs/official-website-blueprint.md`
- `docs/official-website-build-spec.md`
- `docs/official-website-acceptance.md`
- `apps/website/package.json`
- `apps/website/next.config.ts`
- `apps/website/tsconfig.json`
- `apps/website/eslint.config.mjs`
- `apps/website/next-env.d.ts`
- `apps/website/README.md`
- `apps/website/src/app/layout.tsx`
- `apps/website/src/app/page.tsx`
- `apps/website/src/app/privacy/page.tsx`
- `apps/website/src/app/terms/page.tsx`
- `apps/website/src/app/contact/page.tsx`
- `apps/website/src/app/robots.ts`
- `apps/website/src/app/sitemap.ts`
- `apps/website/src/app/icon.svg`
- `apps/website/src/components/SiteHeader.tsx`
- `apps/website/src/components/SiteFooter.tsx`
- `apps/website/src/components/HeroSection.tsx`
- `apps/website/src/components/FeatureGrid.tsx`
- `apps/website/src/components/BuildingSection.tsx`
- `apps/website/src/components/WorkflowSection.tsx`
- `apps/website/src/components/AudienceSection.tsx`
- `apps/website/src/components/BoundarySection.tsx`
- `apps/website/src/components/CtaSection.tsx`
- `apps/website/src/content/site.ts`
- `apps/website/src/styles/globals.css`

## 4. 修改文件列表

- `package.json`：仅新增 website 相关脚本。
- `pnpm-workspace.yaml`：仅加入 `apps/website`。
- `pnpm-lock.yaml`：由 `pnpm install` 更新 workspace 锁定信息和 website importer。

## 5. 未触碰边界确认

本轮未修改以下路径：

- `apps/admin/**`
- `apps/mobile/**`
- `apps/bff/**`
- `apps/server/**`
- `packages/contracts/**`
- `docs/01_contracts/**`
- `infra/nginx/**`
- `infra/env/**`

本轮未 SSH、未改云端、未改 Nginx、未改 env、未改合同生成物、未新增数据库、未新增登录系统、未新增支付系统、未接入真实写操作 API。

## 6. 官网页面清单

- `/`：官网首页 landing page。
- `/privacy`：隐私政策轻量摘要，指向正式源 `docs/legal/privacy_policy.md`。
- `/terms`：用户协议轻量摘要，指向正式源 `docs/legal/user_agreement.md`。
- `/contact`：轻量联系入口。
- `/robots.txt`：由 website 提供。
- `/sitemap.xml`：由 website 提供。
- `/icon.svg`：官网图标。

未新增 `/blog`、`/pricing`、`/case-studies`、`/docs`、`/admin`、`/renovation`、`/custom-furniture`、`/marketplace`、`/payment`。

## 7. 文案边界检查

公开文案集中在 `apps/website/src/content/site.ts`。组件中不散落中文营销文案。

允许表达：

- 面向展览装修与展览定制场景。
- 支持项目展示、企业展示、项目沟通、资料协作。
- 支持消息与互动入口。
- 支持我的楼聚合个人、组织、认证、项目等入口。
- 当前首发围绕展览、消息、我的三楼展开。

## 8. 禁止承诺检查

| 检查项 | 结果 |
| --- | --- |
| 支付、扣费、结算、退款、钱包、保证金、发票 | PASS，仅在能力边界中以“不承诺”方式出现 |
| 完整交易闭环、自动成交、履约验收全流程 | PASS，仅在能力边界中以“不承诺”方式出现 |
| AI 推荐、智能派单、地图找厂、直播 | PASS，仅在能力边界中以“不承诺”方式出现 |
| 装修楼、全屋定制楼、建材市场已开放 | PASS，仅声明不写成已公开开放 |
| 大量真实客户案例、真实成交、生产全链路稳定运行 | PASS，未写入 |
| 内部 runtime、进程、端口、环境变量、支付通知 URL | PASS，未写入用户可见页面 |

用户补充的云端健康与证书状态只作为内部施工背景，不作为官网营销承诺。

## 9. 响应式检查

- 样式为移动端优先，桌面端使用受控最大宽度和网格布局。
- Header、Hero、三楼区、核心场景区、流程区、边界区、CTA、Footer 均有小屏断点。
- 固定卡片、按钮、导航、流程项设置了稳定间距和换行规则，避免移动端文字溢出。
- 未使用复杂动画或大型视觉依赖。

## 10. SEO 检查

- `title`：已实现。
- `description`：已实现。
- Open Graph title / description：已实现。
- `metadataBase` / canonical：已实现。
- `robots.txt`：已实现。
- `sitemap.xml`：已实现。
- `viewport`：由 Next.js App Router 默认与 metadata 管理承接。
- `icon.svg`：已实现。
- SEO 关键词：控制在展览装修、展览定制、展台搭建、展览项目管理、企业展示、项目沟通、资料协作等范围内，未做关键词堆砌。

## 11. 构建 / lint / typecheck 结果

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git status --short` | PASS | 已记录工作区存在其他模块预置脏改，本轮未触碰 |
| `pnpm install` | PASS | 新增 workspace package 后用于生成 website 本地依赖链接和锁文件 |
| `pnpm --filter website lint` | PASS | ESLint 通过 |
| `pnpm --filter website typecheck` | PASS | TypeScript 通过；一次并发 build 清理 `.next/types` 导致的缓存竞态已串行重跑通过 |
| `pnpm --filter website build` | PASS | Next.js 生产构建通过，静态生成 `/`、`/contact`、`/privacy`、`/terms`、`/robots.txt`、`/sitemap.xml` |
| `rg -n "[\\p{Han}]" apps/website/src --glob '!**/content/site.ts'` | PASS | 无输出，公开中文文案已集中 |
| `rg -n` 禁止承诺关键词检查 | PASS | 命中项均为蓝图或官网能力边界中的否定性说明 |
| `pnpm --filter website exec next dev -p 3200` | PASS | 本地开发服务启动于 `http://localhost:3200` |
| `curl -I http://localhost:3200/` | PASS | 首页返回 200 |
| `curl -I http://localhost:3200/robots.txt` | PASS | robots 返回 200 |
| `curl -I http://localhost:3200/sitemap.xml` | PASS | sitemap 返回 200 |
| `curl -I http://localhost:3200/icon.svg` | PASS | favicon / app icon 返回 200，类型为 `image/svg+xml` |

## 12. 已知风险

- 工作区存在与本轮无关的既有脏改，集中在 `apps/mobile`、`apps/bff`、`apps/server`、`infra/env/formal_cloud_target.env` 和若干 SSOT 草案；本轮未清理、未覆盖。
- 法务页当前是官网轻量摘要，不替代正式隐私政策与用户协议。
- 本轮未做云端发布、未做线上 smoke、未验证线上首页 200。
- 当前 `infra/nginx/cloud.conf` 已存在 `location ^~ /_next/` 指向 Admin；Stage 5 若让 `/_next/static` 指向 website，必须先确认 Admin 静态资源不会被覆盖，或在 deploy plan 中给出 Admin / Website 静态资源隔离方案。

## 13. Stage 5 云端部署建议

建议进入 Stage 5，但必须先输出并确认部署预案，不得直接改云端。

建议形态：

- 官网进程端口：建议 `127.0.0.1:3003`，避开当前 BFF `3000`、Server `3001`、Admin `3002`。
- 构建产物：`apps/website/.next` 和 Next.js 运行所需产物；生产启动使用 `pnpm --filter website exec next start -p 3003` 或等价进程管理命令。
- 进程管理：使用与现有云端一致的进程管理方式，独立命名 `website`，不得复用 BFF / Server / Admin 进程。
- Nginx 路由：`/` 指向 website；`/robots.txt`、`/sitemap.xml`、`/icon.svg` 指向 website；`/_next/static` 指向 website 静态资源。
- API 保持：`/api/app/project/list`、`/api/app/**`、`/health/bff/live` 继续转发 BFF。
- Server health 保持：`/health/server/live` 继续转发 Server。
- Admin 保持：已有 Admin 路由和 Admin 静态资源不得被 website 覆盖。
- 部署前 smoke：检查 `/`、`/robots.txt`、`/sitemap.xml`、`/api/app/project/list`、`/health/bff/live`、`/health/server/live`、HTTPS SAN、favicon、title、description。
- 回滚：保留上一份 Nginx 配置与上一版进程状态；失败时恢复 Nginx 配置、停止或切回 website 进程、重新 smoke API 与 health 路由。

Stage 5 最大风险是 `/_next/static` 与现有 Admin `/_next/` 路由冲突。更稳的做法是在部署预案中先给出 Nginx diff plan 和静态资源隔离裁决，再进入实际部署。

## 14. 是否建议合并

建议合并官网 MVP 代码与 Stage 2 / Stage 4 文档。

不建议直接云端发布。下一步应进入 Stage 5 云端部署预案，先审查 Nginx route diff、进程端口、smoke 与回滚，再执行最小发布。

## 15. V2 视觉升级验收记录

### 15.1 总裁决

PASS。

本轮 V2 只升级 `apps/website` 前端视觉和首页结构，并新增 `docs/official-website-v2-visual-upgrade.md`。未 SSH、未发布线上、未改 Nginx、未重启服务、未改 env、未改 API、未改 BFF / Server / Admin / Flutter / contracts。

### 15.2 本轮变更摘要

- 首页从文档型 landing page 升级为产品展示型官网。
- Hero 首屏改为左侧平台定位、标题、副标题、双 CTA、标签，右侧为 CSS 还原的 App 首页视觉样机。
- 新增信任能力条：真实项目展示、资料协作共票、多角色协同、隐私与安全。
- 首页结构调整为顶部导航、Hero、信任能力条、首发三楼、核心场景、工作路径、能力边界、适用对象、CTA、Footer。
- 样式拆分为 tokens、base、home、pages、responsive，统一米白 / 白色、深绿色、金色点缀、大圆角卡片和柔和阴影。
- 公开文案继续集中在 `apps/website/src/content/site.ts`。

### 15.3 新增文件

- `docs/official-website-v2-visual-upgrade.md`
- `apps/website/src/components/TrustStrip.tsx`
- `apps/website/src/styles/base.css`
- `apps/website/src/styles/home.css`
- `apps/website/src/styles/pages.css`
- `apps/website/src/styles/responsive.css`
- `apps/website/src/styles/tokens.css`

### 15.4 修改文件

- `docs/official-website-acceptance.md`
- `apps/website/src/app/page.tsx`
- `apps/website/src/components/AudienceSection.tsx`
- `apps/website/src/components/BoundarySection.tsx`
- `apps/website/src/components/BuildingSection.tsx`
- `apps/website/src/components/FeatureGrid.tsx`
- `apps/website/src/components/HeroSection.tsx`
- `apps/website/src/components/SiteFooter.tsx`
- `apps/website/src/components/SiteHeader.tsx`
- `apps/website/src/components/WorkflowSection.tsx`
- `apps/website/src/content/site.ts`
- `apps/website/src/styles/globals.css`

### 15.5 未触碰边界

本轮未修改：

- `apps/admin/**`
- `apps/mobile/**`
- `apps/bff/**`
- `apps/server/**`
- `packages/contracts/**`
- `docs/01_contracts/**`
- `infra/nginx/**`
- `infra/env/**`
- `pnpm-workspace.yaml`
- `pnpm-lock.yaml`
- 支付配置
- 云端部署配置

### 15.6 素材与截图裁决

仓库内存在 `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_exhibition_home.png`，但该图包含桌面模拟器与外部界面，不适合作为官网公开产品图直接发布。

本轮未下载公网图片，未使用未经确认授权的图片。Hero 右侧先用 CSS 和集中内容还原 App 首页视觉样机。后续若用户提供可公开使用的真实 App 首页截图，可替换该样机。

### 15.7 文案边界检查

PASS。

- 未写入支付、扣费、结算、退款、钱包、保证金、发票能力承诺。
- 未写入完整交易闭环、合同签约、履约验收、真实成交承诺。
- 未写入智能派单、AI 推荐、地图找厂、直播能力承诺。
- 未把装修楼、全屋定制楼、建材市场写成已开放。
- 未写入虚构案例、虚构评价、虚构资质或虚构数据看板。
- 未暴露内部 runtime、端口、进程、环境变量或支付通知 URL。

### 15.8 响应式与视觉检查

PASS。

- 桌面端使用双栏 Hero、产品样机、能力条和高密度卡片。
- 平板端将 Hero、信任条、场景卡片和流程卡片降为两列。
- 移动端将主要区块降为单列，隐藏装饰性展馆背景，保持按钮和文字可读。
- 未使用视口宽度驱动字体缩放。
- 未引入复杂动画、图表库、CMS 或大型 UI 库。

### 15.9 SEO 与基础页面检查

PASS。

- `title`、`description`、Open Graph、canonical、keywords 保持可用。
- `/robots.txt`、`/sitemap.xml`、`/icon.svg` 保持可用。
- `/privacy`、`/terms`、`/contact` 页面未删除。

### 15.10 验证命令结果

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git status --short` | PASS | 已确认工作区存在其他模块既有脏改，本轮不触碰 |
| `rg -n "[\\p{Han}]" apps/website/src --glob '!**/content/site.ts'` | PASS | 无输出，组件内未散落中文公开文案 |
| `rg -n` 禁止承诺关键词检查 | PASS | 命中均为否定性边界说明或验收文档，不是能力承诺 |
| `pnpm --filter website lint` | PASS | ESLint 通过 |
| `pnpm --filter website typecheck` | PASS | TypeScript 通过 |
| `git diff --check -- apps/website docs/official-website-v2-visual-upgrade.md docs/official-website-acceptance.md` | PASS | 无空白错误 |
| `pnpm --filter website build` | PASS | Next.js 生产构建通过，静态生成 9 个页面 / 资源 |
| `curl -I http://localhost:3200/` | PASS | 本地首页 200 |
| `curl -I http://localhost:3200/privacy` | PASS | 本地隐私政策页 200 |
| `curl -I http://localhost:3200/terms` | PASS | 本地用户协议页 200 |
| `curl -I http://localhost:3200/contact` | PASS | 本地联系页 200 |
| `curl -I http://localhost:3200/robots.txt` | PASS | 本地 robots 200 |
| `curl -I http://localhost:3200/sitemap.xml` | PASS | 本地 sitemap 200 |
| `curl -I http://localhost:3200/icon.svg` | PASS | 本地 icon 200，类型为 `image/svg+xml` |

### 15.11 已知风险

- 本轮未云端发布，线上官网不会自动变成 V2。
- 当前 Hero 样机是 CSS 视觉还原，不是正式 App 首页截图。需要用户后续提供可公开使用的真实产品截图，才能替换为真实截图主视觉。
- 工作区仍存在本轮无关的既有脏改，集中在 mobile、BFF、Server、infra/env、workspace 配置和 SSOT 草案；本轮未清理、未覆盖。

### 15.12 是否建议进入下一步

建议先做一次人工浏览器视觉审查，确认首屏比例、样机观感和移动端折叠效果。确认后再另开部署阶段发布 V2；不得把本轮本地构建结果视为线上已发布。

## 16. V2.1 效果图施工验收记录

### 16.1 总裁决

PASS。

本轮按确认后的 4 天路径执行：第 1 天只读冻结，第 2 天完成首屏视觉闭环，第 3 天完成主体区块升级，第 4 天完成响应式、构建、smoke 与边界验收。未 SSH、未发布线上、未改 Nginx、未重启服务、未改 env、未改 API、未改 BFF / Server / Admin / Flutter / contracts。

### 16.2 子代理回执

- 视觉审查子代理：`CONDITIONAL PASS`。确认目标图区域已映射到官网组件和 CSS；最大剩余风险是没有正式授权 App 截图，当前仍是 CSS 高保真样机。
- 边界审查子代理：`CONDITIONAL PASS`。确认当前文案没有硬性能力承诺越界；能力带应继续使用定性短语，不使用数字战报、客户背书或交易承诺。

### 16.3 本轮完成内容

- Header 升级为官网产品导航，右侧增加“联系平台”和“查看用户协议”双按钮。
- Hero 首屏强化为左侧定位文案、CTA、首发标签，右侧 iPhone 产品样机与展馆空间背景。
- 保留信任能力条：真实项目展示、资料协作共票、多角色协同、隐私与安全。
- 核心场景四卡片升级为图标 + 文案 + 小型界面 / 空间视觉。
- 工作路径保持横向 01-04 流程。
- 新增深绿色品牌能力带，使用“展示清晰、沟通有序、资料留痕、边界明确、隐私安全”，不放任何统计数字。
- CTA 区加入暖金展馆空间感。

### 16.4 新增文件

- `apps/website/src/components/CapabilityBand.tsx`
- `apps/website/src/styles/showcase.css`

### 16.5 修改文件

- `apps/website/src/app/page.tsx`
- `apps/website/src/components/SiteHeader.tsx`
- `apps/website/src/content/site.ts`
- `apps/website/src/styles/globals.css`
- `docs/official-website-acceptance.md`

### 16.6 未触碰边界

本轮未修改：

- `apps/admin/**`
- `apps/mobile/**`
- `apps/bff/**`
- `apps/server/**`
- `packages/contracts/**`
- `docs/01_contracts/**`
- `infra/nginx/**`
- `infra/env/**`
- `pnpm-workspace.yaml`
- `pnpm-lock.yaml`
- 支付配置
- 云端部署配置

### 16.7 文案边界检查

PASS。

- 能力带没有使用 `128+`、`230+`、`560+`、`870+`、`100%` 等效果图示例数字。
- 未写入支付、扣费、结算、退款、钱包、保证金、发票能力承诺。
- 未写入完整交易闭环、合同签约、履约验收、真实成交承诺。
- 未写入智能派单、AI 推荐、地图找厂、直播能力承诺。
- 未把装修楼、全屋定制楼、建材市场写成已开放。
- 未写入虚构案例、虚构评价、虚构资质或虚构数据看板。
- 未暴露内部 runtime、端口、进程、环境变量或支付通知 URL。

### 16.8 验证命令结果

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git status --short` | PASS | 已确认工作区存在其他模块既有脏改，本轮不触碰 |
| `rg -n "[\\p{Han}]" apps/website/src --glob '!**/content/site.ts'` | PASS | 无输出，组件内未散落中文公开文案 |
| `rg -n` 禁止承诺关键词检查 | PASS | 命中均为否定性边界说明、CSS 百分比或 sitemap 固定日期，不是能力承诺 |
| `pnpm --filter website lint` | PASS | ESLint 通过 |
| `pnpm --filter website typecheck` | PASS | TypeScript 通过 |
| `git diff --check -- apps/website docs/official-website-acceptance.md docs/official-website-v2-visual-upgrade.md` | PASS | 无空白错误 |
| `pnpm --filter website build` | PASS | Next.js 生产构建通过，静态生成 9 个页面 / 资源 |
| `curl -I http://localhost:3200/` | PASS | 本地首页 200 |
| `curl -I http://localhost:3200/privacy` | PASS | 本地隐私政策页 200 |
| `curl -I http://localhost:3200/terms` | PASS | 本地用户协议页 200 |
| `curl -I http://localhost:3200/contact` | PASS | 本地联系页 200 |
| `curl -I http://localhost:3200/robots.txt` | PASS | 本地 robots 200 |
| `curl -I http://localhost:3200/sitemap.xml` | PASS | 本地 sitemap 200 |
| `curl -I http://localhost:3200/icon.svg` | PASS | 本地 icon 200，类型为 `image/svg+xml` |

### 16.9 已知风险

- 本轮未云端发布，线上官网不会自动变成 V2.1。
- 当前 Hero 样机是 CSS 高保真还原，不是正式 App 首页截图。需要用户后续提供可公开使用的真实产品截图后再替换。
- 当前工作区仍存在本轮无关的既有脏改，集中在 mobile、BFF、Server、infra/env、workspace 配置和 SSOT 草案；本轮未清理、未覆盖。

### 16.10 下一步建议

建议用户先在 `http://localhost:3200` 做人工视觉确认。确认后再单独进入云端发布阶段；不得把本轮本地验收视为线上已发布。

### 16.11 本地人工视觉确认补充

PASS。

在 `http://localhost:3200` 使用 Chrome DevTools Protocol 分别以桌面 `1440 x 1600` 和移动端 `390 x 1400` 视口截图确认。初次移动端截图发现横向裁切风险，根因是 CSS 中存在 `calc(... var(--page-x) * 2)` 乘法写法导致容器宽度约束不稳定；已改为 `calc(100% - var(--page-x) - var(--page-x))` / `calc(100vw - var(--page-x) - var(--page-x))`，并补充移动端标题、导航、手机样机宽度约束。

确认结果：

- 桌面端：Header、Hero、App 样机、展馆背景、信任能力条、核心场景区呈现正常。
- 移动端：导航换行正常，Hero 标题不再裁切，CTA 与标签不重叠，手机样机完整可见。
- 本地 dev 页面左下角的 Next.js 开发标识仅存在于 dev server，不属于生产构建输出。

截图证据：

- `/tmp/website-v21-cdp-desktop.png`
- `/tmp/website-v21-cdp-mobile.png`
