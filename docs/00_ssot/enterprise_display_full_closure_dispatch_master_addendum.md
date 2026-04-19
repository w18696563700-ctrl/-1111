---
owner: Codex 总控
status: frozen
purpose: Freeze the serial dispatch order for fully closing the enterprise-display mainline end to end, from profile-side entry and workbench truth to admin review/publish and public company/factory/supplier visibility.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_mainline_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/my_company_enterprise_display_entry_prd_addendum.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
---

# 《企业展示全闭环主线 Dispatch Master》

## 1. 主线目标

- 当前唯一目标固定为：
  - 把 `企业展示入驻工作台 + 公司/工厂/供应商公域展示` 做成一条完整可验收链
- 当前不接受的“假完成”固定为：
  - 只有工作台，没有公域可见实体
  - 只有公域列表，没有真实提交流
  - 只有 server-admin API，没有真实 review/publish 可操作链

## 2. 串行阶段总表

| 子阶段 | 阶段目标 | 第一执行角色 | 完成产物 | 下一步唯一动作 |
| --- | --- | --- | --- | --- |
| `ED-1` | 修 organization / certification 上游真值 | 后端 | workbench 可消费的有效城市/成立日期/地址真值 | `ED-2` |
| `ED-2` | 收 workbench `basic / profile / case / readiness` | 后端 -> 前端 | workbench 保存、回读、blocker、submit-ready 闭环 | `ED-3` |
| `ED-3` | 收 application `create / submit / status / continue` | 后端 -> BFF -> 前端 | 真实申请提交流和状态续办链 | `ED-4` |
| `ED-4` | 收 admin `review / publish / offline / freeze` | 后端 -> Admin | 审核与上架最小运营闭环 | `ED-5` |
| `ED-5` | 收 public `recommendation / list / detail` | 后端 -> BFF -> 前端 | 公司/工厂/供应商真实实体公域链 | `ED-6` |
| `ED-6` | 收首页卡片与推荐位回显 | 后端 -> BFF -> 前端 | `home -> list/detail` 真实导流链 | `ED-7` |
| `ED-7` | 做全链结果校验与 closure | 结果校验 | 私域到公域完整 through-chain 验证结论 | 下一主线裁决 |

## 3. 分阶段详细路由

### ED-1 上游真值修复

1. 阶段目标

- 修掉 `organization.provinceCode/cityCode = 000000`
- 修掉 `certification.establishedAt/address = null` 导致的工作台必填真值缺失

2. 阶段前置

- [enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md) 已冻结

3. 当前主阻塞

- mobile 没法对无效城市真值发出 `PUT basic`

4. judgment

- `Go`

5. dispatch

- `后端` 先做

6. implementation

- 只改 organization / certification truth owner 与受控修复链
- 禁止让前端绕过无效真值

7. verification

- `organization/mine` 不再返回 `000000`
- workbench 不再提示“注册城市真值不可用”

8. closure

- workbench 具备真实 basic save 前提

9. next route

- 进入 `ED-2`

### ED-2 工作台闭环

1. 阶段目标

- 打通 `basic / boardProfile / case / upload / readiness`

2. 阶段前置

- `ED-1 closure`

3. 当前主阻塞

- `basic.*` 当前为空
- `submitReady` 不能靠前端假推导

4. judgment

- `Go only after ED-1`

5. dispatch

- `后端` 先收 truth / readiness
- `前端` 后收消费与刷新行为

6. implementation

- `Server` 负责 read/write/readiness
- `Flutter` 负责真实消费与 after-save refresh

7. verification

- `PUT basic` 真实发出并回读
- `PUT profiles/{company|factory|supplier}` 回读一致
- 至少 1 case 能创建并回读

8. closure

- workbench 不再只是占位编辑器，而是可测试工作台

9. next route

- 进入 `ED-3`

### ED-3 申请提交与状态闭环

1. 阶段目标

- 打通 `applications create / submit / status / continue`

2. 阶段前置

- `ED-2 closure`

3. 当前主阻塞

- 提交前阻断和提交后状态还没与真实组织会话完整复签

4. judgment

- `Go only after ED-2`

5. dispatch

- `后端 -> BFF -> 前端`

6. implementation

- `Server` 负责 application state
- `BFF` 只做 app-facing transport/normalization
- `Flutter` 负责 status/continue handoff

7. verification

- 真实已登录组织可以提交
- `GET applications/{applicationId}` 能回到真实申请状态
- revision/approved/rejected 最小状态可见

8. closure

- 用户侧申请链闭合

9. next route

- 进入 `ED-4`

### ED-4 审核与上架最小运营闭环

1. 阶段目标

- 打通 `review / publish / offline / freeze`

2. 阶段前置

- `ED-3 closure`

3. 当前主阻塞

- 审核/上架能力存在于 server-admin truth，但还没被纳入当前同一验收链

4. judgment

- `Go only after ED-3`

5. dispatch

- `后端` 先收 server-admin truth
- `Admin` 再收最小操作面

6. implementation

- 必须只限 enterprise-display 相关审核与上架
- 不得扩成平台级 Admin 主线

7. verification

- reviewer 能看 application list/detail
- approve/reject 生效
- operator 能 publish/offline/freeze

8. closure

- 从 submit 到 published 有真实运营承接

9. next route

- 进入 `ED-5`

### ED-5 公域实体链

1. 阶段目标

- 让 `公司 / 工厂 / 供应商` 在公域 recommendation/list/detail 出现真实实体

2. 阶段前置

- `ED-4 closure`

3. 当前主阻塞

- 现有 list/recommendation 多为空状态
- real entity detail chain 未证明

4. judgment

- `Go only after ED-4`

5. dispatch

- `后端 -> BFF -> 前端`

6. implementation

- `Server` 只返回 published + visible entity
- `BFF` 保持 app-facing shape
- `Flutter` 收列表/详情消费

7. verification

- 三个板块至少各有可见真实实体或明确空态规则
- list -> detail 可真实串联

8. closure

- 公域企业展示从 carrier 变成真实对象链

9. next route

- 进入 `ED-6`

### ED-6 首页卡片与推荐位回显

1. 阶段目标

- 把首页 `优秀公司 / 优秀工厂 / 优秀供应商` 和 recommendation slots 收到真实 published entity

2. 阶段前置

- `ED-5 closure`

3. 当前主阻塞

- 首页卡片、recommendation path 现在还不能证明真实实体闭环

4. judgment

- `Go only after ED-5`

5. dispatch

- `后端 -> BFF -> 前端`

6. implementation

- recommendation slots 只能服务已发布且 visible 的 listing
- 首页不能变成第二个 enterprise shell

7. verification

- home card -> list/detail 可导流
- card/recommendation 不再只是空 carrier

8. closure

- 私域提交结果开始反映到公域首页

9. next route

- 进入 `ED-7`

### ED-7 全链结果校验

1. 阶段目标

- 验证从 `我的楼入口` 到 `公域详情` 的完整 through-chain

2. 阶段前置

- `ED-6 closure`

3. 当前主阻塞

- 历史文书只证明局部 slice，不证明完整 through-chain

4. judgment

- `Go only after ED-6`

5. dispatch

- `结果校验`

6. implementation

- 不写代码，只做 end-to-end runtime verification

7. verification

- 统一用一个真实 organization / enterprise / application / published listing 做完整复测
- 必须覆盖：
  - `我的楼 -> 企业展示入驻`
  - `boardType 选择`
  - `workbench save`
  - `submit`
  - `admin review/publish`
  - `home/recommendation`
  - `list/detail`

8. closure

- 输出 `enterprise display full closure conclusion`

9. next route

- 交回总控裁决下一主线

## 4. 当前禁止事项

- 禁止把 `企业展示工作台` 单独做完就宣称主线完成
- 禁止只把公域列表/详情做出来，不收 submit/review/publish
- 禁止先开 `个人/团队`
- 禁止让 `BFF` 持有第二状态机
- 禁止让 `Flutter` 推导 submit-ready 替代 `Server`
- 禁止把 enterprise-display 线扩大成平台级 Admin 或支付主线

## 5. 当前下一步

- 当前阶段完成度：
  - `dispatch 完成`
- 当前下一步唯一动作：
  - 按 `ED-1` 向 `后端` 发出上游真值修复执行任务
- 下一步执行角色：
  - `后端`
- 下一步进入条件：
  - [enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md) 继续有效，且没有新增反证说明当前根因转移
