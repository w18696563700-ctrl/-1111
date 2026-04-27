---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the edit-page wording and surface boundary for the standalone
  supplement note block and the re-entry project detail document zone, so the
  edit surface stops overclaiming attachment duties while continuing to reuse
  the existing `project_attachments` truth family.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_and_factory_bid_day2_flow_brief_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/02_backend/project_detail_document_zone_and_public_resource_download_backend_truth_addendum.md
  - docs/02_backend/project_attachment_prepublish_and_bid_materials_backend_truth_addendum.md
  - docs/04_frontend/project_detail_document_zone_and_public_resource_download_frontend_consumption_addendum.md
  - docs/04_frontend/my_project_detail_compact_materials_surface_frontend_addendum.md
  - docs/04_frontend/project_attachment_corridor_runtime_alignment_frontend_truth_note.md
---

# 《编辑页补充说明与文书区收敛冻结单》

## 0. 总结论

Day1 只冻结编辑页这块的正式口径，不授权云上代码修改。

当前更稳的方案：

- 把编辑页拆清楚：`补充说明` 独立；`项目详情文书区` 继续复用同一
  owner-private 正式附件走廊；不让单一模块同时承担文本说明、附件真相和流程解释。

当前更省成本的方案：

- 不新开附件 truth，不改 `project_attachments` / `FileAsset` 链，不新增状态、
  表、路径或云上接口。

当前阶段最适合的方案：

- 先收紧名称、隐藏误导性解释文案、冻结正式卡片的最小展示要求，然后再进入前端收敛或云上核查。

风险更大的方案：

- 让编辑页继续显示 `补充说明与附件` 混合语义，或把编辑页改成第二套附件工作台 /
  第二状态机。

## 1. Scope

本冻结单只覆盖：

1. 编辑页 `补充说明` 区块的正式命名。
2. 编辑页红框说明文案的隐藏边界。
3. 编辑页与 `项目详情文书区` 的关系。
4. 正式附件主真相与正式卡片最小展示要求。

本冻结单不覆盖：

1. 云上 BFF / Server implementation。
2. 新 attachment kind。
3. `施工图 / 其他资料` 是否改名为 `尺寸图 / 材质图`。
4. `prepublish` 新状态或新路径。
5. OSS、DB schema、upload flow 重写。

## 2. 当前最小闭环

当前最小闭环固定为：

1. 编辑页单独展示 `补充说明` 文本区。
2. 编辑页中的正式附件能力继续作为同一 `项目详情文书区` 的 re-entry /
   同源消费面。
3. 正式附件列表只以后端 `project_attachments` 结果为准。
4. 正式卡片至少显示 `fileName` 和 `查看 / 预览` 动作。

## 3. 正式冻结条款

### 3.1 `补充说明` 独立

- 编辑页该区块标题固定为：
  - `补充说明`
- 该区块只承接：
  - 项目背景
  - 协作提醒
  - 现场重点
  - 其他补充文字
- 该区块不得继续命名为：
  - `补充说明与附件`
- 该区块不得同时承接：
  - 附件类型解释
  - 必传 / 选传说明
  - 上传链路说明

### 3.2 红框说明文案隐藏

- 编辑页 `补充说明` 区块下方原解释性 copy 当前统一隐藏。
- 编辑页原 `资料补充` 提示段当前统一隐藏。
- 以上隐藏范围包括但不限于：
  1. 草稿 / 预发布详情承接关系的解释 copy
  2. 必传 / 选传附件说明 copy
  3. `FileAsset` / bind 技术链路说明 copy
- 当前编辑页保留操作，不保留重复的流程解说。

### 3.3 正式附件主真相不变

- 当前项目正式附件的唯一业务真相 carrier 继续固定为：
  - `project_attachments`
- 上传资产真相继续固定为：
  - `FileAsset`
- `upload confirm` 只确认：
  - `FileAsset`
- `objectKey` 不是业务真相。
- 编辑页不得因为展示 `项目详情文书区` 就新开第二附件 truth family。

### 3.4 编辑页与 `项目详情文书区` 的关系

- 编辑页当前允许承接同一 owner-private `项目详情文书区` 的 re-entry / 消费。
- 编辑页中的 `项目详情文书区` 当前语义固定为：
  - 复用既有正式附件走廊
  - 不是新的附件总控台
  - 不是新的预发布详情替代面
  - 不是新的发布确认主面
- 正式发布前的主流程 authority 继续保持：
  1. create / edit = 基础信息 + 补充说明 + 合法 re-entry
  2. 我的项目详情 / 预发布详情 = 正式附件补充与发布前确认主面

### 3.5 `项目详情文书区` 正式卡片最小要求

- `项目详情文书区` 的正式卡片最小必须显示：
  1. `fileName`
  2. `查看` 或 `预览` 入口
- 图片类正式附件：
  - 必须可预览
- 文档类正式附件：
  - 必须可点击查看
- 不允许：
  1. 只有类型标签而无文件名
  2. 上传成功后正式列表无文件名 / 无查看动作，却仍声称“已形成正式附件”

### 3.6 状态与权限边界

- owner 正式附件 corridor 继续固定为：
  - `submitted-or-later`
- 本冻结单不授权把草稿态直接扩成正式附件写入面。
- public detail 与 factory bid side 继续不得获得 owner-private 写能力。
- 工厂只读投影边界本轮不重开。

### 3.7 附件种类边界

- 当前 formal truth 继续沿用：
  1. `effect_image`
  2. `construction_doc`
  3. `other_material`
- 本冻结单不重开：
  1. `施工图 / 其他资料` 是否改名为 `尺寸图 / 材质图`
  2. 新 attachment kind
  3. 新公开资料下载真相

## 4. 需要保留但暂不开通

当前继续保留，但本轮暂不开通：

1. 第二条附件 truth family。
2. 编辑页内第二套附件状态机。
3. 以 `objectKey` 直接充当项目正式附件真相。
4. 草稿态 owner 正式附件写入面。
5. 编辑页直接承担发布确认主面。
6. 附件种类重命名与公开资料下载区重开。

## 5. 后续扩展位

后续如需继续推进，只允许单独冻结以下扩展位：

1. `施工图 / 其他资料` 到 `尺寸图 / 材质图` 的正式命名裁决。
2. 文档类正式附件的查看承载形态：
   - 新窗口
   - WebView
   - 下载后查看
3. 正式卡片的次级信息是否展示：
   - `createdAt`
   - `mimeType`
   - 上传人审计字段
4. 编辑页是否长期保留 `项目详情文书区` re-entry 能力。

## 6. 实施门禁

本冻结单的实施门禁固定为：

1. 未冻结前不动云上代码。
2. 本冻结单只 author L0 SSOT，不直接 author BFF / Server 改动。
3. 若下一阶段进入实现，必须先提交《阶段门禁核查表》。
4. 在未单独放行前，不得把本冻结单解释成：
   - 云上写链核修放行
   - attachment kind 重命名放行
   - 编辑页变成正式发布主面的放行

## 7. Formal Conclusion

当前编辑页正式口径固定为：

1. `补充说明` 独立。
2. 红框说明隐藏。
3. 正式附件主真相继续是 `project_attachments`。
4. 编辑页中的 `项目详情文书区` 继续只是同源 re-entry / 消费面。
5. 正式卡片必须显示文件名，并提供查看 / 预览能力。
