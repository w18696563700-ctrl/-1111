---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded rollback and fail-closed runbook for the enterprise-display company/factory board-separation and case-media repair round, so production rollback is explicit, auditable, and does not improvise target pointers after the fact.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_release_execution_runbook_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
---

# 《企业展示 company/factory 串板块与案例媒体回显维修失败回滚单》

## 1. Scope

- 本回滚单只服务于本轮维修包发布失败时的 bounded rollback。
- 本回滚单只 author：
  - `Server` 回滚
  - `BFF` 回滚
  - rollback 后的最小运行态核验
- 本回滚单不 author：
  - 数据库 time-travel
  - release artifact 重建
  - 后续 root-cause 报告替代

## 2. Mandatory Rollback Inputs

- 回滚前必须已经记录：
  - `PREV_SERVER_RELEASE`
  - `PREV_BFF_RELEASE`
- 若发布前未记录 previous target：
  - 不得声称具备正式回滚准备
  - 不得临时凭目录时间猜测 rollback target

## 3. Rollback Trigger Conditions

- 任何一项成立即触发回滚判断：
  - `public-cases/:caseId` 仍返回 `404`
  - 私有 `cases/:caseId` 仍无 `caseImageUrlMap`
  - `BFF` 或 `Server` 重启后无法稳定 active
  - `factory` 详情标题错误，不再显示 `factoryName`
  - 发布后出现新的 `5xx`
  - 发布后 `company` 详情开始误带 `factory approved case`
  - smoke 脚本出现关键断言失败

## 4. Canonical Rollback Order

### 4.1 先回 BFF

- 原因：
  - 新 `BFF` 依赖新 `Server` 的 `public-cases` 与媒体字段语义
  - 若先回 `Server`，保留新 `BFF` 会形成路由和字段不兼容窗口
- 步骤：
  1. `ln -sfn "$PREV_BFF_RELEASE" /srv/apps/bff/current`
  2. `systemctl restart exhibition-bff`
  3. `systemctl is-active exhibition-bff`

### 4.2 再回 Server

- 步骤：
  1. `ln -sfn "$PREV_SERVER_RELEASE" /srv/apps/server/current`
  2. `systemctl restart exhibition-server`
  3. `systemctl is-active exhibition-server`

## 5. Minimal Rollback Verification

- rollback 后必须完成以下最小核验：
  - `systemctl is-active exhibition-bff = active`
  - `systemctl is-active exhibition-server = active`
  - `curl http://127.0.0.1:3000/api/app/exhibition/enterprise-hub/enterprises/<factory-enterprise-id>?boardType=factory` 返回 `200`
  - `curl http://127.0.0.1:3001/server/exhibition/enterprise-hub/enterprises/<factory-enterprise-id>?boardType=factory` 返回 `200`
- 回滚后若 `public-cases` 恢复成旧版 `404`：
  - 这是已知功能回退
  - 必须记录为 `expected residual impact`
  - 不得再误写成“未知线上故障”

## 6. Residual Impact After Rollback

- 若本轮回滚成功，以下已知问题会一起恢复：
  - `public-cases/:caseId` 不可用
  - 工厂工作台继续编辑依旧可能不回显案例图片
  - factory/public naming 修复不会保留
- 因此回滚 verdict 只能解释为：
  - `runtime restored`
  - 不是 `feature fixed`

## 7. Fail-Closed Rules

- rollback 触发后：
  - 不得继续执行写库修复模板
  - 不得要求真人继续按新功能清单验收
  - 不得把 `company 详情仍为空` 单独解释成 rollback 失败
- rollback 后需要单独补留证：
  - 触发时间
  - 触发原因
  - 回滚执行人
  - 使用的 previous release pointer
  - rollback 后 systemd 状态
  - rollback 后最小 curl 核验结果

## 8. Formal Conclusion

- 本轮 rollback 的唯一合法语义是：
  - `restore previous release pair`
- 本轮 rollback 不是：
  - 保留部分修复
  - 单边保留新 `BFF` 或新 `Server`
  - 一边新一边旧长期运行
