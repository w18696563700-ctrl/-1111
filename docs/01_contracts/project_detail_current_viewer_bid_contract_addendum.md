# 《项目详情 currentViewerBid L2 Contracts Addendum》

## 0. 总裁决

- 本轮允许在 `GET /api/app/project/detail` 的 `ProjectReadModel` 增加最小只读字段。
- 字段 owner：Server。
- BFF：只读投影。
- Flutter：只读消费。
- 不新增命令字段，不允许 Flutter 传入 `currentViewerBid`。

## 1. 字段冻结

### 1.1 ProjectCurrentViewerBid

| 字段 | 类型 | 是否必填 | owner | 说明 |
|---|---|---:|---|---|
| `bidId` | string | 是 | Server | 当前登录组织在该项目下的竞标 ID |
| `state` | string | 是 | Server | 当前竞标最小状态 |

### 1.2 ProjectReadModel.currentViewerBid

| 字段 | 类型 | 是否必填 | 语义 |
|---|---|---:|---|
| `currentViewerBid` | `ProjectCurrentViewerBid \| null` | 否 | 有值表示当前账号组织已提交竞标；`null` 或缺失表示未投标 / 旧版本兼容 |

### 1.3 ProjectViewerRelation

本轮不扩展 `ProjectViewerRelation` enum，继续保持：

- `owner`
- `non_owner`

已投标关系不再塞入 `viewerProjectRelation`，只由 `currentViewerBid` 表达。

## 2. 禁止项

1. 不把 `currentViewerBid` 扩成竞标详情。
2. 不在项目列表增加该字段。
3. 不让 BFF 本地查询竞标归属。
4. 不让 Flutter 传入或修改该字段。
5. 不改 `POST /api/app/bid/submit` 成功体。

## 3. 兼容口径

- 部署过渡期 Flutter 必须把字段缺失视为 `null`。
- BFF 新版本应在 Server 缺字段时输出 `null`，不得生成假 `bidId`。
- Server 新版本应在无登录组织或无竞标记录时输出 `null`。
