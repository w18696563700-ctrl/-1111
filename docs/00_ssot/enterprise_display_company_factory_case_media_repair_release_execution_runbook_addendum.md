---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded production release execution runbook for the enterprise-display company/factory board-separation and case-media repair round, so deployment, smoke, and data-readiness are executed in the correct order.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_task_sheet_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
  - apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql
  - apps/server/scripts/enterprise_hub_case_media_post_release_smoke.sh
---

# 《企业展示 company/factory 串板块与案例媒体回显维修发版执行单》

## 1. Scope

- 本执行单只服务于当前维修包：
  - `enterprise display / company-factory board separation and case-media repair`
- 本执行单 author：
  - 云端 `Server` 发布
  - 云端 `BFF` 发布
  - 隧道 smoke
  - 数据修复前置只读核查
- 本执行单不 author：
  - 线上写库修复直接执行
  - 审核运营决策替代
  - Flutter 发版
  - 与 `enterprise_hub` 无关的合包发布

## 2. 当前已冻结的发布前事实

- 当前云端正式拓扑固定为：
  - `47.108.180.198`
  - `nginx :80`
  - `BFF :3000`
  - `Server :3001`
- 当前唯一正式 app-facing 验证隧道固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 当前线上活跃缺陷已确认：
  - 活跃 `BFF/Server` 发布包都不含 `public-cases/:caseId`
  - 活跃 `Server` 私有 `getCaseDetail(caseId)` 不返回 `caseImageUrlMap`
- 当前线上业务状态也已确认：
  - `company` 公开详情为空，是因为当前只有 `submitted current change + draft case`
  - `factory` 公开详情显示自己的 `approved` 案例

## 3. 本轮 release object

### 3.1 Server 必须带上的修复

- `public-cases/:caseId` 正式路由
- 私有 `getCaseDetail(caseId)` 返回 `caseImageUrlMap`
- case 读取、提升、快照、apply 全链路按 `enterpriseId + boardType` 收口
- factory 对外标题统一走 `factoryName`

### 3.2 BFF 必须带上的修复

- app-facing `public-cases/:caseId` 正式可达
- `caseImageUrlMap` / `showcaseImageUrlMap` 不被 read-model 静默裁掉
- factory list / detail / recommendation 命名一致

### 3.3 Flutter 当前轮定位

- Flutter 不需要先于云端发布。
- 当前轮真人验收使用本地最新代码配合云端新发布包完成。
- 若云端 smoke 未通过，不得先要求 Flutter 人工兜底验收。

## 4. Release Preconditions

- 必须先记录当前 rollback target：
  - `readlink -f /srv/apps/server/current`
  - `readlink -f /srv/apps/bff/current`
- 必须确认新 release artifact 已完成 build。
- 必须确认新 release artifact 包含目标代码，而不是旧目录重打包。
- 必须确认当前维修包定点测试已通过。
- 必须确认只读 SQL 与只读 smoke 脚本已经就位。
- 在云端 smoke 通过前：
  - 不得执行 `enterprise_hub_case_media_repair_template.sql`
  - 不得对 `enterprise_case` / `enterprise_listing` / `enterprise_change_request` 做人工写库

## 5. Canonical Release Order

### 5.1 Step A｜记录发布前锚点

- 记录：
  - `PREV_SERVER_RELEASE=$(readlink -f /srv/apps/server/current)`
  - `PREV_BFF_RELEASE=$(readlink -f /srv/apps/bff/current)`
- 记录当前 systemd 状态：
  - `systemctl is-active exhibition-server`
  - `systemctl is-active exhibition-bff`
- 保存当前时间戳与 release operator。

### 5.2 Step B｜先发 Server

- 在 `/srv/releases/server/<new-release>` 制备新版本。
- 在新 release 内完成 build 与产物核验。
- 切换：
  - `/srv/apps/server/current -> /srv/releases/server/<new-release>`
- 重启：
  - `systemctl restart exhibition-server`
- 只读核验：
  - `systemctl is-active exhibition-server`
  - `curl http://127.0.0.1:3001/server/exhibition/enterprise-hub/public-cases/<factory-case-id>`
- 若此时 `Server` 仍无 `public-cases` 或仍缺 `caseImageUrlMap`：
  - 直接停止发布
  - 不得继续发 `BFF`

### 5.3 Step C｜再发 BFF

- 在 `/srv/releases/bff/<new-release>` 制备新版本。
- 在新 release 内完成 build 与产物核验。
- 切换：
  - `/srv/apps/bff/current -> /srv/releases/bff/<new-release>`
- 重启：
  - `systemctl restart exhibition-bff`
- 只读核验：
  - `systemctl is-active exhibition-bff`
  - `curl http://127.0.0.1:3000/api/app/exhibition/enterprise-hub/public-cases/<factory-case-id>`

### 5.4 Step D｜隧道 post-release smoke

- 在本地开启隧道：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 运行：
  - `bash apps/server/scripts/enterprise_hub_case_media_post_release_smoke.sh`
- 若已有合法 app bearer：
  - `APP_TOKEN=<token> bash apps/server/scripts/enterprise_hub_case_media_post_release_smoke.sh`

### 5.5 Step E｜只读数据审计

- 运行只读 SQL：
  - `apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql`
- 只读审计用于回答：
  - 是否仍有 hard mismatch
  - 是否仍有缺失 `file_asset`
  - 当前公司 `current change` 是否仍为 `submitted`
  - 当前工厂 `approved` 案例是否仍稳定存在

### 5.6 Step F｜人工验收

- 只在以下条件同时成立后进入：
  - `Server` / `BFF` 新 release 均 active
  - post-release smoke 通过
  - 只读数据审计无新异常
- 人工验收以：
  - `docs/00_ssot/enterprise_display_company_factory_case_media_repair_manual_acceptance_checklist_addendum.md`
  为唯一清单

## 6. Hard Stop Conditions

- 若 `public-cases/:caseId` 任一层仍返回 `404`：
  - `No-Go`
- 若私有 `cases/:caseId` 仍无 `caseImageUrlMap`：
  - `No-Go`
- 若 `factory` 详情标题未显示 `factoryName`：
  - `No-Go`
- 若 `company` 详情开始展示 `factory` 的 `approved` case：
  - `No-Go`
- 若 `BFF` 或 `Server` 任一 systemd 未稳定 active：
  - `No-Go`
- 若 only-read smoke 未通过：
  - `No-Go`

## 7. 关于 company 详情验收的强制解释

- 截至 `2026-04-19`：
  - `company` 当前新增案例仍在 `submitted current change / draft case`
- 因此本轮发布后，若运营状态未变化：
  - `company` 详情继续显示空案例，属于 `PASS`
- 只有在以下前提成立后：
  - 运营确认该变更已被批准并应用到公开面
- 才允许把：
  - `company` 详情展示自己的案例
  作为必过项

## 8. Release Completion Criteria

- 本轮发版完成必须同时满足：
  1. `public-cases` 不再 `404`
  2. 工厂工作台继续编辑图片可通过私有 detail 回显
  3. `factory` 公开详情标题稳定为 `factoryName`
  4. `company` 公开详情不再误显示 `factory` 的 case
  5. post-release smoke 通过
  6. 人工验收完成并留证

## 9. After-Release Next Action

- 若本执行单完成且通过：
  - 才允许进入“是否需要线上写库修复”的独立判断
- 若只读核查已证实当前无 hard mismatch：
  - 优先处理发布与运营状态
  - 不得把写库修复作为默认动作
