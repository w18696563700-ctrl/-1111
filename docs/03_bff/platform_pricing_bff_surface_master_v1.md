---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the unique L4 BFF surface authority for the current platform pricing
  master, aligning the app-facing charging corridor to the existing
  `project publish -> bid participation request -> bid submit` mainline while
  introducing only the minimum pricing-specific app-facing routes, Server
  mapping, auth shaping, request shaping, response shaping, error
  normalization, and route-target handoff required by the 200/4000/deal
  confirmation model.
layer: L4 BFF
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md
  - docs/03_bff/project_publish_prepublish_relabel_and_confirmation_bff_surface_addendum.md
  - docs/03_bff/exhibition_bid_submit_full_version_bff_surface_addendum.md
  - docs/03_bff/project_transaction_skeleton_p0_bff_surface_addendum.md
  - docs/03_bff/bff_ssot.md
  - docs/03_bff/bff_routes.md
  - apps/bff/src/routes/exhibition_p0_pay/app-exhibition-p0-pay.controller.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts
  - apps/bff/src/routes/bid_participation_request/app-bid-participation-request.controller.ts
  - apps/bff/src/routes/bid_participation_request/bid-participation-request.service.ts
---

# 《平台收费规则 L4 BFF Surface 母文件 V1》

## 0. 总裁决

当前收费 `L4 BFF surface` 正式重写完成。

本轮正式选择：

1. `BFF` 继续只做 app-facing shaping，不成为收费真相 owner
2. 收费 app-facing 走现有 `project publish -> bid participation request -> bid submit` 主链
3. 只新增最小收费专属 BFF path family，不再以旧 `trade-tasks / p0-pay` 作为当前 app-facing 主骨架
4. `publish` 与 `bid/submit` 的主体 request shape 保持现状，收费通过 pricing gate 和 pricing-specific routes 接入

当前更稳的方案：

- 复用现有 `project`、`bid_participation_request`、`bid/submit` 路径家族，只把 `200 / 4000 / deal confirmation / pricing summary` 下沉为最小 BFF surface

当前更省成本的方案：

- 继续复用 `BFF` 现有 auth forwarding、organization scope、idempotency forwarding、error envelope 和 `routeTarget` shaping，不重起第二收费入口壳

当前阶段最适合的方案：

- 先冻结收费 `L4` 消费面，明确 `publish` 与 `bid submit` 的前置 gate，真实冻结/扣费 runtime 继续受 feature flag 控制

风险更大的方案：

- 一边保留旧 `trade-tasks / 3% / inquiry deposit` BFF surface，一边在 `project/publish`、`bid/submit` 和 Flutter 局部偷偷切成 `200 / 4000 / 阶梯费率`

本文件生效后：

1. [exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md) 不再作为当前收费 `L4 BFF surface` 主文件
2. 当前收费 `L4` 只以本文件为准
3. 下一轮唯一动作切换为 `L5 Flutter consumption`

## 1. Scope

本文件只冻结 `当前平台收费规则` 的 `L4 BFF surface`。

本文件覆盖：

1. `project publish` 前后的 pricing gate app-facing surface
2. `200 元项目真实性诚意金` 的订单、支付拉起、状态读回 BFF surface
3. `bid participation approved` 之后 `4000 元竞标服务费预授权额度` 的创建、冻结、状态、主动解冻 BFF surface
4. `bid/submit` 的收费准入 handoff 语义
5. `deal confirmation` 的 app-facing BFF surface
6. `pricing summary` 的只读 shaping
7. `routeTarget / nextAction / pricingGate` 的 BFF handoff 规则
8. 相关的 auth、scope、payload shaping、error normalization、visibility trimming

本文件不覆盖：

1. `apps/bff/**` 实现改动
2. 云上 `BFF` 部署
3. 真实支付 runtime 开通
4. payment callback runtime
5. Flutter 页面实现
6. wallet / balance / coins / fund-pool
7. 通用 payment / billing center
8. settlement / invoice / finance-admin
9. 履约保证金
10. 会员直购支付 runtime

## 2. 当前最小闭环

当前收费 `L4` 的最小闭环固定为：

1. `project create / save / submit` 保持现状
2. 需要时先通过 `pricing-summary` 读取 `publishGateStatus`
3. 若 `200 元项目真实性诚意金` 未完成，则走：
   - `POST /api/app/project/{projectId}/authenticity-sincerity/orders`
   - `POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init`
   - `GET /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}`
4. `publish` 路径本身不改名、不改主体 shape，但必须尊重收费 gate
5. `bid participation request approve` 保持现状，但 `approved` 后首个 CTA 可能先指向 `4000` 冻结
6. 若 `4000 元竞标服务费预授权额度` 未完成，则走：
   - `POST /api/app/project/{projectId}/bid-service-fee-authorizations`
   - `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init`
   - `GET /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}`
   - `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release`
7. 只有 `approved + authorizationStatus=frozen` 时，`POST /api/app/bid/submit` 才允许通过
8. 达成唯一合作对象后，通过 `POST /api/app/project/{projectId}/deal-confirmations` 推进双向确认
9. `BFF` 只负责 transport、shaping、error normalize，不负责本地收费裁决

## 3. 需要保留但暂不开通

当前 `L4 BFF surface` 必须保留但暂不开通：

1. bare `/api/app/payment/*`
2. bare `/api/app/wallet/*`
3. bare `/api/app/billing/*`
4. bare `/api/app/settlement/*`
5. bare `/api/app/invoice/*`
6. 通用 profile 账单中心写链
7. 履约保证金相关 app-facing 写链
8. 会员直购支付写链
9. 线下转账对账入口

当前正式解释固定如下：

1. `BFF` 不是支付执行平台
2. `BFF` 不是收费规则真相 owner
3. `BFF` 不是回调真相 owner
4. `BFF` 不是第二收费状态机 owner

## 4. 后续扩展位

后续扩展位正式保留：

1. `pricing summary` 在 `project detail / my project / workbench / message handoff` 的一致性消费
2. `deal confirmation detail` 的 richer read-only 展开
3. `Admin / Server` 侧风控与审计辅助消费
4. feature flag 打开后的真实支付通道联调
5. 发布后对 Flutter 消费面和文案口径的统一收口

## 5. App-facing Path Family

### 5.1 保留不重写的既有锚点

以下 app-facing family 继续保留既有 canonical 地位：

1. `POST /api/app/project/create`
2. `POST /api/app/project/save`
3. `POST /api/app/project/submit`
4. `POST /api/app/project/publish`
5. `POST /api/app/project/withdraw`
6. `POST /api/app/project/bid-participation/request`
7. `GET /api/app/project/bid-participation/thread/detail`
8. `GET /api/app/my/projects/{projectId}/bid-participation/pending`
9. `POST /api/app/my/projects/{projectId}/bid-participation/{requestId}/approve`
10. `POST /api/app/my/projects/{projectId}/bid-participation/{requestId}/reject`
11. `POST /api/app/bid/submit`

### 5.2 本轮新增的收费专属 family

| Method | App-facing path | BFF 定位 |
|---|---|---|
| `GET` | `/api/app/project/{projectId}/pricing-summary` | 项目收费只读摘要 shaping |
| `POST` | `/api/app/project/{projectId}/authenticity-sincerity/orders` | `200 元项目真实性诚意金` 订单创建 shaping |
| `POST` | `/api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init` | `200 元项目真实性诚意金` 支付拉起 shaping |
| `GET` | `/api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}` | `200 元项目真实性诚意金` 状态只读 shaping |
| `POST` | `/api/app/project/{projectId}/bid-service-fee-authorizations` | `4000 元竞标服务费预授权额度` 创建 shaping |
| `POST` | `/api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init` | `4000 元竞标服务费预授权额度` 冻结拉起 shaping |
| `GET` | `/api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}` | `4000 元竞标服务费预授权额度` 状态只读 shaping |
| `POST` | `/api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release` | 主动解冻并退出竞标 shaping |
| `POST` | `/api/app/project/{projectId}/deal-confirmations` | 成交双向确认 shaping |
| `GET` | `/api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}` | 成交确认与扣费结果只读 shaping |

### 5.3 当前明确禁止的新 family

当前禁止：

1. `/api/app/exhibition/trade-tasks/*` 继续被当成当前收费 app-facing authority
2. `/api/app/exhibition/p0-pay/*`
3. bare `/api/app/payment/*`
4. bare `/api/app/wallet/*`
5. bare `/api/app/charge/*`
6. Flutter 直连 `/server/*`

## 6. Server Mapping Boundary

`BFF` 当前只允许映射到 `Server` 拥有的收费主线家族。

建议的 server-facing family 正式冻结为：

| App-facing family | Server-facing family | 说明 |
|---|---|---|
| `project/{projectId}/pricing-summary` | `/server/projects/{projectId}/pricing-summary` | 收费只读摘要由 `Server` 派生 |
| `authenticity-sincerity/orders` | `/server/projects/{projectId}/authenticity-sincerity/orders*` | `200 元项目真实性诚意金` 真相由 `Server` 持有 |
| `bid-service-fee-authorizations` | `/server/projects/{projectId}/bid-service-fee-authorizations*` | `4000 元竞标服务费预授权额度` 真相由 `Server` 持有 |
| `deal-confirmations` | `/server/projects/{projectId}/deal-confirmations*` | 成交与扣费结果由 `Server` 持有 |
| `project/publish` | `/server/projects/publish` 或既有 publish canonical path | 发布命令继续复用既有主链 |
| `bid participation approve/reject/thread detail` | 既有 `/server/projects/bid-participation/*` 与 `/server/my/projects/*/bid-participation/*` | 竞标准入主链继续保留 |
| `bid/submit` | 既有 `Server` bid submit canonical path | 竞标提交主链继续保留 |

Mapping rules：

1. `/server/*` 不得暴露给 Flutter
2. 如实现阶段需要复用旧 `p0_pay` module 内部 adapter，只允许发生在 `Server` 内部，不得外露旧 `trade-task / p0-pay` app-facing 语义
3. `BFF` 不得新增未在 `L2/L3` 冻结的收费 business family

## 7. Auth And Scope Shaping

`BFF` 必须统一承接：

1. auth carrier
2. current organization scope
3. actor role
4. request id / trace id
5. idempotency key forwarding

当前 auth 规则固定为：

1. `pricing-summary`、`200` 订单、`4000` 授权、`deal-confirmations` 均为 private-auth
2. `project/publish` 继续保持 private-auth
3. `bid participation approve/reject` 与 `bid/submit` 继续保持 private-auth
4. `BFF` 不得因为收费新主线而把任何收费写链偷放成 public

当前 `BFF` 不得做：

1. 本地判断 `publishGateStatus`
2. 本地判断 `bidSubmissionEligible`
3. 本地生成第二收费权限状态机
4. 本地移动最终 permission judgement 出 `Server`

## 8. Request Shaping

### 8.1 统一规则

`BFF request shaping` 只允许：

1. 字段白名单裁剪
2. 基础类型校验
3. envelope 归一
4. idempotency key 透传
5. auth / organization scope 注入到 `Server` 请求上下文
6. `clientPlatform`、`payChannel` 等冻结枚举的归一

`BFF request shaping` 不得：

1. 本地计算平台服务费最终真值
2. 本地决定是否放行 `publish`
3. 本地决定是否放行 `bid/submit`
4. 本地重算会员折扣、封顶或阶梯费率
5. 本地生成 payment order id、charge id 或 callback state

### 8.2 `project/publish`

`POST /api/app/project/publish` 的主体 request shape 保持既有 canonical shape。

但新增收费门禁语义：

1. `BFF` 不向 publish request 额外注入收费金额真相
2. 当 upstream 返回 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED` 等 pricing gate 错误时，`BFF` 只能归一错误和 handoff，不得伪装成普通 publish 成功
3. publish 前的收费前置动作通过 `pricing-summary + authenticity-sincerity orders` 解决，不在 publish body 内硬塞第二套字段

### 8.3 `200 元项目真实性诚意金`

`POST /api/app/project/{projectId}/authenticity-sincerity/orders` 最小输入只允许：

1. `expectedAmount`
2. `expectedCurrency`
3. `ruleVersion`
4. `ruleSnapshotHash`
5. `idempotencyKey`

`POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init` 最小输入只允许：

1. `payChannel`
2. `clientPlatform`
3. `idempotencyKey`

`BFF` 不得：

1. 把 `200` 改名成发单诚意金、服务费或保证金
2. 在本地把 `expectedAmount` 改成其他数额
3. 生成本地支付成功真相

### 8.4 `bid participation approved` 之后的 pricing handoff

`GET /api/app/project/bid-participation/thread/detail` 当前允许的最小 pricing handoff 语义固定为：

1. `pricingGateRequired`
2. `pricingGateType`
3. `detailRouteTarget`

当前允许的 `pricingGateType` 只包括：

1. `none`
2. `bid_service_fee_authorization_required`

`approved` 当前不得再被 `BFF` 解释成“必然可直接进入 bid submit”。

### 8.5 `4000 元竞标服务费预授权额度`

`POST /api/app/project/{projectId}/bid-service-fee-authorizations` 最小输入只允许：

1. `bidParticipationRequestId`
2. `expectedAmount`
3. `expectedCurrency`
4. `ruleVersion`
5. `ruleSnapshotHash`
6. `idempotencyKey`

`POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init` 最小输入只允许：

1. `payChannel`
2. `clientPlatform`
3. `idempotencyKey`

`POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release` 最小输入只允许：

1. `releaseReasonCode`
2. `releaseReasonText`
3. `idempotencyKey`

`BFF` 不得：

1. 把 `4000` 改写成报名费、席位费或货款
2. 在本地放行 `authorizationStatus != frozen` 的 bid submit
3. 把主动解冻成功伪装成仍可继续竞标

### 8.6 `bid/submit`

`POST /api/app/bid/submit` 的主体 request shape 继续保持既有 6 字段 canonical shape。

但新增硬门禁：

1. upstream 若判定缺少 `approved` 参与竞标准入，`BFF` 必须 fail closed
2. upstream 若判定缺少状态为 `frozen` 的 `bidServiceFeeAuthorization`，`BFF` 必须 fail closed
3. `BFF` 不得要求 Flutter 在 `bid/submit` body 内重复上传 `4000` 冻结真相

### 8.7 `deal-confirmations`

`POST /api/app/project/{projectId}/deal-confirmations` 最小输入只允许：

1. `selectedBidId`
2. `finalConfirmedAmount`
3. `currency`
4. `contractFileAssetIds`
5. `confirmationRole`
6. `idempotencyKey`

`BFF` 不得：

1. 本地伪造 `confirmed_deal`
2. 本地决定最终平台服务费金额
3. 本地把未双向确认写成已成交

## 9. Response Shaping

`BFF response shaping` 只允许：

1. 保留 `L2` 冻结字段
2. 隐藏 `Server` internal 字段
3. 将 `Server` state 映射为 app-facing enum
4. 把 `channelPayload` 作为 opaque payload 传给 Flutter
5. 在收费 gate 场景下提供最小 `nextAction / routeTarget`

### 9.1 `pricing-summary`

`GET /api/app/project/{projectId}/pricing-summary` 最小输出固定为：

1. `projectId`
2. `publisherPricing`
3. `bidderPricing`
4. `dealSummary`
5. `updatedAt`
6. `readOnly`

`BFF` 不得：

1. 本地推导第二份收费摘要
2. 把缺失上游结果伪装成“无需收费”

### 9.2 `200 元项目真实性诚意金`

订单、支付拉起、状态读回的最小成功响应，只允许保留 `L2` 已冻结字段。

`BFF` 不得：

1. 把 `pending` 写成 `paid`
2. 把 `paid` 写成 `released`
3. 扩写第二套支付状态解释块

### 9.3 `4000 元竞标服务费预授权额度`

授权创建、冻结拉起、状态读回、主动解冻的最小成功响应，只允许保留 `L2` 已冻结字段。

`BFF` 不得：

1. 把 `frozen` 写成 `charged`
2. 把 `release_pending` 写成 `released`
3. 把 `release` 成功后仍给出 `bid_submit.open`

### 9.4 `deal-confirmations`

`deal-confirmations` create/detail 的最小成功响应，只允许保留：

1. `dealConfirmationId`
2. `dealStatus`
3. `selectedBidId`
4. `finalConfirmedAmount`
5. `platformServiceFeeCalculation`
6. `serviceFeeChargeStatus`
7. `updatedAt`

detail 还可附带：

1. `publisherConfirmedAt`
2. `factoryConfirmedAt`
3. `publisherAuthenticitySincerityStatus`

## 10. Error Normalization Boundary

当前 `BFF` 对收费主线只允许做：

1. `AUTH_SESSION_INVALID` 统一登录态失效文案
2. `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED` 等 `200` gate 错误归一
3. `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED` 等 `4000` gate 错误归一
4. `DEAL_CONFIRMATION_INVALID`、`DEAL_CONFIRMATION_INVALID_STATE` 等成交确认错误归一
5. 统一 `statusCode / code / message / source`

当前 `BFF` 不允许做：

1. 把未知 critical pricing error 改成成功
2. 把收费 gate 错误改造成普通空态
3. 把上游 transport gap 假装成“可继续下一步”

## 11. RouteTarget / NextAction Handoff

当前收费 `L4` 最小 handoff 规则正式冻结为：

1. 当 `publishGateStatus` 不满足时，`nextAction` 必须指向：
   - `pricing_summary.open`
   - 或 `project_authenticity_sincerity.open`
2. 当 `approved` 但 `4000` 未冻结时，`detailRouteTarget` 必须先指向：
   - `bid_service_fee_authorization.open`
3. 只有 `authorizationStatus = frozen` 时，才允许 handoff：
   - `bid_submit.open`
4. 主动解冻成功后，`nextAction` 不得继续指向 `bid_submit.open`

`BFF` 不得：

1. 构造未冻结的新深链 page family
2. 把收费 gate 绕开成旧 `trade-task` 路由
3. 让 Flutter 本地猜测下一步收费动作

## 12. 被正式降级的旧 BFF 文书与条款

当前正式降级如下：

1. [exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md)
   - 旧 `trade-tasks / inquiry-deposit / service-fee-authorizations / p0-pay-summary` app-facing 主骨架
   - 当前只保留为 `historical migration baseline`
2. [project_publish_prepublish_relabel_and_confirmation_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/project_publish_prepublish_relabel_and_confirmation_bff_surface_addendum.md)
   - 保留 `publish` 路径和命名重排真相
   - 但不再拥有收费 gate authority
3. [exhibition_bid_submit_full_version_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/exhibition_bid_submit_full_version_bff_surface_addendum.md)
   - 保留 `bid/submit` 主体 shape 真相
   - 但不再拥有收费 gate authority
4. [project_transaction_skeleton_p0_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/project_transaction_skeleton_p0_bff_surface_addendum.md)
   - 仍保留其交易骨架定位
   - 其中“收费/deposit 不进入当前对象”的旧条款，当前只保留为历史阶段语义，不再裁决本轮收费 `L4`

## 13. Stage Conclusion

当前收费 `L4 BFF surface` 正式冻结为：

1. `BFF` 只拥有收费 app-facing shaping 权
2. `BFF` 不拥有任何收费业务真相
3. `BFF` 不拥有任何第二收费状态机
4. 当前唯一 app-facing 收费主链是：
   - `pricing-summary`
   - `200 元项目真实性诚意金`
   - `4000 元竞标服务费预授权额度`
   - `deal-confirmations`
   - 以及与之对接的 `publish / bid participation / bid submit`
5. 下一轮唯一动作固定为：
   - 输出收费 `L5 Flutter consumption` 母文件
