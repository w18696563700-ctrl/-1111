---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Server truth and persistence boundary for the exhibition
  bid-submit full version so the required attachment slots, confirmed
  FileAsset references, and template catalog reuse are all backed by one
  backend truth owner without reintroducing fee or seat-count truth.
layer: L3 Backend truth specs
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/00_ssot/exhibition_bid_submit_full_version_truth_freeze_addendum.md
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/db_schema.md
---

# 《竞标提交页满分版 backend truth freeze》

## 1. Scope

- 本文件只覆盖：
  - `竞标提交页` 的 Server truth
  - submit 命令的 persistence boundary
  - 模板下载目录 truth
- 本文件不进入：
  - migration
  - Flutter implementation
  - BFF implementation
  - seat console truth
  - completeness workspace truth

## 2. Truth Owner

- 当前唯一 truth owner 固定为：
  - `Server`
- `BFF` 不得拥有业务真值。
- Flutter 不得拥有业务真值。

## 3. Bid Submit Truth Carrier

- 当前 `bid submit` 的 canonical truth carrier 固定为：
  - `bids`
- `bids` 至少需要承接以下提交真值：
  - `projectId`
  - `quoteAmount`
  - `proposalSummary`
  - `projectUnderstandingFileAssetId`
  - `quoteSheetFileAssetId`
  - `schedulePlanFileAssetId`
  - `submittedAt`
- 以上 3 个附件槽位只允许引用：
  - confirmed `FileAsset`
- `objectKey` 继续只属于存储层，不属于业务 truth。

## 4. Attachment Slot Truth

- 3 个附件槽位是固定业务语义，不是自由上传池。
- 三个槽位必须分别对应：
  - `项目理解`
  - `报价表`
  - `进度安排`
- 槽位绑定必须满足：
  - confirmed FileAsset
  - 同一槽位只能保留当前有效 truth
  - 上传成功但未 confirm 的数据不得写入 `bids`

## 5. Upload Truth Boundary

- `POST /api/app/file/upload/init`
  只负责生成上传会话。
- `POST /api/app/file/upload/confirm`
  只负责冻结 confirmed `FileAsset`。
- upload confirm 不得直接替代 bid submit truth。
- bid submit 不得把 upload session 误当成最终附件真值。

## 6. Template Catalog Truth

- 当前模板下载区的 Server truth 继续沿用：
  - `project_public_resources`
- 当前模板目录只负责：
  - 模板标题
  - 分类
  - fileAssetId
  - publishedAt
- 当前模板目录不得替代：
  - `bids`
  - `file_assets`
  - `project_attachments`
- 当前 page 使用的模板语义固定为：
  - `项目理解模板`
  - `报价表模板`
  - `进度安排模板`

## 7. Seat / Completeness Retire-from-Page Decision

- 当前 submit page 不再把 seat 数量限制、seat 状态或 completeness 状态作为 truth 展示。
- 这不等于删除历史 canonical truth。
- 这只表示：
  - 当前 submit page 的消费面已经退役
  - 旧 truth 不再是当前 submit page 的主链

## 8. No Fee / No Seat Limit Decision

- 当前 Server truth 冻结为：
  - 不设置席位数量限制
  - 不收报名费
  - 不收占位费
- 当前 Server 不得再把这轮 submit page 写成收费占位页。

## 9. Formal Conclusion

- 当前 backend truth 的正式结论固定为：
  - `bids` 承接 3 个 confirmed FileAsset slot + quote/proposal
  - `project_public_resources` 承接模板下载目录 truth
  - `file_assets` 承接文件资产真值
  - `objectKey` 只做存储位置，不做业务 truth

## 10. Duplicate Submit Truth Freeze

- `2026-04-15` 残余缺陷修复后，`Server` 额外冻结以下真相：
  - `bid_no` 必须是 `bid instance` 唯一编号
  - 不得再把 `bid_no` 退化为 `project_no` 的镜像编号
  - `同一 organization + 同一 project` 当前只允许存在一条活动 `bid`
- 这条规则必须以显式业务约束表达：
  - 先做业务侧重复提交判定
  - 再由持久层唯一约束兜底并回写受控冲突
- `Server` 对该场景的 canonical 错误冻结为：
  - `HTTP 409`
  - `code = BID_DUPLICATE_SUBMISSION`
  - message:
    - `Current actor has already submitted a bid for this project.`
- 当前冻结结论只关闭：
  - `same organization + same project` 重复提交误暴露 `500`
- 当前明确不开放：
  - bid 修改 / 撤回 / 覆盖提交
  - production release
