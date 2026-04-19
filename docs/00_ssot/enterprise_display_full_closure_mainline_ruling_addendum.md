---
owner: Codex 总控
status: frozen
purpose: Freeze the current unique mainline as the full enterprise-display closure chain, so the workbench side and the public company/factory/supplier side are no longer treated as two half-lines or left to drift behind unrelated stage priorities.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
  - docs/00_ssot/my_company_enterprise_display_entry_prd_addendum.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md
  - docs/00_ssot/enterprise_hub_v1_implementation_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
---

# 《企业展示全闭环主线裁决单》

## 1. 当前唯一主线

- 当前唯一主线正式改判为：
  - `enterprise display full closure mainline`
- 该主线唯一含义固定为：
  - 从 `我的楼 / 我的资产 -> 企业展示入驻`
  - 到 `公司 / 工厂 / 供应商` 板块选择
  - 到企业展示工作台 `create / save / case / submit / status`
  - 到 `server-admin review / publish / offline / freeze`
  - 到公域 `优秀公司 / 优秀工厂 / 优秀供应商`
  - 到列表、详情、推荐位与首页卡片回显
- 当前不得再把以下对象拆成彼此独立主线：
  - `企业展示工作台`
  - `优秀公司 / 优秀工厂 / 优秀供应商`
  - `enterprise_hub` admin publish/review

## 2. 为什么现在必须是它

- 当前这条线已经具备最多现成资产：
  - `我的楼入口 owner` 已冻结
  - `工作台 truth / contract / frontend / BFF` 已冻结
  - `list / detail / recommendation / application` 既有 path family 已存在
  - `server-admin review / publish / offline / freeze` 既有 truth family 已存在
- 当前这条线也具备最清晰的单一产品结果：
  - 用户能进入自己的企业展示工作台
  - 用户能提交
  - 运营能审核并上架
  - 公域能真实看到公司 / 工厂 / 供应商
- 如果现在不把它升成主线，当前项目会继续停在：
  - 私域工作台能编辑但公域看不到
  - 公域列表/详情路由存在但没有真实实体链
  - 审核/上架能力存在但不纳入同一验收链

## 3. 当前主线目标

- 当前主线的完成定义固定为：
  - 用户从 `我的楼 / 我的资产` 进入 `企业展示入驻`
  - 选择 `公司 / 工厂 / 供应商`
  - 进入对应工作台并完成基础资料、板块画像、案例、联系人、认证承接
  - 真实提交申请并可查看申请状态
  - `Admin/Server Admin` 可真实 review 并做 publish/offline/freeze
  - 公域能出现真实已发布实体
  - 首页卡片、推荐、列表、详情之间形成真实实体链
- 当前主线不含：
  - `个人/团队` 正式专区
  - 新的企业真相根
  - 在线交易、支付、IM、地图深能力
  - 更大范围的企业运营后台

## 4. 当前覆盖对象

- 当前主线必须覆盖以下功能项：
  - `ME-006` 我的楼资产 handoff
  - `EXH-001` 展览首页企业展示入口承载
  - `EXH-002` 优秀公司
  - `EXH-003` 优秀工厂
  - `EXH-004` 优秀供应商
  - `EXH-005` 企业详情页
  - `EXH-006A` 企业展示工作台
  - `EXH-006` 企业入驻申请状态/续办
  - `ADM-002` 内容审核/申请审核承接
  - `ADM-005` 处罚台之外与企业展示相关的 review/publish 操作承接
- 当前主线必须复用但不改写的真相 owner：
  - `organization`
  - `profile/certification`
  - `enterprise_listing`
  - `enterprise_application`
  - `enterprise_certification_snapshot`

## 5. 当前阶段定位

- 当前主线真实所处阶段固定为：
  - `judgment 完成`
  - `dispatch authoring 中`
- 当前第一阻断固定为：
  - `organization province/city truth invalid`
  - `certification establishedAt/address truth incomplete`
  - `workbench -> submit -> public entity` 没形成一条连续验收链
- 当前第二阻断固定为：
  - 公域真实实体链未证明
  - 首页卡片与推荐位虽有 carrier，但没有完成“真实已发布实体”闭环

## 6. 为什么不是其他候选主线

| 候选主线 | 为什么不是当前唯一主线 |
| --- | --- |
| `交易主链 order/contract/milestone/inspection` | 这是另一条跨对象重链；当前用户明确要求先把企业展示完整打通，而且 enterprise-display 已有更多现成资产和更短闭环。 |
| `Admin 通用登录/治理平台化` | Admin 在本线里只承担 enterprise-display 必需的 review/publish 子集；不允许把它扩大成平台级后台主线。 |
| `消息楼 / message/index` | 与当前“从工作台到公域展示”的单结果目标不直接相关，继续并行只会分散 owner。 |
| `我的楼 V2 包` | 当前这条线已经从 `我的楼` 入口起步，但完成结果落在 `exhibition` 公域展示，不应再被 V2 包抢主线。 |

## 7. 完整闭环定义

- 只有同时满足以下 6 段，当前主线才算真正打通：
  - `入口 owner`：`我的楼 / 我的资产 -> 企业展示入驻`
  - `工作台`：basic / boardProfile / case / upload / blocker / submit
  - `申请态`：create / submit / status / continue
  - `审核态`：review approve/reject
  - `上架态`：publish / offline / freeze / visible
  - `公域态`：home card / recommendation / list / detail 出现真实实体并可串联

## 8. 正式结论

- 当前正式结论固定为：
  - `enterprise display` 现在起重新成为当前唯一业务主线
  - 这条主线必须同时收私域工作台与公域展示
  - 不得再只修 workbench、不管 public entity
  - 不得再只修列表/详情、不管 workbench submit

## 9. Next Route

- 当前阶段完成度：
  - `judgment 完成`
- 当前下一步唯一动作：
  - 输出《enterprise display full closure dispatch master》并按子阶段顺序派工
- 下一步执行角色：
  - `总控`
- 下一步进入条件：
  - 本主线裁决单已落盘，且总表主线口径已同步
