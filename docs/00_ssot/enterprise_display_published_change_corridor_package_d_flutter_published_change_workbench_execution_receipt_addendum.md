---
owner: Frontend Agent
status: completed
purpose: Record the real Package D Flutter published-change workbench implementation result for the enterprise display published change corridor.
layer: L0 SSOT
freeze_date_local: 2026-04-12
---

# 《enterprise display published change corridor Package D Flutter published-change workbench execution receipt》

## 1. 修改文件清单

- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_widgets.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`

## 2. workbench / status / submit flow 实现说明

- Flutter 已补入 published-change 专用 consumer layer，只消费 canonical `changes/current` family：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/{boardType}`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
  - `DELETE /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
- 用户侧已可通过 published-change route 进入 workbench 与 status：
  - `enterprisePublishedChangeWorkbenchWithEnterpriseId(...)`
  - `enterprisePublishedChangeStatusWithEnterpriseId(...)`
- workbench 已消费 `changes/current` 主 carrier，并把外围组织/认证/地区 truth hydration 改成后补，不再阻断主工作台落屏。
- basic / profiles / cases 的保存都已切到 `changes/current` family；页面文案统一明确为“保存到当前变更内容”，不再暗示已立即上线。
- `submit` 已接到真实 `POST /changes/current/submit`，成功后进入 published-change status 页，再按真实状态返回结果，不本地猜测 live 结果。
- `revision_required` 下继续回到同一条 `changeRequestId` 修改并再次提交，不新建第二条 change request 心智。
- 案例库卡片已提供 `继续编辑`，published-change 下从 current snapshot 直接回填当前案例编辑器；编辑模式按钮为 `保存修改`，保存走 `PUT /changes/current/cases/{caseId}`。
- 命中 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED` 时只做受控提示，不实现 `changes/current` 之外的 fake continuation。

## 3. `liveSnapshot / current snapshot` 区分说明

- workbench 已新增 published-change snapshot section，同时显示：
  - `current change snapshot`
  - `liveSnapshot`
- `current change snapshot` 展示 `changeRequestId`、`changeStatus`、提交时间、审核时间、退回原因，并说明当前保存只写入 current change carrier。
- `liveSnapshot` 展示当前线上公开真值的企业状态、展示状态、发布时间，并明确说明“当前线上展示仍以 liveSnapshot 为准，保存修改不会立即改线上”。
- 提交区和 header 文案同步使用这一边界，不再把 current change snapshot 与 live listing 合并成一个用户心智。

## 4. 用户侧 `approved / applied` 边界说明

- Flutter 已单独定义 published-change status label / explanation。
- `approved` 明确表达为：
  - 审核通过
  - 待 apply
  - 不等于已上线
- `applied` 明确表达为：
  - 已写入线上展示
  - liveSnapshot 已更新到当前公开展示真值
- status 页和 workbench 提交区都沿用这一边界；用户不会再把 `approved` 误判成已经写入 live listing。

## 5. 测试清单

- `enterprise published change workbench consumes changes current family and separates live snapshot from current snapshot`
- `enterprise published change basic save uses changes current basic path and keeps copy off live semantics`
- `enterprise published change case continuation stays inside current snapshot and save modification uses changes current case path`
- `enterprise published change submit navigates to real status instead of guessing local live result`
- `enterprise published change revision required stays on same change request and remains editable`
- `enterprise published change status keeps approved and applied clearly separated`
- 以上用例均位于 `apps/mobile/test/enterprise_hub_routes_test.dart`

## 6. analyze / test 结果

- `cd apps/mobile && flutter analyze lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart lib/features/exhibition/navigation/exhibition_routes.dart lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart test/enterprise_hub_routes_test.dart`
  - 结果：`No issues found!`
- `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise published change"`
  - 结果：`6 tests passed`
- `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart`
  - 结果：`46 tests passed`

## 7. 当前剩余未闭合项

- Package D / Flutter published-change workbench 范围内无剩余未闭合项。
- 本轮未实现也未扩写：
  - `changes/current` 之外的治理真相 owner 逻辑
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - 频次治理
