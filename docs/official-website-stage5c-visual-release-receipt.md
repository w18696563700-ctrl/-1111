# 官方网站 Stage 5C 视觉版最小发布回执

## 1. 总裁决

PASS。

本轮已将官方网站 V2.1 视觉升级版发布到当前域名根路径，并保持 Stage 5 的 Nginx 静态资源隔离方案不变。

## 2. 发布范围

- 仅发布 `apps/website`。
- 未修改云端 Nginx 配置。
- 未修改 env。
- 未修改 BFF、Server、Admin、Flutter、contracts。
- 未执行数据库操作。
- 未变更支付配置。

## 3. Release 信息

- 上一版 release：`/srv/releases/website/20260508031343-official-website-mvp`
- 本轮 release：`/srv/releases/website/20260508043854-official-website-v21`
- 当前 symlink：`/srv/apps/website/current -> /srv/releases/website/20260508043854-official-website-v21`
- Website 服务：`exhibition-website`
- 监听地址：`127.0.0.1:3003`
- Nginx reload：未执行
- Website service restart：已执行

## 4. 本轮执行动作

1. 只读确认云端当前 release、systemd 单元、进程 cwd。
2. 新建 release 目录。
3. 从上一版 release 复制基线。
4. 上传本地已构建的 `apps/website` V2.1 产物。
5. 在新 release 内确认 `.next` 构建产物存在。
6. 确认生产 HTML 使用 `/website-assets/_next/static/`。
7. 执行 `nginx -t`，结果通过。
8. 切换 `/srv/apps/website/current` 到新 release。
9. 重启 `exhibition-website`。
10. 执行线上 smoke。

## 5. Smoke 结果

| 检查项 | 结果 |
| --- | --- |
| `/` | 200 |
| `/privacy` | 200 |
| `/terms` | 200 |
| `/contact` | 200 |
| `/robots.txt` | 200 |
| `/sitemap.xml` | 200 |
| `/icon.svg` | 200 |
| `/api/app/project/list` | 200 |
| `/health/bff/live` | 200 |
| `/health/server/live` | 200 |
| `/login` | 200 |
| Website 静态资源 `/website-assets/_next/static/css/9d33355cc2db50c3.css` | 200 |
| Admin 静态资源 `/_next/static/css/be7e4c9a18ae0fd3.css` | 200 |
| HTTPS SAN | `DNS:zhanlan.ddup-ddup.com` |

## 6. 路由隔离确认

- `/` 由 Website 提供。
- `/website-assets/_next/` 由 Website 静态资源提供。
- `/_next/` 仍保留给 Admin 静态资源。
- `/login` 仍返回 Admin 页面。
- `/api/app/project/list` 仍返回 200。
- `/health/bff/live` 仍返回 200。
- `/health/server/live` 仍返回 200。

## 7. 回滚命令

如需回滚到上一版官网 release：

```bash
ln -sfn /srv/releases/website/20260508031343-official-website-mvp /srv/apps/website/current
systemctl restart exhibition-website
systemctl is-active exhibition-website
```

回滚后建议重新 smoke：

```bash
curl -I https://zhanlan.ddup-ddup.com/
curl -I https://zhanlan.ddup-ddup.com/api/app/project/list
curl -I https://zhanlan.ddup-ddup.com/health/bff/live
curl -I https://zhanlan.ddup-ddup.com/health/server/live
curl -I https://zhanlan.ddup-ddup.com/login
```

## 8. 已知风险

- 本轮仅完成官网 V2.1 前端发布，不代表 BFF / Server 有新增产品能力。
- 官网中的 App 首页视觉仍为 CSS 高保真样机，不是真实 App 截图；后续可替换为授权截图。
- 未执行 Nginx reload，因为本轮未修改 Nginx 配置。
- 未执行 Admin 深度登录流程，只验证 `/login` 与 Admin 静态资源未被覆盖。

## 9. 是否建议保留当前版本

建议保留当前版本。

理由：

- Website 根路径已 200。
- Website 静态资源隔离有效。
- Admin `/_next/` 未被覆盖。
- BFF / Server health 与 App API smoke 均保持 200。
- 证书 SAN 未变。
