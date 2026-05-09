# 项目沟通 Shell 未读可见投影同源云端部署回执 Addendum

状态：执行回执

## 1. 总裁决

本轮已将 Server unread 投影同源补丁部署到阿里云 active development runtime，并完成只读 runtime 复测与 Computer Use 验证。

云上 `GET /api/app/shell/context` 的 `unreadSummary.messages` 已与 `GET /api/app/message/interactions?lane=project_communication` 的可见 `items[].conversationUnreadCount` 合计对齐。

## 2. 部署范围

本轮只部署 Server：

1. `apps/server/src/modules/shell/shell-query.service.ts`
2. `apps/server/src/modules/shell/shell.module.ts`
3. `apps/server/src/modules/message_interaction/message-interaction.module.ts`
4. `apps/server/test/shell-unread-projection.test.cjs`

本轮不部署 BFF，不改 Flutter，不改 Nginx，不改数据库，不执行迁移。

## 3. Release 指针

| 项 | 值 |
| --- | --- |
| previous rollback target | `/srv/releases/server/20260503040500-d97a3f2-main-phase-a3-server-native-fix` |
| new active release | `/srv/releases/server/20260504061752-shell-unread-visible-projection` |
| current pointer | `/srv/apps/server/current` |
| restart target | `exhibition-server` |
| runtime command | `node dist/main.js` |

## 4. 构建与测试证据

本地 Server：

1. `npm run build`：PASS。
2. `node --test test/shell-unread-projection.test.cjs test/message-interaction-bid-carry.test.cjs test/project-publish-eligibility.test.cjs`：37 PASS。

云上新 release：

1. 以当前 active Server release 为基底复制新 release。
2. 只覆盖本轮 Server 源码、测试和对应 local-built runtime dist。
3. `node --test test/shell-unread-projection.test.cjs test/message-interaction-bid-carry.test.cjs test/project-publish-eligibility.test.cjs`：37 PASS。

云上 source build 记录：

1. `npm run build` 在云上新 release 内被既有 dev/type 环境阻断。
2. 阻断点为既有 `express` type/module resolution 与 `base64url` BufferEncoding 编译能力，不是本轮 unread 投影逻辑。
3. 本轮没有执行 `npm install`，没有扩大云端依赖变更。

## 5. Runtime 证据

1. `systemctl is-active exhibition-server`：`active`。
2. `GET /health/server/live`：`200`。
3. `GET /health/bff/live`：`200`。
4. 指定登录态只读对比：
   - `POST /api/app/auth/password/login`：`200`。
   - `GET /api/app/shell/context`：`200`，`unreadSummary.messages = 0`。
   - `GET /api/app/message/interactions?lane=project_communication`：`200`，`items.length = 1`，`conversationUnreadCount sum = 0`。
   - 结论：`shell/context.unreadSummary.messages == message/interactions.items[].conversationUnreadCount sum`。

## 6. Computer Use 验证

重启本地 Flutter macOS App 后，通过真实云上 BFF / Server 登录并验证：

1. 进入互动中心后，底部 `消息` 无红色未读角标。
2. 返回 `展览` 首页后，底部 `消息` 入口仍无红色未读角标。

## 7. 当前最小闭环

Server shell unread 与互动中心可见项目沟通投影同源，BFF 只透传，Flutter 只展示 Server 给出的 unread。

## 8. 需要保留但暂不开通

1. 不新增消息来源。
2. 不扩通用消息中心。
3. 不改 read cursor 写入。
4. 不把论坛互动并入项目沟通 unread。
5. 不在 Flutter 启动阶段建立第二套 unread 推断。

## 9. 后续扩展位

后续如果 shell badge 要统计更多来源，先扩展 `message/interactions` 可见承接项，再让 shell 读取该同源投影，不允许 shell 单独统计不可见线程。

## 10. 风险与回滚

更稳：当前已部署 Server 同源投影，用户不会再看到点进去找不到的项目沟通未读。

更省成本：Flutter 本地清角标成本更低，但不能解决冷启动 shell unread 真相。

更适合当前阶段：只改 Server 读投影，不改合同、不改 BFF、不改 Flutter。

风险更大：继续让 shell 单独统计 raw unread，会再次出现 `shell=2`、`interactions=0` 的不可解释角标。

如需回滚，使用本轮 recorded previous target：

1. `ln -sfn /srv/releases/server/20260503040500-d97a3f2-main-phase-a3-server-native-fix /srv/apps/server/current`
2. `systemctl restart exhibition-server`
3. 重跑 health 与同登录态只读对比。
