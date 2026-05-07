# 展览装修之家官网

第一版官网 MVP，独立于 Admin、Flutter App、BFF 和 Server。

## 本地开发

```bash
pnpm --filter website dev
```

指定端口：

```bash
pnpm --filter website exec next dev -p 3200
```

## 验证

```bash
pnpm --filter website lint
pnpm --filter website typecheck
pnpm --filter website build
```

## 边界

- 不接入登录。
- 不接入支付。
- 不读取生产项目列表作为首页动态依赖。
- 不修改 Admin / Flutter / BFF / Server / contracts / Nginx / env。
