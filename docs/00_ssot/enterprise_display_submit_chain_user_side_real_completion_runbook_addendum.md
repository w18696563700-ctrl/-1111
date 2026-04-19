---
owner: Codex 总控
status: frozen
purpose: Freeze the user-side real completion runbook for the enterprise-display submit chain after dirty runtime drift repair closure.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_submit_chain_runtime_scan_receipt_addendum.md
  - docs/00_ssot/enterprise_display_submit_chain_runtime_drift_repair_backend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
---

# 《enterprise display submit chain 用户侧真实补齐操作单》

## 1. 当前目标

- 当前目标不是“强行提交成功”。
- 当前目标是：
  - 在干净 submit object 上
  - 真实补齐上游真值与工作台必填
  - 最终一次性成功提交入驻申请

## 2. 当前已冻结事实

- 当前 active organization：
  - `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`
- 当前 active listing：
  - `enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
  - `primaryBoardType = factory`
- 当前 dirty runtime drift 已收干净：
  - draft application 只剩 `1` 条
  - stale certification snapshot 已清空
- 当前仍未满足 final submit 条件：
  - 注册城市真值未成立
  - 当前 organization certification 已清空
  - basic 未补齐
  - factory profile 未补齐
  - case 数量为 `0`

## 3. 唯一正确顺序

### Step 1｜去《我的公司》补有效注册城市

- 操作：
  - 进入 `我的楼 -> 我的公司`
  - 找到公司注册地址 / 注册城市
  - 保存为有效省市 code
- 当前通过信号：
  - 回到企业展示工作台时
  - `注册城市` 不再显示“当前还没有同步到我的公司里的注册城市真值”
  - 应显示真实城市名
- 当前停机条件：
  - 如果这里仍不能保存有效城市
  - 或回到工作台后仍显示城市缺失
  - 本轮停止，不继续做认证与提交

### Step 2｜重新完成企业认证

- 操作：
  - 进入 `我的楼 -> 企业认证`
  - 重新上传营业执照
  - 完成识别、提交、审核通过
- 当前通过信号：
  - 工作台中的 `认证摘要` 显示：
    - 认证状态 = `已通过`
  - `企业名称`
  - `统一社会信用代码`
  - `成立日期`
  - 应能真实回显
- 当前停机条件：
  - 如果认证状态未回到 `approved`
  - 或成立日期仍为空
  - 本轮停止，不继续 basic/profile/case

### Step 3｜回工作台保存基础资料

- 操作：
  - 进入 `我的楼 / 我的资产 -> 企业展示入驻 -> 工厂工作台`
  - 填写并保存：
    - 一句话简介
    - 展示介绍
    - 详细地址
    - 团队规模
    - 合作方式
    - 联系人展示开关
- 当前通过信号：
  - 点击 `保存基础资料` 成功
  - 页面刷新后这些字段真实回显
  - `basic` 不再为空
- 当前停机条件：
  - 如果仍被 `注册城市` 或 `成立日期` 阻断
  - 返回 Step 1 / Step 2，不继续后面的 profile 与 case

### Step 4｜完成工厂画像

- 操作：
  - 在同一工作台填写工厂画像最小必填：
    - 工厂名称
    - 生产工艺
    - 核心产品
- 当前通过信号：
  - 保存成功
  - 页面刷新后画像字段真实回显
  - `factory profile` 不再为空
- 当前停机条件：
  - 如果保存失败
  - 或刷新后画像字段未回显
  - 本轮停止，不继续新增案例

### Step 5｜新增至少 1 个案例

- 操作：
  - 在 `已有案例` 区新增至少 `1` 个案例
  - 上传案例图片
  - 填写案例标题 / 分类 / 地区 / 时间 / 亮点摘要
- 当前通过信号：
  - 页面出现至少 `1` 个案例
  - 当前 listing 的 `hasCase = true`
- 当前停机条件：
  - 如果案例未成功创建
  - 或保存后案例列表仍为空
  - 本轮停止，不继续 submit

### Step 6｜提交入驻申请

- 操作：
  - 回到工作台底部
  - 点击 `提交入驻申请`
- 当前通过信号：
  - 成功进入 `application status` 页
  - 状态页能回显：
    - `applicationId`
    - `enterpriseId`
    - 申请状态
    - 提交时间
- 当前停机条件：
  - 如果仍被阻断
  - 记录当前 blocker 文案与页面位置
  - 不要继续重复点提交

## 4. 当前页面期望

- 当前页面不再依赖大块说明卡来引导用户。
- 用户应该只看到：
  - 当前可编辑字段
  - 上游真值字段
  - 简洁的提交入口
- 真正的 submit 是否放行，仍只由 Server truth 决定。

## 5. 当前最重要的执行纪律

- 不跳步。
- 必须按：
  - `注册城市 -> 企业认证 -> basic -> factory profile -> case -> submit`
  - 这个顺序执行。
- 任一步失败，都不要直接跳到下一步。

## 6. 当前下一步唯一动作

- 当前阶段完成度：
  - `closure 后进入用户侧真实补齐链`
- 当前下一步唯一动作：
  - 先进入《我的公司》补有效注册城市
- 下一步执行角色：
  - `用户`
- 下一步进入条件：
  - dirty runtime drift 已收干净，可以开始补第一项上游真值
