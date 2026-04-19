---
owner: Codex 总控
status: active
purpose: Record the execution receipt for the bounded integration-verification round of enterprise-display three-board independence, including live tunnel evidence, targeted regression results, and the formal conclusion that legacy compatibility bridges remain required until cloud board-scoped family exposure and authenticated positive smoke are closed.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_integration_verification_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_integration_verification_dispatch_bundle_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_legacy_compatibility_removal_plan_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_bff_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_execution_receipt_addendum.md
---

# 《enterprise display three-board independence integration verification execution receipt》

## 1. Scope Closure

- 当前 receipt 只覆盖：
  - tunnel-based runtime evidence collection
  - authenticated integration attempt
  - targeted regression against current cloud-visible compatibility surfaces
  - legacy compatibility removal plan output
- 当前 receipt 不覆盖：
  - code implementation
  - deploy / restart / rollback
  - bridge deletion
  - production release

## 2. Delivered Docs

- [enterprise_display_three_board_independence_integration_verification_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_three_board_independence_integration_verification_stage_gate_checklist_addendum.md)
- [enterprise_display_three_board_independence_integration_verification_dispatch_bundle_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_three_board_independence_integration_verification_dispatch_bundle_addendum.md)
- [enterprise_display_three_board_independence_legacy_compatibility_removal_plan_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_three_board_independence_legacy_compatibility_removal_plan_addendum.md)

## 3. Touched Code and Runtime Surfaces

- 当前轮没有代码写入。
- 当前轮只读观测的 live runtime surfaces 包括：
  - `GET http://127.0.0.1:8080/health/bff/live`
  - `POST /api/app/auth/otp/login`
  - `GET /api/app/exhibition/enterprise-hub/company/recommendations`
  - `GET /api/app/exhibition/enterprise-hub/company/enterprises?page=1&pageSize=1`
  - `GET /api/app/exhibition/enterprise-hub/company/enterprises/{enterpriseId}`
  - `GET /api/app/exhibition/enterprise-hub/factory/enterprises?page=1&pageSize=1`
  - `GET /api/app/exhibition/enterprise-hub/factory/recommendations`
  - `GET /api/app/exhibition/enterprise-hub/supplier/recommendations`
  - `GET /api/app/exhibition/enterprise-hub/company/workbench`
  - `GET /api/app/exhibition/enterprise-hub/factory/workbench`
  - `GET /api/app/exhibition/enterprise-hub/supplier/workbench`
  - `GET /api/app/exhibition/enterprise-hub/recommendations?boardType=company`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=company`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory&page=1&pageSize=1`
  - `GET /api/app/exhibition/enterprise-hub/workbench?boardType=factory`
  - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=factory`

## 4. Authenticated Integration Result

- tunnel health：
  - `GET /health/bff/live` 返回 `200 OK`
  - 说明本地 SSH tunnel 与云上 BFF runtime 已连通
- auth entry：
  - `POST /api/app/auth/otp/login`
  - 样本 mobile `18696563700`、otp `000000`
  - 返回 `401 AUTH_LOGIN_INVALID`
  - 说明当前轮没有拿到有效 access token
- canonical board-scoped family route visibility：
  - `GET /api/app/exhibition/enterprise-hub/company/recommendations` 返回 `200 OK`
  - `GET /api/app/exhibition/enterprise-hub/company/enterprises?page=1&pageSize=1` 返回 `200 OK`
  - `GET /api/app/exhibition/enterprise-hub/company/enterprises/e2a016f4-0b6a-497d-902c-409413858ca9` 返回 `200 OK`
  - `GET /api/app/exhibition/enterprise-hub/factory/recommendations` 返回 `200 OK`
  - `GET /api/app/exhibition/enterprise-hub/factory/enterprises?page=1&pageSize=1` 返回 `200 OK`
  - `GET /api/app/exhibition/enterprise-hub/supplier/recommendations` 返回 `200 OK`
  - `GET /api/app/exhibition/enterprise-hub/company/workbench` 在 fake `x-actor-id` 下返回 controlled `401 AUTH_SESSION_INVALID`
  - `GET /api/app/exhibition/enterprise-hub/factory/workbench` 在 fake `x-actor-id` 下返回 controlled `401 AUTH_SESSION_INVALID`
  - `GET /api/app/exhibition/enterprise-hub/supplier/workbench` 在 fake `x-actor-id` 下返回 controlled `401 AUTH_SESSION_INVALID`
  - 远端只读核对：
    - `readlink -f /srv/apps/bff/current` 指向 `20260419173126-enterprise-display-three-board-bff-family`
    - `systemctl show exhibition-bff -p ActiveEnterTimestamp -p MainPID`
    - `/proc/<pid>/cwd` 指向该 release
- 当前 integration judgment：
  - 云上新 board-scoped family 已暴露
  - 当前轮 authenticated positive integration pass 仍不成立，因为没有拿到真实 access token

## 5. Targeted Regression Result

- shared public recommendations：
  - `GET /api/app/exhibition/enterprise-hub/recommendations?boardType=company`
  - 返回 `200 OK`
  - body 为 `{"boardType":"company","items":[]}`
- shared public list：
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1`
  - 返回 `200 OK`
  - 命中 real enterprise：
    - `enterpriseId = e2a016f4-0b6a-497d-902c-409413858ca9`
    - `name = 重庆坤特展览展示有限公司`
    - `boardType = company`
    - `caseCount = 1`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory&page=1&pageSize=1`
  - 返回 `200 OK`
  - 命中 real factory：
    - `enterpriseId = a9b46040-956e-44fd-8e35-e3c533687e27`
    - `name = 重庆海川展览工厂`
    - `boardType = factory`
    - `caseCount = 1`
- shared public detail：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/e2a016f4-0b6a-497d-902c-409413858ca9?boardType=company`
  - 返回 `200 OK`
  - detail 中 `casesState = available`
  - case 列表命中：
    - `caseId = a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64`
    - `coverImageUrl` 已走 `enterprise_display/enterprise_case_media/...`
- shared private bridge continuity：
  - `GET /api/app/exhibition/enterprise-hub/workbench?boardType=factory` 携带 fake `x-actor-id` 返回 `401 AUTH_SESSION_INVALID`
  - `GET /api/app/exhibition/enterprise-hub/applications/c1e83c6f-4637-407f-8d41-5c1413821874` 携带 fake `x-actor-id` 返回 `404 ENTERPRISE_HUB_APPLICATION_NOT_FOUND`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/bf5ff83a-26e7-4138-8157-042fb38a5f46?boardType=factory` 携带 fake `x-actor-id` 返回 `404 ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND`
- regression judgment：
  - shared compatibility bridge 当前仍然存活
  - private shared bridge 至少没有 route-level 缺失
  - current cloud behavior 说明旧桥仍在承接实际流量，但 canonical family 现在也已可见

## 6. Legacy Compatibility Removal Plan Output

- standalone removal plan 已形成：
  - [enterprise_display_three_board_independence_legacy_compatibility_removal_plan_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_three_board_independence_legacy_compatibility_removal_plan_addendum.md)
- 当前结论固定为：
  - 可以 author 计划
  - 不能执行 bridge deletion

## 7. Verification

- 当前轮主要验证命令：
  - `curl -sS -D - http://127.0.0.1:8080/health/bff/live`
  - `curl -sS -D - -X POST http://127.0.0.1:8080/api/app/auth/otp/login ...`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/recommendations?boardType=company'`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/company/recommendations'`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1'`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/company/enterprises?page=1&pageSize=1'`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises/e2a016f4-0b6a-497d-902c-409413858ca9?boardType=company'`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/company/enterprises/e2a016f4-0b6a-497d-902c-409413858ca9'`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises?boardType=factory&page=1&pageSize=1'`
  - `curl -sS -D - 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/factory/enterprises?page=1&pageSize=1'`
  - `curl -sS -D - -H 'x-actor-id: actor-1' 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/company/workbench'`
  - `curl -sS -D - -H 'x-actor-id: actor-1' 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/factory/workbench'`
  - `curl -sS -D - -H 'x-actor-id: actor-1' 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/supplier/workbench'`
  - `ssh root@47.108.180.198 'readlink -f /srv/apps/bff/current'`
  - `ssh root@47.108.180.198 'systemctl show exhibition-bff -p ActiveEnterTimestamp -p MainPID'`
- 当前轮没有新增 automated test，因为本轮是 runtime read-only evidence collection 与 docs authoring，不是代码实现。

## 8. Residual Risks

- 当前没有有效 access token，所以 authenticated positive smoke 仍未闭合。
- 当前云上 canonical family 已可见，但还没有真实登录态证明 private canonical chain 完整闭合。
- 历史 receipt 中的旧 enterpriseId / applicationId 样本已不稳定，不能继续当正向 smoke 证据复用。
- 由于还没有 positive authenticated smoke，本轮仍不能得出“兼容桥可以删除”的结论。

## 9. Formal Conclusion

- `Package A / authenticated integration verification`：已执行，但未取得 positive authenticated pass
- `Package B / targeted regression`：已执行，shared compatibility bridge continuity 已取证
- `Package C / legacy compatibility removal plan authoring`：已完成
- 当前总判断：
  - `Go for keeping legacy compatibility bridges for now`
  - `No-Go for legacy compatibility bridge deletion`
  - `No-Go for deploy / restart / rollback`
  - `No-Go for release-prep`
  - `No-Go for production release`
