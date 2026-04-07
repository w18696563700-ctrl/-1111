---
owner: Codex 总控
status: draft
purpose: Formally archive the Round 0 cloud-verified backend current-state and incremental-plan document so that backend existence, runtime, database, and migration evidence can be cited as retrievable truth without unlocking implementation.
layer: L0 SSOT
---

# 《后端现状与增量施工计划（云端核实版）》

## 文书属性
- 当前归属：Round 0
- 当前定位：云端核实盘点文书
- 当前用途：正式记录后端已完成的云端只读核实结果，并为后续字段级、审计级、契约级只读复核提供上游依据
- 非授权事项：
  - 不得作为施工指令
  - 不得作为修复指令
  - 不得作为迁移指令
  - 不得作为部署指令
  - 不得作为发布指令

## 当前对象
- 后端云端核实盘点

## 已冻结核实结论
- 云端开发/运行主机 `47.108.180.198` 已可 SSH 进入并完成只读盘点。
- 云端 `BFF / Server` 已核实存在正式 release 与 `current` 软链。
- 云端运行进程、监听端口、`health/live` 已核实存在并通过。
- 云端 Nginx 外部 canonical path 为 `/api/app/**`，并通过 rewrite 转发到内部 `/bff/**`。
- 云端 BFF 源码与 Server 源码已核实存在。
- PostgreSQL、`schema_migrations`、关键实表、migration 记账与样本计数已核实存在。

## 需修正的旧口径
- 本地 `apps/server` 镜像缺失正式实现，不代表云端后端缺失。
- 云端后端已核实存在并运行。
- 本地正式仓库未见迁移目录，但云端 `Server` 内置 forward migration 机制与 `schema_migrations` 记账已核实存在。
- 不得再把本地镜像不足继续推导为云端未落地。

## 当前未完成项
- 尚未完成字段级对表复核。
- 尚未完成审计样本字段完整性复核。
- 尚未完成 `OpenAPI / contracts / BFF / Server` 返回一致性逐项复核。
- 尚未完成云端 release 与本地镜像差异全量对比。
- 尚未完成结果校验 Agent 独立复核。

## 当前边界
- 当前仍属 Round 0。
- 当前只允许文书补冻结与只读复核。
- 当前不允许施工。
- 当前不允许迁移。
- 当前不允许部署。
- 当前不允许发布。

## 当前下游使用关系
- 本单作为以下论坛补冻结文书的上游依据被使用：
  - `docs/00_ssot/forum_readonly_review_official_archive_addendum.md`
  - `docs/00_ssot/forum_production_staging_smoke_evidence_boundary_addendum.md`
  - `docs/00_ssot/forum_truth_runtime_diff_freeze_addendum.md`

## 最终结论
- 本轮后端判断已从“本地镜像盘点”升级为“云端核实盘点”。
- 但 Round 0 仍未结束。
- 下一步只允许进入字段级 / 审计级 / 契约级只读复核。
- 本单不代表准许施工。
- 本单不代表准许发布。

