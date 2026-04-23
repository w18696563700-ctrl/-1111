---
owner: Codex 总控
status: frozen
purpose: Freeze the truth ruling that public enterprise case detail read must not drift from the enterprise-detail public visibility compensation semantics.
layer: L0 SSOT
freeze_date_local: 2026-04-23
inputs_canonical:
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_backend_truth_scope_addendum.md
  - docs/02_backend/enterprise_display_album_and_target_enterprise_info_backend_truth_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/test/enterprise-hub-public-read-closure.test.cjs
---

# 《enterprise hub public case detail read alignment truth ruling》

## 1. Scope

- 当前 ruling 只覆盖：
  - `GET /server/exhibition/enterprise-hub/public-cases/{caseId}`
  - 公域企业详情页已可见案例卡与二级案例详情之间的一致性
- 当前 ruling 不覆盖：
  - `formal-info` 真值来源
  - 双认证硬门禁
  - 新字段或新前端交互

## 2. Truth Ruling

- 若公域企业详情在当前 runtime truth 下已经可以展示某个案例卡，
  则同一案例进入 `public-cases/{caseId}` 详情读链时，
  不得因为仅存在“待补偿的发布态漂移”而额外返回假性 `404`。
- `public case detail` 读链必须与企业详情页共享同一组 public-read
  收敛语义：
  - listing certification repair
  - published listing approved-history case repair
  - latest application finalize
- 只有在完成上述收敛后，后端才允许执行：
  - `listing published + visible` 公域校验
  - `caseStatus = approved` 公域校验

## 3. Contract Boundary

- 当前 path、字段名、响应形状保持不变。
- 本轮只修正读语义一致性，不引入新的 app-facing contract。

## 4. Explicit Non-goals

- 不得把 `formal-info` 缺失问题伪装成 snapshot fallback。
- 不得让 `BFF` 或 Flutter 兜底纠正 `Server` 的公域案例发布真值。
- 不得把该修复扩展成第二套 enterprise case state machine。

## 5. Formal Conclusion

- 当前正式裁决：
  - `enterprise detail` 与 `public case detail` 的公域案例可见性判定必须先收敛、后裁决
  - `formal-info` 路径保持既有真值与门禁，不在本轮变更
