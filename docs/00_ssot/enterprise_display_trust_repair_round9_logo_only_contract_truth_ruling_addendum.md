---
owner: Codex 总控
status: frozen
purpose: Freeze the Logo-only contract/truth scheme after independent verification confirmed that the current carrier still incorrectly depends on applicant fields.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-09
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round8_independent_verification_judgment_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-application.entity.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
---

# 《enterprise display trust repair round 9 Logo-only contract/truth ruling》

## 1. 当前 blocker 裁决

- 当前 `Logo-only` 不是前端单点校验错误。
- 当前真正的 blocker 是：
  - `enterprise shell` 的首次获取被错误绑定到 `createApplication`
  - `createApplication` 又强制要求：
    - `applicantName`
    - `applicantMobile`
  - `enterprise_application` 实体也把这两个字段冻结成必填 persistence truth
- 因此现在的真实问题不是“Logo 上传组件拦截过严”，而是：
  - `listing shell carrier` 与 `application carrier` 被混成了一条链

## 2. 当前证据链

- round-8 独立校验已正式判定：
  - `Logo-only` 仍未关闭，`createApplication` 继续强制 `applicantName / applicantMobile`
- 当前 `Server` write 链明确如此实现：
  - `createApplication()` 先 `readText(payload.applicantName)`
  - `createApplication()` 再 `readText(payload.applicantMobile)`
  - 然后才创建或复用 listing/application
- 当前 contract 也把 `enterprise_application` 冻为：
  - `applicantName: string`
  - `applicantMobile: string`

## 3. 正式方案裁决

### 3.1 shell carrier 与 application carrier 必须拆开

- 当前正式裁决：
  - `enterprise_listing` 才是 `Logo-only` 与基础资料草稿维护的 carrier
  - `enterprise_application` 只承担申请流转 carrier
- 这意味着：
  - 先拿到 `enterprise shell`
  - 后进入 `application draft / submit`
  是两步，不得再强绑成一步

### 3.2 不允许用“放宽 application 必填”伪修

- 当前正式禁止以下伪方案：
  - 把 `enterprise_application.applicantName / applicantMobile` 改成允许空值，然后继续让 `Logo-only` 走 `createApplication`
  - 伪造申请人姓名/手机号
  - 用认证资料或组织资料静默冒充申请人资料
- 原因：
  - 这会污染申请流 carrier
  - 也会把联系人真值和申请人真值混成一套

### 3.3 首选 contract/truth 方向

- 当前首选方案正式冻结为：
  - `Logo-only` 和基础资料维护先拿 `enterpriseId`
  - `createApplication` 留给真正进入申请流时再调用
- 下一轮 contract/truth 必须至少解决一件事：
  - app-facing 如何在不要求申请人字段的前提下拿到或确保 `enterprise shell`
- 当前允许的实现方向只有两类：
  - `workbench read / ensure-shell` 路由在 organization scope 下返回或创建 `enterpriseId`
  - 或由现有 basic/upload 写链内部显式走 `ensureOwnedListingShell`
- 当前不允许的方向：
  - 继续把 `applicationId` 当成 `enterprise shell` 的唯一入口

### 3.4 submit chain 继续保留联系人/申请人硬门槛

- 当前正式裁决：
  - `Logo-only` 可先脱离申请人门槛
  - 但 `submit application` 仍必须在受控时机校验：
    - primary contact
    - applicantName
    - applicantMobile
- 当前不允许把“可上传 Logo”误解成“可无联系人提交入驻”

## 4. 下一轮必须冻结什么

- `docs/01_contracts`
  - `enterprise shell acquisition` 的 app-facing contract
- `docs/02_backend`
  - listing shell 与 application draft 的 truth boundary
  - audit 与 persistence 是否受影响
- `docs/03_bff`
  - 仅做 transport / shaping，不新增第二状态机

## 5. Anti-revert

- 不得把 `Logo-only` 再绕回 `createApplication` 前置。
- 不得把 `enterprise_application` 继续当基础资料草稿 carrier。
- 不得伪造申请人字段来换取 `enterpriseId`。
- 不得把“联系人缺失不可提交”偷改成“联系人缺失也可提交”。

## 6. Formal Conclusion

- `Logo-only` 下一轮实施必须按“shell 与 application 分离”推进。
- 当前正式结论不是“放宽校验”，而是“纠正 carrier 边界”。
- 在 contract / backend truth / BFF surface 冻结完成前，`Logo-only` 仍然是 blocker，不得报已修复。
