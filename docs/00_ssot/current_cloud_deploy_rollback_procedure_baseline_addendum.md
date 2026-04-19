---
owner: Codex 总控
status: frozen
purpose: Freeze the current cloud deploy and rollback procedure baseline for the active development runtime, correcting the earlier single-command expectation into a verified procedure bundle aligned with the current systemd plus current-symlink mainline.
layer: L0 SSOT
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/current_cloud_execution_baseline_freeze_addendum.md
  - docs/00_ssot/release_environment_rollback_baseline_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_revalidation_receipt.md
  - docs/00_ssot/project_attachment_bff_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/trading_im_round_a_stage_gate_checklist_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
---

# 《当前云端 deploy / rollback procedure 基线冻结单》

## 1. Scope

- 本冻结单只适用于当前 active development runtime：
  - `47.108.180.198`
  - `systemd + /srv/apps/*/current + /srv/releases/**`
- 本冻结单不 author：
  - CI/CD
  - Git push policy
  - release artifact 制备细节
  - integration release sign-off

## 2. Correction Rule

- 先前 blocker 的核心问题是：
  - 当前主链没有可直接引用的单一 `deploy.sh` / `rollback.sh`
- 本轮 read-only 补证还进一步确认：
  - 当前主链没有显式 `/srv/apps/*/previous` 指针
  - 当前主链也没有专用的 `deploy` / `rollback` shell 入口
- 本轮补证确认：
  - 当前主链虽然没有单一 shell，但已经有足够证据支持一条正式的 `procedure baseline`
  - 因此本轮正式修正为：
    - `deploy / rollback` 以 procedure bundle 冻结
    - 不再错误要求当前主链必须先存在单一脚本文件，才能进入 cloud implementation gate

## 3. Frozen Runtime Anchors

| 变量 | 冻结值 | 含义 |
|---|---|---|
| `BFF_RELEASE_ROOT` | `/srv/releases/bff` | BFF 正式 release 根 |
| `SERVER_RELEASE_ROOT` | `/srv/releases/server` | Server 正式 release 根 |
| `BFF_CURRENT_POINTER` | `/srv/apps/bff/current` | BFF active symlink |
| `SERVER_CURRENT_POINTER` | `/srv/apps/server/current` | Server active symlink |
| `BFF_RESTART_CMD` | `systemctl restart exhibition-bff` | BFF 正式 restart 锚点 |
| `SERVER_RESTART_CMD` | `systemctl restart exhibition-server` | Server 正式 restart 锚点 |
| `BFF_ACTIVE_CHECK_CMD` | `systemctl is-active exhibition-bff` | BFF active 状态核验 |
| `SERVER_ACTIVE_CHECK_CMD` | `systemctl is-active exhibition-server` | Server active 状态核验 |

## 4. Canonical Deploy Procedure

### 4.1 Server

- `SERVER_DEPLOY_PROCEDURE` 正式冻结为：
  1. 在 `SERVER_RELEASE_ROOT` 下制备新的唯一 release artifact
  2. 在新 release 目录内完成云端 build / 产物核验
  3. 记录切换前 `readlink -f SERVER_CURRENT_POINTER` 的结果，作为本轮 rollback target
  4. 将 `SERVER_CURRENT_POINTER` 切到新的 release artifact
  5. 执行 `SERVER_RESTART_CMD`
  6. 使用 `SERVER_ACTIVE_CHECK_CMD` 与当前 read-only status / log 基线完成运行态核验

### 4.2 BFF

- `BFF_DEPLOY_PROCEDURE` 正式冻结为：
  1. 在 `BFF_RELEASE_ROOT` 下制备新的唯一 release artifact
  2. 在新 release 目录内完成云端 build / 产物核验
  3. 记录切换前 `readlink -f BFF_CURRENT_POINTER` 的结果，作为本轮 rollback target
  4. 将 `BFF_CURRENT_POINTER` 切到新的 release artifact
  5. 执行 `BFF_RESTART_CMD`
  6. 使用 `BFF_ACTIVE_CHECK_CMD` 与当前 read-only status / log 基线完成运行态核验

## 5. Canonical Rollback Procedure

### 5.1 Server

- `SERVER_ROLLBACK_PROCEDURE` 正式冻结为：
  1. 使用本轮 deploy 前已记录的 `previous SERVER_CURRENT_POINTER target`
  2. 将 `SERVER_CURRENT_POINTER` 恢复到该 recorded previous release
  3. 执行 `SERVER_RESTART_CMD`
  4. 用 `SERVER_ACTIVE_CHECK_CMD` 与 read-only status / log 基线重新核验

### 5.2 BFF

- `BFF_ROLLBACK_PROCEDURE` 正式冻结为：
  1. 使用本轮 deploy 前已记录的 `previous BFF_CURRENT_POINTER target`
  2. 将 `BFF_CURRENT_POINTER` 恢复到该 recorded previous release
  3. 执行 `BFF_RESTART_CMD`
  4. 用 `BFF_ACTIVE_CHECK_CMD` 与 read-only status / log 基线重新核验

## 5.3 Mandatory Recording Rule

- 当前主链没有显式 `previous` symlink。
- 因此 rollback target 不得靠事后猜测目录时间或最近 release 名称恢复。
- 每一轮真正 author 的 deploy 若要保留 rollback 能力，必须在切换 `current` 前先记录：
  - `readlink -f SERVER_CURRENT_POINTER`
  - `readlink -f BFF_CURRENT_POINTER`
- 未先记录 previous target 的轮次，不得声称已经具备正式 rollback 准备。

## 6. Evidence Chain

- rollback baseline 文书已冻结：
  - active runtime 以 release artifact 选择，不以 source workspace 切换
  - rollback 认最小 runtime release unit
- 实际 Server release receipt 已记录：
  - 新 release 目录
  - `current` 切换
  - `systemctl restart exhibition-server`
- 实际 BFF runtime alignment / repair receipt 已记录：
  - `current` 指向 release artifact
  - `systemctl restart exhibition-bff`
- cloud read-only 补证已确认：
  - 当前 `current` 指针
  - 最近 release 目录序列
  - 当前 systemd `WorkingDirectory=/srv/apps/*/current`
  - 当前没有显式 `previous` 指针
  - 当前没有主链专用 `deploy` / `rollback` shell
  - `exhibition-bff` 的实际 `ExecStart` 依赖 systemd drop-in override，而不是基础 unit 原值

## 7. Non-goals

- 本冻结单不 author：
  - 单一 shell 脚本文件必须存在
  - release artifact 如何从 git workspace 制备
  - 如何 push / PR / merge
  - release sign-off

## 8. Formal Conclusion

- 当前主链 `deploy / rollback` 已完成 formal freeze，但形式是：
  - `procedure baseline`
  - 不是 `single shell script baseline`
- 当前正式 author 的 deploy / rollback 语义是：
  - `release artifact preparation`
  - `record previous current target`
  - `switch current`
  - `restart service`
  - `verify active/log`
- 自本冻结单起：
  - cloud implementation gate 不再因为“缺少单一 shell 文件”而被 blanket 阻断
  - 但 integration release 与最终 sign-off 仍需独立校验，不因本冻结单自动放行
