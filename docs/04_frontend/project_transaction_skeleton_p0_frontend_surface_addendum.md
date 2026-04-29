---

## Pricing Rebaseline Note

本文件继续保留 `项目交易骨架 P0` 的总体 Flutter 边界意义。

但自 [platform_pricing_frontend_consumption_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md) 生效后，本文件中把 `payment / deposit` 一并排除出当前对象的旧阶段性条款，不再裁决现行收费 `L5 Flutter consumption`。

当前正式解释固定如下：

1. Flutter 仍不得本地判断最终收费真相
2. Flutter 仍不得自建第二收费状态机
3. 但 `200 元项目真实性诚意金`、`4000 元竞标服务费预授权额度`、`deal confirmation` 已有独立的当前收费 `L5` authority，不再受本文件旧排除口径限制
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-side surface for `项目交易骨架 P0`, including admitted
  pages, UI guard vs final truth split, page handoff graph, and forbidden copy
  that must not misrepresent profile-side bounded packages as trade-mainline capability.
layer: L5 Frontend
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_transaction_skeleton_p0_gate_checklist.md
  - docs/01_contracts/project_transaction_skeleton_p0_contracts_addendum.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/03_bff/project_transaction_skeleton_p0_bff_surface_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/profile/data/profile_membership_consumer_layer.dart
  - apps/mobile/lib/features/profile/data/profile_payment_billing_models.dart
  - apps/mobile/lib/features/profile/data/profile_credit_constraints_consumer_layer.dart
---

# 项目交易骨架 P0 Frontend Surface Addendum

## 1. Scope

本文件只冻结 Flutter 在 `项目交易骨架 P0` 中允许承载的页面与交互。

本文件不做：

- Flutter 业务实现
- payment / billing / credit / deposit / guarantee 页面升格
- project visibility / review runtime UI

## 2. 页面 / 路由矩阵

| 页面或入口 | 当前定位 | P0 定位 | 当前裁决 |
|---|---|---|---|
| `project/list` | 公域发现 | 既有上游入口 | 保持现状 |
| `project/detail` | 公域 detail + owner/non-owner handoff | 既有上游入口 | 保持现状 |
| `my/projects` | 私域资产列表 | 既有私域承接 | 保持现状 |
| `my/projects/{id}` | 私域单项目承接 | 既有私域承接 | 保持现状 |
| `exhibition/workbench` | 私域四容器摘要 | 既有私域承接 | 保持现状 |
| `bid continuation` | 从 public detail 进入的继续竞标入口 | P0 write corridor 起点页面 | 批准 |
| `order detail` | 交易 read corridor 页面 | read-only baseline | 保留 |
| `order create handoff` | 从 bid 成功后的下一动作 | P0 write corridor | 批准 |
| `contract detail` | 交易 read corridor 页面 | read-only baseline | 保留 |
| `contract confirm handoff` | 合同确认入口 | P0 write corridor | 批准 |
| `milestone list` | 交易 read corridor 页面 | read-only baseline | 保留 |
| `milestone submit handoff` | 里程碑提交入口 | P0 write corridor | 批准 |
| `inspection detail` | 交易 read corridor 页面 | read-only baseline | 保留 |
| `inspection submit handoff` | 验收提交入口 | P0 write corridor | 批准 |

## 3. UI Guard vs Final Truth Split

### 3.1 只能是 UI guard 的对象

以下对象在 Flutter 里只能是 UI guard 或 handoff guard：

1. `workbench.canCreateProject`
2. `viewerProjectRelation`
3. `summary.stateLabel`
4. 页面按钮可见性
5. 本地 continuation anchor

### 3.2 必须以 Server/BFF 最终结果为准的对象

以下对象必须以 `Server/BFF` 最终结果为准：

1. `project/create` 资格
2. `bid/submit` 是否成功
3. `order/create` 是否成功
4. `contract/confirm` 是否成功
5. `milestone/submit` 是否成功
6. `inspection/submit` 是否成功
7. 所有 unauthorized / forbidden / invalid-state / unavailable 错误

## 4. public detail / private carry / bid continuation 承接图

当前页面关系冻结为：

```text
project/list
  -> project/detail
     -> viewerProjectRelation = non_owner
        -> bid continuation
           -> order detail / order create handoff
              -> contract detail / contract confirm handoff
                 -> milestone list / milestone submit handoff
                    -> inspection detail / inspection submit handoff

project/detail
  -> viewerProjectRelation = owner
     -> my/projects/{id}
     -> exhibition/workbench
```

写死两条规则：

- 公域 `project/detail` 不能膨胀成私域控制台。
- 私域 `my/projects / workbench` 不能冒充交易实例真源。

## 5. 当前禁止的页面误导

Flutter 当前不得把以下页面误导成交易主链能力：

1. `profile/payment-and-billing-status/*`
2. `profile/credit-and-constraints/*`
3. `profile/membership/*`

这些页面当前只能表达：

- bounded status
- bounded posture
- bounded explanation
- bounded handoff

不能表达：

- 当前项目已可支付
- 当前项目已具备押金/保证金执行
- 当前项目已具备交易保障执行
- 当前项目已具备会员资格放行

## 6. 不得创建第二套资格或状态机

Flutter 当前明确不得创建：

1. 第二套 publish eligibility
2. 第二套 bid eligibility
3. 第二套 trade-state machine
4. 第二套 archive-ready / completion-ready 判定
5. 第二套 visibility / review 状态机

## 7. 文案禁止误导清单

以下文案当前必须禁止：

1. “已完成真实交易闭环”
2. “已支持支付”
3. “已完成押金/保证金”
4. “已开启交易保障”
5. “会员通过即可创建项目”
6. “workbench 状态即交易真值”
7. “historicalProjects 只是归档，不代表正式完结”
8. “project detail 即 owner 管理后台”
9. “summary.stateLabel 即状态真值”

## 8. P0 外交互禁止项

以下交互当前不得进入 `P0`：

1. `contract amend`
2. `inspection recheck`
3. `rating entry/submit`
4. `dispute open/withdraw`
5. payment execution 交互
6. billing execution 交互
7. deposit / guarantee execution 交互
8. visibility 管理交互
9. review-before-display 交互

## 9. Formal Conclusion

Flutter 在 `项目交易骨架 P0` 中的正式边界写死为：

- 允许承载：
  - `public detail -> bid continuation -> order/contract/milestone/inspection`
    的最小 handoff 与最小页面
- 继续保留：
  - `project/list / detail`
  - `my/projects`
  - `exhibition/workbench`
    的既有职责
- 明确禁止：
  - 把 `profile/*` bounded 页面误导成交易主链能力
  - 创建第二套资格或状态机
