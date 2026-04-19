---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L5 frontend consumption boundary for `BidAward bridge`, including
  the minimum route/page carriers, buyer-side award entry handoff,
  supplier-side loser-result read outlet, controlled loading/failure/feedback,
  and the hard rule that Flutter only consumes app-facing projection and must
  not inflate workbench, my-project, or project detail into a second trade
  console or truth owner.
layer: L5 Frontend
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/00_ssot/bid_award_bridge_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/bid_award_bridge_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/bid_award_bridge_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/bid_award_bridge_package_level_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/bid_award_bridge_phase0_implementation_exception_independent_review_addendum.md
  - docs/01_contracts/bid_award_bridge_contract_freeze_addendum.md
  - docs/02_backend/bid_award_bridge_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/bid_award_bridge_bff_surface_freeze_addendum.md
  - docs/04_frontend/frontend_ssot.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
---

# 《BidAward bridge frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `BidAward bridge`
- 本冻结单只服务于：
  - 当前对象 Flutter 最小消费边界
  - buyer 侧最小 award 入口 handoff
  - supplier 侧最小 loser result 读取出口
  - 当前对象 `loading / content / blocker / failure / controlled feedback`
  - 当前对象 fallout refresh 的最小页面承接边界
- 本冻结单不进入：
  - `apps/mobile/**` 实现
  - 新业务工作台
  - compare console
  - `my bids workspace`
  - integration
  - release-prep
  - production release

## 2. Frontend Freeze Conclusion

- 本轮 frontend freeze 不是 `no-op`。
- 当前正式冻结：
  - Flutter 只消费 `BFF` app-facing projection
  - buyer 侧 award 入口不新开独立工作台
  - supplier 侧 loser result 不新开独立 workspace
  - 现有 `Workbench / My Project / Project Detail / Bid Submit` 只允许承担最小 handoff 与最小读取
- 当前必须明确：
  - repo 中还没有 `bid award` 专用 page / route family
  - 当前冻结只定义最小消费落点
  - 不得被误读为当前 frontend 已实现 bridge 主链

## 3. Frontend 总边界

Flutter 当前只允许做：

- consume app-facing projection
- controlled `loading / content / blocker / failure`
- controlled submit feedback
- continuation handoff
- 最小状态文案映射

Flutter 当前不得做：

- truth owner
- 第二交易状态机
- 本地 winner / loser 判断
- 本地 award legality 判断
- 把 `Workbench` 做成交易总控台
- 把 `My Project` 做成 bridge 真相页
- 把 `Project Detail` 做成 buyer compare console

## 4. 最小 route / page carrier 冻结

### 4.1 当前批准的最小 carrier

- 当前只允许冻结以下现有 route / page 作为最小消费承接位：
  - `/exhibition/my/projects/detail`
  - `/exhibition/bids/submit`
  - `/exhibition/workbench`
  - `/exhibition/projects/detail`

### 4.2 当前明确不新开

- 当前不得新开以下 family：
  - `/exhibition/bids/award`
  - `/exhibition/bids/result`
  - `/exhibition/bids/compare`
  - `/exhibition/my/bids`
  - `/exhibition/orders/create`

## 5. Buyer 侧 award 入口冻结

- buyer 侧最小 award 入口当前只允许挂在：
  - `/exhibition/my/projects/detail`

### 5.1 角色定位

- `my project detail`
  只允许承担：
  - owner 私域继续动作入口
  - 当前 bridge handoff 入口

### 5.2 硬边界

- 当前不得把 `my project detail` 扩成：
  - compare board
  - loser 管理台
  - order create 控制台
  - contract seed 控制台

## 6. Supplier 侧 loser result 出口冻结

- supplier 侧最小 loser result 读取出口当前只允许复用：
  - `/exhibition/bids/submit`

### 6.1 正式含义

- `bid submit` 页面当前允许增加最小 result 读取模式，
  但不得改名、不得膨胀成 workspace。
- 当前 `GET /api/app/bid/result?projectId={projectId}` 的最小消费出口，
  只允许挂在该页面或其最小 result section 上。

### 6.2 硬边界

- 当前不得：
  - 新开 supplier `my bids workspace`
  - 新开独立 loser detail page
  - 新开 compare 结果页

## 7. `Project Detail` 与 `Workbench` 的消费边界

### 7.1 `Project Detail`

- 当前只允许：
  - 显示 `awarded / converted_to_order` 的最小状态文案
  - 作为 public / optional-auth 下的项目信息页
- 当前不得：
  - 变成 buyer 私域 award 操作台
  - 变成 supplier result 真相页

### 7.2 `Workbench`

- 当前只允许：
  - summary
  - handoff
  - 待办提示
- 当前不得：
  - 变成 award 操作页
  - 变成 loser disposition 读取页
  - 变成 bridge 真相页

## 8. Fallout Refresh 消费边界

- award 成功后的最小 refresh 面只允许承接：
  - buyer 侧 `My Project`
  - buyer 侧 `Workbench`
  - `Project Detail` 的状态文案更新

### 8.1 最小消费语义

- Flutter 只允许消费：
  - `project.state = awarded / converted_to_order`
  - `privateProgress.orderStatus`
  - `privateProgress.contractStatus`
  - `workbench.project_chain / order_chain` 的最小 continuation 提示

### 8.2 硬边界

- Flutter 不得把这些投影解释为：
  - `BidAward` 真相
  - loser disposition 真相
  - compare matrix 真相

## 9. Controlled feedback 边界

- 当前页面允许展示：
  - `loading`
  - `content`
  - `blocker`
  - `failure`
  - controlled invalid-state
  - controlled unavailable
  - controlled conflict

### 9.1 允许的 submit/result 反馈

- 对 `POST /api/app/bid/award`，
  Flutter 只允许展示：
  - 稳定成功反馈
  - 稳定 invalid-state / duplicate / concurrent-conflict 反馈
- 对 `GET /api/app/bid/result`，
  Flutter 只允许展示：
  - 最小 result
  - unavailable / invalid 的受控反馈

### 9.2 禁止动作

- Flutter 不得：
  - 本地猜测“这次并发谁赢了”
  - 将 unavailable 伪装成空成功
  - 将 duplicate 伪装成“已经完成可忽略”

## 10. 最小 authoring 触达范围冻结

### 10.1 必改 authoring 目标

- 首轮 frontend authoring 只允许围绕：
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`

### 10.2 条件触达

- 只有在 fallout refresh 无法自然承接时，才允许条件触达：
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart`

### 10.3 禁止触达

- 当前明确禁止触达：
  - 新 route 注册族
  - `apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/rating_*`
  - `apps/mobile/lib/features/exhibition/presentation/pages/dispute_*`

## 11. 非目标

- 当前明确不做：
  - frontend real dispatch
  - compare board
  - `my bids workspace`
  - 独立 winner / loser page family
  - `seat`
  - `bid package completeness`
  - payment / split-billing / electronic signature
  - complex scoring / heavy risk control

## 12. 阶段结论

- 当前阶段结论只允许写：
  - `Go for freeze-chain closure / reentry ruling authoring`
  - `No-Go for frontend real dispatch issuance`
  - `No-Go for implementation unlock`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
