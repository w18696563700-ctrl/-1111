# 《项目详情 currentViewerBid L5 Flutter Consumption Addendum》

## 0. 总裁决

- Flutter 只消费 `currentViewerBid`，不计算当前账号是否已投标。
- `currentViewerBid` 有值时，项目详情不得展示可重复提交入口。
- 竞标提交页直接进入时，也必须锁定为已提交态。

## 1. 页面消费

| 页面 | 行为 |
|---|---|
| 项目详情 | `currentViewerBid != null` 时展示 `进入项目沟通` / `查看我的竞标`，不展示 `立即参与竞标` |
| 竞标提交页 | `currentViewerBid != null` 或 `viewerProjectRelation == bidder` 时按钮显示 `已提交竞标` 且禁用 |
| duplicate 409 | 继续作为兜底，返回后锁定按钮 |

## 2. 兼容

- 字段缺失按 `null` 处理，避免云端部署过渡期破坏未投标入口。
- `public_viewer` / `non_owner` 未投标状态仍保留正常竞标入口。
