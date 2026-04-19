---
owner: Codex 总控
status: frozen
purpose: Freeze the frontend execution prompt for enterprise-display post-submit disposition, replacing the stale grey submit mental model after approved/published runtime truth already exists.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_runtime_rescan_and_stage_reroute_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
---

# 《enterprise display post-submit disposition 前端执行口令》

你现在是：

- enterprise display post-submit disposition frontend owner

你的唯一目标是：

- 修正企业展示工作台提交区在 `application 已 approved / listing 已 published` 后仍显示灰 submit 的错误任务感
- 让用户一眼看懂：当前不是“继续补资料再提交”，而是“申请已通过，进入下一步查看”

这一步只做：

- workbench 提交区的 post-submit 状态呈现
- workbench 底部 CTA 选择
- 与 application approved/published 后续动作相关的最小前端文案与跳转

这一步不做：

- 不改 apps/server/**
- 不改 apps/bff/**
- 不改 apps/admin/**
- 不改 workbench truth 写链
- 不改 create / submit / status transport
- 不改 public recommendation/list/detail 数据链
- 不改 release / deploy

允许修改范围：

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- 与此问题直接相关的最小测试文件

你必须完成：

1. 当 `latestApplication.applicationStatus` 已进入非草稿、非待提交的后置状态时：
   - 不再把主 CTA 渲染为灰色 `提交入驻申请`
2. 至少对 `approved` 状态做正确呈现：
   - 页面主状态应明确表达“申请已通过”或“当前已上架/已通过”
   - 主 CTA 应切换为：
     - `查看申请状态`
     - 如当前页面已有安全路径，也可增加 `查看公域详情`
3. 不得在 `approved` 状态下继续显示：
   - `当前暂不能提交`
   - `还差这些`
   - 会让用户误以为还要补资料的 blocker 列表
4. 如果当前仍存在历史旧 draft，也不得让用户在已 approved 的 runtime 下优先看到“继续提交”的错误入口。
5. 保持现有 app-facing 依赖不变：
   - 继续通过 `application-status` 页承接正式状态查看
   - 不得直打 `/server/*`

你必须遵守：

1. 不得伪造新的 application 状态机。
2. 不得放宽真实 submit 条件。
3. 不得把 `approved` 误写成 `published`，除非当前页面已有冻结真值能直接表达上架状态。
4. 不得顺手重写 workbench 其他区块。

完成标准：

- 当 application 已 `approved` 时，workbench 不再表现成“灰 submit 死路”
- 用户能直接进入正确的后续动作：
  - 查看申请状态
  - 或查看已开放的后续入口
- 页面不再用 blocker 列表误导用户继续补 submit 前资料

交付回执要求：

1. 修改文件清单
2. 为什么之前 `approved` runtime 仍显示成“当前暂不能提交”
3. 现在如何区分：
   - submit 前状态
   - post-submit 状态
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
