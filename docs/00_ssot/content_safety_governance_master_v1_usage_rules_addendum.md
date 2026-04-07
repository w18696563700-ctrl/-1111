---
title: Content Safety Governance Master V1 Usage Rules
status: frozen
owner: Control
scope: docs-only
created_at: 2026-04-07
---

# 内容安全治理母版 V1 使用规则

## A. 当前判断对象

本文件独立正式化《内容安全治理母版 V1 使用规则》。

本轮仅允许在 `docs/00_ssot/**` 内完成总控文书补锚；这不构成 `apps/**` 实施，也不允许顺手修改任何代码。

本文件不发明新范围，不放开新实施包，不改变既有 P0/P1/P2 阶段裁决。

## B. 文书定位

《内容安全治理母版 V1》是内容安全与 UGC 治理域的上位真源文书。

它保存平台在该领域的完整能力意图、边界、治理结构、阶段规划与最终目标。

本母版不是当前直接施工包。

任何实施动作必须先经过：

1. 阶段拆分
2. 边界冻结
3. 能力映射
4. 独立复核
5. 总控下一轮唯一动作裁决

缺任一项，不得进入代码实施。

## C. 内容来源保留

以下既有治理内容继续保留，作为《内容安全治理母版 V1》的内容来源，不删除、不废弃：

1. 《社区规则 V1》
2. 《内容审核与处罚机制 V1》
3. 《举报/拉黑/申诉流程 V1》

上述资料可被阶段性拆分和延期，但不得因当前阶段未实施而默认删除。

## D. 适用范围

本规则适用于以下全部内容安全治理对象：

1. 账号资料层
   - 昵称
   - 头像
   - 简介
   - 签名
   - 封面
   - 认证展示信息
2. 公开内容层
   - 发帖
   - 评论
   - 回复
   - 项目介绍
   - 企业介绍
   - 广场内容
   - 公开互动内容
3. 私域互动层
   - 私信
   - 会话消息
   - 消息预览
   - 陌生人消息入口
   - 互动提醒内容
4. 治理动作层
   - 举报
   - 拉黑
   - 审核
   - 处罚
   - 申诉
   - 审计留痕
   - 存量复扫
   - 风险分级
   - 人工审核台

## E. 优先级与引用关系

内容安全治理域的当前优先级为：

1. 《内容安全治理母版 V1 控制包》
2. 本文件：`content_safety_governance_master_v1_usage_rules_addendum.md`
3. `content_safety_governance_master_v1_control_package_positioning_addendum.md`
4. `content_safety_capability_tracking_table_v1.md`
5. 各 P0 子包 freeze 文书
   - `profile_safety_p0_freeze_addendum.md`
   - `forum_report_p0_freeze_addendum.md`
   - `block_p0_freeze_addendum.md`
   - `admin_review_p0_freeze_addendum.md`
   - `safety_audit_p0_freeze_addendum.md`
6. 实施 unlock / execution prompt / implementation receipt
7. 结果校验文书
8. 联调发布判断

如出现冲突，以优先级高者为准。

本文件与关键文书的关系：

- `content_safety_governance_master_v1_control_package_positioning_addendum.md` 冻结控制包定位、上位真源关系、docs-only 阶段属性。
- 本文件冻结母版如何被使用、如何拆包、防遗漏检查如何生效。
- `content_safety_capability_tracking_table_v1.md` 是唯一正式防遗漏追踪表。
- 各 P0 freeze 文书只冻结对应子包边界，不得删除母版中未纳入当前阶段的能力点。
- 结果校验文书只能在独立复核后作为 PASS / NO-GO 依据；聊天回执不得单独作为正式验收依据。

## F. 拆分原则

允许将母版按 P0 / P1 / P2 / 暂缓项拆分，但必须遵守以下规则：

1. 拆分不等于删减。
   - 未纳入当前阶段的能力点，不得默认视为取消、废弃或不再需要。
2. 拆分必须映射。
   - 母版中的每一个能力点，都必须进入 `content_safety_capability_tracking_table_v1.md` 并拥有唯一编号。
3. 拆分必须标去向。
   - 每一项未纳入当前阶段的能力点，都必须明确当前不纳入原因、预计归属阶段、后续回收节点、当前挂靠文书。
4. 拆分必须写边界。
   - 每一份阶段冻结单，必须明确本轮纳入项、本轮明确不纳入项、不纳入但保留在母版中的项、本轮禁止越界项。

## G. 追踪机制

`content_safety_capability_tracking_table_v1.md` 是母版防遗忘、防拆丢、防默认删除的唯一正式追踪表。

任何阶段推进前，必须先检查并按需更新该表。

任何阶段验收后，也必须回写该表。

未经该表登记的能力点，不得视为：

- 已冻结
- 已实施
- 已完成
- 已延期
- 已删除

## H. 阶段推进前置条件

任何内容安全阶段包进入实施前，必须同时满足：

1. 母版已正式定位为上位真源。
2. 本使用规则已存在并生效。
3. 能力追踪总表已建立。
4. 当前阶段冻结单已完成。
5. 当前阶段的纳入项、排除项、延期项已和追踪总表逐项对齐。
6. 当前阶段的验收标准已明确。
7. 当前阶段已指定独立复核动作与责任角色。

缺任一项，均不得进入代码实施。

## I. 总控职责

总控在本域中的职责是：

1. 识别母版与实施包的关系。
2. 维护能力追踪不丢失。
3. 决定阶段边界。
4. 派工到正确角色。
5. 要求独立复核。
6. 推出下一轮唯一动作。

总控不是执行者。

总控不得越位代替：

- 前端 Agent
- 后端 Agent
- BFF Agent
- 结果校验 Agent
- 联调发布 Agent

## J. 文书冻结职责

总控文书冻结角色负责：

1. 把阶段边界写死。
2. 把纳入 / 排除 / 延期项写死。
3. 把禁止越界项写死。
4. 让当前实施包与母版编号逐项对齐。

总控文书冻结不得跳过能力追踪总表直接“就地开工”。

## K. 执行回执与验收规则

实施回执只能证明“执行者声称完成了什么”，不能直接证明“系统真实完成了什么”。

结果校验必须独立复核以下内容：

1. 是否遗漏母版能力点。
2. 是否有能力点被私自删除。
3. 是否存在“文书写了但代码没落地”。
4. 是否存在“代码落地了但追踪总表未回写”。
5. 是否存在“实施超出当前阶段边界”。
6. 是否存在“聊天回执未落文书却被当作正式 PASS 依据”。

结果校验必须落成正式文书并登记 `source_of_truth_map.md`。

未经独立复核文书确认，不得将当前能力点状态改写为“已完成”。

## L. 状态定义

能力追踪总表中的状态统一使用：

- 未开始
- 待冻结
- 冻结中
- 待实施
- 实施中
- 待复核
- 已完成
- 明确延期
- 暂停

## M. 变更规则

如需新增、拆分、合并、延期内容安全能力点，必须：

1. 先更新母版或母版附录。
2. 再更新能力追踪总表。
3. 再更新相关阶段冻结单。
4. 最后才允许进入实施。

禁止在没有文书更新的前提下，直接在执行线程中私自增加或删除能力点。

## N. 强制检查动作

以后每一轮总控输出，必须包含以下检查项：

> 本轮是否有母版能力点未登记、未承接、未回收、被默认删除。

以后每一轮结果校验输出，必须包含以下检查项：

> 本轮是否发生母版能力点遗漏、越界实施或默认删除。

若任一项无法确认，则当前阶段不得进入下一轮实施或最终完成裁决。

## O. Current Stage Check

截至本文件落盘时：

- `content_safety_governance_master_v1_control_package_positioning_addendum.md` 已存在。
- `content_safety_capability_tracking_table_v1.md` 已存在。
- 五份 P0 子包 freeze 文书已存在。
- `Profile Safety P0 + Safety Audit P0` 已完成当前开发阶段验收。
- `Forum Report P0` 仍在处理中，当前阻断集中在角色越界补救、结果校验文书化、BFF 云端 artifact alignment / final rerun、`CS-013` 最小查看边界裁决。
- `Block P0` 未实施。
- `Admin Review P0` 未实施。
- P1 / P2 能力仍为明确延期，不得擅自打开。

本轮是否有母版能力点未登记、未承接、未回收、被默认删除：无新增发现。CS-001 至 CS-034 已登记；当前未实施项保留在 `content_safety_capability_tracking_table_v1.md` 中。

## P. Next Unique Action

回到 `Forum Report P0` 当前阻断链：

`Forum Report P0 final result verification rerun`

该下一轮必须由 `结果校验 Agent` 落成正式结果校验文书并登记 `source_of_truth_map.md` 后，才允许总控继续做 final completion judgment。

不得因此打开：

- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- precheck
- 自动隐藏 / 下架
- 处罚 / 申诉
- release-prep / launch approval

