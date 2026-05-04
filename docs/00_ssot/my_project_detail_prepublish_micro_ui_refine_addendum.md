---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the smallest Flutter-only UI refinement for the My Project Detail
  prepublish materials page: required labels, formal file icon polish, and
  publish confirmation success-state styling.
layer: L0 SSOT
freeze_date_local: 2026-05-04
version: V1
---

# 《我的项目详情：预发布补资料并发布页微调冻结单》

## 0. 总裁决

本轮只允许进入 Flutter 展示层微调，不改 BFF、Server、contracts、OpenAPI、数据库、项目状态机，也不动云端。

当前真机仍提示 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`，属于云端 Server 仍在旧发布门禁上的运行态问题。本轮不得用 Flutter 绕过 Server，也不得把该 409 写成已解决。

## 1. 当前最小闭环

本轮只做三处：

1. 报价依据资料 checklist 中三类必传资料增加 `（必填项）` 标识：
   - 效果图
   - 尺寸图 / 施工图
   - 材质图 / 材料样板
2. 正式附件列表中非图片文件使用更清晰的文件类型图标，不减少预览、删除、高级信息能力。
3. 发布确认满足真实条件时使用绿色成功态；未满足时继续保持灰色弱化且不可提交。

## 2. 字段与状态真源

| 项 | 真源 | 本轮展示规则 |
| --- | --- | --- |
| 必传资料 | Flutter 现有 `_projectRequiredQuoteBasisAttachmentKinds` | 只给三类必传项加标识 |
| 建议资料 | Flutter 现有资料类型列表 | 设备物料清单、服务清单不加必填标识 |
| 正式附件 | 云端正式附件回读 `ProjectAttachmentReadModel` | 仅优化非图片图标 |
| 发布确认 | 现有 `bottomPlan.kind == publish` | 满足时绿色成功态，未满足时不可点 |

## 3. 不做事项

本轮不做：

1. 不改 BFF、Server、OpenAPI、contracts、数据库、状态机。
2. 不新增 mock，不新增假状态。
3. 不修改上传三步流。
4. 不修改发布接口 action。
5. 不用 Flutter 解决云端 409。
6. 不隐藏真实 `required`、`未满足`、`可提交` 等状态。

## 4. 验收标准

1. 三类必传资料均显示 `（必填项）`。
2. 设备物料清单、服务清单不显示必填。
3. 非图片正式附件图标更清楚，不再只是单个通用文件图标。
4. 预览、删除、高级信息入口不减少。
5. 发布条件满足时，发布确认卡片和按钮呈绿色成功态。
6. 发布条件未满足时，按钮仍禁用。
7. 409 仍明确归入云端部署 / Server 门禁轮处理。

## 5. 风险

| 风险 | 控制方式 |
| --- | --- |
| 仓库已有大量 dirty 文件 | 只隔离本轮文书和 Flutter 目标文件 |
| 必填文案挤压窄屏 | 使用小号红色文本，允许轻量换行 |
| 绿色态误导用户 | 只在现有真实 `publish` plan 下展示 |
| 文件图标改动影响功能 | 只替换视觉，不动按钮和 action |

## 6. 四类判断

| 判断 | 结论 |
| --- | --- |
| 哪个更稳 | Flutter 展示层局部微调 |
| 哪个更省成本 | 不改接口、不改后端、不改云端 |
| 哪个更适合当前阶段 | 先把页面可理解性补齐，409 另走部署验证 |
| 哪个风险更大 | 把 UI 微调和 Server 发布门禁部署混在同一轮 |
