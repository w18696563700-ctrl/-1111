# 项目沟通预授权入口投影 Gate Addendum

状态：Frozen

冻结日期：2026-05-09

## 1. 总裁决

当 Server 已判定项目沟通进入 `service_fee_authorization_pending`，且当前查看方是竞标方组织时，消息楼必须承接一个可打开的 `bid_service_fee_authorization.open` 入口。

该入口只表示“进入竞标服务费预授权处理页”的导航投影，不表示预授权已创建、已冻结、已支付或已扣款。

## 2. 数据表达

本轮采用既有 `bid_participation_request` 业务卡的 `detailRouteTarget` 承载入口：

- `detailRouteTarget.objectType = bid_service_fee_authorization`
- `detailRouteTarget.actionKey = bid_service_fee_authorization.open`
- `detailRouteTarget.canonicalPath = /api/app/project/{projectId}/bid-service-fee-authorizations`
- `detailRouteTarget.params.projectId` 必填
- `detailRouteTarget.params.bidParticipationRequestId` 必填
- `detailRouteTarget.params.bidId` 可选

不新增独立 `bid_service_fee_authorization` cardType，避免把消息楼 business card 扩成支付业务卡中心。

## 3. 分层边界

Server 负责：

- 判断 `complete_service_fee_authorization` 是否成立。
- 只给竞标方组织在既有 `bid_participation_request` 卡上投影可执行预授权入口。
- 发布方只看到等待状态，不得到可执行预授权入口。
- 查找 approved `BidParticipationRequest`，并生成 routeTarget 参数。

BFF 负责：

- 按合同校验并透传 `bid_service_fee_authorization` 卡片。
- 不计算预授权状态。
- 不伪装上游 routeTarget。

Flutter 负责：

- 按 Server/BFF 返回的 `detailRouteTarget` 打开入口。
- 入口缺失时保留受控提示。
- 不反推 `bidParticipationRequestId`，不本地判断支付真值。

## 4. No-Go

本 Addendum 不解锁：

- 真实支付宝 / 微信预授权写入 smoke。
- `freeze-init` 调用。
- 支付 callback。
- 预授权状态机重构。
- 泛 IM / 私信 / 群聊。
- BFF 或 Flutter 自行判断支付业务真值。
