# App P0-E Admin IA / Shell 轻度规整 Addendum

更新时间：2026-05-01

适用范围：第 8 天 Admin IA / Shell 轻度规整。本文只冻结已有 Admin 页面命名和职责边界，不作为新 Admin 功能开发许可。

## 1. 总裁决

| 项 | 结论 |
| --- | --- |
| 当前状态 | Conditional Pass：已有页面边界更清楚，但不是 Admin 大厂后台 UI 重构完成 |
| 是否允许进入第 9 天 | 允许 |
| 是否新增接口 | 否 |
| 是否新增状态机 | 否 |
| 是否新增 Admin 业务真值 | 否 |
| 是否接入 BFF | 否 |
| 是否开放支付、信用、会员、消息、工单、settings、feature flags 后台 | 否 |

## 2. IA 命名冻结

| 路径 | 第 8 天命名 | 边界 | 依据类型 |
| --- | --- | --- | --- |
| `/review` | 审核任务 | 内容安全与企业认证等已有 Server review task 工作台 | 代码：`apps/admin/src/modules/review/review-shell.tsx` |
| `/review/change_requests` | 展示变更 | 企业展示发布变更审核，不是企业资料真值编辑器 | 代码：`apps/admin/src/modules/published_change_review/published-change-review-shell.tsx` |
| `/governance` | 治理处罚 | 处罚与申诉治理台，不是信用人工改分或资金处理台 | 代码：`apps/admin/src/modules/governance/*` |
| `/project_review` | 举报案件 | exhibition report-case queue/detail/request explanation/decide/escalate，不是项目发布审核状态机 | 代码：`apps/admin/src/modules/project_review/project-review-shell.tsx`；文书：`docs/00_ssot/stage3_admin_package_b_result_verification_pass_addendum.md` |
| `/template_config` | 模板治理 | template/version/rule snapshot governance，不是 runtime-config、CMS、feature flags center | 代码：`apps/admin/src/modules/template_config/template-config-shell.tsx`；文书：`docs/05_admin/stage3_admin_package_d_template_config_admin_surface_addendum.md` |
| `/audit` | 审计日志 | 只读审计查询，不得编辑、删除、伪造 audit log | 代码：`apps/admin/src/modules/audit/audit-shell.tsx`；文书：`docs/05_admin/stage3_admin_package_c_audit_admin_surface_addendum.md` |
| `/ticketing` | 工单占位 | 仅保留后续治理案件/客服受理扩展位，不接入通用工单重系统 | 代码：`apps/admin/src/modules/ticketing/ticketing-shell.tsx`；推断：Root AGENTS Phase 0 guardrail |

## 3. 本轮轻度 patch

| 文件 | 变更 | 风险控制 |
| --- | --- | --- |
| `apps/admin/src/app/layout.tsx` | 全局导航将「项目审核」改为「举报案件」，「模板配置」改为「模板治理」，「工单」改为「工单占位」 | 只改文案，不改路由、权限、接口 |
| `apps/admin/src/modules/ticketing/ticketing-shell.tsx` | 明确工单当前未开放，不接入通用工单重系统 | 避免 P0 被工单平台化 |

## 4. 明确不做

| 范围 | 裁决 |
| --- | --- |
| Admin 大厂后台全量 UI 重构 | 不进入本轮，只保留后续 UI 包 |
| 支付后台 | 不做 |
| 信用人工改分后台 | 不做 |
| 会员配置后台 | 不做 |
| 通用消息后台 | 不做 |
| 通用工单重系统 | 不做 |
| settings / flags center | 不做 |
| order / contract / fulfillment / settlement 后台 | 不做 |
| 将 `template_config` 当正式 runtime 配置真源 | 禁止 |
| 将 `/project_review` 写回项目发布审核状态机 | 禁止 |

## 5. 需要人工 runtime 复核项

| 核验项 | 需要提供的结果 | 阻断级别 |
| --- | --- | --- |
| 未登录访问 `/review` 是否跳转 `/login` | HTTP 结果或截图 | P0-A/P0-E 共同阻断 |
| 未登录访问 `/project_review` 是否跳转 `/login` | HTTP 结果或截图 | P0-E 阻断 |
| 登录后全局导航是否展示「举报案件 / 模板治理 / 工单占位」 | 截图 | 非阻断，但影响 IA 验收 |
| `/project_review` 页面文案是否显示举报案件台而非项目审核状态机 | 截图 | P0-E 阻断 |
| `/template_config` 页面文案是否仍明确不是 runtime-config/feature flags | 截图 | P0-E 阻断 |

## 6. 下一步

第 9 天只允许做 runtime 结果汇总与回归判断。若没有已打开的本地隧道或用户提供的运行结果，则必须标记为「待人工复核」，不得编造 runtime 通过结论。

