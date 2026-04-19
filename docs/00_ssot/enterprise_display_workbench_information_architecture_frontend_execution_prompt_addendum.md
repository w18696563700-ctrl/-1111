# 《enterprise display workbench information architecture frontend execution prompt》

## 当前阶段
- 主线：enterprise display full closure mainline
- 子阶段：workbench information architecture closure
- 当前完成度：verification 中

## 当前唯一动作
- 发给前端的唯一执行口令如下。

```text
你现在是：
- enterprise display full closure mainline
- workbench information architecture frontend owner

你的唯一目标是：
- 重构企业展示工作台页面的信息架构
- 把“当前页可编辑内容”和“上游真值只读内容”彻底分层
- 让用户进入页面后，先看到自己现在要做什么，再看到哪些信息来自上游

这一步只做：
- workbench 页面结构重排
- 区块层级重排
- 说明文案降噪
- 企业认证只读区降级

这一步不做：
- submit/status transport
- geocoding 能力逻辑
- workbench truth 扩写
- admin review/publish
- public recommendation/list/detail
- release / deploy

当前问题已确认：
1. 页面顶部太像后台，不像用户任务页。
2. 基础资料区前面的说明过重，用户还没开始填，就先看到一大段系统解释。
3. 企业名称 / 注册城市 / 成立日期 这组上游真值虽然已只读，但仍然插在主表单里，造成“当前页坏掉字段”的感受。
4. 企业认证整块位置不对；它是只读信息，不该横插在主编辑流中间。
5. 板块画像才是当前页的核心编辑任务，但现在被压到后面，主次倒置。

这次只允许修改：
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
- 与此次页面结构直接相关的最小测试文件

这次不允许修改：
- apps/server/**
- apps/bff/**
- apps/admin/**
- submit/status 已通过的消费面
- geocoding 热修逻辑
- ED-4 / ED-5 范围

你必须完成：
1. 顶部工作台区降噪，只保留：
   - 当前板块标题
   - 板块切换
   - 当前状态一句话
2. 基础资料区只保留当前页真可编辑字段：
   - 一句话简介
   - 展示介绍
   - 详细地址
   - 团队规模
   - 合作方式
   - 联系人展示开关
3. 企业名称 / 注册城市 / 成立日期 必须从主编辑流中抽离，形成紧凑的“上游真值区”：
   - 明确来源
   - 明确当前页不能改
   - 明确修复入口
4. 企业认证整块降级处理：
   - 要么折叠
   - 要么摘要化
   - 不得继续占据主编辑流中段的大块空间
5. 板块画像必须前移，成为页面核心编辑区之一。
6. 整体页面必须满足：
   - 用户先看到“现在要做什么”
   - 再看到“哪些信息只是上游同步”
   - 最后看到补充说明
7. 文案要明显变短，禁止整页堆系统说明。
8. 至少补一条测试覆盖：
   - 页面首屏优先出现主编辑任务，而不是企业认证大块只读内容
9. 至少补一条测试覆盖：
   - 上游真值区与基础资料编辑区在结构上已分离

你必须遵守：
1. 不得新增第二套城市选择器。
2. 不得新增第二套成立日期输入源。
3. 不得把上游真值重新塞回基础资料主表单。
4. 不得把企业认证区继续放在主编辑流中间。
5. 不得为了“视觉好看”隐藏当前阻断来源。
6. 不得顺手扩到 submit/status、admin review/publish、public list/detail。

完成标准：
- 结果必须证明：
  - 页面主任务清晰
  - 基础资料只包含当前页可编辑字段
  - 上游真值区被独立分层
  - 企业认证区不再打断主编辑流
  - 板块画像进入用户主视线

交付回执要求：
1. 修改文件清单
2. 为什么之前是错误信息架构
3. 现在如何区分 主编辑区 / 上游真值区 / 认证摘要区
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
```
