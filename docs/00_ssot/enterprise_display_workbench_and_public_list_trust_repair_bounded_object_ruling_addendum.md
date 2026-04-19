---
owner: Codex 总控
status: active
purpose: Freeze the next bounded enterprise-display maintenance object for workbench and public-list trust repair after user-provided runtime evidence reopened concrete blocker symptoms.
layer: L0 SSOT
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_hub_v1_current_active_sub_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
  - docs/04_frontend/enterprise_display_stage2_public_card_and_album_frontend_consumption_addendum.md
  - 用户截图与本轮运行态反馈
---

# 《企业展示工作台与公域列表可信度修复边界裁决单》

## 1. 裁决目的

- 当前正式重开一个新的 bounded object，只处理用户已提供截图与运行态反馈所指向的 enterprise display 可信度问题。
- 当前重开不等于改写平台唯一主线，也不等于重新打开 enterprise-display 的整条 closure 主线。
- 当前 bounded object 的唯一目标是：
  - 修复企业展示工作台与公域列表里已存在的真实 blocker / 死控件 / 误导提示
  - 保持已冻结的展示骨架与 published-change corridor 不回退
  - 为后续“成立时间筛选”单独开新阶段做前置清障

## 2. 当前唯一 active bounded object

- 当前唯一 active bounded object 正式锁定为：
  - `enterprise display / workbench + public list trust repair`
- 当前对象只覆盖：
  - 工作台真值显示与提交阻断说明
  - Logo / 联系人建档拦截行为
  - 企业位置解析失败映射与受控降级
  - 公域列表 Logo 呈现与城市筛选可用性
  - region asset 加载失败的受控兜底
- 当前对象明确不覆盖：
  - 成立时间筛选 contract 新增
  - 详情页整体重排
  - 新信用系统
  - Admin
  - release-prep
  - production release

## 3. 当前已确认的真实问题族

- 工作台顶部 truth-derived 字段存在运行态缺值与阻断体验问题：
  - 公司名称未稳定同步到展示区
  - 公司省市真值未稳定同步到展示区
- 工作台存在错误的建档门槛：
  - 仅上传 Logo 也会被联系人姓名 / 手机号拦截
- 工作台存在位置能力失败态不清问题：
  - 文字地址解析失败
  - provider/config 问题与输入问题未被稳定区分
- 工作台存在提交解释问题：
  - CTA 置灰时并非所有失败路径都能明确告诉用户“为什么现在不能提交”
- 公域列表存在展示与交互可信度问题：
  - 列表卡片未消费 `logoUrl`
  - 城市筛选在当前运行态下存在“可点但无效”的真实风险
- 当前存在一条非业务文案级的受控失败缺口：
  - `assets/location/china_province_city.json` 失败时 raw asset error 会泄漏到页面

## 4. 本轮阶段拆分裁决

### 4.1 Stage 1

- 当前 stage-1 只负责：
  - 文书冻结
  - 本地 Flutter 可信度修复
  - 必要的云端只读核查
  - 结果校验
- 当前 stage-1 不允许：
  - 发明新 contract query 字段
  - 直接启动 founded-time filter 全链路实现
  - 把 provider/config 问题误报为前端已修复

### 4.2 Stage 2 Candidate

- 只有当 stage-1 通过后，才允许重新判断是否打开：
  - `enterprise display founded-time filter`
- 该 candidate 预期属于：
  - contracts
  - Server
  - BFF
  - Flutter
  的联动新增对象

## 5. Allowed Directories For Stage 1

- 当前允许：
  - `docs/**`
  - `apps/mobile/lib/features/exhibition/**`
  - `apps/mobile/lib/core/location/**`
  - `apps/mobile/test/**`
- 当前只允许云端：
  - 只读查看
  - 隧道验证
  - 运行态取证
- 当前不允许：
  - stage-1 内直接改云端 `Server` / `BFF` 代码

## 6. Anti-revert

- 不得把 company 的公域卡片继续固定为首字占位，忽略已存在的 `logoUrl`
- 不得继续保留“看起来可点但实测无效”的城市筛选而不给出受控说明
- 不得继续让 raw asset error 直接泄漏到提交区
- 不得因为联系人缺失就阻断 Logo-only 的展示标识维护
- 不得借修复之名回退 stage-1 workbench 骨架
- 不得削弱 published-change corridor
- 不得把 founded-time filter 偷渡进当前 bounded object

## 7. Formal Conclusion

- 当前 enterprise display 已正式打开一个新的 bounded maintenance object：
  - `workbench + public list trust repair`
- 当前 founded-time filter 不属于本轮 stage-1。
- 当前必须先完成：
  - bounded object ruling
  - drift note
  - stage gate checklist
  - frontend surface freeze
  然后才能进入实施派工。
