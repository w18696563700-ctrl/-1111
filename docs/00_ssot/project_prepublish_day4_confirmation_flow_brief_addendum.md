---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day4 prepublish-detail confirmation brief for the owner-private
  submitted project surface, defining the formal publish confirmation flow while
  reusing the existing `submitted = 预发布列表` state and existing publish,
  withdraw, and archive actions.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_and_factory_bid_day2_flow_brief_addendum.md
  - docs/00_ssot/project_create_day3_create_page_revision_brief_addendum.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/01_contracts/project_publish_prepublish_relabel_and_confirmation_contract_freeze_addendum.md
  - docs/04_frontend/project_publish_prepublish_relabel_and_confirmation_frontend_consumption_addendum.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - docs/00_ssot/my_project_lifecycle_correction_ruling_addendum.md
  - docs/01_contracts/my_project_lifecycle_correction_contract_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart
---

# 《Day4 预发布确认稿：预发布详情正式发布确认流程》

## 0. 总结论

Day4 只冻结预发布详情确认流程，不授权代码实现。

当前更稳的方案：

- 只使用现有 `submitted = 预发布列表`，在 owner-private 预发布详情里完成正式发布确认。

当前更省成本的方案：

- 复用现有 `publish / withdraw / archive` action family，不新增 BFF / Server 路径。

当前阶段最适合的方案：

- 把正式发布确认从创建页剥离到预发布详情，形成“核对信息 -> 补充文书 -> 二次确认 -> publish”的清晰闭环。

风险更大的方案：

- 新增 `prepublish / prepublished` 状态，或在创建页、附件区、支付区同时放最终发布动作，造成多个发布确认主面互相竞争。

## 1. Day4 Scope

本文件只覆盖：

1. `我的项目 -> 我的发布 -> 预发布列表 -> 单项目详情`。
2. `submitted` 项目的正式发布确认流程。
3. `返回草稿继续编辑` 与 `作废归档` 的确认流程。
4. 项目详情文书区在发布前核对中的位置。

本文件不覆盖：

1. 普通创建接口。
2. 新 lifecycle state。
3. 新 app-facing path。
4. P0-Pay 支付或 trade-task 创建。
5. 工厂竞标提交。
6. BFF / Server 实现。

## 2. 入口与状态

唯一正式入口：

```text
我的项目 -> 我的发布 -> 预发布列表 -> 单项目详情
```

入口状态：

- 只允许 canonical `submitted`。

用户侧命名：

- `submitted` -> `预发布列表`。

当前不得新增：

1. `prepublish`
2. `prepublished`
3. `publish_review`
4. `confirming_publish`
5. `cancelled`
6. `invalid`
7. `withdrawn_project`
8. `offline`
9. `unpublished`
10. `closed_project`

## 3. 预发布详情页面结构

预发布详情页面固定为以下结构。

### 3.1 顶部摘要

顶部摘要展示：

1. 当前阶段：`预发布列表`。
2. 下一步：`补充项目详情文书，检查无误后正式发布`。
3. 关键后果提示：
   - 发布后进入公域项目详情。
   - 工厂可查看公开项目并参与竞标。
   - 发布后不能直接删除。
   - 如需退出公域，后续走下架关闭。

### 3.2 基础信息核对

基础信息核对展示：

1. `展会`
2. `品牌`
3. `项目类型`
4. `预算金额`
5. `项目面积`
6. `地点`
7. `计划时间`
8. `范围说明`
9. `补充说明`

核对规则：

- 该区只消费既有 project detail / my project detail read model。
- 不新增 readiness API。
- 不用 Flutter 本地伪造 Server 审核结论。

### 3.3 项目详情文书区

项目详情文书区展示：

1. `效果图`
2. `施工图`
3. `其他资料`

附件规则：

- owner 可在 `submitted` 补充正式附件。
- 上传仍必须 `init -> direct upload -> confirm -> bind`。
- confirmed `FileAsset` 不等于已形成项目附件。
- bind 成功后的 `project_attachments` 才是项目附件业务真相。

### 3.4 发布前确认区

发布前确认区展示三项核对：

1. `基础信息已核对`
2. `项目详情文书已补充或确认暂不补充`
3. `已知发布后将进入公域竞标阶段`

这三项只作为 UI 确认提示，不作为新 Server readiness truth。

若未来要把这些核对持久化，必须先补 contract，不得从 Flutter 本地写入。

## 4. 正式发布确认流程

正式发布主按钮：

```text
检查无误，确定发布
```

点击后弹出确认面。

确认标题：

```text
检查无误，确定发布
```

确认正文：

```text
确认后，项目将从预发布列表进入公域项目详情，工厂可以查看公开信息并参与竞标。发布后不能直接删除；如需退出公域，后续请走下架关闭。
```

确认按钮：

```text
确认发布
```

取消按钮：

```text
继续核对
```

确认后调用 existing action：

```text
POST /api/app/project/publish
```

BFF 继续转发到 existing Server path：

```text
POST /server/projects/publish
```

success accepted state：

```text
published
```

成功响应只认：

```text
{ projectId, state: "published" }
```

成功提示：

```text
已正式发布
```

成功后页面承接：

1. 刷新我的项目详情。
2. 当前阶段展示为 `竞标中`。
3. 提供：
   - `查看公域项目详情`
   - `返回我的项目`
   - `继续补充资料`

## 5. 返回草稿继续编辑流程

按钮：

```text
返回草稿继续编辑
```

确认标题：

```text
返回草稿继续编辑
```

确认正文：

```text
撤回后，项目会回到草稿，暂不进入公域展示。附件可见性和后续处理继续按现有项目状态规则与后端返回展示，前端不得伪造草稿态正式附件走廊。
```

确认按钮：

```text
确认撤回
```

调用 existing action：

```text
POST /api/app/project/withdraw
```

BFF 继续转发到 existing Server path：

```text
POST /server/projects/withdraw
```

success accepted state：

```text
draft
```

成功提示：

```text
已撤回到草稿
```

## 6. 作废归档流程

按钮：

```text
作废归档
```

确认标题：

```text
作废归档
```

确认正文：

```text
归档后，项目会退出当前活跃流转，不会进入公域展示。归档项目仅保留 owner 私域查看入口。
```

确认按钮：

```text
确认归档
```

调用 existing action：

```text
POST /api/app/project/archive
```

BFF 继续转发到 existing Server path：

```text
POST /server/projects/archive
```

success accepted state：

```text
archived
```

成功提示：

```text
已作废归档
```

## 7. 错误与失败态

所有失败态必须受控展示。

允许失败态：

1. 当前项目不可用。
2. 当前状态不允许发布。
3. 当前账号无权限。
4. 后端返回 invalid state。
5. 附件 bind 未完成时的提示。
6. 网络或云上 runtime 错误。

禁止：

1. 把 publish 失败伪装成成功。
2. 用本地状态把 `submitted` 改成 `published`。
3. 吞掉未知错误码后继续跳转公域详情。
4. 在 BFF 中造第二发布确认状态机。

## 8. 当前最小闭环

Day4 当前最小闭环：

1. 发布方进入预发布列表详情。
2. 核对基础信息。
3. 补充或确认项目详情文书。
4. 点击 `检查无误，确定发布`。
5. 二次确认。
6. 调用 existing `publish`。
7. 成功后进入 `published / 竞标中`。

## 9. 需要保留但暂不开通

本轮保留但不开通：

1. 新 `prepublish / prepublished` 状态。
2. 新 `confirmPublish` path。
3. Server readiness checklist truth。
4. BFF 第二发布确认状态机。
5. 创建页最终发布主按钮。
6. P0-Pay 支付动作。
7. 完整 compare / award / post-award 工作台。

## 10. 后续扩展位

后续扩展位：

1. 若要把发布前核对项持久化，先补 L2 contract。
2. 若要增加发布前审核，先补 Server truth 与 audit。
3. 若要把 P0-Pay taskType 接入正式发布，必须等待对应 P0-Pay 当前日期门禁通过。
4. 若要开放公共资源或模板下载，继续走已有 public resource truth chain，不并入发布确认状态机。

## 11. 阶段门禁核查表

已通过门禁：

1. Day1 范围冻结已完成。
2. Day2 流程说明已完成。
3. Day3 创建页改版稿已完成。
4. Day4 未新增 state。
5. Day4 未新增 app-facing path。
6. Day4 继续复用 existing `publish / withdraw / archive`。

未通过门禁：

1. 前端实现门禁尚未输出。
2. 云上联调未进入本轮。
3. Computer Use 联调未进入本轮。

一票否决门禁：

1. 若新增 `prepublish / prepublished` 状态，直接 No-Go。
2. 若新增 `confirmPublish` path，直接 No-Go。
3. 若创建页继续作为最终发布确认主面，直接 No-Go。
4. 若 publish 失败被伪装成成功，直接 No-Go。
5. 若 BFF 持有 `预发布列表` 业务真相或决定最终发布确认面，直接 No-Go。

下一阶段结论：

- `Go`：进入前端实现门禁核查表编写。
- `No-Go`：直接改 BFF / Server。
- `No-Go`：直接进行 Computer Use 联调。

## 12. Formal Conclusion

Day4 正式冻结为：

```text
预发布详情是正式发布确认主面。
不新增状态。
只用现有 submitted = 预发布列表。
正式发布继续调用 existing publish。
返回草稿继续调用 existing withdraw。
作废归档继续调用 existing archive。
```
