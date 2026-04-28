---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day1 truth and page-surface boundary for the owner-facing
  exhibition project edit page, including verified state source, action source,
  form-cluster boundary, return-path rule, and the allowed collapsed-vs-open
  rendering strategy before any frontend implementation round.
layer: L0 SSOT
freeze_date_local: 2026-04-28
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_day3_create_page_revision_brief_addendum.md
  - docs/00_ssot/project_edit_supplement_and_document_zone_convergence_freeze_addendum.md
  - docs/00_ssot/publisher_project_detail_information_density_optimization_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md
  - docs/04_frontend/project_publish_prepublish_relabel_and_confirmation_frontend_consumption_addendum.md
  - docs/04_frontend/publisher_project_detail_information_density_optimization_frontend_surface_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart
  - apps/mobile/lib/shell/presentation/app_shell_scaffold.dart
---

# 《编辑项目页 Day1 真相冻结与页面口径冻结单》

## 0. 总结论

本 Day1 只冻结 `编辑项目` 页真相与页面口径，不授权 BFF / Server / contracts 改动。

当前更稳的方案：

- 保持 `draft -> submitted -> published` canonical lifecycle 不变。
- `submitted` 继续只是 canonical `submitted`，用户侧显示为 `预发布列表`。
- `编辑项目` 页继续只是 `create / edit` 的核对与补录面，不抢 `我的项目 -> 预发布列表 -> 单项目详情` 的正式发布确认 authority。

当前更省成本的方案：

- 只改 Flutter 页面结构、折叠状态、按钮位置和回流承接。
- 不改接口、不改状态机、不改附件真相、不改上传链路。

当前阶段最适合的方案：

- 把编辑页从“整页长表单”收成“生命周期卡 + 当前内容核对区 + 报价依据资料主任务区”的核对流。

风险更大的方案：

- 前端本地发明 `prepublish` 新状态。
- 让编辑页直接承担最终发布确认主面。
- 把报价依据资料、发布确认、附件真相和大表单继续混成一个长页。

## 1. Scope

本冻结单只覆盖：

1. 编辑页状态来源核对。
2. 编辑页顶部按钮和生命周期按钮来源核对。
3. 编辑页表单区边界核对。
4. 编辑页返回路径规则核对。
5. `哪些折叠 / 哪些保留展开` 的前端页面口径冻结。

本冻结单不覆盖：

1. BFF / Server / DB / OSS 改动。
2. 新 lifecycle state。
3. 新 `prepublish` path family。
4. 新附件种类或附件权限真相。
5. 正式实现代码。

## 2. 真相冻结回执

### 2.1 状态来源

代码核对结论固定为：

1. 编辑页 edit-mode 由 `ProjectCreatePage(projectId)` 触发。
2. 编辑页真值读取固定来自：
   - `ExhibitionConsumerLayer.instance.loadProjectEditDetail(projectId: ...)`
3. 当前状态固定来自 edit-detail payload 的 `state` 字段。
4. 用户侧状态名称固定通过 `_frontStageStateLabel` 投影：
   - `draft => 草稿`
   - `submitted => 预发布列表`
   - `published => 竞标中`
5. 前端不得在编辑页本地发明第二套 `prepublish` raw state。

### 2.2 按钮来源

代码核对结论固定为：

1. 编辑页顶部标题当前是：
   - `编辑项目`
2. 生命周期动作按钮固定来自 `_buildLifecycleActionButtons(...)`。
3. `submitted` 态当前既有动作固定为：
   - `返回预发布列表详情`
   - `继续核对当前内容`
4. 其中：
   - `返回预发布列表详情` 当前走 `_openMyProjectDetail(projectId)`
   - `继续核对当前内容` 当前走 `_scrollToField(_ProjectCreateFieldId.title)`
5. `编辑项目` 页不得直出最终发布按钮。

### 2.3 表单区边界

代码核对结论固定为：

1. 当前内容核对区的字段边界固定为：
   - `基础信息`
   - `项目地点与范围`
   - `计划时间`
   - `补充说明`
2. 上述 4 块当前复用同一套 create/edit 表单控制器和字段真值。
3. `报价依据资料` 不属于上述 4 块表单字段族。
4. `报价依据资料` 继续复用 owner-private `project_attachments` truth family。

### 2.4 返回路径

代码核对结论固定为：

1. 页面左上返回键继续遵守壳层通用规则：
   - `Navigator.pop`
   - 只返回上一层 route
   - 不做固定重定向
2. 编辑页中的正式回流出口固定使用显式动作按钮，不依赖左上返回键替代业务出口。
3. `submitted` 态的正式业务回流出口固定为：
   - `返回预发布列表详情`
   - 目标：`我的项目详情 / 预发布详情`

## 3. 页面口径冻结

### 3.1 页面职责

编辑页当前正式职责固定为：

1. 核对当前项目基础信息。
2. 补录或修正当前项目内容。
3. 在合法状态下进入报价依据资料补充区。
4. 回流到 `预发布列表详情` 继续正式发布确认。

编辑页当前不得承担：

1. 最终发布确认主面。
2. 新 lifecycle 主控台。
3. 新附件工作台真相。
4. BFF / Server truth 补丁面。

### 3.2 顶部状态展示

正式冻结为：

1. 页面标题继续固定为：
   - `编辑项目`
2. 当前状态应上移到标题区右侧，以高层级状态标识呈现。
3. 生命周期卡内部不再重复展示一条独立的：
   - `当前状态：预发布列表`
4. 生命周期卡正文只保留：
   - 当前还能做什么
   - 下一步去哪里
   - 动作按钮

### 3.3 折叠与展开规则

当前正式冻结为：

1. `当前生命周期` 卡：
   - 默认展开
   - 保留在首屏
2. `报价依据资料` 区：
   - 默认展开
   - 保持为当前阶段主任务区
3. 以下 4 块改为同一个 `当前内容核对区`：
   - `基础信息`
   - `项目地点与范围`
   - `计划时间`
   - `补充说明`
4. `当前内容核对区` 在以下状态默认折叠：
   - `submitted`
   - `published`
   - `bidding_closed`
   - `awarded`
   - `converted_to_order`
5. `当前内容核对区` 在以下状态默认展开：
   - `draft`
6. 折叠态只保留摘要，不删除任何字段真值或编辑能力。
7. 展开动作只展开当前内容核对区，不影响 `当前生命周期` 和 `报价依据资料` 区。

### 3.4 折叠摘要最小字段

为保证低风险和纯前端可实现，折叠摘要最小字段固定为：

1. 展会
2. 品牌
3. 省 / 市
4. 计划时间
5. 预算金额或项目面积中的现有值

摘要字段必须直接复用当前页面已加载字段，不新增接口字段。

### 3.5 顶部与底部收口

正式冻结为：

1. 顶部 `继续核对当前内容`：
   - 必须真正对应下方核对区
   - 折叠时点击后应展开
   - 展开后应滚动到核对区起点
2. 顶部 `返回预发布列表详情`：
   - 继续保留
   - 作为正式业务回流出口
3. 页面底部补一次同类收口动作：
   - `信息核对无误，返回预发布列表详情`
4. 底部收口与顶部回流动作必须复用同一目标，不得新开第二返回分支。

## 4. 当前最小闭环

当前最小闭环固定为：

1. 编辑页首屏先看 `当前生命周期`。
2. `submitted-or-later` 用户优先进入 `报价依据资料` 主任务区。
3. 如需回看已保存内容，再展开 `当前内容核对区`。
4. 核对完成后，直接从顶部或底部回到 `预发布列表详情`。
5. 最终发布确认继续只在 `我的项目 -> 预发布列表 -> 单项目详情` 完成。

## 5. 需要保留但暂不开通

本轮继续保留但暂不开通：

1. 编辑页直接发布。
2. 编辑页新状态机。
3. 编辑页新 attachment truth family。
4. 折叠区字段 diff 高亮。
5. 字段级修改痕迹审计展示。
6. 吸底操作栏。

## 6. 后续扩展位

后续如要继续推进，只允许单独冻结：

1. 折叠摘要是否加入 `项目编号`。
2. 折叠区是否记忆上次展开状态。
3. 底部收口是否升级为吸底操作栏。
4. 编辑页与我的项目详情之间的长期同构策略。

## 7. 验收清单

### 7.1 结构冻结单

- [x] 已核对编辑页状态来源。
- [x] 已核对生命周期按钮来源。
- [x] 已核对表单区边界。
- [x] 已核对左上返回与业务回流出口的区别。
- [x] 已冻结 `哪些折叠 / 哪些展开`。
- [x] 已确认本轮只做前端结构调整，不改 BFF / Server。

### 7.2 实施验收清单

后续进入 Flutter 实现时，必须逐项满足：

1. 标题栏右侧显示当前状态。
2. 生命周期卡内部不再重复 `当前状态` 行。
3. `当前内容核对区` 成为单一折叠区。
4. `submitted-or-later` 默认折叠。
5. `draft` 默认展开。
6. `继续核对当前内容` 能展开并滚动到核对区。
7. `报价依据资料` 保持默认展开。
8. 页面底部出现 `信息核对无误，返回预发布列表详情`。
9. 不改 create / save / submit / publish / withdraw / archive 接口。
10. 不改 `project_attachments` / `FileAsset` / upload flow truth。

## 8. 阶段门禁核查表

已通过门禁：

1. 真源门禁：先看 docs，再看 code，未跳过真源冻结。
2. 架构边界门禁：未改 One shell / five buildings，未改 Flutter -> BFF 边界。
3. 契约门禁：未新增 path、field、query、schema。
4. 状态机门禁：未新增 canonical state，未本地发明 `prepublish` raw state。
5. 前端体验门禁：未以假成功掩盖真实状态，明确区分左上返回与业务回流按钮。
6. 阶段控制门禁：本轮目标单一，只冻结编辑页真相与页面口径。

未通过门禁：

1. L5 frontend surface 文书尚未单独 author。
2. Flutter 实现尚未开始。
3. 结果校验 / Computer Use 联调尚未开始。

一票否决门禁：

1. 若后续实现改动 BFF / Server，直接 No-Go。
2. 若后续实现新增 `prepublish` state 或 path，直接 No-Go。
3. 若后续实现让编辑页直接承担最终发布确认，直接 No-Go。
4. 若后续实现更改附件真相或上传链路，直接 No-Go。

下一阶段结论：

- `Go`：进入 L5 frontend surface authoring 或 Flutter 前端实现拆单。
- `No-Go`：进入 BFF / Server。
- `No-Go`：绕过本冻结单直接重构长页。

## 9. Formal Conclusion

当前 `编辑项目` 页 Day1 正式冻结为：

1. 状态真相继续来自 edit-detail payload 的 canonical `state`。
2. 正式发布确认面继续留在 `我的项目 -> 预发布列表 -> 单项目详情`。
3. 编辑页只承接 `生命周期卡 + 当前内容核对区 + 报价依据资料主任务区`。
4. `submitted-or-later` 的当前内容核对区默认折叠，`draft` 默认展开。
5. 顶部与底部都必须提供回到 `预发布列表详情` 的收口动作。
