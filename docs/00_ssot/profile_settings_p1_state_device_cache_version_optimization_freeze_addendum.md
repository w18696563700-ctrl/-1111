---
owner: Codex 总控
status: frozen
purpose: Freeze the P1 profile settings optimization scope for certification identity status, current session/device display, local cache cleanup, and version/runtime information.
layer: L0 SSOT
freeze_date_local: 2026-04-28
---

# 《设置 P1 状态展示与本地轻操作优化对象冻结单》

## 1. 总控结论

本轮优化对象锁定为：

- `我的楼 -> 设置` 的 P1 四项：
  - 公司认证与我的身份
  - 会话与设备
  - 清理缓存
  - 当前版本

本轮不执行默认的 App 首屏 / 展览楼首页 / 项目列表视觉大改。用户已给出更明确 P1 设置项目标，且该目标更适合以 Flutter 最小闭环完成。

## 2. 本轮只优化什么

### 2.1 公司认证与我的身份

- 在设置页展示可信状态摘要。
- 状态只来自现有 shell context / 已有 profile 显示函数。
- 点击进入轻量状态说明页或受控说明，不直接打开完整认证提交链。
- 数据不足时显示“状态待确认”，不得硬编码假认证状态。

### 2.2 会话与设备

- 只展示当前设备、本地登录态、登录来源、token 是否存在、过期状态。
- 不展示其他设备列表。
- 不提供踢设备 / 撤销设备。
- 不把本地 deviceId 当成 Server 设备真值。

### 2.3 清理缓存

- 只清理安全的本地可重建缓存：
  - Flutter 图片内存缓存。
  - 本项目已知临时预览文件前缀。
- 清理前必须二次确认。
- 清理中必须防重复点击。
- 不清理登录态、token、业务草稿、待上传附件、用户资料。

### 2.4 当前版本

- 展示真实 app version / build number。
- 展示 runtime entry mode / environment label。
- 展示 app-facing base URL 的脱敏运行态。
- 不展示 token、账号密钥、云端 root 信息。

## 3. 本轮不优化什么

- 不新增或修改 contracts。
- 不修改 BFF。
- 不修改 Server。
- 不修改 Admin。
- 不做完整公司认证提交、重提、OCR、审核流。
- 不做完整设备列表、踢设备、退出全部设备。
- 不做完整缓存管理中心。
- 不重构全 App 设置架构。
- 不把 mock 数据写成生产事实。
- 不把本地 3000 / 3001 当真实 BFF / Server。

## 4. 涉及页面 / 路由 / 文件

### 4.1 Flutter 页面与路由

- `apps/mobile/lib/features/profile/presentation/profile_settings_page.dart`
- `apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart`
- `apps/mobile/lib/features/profile/navigation/profile_routes.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`

允许新增 profile settings 子页，用于：

- 公司认证与我的身份轻量状态说明。
- 当前会话与设备轻量说明。
- 当前版本与运行信息。

### 4.2 Flutter 支撑模块

允许新增最小 Flutter 支撑模块：

- runtime info service
- local cache cleanup service

支撑模块只能读取本地运行态或清理安全缓存，不拥有业务真相。

### 4.3 测试

- `apps/mobile/test/profile_page_test.dart`
- 允许新增独立 capture / focused test 文件。

## 5. 是否涉及 contracts / BFF / Server / 云端联调

| 范围 | 是否涉及 | 裁决 |
|---|---|---|
| Flutter | 是 | 本轮唯一实现面 |
| SSOT | 是 | 只冻结边界与验收回执 |
| contracts | 否 | 不新增字段，不改契约 |
| BFF | 否 | 只读探查，不改实现 |
| Server | 否 | 只读探查，不改实现 |
| 云端联调 | 是 | 仅通过 `127.0.0.1:8080` 只读/认证态 smoke |

## 6. 候选项判断

- 更稳：
  - 只做设置 P1 四项最小闭环，不扩认证、设备、安全中心。
- 更省成本：
  - 使用现有 shell context、本地 session store、Flutter image cache、package info。
- 更适合当前阶段：
  - 设置页继续补齐可信状态与本地轻操作，延续 P0 已完成链路。
- 风险更大：
  - 同时打开完整认证提交流、设备列表撤销、缓存中心、BFF/Server 字段扩展。

## 7. 阶段门禁

- passed gates：
  - 已确认本地只有 Flutter。
  - 已确认 BFF / Server 在阿里云。
  - 已确认本地联调入口为 `http://127.0.0.1:8080`。
  - 已确认本轮不改 contracts / BFF / Server。
  - 已确认本轮 P1 不进入完整账号安全中心。
- failed gates：
  - 无。
- veto gates：
  - 无。
- next stage allowed：
  - 允许进入 Flutter P1 最小闭环实现。
