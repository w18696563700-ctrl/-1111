---
owner: Codex 总控
status: frozen
purpose: Freeze the next increment-dispatch judgment for `我的楼功能本体 Round 1`, keeping the active mainline on feature-body progression only and explicitly suspending any further gate-chain motion unless the user explicitly reopens it.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_backend_profile_consistency_correction_review_conclusion_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_bff_profile_consistency_correction_review_conclusion_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_frontend_success_path_correction_review_conclusion_addendum.md
  - apps/server/src/modules/profile/profile-query.service.ts
  - apps/server/src/modules/profile/profile-certification-write.service.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/organization/organization-write.service.ts
  - apps/bff/src/routes/profile/profile-read.service.ts
  - apps/bff/src/routes/profile/profile-command.service.ts
  - apps/bff/src/routes/shell/shell.service.ts
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart
  - apps/mobile/test/profile_page_test.dart
  - apps/mobile/test/profile_identity_contract_compat_test.dart
  - apps/mobile/test/my_project_private_carry_test.dart
---

# 《我的楼功能本体 Round 1 下一批增量施工判断》

## 1. Current Single Mainline

- 当前唯一主线：
  - `我的楼功能本体推进`
- 当前唯一动作：
  - `增量施工判断 / 派工`
- 当前明确禁止：
  - `integration`
  - `release-prep`
  - `launch-approval`
  - `closure judgment`
- 除非用户明确说出：
  - `进入后段门禁`
  否则当前主线不得切回联调发布链

## 2. 当前功能缺口清单

- 当前最明确的功能缺口已经收缩到：
  - `organization/join-by-code` 缺少 live success sample
  - `certification/resubmit` 缺少 `rejected / expired` 前置 truth 下的 success sample
- 当前这两个缺口的性质不同：
  - `join-by-code` 当前更接近“样本与承接闭环未完全补齐”
  - `resubmit` 当前更接近“真实前置状态尚未进入当前范围”
- 当前 `我的楼` hub、`我的公司`、`认证与成员身份`、`我的项目` private carry 主体已经成立，当前不再是“主体未做”，而是“剩余样本闭环和稳定性补齐”
- 当前 `profile` 认证状态聚合分叉已在后端 truth 层收口，BFF 与前端 success-path 也已收口；下一批不再围绕“null / not_submitted 分叉修 bug”展开

## 3. 本轮必做项

- 必做 1：
  - 把 `organization/join-by-code` 推到真正可引用的 end-to-end success sample
  - 目标不是新功能扩面，而是把现有真源路径补到“成功样本已存在、前端承接已成立、页面真值已回读”
- 必做 2：
  - 对 `我的楼` hub、`我的公司`、`认证与成员身份` 做 join success 后的同源回读承接收口
  - 成功后必须统一回读 app-facing truth，不得停在旧局部状态
- 必做 3：
  - 把当前剩余样本缺口分类冻结清楚：
    - 哪些是 implementation gap
    - 哪些是 runtime sample gap
    - 哪些是当前范围外前置 truth

## 4. 本轮冻结占位项

- `certification/resubmit` success sample 当前继续冻结：
  - 只有当真实 `rejected / expired` truth 进入当前范围后，才允许继续向 success sample 推进
- `security/devices` 继续冻结为受控壳
- `organization members list / role / disable` 继续冻结
- `admin review / governance` 继续冻结
- `我的项目` owner manage 继续冻结为 shell，不接 action execution
- `organizationType=both` 的 richer dual-role semantics 继续冻结

## 5. 战略保留项

- 会员系统
- 信用 / 保证金系统
- 支付 / 账单系统
- 完整治理后台
- 完整风险与安全中心
- richer forum 主线
- `我的项目` richer 私域状态、附件、治理、动作矩阵

## 6. 前端/后端/BFF/文书冻结/校验的增量派工矩阵

- `前端`
  - 只负责：
    - `organization/join-by-code` success 后的 hub / company / identity 同源回读承接
    - 当前已有 success-path closeout 的稳态维护
  - 不得：
    - 新建页面家族
    - 回退 `我的项目` 主体
    - 扩到 devices / governance

- `后端`
  - 只负责：
    - `join-by-code` success sample 所需的 canonical invite truth 可验证性
    - 当前 truth 路径的最小稳定性补齐
  - 不得：
    - 新造第二 truth
    - 把 `resubmit` 前置 truth 越权补进当前范围

- `BFF`
  - 只负责：
    - `join-by-code` success envelope 的 app-facing bounded shaping
    - 读链 / 命令链与 frozen truth 的一致性兜底
  - 不得：
    - 持有 truth
    - 引入第二状态机

- `文书冻结`
  - 只负责：
    - 冻结“下一批只围绕 join success sample 闭环”的边界
    - 明确 `resubmit` 仍是冻结占位
  - 不得：
    - 提前切回任何 gate / release / closure 文书

- `校验`
  - 只负责：
    - 校验 `join-by-code` success sample 是否真正 end-to-end 成立
    - 校验 `我的楼` hub、`我的公司`、`认证与成员身份` 是否仍然只读同一套 app-facing truth
    - 校验 `我的项目` 是否没有回退

## 7. Current Dispatch Recommendation

- 当前 dispatch recommendation：
  - `Go` for `我的楼功能本体 Round 1` 下一批增量施工
- 当前通过的真实含义：
  - 可以进入下一批功能本体派工
  - 不能把当前判断写成任何后段门禁结论

## 8. Next Unique Action

- 下一轮唯一动作：
  - 先输出《我的楼功能本体 Round 1 后端派工口令：join-by-code success sample 补齐判断》
