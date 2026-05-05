# Admin 公共状态与审核工作台冻结 V1 Addendum

状态：冻结草案，供第 3 批 docs-only freeze 使用。
执行裁决：GO for docs-only freeze / NO-GO for implementation。
基线范围：Admin 公共状态语义、审核工作台模式、重复点清单、第 4 批迁移门禁。
新增文件：`docs/00_ssot/admin_public_status_workbench_freeze_v1_addendum.md`。
本轮禁止：不改 Admin 代码、不改 Flutter、不改 BFF、不改 Server、不改 OpenAPI、不生成 types、不部署、不 tunnel smoke、不 commit。

## 1. 总裁决

`CONDITIONAL PASS`：Admin 已有最小运行结构，`adminJsonRequest`、`AdminApiError`、`admin_session` carrier、受保护路由前缀已形成基础闭环；但页面级 loading / empty / error / retry、401 / 403、列表 / 筛选 / 分页、详情面板、审核动作反馈还没有冻结为公共能力。

本轮只冻结治理规则，不实现代码。

- 当前最小闭环：保留现有 Admin 页面、Server Admin API runtime、Server 权限真值、页面级审核动作。
- 需要保留但暂不开通：完整 `AdminListDetailWorkbench` 代码抽象、统一详情 drawer、Admin generated types 全量覆盖、云 runtime 声明。
- 后续扩展位：第 4 批优先只做 `AdminStatusState` 状态壳；`AdminListDetailWorkbench`、Admin generated types、合同补齐、runtime smoke 分批单独立项。

更稳：先冻结 `AdminStatusState` 语义和错误保真规则，再小范围迁移页面状态壳。
更省成本：先统一 401 / 403 / empty / error / retry 文案和 `AdminApiError` 展示，不碰审核业务动作。
更适合当前阶段：第 4 批只考虑 `AdminStatusState`，暂不实现完整工作台。
风险更大：直接重构所有审核页为统一 workbench，并假装 Admin generated types 已完整。

## 2. 只读扫描摘要

本轮只读参考以下范围：

| 范围 | 目的 | 结论 |
| --- | --- | --- |
| `apps/admin/src/**` | 扫描 Admin 状态、列表、详情、错误处理重复点 | transport 已集中，UI 状态和工作台模式仍页面级重复 |
| `apps/server/src/modules/**` admin controller | 只读核对 Server Admin API owner | 多个 Admin controller 存在，Server 仍是权限和业务真值 owner |
| `docs/01_contracts/openapi.yaml` | 只读核对 Admin contract coverage | 部分 `/server/admin/*` 已入主合同，仍有缺口和命名差异需单独冻结 |
| `packages/contracts/src/generated/app-api.types.ts` | 只读核对 generated coverage | 未命中 Admin 生成类型，当前 generated 主链路仍偏 App API |

扫描命令摘要：

- `git status --short --untracked-files=all`
- `rg --files apps/admin/src`
- `rg -n "AdminApiError|loading|empty|empty-card|notice danger|review-list|review-detail|pageSize|page: 1|401|403|forbidden|unauthorized|drawer|detail|approve|reject|reason|retry" apps/admin/src`
- `rg -n "toLoadError|toErrorMessage|function to.*Label|empty-card|notice danger|review-list|review-detail|page: 1|pageSize: 20" apps/admin/src/modules apps/admin/src/core apps/admin/src/shared`
- `rg -n "adminJsonRequest<|adminJsonRequest\\(" apps/admin/src/core/server`
- `find apps/server/src/modules -path "*admin*.controller.ts" -type f`
- `rg -n "/server/admin|server/admin|content-safety|reviews/organizations|exhibition/report-cases|governance/penalties|governance/appeals|admin/audit|config/templates|enterprise-hub/applications|change-requests|membership" docs/01_contracts/openapi.yaml`
- `rg -n "server/admin|Admin|Governance|Audit|EnterpriseHub|OrganizationReview|Membership" packages/contracts/src/generated/app-api.types.ts`

未执行：Admin build、Admin lint、云端 health、tunnel smoke、部署、commit。

## 3. AdminStatusState 状态语义冻结

`AdminStatusState` 是 Admin UI 状态语义，不是 Server 权限、审核、治理、审计真值。它只能消费 Server Admin API 返回的 `status`、`code`、`message`、`details`，不得吞掉真实错误。

| 状态 | 触发条件 | 展示语义 | 必须保留的数据 | 禁止行为 | 第 4 批验收 |
| --- | --- | --- | --- | --- | --- |
| `loading` | SSR 或局部读取中 | 正在读取 Server Admin API | 请求目标、页面上下文 | 不得显示为空数据成功 | 慢请求有明确 loading 文案或骨架 |
| `empty` | 200 成功且列表为空 | 无待处理数据 / 无服务端返回记录 | 查询条件、分页上下文 | 不得吞掉错误成空态 | 空态必须区别于 error |
| `error` | 非 401 / 403 / 404 的请求失败 | 请求失败，可重试 | `status`、`code`、`message`、`details` | 不得只显示字符串导致丢码 | UI 可看到 code，日志/调试可取 details |
| `retry` | error 后允许再次读取 | 提供重试入口 | 原查询条件 | 不得重放写动作 | 只重试 GET / 页面读取 |
| `unauthorized` / `401` | session 缺失、失效、过期、载体无法验证 | 管理员登录失效，请重新连接 | `status=401`、`code`，如 `AUTH_SESSION_INVALID` | 不得当成普通 error | 明确引导回登录或重新连接 |
| `forbidden` / `403` | 已登录但 Server 判定无权限 | 当前管理员无权限访问该资源或动作 | `status=403`、`code`、`details` | 不得由前端自行决定权限真值 | 403 与 401 文案不同 |
| `not_found` | 404 或资源已被处理、不可见 | 资源不存在、已处理或当前 scope 不可见 | `status=404`、`code` | 不得误导为权限不足 | 可返回列表或刷新队列 |
| `degraded` | 合同缺口、runtime 未验证、只读降级 | 当前能力仅降级展示或等待合同补齐 | 缺口来源、缺口编号 | 不得伪装成功闭环 | 文案明确“未验证/降级” |
| `stale` | 页面数据可能已过期 | 数据可能不是最新，建议刷新 | 读取时间、关键 id | 不得自动提交写动作 | 审核动作前仍以 Server 响应为准 |
| `unknown` | 未识别错误或状态 | 未识别状态，请保留原始信息 | 原始 payload | 不得静默兜底成成功 | 未知状态进入风险清单 |

强制规则：

1. `AdminStatusState` 不替代 Server 权限判断。
2. `AdminStatusState` 不替代业务状态机。
3. `AdminStatusState` 不吞掉 `AdminApiError.status/code/details`。
4. 401 与 403 必须分开展示。
5. audit append-only 只读提示只能是展示，不得产生可写动作。

## 4. AdminListDetailWorkbench 模式冻结

`AdminListDetailWorkbench` 是模式冻结，不是第 3 批代码实现。现有右侧详情区不得强行命名为 drawer，除非真实实现抽屉交互。

| 区域 | 当前模式 | 冻结语义 | 禁止行为 | 第 4 批可做 |
| --- | --- | --- | --- | --- |
| 列表区 | `review-list` 多页面重复 | 展示 Server Admin API 返回的队列或记录 | 不得在列表内推导权限真值 | 先复用状态壳，不改数据结构 |
| 筛选区 | 各页手写 status / keyword / type | 过滤条件必须映射合同字段 | 不得新增未冻结 query | 登记 filter schema，暂不抽大组件 |
| 分页区 | 多处 `page: 1, pageSize: 20` | page/pageSize 是合同分页参数 | 不得写死为最终分页策略 | 先登记默认值和缺 UI 控制点 |
| 详情面板 | `review-detail` / 右侧详情区 | 展示选中对象的 Server detail projection | 不得强行改成 drawer | 命名为 detail panel |
| 审核动作区 | `action-card` 多页面重复 | 写动作只提交 Server 允许的 command payload | 不得由 UI 判定最终可写权限 | 保留状态与 reason 输入 |
| 操作结果反馈 | query notice / error 多页面重复 | 成功和失败必须可区分 | 不得丢失错误 code | 后续统一 notice/error policy |
| audit / append-only | audit 页面只读 | audit 是 append-only inspect corridor | 不得加入修改、撤销、补写动作 | 只加只读提示和状态壳 |

## 5. 覆盖面冻结

| Admin surface | 当前入口 | Server owner | OpenAPI 状态 | generated 状态 | 当前治理判断 |
| --- | --- | --- | --- | --- | --- |
| 内容安全审核 | `apps/admin/src/modules/review/review-shell.tsx` | `apps/server/src/modules/content_safety/content-safety-admin.controller.ts` | 主合同见 `security-events`，Admin UI client 使用 `content-safety/*`，需补命名核对 | 未见 Admin generated | 先登记，不先迁移工作台 |
| 企业认证审核 | `apps/admin/src/modules/review/organization-review-shell.tsx` | `apps/server/src/modules/review/organization-review.controller.ts` | `/server/admin/reviews/organizations*` 已入主合同 | 未见 Admin generated | 第 4 批候选 |
| Enterprise Hub Application | `apps/admin/src/modules/review/enterprise-hub-application-review-shell.tsx` | `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts` | `/server/admin/exhibition/enterprise-hub/applications*` 已入主合同 | 未见 Admin generated | 文件 403 行，先迁状态壳，不大拆 |
| Published Change Review | `apps/admin/src/modules/published_change_review/published-change-review-shell.tsx` | `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts` | `/server/admin/exhibition/enterprise-hub/change-requests*` 已入主合同 | 未见 Admin generated | 文件 441 行，高风险，先登记 |
| Project Review / Report Case | `apps/admin/src/modules/project_review/project-review-shell.tsx` | `apps/server/src/modules/exhibition_report_cases/exhibition-report-case-admin.controller.ts` | `/server/admin/exhibition/report-cases*` 已入主合同 | 未见 Admin generated | 第 4 批候选 |
| Governance Penalties | `apps/admin/src/modules/governance/penalty-shell.tsx` | `apps/server/src/modules/governance/governance-admin.controller.ts` | `/server/admin/governance/penalties*` 已入主合同 | 未见 Admin generated | 第 4 批候选 |
| Governance Appeals | `apps/admin/src/modules/governance/appeal-shell.tsx` | `apps/server/src/modules/governance/governance-appeal-admin.controller.ts` | `/server/admin/governance/appeals*` 已入主合同 | 未见 Admin generated | 第 4 批候选 |
| Audit Read-only | `apps/admin/src/modules/audit/audit-shell.tsx` | `apps/server/src/modules/audit/audit-admin.controller.ts` | 本轮未在主合同扫描命中 `/server/admin/audit/logs` | 未见 Admin generated | 先补合同门禁 |
| Template Config | `apps/admin/src/modules/template_config/*` | `apps/server/src/modules/template_config/template-config-admin.controller.ts` | Server controller 存在，合同覆盖需单独核对 | 未见 Admin generated | 登记，不优先迁移 |
| Membership Admin | `apps/admin/src/modules/membership/*` | `apps/server/src/modules/membership/membership-admin.controller.ts` | `/server/admin/membership/*` 已入主合同 | 未见 Admin generated | 登记，不混入支付/账单 |

## 6. 高风险重复点清单

| 重复类型 | 证据路径 | 风险 | 建议动作 |
| --- | --- | --- | --- |
| `AdminApiError` flatten | `review-shell.tsx:199`、`project-review-state.ts:99`、`audit-state.ts:88`、`organization-review-state.ts:82`、`enterprise-hub-application-review-state.ts:176`、`published-change-review-state.ts:153`、`penalty-shell.tsx:251`、`appeal-shell.tsx:242`、`membership-state.ts:79` | 401 / 403 / 404 / details 容易丢失 | 第 4 批先抽 `AdminStatusState` mapper |
| `notice danger` 错误块 | `review-shell.tsx:43`、`project-review-shell.tsx:76`、`audit-shell.tsx:43`、`organization-review-shell.tsx:62`、`enterprise-hub-application-review-shell.tsx:80`、`published-change-review-shell.tsx:50`、`penalty-shell.tsx:56`、`appeal-shell.tsx:63`、`membership-shell.tsx:31`、`template-config-shell.tsx:50` | 错误语义漂移，不能区分 401/403 | 先统一状态展示语义 |
| `empty-card` 空态 | 多个 list/detail/action 区域使用 `empty-card` | 空态、未选中、不可操作、无数据混用 | 建立 empty subtype：no-data / no-selection / action-disabled |
| `review-list` / `review-detail` | review、project_review、audit、governance、membership、template_config 重复 | 工作台布局重复但语义未冻结 | 本轮冻结为 detail panel，不强改 drawer |
| `page: 1, pageSize: 20` | `project-review-state.ts:56`、`audit-state.ts:57`、`organization-review-state.ts:47`、`enterprise-hub-application-review-state.ts:60`、`published-change-review-state.ts:43`、`penalty-shell.tsx:78`、`appeal-shell.tsx:85`、`membership-state.ts:49`、`template-config-state.ts:65/86` | 分页默认散落，分页 UI 控制不统一 | 先登记默认值，后续抽 state helper |
| 审核动作区 | organization approve/reject、project request/decide/escalate、enterprise application approved/revision/rejected、change review/apply、governance decide/apply | reason / note / 状态允许动作散落 | 暂不抽工作台，先保留 Server action truth |
| 状态文案函数 | `toStatusLabel`、`toPenaltyStatusLabel`、`toAppealStatusLabel`、`toCertificationStatusLabel`、`toChangeStatusLabel` 多处 | 文案漂移，unknown 兜底不一致 | 后续可接轻量状态展示策略，但不建业务状态机 |
| 手写 Admin clients/types | `apps/admin/src/core/server/admin-*-api-client.ts` | 手写 TS 类型可能成为事实合同 | 第 4 批前置冻结 generated coverage |
| 受保护路由同步 | `route-guard.ts`、`middleware.ts` | 新 Admin route 容易漏 guard / matcher | apps/admin/AGENTS 第 3.5 批补规则 |
| 大文件预警 | `enterprise-hub-application-review-shell.tsx` 403 行、`published-change-review-shell.tsx` 441 行 | 顺手重构风险高 | 第 4 批不得从这两个文件开始大拆 |

## 7. Contract / Generated 前置门禁

本轮只读结论：

1. `docs/01_contracts/openapi.yaml` 已包含多组 `/server/admin/*` 主合同，如 organizations、governance penalties、governance appeals、membership、report cases、enterprise hub applications、change requests。
2. `apps/admin/src/core/server/admin-review-api-client.ts` 使用 `/content-safety/*`，而主合同扫描命中的是 `/server/admin/security-events`，内容安全 Admin surface 需要先核对正式 canonical path。
3. `apps/admin/src/core/server/admin-audit-api-client.ts` 使用 `/audit/logs`，本轮主合同扫描未命中 `/server/admin/audit/logs`，audit read-only 迁移前必须补合同判断。
4. `packages/contracts/src/generated/app-api.types.ts` 未命中 `server/admin`、`Admin`、`Governance`、`Audit` 等 Admin generated 类型；第 4 批不得假装 Admin generated types 已完整。

第 4 批前置门禁：

- 明确 Admin generated types 是否进入 contracts generation，或登记阶段性豁免。
- 内容安全审核 canonical path 必须在 `openapi.yaml` 或正式 addendum 中对齐。
- audit read-only path 必须进入合同或明确 docs-only / source-only 临时状态。
- 任何 Admin UI 迁移不得顺手改 OpenAPI、generated types 或 Server controller。

## 8. apps/admin/AGENTS.md 补丁草案

本节仅为草案，不在第 3 批写入 `apps/admin/AGENTS.md`。是否写入放到第 3.5 批。

建议补丁内容：

```markdown
## Admin 公共状态与审核工作台规则

- 新 Admin 页面必须优先复用 Server Admin API runtime：`adminJsonRequest`、`AdminApiError`、`toQueryString`。
- 新 Admin 页面不得重新发明 401 / 403 / empty / error / retry 语义；应遵守已冻结 `AdminStatusState`。
- 401 表示未登录、session 缺失、session 无效或 carrier 无法验证；403 表示已登录但 Server 判定无权限。
- Admin UI 状态不得替代 Server 权限判断、审核判断、治理判断或 audit 真值。
- `AdminApiError.status`、`AdminApiError.code`、`AdminApiError.details` 必须保留，不得只 flatten 成字符串。
- 新受保护路由必须同步维护 `PROTECTED_PREFIXES`、middleware matcher、route guard 测试。
- Admin 只能调用 Server Admin API，不得经由 BFF。
- 右侧详情区只能称为 detail panel；没有真实 drawer 交互前不得称为 drawer。
- audit append-only 页面只能提供只读检视和状态提示，不得增加修改、撤销、补写动作。
- Admin generated types 当前存在缺口；手写 TS 类型不得成为合同真相。
- 公共 helper 必须按 transport、state、view、domain client 拆分，不得形成超过 400/450 行的 god file。
```

## 9. 第 4 批迁移优先级任务单

第 4 批推荐只做 `AdminStatusState` 状态壳，不直接实现完整 `AdminListDetailWorkbench`。

| 优先级 | 任务 | 目标文件 | 前置条件 | 验收 |
| --- | --- | --- | --- | --- |
| P0 | 冻结 Admin generated types 缺口处理 | `packages/contracts/src/generated/app-api.types.ts`、contracts generation 规则只读确认 | 总控确认是生成覆盖还是阶段性豁免 | 文书明确，不改 generated |
| P0 | 设计 `AdminStatusState` mapper | `apps/admin/src/core/server/admin-api-runtime.ts` 只作为输入来源 | 不改 transport 语义，不吞 details | 401/403/404/error 映射表可测 |
| P0 | 小范围迁移一个低风险页面错误态 | 建议从 `apps/admin/src/modules/project_review/project-review-state.ts` 或 `apps/admin/src/modules/review/organization-review-state.ts` 二选一 | 合同已入主 OpenAPI，页面不超 400 行或可局部改 | 页面行为不变，错误信息更完整 |
| P1 | 治理 penalties / appeals 统一状态壳 | `penalty-shell.tsx`、`appeal-shell.tsx` | 不抽动作表单，不改变 Server action | `notice danger` 与 `toLoadError` 不再重复 |
| P1 | enterprise application 状态壳 | `enterprise-hub-application-review-state.ts` | 避免改 403 行 shell 布局 | 只迁 mapper，不拆工作台 |
| P2 | published change review 登记迁移 | `published-change-review-shell.tsx` | 文件 441 行，必须单独计划 | 不在第 4 批直接大拆 |
| P2 | audit read-only 状态壳 | `audit-state.ts`、`audit-shell.tsx` | 先补 audit contract / generated 门禁 | append-only 只读提示保留 |
| P2 | template config / membership 登记 | `template_config/*`、`membership/*` | 不混入支付、账单、配置发布大改 | 只登记，不默认施工 |

第 4 批 No-Go：

- 不实现完整 `AdminListDetailWorkbench`。
- 不把右侧详情面板强改 drawer。
- 不改 Server Admin API 语义。
- 不改 OpenAPI / generated types，除非另有总控单独批准。
- 不做 Admin 大治理台。
- 不把 UI 状态当权限真值。

## 10. 风险清单

| 风险 | 等级 | 说明 | 缓解 |
| --- | --- | --- | --- |
| Admin generated types 缺口 | 高 | 手写 Admin 类型可能成为事实合同 | 第 4 批前置冻结生成覆盖或豁免 |
| 401 / 403 混同 | 高 | 用户无法区分登录失效和无权限 | `AdminStatusState` 必须分开展示 |
| 错误 details 丢失 | 高 | 当前多处 `${code}: ${message}` flatten | mapper 必须保留 details |
| 内容安全 path 命名漂移 | 中 | Admin client 与主合同路径命名不完全一致 | 先补 canonical path 判断 |
| audit 可写误扩展 | 中 | audit 是 append-only read-only corridor | 文案只读，不新增动作 |
| 工作台一次性重构 | 高 | 多个页面 300-441 行，容易扩大范围 | 第 4 批只迁状态壳 |
| drawer 术语误用 | 中 | 现有是右侧详情区，不是 drawer | 文档和 AGENTS 明确 detail panel |
| 云 runtime 未验证 | 中 | 本轮没有 tunnel smoke | 不声明 runtime pass |

## 11. 第 3 批验收标准

本轮完成条件：

1. 只新增 `docs/00_ssot/admin_public_status_workbench_freeze_v1_addendum.md`。
2. `git diff --check -- docs/00_ssot/admin_public_status_workbench_freeze_v1_addendum.md` 通过。
3. `apps/admin`、`apps/mobile`、`apps/bff`、`apps/server`、`docs/01_contracts`、`packages/contracts` 无代码或合同变更。
4. 不运行 Admin build。
5. 不运行 tunnel smoke。
6. 不 commit。

最终裁决口径：

- `PASS`：文书新增、diff check 通过、无越界变更。
- `PASS with Risk`：文书新增并通过检查，但 Admin generated types / runtime / 合同缺口仍需后续门禁。
- `No-Go`：出现越界修改、diff check 失败或把本轮文书误写入代码/AGENTS。
