---
owner: Codex 总控
status: closed
purpose: >
  Record the residual duplicate-submit defect discovered during the
  2026-04-15 staging app-facing smoke for the exhibition bid-submit
  full-version corridor, freeze the ruling, and constrain the next
  repair round to backend truth plus BFF normalization only.
layer: L0 SSOT
freeze_date_local: 2026-04-15
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_bid_submit_full_version_stage_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_bid_submit_full_version_truth_freeze_addendum.md
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
  - docs/03_bff/exhibition_bid_submit_full_version_bff_surface_addendum.md
  - docs/04_frontend/exhibition_bid_submit_full_version_frontend_surface_addendum.md
---

# 《竞标提交页满分版改造收尾残余缺陷单》

## 1. Defect Summary

- defect_id:
  - `EXH-BID-FULL-RESIDUAL-001`
- defect_title:
  - `同项目重复竞标提交命中 bids_bid_no_key 并向 App 暴露 500`
- severity:
  - `high`
- owner_layer:
  - `Server truth primary`
  - `BFF normalization secondary`
- frontend_status:
  - `not primary cause`

## 2. Frozen Facts

- `2026-04-15` 本地前端结构改造、云端 staging 运行面对齐、supplier smoke 身份链、三附件真实上传链都已经成立。
- staging app-facing 真实成功提交已经发生过一次：
  - `POST http://127.0.0.1:3100/api/app/bid/submit`
  - `projectId = 5020e1fe-0c49-44c0-8b04-cae5174b59d1`
  - 返回 `202`
  - 返回 `bidId = dce5f2a4-8d4a-41bc-bbe4-d995bfad6d8d`
- staging server 直提也成功发生过一次：
  - `POST http://127.0.0.1:3101/server/bids`
  - `projectId = 6ed769e1-b6f0-4452-b15d-63447d856705`
  - 返回 `202`
  - 返回 `bidId = 2de53935-97d5-44bc-b954-ba23e757cdb4`
- 同项目再次提交时，BFF 当前暴露的是 `500`，不是受控的业务拒绝。
- server journal 已记录数据库错误：
  - `QueryFailedError: duplicate key value violates unique constraint "bids_bid_no_key"`
  - `detail: Key (bid_no)=(BID-EXH-2026-EBE463) already exists.`
  - `code: 23505`

## 3. Reproduction

### 3.1 Reproduced Path

- 先在同一项目上成功写入一条 `bid`。
- 再次以同一项目走提交链路。
- 结果：
  - server 命中数据库唯一键冲突
  - BFF 对上游 `500` 做了通用兜底
  - App 收到：
    - `statusCode = 500`
    - `code = AUTH_RESOURCE_UNAVAILABLE`
    - `message = Internal server error`

### 3.2 What This Proves

- 当前失败不是：
  - 上传链失败
  - supplier 身份链失败
  - submit 路由缺失
  - BFF surface 缺 6 字段
- 当前失败是：
  - `bid_no` 生成/唯一性语义与真实竞标实例语义不一致
  - server 没把该场景收口为受控业务错误
  - BFF 也没有把该场景归一成 app-facing 重复提交错误

## 4. Root-Cause Ruling

### 4.1 Primary Ruling

- `bid_no` 现在表现为基于 `project_no` 的确定性号码。
- 同时数据库又要求 `bid_no` 全局唯一。
- 这两件事放在一起，会把“同项目再次提交”错误地打成数据库唯一键冲突。

### 4.2 Control-Led Interpretation

- `project_id` 才是项目标识。
- `bid_no` 应该是 `bid instance` 的唯一标识，不应退化成 `project mirror id`。
- 如果业务规则要求：
  - `同一组织对同一项目只允许一个活动 bid`
- 那么这个约束必须显式落在业务真相上，而不是靠 `bid_no` 的碰撞“误打误撞”实现。

### 4.3 Inference

- 基于现有报错细节，可以高置信判断当前问题不只影响“同一组织重复提同一项目”。
- 只要 `bid_no` 仍然由 `project_no` 决定，多个供应商竞同一项目也存在高风险撞到同一个 `bid_no`。
- 该项是基于现有日志和号码形式的推断，必须在下一轮修复后再做专项验证。

## 5. Frozen Repair Direction

### 5.1 Backend Truth Fix

- 必须修正 `bid_no` 语义：
  - `bid_no` 必须是每个 `bid instance` 的唯一编号
  - 不得再直接等同于 `BID-${project_no}`
- 必须把“重复提交”从数据库异常提升为受控业务规则。

### 5.2 Business Rule Ruling

- 当前总控裁定采用：
  - `同一组织对同一项目只允许一个活动 bid`
- 这条规则必须通过显式业务约束表达。
- 不允许继续依赖 `bids_bid_no_key` 的 accidental collision。

### 5.3 BFF Fix

- BFF 必须把 server 的重复提交场景归一成 app-facing 受控错误。
- 目标错误形态：
  - `HTTP 409`
  - `code = BID_DUPLICATE_SUBMISSION`
  - message 使用明确中文，不再返回 `Internal server error`

## 6. Required Implementation Scope

### 6.1 Allowed

- `apps/server/**`
- `apps/bff/**`
- `docs/00_ssot/**`
- 如有必要：
  - `docs/02_backend/**`
  - `docs/03_bff/**`

### 6.2 Forbidden

- `apps/mobile/**`
- 生产 `current`
- 生产 `80` 入口
- 与本缺陷无关的 whole-app overlay

## 7. Verification Standard

- 用全新 `published` 项目做一次 app-facing 首次提交：
  - `POST /api/app/bid/submit`
  - 返回 `202`
  - 返回真实 `bidId`
- 对同一 `organization + project` 再次提交：
  - 不允许返回 `500`
  - 必须返回受控业务错误
  - 当前冻结目标为：
    - `HTTP 409`
    - `BID_DUPLICATE_SUBMISSION`
- 若再补做多供应商同项目专项验证：
  - 不应再因为 `bid_no` 冲突而失败

## 8. Stage Gate Checklist

### 8.1 Passed Gates

- submit 主链首次提交：
  - 通过
- 3 附件真实上传：
  - 通过
- BFF 6 字段 surface：
  - 通过
- server 6 字段 truth：
  - 通过

### 8.2 Failed Gates

- duplicate submit controlled rejection：
  - 未通过
- duplicate submit app-facing normalization：
  - 未通过

### 8.3 Veto Gates

- 若下一轮继续接受 `500 Internal server error` 作为重复提交结果，直接 veto。
- 若下一轮继续以 `bid_no` accidental collision 代替显式业务规则，直接 veto。
- 若为了修这个缺陷去动前端页面结构，直接 veto。

## 9. Next Stage Allowed

- `Go`：
  - backend truth residual fix
  - BFF duplicate-submit normalization
  - staging rerun verification
- `No-Go`：
  - production release
  - frontend rework
  - unrelated runtime cleanup

## 10. Next Prompt Bundle

### 10.1 Backend Thread

- 修正 `bid_no` 生成方式，使其成为 `bid instance unique id`
- 明确表达 `same organization + same project` 的重复提交业务规则
- 返回受控 domain error，不再让 DB `23505` 直接冒泡成 `500`

### 10.2 BFF Thread

- 将上游重复提交错误映射成：
  - `409`
  - `BID_DUPLICATE_SUBMISSION`
  - 明确中文 message

### 10.3 Validation Thread

- 使用全新项目验证首次提交成功
- 使用同组织同项目第二次提交验证受控 `409`
- 如条件允许，再验证第二个 supplier 对同一项目不会再撞 `bid_no`

## 11. Closure Outcome

- `2026-04-15` 当前残余缺陷已在 `staging` 收口为：
  - `closed on staging`
  - `production untouched`
- 当前关闭依据固定为：
  - 本地 `Server` 真相已补成显式 duplicate submit controlled conflict
  - 本地 `BFF` 已补成 `409 BID_DUPLICATE_SUBMISSION` app-facing 归一化
  - staging 已完成：
    - 同组织第二次提交 `409`
    - 第二 supplier 同项目真实提交 `202`
    - journal 验证窗口内不再出现 `23505 / bids_bid_no_key`
- 当前 authoritative closure receipt 固定为：
  - `docs/00_ssot/exhibition_bid_submit_full_version_duplicate_submit_500_residual_fix_closure_receipt_addendum.md`
