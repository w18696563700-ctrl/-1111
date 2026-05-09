---
owner: Codex 官网施工代理
status: stage-2-build-spec
purpose: Freeze the implementation specification for the first official website MVP.
layer: Website / Build Spec
updated_at: 2026-05-08
source_of_truth:
  - docs/official-website-discovery.md
  - docs/official-website-blueprint.md
---

# 官方网站 Stage 2 Build Spec

## 0. 总裁决

`Stage 2 Build Spec = PASS`。

Stage 3 采用独立 `apps/website`，使用 Next.js / React / TypeScript / 全局 CSS。第一版只做静态或半静态 landing page，不引入大型 UI 库、CMS、数据库、登录、支付、动画大包或真实写操作 API。

## 1. 技术方案裁决

| 方案 | 裁决 |
| --- | --- |
| 独立 `apps/website` | 采用 |
| 放入 `apps/admin` | 不采用 |
| 放入 `apps/bff` / `apps/server` | 不采用 |
| Flutter Web 官网 | 不采用 |

### 1.1 为什么选择 `apps/website`

- 与 Admin 权限、登录、middleware 和 Server Admin API 隔离。
- 与 Flutter App 业务路由和 shell 隔离。
- 与 BFF / Server 业务真值隔离。
- 后续可独立端口、独立进程、独立 Nginx 根路径发布。

### 1.2 为什么不放入 Admin

Admin 是受控运营后台，只能调用 Server Admin API。官网是公开入口。混入 Admin 会扩大登录、`/_next/`、后台导航和权限边界风险。

### 1.3 为什么不放入 BFF / Server

BFF 是 App-facing 聚合层，Server 是业务真值 owner。官网页面不应污染 API 层或业务真值层。

### 1.4 为什么不做 Flutter Web 官网

Flutter 是当前移动 App 主客户端，不适合第一版 SEO、sitemap、robots 和轻量官网部署。

## 2. 目录结构

```text
apps/website/
  package.json
  next.config.ts
  tsconfig.json
  eslint.config.mjs
  src/
    app/
      layout.tsx
      page.tsx
      contact/page.tsx
      privacy/page.tsx
      terms/page.tsx
      robots.ts
      sitemap.ts
      icon.svg
    components/
      AudienceSection.tsx
      BoundarySection.tsx
      BuildingSection.tsx
      CtaSection.tsx
      FeatureGrid.tsx
      HeroSection.tsx
      SiteFooter.tsx
      SiteHeader.tsx
      WorkflowSection.tsx
    content/
      site.ts
    styles/
      globals.css
  README.md
```

## 3. 组件拆分

| Component | Responsibility |
| --- | --- |
| `SiteHeader` | 品牌、导航、顶部 CTA |
| `HeroSection` | 首屏定位、边界内价值、主 CTA |
| `BuildingSection` | 首发三楼 |
| `FeatureGrid` | 核心场景能力 |
| `WorkflowSection` | 轻量工作流 |
| `BoundarySection` | 明确不承诺能力 |
| `AudienceSection` | 目标用户 |
| `CtaSection` | 转化 CTA |
| `SiteFooter` | 法务、联系、版权 |

## 4. 文案集中管理

所有官网公开文案集中在：

- `apps/website/src/content/site.ts`

包含：

- site metadata
- navigation
- hero
- sections
- features
- workflow steps
- audience
- boundary notes
- CTA
- footer
- SEO title / description
- Open Graph 文案

组件只消费 content，不散落大量营销文案。

## 5. 样式方案

- 使用全局 CSS：`apps/website/src/styles/globals.css`。
- 不引入 UI 库。
- 不引入动画大包。
- 使用少量 CSS transitions，避免复杂动画。
- 色彩保持克制，服务平台型信息表达。

## 6. 响应式规则

- Mobile first。
- 小屏单列，主要 CTA 不溢出。
- 中屏两列能力卡。
- 桌面端增强信息密度，但不使用营销型大面积空白堆叠。
- Header 在窄屏允许换行。
- 卡片和按钮必须避免文字溢出。

## 7. SEO Metadata

必须实现：

- title
- description
- Open Graph title
- Open Graph description
- canonical metadata base
- viewport 由 Next.js 管理
- robots
- sitemap
- favicon / app icon

默认站点 URL：

- `https://zhanlan.ddup-ddup.com`

该 URL 只用于 SEO metadata 和部署预备，不在官网文案中宣传内部 runtime 状态。

## 8. Robots / Sitemap

- `src/app/robots.ts` 输出允许索引官网公开页。
- `src/app/sitemap.ts` 输出 `/`、`/privacy`、`/terms`、`/contact`。
- 不包含未开放页面。

## 9. Favicon / App Icon

- Stage 3 使用轻量 `icon.svg` 作为官网 favicon。
- 不复制移动端图片资产，避免二进制资产和权属扩大。
- 后续如要使用 App icon，需单独确认资产规范。

## 10. 性能要求

- 不接首页动态生产 API。
- 不加载第三方 JS。
- 不引入大依赖。
- 首屏信息静态渲染。
- 图片和视觉表达使用 CSS / HTML 轻量结构。

## 11. 可访问性要求

- 使用语义化 `header`、`main`、`section`、`footer`。
- CTA 使用真实链接。
- 色彩对比满足基础可读性。
- Focus 状态可见。
- 导航锚点命名清晰。

## 12. 本地运行方式

```bash
pnpm --filter website dev
```

默认端口由 Next.js 决定。若端口冲突，使用：

```bash
pnpm --filter website exec next dev -p 3200
```

## 13. 构建命令

```bash
pnpm --filter website lint
pnpm --filter website typecheck
pnpm --filter website build
```

若新增 workspace 后 pnpm 无法识别 package，允许运行一次：

```bash
pnpm install
```

只允许用于更新 workspace lock，不得安装大型额外依赖。

## 14. 验收标准

- `pnpm --filter website lint` 通过。
- `pnpm --filter website typecheck` 通过。
- `pnpm --filter website build` 通过。
- 页面存在 `/`、`/privacy`、`/terms`、`/contact`。
- robots 与 sitemap 存在。
- title / description / Open Graph metadata 存在。
- 官网文案不承诺支付、全交易闭环、隐藏楼公开、AI 派单、地图找厂、直播或真实客户案例。
- 不修改 Admin / Flutter / BFF / Server / Contracts / Nginx / env。

## 15. 不允许触碰的代码边界

- `apps/admin/**`
- `apps/mobile/**`
- `apps/bff/**`
- `apps/server/**`
- `packages/contracts/**`
- `docs/01_contracts/**`
- `infra/nginx/**`
- `infra/env/**`

## 16. Stage 3 实现门禁

| Gate | Result |
| --- | --- |
| Discovery exists | PASS |
| Blueprint and build spec exist | PASS after this file |
| No Admin / Flutter / BFF / Server changes required | PASS |
| No large dependency required | PASS |
| No env / secret access required | PASS |
| Dirty worktree conflict with website scope | PASS; existing dirty files are outside website scope |

## 17. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 独立 `apps/website` |
| 哪个更省成本 | 复用 Next.js / React / TypeScript 技术经验和既有版本 |
| 哪个更适合当前阶段 | 单页官网 MVP + 三个轻量法务/联系页面 |
| 哪个风险更大 | 直接改 Admin / Flutter / BFF / Server 或云端 Nginx |
