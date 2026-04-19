---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Server Admin contract family for CS-033 historical content rescan without opening app-facing rescan centers or full governance desks.
layer: L2 Contracts
---

# CS-033 存量内容复扫 P2-A Contracts Addendum

## 1. 范围

本文件只冻结 `CS-033` 当前最小 contract：

- `POST /server/admin/governance/rescan-jobs`
- `GET /server/admin/governance/rescan-jobs`
- `GET /server/admin/governance/rescan-jobs/{rescanJobId}`

## 2. 当前包角色

- `Server` 是唯一 rescan truth owner
- `Admin` 只消费 bounded rescan-job family
- `BFF` 不新增 route
- `Flutter` 不新增 route

## 3. 当前创建 contract

`POST /server/admin/governance/rescan-jobs`

当前最小 request 只允许：

- `scopeType`
- `windowStart`
- `windowEnd`
- `reason`
- optional `ruleSetVersion`
- optional `engineMode`

最小 response 必须包含：

- `rescanJobId`
- `status`
- `traceId`

## 4. 当前 list/detail contract

`GET /server/admin/governance/rescan-jobs`

最小响应必须包含：

- `items`
- `pagination`

单个 list item 至少包含：

- `rescanJobId`
- `scopeType`
- `status`
- `candidateCount`
- `createdAt`

`GET /server/admin/governance/rescan-jobs/{rescanJobId}`

最小 detail 响应至少包含：

- `rescanJobId`
- `scopeType`
- `status`
- `windowStart`
- `windowEnd`
- `candidateCount`
- `flaggedCount`
- `createdAt`
- `completedAt`

## 5. 当前 contract 边界

- 当前 contract 只允许 rescan job 级别的最小可见面
- 当前 contract 不得暴露全量历史命中明细中心
- 当前 contract 不得暴露用户侧 read surface
- 当前命中项若需人工处理，只能复用既有 `review task` / `admin review` 基线

## 6. 当前明确不纳入项

- 自动处罚 contract
- penalty / appeal full desk contract
- user-side rescan history contract
- AI runtime gateway contract
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`
- release-prep / launch approval

## 7. Formal Conclusion

当前 `CS-033 P2-A` contract 已冻结。

该冻结只允许后续进入 bounded implementation-unlock judgment authoring，不等于 implementation 已放开。
