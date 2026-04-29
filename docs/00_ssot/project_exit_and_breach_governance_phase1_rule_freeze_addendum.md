---
title: project_exit_and_breach_governance_phase1_rule_freeze_addendum
owner: Codex 总控
status: frozen
layer: L0 SSOT
updated_at: 2026-04-29
purpose: Freeze phase-1 rules for project exit and breach governance before contracts, Server, BFF, Flutter, or cloud changes.
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/my_project_lifecycle_correction_ruling_addendum.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_frontend_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/my_project_lifecycle_correction_backend_truth_addendum.md
  - docs/03_bff/my_project_lifecycle_correction_bff_surface_addendum.md
  - apps/server/src/modules/project/project-lifecycle.service.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-state-action.service.ts
---

# 项目退出与违约治理第一期 L0 规则冻结单

## 0. 总裁决

- 当前是否允许直接实现：`No-Go`
- 当前是否允许进入 L2 Contracts 冻结：`Go`
- 当前是否允许动云端：`No-Go`
- 当前是否允许自动费用扣罚：`No-Go`
- 当前第一期定位：先打通项目退出、双方取消、违约记录与最小信用留痕；不进入真实扣款、保证金扣罚、仲裁、申诉中心。

## 1. 当前真相复核

| 事项 | 当前真相 | 证据 | 本期处理 |
|---|---|---|---|
| 草稿删除 | `draft` 可删除，且是硬删除 project 记录 | `project-write.service.ts` 仅允许 `state === draft` | 保持，但前端文案继续明确“仅草稿” |
| 预发布撤回 | `submitted -> draft` 已存在 | `project-lifecycle.service.ts#withdrawProject` | 保持；不复用为竞标中撤回 |
| 预发布作废 | `submitted -> archived` 已存在 | `project-lifecycle.service.ts#archiveProject` | 作为“预发布作废删除”的低风险真相承载 |
| 竞标中下架关闭 | `published -> archived` 已存在 | `project-lifecycle.service.ts#closeProject` | 保留但不是本期主路径 |
| 竞标中撤回到预发布 | 当前不存在 | 现有 `withdraw` 只允许 `submitted -> draft` | 本期新增核心规则 |
| 进行中业务关闭链 | 当前禁止复用 withdraw/archive/close | 既有 L0/L3 文书与 Server fail-closed | 本期只做双方取消/违约记录，不直接回预发布 |
| P0-Pay breach hold/release | 有局部 action，但不等于通用项目退出治理 | `p0-pay-state-action.service.ts` | 本期只定义安全边界，不自动扣款 |

## 2. 本期只做什么

1. `draft`：
   - 保持“删除此项目”。
   - 删除后仍返回 `state=deleted`。

2. `submitted / 预发布列表`：
   - 保持“返回草稿继续编辑”。
   - 保持“作废归档”。
   - 用户侧可以称为“删除/作废删除”，但 Server 真相优先使用 `archived`，避免删除已经形成的审计和附件承接关系。

3. `published / 竞标中`：
   - 新增“撤回到预发布”。
   - 真相流转为 `published -> submitted`。
   - 必须退出 public showcase corridor。
   - 必须清理 `publishedAt` 或使用等价机制确保公域不可见。
   - 已有竞标记录保留为历史，不物理删除。
   - 已有可释放的 P0-Pay 预授权必须释放或失效；若当前 P0-Pay 状态无法安全释放，动作必须 fail closed。

4. `active / 进行中`：
   - 新增“发起取消申请”。
   - 新增“同意取消 / 拒绝取消”。
   - 新增“记录发布方违约 / 记录工厂违约”。
   - 双方同意后进入 `mutually_cancelled` 或等价的已取消承接，不回到 `submitted`。
   - 单方违约只记录责任与信用候选，不自动扣钱。

## 3. 本期不做什么

1. 不做真实自动扣款。
2. 不做保证金扣罚。
3. 不做服务费罚没。
4. 不做平台仲裁。
5. 不做申诉中心。
6. 不做后台人工裁决台。
7. 不重做合同系统。
8. 不重做订单状态机。
9. 不把进行中项目直接退回预发布列表。
10. 不删除已经形成的 bid、order、contract、payment、message、audit 记录。

## 4. 状态与动作冻结

| 当前状态 | 用户可见动作 | Server 真相动作 | 目标状态 / 结果 | 本期 |
|---|---|---|---|---|
| `draft` | 删除此项目 | `deleteDraftProject` 或现有 delete | `deleted` | 做 |
| `submitted` | 返回草稿继续编辑 | 现有 `withdraw` | `draft` | 保持 |
| `submitted` | 作废删除 / 作废归档 | 现有或增强 `archive` | `archived` | 做 |
| `published` | 撤回到预发布 | 新增 `withdrawPublishedToSubmitted` | `submitted` | 做 |
| `published` | 下架关闭 | 现有 `close` | `archived` | 保留，不作为主路径 |
| `awarded / converted_to_order` | 发起取消 | 新增 `requestProjectCancellation` | `cancellation_requested` | 做 |
| `cancellation_requested` | 同意取消 | 新增 `respondProjectCancellation(accept)` | `mutually_cancelled` | 做 |
| `cancellation_requested` | 拒绝取消 | 新增 `respondProjectCancellation(reject)` | 回到进行中可继续 | 做 |
| `awarded / converted_to_order` | 记录发布方违约 | 新增 `recordPublisherBreach` | `breach_recorded` 或 exit case recorded | 做 |
| `awarded / converted_to_order` | 记录工厂违约 | 新增 `recordFactoryBreach` | `breach_recorded` 或 exit case recorded | 做 |

## 5. 竞标中撤回规则

`published -> submitted` 只允许在以下条件满足时执行：

1. 当前组织是项目 owner。
2. 项目仍处于 `published`。
3. 项目未进入 `awarded / converted_to_order`。
4. 不存在已进入 final charge、合同确认或履约中的交易对象。
5. 已有 bid 只允许转入只读历史，不允许物理删除。
6. 已有 P0-Pay authorization：
   - `pending_authorization` 且无 payment order：允许标记失效或取消。
   - `authorized / pending_contract_confirm`：必须走 Server 安全释放动作。
   - `charged / final charge`：必须 fail closed。
   - 不允许扣罚。
7. 重新发布时必须被视为新一轮竞标承接，不能让旧竞标自动恢复为有效竞标。

## 6. 进行中取消与违约规则

### 6.1 双方取消

- 进行中项目不允许单方直接退回 `submitted`。
- 一方发起取消后，另一方必须明确同意或拒绝。
- 双方同意取消后：
  - 订单/合同/履约记录保留。
  - 项目进入 `mutually_cancelled` 或由 exit case 表达的取消完成态。
  - 不自动扣钱。
  - 可生成信用候选事件，但不直接处罚。

### 6.2 发布方违约

- 发布方主动终止进行中项目，若没有双方同意，应记录 `publisher_breach`。
- 本期只做：
  - 违约事件留痕。
  - 信用候选记录。
  - P0-Pay 不自动扣罚。

### 6.3 工厂违约

- 工厂拒绝继续履约，若没有双方同意，应记录 `factory_breach`。
- 本期只做：
  - 违约事件留痕。
  - 信用候选记录。
  - 可进入 P0-Pay `breach_hold` 兼容边界，但不自动扣服务费或保证金。

## 7. 信用与惩罚边界

- 第一阶段只允许生成“信用候选事件”。
- 不允许直接改组织信用分。
- 不允许直接限制账号。
- 不允许扣款。
- 后续若接入信用评分，必须进入独立 `credit scoring / governance` 包。

## 8. Server / BFF / Flutter 边界

| 层级 | 边界 |
|---|---|
| Server | 唯一状态机、退出、取消、违约与审计真相 owner |
| BFF | 只转发、鉴权上下文透传、错误整形、最小响应 shaping |
| Flutter | 只展示允许动作、收集原因/确认、展示结果；不得决定最终状态 |

## 9. Stop Rule

任一条件触发即停止实现：

| Stop 条件 | 处理 |
|---|---|
| 发现需要自动费用扣罚才能闭环 | 停止，转入二期费用惩罚方案 |
| 竞标中撤回存在 charged / final charge 数据 | 当前动作 fail closed |
| 进行中取消需要删除 order / contract | 停止，不允许物理删除 |
| BFF 或 Flutter 试图本地推导最终状态 | 停止，回到 Server truth |
| 云端 release 与本地实现不一致 | 停止 runtime 验证 |

## 10. 阶段门禁核查表

| 门禁 | 结论 | 说明 |
|---|---|---|
| 真源门禁 | Pass | 已按 docs -> contracts -> code 取证 |
| 范围门禁 | Pass | 第一阶段不做费用扣罚、仲裁、申诉中心 |
| 状态机门禁 | Pass | 进行中不直接回预发布 |
| 支付门禁 | Pass with Risk | P0-Pay 仅允许释放/失效/hold，不允许扣罚 |
| 契约门禁 | Pass | 下一步必须冻结 L2 contracts |
| 云端门禁 | No-Go | 当前未授权动云端 |

## 11. 下一步唯一动作

进入 L2 Contracts 冻结，补齐：

- 竞标中撤回到预发布接口。
- 预发布作废删除接口或 existing archive 的正式语义。
- 进行中取消 request/respond 接口。
- 发布方/工厂违约记录接口。
- 最小响应、错误码与权限边界。
