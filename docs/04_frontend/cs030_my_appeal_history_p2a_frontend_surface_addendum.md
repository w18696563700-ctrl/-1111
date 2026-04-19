---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Flutter consumption boundary for CS-030 my-appeal-history list/detail.
layer: L4 Frontend
---

# CS-030 我的申诉记录 P2-A Frontend Surface Addendum

## 1. 当前范围

本文件只冻结 Flutter 对以下 app-facing path 的消费：

- `GET /api/app/profile/governance/appeals`
- `GET /api/app/profile/governance/appeals/{appealCaseId}`

## 2. 当前页面边界

当前只允许：

- 我的申诉记录列表页
- 我的申诉记录详情页

当前不允许：

- 处罚历史中心
- 申诉提交页改造
- 申诉聊天页
- 申诉处理页
- whitelist / permanent-ban 用户中心

## 3. 当前交互规则

- happy path 不得依赖手输 `appealCaseId`
- detail 必须从列表项进入
- 无记录时进入受控 empty state
- 不可见 detail 必须进入受控 unavailable state
- 不得伪造成功态或补造 history 数据

## 4. 当前展示边界

列表只展示最小字段：

- 申诉状态
- 处罚类型
- 原因摘要
- 提交时间

详情只展示最小字段：

- 申诉原因
- 处罚类型 / 状态
- 提交时间
- 裁决结果（若已有）
- 裁决说明（若已有）
- 证据附件标识（若已有）

## 5. 当前明确不纳入项

- app 内 appeal submit 新流程
- user-side penalty detail center
- full governance dashboard
- 违规累计分
- AI / OCR / QR
- precheck
- `CS-019`

## 6. 当前 Formal Conclusion

`CS-030 P2-A` 的 Flutter consumption boundary 已冻结。

后续实现只允许围绕当前 list/detail bounded surface 开工。
