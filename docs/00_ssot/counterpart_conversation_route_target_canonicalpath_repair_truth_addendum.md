---
owner: Codex 总控
status: effective
purpose: Freeze the repair truth for counterpart conversation detailRouteTarget canonicalPath mismatch.
layer: L0 SSOT
---

# Counterpart Conversation RouteTarget CanonicalPath Repair Truth Addendum

## 结论

本轮修复真相是：项目沟通页右侧账号出现 `detail routeTarget canonicalPath mismatch`，不是聊天线程、项目分组、权限或 Server 业务状态错误，而是 BFF 输出的 `bid_service_fee_authorization.open` 入口 `canonicalPath` 使用了实例路径，和 Flutter 注册入口表的冻结模板路径不一致。

正式冻结为：

```text
actionKey: bid_service_fee_authorization.open
objectType: bid_service_fee_authorization
canonicalPath: /api/app/project/{projectId}/bid-service-fee-authorizations
params.projectId: <actual projectId>
```

`canonicalPath` 必须保持模板路径；真实 `projectId` 只能放在 `params` 中。

## 当前最小闭环

- 只修 BFF projection / read-model，不改 Server 状态机、不改数据库、不迁移。
- `bid_service_fee_authorization.open` 在以下 BFF 投影中统一输出模板路径：
  - `counterpart-conversation.detail` business card projection
  - `bid-participation-request` pricing gate projection
- Flutter parser / registered entry registry 继续严格校验 canonicalPath，不为本次问题放宽。
- 双账号项目沟通仍保持：
  - 一级：对方主体总框。
  - 总框内：只列项目入口。
  - 项目入口内：项目级业务按钮 + 项目级聊天。
  - 聊天继续绑定 `projectId + threadId`。

## 不允许扩大的范围

- 不把 BFF 变成业务真相层。
- 不在 BFF 新增状态机、持久化表、迁移或支付状态判断。
- 不用 Flutter fallback 吞掉 routeTarget 漂移。
- 不把实例路径 `/api/app/project/<projectId>/...` 注册为新的合法 canonicalPath。
- 不借本轮修复打开支付、结算、订单转换或完整竞标提交新范围。

## 需要保留但暂不开通

- `bid_service_fee_authorization.open` 的后续页面跳转、支付授权与金额冻结流程保留为独立支付链路验收项。
- PM2 历史进程注册可保留为运行态遗留清理项；正式运行口径以 `systemd + /srv/apps/*/current` 为准。
- 新项目从创建到竞标、项目沟通、授权页全链路 UAT 保留为后续发布判断前的扩展验收。

## 后续扩展位

- 可以在 `docs/01_contracts` 追加 routeTarget canonicalPath 表，集中冻结所有 `actionKey -> objectType -> canonicalPath -> params`。
- 可以增加 BFF routeTarget normalization helper，减少多个 read-model 重复写路径常量。
- 可以增加云上 smoke 脚本化检查：扫描 project communication detail 中所有 `detailRouteTarget`，发现实例路径直接失败。

## 阶段门禁核查表

| Gate | Result | Evidence |
| --- | --- | --- |
| 真源门禁 | Pass | 本文件冻结 L0 修复真相。 |
| 架构边界门禁 | Pass | Flutter 仍只访问 BFF；Server 仍为业务真相层；BFF 只做投影规范化。 |
| 契约门禁 | Pass | 修复 canonicalPath drift；不新增字段、不新增路由。 |
| 状态机门禁 | Pass | 不改状态机、不新增状态。 |
| 云上运行门禁 | Pass with receipt required | 云上对齐和 8080 smoke 见 Day2 runtime receipt。 |
| 阶段控制门禁 | Pass | 目标限定为 routeTarget canonicalPath mismatch 修复。 |

## 判断

- 更稳：BFF 输出模板 canonicalPath，Flutter 继续严格校验。
- 更省成本：只改 BFF 两个 read-model 和 targeted tests。
- 更适合当前阶段：本轮是云上真实账号触发的投影漂移修复，最小 BFF patch 足够闭环。
- 风险更大：放宽 Flutter parser 或把实例路径登记为合法入口，会掩盖后续 routeTarget 漂移。
