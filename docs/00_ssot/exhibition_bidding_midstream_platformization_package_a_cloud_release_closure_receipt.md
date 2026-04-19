---
owner: Codex 总控
status: active
purpose: Record the latest local truth repairs, cloud release closure, live app-facing verification evidence, and rollback guard for exhibition bidding midstream platformization Package A so later threads do not mistakenly revert required runtime fixes.
layer: L0 SSOT
freeze_date_local: 2026-04-14
---

# 《展览竞标平台化中段 Package A 云端发布收口回执》

## 1. 当前对象

- 当前对象：
  - `展览竞标平台化中段 / Package A`
- 当前范围：
  - `seat`
  - `bid package completeness`
- 当前不包含：
  - `Package B = buyer compare + winner decision`
  - `Package C = loser feedback`
  - `payment / deposit / esign`

## 2. 当前本地真相修补

### 2.1 Server legacy schema compatibility

- 当前为保持旧库 `bids` 非空字段兼容，`Server` 已正式补齐：
  - `bid_no`
  - `bidder_organization_id`
  - `submitted_by`
  - `submitted_at`
- 对应本地权威源码文件：
  - [bid.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/entities/bid.entity.ts)
  - [bid-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/bid-write.service.ts)
  - [bid-submit.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/bid-submit.test.cjs)

### 2.2 Seat access truth alignment

- 当前 `seat/status / lock / release` 已明确允许：
  - `buyer` 在项目私域内访问已提交 `bid`
  - `supplier` 访问自己的已提交 `bid`
- 这不是越权扩包，而是 `Package A` 真实 app-facing submit 链所需的最小运行态真相。
- 对应本地权威源码文件：
  - [bid-seat.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/bid-seat.service.ts)
  - [bid-seat-package-completeness.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/bid-seat-package-completeness.test.cjs)

### 2.3 BFF status nullable drift alignment

- 当前 `GET /api/app/bid/seat/status` 在 `available` 态已允许：
  - `seatId = null`
- 同时继续保持：
  - `lock / release` accepted response 的 `seatId` 必填
- 对应本地权威源码文件：
  - [bid-seat-completeness.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/bid/bid-seat-completeness.read-model.ts)
  - [bid.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/bid/bid.service.ts)
  - [bid-seat-completeness.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/bid/bid-seat-completeness.test.cjs)

### 2.4 Flutter bounded consumption truth

- 当前 `bidder / submit` 已是 `Package A` 的真实主消费面：
  - `seat status`
  - `seat lock / release CTA`
  - `package completeness`
- 当前 `buyer / detail` 已被正式收口为诚实的：
  - `compare_not_ready`
  - `not_visible`
- 这表示当前页面没有 authoritative `bidId` 时，不伪装成 `seat / completeness` 已真实接通。
- 对应本地权威源码文件：
  - [bid_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart)
  - [bid_submit_sections_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_sections_support.dart)
  - [my_project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart)
  - [bid_seat_completeness_consumption_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/bid_seat_completeness_consumption_test.dart)

## 3. 云端发布收口结果

### 3.1 Server active release

- 中间 release：
  - `/srv/releases/server/20260414013844`
- 当前最终 active release：
  - `/srv/releases/server/20260414014757`
- 当前 `current` 已指向最终 release：
  - `/srv/apps/server/current -> /srv/releases/server/20260414014757`
- 当前 `exhibition-server.service` 已稳定接管该 release。

### 3.2 BFF active release

- 当前 active release：
  - `/srv/releases/bff/20260414010700/apps/bff`
- 当前 `current` 指向：
  - `/srv/apps/bff/current -> /srv/releases/bff/20260414010700/apps/bff`
- 当前 `exhibition-bff.service` 已稳定接管该 release。

### 3.3 运行态一致性

- 本轮最终运行态以真实业务路径和数据库真值验活，不以旧 health 争议替代。
- 当前 `Package A` 在 active runtime 中已 materialize：
  - `POST /api/app/bid/submit`
  - `GET /api/app/bid/seat/status`
  - `GET /api/app/bid/package-completeness`
  - `POST /api/app/bid/seat/lock`
  - `POST /api/app/bid/seat/release`

## 4. 真实 app-facing 验真证据

- 当前 supplier 样本在 active runtime 下已完成：
  1. `POST /api/app/bid/submit`
     - `202`
     - `bidId = 308440a8-7881-48a6-bc1b-821a108581e4`
  2. `GET /api/app/bid/seat/status`
     - `200`
     - `state = available`
     - `seatId = null`
  3. `GET /api/app/bid/package-completeness`
     - `200`
     - `state = complete`
     - `missingItems = []`
  4. `POST /api/app/bid/seat/lock`
     - `202`
     - `state = locked`
     - `seatId = 2ec216e1-8339-4678-9e27-493e97854270`
  5. `GET /api/app/bid/seat/status`
     - `200`
     - `state = locked`
  6. `POST /api/app/bid/seat/release`
     - `202`
     - `state = released`
  7. `GET /api/app/bid/seat/status`
     - `200`
     - `state = released`

## 5. 数据库真值证据

- 当前新建 `bid`：
  - `bid_id = 308440a8-7881-48a6-bc1b-821a108581e4`
  - `bid_no = BID-EXH-2026-8AC90B`
  - `bidder_organization_id = 5564ecfa-0ef2-4545-a15c-bf1b66458d2a`
  - `submitted_by = 99c99709-3786-4d8a-a0c3-5e1a0e945821`
  - `submitted_at = 2026-04-14 01:43:02`
- 当前对应 `bid_seats` 真值：
  - `seat_id = 2ec216e1-8339-4678-9e27-493e97854270`
  - `project_id = 97779e2d-50a0-4038-a0d8-1ee3b4d9d122`
  - `bid_id = 308440a8-7881-48a6-bc1b-821a108581e4`
  - `state = released`
- 当前 `project_publish_audit_log` 已存在：
  - `bid_completeness_evaluated`
  - `seat_locked`
  - `seat_released`

## 6. 不得误回退的最新真相

- 不得把 [bid.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/entities/bid.entity.ts) 里新增的 `bid_no / bidder_organization_id / submitted_by / submitted_at` 兼容字段误判成无关漂移后回退；当前 active runtime 已依赖这些字段通过旧库非空约束。
- 不得把 [bid-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/bid-write.service.ts) 中对 legacy 非空字段的 submit 写入兼容误判成多余逻辑后回退；否则 `POST /api/app/bid/submit` 会重新回到运行时失败。
- 不得把 [bid-seat.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/bid-seat.service.ts) 的 supplier own-bid seat access 误判成越权后回退；当前 `Package A` 的真实 supplier submit -> seat 链路依赖该访问规则。
- 不得把 [bid-seat-completeness.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/bid/bid-seat-completeness.read-model.ts) 对 `seat/status.available -> seatId = null` 的放行误判成 contract 放宽错误后回退；这已经与正式 contract truth 对齐。
- 不得把 [my_project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart) 中 `buyer/detail` 的 `compare_not_ready / not_visible` 受控表达误判成未完成 bug 后强行改回假消费壳；当前收口是 Package A 的正式边界。
- 不得把 [bid_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart) 与 [bid_submit_sections_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_sections_support.dart) 中真实 `seat lock / release` CTA 再次关死。

## 7. 当前裁决

- `Package A = seat + bid package completeness`
  - `code truth = pass`
  - `cloud release closure = pass`
  - `live supplier chain = pass`
- 当前结论仅适用于：
  - `Package A`
- 当前不自动开放：
  - `Package B`
  - `Package C`
  - 完整竞标平台化中段

## 8. 是否可作为最新 authoritative receipt

- 结论：
  - `yes`
- 当前用途：
  - 作为 `Package A` 的最新 authoritative runtime / release closure receipt
  - 作为后续线程进行：
    - `Package A maintenance`
    - `Package B planning`
    - `rollback risk review`
    时的最新真相依据
