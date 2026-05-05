---
owner: Codex 总控
status: frozen
purpose: Freeze the L0 truth for stale notification routeTarget availability and fallback handling.
layer: L0 SSOT
---

# Stale Notification RouteTarget Availability V1 Truth Freeze Addendum

## 1. 总裁决

本 addendum 是 `消息提示与引导体系 V1` 的小门禁补冻，只解决 stale notification / routeTarget availability 质量问题。

当前冻结：

- 铃铛通知可以保留历史未读，但不能把失效 routeTarget 直接带进技术错误页。
- 通知 `routeTarget` 可用性由 Server 判断并返回，BFF 只透传，Flutter 只消费展示和 fallback 导航。
- 不可用通知不得因为点击失败而被自动 mark-read。
- 项目沟通历史通知的目标失效时，优先回退到主体项目列表，让用户重新进入当前可用项目沟通链路。

本门禁不改变业务状态机，不新增泛通知平台，不触碰支付、服务费、钱包、结算、发票、履约、验收、评价、争议，也不改上游项目创建到发布主链路。

## 2. 问题边界

已观察到的故障形态：

1. 铃铛中存在历史项目沟通通知。
2. 点击后进入 `counterpart-conversation/detail`。
3. 当前对方沟通容器已不可用，页面显示技术态：`COUNTERPART_CONVERSATION_UNAVAILABLE`。
4. 旧逻辑存在点击失败后仍可能清除未读的风险。

该问题属于消息系统质量问题，不属于项目沟通 UI 视觉问题。

## 3. routeTargetAvailability 真值

`routeTargetAvailability` 是 Server-owned read model，不是 Flutter 本地推断。

V1 状态如下：

| state | 含义 | 允许行为 |
| --- | --- | --- |
| `available` | 目标 routeTarget 当前可承接 | Flutter 可尝试进入目标页；成功定位后才允许 mark-read |
| `unavailable` | 目标容器当前不可用，但可能仍有回退入口 | Flutter 显示中文原因，可进入 fallback，不自动 mark-read |
| `expired` | 目标已过期或目标对象不存在 | Flutter 显示中文原因，可进入 fallback，不自动 mark-read |
| `forbidden` | 当前账号 / 组织无权访问目标 | Flutter 显示中文原因，不自动 mark-read |
| `missing_context` | routeTarget 缺少必要参数 | Flutter 显示中文原因，不自动 mark-read |

Server 必须同时返回：

- `reasonCode`
- `reasonText`
- `fallbackAction`
- `fallbackRouteTarget`

## 4. fallback 规则

V1 只冻结一个最小 fallback：

| 通知类型 | 失效目标 | fallback |
| --- | --- | --- |
| 项目沟通通知 | 具体项目聊天框不可用 | 打开同一主体下的项目列表 |

fallback 是引导能力，不是业务处理成功。

因此：

- fallback 成功打开主体项目列表，不代表该通知已处理。
- fallback 成功打开主体项目列表，默认不自动 mark-read。
- 若后续需要“用户手动忽略 / 标记已读”，必须另行冻结。

## 5. 未读清除规则

通知 mark-read 必须满足：

1. 通知仍存在且属于当前 actor / organization。
2. `routeTargetAvailability.state = available`。
3. Flutter 成功进入目标承接页。
4. mark-read 请求只清通知中心 unread，不替代业务待办、项目沟通 read cursor 或论坛互动 read cursor。

以下场景禁止自动 mark-read：

- `routeTargetAvailability.state != available`
- routeTarget 缺少 `conversationId / projectId / threadId` 等必要上下文
- Flutter 路由构造失败
- 目标页返回 `COUNTERPART_CONVERSATION_UNAVAILABLE`
- fallback 只打开主体项目列表，尚未真正定位到原通知对应聊天目标

## 6. Layer Responsibilities

| Layer | Responsibility | Forbidden |
| --- | --- | --- |
| Server | 计算 routeTarget 可用性、原因、fallback routeTarget、mark-read 真值 | 删除历史通知、list 即已读、把不可用通知伪装成可用 |
| BFF | 透传 `routeTargetAvailability`，校验结构 | 本地计算可用性、吞掉未知状态、自动清未读 |
| Flutter | 展示可用性、中文兜底、fallback 导航、成功定位后请求 mark-read | 进入技术错误页、点击失败清未读、本地推断业务处理完成 |

## 7. App Copy

不可用项目沟通通知的 V1 文案：

`入口已失效，可从主体项目列表重新进入`

完全缺少上下文时：

`当前通知暂时无法定位，请稍后重试或从对应入口进入。`

不得暴露：

- `COUNTERPART_CONVERSATION_UNAVAILABLE`
- `route params must contain non-empty strings`
- `routeTarget` 解析异常

## 8. Non-Goals

本门禁不做：

- 推送渠道治理
- 通知偏好中心
- 历史通知批量清理
- 自动迁移旧通知 routeTarget
- 用户手动忽略通知
- 论坛互动 read cursor 合并
- 业务待办完成态改造
- 支付、服务费、钱包、结算、发票
- 履约、验收、评价、争议
