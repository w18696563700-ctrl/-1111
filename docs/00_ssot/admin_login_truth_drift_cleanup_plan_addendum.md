# Admin Login Truth Drift Cleanup Plan Addendum

doc_meta:
  owner: Codex 总控
  status: draft
  layer: L1 SSOT
  scope: Admin 登录真相后的文书 / contracts 漂移清理计划
  created_at: 2026-05-01
  based_on:
    - docs/00_ssot/admin_session_carrier_login_truth_addendum.md

## 1. 当前裁决复述

当前 Admin 登录真相已经冻结为：

- Admin 没有独立账号密码体系。
- Admin 不提供管理员注册。
- Admin 登录页只接收 `Server Auth` 已签发的 session carrier。
- Admin 前端只把验证通过的 carrier 写入浏览器 `admin_session` cookie。
- Admin 后续请求把 `admin_session` 转为 `Authorization: Bearer <carrier>`，直连 `Server Admin API`。
- Server Admin API 继续按 verified current session + DB-backed platform membership 做准入。
- 平台 Admin 主门禁为 `platform_reviewer | platform_super_admin`。
- `password/login` 不得被扶正为 Admin 登录。
- `whitelist-test-session` 只能作为非生产 / isolated 受控测试入口，不是正式登录方式。

依据类型：新 SSOT / 代码 / contracts / 文书。

## 2. 扫描范围与方法

本轮只扫描，不改现有业务代码、不改 Server Auth 行为、不改 OpenAPI / generated 输出。

已扫描范围：

- `docs/00_ssot/**`
- `docs/01_contracts/**`
- `docs/05_admin/**`
- `apps/admin/**`
- `apps/server/**`
- `packages/contracts/**`
- `docs/01_contracts/openapi.yaml`
- `packages/contracts/openapi/openapi.bundle.json`
- `packages/contracts/src/generated/**`

关键词：

- `account_password_plus_second_factor`
- `server_session_carrier_only`
- `admin_session`
- `password/login`
- `password auth`
- `whitelist-test-session`
- `AUTH_WHITELIST_TEST_SESSION`
- `platform_reviewer`
- `platform_super_admin`
- `sessionCarrier`
- `管理员会话`

依据类型：代码 / contracts / 文书。

## 3. 旧口径残留总表

| 编号 | 残留项 | 位置 | 当前风险 | 推荐处理方式 | 是否改文书 | 是否改 contracts | 是否改 generated types | 是否改 Admin UI 文案 | 是否改代码 | 当前裁决 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| D1 | Admin `login_mode` 仍写 `account_password_plus_second_factor` | `docs/01_contracts/auth_contracts.yaml` | 高：直接违背 Admin carrier-only 真相，容易误导后续实现账号密码后台 | 改写 | 是 | 是 | 否 | 否 | 否 | 必须进最小 patch |
| D2 | Admin `login_mode` 仍写 `account_password_plus_second_factor` | `docs/01_contracts/identity_permission_minimum_contracts.yaml` | 高：权限合同入口处仍暗示 Admin 有账号密码 + 二因子体系 | 改写 | 是 | 是 | 否 | 否 | 否 | 必须进最小 patch |
| D3 | App-facing `password/login|set|reset` 已进入 OpenAPI / bundle / generated | `docs/01_contracts/openapi.yaml`、`packages/contracts/openapi/openapi.bundle.json`、`packages/contracts/src/generated/app-api.types.ts` | 中：不等于 Admin 登录，但与旧 OTP-only 文书存在口径漂移 | 待裁决 | 是 | 待裁决 | 待裁决 | 否 | 否 | 不在 Admin patch 内扶正或删除 |
| D4 | P0-B 文书对 password auth 从 conditional 演进到 formal active | `docs/00_ssot/app_p0_b_contracts_runtime_drift_ruling_addendum.md`、`docs/00_ssot/app_p0_b_contracts_clean_window_ruling_addendum.md`、`docs/00_ssot/app_p0_b_contracts_clean_window_sync_receipt_addendum.md` | 中：历史演进容易被误读为 Admin password login 成立 | 标记历史残留 / 补交叉引用 | 是 | 否 | 否 | 否 | 否 | 保留但要加“App-facing only”索引说明 |
| D5 | `auth_password_login_round_b_contract_freeze.md` 冻结账号密码登录 Round B | `docs/01_contracts/auth_password_login_round_b_contract_freeze.md` | 中：文件本身是 App-facing，但标题容易被误读成平台统一登录或 Admin 登录 | 保留并补边界说明 | 是 | 是 | 否 | 否 | 否 | 保留，不得接入 Admin |
| D6 | debug whitelist 文书提到“不做 Admin 密码登录流程变更” | `docs/01_contracts/debug_whitelist_session_contracts_addendum.md` | 低：本意是否定 Admin 密码登录，但旧措辞仍依赖“Admin 密码登录”概念 | 改写 | 是 | 是 | 否 | 否 | 否 | 改成“不改 Admin carrier-only 接入” |
| D7 | 老 SSOT 写登录页仍是占位 / carrier 未形成 | `docs/00_ssot/stage3_admin_minimal_operation_governance_controller_review_spec_bundle_addendum.md` | 中：与当前 Admin login page 已形成 carrier-only 接入相冲突 | 标记历史残留 | 是 | 否 | 否 | 否 | 否 | 不回改历史正文，建议在索引声明被新 SSOT supersede |
| D8 | 老 SSOT 写 Admin carrier-only 已通过但仍可能透传 incoming `Authorization` | `docs/00_ssot/backend_document_execution_state_rectification_and_index_registration_ruling_addendum.md`、`apps/admin/src/core/server/admin-api-runtime.ts` | 中：文书与代码都提示存在“incoming Authorization 优先”语义，可能弱化 `admin_session` 唯一入口认知 | 待裁决 | 是 | 否 | 否 | 否 | 待裁决 | 当前仅登记，不在文书清理 patch 内改代码 |
| D9 | Admin API runtime / test 仍转发 `x-actor-role`、`x-role` | `apps/admin/src/core/server/admin-api-runtime.ts`、`apps/admin/test/admin-api-client.test.cjs` | 中：若被误认为权限真相，会违背 DB-backed platform membership 门禁；Server 当前主链仍应以 DB truth 为准 | 待裁决 | 是 | 否 | 否 | 否 | 待裁决 | 安全复核项，不纳入本轮文书 patch |
| D10 | `docs/05_admin/**` 未检出登录口径关键词 | `docs/05_admin/*` | 低：Admin surface 文书没有承接新 SSOT，后续读者不易发现登录真相 | 保留 / 可补索引 | 可选 | 否 | 否 | 否 | 否 | 可在后续 docs index 注册 |
| D11 | Admin UI 登录页文案已是 carrier-only | `apps/admin/src/app/login/page.tsx` | 低：当前与新 SSOT 一致 | 保留 | 否 | 否 | 否 | 否 | 否 | 不改 |
| D12 | Server role gate 代码与合同一致 | `apps/server/src/modules/organization/current-actor-eligibility.service.ts`、`docs/01_contracts/identity_permission_minimum_contracts.yaml` | 低：`platform_reviewer_or_super_admin` 语义正确，应保留 | 保留 | 否 | 否 | 否 | 否 | 否 | 不改 |

依据类型：代码 / contracts / 文书 / 推断。

## 4. 分项说明

### D1 / D2：`account_password_plus_second_factor` 必须清理

残留位置：

- `docs/01_contracts/auth_contracts.yaml`
- `docs/01_contracts/identity_permission_minimum_contracts.yaml`

当前风险：

- 直接把 Admin 登录模式描述成账号密码 + 二因子。
- 与 `apps/admin/src/core/auth/route-guard.ts` 的 `server_session_carrier_only` 冲突。
- 与 `apps/admin/src/app/login/page.tsx` 的 `sessionCarrier` 表单冲突。
- 容易导致后续 Agent 误开 Admin 账号密码登录、二因子、注册或 operator issuer flow。

推荐处理：

```yaml
admin:
  login_mode: server_session_carrier_only
  consumes: Server admin APIs
  issuer: Server Auth
  role_gate: platform_reviewer_or_super_admin
```

是否需要改文书：是。

是否需要改 contracts：是。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：contracts / 代码。

### D3：App-facing password auth 与 Admin 登录必须切开

残留位置：

- `docs/01_contracts/openapi.yaml`
- `packages/contracts/openapi/openapi.bundle.json`
- `packages/contracts/src/generated/app-api.types.ts`

当前事实：

- `POST /api/app/auth/password/login`
- `POST /api/app/auth/password/set`
- `POST /api/app/auth/password/reset`

已存在于 formal / generated 路径中。

当前风险：

- 该事实只能说明 App-facing bounded auth path 已进入 contracts/generated。
- 不能推导出 Admin 有 password login。
- 与仍写 `phone_code_plus_org_invite` 或 OTP-only 的旧文书存在漂移。

推荐处理：

- 本轮不删除、不新增、不重生成。
- 在 Admin 登录文书中明确：password auth 即使存在，也只属于 App-facing auth 裁决，不属于 Admin。
- 另开 `App auth mode clean-window` 决定：OTP-only、bounded password auth、或 reserved compatibility。

是否需要改文书：是。

是否需要改 contracts：待裁决。

是否需要改 generated types：待裁决。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：contracts / generated / 文书。

### D4：P0-B password auth 文书演进需要标记历史上下文

残留位置：

- `docs/00_ssot/app_p0_b_contracts_runtime_drift_ruling_addendum.md`
- `docs/00_ssot/app_p0_b_contracts_clean_window_ruling_addendum.md`
- `docs/00_ssot/app_p0_b_contracts_clean_window_sync_receipt_addendum.md`

当前风险：

- 这些文书记录了 password auth 从 drift 到 formal active 的演进。
- 后续如果只读最后一个 receipt，可能误以为 password auth 是全平台统一登录主线。
- 需要明确它只限 App-facing，不扩展到 Admin。

推荐处理：

- 保留历史文书，不回写历史结论。
- 在 `source_of_truth_map.md` 或本次 clean-window 文书中登记优先级：新 SSOT 优先解释 Admin 登录。
- 若后续要整理，可追加“password auth is App-facing only, not Admin login”的交叉引用。

是否需要改文书：是，建议改索引 / addendum，不直接篡改历史 receipt。

是否需要改 contracts：否。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：文书 / 推断。

### D5：Round B password contract 保留但要防误读

残留位置：

- `docs/01_contracts/auth_password_login_round_b_contract_freeze.md`

当前风险：

- 标题是“账号密码登录最小闭环”，容易被跨上下文误读为 Admin 登录能力。
- 但正文已包含“手机号 + 密码登录”“不新增第二条 password auth family”等约束，偏 App-facing。

推荐处理：

- 保留该合同，不删除。
- 补一行边界：`This contract is app-facing only and does not define Admin password login.`
- 不触碰 Server Auth 行为。

是否需要改文书：是。

是否需要改 contracts：是，属于合同文书澄清。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：contracts / 文书。

### D6：debug whitelist 文书措辞需替换为 carrier-only

残留位置：

- `docs/01_contracts/debug_whitelist_session_contracts_addendum.md`

当前风险：

- 当前文字“不做 Admin 密码登录流程变更”本意是禁止扩张，但仍保留了“Admin 密码登录”的概念。
- 容易被后续误解为曾存在或计划存在 Admin 密码登录。

推荐处理：

- 改成“不改 Admin carrier-only 接入流程”。
- 保留 debug whitelist 仅用于受控联调，不写成正式登录入口。

是否需要改文书：是。

是否需要改 contracts：是。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：contracts / 文书。

### D7：旧 Admin package spec 的“占位页”结论需要被新 SSOT supersede

残留位置：

- `docs/00_ssot/stage3_admin_minimal_operation_governance_controller_review_spec_bundle_addendum.md`

当前风险：

- 老文书写 `apps/admin/src/app/login/page.tsx` 仍是占位页，真实管理员会话载体未形成。
- 当前代码与新 SSOT 已确认 carrier-only 接入成立。

推荐处理：

- 不回改历史正文。
- 在 `source_of_truth_map.md` 或本报告后续 patch 中声明：该旧结论已被 `admin_session_carrier_login_truth_addendum.md` supersede。

是否需要改文书：是。

是否需要改 contracts：否。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：文书 / 代码。

### D8：incoming `Authorization` 优先透传需要安全语义复核

残留位置：

- `apps/admin/src/core/server/admin-api-runtime.ts`
- `docs/00_ssot/backend_document_execution_state_rectification_and_index_registration_ruling_addendum.md`

当前事实：

- Admin runtime 当前会先读取 incoming `authorization`，再 fallback 到 `admin_session` carrier。
- 旧文书已记录 `server_session_carrier_only` 当前并未严格限制为唯一 carrier，仍允许优先透传来路 `Authorization`。

当前风险：

- 如果部署边界允许外部请求带入 `Authorization`，可能使“Admin 只消费 admin_session”在实现层变成“Admin API client 可优先透传外来 Authorization”。
- 这不等同于 Admin password login，但属于 carrier 入口边界漂移。

推荐处理：

- 本轮只登记，不改代码。
- 后续安全 clean-window 裁决：Admin server runtime 是否应优先使用 `admin_session`，或只在明确 internal test runtime 允许 incoming Authorization。

是否需要改文书：是。

是否需要改 contracts：否。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：待裁决。

依据类型：代码 / 文书 / 推断。

### D9：`x-actor-role` / `x-role` 转发需要避免被误当权限真相

残留位置：

- `apps/admin/src/core/server/admin-api-runtime.ts`
- `apps/admin/test/admin-api-client.test.cjs`

当前事实：

- Admin API runtime 会转发 `x-actor-role` / `x-role`。
- 测试样本中使用 `platform_reviewer`。
- Server 当前主门禁应通过 `CurrentActorEligibilityService.requireReviewer()` 读取 DB-backed platform membership，而不是信任 raw role header。

当前风险：

- 容易让后续 Agent 误以为 `x-actor-role` 是 Admin 权限真相。
- 与新 SSOT 的“platform role gate 来自 DB-backed platform membership”存在解释风险。

推荐处理：

- 本轮只登记，不改代码。
- 后续安全 clean-window 复核 Admin 是否需要继续转发 actor hint headers。
- 文书中明确 raw role header 只可作为 trace / compatibility hint，不可作为 authz truth。

是否需要改文书：是。

是否需要改 contracts：否。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：待裁决。

依据类型：代码 / tests / 推断。

### D10：`docs/05_admin` 未承接登录真相

残留位置：

- `docs/05_admin/account_and_enterprise_certification_rules_v1_admin_surface_addendum.md`
- `docs/05_admin/admin_governance_surface_matrix.md`
- `docs/05_admin/admin_ssot.md`
- `docs/05_admin/stage3_admin_package_c_audit_admin_surface_addendum.md`
- `docs/05_admin/stage3_admin_package_d_template_config_admin_surface_addendum.md`

当前风险：

- 未检出明显错误口径。
- 但 `docs/05_admin` 是 Admin surface 文书目录，未显式引用最新 Admin 登录真相，后续读者可能继续从旧 package 文书理解登录方式。

推荐处理：

- 可选：在 `docs/05_admin/admin_ssot.md` 增加一行引用新 SSOT。
- 本轮最小 patch 可以不处理。

是否需要改文书：可选。

是否需要改 contracts：否。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：文书 / 推断。

### D11：Admin UI 文案当前无需修改

残留位置：

- `apps/admin/src/app/login/page.tsx`
- `apps/admin/src/modules/**`

当前事实：

- 登录页文案已明确 `server_session_carrier_only`。
- 表单字段为 `sessionCarrier`。
- 多个 Admin shell 页面使用“拿到有效的服务端管理员会话载体后”文案。
- 未检出账号密码登录入口文案。

推荐处理：

- 保留。
- 不改 UI。

是否需要改文书：否。

是否需要改 contracts：否。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：代码。

### D12：Server platform role gate 当前无需改

残留位置：

- `apps/server/src/modules/organization/current-actor-eligibility.service.ts`
- `docs/01_contracts/identity_permission_minimum_contracts.yaml`

当前事实：

- `platform_reviewer_or_super_admin` 合同定义为 verified actor identity + active DB-backed membership truth。
- Server 代码中的 `REVIEWER_ROLE_KEYS` 为 `platform_reviewer`、`platform_super_admin`。
- 该部分与新 SSOT 一致。

推荐处理：

- 保留。
- 不改 Server。

是否需要改文书：否。

是否需要改 contracts：否。

是否需要改 generated types：否。

是否需要改 Admin UI 文案：否。

是否需要改代码：否。

依据类型：代码 / contracts。

## 5. 下一步最小 patch 范围

推荐下一步只做 `Admin auth truth docs clean-window`，不动业务代码。

允许修改：

1. `docs/01_contracts/auth_contracts.yaml`
   - 将 `admin.login_mode` 从 `account_password_plus_second_factor` 改为 `server_session_carrier_only`。
   - 增加 `issuer: Server Auth`。
   - 增加 `role_gate: platform_reviewer_or_super_admin`。

2. `docs/01_contracts/identity_permission_minimum_contracts.yaml`
   - 同步修改 `admin.login_mode`。
   - 保留 `platform_reviewer_or_super_admin` 定义。

3. `docs/01_contracts/auth_password_login_round_b_contract_freeze.md`
   - 追加边界说明：仅 App-facing，不定义 Admin password login。

4. `docs/01_contracts/debug_whitelist_session_contracts_addendum.md`
   - 将“Admin 密码登录流程”措辞改成“Admin carrier-only 接入流程”。

5. `docs/00_ssot/source_of_truth_map.md`
   - 注册 `admin_session_carrier_login_truth_addendum.md`。
   - 注册本清理计划。
   - 标注旧 `account_password_plus_second_factor` 术语被 supersede。

可选修改：

6. `docs/05_admin/admin_ssot.md`
   - 增加一行 Admin 登录真相索引。

禁止修改：

- 不改 `apps/admin/**` 业务代码。
- 不改 `apps/server/**` Auth 行为。
- 不改 `apps/bff/**`。
- 不改数据库。
- 不改 `openapi.yaml` 中 app-facing password auth，除非另开 App auth mode 裁决窗口。
- 不重生成 `openapi.bundle.json` 或 `packages/contracts/src/generated/**`，除非另开 contracts/generated clean-window。
- 不新增 Admin 账号密码登录。
- 不新增 Admin 注册。
- 不把 `whitelist-test-session` 写成正式登录方式。
- 不输出真实 token、手机号、密钥。

## 6. Go / No-Go

当前漂移清理进入最小文书 patch：`Go`。

允许进入的最小范围：

- 清理 Admin 登录旧术语。
- 补充 App-facing password auth 与 Admin 登录的隔离说明。
- 登记新 SSOT 的优先级。

不允许进入的范围：

- Admin 登录产品改造。
- Server Auth 行为改造。
- App auth mode 重新裁决。
- OpenAPI/generated 重生成。
- whitelist-test-session 生产化。
- raw role header 权限语义重构。

唯一下一步动作：

提交 `Admin auth truth docs clean-window` 最小 patch，先改 D1 / D2 / D5 / D6 / source map；D3 / D8 / D9 保持待裁决，不在同一 patch 内扩张。
