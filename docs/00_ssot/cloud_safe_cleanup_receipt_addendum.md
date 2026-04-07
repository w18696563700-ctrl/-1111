# 云端安全清理回执补充文书

## 1. 当前对象
- 执行角色：联调发布 Agent
- 执行日期：2026-04-02
- 目标主机：`47.108.180.198`
- 清理范围：仅限 `/srv/workspaces/exhibition-infra-monorepo` 工作区内可再生垃圾与条件满足后的工作区 `node_modules`
- 禁止动作：未做代码修改、未做数据库变更、未做 release 切换、未碰 active runtime、未碰 `current` 指向目录

## 2. 清理前盘点结果

### 2.1 current 与 active runtime
- `readlink -f /srv/apps/server/current`
  - `/srv/releases/server/20260401023418`
- `readlink -f /srv/apps/bff/current`
  - `/srv/releases/bff/20260331195903/apps/bff`
- `systemctl status exhibition-server --no-pager`
  - 结论：`active (running)`
  - `Main PID`: `518368`
  - 进程工作目录核验：`/proc/518368/cwd -> /srv/releases/server/20260401023418`
- `systemctl status exhibition-bff --no-pager`
  - 结论：`active (running)`
  - `Main PID`: `518369`
  - 进程工作目录核验：`/proc/518369/cwd -> /srv/releases/bff/20260331195903/apps/bff`
- `systemctl show exhibition-server -p WorkingDirectory -p ExecStart`
  - `WorkingDirectory=/srv/apps/server/current`
  - `ExecStart=/usr/bin/node dist/main.js`
- `systemctl show exhibition-bff -p WorkingDirectory -p ExecStart`
  - `WorkingDirectory=/srv/apps/bff/current`
  - `ExecStart=/usr/bin/node dist/main.js`
- `systemctl show ... -p Environment`
  - `exhibition-server`: `Environment=`
  - `exhibition-bff`: `Environment=`
  - 结论：未见将工作区路径注入运行态的环境变量

### 2.2 工作区体积
- `du -sh /srv/workspaces/exhibition-infra-monorepo/apps/bff`
  - 清理前：`3.0M`
- `du -sh /srv/workspaces/exhibition-infra-monorepo/apps/server`
  - 清理前：`266M`

### 2.3 清理候选盘点
- `find /srv/workspaces/exhibition-infra-monorepo -maxdepth 4 ...`
  - `/srv/workspaces/exhibition-infra-monorepo/.tmp`
  - `/srv/workspaces/exhibition-infra-monorepo/apps/bff/dist`
  - `/srv/workspaces/exhibition-infra-monorepo/apps/server/dist`

### 2.4 条件性对象盘点
- `du -sh /srv/workspaces/exhibition-infra-monorepo/apps/bff/node_modules`
  - `204K`
- `du -sh /srv/workspaces/exhibition-infra-monorepo/apps/server/node_modules`
  - `261M`
- 可再安装依据
  - `apps/bff`: 存在 `package.json` 与 `package-lock.json`
  - `apps/server`: 存在 `package.json`

## 3. 明确删除的路径清单

### 3.1 优先级 A
- `/srv/workspaces/exhibition-infra-monorepo/.tmp`
  - 删前大小：`76K`
- `/srv/workspaces/exhibition-infra-monorepo/apps/bff/dist`
  - 删前大小：`2.0M`
- `/srv/workspaces/exhibition-infra-monorepo/apps/server/dist`
  - 删前大小：`3.5M`

### 3.2 优先级 B
- 判定条件
  - `WorkingDirectory` 均指向 `/srv/apps/*/current`，不指向工作区 `node_modules`
  - active runtime 的 `cwd` 均解析到 `/srv/releases/...`
  - 优先级 A 已先完成
  - 两处 `node_modules` 均属工作区可再生依赖树
- 删除路径
  - `/srv/workspaces/exhibition-infra-monorepo/apps/bff/node_modules`
    - 删前大小：`204K`
    - 影响说明：仅影响工作区本地依赖缓存，运行中 BFF 不依赖该目录
    - 可再安装性：可基于 `apps/bff/package.json` 与 `apps/bff/package-lock.json` 重装
  - `/srv/workspaces/exhibition-infra-monorepo/apps/server/node_modules`
    - 删前大小：`261M`
    - 影响说明：仅影响工作区本地依赖缓存，运行中 Server 不依赖该目录
    - 可再安装性：可基于 `apps/server/package.json` 重装

## 4. 被判定为禁止删除的路径
- `/srv/apps/server/current`
- `/srv/apps/bff/current`
- `/srv/releases/server/20260401023418`
- `/srv/releases/bff/20260331195903/apps/bff`
- `/srv/releases/**` 下所有被 `current` 指向的 active release
- `/srv/workspaces/exhibition-infra-monorepo/docs/**`
- `/srv/workspaces/exhibition-infra-monorepo/apps/**/src/**`
- 任意 `.env`、配置文件、迁移文件、正式回执文书
- PostgreSQL / Redis / MinIO 数据目录
- Nginx 配置与 systemd 单元文件

## 5. 清理前后体积对比

### 5.1 优先级 A 后
- `apps/bff`: `3.0M -> 1.1M`
- `apps/server`: `266M -> 263M`
- `find ...` 复盘结果：无剩余优先级 A 命中项

### 5.2 最终结果
- `apps/bff`: `3.0M -> 852K`
- `apps/server`: `266M -> 1.4M`
- 估算回收体积
  - 优先级 A：约 `5.6M`
  - 优先级 B：约 `261.2M`
  - 合计：约 `266.8M`

## 6. 服务健康检查结果
- 云端 `curl -sS http://127.0.0.1:80/health/bff/live`
  - `{"status":"ok","service":"exhibition-bff","port":3000,...}`
- 云端 `curl -sS http://127.0.0.1:80/health/server/live`
  - `{"status":"ok","service":"exhibition-server","port":3001,...}`
- `systemctl is-active exhibition-bff`
  - `active`
- `systemctl is-active exhibition-server`
  - `active`

## 7. tunnel 验证结果
- 本地 `8080` 已存在同目标主机的匹配隧道
  - 进程：`ssh -fN -L 8080:127.0.0.1:80 root@47.108.180.198`
- 使用该隧道验证：
  - `curl -sS http://127.0.0.1:8080/health/bff/live`
    - `{"status":"ok","service":"exhibition-bff","port":3000,...}`
  - `curl -sS http://127.0.0.1:8080/health/server/live`
    - `{"status":"ok","service":"exhibition-server","port":3001,...}`

## 8. 是否影响当前联调 / 发布链路
- 结论：未观察到影响
- 依据：云端健康检查通过，systemd 状态保持 `active`，本地隧道回环健康检查通过

## 9. 剩余未清理大项
- 允许清理范围内未发现剩余大项
- 若继续追求更大空间，潜在大头只可能位于 `/srv/apps/*/current` 或其解析到的 `/srv/releases/...` active release 树内
- 上述路径属于明确禁止删除对象，本次未触碰

## 10. 最终硬结论
`safe cleanup completed without runtime damage`
