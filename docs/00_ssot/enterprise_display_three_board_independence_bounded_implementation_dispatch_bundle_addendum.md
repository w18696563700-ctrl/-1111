---
owner: Codex 总控
status: active
purpose: Freeze the bounded implementation dispatch bundle for enterprise-display three-board independence so the current round executes only the backend truth repair package before any BFF, Flutter, data-repair, or release follow-up is allowed.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_three_board_independence_backend_truth_scope_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
---

# 《enterprise display three-board independence bounded implementation dispatch bundle》

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 先把 `Server truth` 的 media ownership 缺口闭合
  - 让企业展示的 basic media / factory showcase / case media / current-change media 都回到同一条 backend truth 链
  - 在不触碰 data repair 的前提下，让后续 BFF / Flutter 有稳定真值可接

## B. 当前轮明确非目标

- 不做历史脏数据修复
- 不做 `apps/bff/**` implementation
- 不做 `apps/mobile/**` implementation
- 不做 upload 协议重写
- 不做第二条 published-change corridor
- 不做 deploy / restart / rollback / release

## C. 当前轮项目拓扑冻结

- 总控只允许写：
  - `docs/**`
- backend implementation 只允许写：
  - `apps/server/**`
- 本轮不允许写：
  - `apps/bff/**`
  - `apps/mobile/**`
  - 线上数据修复脚本
- tunnel 仍只用于只读验证：
  - `http://127.0.0.1:8080`

## D. 当前轮 package split

### D1. Package 0 | 总控门禁与派工包

- owner：
  - `Codex 总控`
- allowed directories：
  - `docs/00_ssot/**`
- deliverables：
  - implementation dispatch stage gate checklist
  - bounded implementation dispatch bundle
  - backend execution prompt
  - backend execution receipt
- must not do：
  - 越过门禁直接改 `apps/server/**`

### D2. Package 1 | Backend truth repair 包

- owner：
  - `后端 Agent / Codex backend worker`
- allowed directories：
  - `apps/server/src/modules/enterprise_hub/**`
  - 与当前对象直接相关的最小 `apps/server/test/**`
- unique goal：
  - 为 enterprise display 补齐 write-time media ownership validation
  - 让 `enterprise_media_asset_ref` 进入正式职责
  - 对 read-side media projection 做 fail-close
- must do：
  - 校验 `businessType / businessId / organizationId / fileKind / image mime`
  - 校验 case media 与当前 `enterpriseId + boardType` 一致
  - 在 direct case 与 published-change corridor 两条链都闭合
  - 同步 live carrier 的 media ref truth
- must not do：
  - 改 `apps/bff/**`
  - 改 `apps/mobile/**`
  - 改线上数据
  - 发明第二套 truth owner

### D3. Package 2 | Backend result verification 包

- owner：
  - `Codex 总控 / 结果校验`
- unique goal：
  - 验证 backend package 是否真的闭合当前 truth gap
- must check：
  - invalid media binding 被拒绝
  - `profile/business_license` 不再被 case/public read 当成合法 enterprise display 图片
  - published-change live apply 不再吞进非法 media
  - `enterprise_media_asset_ref` 有真实同步落点
- must not do：
  - 代替 data repair
  - 把 backend 通过误写成跨层联调通过

## E. 当前轮执行顺序

1. 总控完成 implementation gate 与 dispatch bundle。
2. backend package 在允许目录内完成 source + test 修复。
3. backend package 提交 execution receipt。
4. 总控做本地 build / test / diff 验收。
5. 只有 backend receipt 验收通过后，才允许讨论下一轮 `BFF / Flutter / data repair`。

## F. 当前轮 backend 修复骨架

- 当前修复骨架固定为：
  - 新增 enterprise display media ownership service
  - direct basic / factory / case write 校验
  - current-change basic / case save 校验
  - live apply 二次校验
  - `enterprise_media_asset_ref` sync
  - media projection fail-close
- 当前不要求：
  - case media fileKind 三板块拆分立即上线
  - upload transport family 改名

## G. 当前轮验收通过标准

- 非 `enterprise_display` 图片不能再被保存为企业展示案例图
- 错 listing、错组织、错 fileKind 的 image `FileAsset` 不能再被保存为合法展示媒体
- current-change corridor 与 live apply 都不能绕过校验
- read-side 对非合法 enterprise display 图片必须 fail-close
- 至少有一组 direct case 测试、一组 published-change 测试、一组 read/projection 测试通过

## H. 当前轮 Formal Conclusion

- 当前轮唯一合法推进路径固定为：
  - `implementation gate -> backend package -> backend receipt -> 验收`
- 在 backend receipt 通过前：
  - `BFF / Flutter / data repair / release` 一律继续 `No-Go`
