# 官方网站 Stage 5B 最小发布回执

> 阶段：Stage 5B 最小发布。
> 日期：2026-05-08。
> 前置计划：`docs/official-website-deploy-plan.md`。
> 结论：PASS。

## 1. 总裁决

官方网站 MVP 已完成最小云端发布。

本次发布采用 Stage 5A 推荐的方案 B：

- `/`、`/privacy`、`/terms`、`/contact`、`/robots.txt`、`/sitemap.xml`、`/icon.svg` 指向 Website。
- `/website-assets/_next/` 指向 Website 静态资源。
- `/_next/` 继续保留给 Admin。
- `/api/app/project/list`、`/health/bff/live`、`/health/server/live` 保持可用。

## 2. 本轮本地变更

新增：

- `docs/official-website-stage5b-release-receipt.md`

修改：

- `apps/website/next.config.ts`

修改内容：

- Website 生产环境启用 `assetPrefix: '/website-assets'`。
- 本地开发仍保持默认静态资源路径。

未修改：

- `apps/admin/**`
- `apps/mobile/**`
- `apps/bff/**`
- `apps/server/**`
- `packages/contracts/**`
- `infra/env/**`
- 本地 `infra/nginx/**`

## 3. 云端发布动作

Release：

- `20260508031343-official-website-mvp`
- Cloud release path：`/srv/releases/website/20260508031343-official-website-mvp`
- Current pointer：`/srv/apps/website/current -> /srv/releases/website/20260508031343-official-website-mvp`

Website process：

- systemd service：`exhibition-website`
- listen：`127.0.0.1:3003`
- status：`active`

Nginx：

- Active config：`/etc/nginx/conf.d/exhibition.conf`
- Backup：`/etc/nginx/conf.d/exhibition.conf.bak.website-stage5-20260508031343`
- `nginx -t`：PASS
- reload：PASS

## 4. 构建与本地验证

| Command | Result |
| --- | --- |
| `pnpm --filter website lint` | PASS |
| `pnpm --filter website typecheck` | PASS |
| `pnpm --filter website build` | PASS |
| production HTML asset check | PASS，静态资源指向 `/website-assets/_next/static/` |

## 5. 云端 Smoke

| Check | Result |
| --- | --- |
| `GET /` | 200 |
| `GET /privacy` | 200 |
| `GET /terms` | 200 |
| `GET /contact` | 200 |
| `GET /robots.txt` | 200 |
| `GET /sitemap.xml` | 200 |
| `GET /icon.svg` | 200 |
| Website asset `/website-assets/_next/static/...` | 200 |
| Admin `/login` | 200 |
| Admin asset `/_next/static/...` | 200 |
| `GET /api/app/project/list` | 200 |
| `GET /health/bff/live` | 200 |
| `GET /health/server/live` | 200 |
| HTTPS SAN | contains `DNS:zhanlan.ddup-ddup.com` |

## 6. 文案边界 Smoke

Hard-claim check：PASS。

首页未出现：

- 生产全链路稳定
- 真实客户案例
- 保证成交
- 自动赚钱
- 全网第一
- 革命性
- 颠覆

保留能力相关词只出现在否定性边界表达中，例如“不承诺”“不把”“不展示”。

## 7. 回滚方案

如后续需要回滚本次官网发布，执行：

```bash
cp /etc/nginx/conf.d/exhibition.conf.bak.website-stage5-20260508031343 /etc/nginx/conf.d/exhibition.conf
nginx -t
systemctl reload nginx
systemctl stop exhibition-website
systemctl disable exhibition-website
```

回滚后必须重新 smoke：

```bash
curl -I https://zhanlan.ddup-ddup.com/api/app/project/list
curl -I https://zhanlan.ddup-ddup.com/health/bff/live
curl -I https://zhanlan.ddup-ddup.com/health/server/live
curl -I https://zhanlan.ddup-ddup.com/login
```

## 8. 未完成内容

- 未做浏览器人工视觉验收。
- 未做 CDN 或缓存策略优化。
- 未新增独立官网域名。
- 未把 Admin 迁到 `/admin` basePath。

## 9. 风险与边界

- 本次没有修改 Admin / BFF / Server / Flutter / contracts / env。
- 本次云端 Nginx 只新增 Website upstream、Website allowlist 页面和 `/website-assets/_next/` 静态资源前缀。
- 现有 Admin `/_next/` 保持不变。
- 后续新增官网页面时，应继续显式增加 Nginx allowlist，避免使用宽泛 `location /` 吞掉保留路径。

## 10. 是否建议关闭 Stage 5B

建议关闭 Stage 5B。

下一步如继续推进，应进入 Stage 5C：浏览器视觉验收、移动端视口检查、缓存策略和正式运维回执归档。
