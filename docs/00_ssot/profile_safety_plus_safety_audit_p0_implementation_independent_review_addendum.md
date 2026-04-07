---
title: Profile Safety Plus Safety Audit P0 Implementation Independent Review
status: effective
created_at: 2026-04-07 02:56 CST
scope: content_safety_profile_safety_plus_safety_audit_p0
---

# Profile Safety P0 + Safety Audit P0 实施独立复核结论单

## 1. Current Judgment Object

本轮复核对象为三份执行回执：

- `Profile Safety P0 + Safety Audit P0` Server receipt
- `Profile Safety P0 + Safety Audit P0` BFF receipt
- `Profile Safety P0 + Safety Audit P0` Flutter receipt

本轮复核不是 Forum Report P0、Block P0、Admin Review P0、AI runtime、OCR/QR、处罚、申诉、发布准备或 launch approval。

## 2. Current Scope

允许复核范围：

- `Profile Safety P0`
- `Safety Audit P0`
- CS-001 至 CS-006
- CS-025
- CS-026
- CS-031
- active cloud ingress 对首包链路的最小读证

继续阻断：

- Forum Report P0
- Block P0
- Admin Review P0
- AI runtime
- OCR / QR detection
- penalty / appeal
- private-message governance
- release-prep / launch approval

## 3. Review Evidence

本地源码与构建证据：

- `apps/server npm run build`：通过。
- `apps/bff npm run build`：通过。
- `apps/mobile flutter analyze lib/features/profile/data/profile_personal_edit_consumer_layer.dart lib/features/profile/presentation/profile_detail_pages.dart test/profile_personal_minimal_edit_test.dart test/profile_page_test.dart`：通过。
- `apps/mobile flutter test test/profile_personal_minimal_edit_test.dart test/profile_page_test.dart`：通过，34 tests passed。
- 本地 `apps/server/dist` 已包含 `ProfileSafetyWriteService`、`ProfileSafetyQueryService`、`ContentSafetyModule`、`profile_safety_submissions`、`content_safety_rules`、`content_safety_audit_logs`、`content_safety_snapshots`。

云端 active ingress 证据：

- `127.0.0.1:8080` 当前为 SSH 转发到云端 `nginx :80`。
- `GET /api/app/profile/personal/safety` 无会话时返回受控 `401 AUTH_SESSION_INVALID`，说明 active BFF app-facing route 已 materialize。
- 带 actor headers 的 `GET /api/app/profile/personal/safety` 经 active ingress 返回 `404 PROFILE_SAFETY_SUBMISSION_UNAVAILABLE`，`details.originalMessage` 为 `Cannot GET /server/profile/personal/safety`。
- 云端 `exhibition-bff.service` 与 `exhibition-server.service` 均为 `active`。
- 云端 active BFF symlink：`/srv/apps/bff/current -> /srv/releases/bff/20260406222006/apps/bff`。
- 云端 active Server symlink：`/srv/apps/server/current -> /srv/releases/server/20260406222006`。
- 云端 active BFF artifact 中存在 `ProfileSafetyService` 与 app-facing personal safety routes。
- 云端 active Server artifact 中未找到 `ProfileSafety`、`content_safety`、`personal/safety`、`personal/intro` 相关产物。
- 直连云端 Server `:3001` 与 `:3401` 均对 `/server/profile/personal/safety` 返回 raw `Cannot GET /server/profile/personal/safety`。

## 4. Findings

### Finding 1: Active cloud Server artifact 未对齐当前 Server truth

严重级别：Blocker。

本地 Server 源码与 dist 已具备首包实现，但云端 active Server runtime 不具备对应 artifact。active ingress 经 BFF 转发到 Server 后仍返回：

- `Cannot GET /server/profile/personal/safety`

这意味着 live success proof 当前不成立，首包不能验收通过。

### Finding 2: BFF bounded implementation 局部通过，但被 upstream Server runtime 阻断

严重级别：High。

云端 active BFF 已 materialize app-facing route，并能把缺失 Server route 归一化为 controlled app-facing error。BFF 局部实现可接受，但不能替代 Server live success proof。

### Finding 3: Flutter 局部测试通过，但仍存在文件长度门风险

严重级别：High。

本轮触达或相关文件存在明显超过 AGENTS 文件长度门的情况：

- `apps/mobile/lib/features/profile/data/profile_personal_edit_consumer_layer.dart`：约 777 行。
- `apps/mobile/lib/features/profile/presentation/profile_personal_edit_pages.dart`：约 703 行。
- `apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart`：约 625 行。
- `apps/server/src/modules/profile/profile-safety.write.service.ts`：约 640 行。

这些不一定阻断本轮 runtime correction，但不能在最终验收中忽略。后续必须拆出独立 refactor/correction 边界或登记正式豁免；不能口头豁免。

### Finding 4: Flutter 存在冗余嵌套质量点，但非当前编译阻断

严重级别：Low。

`profile_personal_edit_consumer_layer.dart` 中 `commitAvatar` 的成功响应判定曾出现可疑重复嵌套结构。当前 `flutter analyze` 通过，因此不是编译阻断，但仍应在前端修正包中清理。

### Finding 5: `ProfileSafetyQueryService` app-facing safety readback 仍需确认 avatar URL 投影策略

严重级别：Medium。

`ProfileQueryService` 与 `ShellQueryService` 已通过 `UploadPublicUrlService` 把头像 URL 转成可访问签名 URL；`ProfileSafetyQueryService` 当前直接返回 `user.avatarUrl` 与 `proposedAvatarUrl`。如果安全状态页未来展示头像图像而非只展示文字状态，需要保证 app-facing `avatarUrl/pendingAvatarUrl` 不回退成私有 OSS 静态 URL。

## 5. Decision

Server 本地源码层：conditional pass。

BFF 本地源码层：pass。

Flutter 本地源码 / 测试层：conditional pass。

Active cloud runtime：fail。

总控总判定：

- `Profile Safety P0 + Safety Audit P0` implementation receipt：NO-GO。
- 不允许进入 Forum Report P0。
- 不允许进入 Block P0。
- 不允许进入 Admin Review P0。
- 不允许进入联动发布准备。

## 6. Required Correction

唯一下一步：

`Profile Safety P0 + Safety Audit P0 cloud Server artifact alignment correction`

该修正只允许处理：

- 将当前 Server artifact 对齐到 cloud active Server runtime。
- 确认 `/server/profile/personal/safety`、`/server/profile/personal/intro`、`/server/profile/personal/nickname`、`/server/profile/personal/avatar` 在 active Server `:3001` 上存在。
- 确认 `content_safety` 与 `profile_safety_submissions` migration carrier 已在 active cloud DB 对齐。
- 通过 active ingress `:80 -> BFF :3000 -> Server :3001` 重跑昵称、头像、简介 safety status 的最小 live proof。

不得处理：

- Forum Report P0
- Block P0
- Admin Review P0
- AI runtime
- OCR / QR detection
- penalty / appeal
- private-message governance
- launch / release-prep

## 7. Capability Tracking Impact

不得把 CS-001 至 CS-006、CS-025、CS-026、CS-031 标为已完成。

当前状态应视为：

- 已进入实施复核。
- active runtime 未闭环。
- pending cloud artifact alignment correction。

本轮是否发生母版能力点遗漏、越界实施或默认删除：

- 未发现默认删除。
- 未发现 Forum Report / Block / Admin Review 代码越界。
- 发现 active cloud Server artifact 未对齐，阻断首包验收。

