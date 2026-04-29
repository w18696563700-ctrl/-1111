# 申请参与竞标 Phase 1 L2 Contracts 冻结单

## Pricing Override Note

自 `2026-04-29` 起，若项目已接入
[platform_pricing_contracts_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/platform_pricing_contracts_master_v1.md)
定义的收费主线，则本文件中关于 `approved -> 直接进入 bid_submit` 的旧 handoff 语义只保留为历史最小闭环参考。

当前收费主线下：

1. `approved` 只代表竞标准入通过
2. 若 `4000 元竞标服务费预授权额度` 尚未冻结，approved 后首个 CTA 必须先进入 `bid-service-fee-authorization`
3. 只有 `authorizationStatus = frozen` 时，才允许 `bid_submit.open`

## 0. 总裁决

- 当前是否允许新增 app-facing contract：Go
- 当前是否允许前端传最终审批状态：No-Go
- 当前是否允许 BFF 判断业务真相：No-Go
- 当前是否允许继续暴露独立名称申请用户入口：No-Go

## 1. App-facing routes

| Method | Path | 说明 |
|---|---|---|
| `POST` | `/api/app/project/bid-participation/request` | 竞标方创建参与申请 |
| `GET` | `/api/app/project/bid-participation/thread/detail` | 申请详情/审批承接页 |
| `GET` | `/api/app/my/projects/{projectId}/bid-participation/pending` | 发布方读取待审申请 |
| `POST` | `/api/app/my/projects/{projectId}/bid-participation/{requestId}/approve` | 发布方通过 |
| `POST` | `/api/app/my/projects/{projectId}/bid-participation/{requestId}/reject` | 发布方拒绝 |

## 2. Server routes

| Method | Path | 说明 |
|---|---|---|
| `POST` | `/server/projects/bid-participation/request` | 创建申请真值 |
| `GET` | `/server/projects/bid-participation/thread/detail` | 读取申请详情 |
| `GET` | `/server/my/projects/{projectId}/bid-participation/pending` | 发布方待审列表 |
| `POST` | `/server/my/projects/{projectId}/bid-participation/{requestId}/approve` | 审批通过 |
| `POST` | `/server/my/projects/{projectId}/bid-participation/{requestId}/reject` | 审批拒绝 |

## 3. Request / response

### 3.1 创建申请

Request:

```json
{
  "projectId": "project-id"
}
```

Response `202`:

```json
{
  "requestId": "request-id",
  "projectId": "project-id",
  "status": "pending",
  "threadId": "request-id"
}
```

### 3.2 审批结果

Response `202`:

```json
{
  "requestId": "request-id",
  "projectId": "project-id",
  "status": "approved"
}
```

`status` 只允许 `approved / rejected`。

### 3.3 详情页

```json
{
  "threadId": "request-id",
  "threadType": "bid_participation_review",
  "projectId": "project-id",
  "requestId": "request-id",
  "requestStatus": "pending",
  "displayTitle": "项目名称需申请查看",
  "requesterOrganization": {
    "organizationId": "org-id",
    "displayName": "申请方主体",
    "avatarUrl": null
  },
  "items": [],
  "primaryReviewAction": {
    "actionKey": "bid_participation.review",
    "enabled": true,
    "availableDecisions": ["approve", "reject"]
  }
}
```

## 4. Counterpart conversation 扩展

新增允许：

| 字段 | 新值 |
|---|---|
| `cardType` | `bid_participation_request` |
| `truthType` | `bid_participation_request` |
| review action | `bid_participation_request.open` |
| approved CTA action | `bid_submit.open` |

旧最小闭环下，`approved` 时竞标方消息卡的 `detailRouteTarget` 可直达：

```json
{
  "objectType": "bid_submit",
  "actionKey": "bid_submit.open",
  "canonicalPath": "/api/app/bid/submit",
  "params": {
    "projectId": "project-id"
  }
}
```

当前收费主线下，也允许先返回：

```json
{
  "objectType": "bid_service_fee_authorization",
  "actionKey": "bid_service_fee_authorization.open",
  "canonicalPath": "/api/app/project/{projectId}/bid-service-fee-authorizations",
  "params": {
    "projectId": "project-id",
    "requestId": "request-id"
  }
}
```

## 5. 错误码

| code | HTTP | 说明 |
|---|---:|---|
| `BID_PARTICIPATION_INVALID` | 400 | 参数错误 |
| `AUTH_SESSION_INVALID` | 401 | 登录态无效 |
| `BID_PARTICIPATION_FORBIDDEN` | 403 | 主体无权限 |
| `BID_PARTICIPATION_UNAVAILABLE` | 404 | 项目或申请不可用 |
| `BID_PARTICIPATION_CONFLICT` | 409 | 已存在 pending/approved |
| `BID_PARTICIPATION_INVALID_STATE` | 409 | 当前状态不允许操作 |
| `BID_PARTICIPATION_REQUIRED` | 403 | 未通过参与申请，不能读取资料或提交竞标 |

## 6. 字段 owner

| 字段 | owner |
|---|---|
| `status/requestStatus` | Server |
| `displayTitle/titleVisibility` | Server |
| `decisionAvailability` | Server |
| `detailRouteTarget` | Server 产出，BFF 校验整形 |
| `routeLocation` | Flutter 本地路由注册表派生 |

## 7. 阶段门禁

| 门禁 | 结论 |
|---|---|
| Contracts 字段冻结 | Pass |
| BFF 本地判断状态 | No-Go |
| Flutter 传最终状态 | No-Go |
| 进入 L3 Server Truth | Allow |
