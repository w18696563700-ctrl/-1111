---
owner: Codex 总控
status: frozen
purpose: Freeze the manual acceptance checklist for the enterprise-display company/factory board-separation and case-media repair round, separating release-defect acceptance from current business-state acceptance.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_release_execution_runbook_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
---

# 《企业展示 company/factory 串板块与案例媒体回显维修人工验收清单》

## 1. Scope

- 本清单只用于本轮维修包发版后的真人验收。
- 本清单分成两类：
  - `A 类：发布缺陷验收`
  - `B 类：业务状态验收`
- 当前必须先通过 `A 类`，再解释 `B 类`。

## 2. 验收前提

- 本地前端代码必须为当前维修包最新代码。
- 云端 `Server/BFF` 必须已按发版执行单发布完成。
- 隧道必须可用：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 测试账号必须能进入：
  - `我的 -> 企业展示入驻工作台`
- 当前目标企业固定为：
  - company：`重庆坤特展览展示有限公司`
  - factory：`重庆海川展览工厂`

## 3. A 类｜发布缺陷验收

### 3.1 工厂工作台继续编辑图片回显

- 路径：
  1. `我的`
  2. `企业展示入驻工作台`
  3. 选择 `工厂`
  4. 进入 `案例库`
  5. 点击已有案例 `继续编辑`
- 通过标准：
  - 历史案例图片进入编辑页后立即可见
  - 不再全部退成空白占位图
  - 保存前后图片列表不丢失
- 失败判定：
  - 图片区只有空白占位
  - 进入编辑页后原图瞬间消失
  - 继续编辑只剩 `fileAssetId`，无实际远程图回显

### 3.2 优秀工厂 / 工厂详情标题与案例

- 路径：
  1. `展览`
  2. 找到 `优秀工厂`
  3. 进入目标工厂详情
- 通过标准：
  - 详情主标题显示 `重庆海川展览工厂`
  - 不再把公司主体名当成工厂主标题
  - 案例区若展示 `机械展`，其图片与工厂案例一致
- 失败判定：
  - 工厂详情主标题仍显示公司主体名
  - 工厂案例区显示了明显属于公司的案例图

### 3.3 `public-cases` 链路可达

- 验证方式：
  - 以隧道访问 `GET /api/app/exhibition/enterprise-hub/public-cases/{factory-case-id}`
- 通过标准：
  - 返回 `200`
- 失败判定：
  - 仍返回 `404`
  - 或返回结构缺失核心案例字段

### 3.4 company/factory 不再互串

- 路径：
  1. 进入目标 company 详情
  2. 进入目标 factory 详情
  3. 对比两边案例区
- 通过标准：
  - company 详情不再显示 factory 的 `approved` case
  - factory 详情不再误显示 company 的 draft/current-change case
- 失败判定：
  - company/factory 任一边出现对方案例

## 4. B 类｜业务状态验收

### 4.1 当前 `company` 详情为空的解释

- 截至 `2026-04-19` 的线上真值是：
  - company 新增案例仍在 `submitted current change / draft case`
- 因此若发版后运营状态没有变化：
  - company 详情继续显示“暂无公开案例”
  - 这是 `PASS`
  - 不是 `FAIL`

### 4.2 只有在运营状态变化后，才验 company 案例公开

- 若运营确认：
  - company 当前提交已被批准并应用到公开面
- 才追加以下验收：
  - company 详情显示自己的案例
  - 图片正确
  - 不带 factory 案例

## 5. 验收留证要求

- 每一项至少留 1 份证据：
  - 页面截图
  - 路径说明
  - 时间戳
- 建议最少留证四张：
  1. 工厂案例继续编辑页图片回显
  2. 工厂详情主标题与案例区
  3. company 详情案例区
  4. `public-cases` 返回成功记录

## 6. 不允许的错误判定

- 不允许把：
  - `company 详情当前为空`
  直接判成“仍然串板块”
- 不允许把：
  - `factory 标题显示公司名`
  说成“只是文案问题”
- 不允许把：
  - `继续编辑图片空白`
  解释为“网络慢再等等”

## 7. 当前清单的正式结论语义

- `A 类全部通过`：
  - 代表发布缺陷修复成立
- `B 类按当前业务状态解释通过`：
  - 代表业务状态与发布缺陷已区分清楚
- 只有这两类都解释清楚后：
  - 本轮任务才允许关单
