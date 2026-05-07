---
title: stale_notification_invalid_entry_governance_v1
status: frozen
date: 2026-05-07
scope: SSOT
---

# 失效提醒检测与软清理治理 V1

## 0. 总裁决

消息中心 / 铃铛里的“入口已失效”提醒不得继续长期占用默认消息列表和 unread。治理原则是：不硬删除业务记录，由 Server 标记失效、已清理或不可达；BFF 只透出投影；Flutter 只展示、折叠和发起清理动作。

本文件只冻结治理口径和后续施工边界，不解锁代码施工、OpenAPI 变更、migration、批量清理任务或云端数据清理。

## 1. 当前最小闭环

| 能力 | 最小闭环裁决 |
|---|---|
| 失效检测 | Server 根据 `sourceType / sourceId / routeTarget` 判断主体是否仍可打开 |
| unread 处理 | 失效提醒不应继续计入默认 unread |
| 清理动作 | 用户点击“清理失效提醒”后应 Server-side mark dismissed / invalid_target_acknowledged |
| 默认列表 | 默认隐藏或折叠失效提醒，保留审计入口 |
| fallback | 无法打开时提供“从主体列表进入”的安全提示 |

## 2. 真值归属

| 项 | Owner | 说明 |
|---|---|---|
| notification truth | Server | 通知记录、read、dismiss、invalid target state |
| routeTarget availability | Server | 主体是否仍存在、actor 是否仍有权限、入口是否过期 |
| unread projection | Server read model | 不由 Flutter 本地扣减 |
| app-facing shape | BFF | 只透出 `available / expired / dismissed / fallback` |
| 展示与交互 | Flutter | 展示失效状态、清理按钮、折叠历史 |

## 3. No-Go

1. 不硬删除通知业务记录。
2. 不让 Flutter 本地把失效提醒从 unread 中扣掉。
3. 不让 BFF 创造失效状态。
4. 不在消息楼里修复支付、合同、钱包、发票、保证金真值。
5. 不把失效提醒批量治理混入本轮 gate 后移施工。

## 4. 后续施工切片

| 阶段 | 内容 | 是否需 OpenAPI | 是否需 DB |
|---|---|---:|---:|
| L1 裁决 | 明确失效状态字段、清理动作、默认列表策略 | 待裁 | 待裁 |
| Server | 增加 routeTarget availability 检测、dismiss/invalid 状态 | 可能 | 可能 |
| BFF | 透出 availability 和 fallback，不制造状态 | 可能 | 否 |
| Flutter | 默认折叠失效提醒，清理动作走 Server | 可能 | 否 |
| UAT | 检查 unread 不再被失效提醒占用 | 否 | 否 |

## 5. 当前阶段结论

当前只允许作为后续“消息通知治理专项”进入单独冻结和施工评审，不进入本轮项目沟通 / 预授权 gate 后移 P0 施工。
