# 《enterprise display workbench truth fields UX closure frontend execution prompt》

## 当前阶段
- 主线：enterprise display full closure mainline
- 子阶段：workbench truth fields UX closure
- 当前完成度：verification 中

## 当前唯一动作
- 发给前端的唯一执行口令如下。

```text
你现在是：
- enterprise display full closure mainline
- workbench truth fields UX closure frontend owner

你的唯一目标是：
- 收掉企业展示工作台里 注册城市 / 成立日期 / 详细地址辅助动作 这三个字段的剩余表单语义问题
- 让用户一眼看懂：
  - 哪些是当前页可编辑字段
  - 哪些是上游真值只读字段
  - 缺值时应该去哪里修

这一步只做：
- workbench 基础资料区的字段语义与辅助文案
- 只读真值展示样式
- 地址辅助动作的层级整理

这一步不做：
- submit/status transport
- geocoding 能力逻辑
- workbench truth 扩写
- admin review/publish
- public recommendation/list/detail
- release / deploy

当前 blocker：
- verifier 已确认：
  1. 注册城市 虽然已经从伪输入框改成只读展示，但它仍然表现成当前页必填缺口；用户在当前页无法修，却会在当前页被它阻断保存。
  2. 成立日期 也是同类问题：当前页只读、当前页不可修，但仍作为当前页保存前提暴露给用户。
  3. 详细地址 -> 用当前位置回填 虽然不再崩溃，但仍然过于贴近主表单，容易让用户误以为补详细地址就能绕过上游真值缺口。

这次只允许修改：
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
- apps/mobile/lib/core/location/china_region_picker.dart
- 与这三个字段直接相关的最小测试文件

这次不允许修改：
- apps/server/**
- apps/bff/**
- apps/admin/**
- submit/status 已通过的消费面
- geocoding 热修逻辑
- ED-4 / ED-5 范围

你必须完成：
1. 注册城市 必须被渲染成明确的“上游真值字段”，不是当前页表单项：
   - 缺值时明确写清：
     - 当前字段来源于 我的公司
     - 当前页不能修改
     - 如需继续，请先去 我的公司 补全注册城市
   - 不得继续使用会让用户误判为“当前页待填写”的必填输入语义
2. 成立日期 必须被渲染成明确的“上游真值字段”，不是当前页表单项：
   - 缺值时明确写清：
     - 当前字段来源于 企业认证/营业执照识别结果
     - 当前页不能修改
     - 如需继续，请先完成企业认证信息补齐
3. 详细地址 保持真实可编辑输入。
4. 用当前位置回填 必须被降级成明确的辅助动作区：
   - 不得再像输入框里的第二层盒子
   - 必须让用户看懂它只是“辅助填写详细地址”
   - 不会修复 注册城市 / 成立日期 这类上游真值问题
5. 基础资料区的文案层级必须明确区分：
   - 当前页可编辑
   - 上游真值只读
   - 保存阻断来自哪里
6. 至少补一条测试覆盖：
   - 注册城市 缺值时展示“去我的公司修”的上游提示
7. 至少补一条测试覆盖：
   - 成立日期 缺值时展示“来自企业认证”的上游提示
8. 至少补一条测试覆盖：
   - 用当前位置回填 作为辅助动作展示，不再伪装成表单主输入

你必须遵守：
1. 不得新增第二套城市选择器。
2. 不得新增第二套成立日期输入源。
3. 不得为了“视觉简洁”隐藏当前真实阻断。
4. 不得把上游真值缺失伪装成当前页用户填错。
5. 不得顺手扩到 submit/status、admin review/publish、public list/detail。

完成标准：
- 结果必须证明：
  - 用户能一眼区分“当前页可编辑字段”和“上游真值字段”
  - 注册城市 缺值时不会再被理解成坏掉的当前页必填框
  - 成立日期 缺值时不会再被理解成当前页日期输入器
  - 用当前位置回填 明确是详细地址辅助动作，不会误导成解锁上游真值的手段

交付回执要求：
1. 修改文件清单
2. 这三个字段之前为什么构成错误表单语义
3. 现在如何区分 当前页可编辑字段 与 上游真值字段
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
```
