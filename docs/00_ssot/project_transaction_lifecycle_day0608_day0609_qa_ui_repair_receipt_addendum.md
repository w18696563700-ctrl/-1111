# Project Transaction Lifecycle Day0608-Day0609 QA / Flutter UI Repair Receipt Addendum

计划日期：2026-06-08 至 2026-06-09
执行记录日期：2026-04-26
状态：Repo-local Conditional Pass；Production / dual-account UAT No-Go

## 1. 结论

Day0608 与 Day0609 可以作为“负向 QA 覆盖 + Flutter 受控 UI 修复包”完成，但不能作为 100% 生产验收完成。

更稳：承认当前证据只覆盖本地仓库测试、Flutter widget 行为和既有 Server/BFF 测试清单，不冒充阿里云真实双账号交易验收。

更省成本：先补前端负向文案、空态、错误态、按钮禁用态与本地回归测试，再等 Computer Use 与真实双账号可用时补云上负向验收。

更适合当前阶段：Day0608-Day0609 先收口“不能跨 projectId/orderId 操作”的 UI 与测试报告口径；生产放行仍留到后续云上 R2 / Computer Use。

风险更大：把 repo-local 测试、401 路由探针、或未带真实交易数据的隧道访问写成生产验收通过。

## 2. 当前最小闭环

- Flutter 已统一交易链路动作失败文案：登录失效、权限不足、资源不可见、幂等冲突、重复竞标/定标、非法完工状态、双方互评未开放/越权/重复提交均进入中文受控提示。
- `OrderStatusCard` 的订单读取失败不再直接展示 raw BFF message，统一走 `_userFacingLoadFailureMessage`。
- `LoadStateCard` 的 `unauthorized` / `forbidden` 不再直接直出后端 message，先走受控文案映射。
- 新增 Flutter 负向 widget 覆盖：重复选择合作方、非法完工申请、双方互评越权提交、双方互评重复提交，均验证不泄露 canonical path / stack trace。
- 项目沟通页订单卡回归通过：订单卡缺组织锚点只读、承接方申请完工、发布方确认完工、完成后评价入口、相册与聊天链路保持可用。

## 3. 需要保留但暂不开通

- 不声明 Production Pass。
- 不声明真实双账号完整负向验收已完成。
- 不声明阿里云当前运行版本已经覆盖所有负向分支。
- 不新增 Server/BFF 状态机，不在 BFF 揉平业务真值。
- 不通过手工改 DB、mock 数据或本地路由替代真实交易链路验收。

## 4. 后续扩展位

- Computer Use 双账号负向验收：发布方、承接方、第三方账号分别验证权限边界。
- 云上跨锚点验收：错误 `projectId/orderId`、错误 `rateeOrganizationId`、跨组织订单、跨项目订单必须被 Server/BFF 拦截。
- 幂等与重复提交云上验收：重复点击选择合作方、重复申请完工、重复确认完工、重复评价必须返回稳定错误码或稳定已处理结果。
- 状态回退验收：未申请完工不能确认完成；未完成订单不能评价；已完成订单不能重复回退到 active。
- 信用链路验收：评价提交后必须能查到 `rating truth -> credit shadow recompute / ledger` 证据。

## 5. Day0608 QA 覆盖矩阵

| 维度 | repo-local 证据 | 当前结论 |
| --- | --- | --- |
| 权限 | Server/BFF 既有测试覆盖 outside order boundary、missing truth anchor、forbidden transport；Flutter 新增 `PROJECT_COUNTERPARTY_RATING_FORBIDDEN` 受控展示 | Conditional Pass |
| 幂等 | 既有 BFF/Server 测试覆盖 duplicate / conflict；Flutter 新增 `IDEMPOTENCY_KEY_CONFLICT` 统一受控文案 | Conditional Pass |
| 重复提交 | Flutter 新增重复选择合作方、重复双方互评；Server/BFF 既有重复投标、重复定标、重复评价测试 | Conditional Pass |
| 跨 projectId/orderId 越权 | Server/BFF 既有 mismatched optional projectId / outside scoped order chain 测试；Flutter 只负责不泄露 raw 错误 | Conditional Pass |
| 状态回退 / 非法状态 | Flutter 新增非法完工申请受控展示；Server 既有 active order confirm reject、未完成订单不可评价、rollback clean 测试 | Conditional Pass |
| 云上真实双账号 | 本轮未使用 Computer Use，不做云上写链路 | No-Go |

## 6. Day0609 Flutter UI 修复包

改动文件：

- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart`
- `apps/mobile/test/rating_entry_test.dart`
- `apps/mobile/test/bid_award_bridge_test.dart`

修复口径：

- 空态：继续不本地编造竞标候选、订单状态、评价入口。
- 错误态：稳定错误码优先映射中文业务文案，英文 upstream message、canonical path、stack trace 不进入用户界面。
- 加载态：保留现有读取中与刷新状态，不改变业务真值。
- 按钮禁用态：提交中禁用；已申请完工禁用重复申请；完成后只展示互评入口或缺锚点只读提示。

## 7. 验证命令

已通过：

```bash
cd apps/mobile
flutter test test/rating_entry_test.dart test/bid_award_bridge_test.dart
flutter test test/counterpart_conversation_chat_test.dart
flutter analyze lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart lib/features/exhibition/presentation/widgets/exhibition_status_widgets.dart lib/features/exhibition/presentation/presentation_support/order_status_card.dart test/rating_entry_test.dart test/bid_award_bridge_test.dart
```

结果：

- `rating_entry_test.dart` + `bid_award_bridge_test.dart`：11/11 passed
- `counterpart_conversation_chat_test.dart`：13/13 passed
- `flutter analyze`：No issues found

## 8. 阶段门禁核查表

Passed gates：

- Flutter 负向错误码进入受控中文文案。
- 重复定标、非法完工、互评越权、互评重复提交均有 widget 测试。
- 项目沟通页订单卡回归通过。
- BFF/Server 没有被本轮本地改造为第二真值或第二状态机。

Failed / veto gates：

- 云上真实双账号负向验收未执行。
- 生产交易链路仍缺真实 `projectId/orderId/buyerOrgId/sellerOrgId/rating/credit ledger` 全链路证据。
- 本地 repo-local 测试不能替代阿里云当前版本验收。

Next stage：

- 允许进入 Day0610 的云上 R2 发版准备与 migration / rollback plan。
- 不允许宣布 100% 生产验收完成。
- 不允许跳过 Computer Use 双账号验收直接 cutover。
