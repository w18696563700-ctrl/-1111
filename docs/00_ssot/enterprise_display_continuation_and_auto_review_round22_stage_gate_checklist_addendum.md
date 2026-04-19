---
owner: Codex 总控
status: frozen
purpose: Record the stage gate checklist for enterprise display continuation repair and server-side auto-review v1 preparation.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-22
inputs_canonical:
  - docs/02_backend/enterprise_display_workbench_v1_backend_truth_addendum.md
  - docs/02_backend/enterprise_display_continuation_and_auto_review_round22_backend_truth_scope_addendum.md
  - docs/04_frontend/enterprise_display_continuation_and_auto_review_round22_frontend_consumption_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-app.service.ts
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_application_status_support.dart
---

# 《enterprise display continuation and auto-review round22 stage gate checklist》

## 1. 本轮目标

- 打通未发布申请在 `approved / revision_required / rejected` 后的继续测试入口。
- 收口已发布展示的修改与新增案例入口口径，明确继续维护走 `published-change corridor`。
- 冻结 `Server auto-review v1` 的实现边界，限定为：
  - `自动审核`
  - `不自动发布`

## 2. 非目标

- 不做 AI 审核接入
- 不做 `publishListing()` 自动化
- 不做新的推荐位、曝光位或运营治理逻辑
- 不做 BFF 第二状态机

## 3. passed gates

- 当前 `Server` 已具备：
  - `createApplication()` 新建或复用 `draft` 的真值能力
  - `published-change corridor` 的 current draft / case create / case update / submit 能力
- 当前 `Flutter` 已具备：
  - workbench / published-change 双模式承载结构
  - 已发布展示案例保存进入 current change carrier 的消费链
- 当前审核真值仍完全集中在 `Server`，`BFF` 只透传状态，适合按既有拓扑接入 `auto-review v1`。

## 4. failed gates

- 当前未发布申请在 `approved / revision_required / rejected` 后缺少显式的“重新创建申请草稿”前端入口。
- 当前用户对“已审核通过但未发布”与“已发布后继续修改”的路径区分不清晰。
- `auto-review v1` 尚无正式冻结文书，不应直接写进代码。

## 5. veto gates

- 本轮禁止：
  - 在 `BFF` 或 Flutter 本地发明自动审核判定
  - 把 `自动审核` 与 `自动发布` 绑成一条状态链
  - 绕过 `published-change corridor` 直接修改 live listing
- 上述 veto gate 当前均可通过文书冻结和 bounded write set 规避。

## 6. Go / No-Go

- 对 `frontend continuation repair`：
  - `Go`
- 对 `published-change entry/wording repair`：
  - `Go`
- 对 `Server auto-review v1 docs-first implementation`：
  - `Go`
- 对 `AI auto-review`：
  - `No-Go`

## 7. Formal Conclusion

- 当前允许进入：
  - `frontend continuation bounded implementation`
  - `published-change corridor entry bounded implementation`
  - `Server auto-review v1 docs-first bounded implementation`
- 当前不允许进入：
  - `AI review`
  - `auto publish`
  - `BFF-owned review state`
