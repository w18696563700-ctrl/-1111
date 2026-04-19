---
owner: Codex 总控
status: frozen
purpose: >
  冻结 BidAward bridge 后端实施阶段的包级验收基线，明确当前阶段不以
  apps/server 全仓 npm run build 全绿作为唯一准入条件，而改以本包写集、
  本包目标路径、本包目标测试与本包烟雾验证为验收基线；非目标历史红项
  在本阶段不作为 veto blocker。
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/bid_award_bridge_root_guardrail_scoped_implementation_exception_addendum.md
  - docs/00_ssot/bid_award_bridge_backend_implementation_dispatch_addendum.md
  - docs/02_backend/bid_award_bridge_backend_truth_persistence_freeze_addendum.md
---

# 《BidAward bridge backend package-scoped validation baseline ruling》

## 1. 当前裁决对象

- 当前裁决只对以下阶段生效：
  - `BidAward bridge / backend-first bounded implementation`
- 当前裁决只对以下对象写集生效：
  - `BidAward truth`
  - `loser disposition truth`
  - `POST /api/app/bid/award`
  - `GET /api/app/bid/result?projectId={projectId}`
  - `BidAward -> Order conversion`
  - `synchronous contract seed`
  - `Project.state = awarded / converted_to_order`
  - `my_project / exhibition_workbench` 最小 fallout refresh

## 2. 当前不再采用的唯一准入条件

- 当前阶段不再把以下条件作为唯一准入条件：
  - `apps/server && npm run build` 全仓全绿
- 原因已经固定：
  - 云端后端工作区存在与本包无关的历史红项
  - 这些历史红项当前会阻断全仓 build
  - 但它们不属于本包写集，也不属于本包目标路径

## 3. 当前正式采用的包级验收基线

### 3.1 P0 必过主链

- `BidAward + loser disposition persistence`
- `POST /server/bid/award`
- `GET /server/bid/result?projectId={projectId}`
- `BidAward -> Order -> Contract seed -> Project.state`
  同事务闭合
- 重复定标 `fail-close`
- 并发定标单胜
- 部分失败整体回滚

### 3.2 P1 非回退烟雾

- `project publish / showcase` 不回退
- `bid submit` 不回退
- `my_project` fallout refresh 不回退
- `exhibition_workbench` fallout refresh 不回退

### 3.3 目标路径与类型基线

- 目标路径必须存在且可解析：
  - `POST /server/bid/award`
  - `GET /server/bid/result?projectId={projectId}`
- 目标写集文件必须通过包级类型检查与最小可执行验证
- 若全仓历史红项仍在，但未污染本包目标路径与目标测试，
  则当前不作为本包 veto blocker

## 4. 当前明确不作为 veto blocker 的历史红项

- 以下历史红项当前不作为本包 veto blocker：
  - 论坛历史字段漂移
  - OCR 依赖缺失
  - 老的 `order.service.ts`
    / `project.service.ts`
    与当前实体字段不一致
  - 其他未触达、未进入本包写集的历史编译红项

## 5. 当前仍然作为 veto blocker 的事项

- 以下事项仍然是本包 veto blocker：
  - 本包目标路径不存在
  - 本包目标写集自身类型错误
  - 本包 P0 主链测试不过
  - 本包事务原子性规则失效
  - 本包并发 / 幂等规则失效
  - 本包写集污染禁区对象

## 6. 当前阶段完成标志

- 只有当以下条件同时成立，当前阶段才算完成：
  - `BidAward` 真相落位
  - `loser disposition` 同步落位
  - `POST /server/bid/award` 可跑通
  - `GET /server/bid/result?projectId={projectId}` 可读
  - `BidAward -> Order -> Contract seed -> Project.state`
    同事务成立
  - 重复定标 `fail-close`
  - 并发定标单胜
  - 部分失败整体回滚
  - `P0` 主链测试通过
  - `P1` 非回退烟雾通过

## 7. Formal Conclusion

- 当前正式采用：
  - `BidAward bridge backend package-scoped validation baseline`
- 当前后端实施阶段不以全仓 build 全绿为唯一准入条件
- 当前改以本包写集、本包目标路径、本包目标测试、本包烟雾为验收基线
- 非目标历史红项暂不作为本包 veto blocker
- `Go for backend continuation`

## 8. Next Unique Action

- 下一步唯一动作：
  - 继续云端 `BidAward bridge / backend-first bounded implementation`
