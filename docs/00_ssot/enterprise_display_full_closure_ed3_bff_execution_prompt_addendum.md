---
owner: Codex 总控
status: frozen
purpose: Provide the prepared BFF execution prompt for ED-3 of the enterprise-display full-closure mainline, so application submit/status transport can start immediately after the ED-2 workbench gate closes.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - docs/03_bff/enterprise_display_workbench_v1_bff_surface_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
---

# 《enterprise display full closure ED-3 BFF execution prompt》

## 1. 当前唯一任务

- 你现在是：
  - `enterprise display full closure mainline`
  - `ED-3 BFF execution owner`
- 你的唯一目标是：
  - 把 enterprise-display 的 `application create / submit / status / continue` 收成唯一 app-facing transport
  - 保证 Flutter 继续只访问 `/api/app/*`
- 这一步只做：
  - application family 的 app-facing transport
  - session/auth 透传
  - organization-scope forward
  - response normalization
- 这一步不做：
  - Server truth 改写
  - workbench truth 扩写
  - admin review/publish
  - public recommendation/list/detail
  - release / deploy

## 2. 当前阶段前提

- 当前前提固定为：
  - `ED-2` 已 closure
  - workbench 侧 `basic/profile/case/readiness` 已稳定
- 当前 BFF 要解决的是：
  - `application` family 的 app-facing transport 和错误语义
  - 不是第二套 application state machine

## 3. 允许修改范围

- 只允许修改：
  - `apps/bff/src/routes/enterprise_hub/**`
- 不允许修改：
  - `apps/server/**`
  - `apps/mobile/**`
  - `apps/admin/**`

## 4. 你必须完成

1. 统一以下 app-facing path 的 transport 与 normalization：
   - `POST /api/app/exhibition/enterprise-hub/applications`
   - `POST /api/app/exhibition/enterprise-hub/applications/{applicationId}/submit`
   - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`
2. 保持 `Flutter -> BFF -> Server` 单向链，不允许 Flutter 直打 `/server/*`。
3. 透传当前 session 与 current organization scope，不得在 BFF 派生第二套 organization truth。
4. 归一错误语义，至少保证：
   - auth/session 错误
   - boardType/body invalid
   - resource unavailable
   - permission denied
   - submit blocked
   在 app-facing 面是稳定可消费的。
5. `continue/status` 所需最小 response shape 必须与既有 contract 对齐，不得自造新字段族。

## 5. 你必须遵守

1. 不得在 BFF 推导 `submitReady`。
2. 不得在 BFF 复制 application 状态机。
3. 不得在 BFF 派生 certification / organization 真值。
4. 不得把这一步扩到 admin review/publish。
5. 不得把 `/bff/*` 暴露成产品真相路径。

## 6. 完成标准

- 结果必须证明：
  - application create / submit / status 三条 app-facing 路由稳定
  - 错误语义可被 Flutter 稳定消费
  - BFF 只做 transport/normalization，不持有第二状态机
- 这一步不要求你证明：
  - admin review/publish 已成功
  - public list/detail 已成功
  - 首页卡片已成功

## 7. 交付回执要求

- 你完成后必须给出：
  1. 修改文件清单
  2. app-facing path 与 server path 对照
  3. 新增/更新的测试或编译结果
  4. 仍未覆盖的非目标清单

## 8. 当前下一步

- 当前阶段完成度：
  - `dispatch 完成`
- 当前下一步唯一动作：
  - 在 `ED-2 closure` 后发出本口令给 `BFF`
- 下一步执行角色：
  - `BFF`
- 下一步进入条件：
  - workbench ED-2 已 closure，且 application family 准备进入 app-facing transport 收口
