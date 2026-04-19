---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded truth adjustment that moves owner-managed project
  attachments forward into prepublish continuation and admits a read-only bid
  materials projection for bid-submit, without creating a second attachment
  carrier, a second lifecycle state machine, or a generic public attachment
  center.
layer: L0 SSOT
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/04_frontend/exhibition_bid_submit_full_version_frontend_surface_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目附件预发布前移与竞标材料只读投影 truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - owner `项目详情文书区`
  - bid-submit 页的项目附件只读投影
  - bid-submit 页的 staged reveal 排布
- 本冻结单不进入：
  - 新生命周期 state
  - 第二附件 carrier
  - 通用 public attachment center
  - Admin 模板中心

## 2. Truth Freeze Conclusion

- 当前 `project_attachments` 继续是唯一合法项目附件业务真值 carrier。
- `file_asset` 继续只承担上传资产真值，不承担项目附件业务真值。
- 当前正式把 owner 附件补充走廊从：
  - `post-publish only`
  调整为：
  - `prepublish-or-later owner continuation`
- 当前允许进入 owner 附件走廊的项目状态固定为：
  - `submitted`
  - `published`
  - `bidding_closed`
  - `awarded`
  - `converted_to_order`
- 当前不允许：
  - `draft` 进入正式附件走廊
  - `archived` 继续补充附件

## 3. Owner Attachment Boundary

- `项目详情文书区` 继续只允许 owner 主体读写。
- `效果图 / 施工图 / 其他资料` 继续复用既有 `project_attachments` carrier。
- 本轮没有新增：
  - 附件主表单预创建 carrier
  - 第二附件列表真值
  - 第二上传确认真值

## 4. Bid Materials Projection

- 当前正式新增一个 bounded bid-side read-only projection：
  - 只服务 `竞标提交`
  - 只读
  - 不可上传
  - 不可删除
- 当前 bid-side 只允许投影：
  - `effect_image`
  - `construction_doc`
- 当前 bid-side 不得投影：
  - `other_material`
- 当前 bid-side 投影来自既有 `project_attachments` 真值过滤，不产生第二附件 carrier。

## 5. Bid Submit Layout Freeze

- `立即参与竞标` 进入后，首屏先只显示：
  - `第一步 核对项目`
- 当前用户点击：
  - `继续竞标`
  之后，才继续显示：
  - 项目附件只读区
  - `第二步 填写报价与方案说明`
  - `第三步 上传必选文档`
- `提交竞标` 不得在首屏核对阶段提前出现。

## 6. Lifecycle Clarification

- 当前 canonical lifecycle 继续保持：
  - `draft -> submitted -> published`
- 本轮不新增：
  - `published -> submitted`
  - `published -> draft`
  - `退回预发布列表`
  的新 canonical transition
- 当前结论只修复：
  - 附件补充时机
  - bid-submit 只读附件承接
- 当前不把“竞标中退回预发布列表”误写成已经存在的 lifecycle truth。

## 7. Superseded Slice

- [project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md)
  中关于：
  - `post-publish materials supplement`
  - owner 附件只在已发布后开放
  的条款，
  当前仅在本对象范围内被本冻结单取代。

## 8. Formal Conclusion

- 当前正式冻结为：
  - owner 附件可在 `submitted` 开始补充
  - bid-submit 可读取 `effect_image / construction_doc` 的只读投影
  - bid-submit 采用先核对、后展开的 staged reveal
