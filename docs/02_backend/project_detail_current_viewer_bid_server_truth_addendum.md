# 《项目详情 currentViewerBid L3 Server Truth Addendum》

## 0. 总裁决

- Server 是 `currentViewerBid` 的唯一真相 owner。
- 本轮只增强 `GET /server/projects/{projectId}` / `GET /api/app/project/detail` 对应的只读详情。
- 不改竞标提交、竞标状态机、支付、订单、合同。

## 1. 查询规则

| 项 | 冻结结论 |
|---|---|
| 查询条件 | `project_id = projectId` 且 `coalesce(nullif(bidder_organization_id,''), organization_id) = currentOrganizationId` |
| 返回字段 | `bidId`, `state` |
| 无组织上下文 | `currentViewerBid = null` |
| 无竞标记录 | `currentViewerBid = null` |
| 多记录异常 | 按提交时间倒序 / 创建时间倒序取第一条，同时保留 duplicate 提交兜底 |

## 2. 关系态规则

本轮不改 `viewerProjectRelation` enum：

| 条件 | `viewerProjectRelation` | `currentViewerBid` |
|---|---|---|
| 当前组织为项目 owner | `owner` | `null` |
| 非 owner 且存在当前组织竞标 | `non_owner` | `{ bidId, state }` |
| 非 owner 且无当前组织竞标 | `non_owner` | `null` |

发布方不得通过公域竞标入口继续提交；已投标接单方通过 `currentViewerBid` 导流。

## 3. 测试要求

至少覆盖：

1. 未投标非 owner：`currentViewerBid = null`, `viewerProjectRelation = non_owner`。
2. 已投标非 owner：返回 `currentViewerBid.bidId/state`, `viewerProjectRelation = non_owner`。
3. owner：不混入当前 viewer bid，仍返回 owner-only `bidCandidates`。
4. 其他组织的竞标不可见。
5. `BID_DUPLICATE_SUBMISSION` 提交兜底不变。
