# 《项目详情 currentViewerBid 入口防重复提交真相冻结》

## 0. 总裁决

- 当前 bug：已提交竞标后，重新从项目列表 / 项目详情进入时，Flutter 只依赖页面内 `_bidAlreadySubmitted`，新页面实例会重新开放提交入口。
- 本轮目标：在 `project/detail` 只读详情中补最小当前账号竞标摘要，提前关闭重复提交入口。
- 当前是否允许改支付 / 订单 / 合同：No-Go。
- 当前是否允许改竞标提交状态机：No-Go。
- 当前是否允许增强项目详情只读投影：Go。

## 1. 真相来源

| 项 | 冻结结论 |
|---|---|
| 当前账号是否已投标 | Server 唯一真相 |
| 查询维度 | `projectId + currentOrganizationId` |
| 组织维度 | 使用当前登录组织，不使用个人账号作为竞标归属 |
| BFF 职责 | 只读投影 / 字段整形，不查询竞标表，不自行推断 |
| Flutter 职责 | 展示、导流、关闭重复提交入口，不计算竞标归属 |

## 2. 最小字段

`ProjectReadModel` 新增可空字段：

```json
{
  "currentViewerBid": {
    "bidId": "bid-xxx",
    "state": "submitted"
  }
}
```

- `currentViewerBid = null`：当前账号组织尚未对该项目提交竞标，或当前无有效组织上下文。
- `currentViewerBid.bidId`：当前账号组织在该项目下的竞标 ID。
- `currentViewerBid.state`：当前竞标的最小状态字符串，只用于导流和入口关闭，不扩成竞标详情。
- `viewerProjectRelation`：本轮保持既有 `owner / non_owner` 口径，不扩 enum；是否已投标只看 `currentViewerBid`。

## 3. 边界

本轮做：

1. Server 在项目详情中返回 `currentViewerBid`。
2. BFF 透传 `currentViewerBid`。
3. Flutter 项目详情和竞标提交页消费 `currentViewerBid`。
4. 保留 `BID_DUPLICATE_SUBMISSION` 作为提交接口兜底。

本轮不做：

1. 不新增竞标详情工作台。
2. 不新增竞标报价历史。
3. 不改竞标提交接口语义。
4. 不改支付、平台服务费、预授权。
5. 不改定标、订单、合同状态机。
6. 不把 BFF 或 Flutter 变成竞标归属真相 owner。

## 4. 门禁

| 阶段 | 是否允许进入 | blocker |
|---|---:|---|
| L2 Contracts | 是 | 只允许最小 `currentViewerBid` 字段 |
| Server 实现 | 是 | 必须只读查询且组织隔离 |
| BFF 实现 | 是 | 必须只读透传 |
| Flutter 实现 | 是 | 必须兼容字段缺失为未投标 |
| 云端联调 | 条件允许 | 需云上部署对应 BFF / Server |
