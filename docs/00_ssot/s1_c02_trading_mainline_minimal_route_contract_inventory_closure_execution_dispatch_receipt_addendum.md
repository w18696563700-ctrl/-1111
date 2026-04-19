---
owner: 总控文书冻结
status: frozen
purpose: Freeze the stage-1 minimal route, contract, and inventory closure receipt for the trading mainline families, removing ghost routes from the first-release runnable inventory without opening implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/credit_constraints/credit-constraints.catalog.ts
  - apps/bff/src/routes
  - apps/server/src/modules
---

# 《S1-C02 trading mainline minimal route / contract / inventory closure execution dispatch receipt》

## 1. 当前对象

- 本轮当前对象固定为：
  - `bid`
  - `order`
  - `contract`
  - `milestone`
  - `inspection`
  - `rating`
  - `dispute`

## 2. inventory matrix

| family | app-facing contract 是否已冻结 | mobile consumer / routeTarget 是否存在 | BFF upstream 是否存在 | Server truth carrier 是否存在 | 当前状态 |
|---|---|---|---|---|---|
| `bid` | 是。`/api/app/bid/submit` 已冻结在 `openapi.yaml`。 | 是。`exhibition_canonical_paths.dart` 已注册 `bidSubmit`，mobile tests 也有 stub。 | 否。`apps/bff/src/routes/**` 未见 `api/app/bid/submit` carrier。 | 否。`apps/server/src/modules/**` 未见 bid submit controller family；仅有 `restrict_bid` 治理姿态与 `bidding_closed` 状态文案。 | `missing carrier` |
| `order` | 是。`/api/app/order/detail`、`/api/app/order/create` 已冻结。 | 是。mobile 已注册 canonical path，`order/detail` 还被 message routeTarget 复用为 continuation anchor。 | 否。`apps/bff/src/routes/**` 未见 `api/app/order/detail` 或 `api/app/order/create` carrier。 | 是，但仅为 partial truth carrier。`my-project.query.service.ts` 可回读 `orders` 表与 current order progress，`workbench.presenter.ts` 仅给出 summary container。 | `current closed` |
| `contract` | 是。`/api/app/contract/detail`、`/confirm`、`/amend` 已冻结。 | 是。mobile canonical path 已注册，messages registry 已冻结 `contract.confirm` / `contract.amend` routeTarget。 | 否。`apps/bff/src/routes/**` 未见 contract app-facing carrier。 | 是，但仅为 partial truth carrier。`my-project.query.service.ts` 可回读 `contracts` 表，`workbench.presenter.ts` 只保留 `canOpenContractDetail` 边界位。 | `current closed` |
| `milestone` | 是。`/api/app/milestone/submit` 已冻结；`milestone/list` 也已存在 frozen contract。 | 是。mobile canonical path 已注册，current exhibition flow 已把 milestone continuation 当作 local continuation context。 | 否。`apps/bff/src/routes/**` 未见 milestone app-facing carrier。 | 是，但仅为 partial truth carrier。`my-project.query.service.ts` 可回读 `milestones` 表，`workbench.presenter.ts` 只保留 milestone summary container。 | `current closed` |
| `inspection` | 是。`/api/app/inspection/detail`、`/submit`、`/recheck` 已冻结。 | 是。mobile canonical path 已注册，messages registry 已冻结 `inspection.submit` routeTarget。 | 否。`apps/bff/src/routes/**` 未见 inspection app-facing carrier。 | 否。`apps/server/src/modules/**` 未见 inspection controller / query / write family；仅有 `workbench.presenter.ts` 中的 `inspectionState: null` 与受控边界位。 | `missing carrier` |
| `rating` | 是。`/api/app/rating/entry`、`/submit` 已冻结。 | 是。mobile canonical path 已注册，messages registry 已冻结 `rating.submit` routeTarget。 | 否。`apps/bff/src/routes/**` 未见 rating app-facing carrier。 | 是，但仅为 partial truth carrier。`my-project.query.service.ts` 可回读 `ratings` 表，`workbench.presenter.ts` 明确 `ratingEntryState = controlled_unavailable`。 | `current closed` |
| `dispute` | 是。`/api/app/dispute/open`、`/withdraw` 已冻结。 | 是。mobile canonical path 已注册，messages registry 已冻结 `dispute.open` / `dispute.withdraw` routeTarget。 | 否。`apps/bff/src/routes/**` 未见 dispute app-facing carrier。 | 是，但仅为 partial truth carrier。`my-project.query.service.ts` 可回读 `disputes` 表，`workbench.presenter.ts` 明确 `disputeWithdrawState = frozen`。 | `current closed` |

## 3. ghost route judgment

- 当前必须被判定为 ghost route 的 path 固定如下：
  - `/api/app/bid/submit`
  - `/api/app/order/detail`
  - `/api/app/order/create`
  - `/api/app/contract/detail`
  - `/api/app/contract/confirm`
  - `/api/app/contract/amend`
  - `/api/app/milestone/submit`
  - `/api/app/inspection/detail`
  - `/api/app/inspection/submit`
  - `/api/app/inspection/recheck`
  - `/api/app/rating/entry`
  - `/api/app/rating/submit`
  - `/api/app/dispute/open`
  - `/api/app/dispute/withdraw`
- 当前之所以判定为 ghost，原因固定如下：
  - app-facing contract 虽已冻结，mobile 侧也已有 canonical path、routeTarget 或 test stub
  - 但 `apps/bff/src/routes/**` 中未见对应 app-facing runtime carrier
  - `apps/server/src/modules/**` 中也未形成同等完整的 canonical controller family
  - 因此这些 path 当前只能被视为 frozen contract / placeholder / continuation anchor，不能再留在“首发可运行口径”里
- 当前必须写死：
  - placeholder、test stub、workbench summary carrier、dependency posture，都不能被解释为真实 upstream

## 4. controlled-closed judgment

- 当前必须明确保留为 `controlled_unavailable / frozen / dependency` 的 family 与 path 固定如下：
  - `order`
    - `/api/app/order/detail` 只允许保留为 controlled continuation carrier
    - `/api/app/order/create` 只允许保留为 frozen command request/response skeleton
  - `contract`
    - `/api/app/contract/detail`、`/confirm`、`/amend` 只允许保留为 workflow skeleton
    - 不得宣称 contract detail / confirm / amend runtime 已成立
  - `milestone`
    - `/api/app/milestone/submit` 只允许保留为 frozen submit skeleton
    - milestone truth 不得被宣称为已形成 runnable workflow
  - `inspection`
    - `/api/app/inspection/detail`、`/submit` 只允许保留为 controlled skeleton
    - `/api/app/inspection/recheck` 明确属于 frozen extension-round placeholder
  - `rating`
    - `/api/app/rating/entry` 只允许保留为 `controlled_unavailable`
    - `/api/app/rating/submit` 只允许保留为 extension-round skeleton
  - `dispute`
    - `/api/app/dispute/open` 只允许保留为 entry-state skeleton
    - `/api/app/dispute/withdraw` 明确保留为 `frozen`
  - `bid`
    - `/api/app/bid/submit` 只允许保留为 frozen submit contract
    - 不得宣称当前已有 bid runtime carrier
- 当前可以保留 skeleton，但不能宣称 runtime 已成立的载体固定如下：
  - `openapi.yaml` 中已冻结的 request / response skeleton
  - mobile canonical path 常量
  - mobile routeTarget registry
  - workbench summary boundary carrier
  - `credit_constraints.catalog.ts` 中的 `dependency` / `handoff` posture 引用

## 5. minimal closure verdict

- 本轮 minimal closure verdict 固定为：
  - `MINIMAL CLOSURE PASS WITH RISK`
- 当前之所以不是 `FAIL`，原因固定如下：
  - `bid / order / contract / milestone / inspection / rating / dispute` 的 active runtime truth 已被分层为 `current closed` 或 `missing carrier`
  - ghost route 已被显式从首发可运行口径剔除
  - 当前不存在把 placeholder、test stub、workbench summary 或 dependency posture 继续冒充真实 upstream 的口径
- 当前之所以不是无风险 `PASS`，原因固定如下：
  - `openapi`、mobile canonical path、routeTarget 与 tests 中仍保留大量 frozen placeholder 面
  - 这些冻结面若脱离当前 receipt 单独阅读，仍存在被误读为 runnable transport 的语义污染风险

## 6. next-step recommendation

- 当前 next-step recommendation 固定为：
  - `Go for S1-C02 result verification`

## 7. Formal Conclusion

- `S1-C02 trading mainline minimal route / contract / inventory closure execution dispatch receipt` 已冻结。
- 当前正式口径已写死为：
  - `bid`、`inspection` = `missing carrier`
  - `order`、`contract`、`milestone`、`rating`、`dispute` = `current closed`
  - 当前无任何 family 可写成 `current runnable`
  - 所有已列 app-facing canonical path 当前都不得再进入“首发可运行口径”
  - 当前只允许把这些 path 保留为 frozen skeleton、controlled boundary、dependency posture 或 fail-closed placeholder
  - 当前下一步仅释放到 `Go for S1-C02 result verification`
