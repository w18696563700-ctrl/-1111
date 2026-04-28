# 《项目详情 currentViewerBid L4 BFF Surface Addendum》

## 0. 总裁决

- BFF 不拥有竞标归属真相。
- BFF 只把 Server 返回的 `currentViewerBid` 投影给 Flutter。
- Server 缺字段时，BFF 输出 `currentViewerBid = null`，不得自行查询或伪造。

## 1. 投影字段

| 字段 | 来源 | BFF 行为 |
|---|---|---|
| `currentViewerBid.bidId` | Server | 透传非空字符串 |
| `currentViewerBid.state` | Server | 透传非空字符串 |
| `viewerProjectRelation` | Server | 保持既有 `owner / non_owner` 校验并透传 |

## 2. 禁止项

1. BFF 不查询 `bids` 表。
2. BFF 不根据 `viewerProjectRelation` 反推 bidId。
3. BFF 不生成假 `currentViewerBid`。
4. BFF 不改变 `POST /api/app/bid/submit` 语义。
