# 《enterprise display submit chain runtime scan receipt》

---
owner: Codex 总控
status: frozen
freeze_date_local: 2026-04-10
purpose: Freeze one end-to-end runtime and code scan receipt for the current enterprise-display submit chain so the next execution prompt is based on real blockers instead of UI impression.
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-certification-sync.service.ts
---

## 1. 当前扫描对象

- `我的公司 -> organization current city truth`
- `企业认证 current / submit / resubmit`
- `enterprise display workbench basic / profile / case / contact`
- `application create / submit / status`
- runtime persistence on current cloud host `47.108.180.198`

## 2. 当前链路结论

- 当前 `提交入驻申请` 不能成功，不是单一前端灰按钮问题。
- 当前阻断来自真实 `Server truth` 与 runtime object state：
  - 当前 organization certification truth 已被清空
  - 当前 organization 注册城市真值仍未成立
  - 当前 listing `basic` 仍为空
  - 当前 factory `boardProfile` 仍为空
  - 当前 case 数量为 `0`
- 同时还存在两条 runtime drift：
  - 同一 listing 下累计了大量 draft application
  - organization certification 被清空后，listing certification snapshot 仍残留 `approved`

## 3. 代码链扫描结论

### 3.1 mobile

- `submitApplication()` 当前只走 app-facing submit path，且 body 已按合同发送 `confirm: true`。
- `提交入驻申请` 按钮当前完全受 `readiness.submitReady` 驱动；当 `submitReady=false` 时直接灰掉。
- `saveBasic()` 仍依赖有效注册城市真值；若 `provinceCode/cityCode` 无法从 `我的公司` 或当前 workbench truth 解出，就会直接 fail-closed。

### 3.2 BFF

- `submit` transport 当前合同对齐：
  - `confirm !== true` 直接 fail-closed
  - app-facing 错误语义已与 submit confirm 对齐
- 当前未发现 BFF second state machine 问题。

### 3.3 Server

- workbench readiness 当前固定依赖：
  - `basicCompleted`
  - `profileCompleted`
  - `hasCase`
  - `hasContact`
  - `certificationApproved`
- submit write gate 与 readiness 口径一致，仍会执行：
  - `ensureListingMinimum`
  - `ensureContactMinimum`
  - `ensureCertificationMinimum`
  - `ensurePrimaryProfileMinimum`
  - `ensureCaseMinimum`
- `createApplication()` 当前每次都会新建一条 draft application，没有复用当前 listing 既有 draft 的去重逻辑。
- `certificationSyncService.syncForListing()` 在 organization certification 不存在时，会把 listing `verificationStatusSnapshot` 写成 `null`，但不会删除已有 `enterprise_certification_snapshot`。

## 4. 当前云上 runtime 实况

### 4.1 organization / certification

- organization: `e6bf4567-016e-45f9-9420-9c950237690e`
- 当前 organization:
  - `province_code = 000000`
  - `city_code = 000000`
- 当前 organization certification row:
  - 已删除

### 4.2 enterprise listing

- listing: `bf5ff83a-26e7-4138-8157-042fb38a5f46`
- boardType: `factory`
- listing 当前状态：
  - `name = ''`
  - `short_intro = ''`
  - `province_name = ''`
  - `city_name = ''`
  - `address = null`
  - `founded_at = null`
  - `verification_status_snapshot = 'verified'`

### 4.3 profile / contact / case / application

- factory profile row：
  - 不存在
- contact:
  - 已存在 `王巍威 / 18696563700`
- case count:
  - `0`
- application count:
  - `19`
- latest application examples:
  - 均为 `draft`
- enterprise certification snapshot:
  - 当前仍残留一条 `approved` 的 `business_license` snapshot

## 5. 当前唯一真实阻断序列

1. `我的公司` 注册城市真值未补齐
2. 企业认证已被清空，当前必须重新认证并回到 `approved`
3. `basic` 为空，必须先保存
4. `factory profile` 为空，必须先保存
5. `case = 0`，必须先创建至少 1 条案例
6. 上述满足后，submit 才有资格成功

## 6. 当前不应误判的事项

- 不应误判为“只是灰按钮交互差”
- 不应误判为“只删文案就能让 final submit 成功”
- 不应误判为“BFF transport 还没打通”
- 不应误判为“只要前端把按钮改成可点就能过”

## 7. 当前第一修复方向

- 当前第一修复方向不是继续改说明文案。
- 当前第一修复方向固定为：
  - 修 `Server` 侧 runtime drift：
    - 同 listing 重复 draft application 去重 / 复用
    - organization certification 清空时，同步清理 stale `enterprise_certification_snapshot`

## 8. 当前阶段完成度

- judgment 完成

## 9. 当前下一步唯一动作

- 向 `后端` 发出 `enterprise display submit chain runtime drift repair` 执行口令

## 10. 下一步执行角色

- 后端

## 11. 下一步进入条件

- 本扫描结论保持成立，且不新增反证证明重复 draft / stale certification snapshot 已被其他链路修复
