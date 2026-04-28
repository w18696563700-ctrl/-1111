---
owner: Codex 总控
status: frozen
purpose: Freeze the Day 1 P0 boundary for profile settings account status and logout work, so Day 2 Flutter implementation does not assume local BFF or Server ownership.
layer: L0 SSOT
freeze_date_local: 2026-04-28
---

# 《设置 P0 账号状态与退出登录 Day1 边界冻结单》

## 1. 当前结论

本轮只冻结并执行 `设置` 页 P0 中的两项：

1. 当前账号状态。
2. 退出登录。

本轮只允许修改 Flutter App 前端消费与交互，不修改本地 BFF / Server，不新增本地后端假设。

## 2. 运行真相

- 本地只有 Flutter App。
- `BFF` 和 `Server` 运行在阿里云。
- 默认联调入口为 SSH 隧道：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- Flutter App 默认 app-facing base URL 已对齐：
  - `http://127.0.0.1:8080/api/app`
- 本轮不得把 `127.0.0.1:3000`、本地 NestJS、mock Server 当作正式运行真相。

## 3. 正式真源

- `docs/00_ssot/my_building_asset_route_page_truth_owner_stage_status_table_v1.md`
  - `设置` 属于 `ProfileSettingsPage / ProfileRoutes.settings`
  - truth owner 为 `Server bounded account/security truth + client grouping`
- `docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`
  - 现有 app-facing auth route 包含 `POST /api/app/auth/logout`
  - `BFF` 只做 auth handoff 和 response shaping，不拥有 session truth
- `docs/legal/privacy_policy.md`
  - 登录、保持登录态、刷新会话、退出登录属于账号与会话安全处理范围

## 4. Day 1 最小闭环

1. 冻结本轮只做 Flutter。
2. 冻结联调只走阿里云 BFF / Server 隧道。
3. 冻结 `设置` 页账号状态必须以本地 session 与 shell context 共同判断。
4. 冻结退出登录必须调用 `POST /api/app/auth/logout`。
5. 冻结 `200` 和 `401` 均可清理本地 session：
   - `200` 表示云端已接受退出。
   - `401` 表示当前登录态已不可用，前端必须清掉本地残留态。

## 5. Day 2 实施边界

### 5.1 必做

- 顶部账号状态：
  - 未登录：显示未登录。
  - 有本地 session 且 shell context 有账号：显示当前账号。
  - 有本地 session 但 shell context 暂无账号：显示已登录。
  - session refresh 中：显示刷新中。
- 退出登录：
  - 点击后必须二次确认。
  - 请求中必须防重复点击。
  - 成功或 `401` 后必须清空本地 session。
  - 成功后回到 `我的楼`，不得保留旧账号显示。
  - 失败时保留当前 session，并给出失败提示。
- 切换账号：
  - 当前阶段不实现多账号并存。
  - 若展示“切换账号”，语义固定为“先退出当前账号，再进入登录页”。
  - 点击后必须二次确认，防止误触。
  - 未确认前不得调用 `POST /api/app/auth/logout`。
  - 请求中必须防重复点击。
  - 成功或 `401` 后必须清空本地 session，并进入登录页。

### 5.2 禁止

- 不实现多账号并存。
- 不实现退出所有设备。
- 不实现完整会话与设备管理。
- 不新增 BFF / Server route。
- 不在 Flutter 内发明第二套 session truth。
- 不用本地 mock 结论替代阿里云隧道联调结论。

## 6. 需要保留但暂不开通

- 多账号切换。
- 会话与设备列表。
- 设备踢出。
- 异常登录记录。
- 安全事件中心。

这些能力后续必须先补 backend truth、BFF surface、contracts，再进入实现。

## 7. 后续扩展位

- 退出所有其他设备。
- 当前设备命名。
- 登录设备列表。
- 登录时间与 IP 展示。
- 账号注销。
- 通知权限、定位权限、隐私说明继续作为后续 P0 子项单独冻结。

## 8. 稳定性判断

- 更稳：只做 Flutter 消费改造，沿用现有 `/api/app/auth/logout`。
- 更省成本：不改 BFF / Server，不引入新依赖，不做完整安全中心。
- 更适合当前阶段：账号状态和退出登录先闭环，再推进通知、定位、隐私说明。
- 风险更大：把切换账号做成多账号体系，或把会话设备管理提前做成完整后端能力。

## 9. Day 1 审核结论

本冻结单通过后，允许进入 Day 2 Flutter 实现。

阶段门禁结论：

- passed gates：
  - 已确认正式真源优先级。
  - 已确认本地只有 Flutter。
  - 已确认阿里云 BFF / Server 通过 8080 隧道联调。
  - 已确认本轮不改 BFF / Server。
- failed gates：
  - 无。
- veto gates：
  - 无。
- next stage allowed：
  - 允许进入 Day 2 Flutter 账号状态与退出登录改造。
