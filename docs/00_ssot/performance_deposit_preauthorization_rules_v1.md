---
owner: Codex 总控
status: frozen-draft
purpose: Freeze the next-mainline rules draft for `履约保证金预授权` under the current `payment MVP` planning object, without making it current execution truth or unlocking contracts, implementation, integration, release-prep, or launch.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/payment_mvp_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_mvp_mainline_judgment_v1.md
  - docs/00_ssot/payment_mvp_scope_ruling_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_rules_freeze_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
---

# 《履约保证金预授权规则 V1》

## 1. Current Position

- 本文当前只作为：
  - `payment MVP`
  - `履约保证金预授权`
  的 next-mainline rules draft
- 本文当前不是：
  - 现行 execution SSOT
  - 当前项目主链硬 gate 真相
  - implementation unlock
  - release-ready 文书

## 2. Scope

- 本文只服务于：
  - 履约保证金预授权冻结
  - 解冻 / 扣划 / 申诉最小流程规则草案
  - deposit execution candidate 与证据链草案
- 本文不服务于：
  - membership charging
  - wallet / balance
  - long-term platform fund pool
  - coins
  - generic punishment engine
  - finance-admin
  - settlement / clearing

## 3. Current Draft Judgment

- 当前 draft judgment 固定如下：
  - 履约保证金正式名称固定为：
    - `履约保证金（预授权冻结）`
  - 它是履约保障工具，不是平台收入工具
  - 它不是会员费，不是货款，不是平台余额
  - 当前最小执行方向只允许讨论：
    - preauthorization freeze
  - 当前不接受：
    - 实缴沉淀余额方案
    - wallet-style 押金方案
    - offline manual transfer deposit

## 4. Trigger Timing Draft Rule

- 当前 V1 draft 触发时点固定为：
  - 不在注册时收取
  - 不在认证时收取
  - 不在普通投标报名时收取
  - 只在中标确认成立且进入合同确认前触发一次预授权冻结候选
- 当前不得前移为：
  - 注册门槛
  - 平台通行费
  - 普通投标门票
  - 发帖权限门槛

## 5. Tier Draft Rule

- 当前 V1 draft 采用固定三档 planning baseline：
  - 标准档：`2000`
  - 中风险档：`5000`
  - 高风险档：`10000`
- 上述金额当前只表示：
  - draft-layer planning baseline
  - not final contract/backend truth
- 当前档位判定因子只允许先写成：
  - 项目金额区间
  - 是否异地执行
  - 是否涉及现场施工 / 进场搭建
- 当前不得直接使用：
  - 主观态度评价
  - 客服印象
  - 未冻结的复杂信用分模型
  - 人工随意改档

## 6. Channel Draft Rule

- 当前 draft channel direction 固定为：
  - 支付宝预授权优先 candidate
  - 微信押金能力保留为 strategic hold
- 上述 channel direction 当前只表示：
  - planning direction
  - not platform-internal permanent truth
- 若后续要冻结具体通道能力、商户准入、时效、资质差异：
  - 必须进入单独的 `payment_channel_constraints_assumptions` 文书

## 7. Allowed Use Boundary

- 当前履约保证金只允许用于以下两类目的：
  - 固定违约处理费候选
  - 经证据支持的实际损失补偿候选
- 当前正式写死：
  - 扣划上限不得超过冻结额度
  - 超出冻结额度的争议不得在本方案内伪装解决
- 当前不得写成：
  - 无限赔偿池
  - 平台任意处罚池
  - 一般差评罚款池

## 8. Deduction Draft Rule

- 当前只允许把以下对象写成直接扣划候选：
  - 中标后无故放弃且通知留痕完整
  - 长时间失联导致交易链路实质中断且证据完整
  - 已进入履约准备后明确违约且损失可举证
  - 已进入正式争议处理并形成平台裁定结果
- 当前明确禁止直接作为扣划依据的对象：
  - 普通差评
  - 低分评价
  - 回复慢
  - 沟通语气不好
  - 主观觉得不积极
  - 未完成责任归属的质量争议

## 9. Release Draft Rule

- 当前解冻规则草案只允许先冻结到：
  - 责任不在冻结方时全额解冻
  - 正常履约完成并通过验收后解冻
  - 争议处理中可延续冻结直至结论形成
  - 部分扣划后剩余额度应按规则解冻
- 当前不得出现：
  - 无限期冻结
  - 未处理长期挂起
  - 无结论不解冻

## 10. Appeal And Evidence Draft Rule

- 当前扣划最小流程草案固定为：
  - 触发事件
  - 提交证据
  - 平台初审
  - 对方陈述 / 补证
  - 平台裁定
  - 申诉复核
- 当前必须继续写死：
  - 无证据不得扣
  - 未通知不得扣
  - 未给陈述机会不得扣
  - 无留痕不得扣
- 当前可接受证据至少包括：
  - 中标确认记录
  - 合同确认通知记录
  - 平台消息通知记录
  - 系统操作日志
  - 上传文件与签章材料
  - 超时记录
  - 双方陈述材料
  - 现场图片 / 交付凭证 / 验收记录

## 11. Relationship With Current `我的信用与约束`

- 当前必须写死：
  - `我的信用与约束` 现行仍只是 posture / status / explanation / handoff package
  - 本文不能回写它的现行 execution truth
- 当前本文只表示：
  - 保证金 execution candidate 的下一层 rules draft
- 当前不得把本文偷换成：
  - 当前 `profile/credit-and-constraints/*` 已经代表保证金已冻结
  - 当前项目主链已经带上保证金已缴硬 gate

## 12. Owner And System Boundary

- 以下真相 owner 当前继续固定为：
  - `Server.payment_billing`
  - `Server.trade_governance`
- BFF 当前只允许：
  - shaping
  - auth consolidation
  - error normalization
  - handoff shaping
- BFF 当前不得：
  - 持有第二扣划状态机
  - 本地裁定责任归属
  - 本地补写扣划结果
- Flutter 当前只允许：
  - 状态展示
  - 证据提交通道
  - 申诉入口
  - 结果回显
- Flutter 当前不得：
  - 本地判断该不该扣
  - 本地判断责任归属
  - 本地缓存长期裁定真相

## 13. Explicit Non-goals

- 当前明确不做：
  - wallet
  - balance deposit
  - offline manual deposit transfer
  - membership 与 deposit 混扣
  - deposit 与 trade payment 混付
  - 双边复杂保证金
  - 动态信用免押
  - invoice / tax full system
  - settlement / clearing
  - finance-admin

## 14. Compliance Baseline Note

- 当前只允许把合规要求写成：
  - 退还方式与程序应明确披露
  - 平台规则修改应遵守适用的显著公示与提前通知义务
- 当前不得在本文中直接冻结：
  - 未单独核验的具体法条号细节
  - 未单独核验的渠道产品准入细节

## 15. Formal Draft Conclusion

- 当前正式结论如下：
  - `履约保证金预授权规则 V1` 已作为 `payment MVP` 的 next-mainline rules draft 冻结
  - 履约保证金当前只允许按 `预授权冻结` 方向讨论
  - 普通差评、低分评价、主观态度判断不得直接写成扣划依据
  - 当前文书只构成后续 contracts/backend/BFF/frontend 文书链的 planning 输入
  - 当前文书不改写 `我的信用与约束` 现行 posture/status package，也不授予 execution implementation unlock
