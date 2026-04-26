---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day3 create-page revision brief for the current exhibition project
  create flow, including the field order and the budget-side fixed-price /
  inquiry intention selector copy, while keeping the selector non-persistent,
  non-transactional, and outside ordinary project create contracts.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_and_factory_bid_day2_flow_brief_addendum.md
  - docs/04_frontend/project_create_cloud_runtime_alignment_frontend_truth_note.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/01_contracts/project_publish_prepublish_relabel_and_confirmation_contract_freeze_addendum.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
temporal_notes:
  - docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md is dated 2026-05-02, later than the current local date 2026-04-26; Day3 does not use it as implementation authority.
  - docs/00_ssot/exhibition_trade_task_p0_pay_implementation_unlock_stage_gate_checklist_addendum_v1_3.md is dated 2026-05-03, later than the current local date 2026-04-26; Day3 does not treat it as current implementation unlock.
---

# 《Day3 创建页改版稿：字段顺序与预算旁明价 / 询价意向选择》

## 0. 总结论

Day3 只冻结创建页页面方案，不授权代码实现。

当前更稳的方案：

- 在创建页保留基础项目创建职责，只在预算旁放一个非提交型 `明价 / 询价` 意向选择。

当前更省成本的方案：

- 不新增普通创建接口字段，不新建 P0-Pay trade-task，不拉起支付，不改 BFF / Server。

当前阶段最适合的方案：

- 先让发布方在填写预算时表达后续发布方式意向，帮助页面理解，但不让这个意向成为业务真相。

风险更大的方案：

- 在创建页直接创建明价竞标单或询价报价单，直接拉起 200 元发单诚意金，或把意向选择写入新的 project state / contract field。

## 1. Day3 Scope

本文件只覆盖：

1. 创建页字段顺序。
2. 预算旁 `明价 / 询价` 意向选择控件。
3. 该控件的标题、选项、说明文案。
4. 创建页动作区的职责边界。

本文件不覆盖：

1. `POST /api/app/project/create` schema 变更。
2. `POST /api/app/project/save / submit / publish` 变更。
3. P0-Pay trade-task 创建。
4. 询价报价单 200 元发单诚意金支付。
5. 明价竞标服务费预授权。
6. BFF / Server 代码实现。

## 2. 创建页字段顺序

创建页字段顺序正式冻结如下。

### 2.1 基础信息

第一组：`基础信息`

1. `展会`
2. `品牌`
3. `项目类型`
4. `预算金额`
5. `报价方式意向`
6. `项目面积`
7. `类型备注（选填）`

布局规则：

- 宽屏第一行：`展会 / 品牌`。
- 宽屏第二行：`项目类型 / 预算金额 + 报价方式意向 / 项目面积`。
- 窄屏按上述顺序纵向排列。
- `报价方式意向` 必须贴近 `预算金额`，不能放到独立 P0-Pay 大卡片里。
- `类型备注（选填）` 单独一行。

### 2.2 项目地点与范围

第二组：`项目地点与范围`

1. `省`
2. `市`
3. `区/县`
4. `详细地址`
5. `范围说明`

布局规则：

- `省 / 市 / 区县` 同排，窄屏降级。
- `详细地址` 整行。
- `范围说明` 继续使用按钮打开底部弹层编辑。
- `范围说明(scopeSummary)` 当前是否必填继续服从 cloud runtime alignment，不在 Day3 重判。

### 2.3 计划时间

第三组：`计划时间`

1. `计划开始日期`
2. `计划结束日期`
3. `详细时间（选填）`

布局规则：

- `计划开始日期 / 计划结束日期` 同排，窄屏降级。
- `详细时间（选填）` 单独一行。

### 2.4 补充说明与资料提示

第四组：`补充说明与资料`

1. `补充说明`
2. `资料补充提示`

文案规则：

- `补充说明` 只承接背景、协作提醒或现场重点。
- `资料补充提示` 继续提示：进入预发布列表后，可在我的项目详情 / 预发布详情补充效果图、施工图、其他资料。
- 创建页不直接承接 owner 正式附件列表，不把 upload confirm 当成项目附件业务真相。

## 3. 预算旁意向选择

### 3.1 控件定位

控件名称：

```text
报价方式意向
```

控件类型：

- segmented control。

选项：

1. `明价意向`
2. `询价意向`

默认状态：

- 推荐默认不选。
- 若产品必须默认一个选项，默认应为 `明价竞标`，但仍不得提交为业务真相。

### 3.2 控件主说明

预算字段下方或控件说明固定为：

```text
仅用于说明本次预算沟通方式，不创建交易任务，不拉起支付或预授权；预算金额仍是当前唯一预算真值。
```

### 3.3 明价竞标选项说明

当选择 `明价意向` 时，展示说明：

```text
已有明确预算，希望工厂按预算范围正式报价。当前只记录沟通意向，正式竞标仍需进入预发布详情检查无误后再发布。
```

禁止文案：

1. `创建明价竞标单`
2. `立即发布明价竞标`
3. `确认预授权并报名`
4. `已进入明价竞标`

### 3.4 询价报价选项说明

当选择 `询价意向` 时，展示说明：

```text
预算仍需参考工厂报价，当前只记录沟通意向，不会创建询价报价单，也不会拉起 200 元发单诚意金。
```

禁止文案：

1. `创建询价报价单并拉起发单诚意金`
2. `立即支付 200 元`
3. `已开放 5 个报价席位`
4. `询价单已发布`

### 3.5 意向选择的真相边界

`报价方式意向` 当前只允许作为：

1. 页面内交互提示。
2. 发布方自我判断辅助。
3. 后续 P0-Pay 扩展位的入口心智铺垫。

当前不得作为：

1. project persisted field。
2. project lifecycle state。
3. BFF / Server contract field。
4. trade-task truth。
5. payment requirement truth。
6. bid seat truth。

当前不得新增：

1. `taskType` 到普通 create / save / submit payload。
2. `quoteMode` 到普通 project contract。
3. `isInquiry` 到 project response。
4. `prepublish` 状态或路径。
5. `/api/app/exhibition/trade-tasks` 创建动作。

## 4. 创建页动作区

创建页主动作继续按当前状态区分。

新创建 / 创建成功前：

- 主按钮：`保存项目基本信息并跳转至我的项目`
- 说明：成功后进入我的项目继续处理；失败时停留当前页并展示后端错误。

`draft`：

- 主按钮：`保存到预发布列表`
- 次按钮：`仅保存草稿`
- 辅助按钮：`查看我的项目详情`

`submitted`：

- 主按钮：`返回预发布列表详情`
- 次按钮：`继续核对当前内容`
- 禁止在创建页直出最终发布按钮。

`published`：

- 主按钮：`查看公域项目详情`
- 次按钮：`查看我的项目详情`

## 5. 当前最小闭环

Day3 当前最小闭环：

1. 发布方填写基础信息。
2. 在预算旁选择或不选择 `报价方式意向`。
3. 保存基础信息。
4. 进入我的项目。
5. 从草稿保存到预发布列表。
6. 在预发布详情正式确认发布。

## 6. 需要保留但暂不开通

本轮保留但不开通：

1. 明价竞标单正式创建。
2. 询价报价单正式创建。
3. 询价报价单 200 元发单诚意金。
4. 工厂报价席位。
5. 平台服务费预授权。
6. 支付结果轮询。
7. 钱包、余额、支付中心、结算、发票。
8. 履约保证金。

## 7. 后续扩展位

后续扩展位固定为：

1. 当 P0-Pay L5 与 implementation unlock 到达当前日期且门禁通过后，再讨论是否把 `报价方式意向` 升级为正式 `taskType`。
2. 若要持久化 `报价方式意向`，必须先补 L2 contract，不得从 Flutter 本地直接写入。
3. 若要在创建页创建 trade-task，必须重新通过 Day-level implementation gate。

## 8. 风险点

最大风险：

- 当前代码中已有 P0-Pay 创建任务区域和“创建询价报价单并拉起发单诚意金”类动作文案。Day3 正式结论要求这些内容不能作为当前创建页主路径。

处理：

- 后续若进入前端实现，应把创建页 P0-Pay 承接收敛为预算旁的 `报价方式意向`，并移除或隐藏交易任务创建与支付动作。

## 9. 阶段门禁核查表

已通过门禁：

1. Day1 / Day2 真相已冻结。
2. Day3 未新增 contract path、schema、enum。
3. Day3 未新增 lifecycle state。
4. Day3 未要求本地 BFF / Server 可写可跑。
5. Day3 明确 P0-Pay 只做意向选择。

未通过门禁：

1. 前端实现门禁尚未输出。
2. BFF / Server 不应进入本轮。
3. P0-Pay L5 与 implementation unlock 日期仍晚于当前日期，不能作为 Day3 当前实现授权。

一票否决门禁：

1. 若把 `报价方式意向` 提交到普通 create / save / submit payload，直接 No-Go。
2. 若创建页拉起 200 元发单诚意金，直接 No-Go。
3. 若创建页创建 P0-Pay trade-task，直接 No-Go。
4. 若新增 `prepublish` 状态或路径，直接 No-Go。

下一阶段结论：

- `Go`：进入 Day4 预发布确认稿冻结。
- `No-Go`：直接进入前端实现。
- `No-Go`：改 BFF / Server。

## 10. Formal Conclusion

Day3 正式冻结为：

```text
创建页字段顺序固定。
预算旁只放明价意向 / 询价意向选择。
明价 / 询价只做意向，不创建交易任务，不触发支付，不新增状态，不改普通创建接口。
```
