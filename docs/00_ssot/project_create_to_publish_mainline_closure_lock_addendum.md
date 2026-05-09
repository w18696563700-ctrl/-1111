---
owner: Codex 总控
status: frozen
closure_type: business_mainline_lock
layer: L0 SSOT
scope:
  - project create
  - draft edit
  - submitted prepublish material completion
  - quote basis attachments
  - sincerity green-channel attestation
  - publish confirmation
  - published bidding state handoff
effective_local_date: 2026-05-04
purpose: >
  Record the final closure lock for the ordinary exhibition project
  create-to-publish chain. This file freezes the current business flow,
  defines what is closed, what remains out of scope, and blocks future
  opportunistic changes unless a new formal reopening gate is approved.
---

# 项目创建到发布主链路收口锁定 Addendum

## 1. 总裁决

`项目创建 -> 草稿 -> 预发布补资料 -> 绿色通道表态 -> 确认发布 -> 竞标中`
这条普通展览项目发布主链路，在当前阶段正式收口。

本文件的结论是：

- `Go` for closing the current create-to-publish business mainline.
- `No-Go` for continuing ad hoc UI polishing, wording reshaping, route reshuffling,
  state reinterpretation, or gate-condition changes inside this mainline.
- Any future work that touches this mainline must first open a new SSOT gate and
  explain why the closed mainline must be reopened.

本文件不是生产发布许可，不替代云端 runtime 验证，不允许绕过 contracts / Server truth。

## 2. 当前最小闭环

当前最小闭环锁定为：

| 顺序 | 页面 / 节点 | 状态 | 冻结职责 | 允许动作 |
| --- | --- | --- | --- | --- |
| 1 | 创建项目 | 创建前 | 填写项目基础信息，保存为草稿 | 创建项目 |
| 2 | 我的项目 - 草稿列表 | `draft` | 展示未完成项目，承接继续编辑 | 查看详情、继续编辑 |
| 3 | 编辑项目 草稿 -> 预发布信息补充页 | `draft` | 可编辑基础信息、地点、计划时间、补充说明，并提交进入预发布 | 仅保存草稿、确认保存并进入预发布信息补充页 |
| 4 | 我的项目 - 预发布列表 | `submitted` 列表分组 | 只作为列表阶段和入口，不是功能页 | 补资料后确认发布 |
| 5 | 我的项目详情（预发布补资料并发布页） | `submitted` | 唯一承接报价依据资料、绿色通道表态、确认发布 | 补资料、表态、确认并发布、返回草稿继续编辑 |
| 6 | 竞标中 / 公域项目详情 | `published` | 项目进入公域竞标展示 | 按已冻结能力查看、沟通、竞标承接 |

主状态链锁定为：

`draft -> submitted -> published`

不得在 Flutter、BFF 或 Server 中引入第二套发布状态机。

## 3. 页面定义锁定

| 页面 | 锁定名称 | 禁止再改的边界 |
| --- | --- | --- |
| 草稿编辑页 | `编辑项目 草稿 -> 预发布信息补充页` | 不得改成只读页；不得把预发布补资料能力搬回此页 |
| 我的项目预发布列表 | `预发布列表` | 只是列表分组；不得恢复 `编辑项目 预发布列表` 中间功能页 |
| 预发布详情页 | `我的项目详情（预发布补资料并发布页）` | 唯一补资料与确认发布页；不得再拆成多个中间页 |
| 报价依据资料区 | `报价依据资料` | 五类资料归属、紧凑附件行、正式附件回读口径保持不变 |
| 发布前待办区 | `发布前待办` | 只展示资料、绿色通道、发布确认的真实派生状态 |

## 4. 发布门禁锁定

发布确认的当前门禁由以下条件组合：

1. 三类必传报价依据资料已经形成正式附件：
   - `effect_image`：效果图
   - `construction_doc`：尺寸图 / 施工图
   - `material_sample`：材质图 / 材料样板
2. 设备物料清单、服务清单保留并建议补充，但当前不作为硬门禁。
3. 项目真实性诚意金绿色通道已经完成二选一表态：
   - 支持项目真实性诚意金机制
   - 暂不支持项目真实性诚意金机制
4. 内测期间，已表态即放行；选择 `暂不支持` 仍允许继续发布。

正式附件真源保持不变：

- 上传三步流：`upload/init -> direct upload -> upload/confirm/bind`
- 业务真值：`FileAsset / Evidence / ProjectAttachment`
- `objectKey` 不是业务真值。

## 5. 保留但暂不开通

以下能力保留为后续扩展位，不得在本链路内继续临时加工：

- 正式期真实诚意金支付 / 冻结 / 退回机制。
- Server 强制三类必传资料门禁的进一步后端硬校验。
- Admin 对项目真实性、资料完整度、绿色通道表态的治理视图。
- 竞标、合作确认、订单、合同、履约、结算、发票、评价等下游交易链路。
- 消息楼里的资料确认和后续合作承接。

这些扩展位必须另开 SSOT / contracts / BFF / Server / Flutter 分层门禁，不得借本文件直接施工。

## 6. 禁改清单

除非另开正式 reopening gate，任何 Agent 不得对本链路做以下改动：

- 不得重命名已锁定页面。
- 不得恢复 `编辑项目 预发布列表` 中间页。
- 不得把草稿编辑页改成只读核对页。
- 不得把预发布补资料职责拆回草稿页或列表页。
- 不得改变 `draft -> submitted -> published` 主状态链。
- 不得新增 fake 状态、fake 附件、fake 发布能力。
- 不得把待上传草稿附件当作正式已补齐资料。
- 不得把设备物料清单、服务清单擅自升级为硬门禁。
- 不得取消绿色通道表态二选一。
- 不得重新把真实诚意金支付 / 冻结作为内测期发布硬门禁。
- 不得绕过 BFF 让 Flutter 直连 Server。
- 不得用 BFF 持有业务真相或第二状态机。
- 不得把本地 mock / 本地 3000 / 本地 3001 当作云端真相。

## 7. 允许的维护例外

本链路关闭后，只允许以下维护进入评估：

| 类型 | 是否允许 | 前置条件 |
| --- | --- | --- |
| P0 崩溃修复 | 允许 | 只修崩溃，不改变业务语义 |
| 安全 / 权限漏洞修复 | 允许 | 必须先记录风险和修复边界 |
| 云端 runtime 与已冻结 SSOT 不一致 | 允许 | 必须先输出 No-Go 或 reopening gate |
| 文案错别字 | 条件允许 | 不改变页面名称、状态名、门禁含义 |
| 视觉微调 | 默认不允许 | 只有遮挡、溢出、不可点击等验收缺陷可开维护单 |
| 新业务需求 | 不允许直接进入 | 必须另开完整冻结方案 |

## 8. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 关闭当前发布主链路，只保留 P0 / 安全 / runtime 不一致维护例外 |
| 哪个更省成本 | 不再继续做 UI 微调或链路重排，避免重复返工 |
| 哪个更适合当前阶段 | 将后续精力转向竞标、消息楼、合作确认等下游链路，而不是反复改发布页 |
| 哪个风险最大 | 在没有新冻结单的情况下继续改页面命名、状态门禁、诚意金规则或上传归属 |

## 9. Reopening Gate

任何未来任务只要触碰以下内容，必须先提交新的施工方案和冻结单：

- 页面名称、路由归属、按钮去向。
- `draft / submitted / published` 状态含义。
- 三类必传资料门禁。
- 设备物料清单 / 服务清单是否变成硬门禁。
- 绿色通道表态规则。
- 诚意金支付 / 冻结 / 退款规则。
- 上传三步流、FileAsset、Evidence、ProjectAttachment 真值。
- Server 发布门禁、BFF 透传、OpenAPI / generated types。

没有 reopening gate，不得改代码、不得改文书、不得改接口、不得动云端。

## 10. 收口结论

当前链路状态：

`项目创建到发布主链路 = 已收口 / 已锁定 / 禁止无门禁改动`

下一阶段建议：

- 不再继续围绕发布页做视觉打磨。
- 后续业务推进应转向：
  - 竞标方查看资料与提交竞标。
  - 消息楼资料确认与沟通承接。
  - 发布方选择合作方 / 合作确认。
  - 订单 / 合同 seed 后续闭环。

若未来出现真实生产阻塞，应以 `reopening gate` 形式重新评估，不得口头改动本链路。
