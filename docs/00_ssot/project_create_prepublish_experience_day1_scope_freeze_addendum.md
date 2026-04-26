---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day1 optimization scope for the exhibition project create page and
  owner-private prepublish detail experience convergence, explicitly blocking
  any ordinary create API change, new lifecycle state, BFF/Server reopening, or
  P0-Pay takeover of the create page before the current truth is frozen.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/04_frontend/project_create_cloud_runtime_alignment_frontend_truth_note.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/01_contracts/project_publish_prepublish_relabel_and_confirmation_contract_freeze_addendum.md
  - docs/04_frontend/project_publish_prepublish_relabel_and_confirmation_frontend_consumption_addendum.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
temporal_notes:
  - docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md is dated 2026-05-02, which is later than the current local date 2026-04-26; it is retained as a pending verification item for this Day1/Day2 round and is not used as current implementation authority here.
  - docs/00_ssot/exhibition_trade_task_p0_pay_implementation_unlock_stage_gate_checklist_addendum_v1_3.md is dated 2026-05-03, which is later than the current local date 2026-04-26; it must not be treated as current implementation unlock for this Day1/Day2 round.
---

# 《Day1 创建页与预发布页体验收敛范围冻结单》

## 0. 总结论

本轮只做：

1. 创建页体验收敛。
2. 预发布详情体验收敛。
3. 创建页、我的项目、预发布详情、附件区、竞标提交页之间的职责边界冻结。

本轮不做：

1. 普通创建接口改造。
2. 新生命周期状态。
3. 新 `prepublish` path family。
4. BFF / Server 重开实现。
5. P0-Pay 在创建页直接提交。

当前更稳的方案：

- 保持 `draft -> submitted -> published` canonical lifecycle 不变，只把 `submitted` 作为用户侧 `预发布列表` 展示。

当前更省成本的方案：

- 复用既有 `save / submit / publish / withdraw / archive`、`project_attachments`、`bid/submit` 和 BFF `/api/app/*`。

当前阶段最适合的方案：

- 先冻结页面职责、状态流、附件流和报价入口关系；暂不重开 BFF / Server。

风险更大的方案：

- 新增 `prepublish / prepublished` 状态或路径，把创建页做成交易总控台，把附件、报价、支付混成第二套状态机。

## 1. Day1 Scope

本 Day1 冻结单只覆盖体验收敛范围：

1. `ProjectCreatePage` 的基础信息录入、草稿保存、保存到预发布列表、创建成功后回到我的项目。
2. `我的项目 -> 预发布列表 -> 单项目详情` 的发布确认主面。
3. `submitted-or-later` owner 附件走廊入口文案。
4. 创建页到我的项目、预发布详情到正式发布、公域详情到竞标提交的 handoff 关系。

本 Day1 冻结单不覆盖：

1. `POST /api/app/project/create` request / response / schema 变更。
2. `POST /api/app/project/save`、`submit`、`publish`、`withdraw`、`archive` 的 path 改名。
3. Server lifecycle persistence、migration、audit 变更。
4. BFF 聚合层新状态机或新业务真相。
5. P0-Pay L5 Flutter 实现。
6. `renovation` / `custom_furniture` 的可见能力开放。

## 2. 普通创建接口冻结

普通创建接口本轮保持不变：

- 创建基础项目仍沿用既有 app-facing create family。
- 创建页不得为了“预发布”新增：
  - `saveToPrepublish`
  - `confirmPublish`
  - `prepublishCreate`
  - `prepublishSubmit`
- 创建页不得要求 BFF / Server 为本轮新增字段、枚举、schema 或 command path。

当前云上 active runtime 仍按既有运行时事实处理：

- 本地只有 Flutter App。
- BFF / Server 在阿里云。
- 默认隧道为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- `scopeSummary` 是否必填继续服从当前 cloud runtime 对齐文书，不在本轮重判。

## 3. 当前最小闭环

当前最小闭环固定为：

1. 发布方在创建页录入项目基础信息。
2. 项目先形成 `draft`。
3. 发布方通过既有 `submit` 进入 `submitted`。
4. `submitted` 在用户侧展示为 `预发布列表`。
5. 发布方在我的项目详情 / 预发布详情补充项目详情文书。
6. 发布方确认无误后通过既有 `publish` 进入 `published`。
7. 公域项目详情只读展示并导流工厂竞标。
8. 工厂进入竞标提交页，核对项目、读取只读附件投影、填写报价与方案、上传 3 份必选文档。
9. 工厂通过既有 `POST /api/app/bid/submit` 提交竞标。

## 4. 页面职责冻结

### 4.1 创建 / 编辑页

创建 / 编辑页只负责：

1. 基础信息录入。
2. 草稿保存。
3. 保存到预发布列表。
4. 创建成功后跳转或 handoff 到我的项目。

创建 / 编辑页不得负责：

1. `submitted` 态最终发布确认主面。
2. 工厂报价收集。
3. P0-Pay 支付或预授权提交。
4. 通用附件中心。
5. 订单、合同、履约、验收、评价、争议工作台。

### 4.2 我的项目

我的项目继续是发布方 / 工厂私域入口：

1. `我的发布` 承接发布方项目。
2. `我的竞标` 承接工厂竞标记录。
3. `我的发布` 至少按 `草稿 / 预发布列表 / 竞标中 / 进行中` 心智组织。
4. `预发布列表` 只对应 canonical `submitted`。

### 4.3 预发布详情

预发布详情是 Day1/Day2 的发布确认主面：

1. 展示项目基础信息回显。
2. 展示项目详情文书区。
3. 允许 `submitted-or-later` owner 补充附件。
4. 提供：
   - `检查无误，确定发布`
   - `返回草稿继续编辑`
   - `作废归档`

预发布详情不得产生：

1. 新 `prepublish` persisted state。
2. 第二附件业务真值。
3. 交易支付真相。
4. 工厂报价真相。

## 5. 附件边界冻结

项目附件继续遵守：

1. 上传链路必须是 `init -> direct upload -> confirm -> bind`。
2. `objectKey` 不是业务真相。
3. `FileAsset` 是上传资产真相。
4. `Evidence` 继续只作为流程证据真相，不替代项目附件列表真相。
5. `project_attachments` 是项目附件业务真相。
6. owner 附件走廊从 `submitted` 开始允许进入。

附件种类继续固定为：

1. `effect_image`
2. `construction_doc`
3. `other_material`

工厂竞标侧只读投影只允许：

1. `effect_image`
2. `construction_doc`

工厂竞标侧不得展示或操作：

1. `other_material`
2. owner 上传按钮
3. owner 删除按钮

## 6. P0-Pay 边界冻结

截至当前本地日期 `2026-04-26`：

1. P0-Pay L0 母资料已在 `2026-04-24` 冻结。
2. P0-Pay L2 contracts 已在 `2026-04-26` 冻结。
3. P0-Pay L5 frontend consumption 文书标注 `freeze_date_local: 2026-05-02`，晚于当前日期，当前仅作为待核对项。
4. P0-Pay implementation unlock 文书标注 `freeze_date_local: 2026-05-03`，晚于当前日期，本轮不得视为当前实现授权。

因此本 Day1/Day2 轮次只能按 L0 / L2 讲边界：

1. 明价竞标服务费预授权是后续扩展位。
2. 询价报价单 200 元发单诚意金是后续扩展位。
3. P0-Pay 不在创建页直接提交。
4. 创建页不得内嵌支付执行、支付结果轮询、预授权结果判定或资金状态真相。

## 7. 需要保留但暂不开通

本轮保留但不开通：

1. `renovation` / `custom_furniture` 继续隐藏预埋。
2. P0-Pay 明价竞标服务费预授权。
3. P0-Pay 询价报价单 200 元发单诚意金。
4. 通用钱包、余额、金币、资金池。
5. 支付中心、账单中心、结算、发票、财务后台。
6. 履约保证金。
7. 泛私信、群聊、完整 compare board、loser board、post-award 工作台。

## 8. 后续扩展位

后续扩展位固定为：

1. P0-Pay：明价竞标服务费预授权。
2. P0-Pay：询价报价单 200 元发单诚意金与 5 个报价席位。
3. 消息楼：只读资金状态、竞标摘要、项目沟通 handoff。
4. 订单：中标后合同、订单、履约、验收、评价、争议继续处理入口。
5. 管理治理：模板、规则、权限、审核、风险、审计。

这些扩展位不得并入创建页。

## 9. 阶段门禁核查表

已通过门禁：

1. 真源门禁：已先查 docs，再查 contracts，再查必要代码位置。
2. 架构边界门禁：继续保持 Flutter -> BFF -> Server，Flutter 不直连 Server。
3. 契约门禁：本轮不新增 app-facing path、schema、enum。
4. 状态机门禁：继续使用 `draft / submitted / published`，不新增 `prepublish`。
5. 数据与上传门禁：继续使用 `FileAsset + project_attachments`，不把 `objectKey` 当真相。
6. 阶段控制门禁：本文件只冻结 Day1 范围，不授权实现。

未通过门禁：

1. P0-Pay L5 frontend consumption 文书日期晚于当前日期，需待核对。
2. P0-Pay implementation unlock 文书日期晚于当前日期，不能作为本轮实现放行依据。
3. Day2 流程说明需由独立 Day2 文书承接，本文件不替代 Day2。

一票否决门禁：

1. 若新增 `prepublish / prepublished` 状态或路径，直接 No-Go。
2. 若改普通创建接口，直接 No-Go。
3. 若让 BFF 持有业务真相或资金真相，直接 No-Go。
4. 若让 Flutter 直连 Server，直接 No-Go。
5. 若跳过 Day2 流程说明直接进入代码实现，直接 No-Go。

下一阶段结论：

- `Go`：进入 Day2 流程说明稿冻结。
- `No-Go`：进入代码实现。
- `No-Go`：重开 BFF / Server。
- `No-Go`：Computer Use 联调。

## 10. Formal Conclusion

Day1 正式冻结为：

```text
本轮只做创建页与预发布页体验收敛的真相冻结。
普通创建接口不改。
submitted 继续只是 canonical state，预发布列表只是用户侧文案。
P0-Pay 不进入创建页直接提交。
Day2 流程说明稿冻结前不得进入实现。
```
