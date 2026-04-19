---
owner: Codex 总控
status: frozen
purpose: Freeze the parallel runtime and release stabilization closure so subsequent business packages can inherit controlled release discipline, build-baseline discipline, and sample-pool discipline without overstating the scope into infra replatforming or CI/CD completion.
layer: L0 SSOT
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/bff_runtime_repo_drift_closure_assessment_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《运行与发布稳定化并行收口冻结文书》

## 1. 目标

- 本轮只冻结：
  - `运行与发布稳定化` 的并行收口范围
- 当前对象是：
  - 后续业务包并行挂载的工程主线
  - 不是独立业务对象
- 当前目标是减少后续业务包被以下问题反复拖慢：
  - build 漂移
  - 热修漂移
  - `current / release / workspace` 不一致
  - 样本污染

## 2. 当前真相

- 当前已知存在的运行 / 发布问题至少包括：
  - `active / release / workspace` 可能不一致
  - `current` symlink 漂移
  - `BFF runtime/repo drift` 曾真实出现
  - `source / dist` 混装矛盾曾真实出现
  - 样本手机号被 provider 限流污染
  - 构建基线不稳定曾阻断阶段推进
- 当前这些问题不是单个包的偶发噪音，而是：
  - 后续主线反复遇到的并行阻塞项
- 当前必须明确：
  - 本轮不是 infra 平台化启动
  - 本轮不是 CI/CD 重写
  - 本轮是最小发布纪律与运行纪律的 formal freeze

## 3. 本轮范围

本轮只允许冻结以下并行收口对象：

1. `active / release / workspace` 一致性
2. build baseline 收敛
3. `release` 目录 / `current` symlink / `systemd` / `nginx` 的受控发布纪律
4. smoke / 回归样本池纪律
5. 发布前检查与证据归档纪律

## 4. 本轮不做什么

- Docker / Kubernetes 重平台化
- 多机部署 / 多环境矩阵重构
- 完整 CI/CD 平台重写
- 监控告警平台化
- 完整 observability 平台
- 支付级高可用 / 财务级稳定性工程
- 不相关业务功能扩包

## 5. 当前缺口

- `active / release / workspace`：
  - 当前仍缺 formal single-truth discipline
- build baseline：
  - 当前仍缺跨包可复用的稳定 build baseline 门禁
- `current / symlink / systemd / nginx`：
  - 当前仍缺明确“只允许从 release 运行”的持续门禁
- sample pool：
  - 当前仍缺“受控新样本 / 未污染样本”的统一纪律
- evidence archive：
  - 当前仍缺“每次 release-prep 前 build / smoke / evidence 必须落档”的强制纪律

## 6. 最小对象矩阵

| 对象 | 当前真相 | 本轮收口到哪层 | 明确不做到哪层 |
|---|---|---|---|
| `current symlink discipline` | 曾出现 current 与 active cwd 不可直接乐观推定一致 | 冻结单一 `current -> release` 纪律与验真方法 | 不做到多环境切流平台 |
| `release artifact discipline` | 曾出现 active release source 与 active dist 不一致 | 冻结 release 目录内单一可运行 artifact truth 纪律 | 不做到完整 artifact platform |
| `systemd startup truth` | systemd/ExecStart/WorkingDirectory 需要被视作运行真相的一部分 | 冻结 working directory / exec target 的核验纪律 | 不做到完整 systemd 平台治理 |
| `nginx canonical path truth` | 样例配置与云端生效配置可能不一致 | 冻结“生效 nginx 为准 + 需留证”的纪律 | 不做到 nginx 平台化重构 |
| `build baseline` | 构建不稳定曾阻断推进 | 冻结最小 build baseline 与通过前置 | 不做到 monorepo build 平台重写 |
| `smoke sample pool` | provider 限流样本已污染过验证链 | 冻结 smoke 样本池纪律 | 不做到完整测试数据平台 |
| `regression sample pool` | 回归样本存在复用污染风险 | 冻结 regression 样本池纪律 | 不做到全量数据工厂 |
| `pre-release checklist` | 当前存在只读盘点与补证文书，但缺统一硬门禁口径 | 冻结发布前检查项最小集合 | 不做到完整 release platform |
| `evidence archive` | 证据链散落于单次文书与阶段回执 | 冻结 build/smoke/release evidence 归档纪律 | 不做到 observability / audit platform |

## 7. 阶段顺序裁决

### 7.1 并行顺序

- `Package S1`：
  - `active / release / workspace` 一致性
  - `current symlink discipline`
  - `systemd startup truth`
  - `nginx canonical path truth`
- `Package S2`：
  - `build baseline`
  - `release artifact discipline`
- `Package S3`：
  - `smoke sample pool`
  - `regression sample pool`
- `Package S4`：
  - `pre-release checklist`
  - `evidence archive`

### 7.2 顺序理由

- `Package S1` 必须最先收口：
  - 运行真相不一致时，任何后续 smoke/build 证据都可能落在错误目标上
- `Package S2` 必须随后：
  - 没有稳定 build baseline，就无法判断当前 release artifact 是否可信
- `Package S3` 必须在 build baseline 之后：
  - 样本池纪律只有建立在稳定 build 与稳定 active target 之上才有意义
- `Package S4` 最后：
  - checklist 与 archive 是前面三个对象的制度化收口，不是它们的替代物

## 8. 最小硬门禁

以下门禁固定为下一阶段并行收口的硬门禁：

- cloud host 只允许从 `release` 目录运行，不得从 `workspace` 目录运行
- `/srv/apps/*/current` 必须指向单一 release
- active PID `cwd` 必须与 `current` 一致
- `source / dist` 不得再出现“同目录双真相”
- `BFF / Server health live` 必须可用
- 每次 smoke 必须使用受控新样本或未污染样本
- provider 限流样本不得重复当作主联调样本
- 发布前必须有：
  - build 记录
  - smoke 记录
  - evidence 记录

## 9. 合规与发布门禁

- 本轮只允许进入：
  - `execution checklist / dispatch freeze authoring`
- 本轮不允许进入：
  - infra 平台化完成
  - CI/CD 完成
  - 业务功能完成
  - release approval
- 本轮必须明确：
  - 样本池纪律不是业务 contract
  - release discipline 不是一次性热修经验
  - 它们是后续所有业务包共用的并行工程门禁

## 10. No-Go 边界

- 不得把本轮写成 infra 平台化完成
- 不得把本轮写成 CI/CD 完成
- 不得把本轮写成业务功能完成
- 不得把样本池纪律写成业务 contract
- 不得把 release discipline 写成一次性热修经验
- 不得把当前并行收口对象扩写到无关业务功能

## 11. 下一步唯一动作

- 下一步唯一动作：
  - `输出《运行与发布稳定化 execution checklist / dispatch freeze》`

## 12. 裁决

- `《运行与发布稳定化并行收口冻结文书》是否可入库：是`
