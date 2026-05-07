# 官方网站 Stage 5A 云端部署预案与 Nginx Diff Plan

> 阶段：Stage 5A，仅预案。
> 状态：PLAN ONLY，未发布、未 SSH、未修改云端、未修改 Nginx、未修改 env、未重启服务。
> 第一真源：`docs/official-website-discovery.md`。
> 前置验收：`docs/official-website-acceptance.md` 已记录 Stage 2 / 3 / 4 PASS。
> 日期：2026-05-08。

## 0. 总裁决

`Stage 5A = CONDITIONAL GO FOR DEPLOY PLAN ONLY`。

推荐方案：方案 B，同域名根路径挂 Website，但 Website 静态资源使用独立前缀 `/website-assets/_next/`，现有 Admin 的 `/_next/` 保持不变。

本阶段不执行部署。进入 Stage 5B 之前必须先获得用户确认，并且 Stage 5B 必须同时完成：

1. Website 生产静态资源前缀配置。
2. Nginx 新增 `website_upstream` 与 Website allowlist 路由。
3. 保持 Admin `/_next/`、Admin 页面、BFF API、BFF health、Server health 不变。
4. 部署后 smoke 全部通过。

更稳：方案 B，不覆盖现有 Admin `/_next/`。
更省成本：方案 B，只改 Website config 和 Nginx 路由，不改 Admin。
更适合当前阶段：方案 B，支撑单页官网 MVP 最小发布。
风险更大：直接把 `/_next/` 改给 Website，或把 Admin 改成 `/admin` basePath。

## 1. 本阶段边界

本阶段只新增本文档。

本阶段禁止：

- SSH 云服务器。
- 修改线上 Nginx。
- 重启 Nginx、BFF、Server、Admin 或任何线上服务。
- 修改 `infra/env/**`。
- 修改支付配置。
- 修改 `apps/admin/**`、`apps/mobile/**`、`apps/bff/**`、`apps/server/**`、`packages/contracts/**`。
- 修改数据库。
- 读取或暴露密钥。
- 把官网写成已上线。

本阶段已只读查看：

- `infra/nginx/cloud.conf`
- `apps/website/next.config.ts`
- `apps/website/package.json`
- `apps/admin/next.config.ts`
- `apps/admin/package.json`
- `apps/admin/src/middleware.ts`
- `package.json`
- `pnpm-workspace.yaml`

## 2. 当前部署事实与冲突

### 2.1 当前本地仓库 Nginx baseline

`infra/nginx/cloud.conf` 当前已有：

- `bff_upstream -> 127.0.0.1:3000`
- `server_upstream -> 127.0.0.1:3001`
- `admin_upstream -> 127.0.0.1:3002`
- `/health/bff/live -> bff_upstream`
- `/health/server/live -> server_upstream`
- `/api/app/project/list` 与其他 App API 路由 -> `bff_upstream`
- `/login`、`/governance`、`/review`、`/project_review`、`/template_config`、`/audit` -> `admin_upstream`
- `/_next/ -> admin_upstream`
- `/api/auth/`、`/api/health` -> `admin_upstream`
- `/server/admin/`、`/api/admin/` -> `server_upstream`

### 2.2 当前 Website / Admin Next 配置

`apps/admin/next.config.ts`：

- 无 `basePath`
- 无 `assetPrefix`
- 因此 Admin 默认使用 `/_next/`

`apps/website/next.config.ts`：

- 无 `basePath`
- 无 `assetPrefix`
- 因此 Website 默认也使用 `/_next/`

### 2.3 核心冲突

如果只把 `/` 代理到 Website，而 `/_next/` 仍指向 Admin：

- Website HTML 可能返回 200。
- Website CSS / JS 会请求 `/_next/static/...`。
- Nginx 会把这些请求发给 Admin。
- 结果可能是 404、加载 Admin 静态资源、页面无样式或 hydration 失败。

因此不得直接发布。必须先隔离 Website 静态资源。

## 3. 三方案对比

| 方案 | 稳定性 | 成本 | 当前阶段适配度 | 对 Admin 影响 | 对 API / health 影响 | 是否需改代码 | 是否需改 Nginx | 是否建议 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A. Website 和 Admin 分域名 | 高 | 中到高 | 中 | 低；Admin 原路径可保持 | 低；API / health 可保持原域 | 可能需要 metadata / canonical 调整 | 需要新增 server block、DNS / 证书路由 | 暂不推荐，适合后续正式域名治理 |
| B. 同域根路径挂 Website，Website 静态资源走 `/website-assets/_next/` | 高 | 低到中 | 高 | 低；Admin `/_next/` 保持不变 | 低；不触碰 API / health location | 需要改 Website `assetPrefix` | 需要新增 Website upstream 和 allowlist 路由 | 推荐 |
| C. Admin 改成 `/admin` basePath | 中 | 高 | 低 | 高；需要改 Admin 路由、链接、middleware、Nginx 和回归 | 低到中；若误改 `/api/auth` 会影响 Admin 登录 | 需要大范围改 Admin | 需要较大 Nginx 改造 | 不推荐 |

### 3.1 为什么方案 B 比直接覆盖 `/_next/` 更安全

直接把 `/_next/` 改给 Website 会立即破坏当前 Admin 静态资源，因为 Admin 仍默认从 `/_next/static/...` 加载 JS / CSS。方案 B 让：

- `/website-assets/_next/` 只服务 Website 静态资源。
- `/_next/` 继续服务 Admin 静态资源。
- `/api/**` 和 `/health/**` 保持原有匹配。
- Admin 不需要改代码、不需要改 basePath、不需要重做登录和 middleware 回归。

## 4. 推荐目标路由

候选部署结构：

```text
/                         -> website
/privacy                  -> website
/terms                    -> website
/contact                  -> website
/robots.txt               -> website
/sitemap.xml              -> website
/icon.svg                 -> website
/website-assets/_next/    -> website static assets, proxy/rewrite to website /_next/
/_next/                   -> existing Admin static assets, keep unchanged
/api/app/project/list     -> BFF, keep unchanged
/api/app/**               -> BFF, keep unchanged
/health/bff/live          -> BFF, keep unchanged
/health/server/live       -> Server, keep unchanged
/login                    -> Admin, keep unchanged
/governance               -> Admin, keep unchanged
/review                   -> Admin, keep unchanged
/project_review           -> Admin, keep unchanged
/template_config          -> Admin, keep unchanged
/audit                    -> Admin, keep unchanged
/api/auth/                -> Admin, keep unchanged
/api/health               -> Admin, keep unchanged
/server/admin/            -> Server Admin API, keep unchanged
/api/admin/               -> Server Admin API, keep unchanged
```

不建议在第一版使用宽泛 `location / { ... }` 吞掉所有未知路径。更稳的做法是官网页面 allowlist：只把 `/`、法务页、联系页、robots、sitemap、icon 和 Website 静态资源交给 Website。后续新增官网页面时再显式增加路由。

## 5. Website 端配置裁决

### 5.1 是否需要 asset prefix

需要。

方案 B 要求 Website 生产构建时生成 `/website-assets/_next/static/...` 静态资源 URL，否则 HTML 仍会指向 `/_next/static/...` 并进入 Admin。

### 5.2 是否需要修改 `apps/website/next.config.ts`

Stage 5B 需要修改，本阶段不修改。

建议 diff plan：

```diff
diff --git a/apps/website/next.config.ts b/apps/website/next.config.ts
--- a/apps/website/next.config.ts
+++ b/apps/website/next.config.ts
@@
 import type { NextConfig } from 'next';

 const nextConfig: NextConfig = {
   reactStrictMode: true,
+  assetPrefix: process.env.NODE_ENV === 'production' ? '/website-assets' : undefined,
 };

 export default nextConfig;
```

说明：

- 使用 `NODE_ENV === 'production'`，不新增 env，不修改 `infra/env/**`。
- 本地 `next dev` 保持默认 `/_next/`，不影响开发。
- 生产构建后 Website HTML 引用 `/website-assets/_next/static/...`。
- Nginx 再把 `/website-assets/_next/` 代理到 Website 的 `/_next/`。

### 5.3 是否需要 basePath

不需要。

Website 目标是挂在根路径 `/`，不能给 Website 配 `/website` basePath，否则首页不再是根路径。

## 6. 官网服务端口与进程管理

### 6.1 建议端口

建议 Website 监听：

```text
127.0.0.1:3003
```

理由：

- `3000` 已由 BFF 使用。
- `3001` 已由 Server 使用。
- `3002` 已由 Admin 使用。
- `3003` 与现有端口序列一致，便于 Nginx upstream 管理。

### 6.2 建议进程管理

更稳方案：使用与当前主联调链一致的 systemd release/current 形态，新增独立服务名：

```text
exhibition-website
```

建议生产启动命令：

```bash
pnpm exec next start -p 3003
```

要求：

- WorkingDirectory 指向 Website release 中的 `apps/website`。
- 不写入 env。
- 不复用 BFF / Server / Admin 进程。
- 不把 Website 放进 PM2 workspace 旁路链，除非后续另行冻结运行态策略。

Stage 5B 前必须只读确认当前云端进程管理真相。如果 active runtime 明确不是 systemd，需先重新出进程管理差异说明，不得直接套用。

## 7. Nginx Diff Plan

以下是对 `infra/nginx/cloud.conf` 的候选 diff plan。Stage 5A 不应用该 diff。

### 7.1 新增 Website upstream

建议加在 `admin_upstream` 后：

```diff
 upstream admin_upstream {
     server 127.0.0.1:3002;
 }
+
+upstream website_upstream {
+    server 127.0.0.1:3003;
+}
```

### 7.2 新增 Website 静态资源前缀

建议加在 `/.well-known/acme-challenge/` 后、所有业务/API/Admin 路由前。放在 `/_next/` 之前也可，但必须保持 `/_next/` Admin 规则不变。

```diff
     location ^~ /.well-known/acme-challenge/ {
         root /var/www/letsencrypt;
         default_type text/plain;
         try_files $uri =404;
     }
+
+    location ^~ /website-assets/_next/ {
+        proxy_http_version 1.1;
+        proxy_set_header Host $host;
+        proxy_set_header X-Real-IP $remote_addr;
+        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_pass http://website_upstream/_next/;
+    }
```

说明：

- 外部请求 `/website-assets/_next/static/...`。
- Nginx 转发到 Website upstream 的 `/_next/static/...`。
- 不覆盖 Admin 的 `/_next/`。

### 7.3 新增 Website 页面 allowlist

建议加在 health/API/Admin 路由之前或之后均可；Nginx exact / regex 匹配会优先于宽泛前缀。为可读性，建议放在 acme 与 health 之间。

```diff
+    location = / {
+        proxy_http_version 1.1;
+        proxy_set_header Host $host;
+        proxy_set_header X-Real-IP $remote_addr;
+        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_pass http://website_upstream;
+    }
+
+    location ~ ^/(privacy|terms|contact)/?$ {
+        proxy_http_version 1.1;
+        proxy_set_header Host $host;
+        proxy_set_header X-Real-IP $remote_addr;
+        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_pass http://website_upstream;
+    }
+
+    location = /robots.txt {
+        proxy_http_version 1.1;
+        proxy_set_header Host $host;
+        proxy_set_header X-Real-IP $remote_addr;
+        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_pass http://website_upstream;
+    }
+
+    location = /sitemap.xml {
+        proxy_http_version 1.1;
+        proxy_set_header Host $host;
+        proxy_set_header X-Real-IP $remote_addr;
+        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_pass http://website_upstream;
+    }
+
+    location = /icon.svg {
+        proxy_http_version 1.1;
+        proxy_set_header Host $host;
+        proxy_set_header X-Real-IP $remote_addr;
+        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_pass http://website_upstream;
+    }
```

### 7.4 必须保持不变的现有规则

以下规则不得删除、不得改指向、不得被 Website fallback 覆盖：

```nginx
location /health/bff/live { ... bff_upstream ... }
location /health/server/live { ... server_upstream ... }
location = /api/app/project/list { ... bff_upstream ... }
location ~ ^/api/app/(...) { ... bff_upstream ... }
location = /login { ... admin_upstream ... }
location ^~ /login/ { ... admin_upstream ... }
location = /governance { ... admin_upstream ... }
location ^~ /governance/ { ... admin_upstream ... }
location = /review { ... admin_upstream ... }
location ^~ /review/ { ... admin_upstream ... }
location = /project_review { ... admin_upstream ... }
location ^~ /project_review/ { ... admin_upstream ... }
location = /template_config { ... admin_upstream ... }
location ^~ /template_config/ { ... admin_upstream ... }
location = /audit { ... admin_upstream ... }
location ^~ /audit/ { ... admin_upstream ... }
location ^~ /_next/ { ... admin_upstream ... }
location ^~ /api/auth/ { ... admin_upstream ... }
location = /api/health { ... admin_upstream ... }
location ^~ /server/admin/ { ... server_upstream ... }
location /api/admin/ { ... server_upstream ... }
```

### 7.5 不建议的 Nginx diff

不得使用以下方式：

```diff
- location ^~ /_next/ { proxy_pass http://admin_upstream; }
+ location ^~ /_next/ { proxy_pass http://website_upstream; }
```

原因：这会破坏 Admin 静态资源。

不建议第一版新增：

```nginx
location / { proxy_pass http://website_upstream; }
```

原因：会吞掉当前未显式列出的路径，增加未来 Admin 路由和保留路径被 Website 404 接管的风险。

## 8. 部署前检查

Stage 5B 执行前必须检查：

1. 本地或 CI：
   - `pnpm --filter website lint`
   - `pnpm --filter website typecheck`
   - `pnpm --filter website build`
2. Website 生产 HTML 是否引用 `/website-assets/_next/static/`，而不是 `/_next/static/`。
3. `apps/website` 未接入生产项目列表动态拉取。
4. `apps/website/src/content/site.ts` 未新增支付、全交易闭环、真实案例、生产全链路稳定等承诺。
5. 当前 active Nginx 配置路径与本 diff plan 对应；若 active 配置不等于仓库 baseline，需要先重新生成 active-config diff plan。
6. `127.0.0.1:3003` 未被占用。
7. active BFF health、Server health、`/api/app/project/list` 均仍为 200。
8. HTTPS 证书 SAN 仍包含 `DNS:zhanlan.ddup-ddup.com`。
9. 已准备 Nginx 配置备份。
10. 已准备 Website 进程回滚方式。

## 9. 部署后 Smoke

只允许只读 smoke。建议顺序：

```bash
curl -I https://zhanlan.ddup-ddup.com/
curl -I https://zhanlan.ddup-ddup.com/privacy
curl -I https://zhanlan.ddup-ddup.com/terms
curl -I https://zhanlan.ddup-ddup.com/contact
curl -I https://zhanlan.ddup-ddup.com/robots.txt
curl -I https://zhanlan.ddup-ddup.com/sitemap.xml
curl -I https://zhanlan.ddup-ddup.com/icon.svg
```

预期：

- 均返回 200。
- 首页 HTML 包含官网 title / description。
- 首页 HTML 静态资源 URL 使用 `/website-assets/_next/static/`。

Website 静态资源 smoke：

```bash
WEBSITE_ASSET="$(curl -s https://zhanlan.ddup-ddup.com/ | rg -o '/website-assets/_next/static/[^"]+' | head -n 1)"
test -n "$WEBSITE_ASSET"
curl -I "https://zhanlan.ddup-ddup.com${WEBSITE_ASSET}"
```

预期：返回 200。

Admin smoke：

```bash
curl -I https://zhanlan.ddup-ddup.com/login
ADMIN_ASSET="$(curl -s https://zhanlan.ddup-ddup.com/login | rg -o '/_next/static/[^"]+' | head -n 1)"
test -n "$ADMIN_ASSET"
curl -I "https://zhanlan.ddup-ddup.com${ADMIN_ASSET}"
```

预期：

- `/login` 返回 200 或现有受控状态。
- Admin 静态资源仍从 `/_next/static/...` 返回 200。

BFF / Server smoke：

```bash
curl -I https://zhanlan.ddup-ddup.com/api/app/project/list
curl -I https://zhanlan.ddup-ddup.com/health/bff/live
curl -I https://zhanlan.ddup-ddup.com/health/server/live
```

预期：均返回 200。

证书 smoke：

```bash
echo | openssl s_client -servername zhanlan.ddup-ddup.com -connect zhanlan.ddup-ddup.com:443 2>/dev/null | openssl x509 -noout -ext subjectAltName
```

预期：输出包含 `DNS:zhanlan.ddup-ddup.com`。

## 10. 回滚方案

Stage 5B 执行前必须先创建 Nginx 备份。建议命名：

```bash
sudo cp /etc/nginx/conf.d/exhibition.conf /etc/nginx/conf.d/exhibition.conf.bak.website-stage5
```

如部署后任一 smoke 失败，按顺序回滚：

```bash
sudo cp /etc/nginx/conf.d/exhibition.conf.bak.website-stage5 /etc/nginx/conf.d/exhibition.conf
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl stop exhibition-website
sudo systemctl disable exhibition-website
```

回滚后必须重新 smoke：

```bash
curl -I https://zhanlan.ddup-ddup.com/api/app/project/list
curl -I https://zhanlan.ddup-ddup.com/health/bff/live
curl -I https://zhanlan.ddup-ddup.com/health/server/live
curl -I https://zhanlan.ddup-ddup.com/login
```

预期：

- API / health 恢复或保持 200。
- Admin `/login` 恢复或保持原状态。
- `/_next/` 仍指向 Admin。

如果 Stage 5B 不是使用 `/etc/nginx/conf.d/exhibition.conf`，必须先替换为 active config 的真实路径；路径不明确时 No-Go。

## 11. No-Go 条件

出现以下任一情况，必须停止，不得发布：

1. active Nginx 配置路径或内容与本 diff plan 不一致，且未重新出 active diff。
2. `127.0.0.1:3003` 已被占用。
3. Website 生产 HTML 仍引用 `/_next/static/`。
4. 需要修改 Admin / BFF / Server / Flutter / contracts 才能上线官网。
5. 需要修改 `infra/env/**` 或新增环境变量才能上线官网。
6. Nginx `nginx -t` 不通过。
7. Admin `/login` 或 Admin 静态资源 smoke 失败。
8. `/api/app/project/list`、`/health/bff/live`、`/health/server/live` 任一不再返回 200。
9. HTTPS 证书 SAN 不包含 `DNS:zhanlan.ddup-ddup.com`。
10. Website 页面出现支付、钱包、保证金、发票、退款、结算、完整交易闭环、AI 派单、地图找厂、直播、真实客户案例或生产全链路稳定承诺。
11. 部署需要读取或暴露密钥。
12. 没有明确回滚备份和回滚命令。

## 12. Stage 5B 最小执行顺序建议

仅在用户确认后执行：

1. 修改 `apps/website/next.config.ts`，生产使用 `/website-assets` asset prefix。
2. 重新运行 `pnpm --filter website lint`、`typecheck`、`build`。
3. 确认生产 HTML 静态资源 URL 为 `/website-assets/_next/static/...`。
4. 准备 Website release 与独立 `exhibition-website` 进程。
5. 备份 active Nginx 配置。
6. 应用 Nginx diff。
7. `nginx -t`。
8. reload Nginx。
9. 执行部署后 smoke。
10. smoke 全部通过后，才允许记录 Stage 5B 发布回执。

## 13. 本阶段未完成内容

- 未修改 `apps/website/next.config.ts`。
- 未修改 `infra/nginx/cloud.conf`。
- 未创建 Website 云端进程。
- 未 SSH。
- 未发布线上。
- 未做线上 smoke。

因此当前官网仍只能称为本地已实现、云端部署预案已冻结，不能称为已上线。
