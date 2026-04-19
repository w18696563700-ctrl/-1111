---
owner: Codex 总控
status: frozen
purpose: Freeze the current minimum cloud execution baseline for the active development runtime, including the verified local truth roots, tunnel, cloud workdirs, service names, and read-only status/log commands, while explicitly preserving deploy and rollback blockers.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-01
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/current_active_runtime_and_formal_host_drift_note_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/bff_runtime_execstart_repair_receipt_addendum.md
---

# 《当前云端执行基线冻结单》

## 1. Scope

- 本冻结单只适用于：
  - 当前 active development runtime 的本地真源路径
  - 当前 tunnel / URL
  - 已被证据确认的 cloud workdir
  - 已被证据确认的 service name
  - 已被证据确认的 read-only status / log 命令
- 本冻结单不适用于：
  - deploy 命令放行
  - rollback 命令放行
  - restart / release / mutation 放行
  - 结果校验结案
  - 联调发布结案

## 2. 已冻结的本地真源与入口

| 变量 | 冻结值 | 适用含义 |
|---|---|---|
| `LOCAL_REPO_ROOT` | `/Users/wangweiwei/Desktop/展览装修之家总控` | 当前本地正式仓库根 |
| `LOCAL_FRONTEND_WORKDIR` | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile` | 当前前端本地唯一实施根 |
| `DOCS_ROOT` | `/Users/wangweiwei/Desktop/展览装修之家总控/docs` | 当前正式文书真源 |
| `GATE_REGISTER` | `/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md` | 当前通用门禁真源 |
| `ACTIVE_DEV_CLOUD_HOST` | `47.108.180.198` | 当前可被引用的 active development runtime host |
| `TUNNEL_CMD` | `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198` | 当前本地联调固定入口 |
| `TUNNEL_URL` | `http://127.0.0.1:8080` | 当前本地映射访问地址 |

## 3. 已冻结的云端 read-only 执行基线

| 变量 | 冻结值 | 当前用途 |
|---|---|---|
| `BFF_CLOUD_WORKDIR` | `/srv/apps/bff/current` | `BFF` active runtime 工作目录只读核验 |
| `SERVER_CLOUD_WORKDIR` | `/srv/apps/server/current` | `Server` active runtime 工作目录只读核验 |
| `BFF_SERVICE_NAME` | `exhibition-bff` | `BFF` systemd 标识 |
| `SERVER_SERVICE_NAME` | `exhibition-server` | `Server` systemd 标识 |
| `BFF_STATUS_CMD` | `systemctl status exhibition-bff --no-pager` | `BFF` 只读状态核验 |
| `SERVER_STATUS_CMD` | `systemctl status exhibition-server --no-pager` | `Server` 只读状态核验 |
| `BFF_LOG_CMD` | `journalctl -u exhibition-bff -n 120 --no-pager` | `BFF` 只读日志核验 |
| `SERVER_LOG_CMD` | `journalctl -u exhibition-server -n 120 --no-pager` | `Server` 只读日志核验 |

## 4. 本轮补证结果

### 4.1 `SERVER_LOG_CMD` 已补齐

- 当前已通过只读 SSH 直接核验：
  - `systemctl status exhibition-server --no-pager`
  - `journalctl -u exhibition-server -n 120 --no-pager`
- 因此 `SERVER_LOG_CMD` 现在正式收口为：
  - `journalctl -u exhibition-server -n 120 --no-pager`
- 当前核验样本显示：
  - `exhibition-server.service` 处于 `active (running)`
  - `journalctl` 可稳定返回最新日志尾部
  - 日志中当前可见 `42P01` 级别数据库错误样本
  - 这属于运行态业务异常证据，不等同于执行基线失效

### 4.2 deploy / rollback 仍未形成单一正式命令

- 当前只读补证已看到：
  - `BFF current -> /srv/releases/bff/20260417040450-enterprise-stage2-card-album/apps/bff`
  - `Server current -> /srv/releases/server/20260417040450-enterprise-stage2-card-album`
  - `/srv/apps/bff/rollback` 目录存在，并保留按对象分组的回退素材
  - `/srv/builds/release-candidates/**` 下存在历史 `start-*.sh` / `stop-*.sh` 脚本与日志
- 但当前仍未形成可正式冻结的单一命令，因为：
  - 未发现与当前主链 `systemd + /srv/apps/*/current` 一致的统一 `BFF_DEPLOY_CMD`
  - 未发现与当前主链 `systemd + /srv/apps/*/current` 一致的统一 `SERVER_DEPLOY_CMD`
  - 未发现与当前主链 `systemd + /srv/apps/*/current` 一致的统一 `BFF_ROLLBACK_CMD`
  - 未发现与当前主链 `systemd + /srv/apps/*/current` 一致的统一 `SERVER_ROLLBACK_CMD`
  - 目前可见的 rollback 素材更像对象级回退备份，而不是当前主链唯一 rollback shell
  - 目前可见的 release-candidate 启停脚本属于历史候选物，不足以直接升格为当前 formal command

## 5. 当前未冻结且继续阻断的变量

下列变量当前不得猜测，不得口头补齐，不得在未补证前直接进入执行：

| 变量 | 当前状态 | 阻断含义 |
|---|---|---|
| `BFF_DEPLOY_CMD` | 未冻结 | `BFF` deploy 不得启动 |
| `SERVER_DEPLOY_CMD` | 未冻结 | `Server` deploy 不得启动 |
| `BFF_ROLLBACK_CMD` | 未冻结 | `BFF` rollback 不得启动 |
| `SERVER_ROLLBACK_CMD` | 未冻结 | `Server` rollback 不得启动 |

## 6. 当前允许动作

- 当前允许：
  - 本地 `docs/**` 文书冻结
  - 对已冻结变量做只读核验
  - 在不猜测 deploy / rollback 的前提下继续补证
- 当前不允许：
  - 使用本冻结单发起 deploy
  - 使用本冻结单发起 rollback
  - 使用未冻结命令发起 restart / release
  - 把 read-only baseline 误写成执行放行单

## 7. 当前基线对下一轮 Go / No-Go 的含义

- 这份冻结单成立后：
  - host / tunnel / current workdir / service name / status command / 日志命令
    已有正式单一口径
- 但由于 deploy / rollback 仍未冻结：
  - 当前仍然 `No-Go for cloud implementation mutation`
  - 当前仍然 `No-Go for integration release`
  - 当前只允许进入新的只读补证轮或新的门禁重判轮

## 8. anti-revert 规则

- 后续线程不得再：
  - 重新发明新的 tunnel 命令
  - 重新发明新的 active host
  - 将 `/srv/workspaces/**` 写成正式 active runtime workdir
  - 把未冻结 deploy / rollback 命令伪装成既有正式基线

## 9. Formal Conclusion

- 当前云端执行基线已经完成最小冻结，但只冻结到了 read-only 层。
- 当前 read-only 基线已覆盖：
  - `BFF / Server workdir`
  - `BFF / Server service name`
  - `BFF / Server status cmd`
  - `BFF / Server log cmd`
- 但在 deploy、rollback 尚未形成正式证据前：
  - 本项目不得把当前轮误判为实施放行轮
  - 只能继续作为 `文书轮 / 补证轮 / 门禁前置`
