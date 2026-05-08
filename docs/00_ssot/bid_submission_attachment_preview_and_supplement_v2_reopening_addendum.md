# 竞标摘要附件预览下载与竞标资料补充 V2 Reopening Addendum

## 总裁决

本文件冻结一个小型 reopening：竞标摘要三附件需要支持 App 内预览与下载；竞标资料被发布方标记为 `needs_supplement` 后，竞标方必须能从资料确认详情直达对应槽位补充资料，并由 Server 将该资料项回到 `pending_review`。

本轮不是重新设计竞标系统，不引入合同金额、支付、服务费扣费、钱包、发票、结算、Admin 或通用 IM。

## 当前最小闭环

1. `GET /api/app/file/access` 继续作为附件访问唯一 App-facing 路径，支持 `mode=preview` 与 `mode=download`。
2. 竞标摘要三附件仍以 `Bid.projectUnderstandingFileAssetId`、`Bid.quoteSheetFileAssetId`、`Bid.schedulePlanFileAssetId` 作为 FileAsset 真相。
3. `POST /api/app/bid/submit` 只表示首次竞标提交，不承接补资料语义。
4. 新增 `POST /api/app/bid/submission/supplement` 作为既有 Bid 的补资料命令。
5. 补资料只允许在对应 `bid_materials` 资料确认项处于 `needs_supplement` 时执行。
6. 补资料成功后，Server 将对应 material review 回到 `pending_review`，并发出消息楼业务事件提醒发布方重新确认。

## 字段与状态边界

补资料命令必须包含：

- `projectId`
- `bidId`
- `entryKey`
- `sourceVersionToken`
- `quoteAmount`
- `proposalSummary`
- `projectUnderstandingFileAssetId`
- `quoteSheetFileAssetId`
- `schedulePlanFileAssetId`
- 可选 `bidMaterialSlot`

`entryKey` 仅允许：

- `bid_project_understanding_review`
- `bid_quote_sheet_review`
- `bid_schedule_plan_review`

`bidMaterialSlot` 仅允许：

- `project_understanding`
- `quote_sheet`
- `schedule_plan`

## 权责边界

- Server 是 Bid、FileAsset、MaterialReview、状态回退、审计和业务事件真相。
- BFF 只转发和做错误映射，不拥有补资料状态。
- Flutter 只负责展示、槽位聚焦、调用补资料命令和刷新 workbench。
- `objectKey` 不允许暴露给 Flutter，也不允许成为附件展示真相。
- 资料确认底部弹层已经是目标交互，本轮只做回归保护，不重新设计。

## 禁止项

- 不把竞标附件并入项目附件业务真相。
- 不把补资料伪装成二次首次竞标。
- 不把报价金额改成最终合同金额。
- 不触碰支付、服务费扣费、钱包、发票、结算、Admin、APNs、信用约束。
- 不新增通用附件访问路径。

## 通过标准

- 竞标摘要三附件可通过 preview/download 获取短期 `accessUrl`。
- 任一竞标资料项 `needs_supplement` 时，竞标方能直达对应槽位。
- 补资料写入由 Server 校验竞标方身份、Bid 归属、FileAsset 归属、review 状态与 `sourceVersionToken`。
- 补资料成功后，发布方 workbench 重新看到待确认。
