---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: Admin 当前阶段 100/100 成熟度口径与缺口冻结
created_at: 2026-05-11
---

# Admin 当前阶段 100/100 成熟度口径冻结

## 1. 总裁决

本文件冻结 Admin 当前阶段 `100/100` 的判定口径。

`100/100` 不等于做成全量大后台，也不等于接入支付、信用、会员写操作、复杂工单、复杂 RBAC 或 APNs 运营后台。当前阶段的满分只表示：

- Admin 登录、权限、审核、举报、治理、审计、证据追踪具备最小运营闭环。
- Admin 仍然只直连 Server Admin API，不经过 BFF。
- Server 仍然是唯一业务真值 owner。
- Admin 不成为第二业务真值，不直接改业务状态机。
- 不在本轮打开支付、信用、会员、工单、settings/flags 等重后台。

当前基线评分来自上一轮只读审计：`64/100`。

目标评分：`100/100（当前阶段口径）`。

## 2. 本轮主线

本轮只围绕以下主线补齐：

1. Admin protected route / Server Admin API fail-close 证据。
2. Forum / exhibition / project report 最小治理闭环。
3. Audit 聚合与追责字段。
4. Project / FileAsset / Evidence 只读追踪。
5. Admin 401 / 403 / loading / empty / error 状态标准化。
6. 必要 SSOT / contracts / generated 对齐。

## 3. P0 缺口冻结表

| 编号 | 缺口 | 当前状态 | 是否阻塞 100/100 | 证据路径 | 是否需 SSOT | 是否需 contracts | 是否需 Server | 是否需 Admin | 下一步 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P0-1 | Admin protected route / Server Admin API runtime 401/403 证据缺失 | UNKNOWN | 是 | `apps/admin/src/middleware.ts`; `apps/admin/src/core/auth/route-guard.ts`; `apps/server/src/modules/organization/current-actor-eligibility.service.ts` | 否 | 否 | 可能只补测试 | 可能只补状态呈现 | 先补本地 role-gate 防误用测试与 runtime 人工核验清单 |
| P0-2 | Forum 举报缺 Admin 处置闭环 | PARTIAL | 是 | `apps/server/src/modules/forum/forum-report.service.ts`; `apps/server/src/modules/content_safety/content-safety-review-task.query.service.ts`; `apps/admin/src/modules/review/review-shell.tsx` | 是 | 是 | 是 | 是 | 冻结 forum report decide / takedown / restore / restrict 最小动作 |
| P0-3 | 举报案件台只覆盖 exhibition report，forum / project content report 分流不清 | PARTIAL | 是 | `apps/server/src/modules/exhibition_report_cases/**`; `apps/admin/src/modules/project_review/**`; `docs/01_contracts/openapi.yaml` | 是 | 是 | 是 | 是 | 冻结 report source 与 Admin queue 分流规则 |
| P0-4 | Audit 后台未聚合 content-safety / governance / report audit | PARTIAL | 是 | `apps/server/src/modules/audit/audit-log-query.service.ts`; `apps/server/src/modules/audit/audit-admin.module.ts`; `apps/server/src/modules/content_safety/**`; `apps/server/src/modules/governance/**` | 是 | 是 | 是 | 是 | 只做只读聚合，不修改历史 audit |
| P0-5 | 治理写动作的 actor / reason / occurredAt / target / action 可查闭环不足 | PARTIAL | 是 | `apps/server/src/modules/exhibition_report_cases/exhibition-report-case.service.ts`; `apps/server/src/modules/governance/**`; `apps/server/src/modules/enterprise_hub/**` | 是 | 可能 | 是 | 是 | 统一追责字段展示，不重写历史数据 |
| P0-6 | Admin 401 / 403 / loading / empty / error 状态未标准化 | PARTIAL | 是 | `apps/admin/AGENTS.md`; `apps/admin/src/modules/**`; `apps/admin/src/app/**` | 否 | 否 | 否 | 是 | 新增或复用统一状态组件，401/403 不混成普通错误 |
| P0-7 | Project / FileAsset / Evidence 缺最小只读追踪 | 未接入 | 是 | `apps/server/src/modules/project/**`; `apps/server/src/modules/upload/**`; `docs/01_contracts/upload_contracts.yaml`; `docs/05_admin/admin_governance_surface_matrix.md` | 是 | 是 | 是 | 是 | 只读查看项目和证据链，不允许 Admin 修改业务真值 |
| P0-8 | Admin P0 页面 cloud/runtime 证据缺失 | UNKNOWN | 是 | `apps/admin/src/app/**`; `apps/admin/src/core/server/**` | 否 | 否 | 否 | 否 | 本地通过后，由人工或受控 runtime 核验补证 |

## 4. P1 缺口冻结表

| 编号 | 缺口 | 当前状态 | 是否阻塞 P0 100/100 | 证据路径 | 是否需 SSOT | 是否需 contracts | 是否需 Server | 是否需 Admin | 下一步 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1-1 | Enterprise Hub publish / offline / freeze 有 API，但 Admin UI 未完整接 | PARTIAL | 否 | `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`; `apps/admin/src/modules/review/**` | 可能 | 可能 | 可能 | 是 | P0 后补最小受控入口 |
| P1-2 | recommendation-slots 有 Server Admin API，但 Admin UI 缺失 | PARTIAL | 否 | `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts` | 可能 | 可能 | 可能 | 是 | 单独冻结推荐位治理边界 |
| P1-3 | 企业展示 company / factory / supplier 三板块缺完整后台管理视图 | PARTIAL | 否 | `apps/server/src/modules/enterprise_hub/**`; `apps/admin/src/app/review/change_requests/**` | 是 | 可能 | 可能 | 是 | 展示 public/current/draft/change snapshot 差异 |
| P1-4 | 项目发布 / 内容治理缺专门 Admin 面 | 未接入 | 否 | `apps/server/src/modules/project/**`; `apps/bff/src/routes/project/**`; `apps/mobile/lib/features/exhibition/**` | 是 | 是 | 是 | 是 | 先只做治理只读与 report 承接 |
| P1-5 | 项目沟通 / material-review 缺证据查看 | 未接入 | 否 | `apps/server/src/modules/project_communication/**`; `apps/bff/src/routes/project_communication/**`; `apps/mobile/lib/features/messages/**` | 是 | 可能 | 可能 | 是 | 只读查看证据，不做通用聊天后台 |
| P1-6 | Governance penalty 生命周期 lift / modify / cancel 边界未冻结 | PARTIAL | 否 | `apps/server/src/modules/governance/**`; `apps/admin/src/modules/governance/**` | 是 | 可能 | 是 | 是 | 单独裁决，不并入 P0 |
| P1-7 | Template config 写动作缺统一 audit | PARTIAL | 否 | `apps/server/src/modules/template_config/**`; `apps/admin/src/modules/template_config/**` | 可能 | 可能 | 是 | 是 | 补模板治理审计，不做 runtime flags center |
| P1-8 | Membership 只读入口口径不一致 | PARTIAL | 否 | `apps/admin/src/modules/membership/**`; `apps/admin/src/app/login/page.tsx` | 否 | 否 | 否 | 是 | 统一只读文案，禁止写操作 |
| P1-9 | ticketing / settings / flags 边界未冻结 | PARTIAL | 否 | `apps/admin/src/modules/ticketing/ticketing-shell.tsx`; `apps/admin/src/app/layout.tsx` | 是 | 否 | 否 | 是 | ticketing 保留占位，settings/flags 不进入本轮 |
| P1-10 | Server Admin API 与 OpenAPI / generated 覆盖不完整 | PARTIAL | 否 | `docs/01_contracts/openapi.yaml`; `packages/contracts/src/generated/**`; `apps/admin/src/core/server/**` | 是 | 是 | 否 | 否 | 在 contracts clean-window 中修正，不手写 generated |

## 5. 本轮不做清单

| 能力 | 当前裁决 | 原因 | 是否预留扩展位 |
| --- | --- | --- | --- |
| 钱包 / 余额 | 不做 | 涉及资金真值与合规，不属于当前 Admin P0 治理闭环 | 是 |
| 分账 / 清结算 | 不做 | 需要独立资金状态机和结算合规 | 是 |
| 复杂财务后台 | 不做 | 风险高，容易把 Admin 做成资金操作台 | 是 |
| 支付真实操作后台 | 不做 | 当前阶段只允许只读监管扩展位，不允许真实资金操作 | 是 |
| 会员配置 / 手工开通 / 退款 | 不做 | 当前会员 Admin 只读，写操作需单独冻结 | 是 |
| 信用人工改分 | 不做 | 信用规则和申诉边界未冻结，不能人工强改 | 是 |
| 通用消息后台 / 泛 IM | 不做 | 消息楼不能扩成泛 IM 管理台 | 是 |
| 复杂客服工单系统 | 不做 | ticketing 当前仅占位，客服状态机未冻结 | 是 |
| 复杂 RBAC | 不做 | 当前只依赖 Server DB-backed platform role gate | 是 |
| APNs 推送运营后台 | 不做 | 推送运营能力不属于 Admin P0 治理闭环 | 是 |
| settings / flags center | 不做 | 不把 template_config 当正式 runtime 配置真源 | 是 |
| order / contract / fulfillment / settlement | 不做 | 当前阶段不扩写完整履约与交易后台 | 是 |

## 6. Day 1 准入下一天裁决

Day 1 准入 Day 2 条件：

- P0 / P1 / NO-GO 范围已冻结。
- 每个 P0 缺口已有编号、证据路径、阻塞性和改动归属。
- 本轮不做清单已冻结，防止后续实现范围外溢。

当前裁决：`PASS`。

## 7. 后续执行顺序

1. Day 2：权限与 protected route 证据闭合。
2. Day 3：Forum / Report 处置闭环设计。
3. Day 4：Audit 聚合与追责字段方案。
4. Day 5：Contracts / SSOT 最小同步窗口。
5. Day 6：P0 最小实现窗口。
6. Day 7：证据只读追踪与 P1 最小补强。
7. Day 8：本地验证、云端受控核验清单、最终门禁。
