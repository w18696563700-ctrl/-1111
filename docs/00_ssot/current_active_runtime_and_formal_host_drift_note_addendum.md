---
owner: Codex 总控
status: frozen
purpose: Resolve the current documentation drift between the old formal-host unlock order and the currently used active development runtime evidence, without silently authorizing cloud write or release actions.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-01
inputs_canonical:
  - docs/00_ssot/formal_cloud_host_unlock_order_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/bff_runtime_execstart_repair_receipt_addendum.md
---

# 《当前 active runtime 与 formal host 口径漂移说明》

## 1. 漂移对象

- 旧文书仍冻结：
  - `47.108.140.84` 为 formal host
  - `ssh -N -L 28790:127.0.0.1:8443 root@47.108.140.84` 为 formal local verification tunnel
- 但后续 active evidence 与用户确认文书已连续使用：
  - `47.108.180.198`
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
  - `http://127.0.0.1:8080`
- 若两组口径继续同时被引用为“当前真相”，就会直接破坏：
  - 真源门禁
  - 云上运行门禁
  - 阶段控制门禁

## 2. 为什么旧口径不能继续直接沿用

- `formal_cloud_host_unlock_order_addendum.md` 的对象是：
  - 旧 formal host block 的解锁顺序
  - witness host 不得静默替代 formal host 的限制
- 当前实际问题已经变成：
  - 后续线程多次把 `47.108.180.198` 当作当前 active development runtime
  - 本地联调隧道、云端 current 目录、`systemd` 服务名、health 探测也都围绕 `47.108.180.198` 形成连续证据
- 因此旧文书的“blocked formal-host unlock order”不能再单独承担“当前 active runtime baseline”的职责。

## 3. 本轮正式裁决

- 对当前 development-stage active runtime 的解释，正式收口为：
  - `47.108.180.198` 是当前可被引用的 active development runtime host
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198` 是当前可被引用的本地联调隧道
  - `http://127.0.0.1:8080` 是当前可被引用的本地验证入口
- `47.108.140.84` 在当前轮中的正式含义只保留为：
  - 历史 formal-host unlock 文书中的旧 blocked-host 口径
  - 不再作为当前 active runtime baseline 被引用

## 4. 与旧 formal-host 文书的关系

- 从本轮开始：
  - `formal_cloud_host_unlock_order_addendum.md` 继续保留历史来源与背景意义
  - 但凡涉及“当前 active development runtime / 当前 tunnel / 当前本地联调入口”的判断：
    - 一律以本说明和本轮执行基线冻结单为准
- 这条裁决：
  - 只解决当前 active runtime 的文书漂移
  - 不永久定义最终 release host
  - 不自动放行云端写操作

## 5. 非目标与未放行项

- 本说明不意味着：
  - `47.108.180.198` 已自动成为永久 formal release host
  - deploy / rollback 已获得正式授权
  - restart / release / rollback 可直接执行
  - 结果校验与联调发布可直接启动

## 6. anti-revert 规则

- 后续线程不得再把：
  - `47.108.140.84`
  - `28790 -> 8443`
  作为当前 active development runtime baseline 引用
- 后续线程若仍需引用旧文书，必须显式写明：
  - 那是历史 blocked formal-host 口径
  - 不是当前 active runtime truth

## 7. Formal Conclusion

- 当前 formal host / active runtime 双口径漂移已被正式记录。
- 从现在开始：
  - 当前 active development runtime 只认 `47.108.180.198`
  - 当前本地联调入口只认 `8080 -> 80`
  - 但云端写操作、deploy、rollback、release 仍需等待单独的执行基线放行
