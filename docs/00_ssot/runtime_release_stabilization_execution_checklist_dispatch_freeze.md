---
owner: Codex 总控
status: frozen
purpose: Freeze the reusable execution checklist and dispatch boundary for runtime and release stabilization so every later business package inherits the same parallel hard-gate input before runtime, smoke, release-prep, or closure language is used.
layer: L0 SSOT
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/runtime_release_stabilization_parallel_freeze.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/bff_runtime_repo_drift_closure_assessment_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《运行与发布稳定化 execution checklist / dispatch freeze》

## 1. 目标

- 本轮只冻结：
  - `运行与发布稳定化` 的 execution checklist
  - `运行与发布稳定化` 的 dispatch freeze
- 当前文书服务于：
  - 后续每个业务包的并行执行门禁
  - release-prep 前的最小运行真相核验纪律
- 当前文书不是：
  - implementation dispatch
  - infra 平台化完成
  - CI/CD 完成
  - release-ready 结论

## 2. 当前真相

- 当前已知存在且必须持续视为并行阻断项的问题包括：
  - `active / release / workspace` 可能不一致
  - `current symlink` 漂移
  - `BFF runtime / repo drift` 曾真实出现
  - `source / dist` 混装矛盾曾真实出现
  - provider 限流样本污染过 smoke / 联调
  - build baseline 不稳定曾直接阻断阶段推进
- 当前必须明确：
  - 这些不是偶发噪音
  - 这些是后续每个业务包都可能复发的并行阻塞项
- 当前 execution checklist 的正确角色是：
  - 作为所有后续业务包的并行硬门禁输入
  - 而不是一次性热修经验记录

## 3. 对象范围

- 当前 checklist / dispatch freeze 只承接：
  - `active / release / workspace` 一致性检查
  - `current symlink` 纪律
  - `release artifact` 纪律
  - `systemd startup truth`
  - `nginx canonical path truth`
  - `build baseline`
  - `smoke sample pool`
  - `regression sample pool`
  - `pre-release checklist`
  - `evidence archive`
- 当前明确不承接：
  - CI/CD 重写
  - 多环境矩阵平台化
  - observability 平台化
  - Docker / Kubernetes 重构

## 4. Execution Checklist Freeze

### 4.1 本地 repo 检查项

- 必查项：
  - 当前业务包对应 truth / contract / backend / BFF / frontend 文书已冻结
  - 当前 repo 工作区不存在把 `source` 与已生成 `dist` 混写成双真相的口径
  - 当前业务包对应 canonical path、health path、样本路径、证据路径已能从 docs 或 runtime 清楚定位
  - 当前 smoke / regression 样本编号、手机号、账号、组织、前置状态已登记
- 硬门禁判定：
  - 若 truth 链未冻结：
    - 直接 veto 实现阶段
  - 若样本未登记：
    - 直接 veto smoke / release-prep

### 4.2 cloud current / release 检查项

- 必查项：
  - `/srv/apps/*/current` 是否存在
  - `current` 是否指向单一 release
  - active process `cwd` 是否与 `current` 一致
  - active process 是否未从 workspace 目录运行
  - 当前 active release 是否与当前业务包目标 release 一致
- 硬门禁判定：
  - 任一项失败：
    - 直接 veto runtime verification
    - 直接 veto release-prep

### 4.3 `systemd` 检查项

- 必查项：
  - unit `is-active=active`
  - `WorkingDirectory` 指向 `/srv/apps/*/current`
  - `ExecStart` 指向唯一 release artifact
  - active PID 与 unit 定义一致
- 硬门禁判定：
  - `WorkingDirectory != current`
  - `ExecStart` 指向 workspace 或不透明目标
  - active PID 与 unit 不一致
  任一项成立即：
    - 直接 veto runtime acceptance

### 4.4 `nginx` 检查项

- 必查项：
  - 生效配置以云端 active conf 为准，不以 repo 样例代替
  - canonical external path 到 upstream 的 rewrite / proxy 规则可留证
  - 当前业务包需要的 health / app-facing 路径能在 active conf 中定位
- 硬门禁判定：
  - 仅有 repo 样例、没有 active conf 证据：
    - 直接 veto runtime proof
  - active conf 与对外路径不一致：
    - 直接 veto release-prep

### 4.5 health / live 检查项

- 必查项：
  - `BFF health/live`
  - `Server health/live`
  - 如业务包依赖 ready，则补查 `health/ready`
- 硬门禁判定：
  - `health/live` 不可用：
    - 直接 veto runtime verification
    - 直接 veto release-prep

### 4.6 build baseline 检查项

- 必查项：
  - 当前业务包所需 build 命令、依赖、产物路径已固定
  - 当前 build 结果可复现，不依赖临时热修目录
  - build 失败原因若来自漂移，不得跳过记录直接重跑冒充通过
- 硬门禁判定：
  - build baseline 未稳定：
    - 直接 veto release-prep
    - 可不阻断 docs freeze

### 4.7 smoke 样本检查项

- 必查项：
  - 本次 smoke 样本属于未污染样本或受控新样本
  - 样本使用前已确认未触发 provider 限流、冷却或未知异常残留
  - 样本与用例一一对应，不能混用历史污染样本
- 硬门禁判定：
  - 主联调样本已污染仍复用：
    - 直接 veto smoke signoff
    - 直接 veto release-prep

### 4.8 evidence archive 检查项

- 必查项：
  - build 证据
  - health 证据
  - path / nginx / systemd 证据
  - smoke 证据
  - 样本池证据
  - closure / review 结论证据
- 硬门禁判定：
  - 关键证据缺失：
    - 直接 veto 下一阶段控制结论

## 5. Dispatch Freeze

### 5.1 每个业务包的硬门禁

以下项固定为每个业务包的并行硬门禁：

- `current -> release -> active cwd` 一致
- `systemd` 启动真相一致
- `nginx` 生效路径真相可留证
- `BFF / Server health live` 可用
- build baseline 稳定
- smoke 样本未污染
- evidence archive 完整

### 5.2 并行建议增强项

以下项属于建议增强，不单独阻断 docs freeze：

- 更细粒度的 regression 样本分层
- 更结构化的 evidence 归档目录命名
- 更自动化的 pre-release 清单生成

### 5.3 直接 veto 条件

以下失败直接构成 veto：

- active PID `cwd` 与 `current` 不一致
- 从 workspace 目录直接运行 cloud 进程
- `source / dist` 双真相无法判定 active artifact
- `nginx` 生效路径无证据或与 health/app-facing 路由不一致
- `health/live` 不可用
- 主 smoke 样本已污染仍复用
- 必需证据缺失

### 5.4 只阻断 release-prep、不阻断 docs freeze 的条件

- build baseline 还未稳定
- regression 样本池还未完全补齐
- evidence archive 结构仍需整理但本轮 freeze 文书已成立

## 6. Sample Pool Discipline

### 6.1 未污染样本定义

- `未污染样本` 固定指：
  - 未触发 provider 限流
  - 未处于 cooldown / retry lock
  - 未被历史失败流程残留污染
  - 当前前置状态与目标用例一致
  - 有明确样本标识与最近一次使用记录

### 6.2 受污染样本定义

- `不可继续使用的受污染样本` 固定指：
  - 已命中 provider rate limit
  - 已命中短信 / OTP / 第三方 provider cooldown
  - 前置状态未知或已被并发流程污染
  - 上一次失败原因无法归档解释

### 6.3 provider 限流样本封存纪律

- provider 限流样本必须：
  - 立即标记为污染
  - 退出当前主 smoke / 联调样本池
  - 单独登记污染原因、时间、 provider 现象
  - 不得继续作为主联调样本使用

### 6.4 新 smoke 选样纪律

- 新 smoke 必须优先：
  - 使用受控新样本
  - 或使用经重新核验的未污染样本
- 不允许：
  - 继续复用已污染样本
  - 口头判断“应该还能用”

### 6.5 边界

- 样本池纪律不是业务 contract
- 样本池纪律是并行运行门禁

## 7. Release Discipline

- cloud host 只允许从 `release` 目录运行
- `/srv/apps/*/current` 必须指向唯一 release
- active PID `cwd` 必须与 `current` 一致
- `source / dist` 不得形成双真相
- release 切换后必须留存：
  - `systemd` 证据
  - `health` 证据
  - `path / nginx` 证据
- 不得再依赖热修经验口头传递

## 8. Evidence Archive Discipline

### 8.1 每次 release-prep / smoke / closure 至少归档的证据

- build 输出与结果
- active release / current / cwd 对照
- `systemd` 状态与 `ExecStart / WorkingDirectory`
- `nginx` 生效路径证据
- `health/live` 与必要时 `health/ready`
- smoke 执行记录
- 样本池使用与污染记录
- closure / review 结论文书

### 8.2 总控必须收回的证据

- 当前 active release 证据
- 当前 active runtime 证据
- 当前 `systemd` / `nginx` 真相证据
- 当前 smoke 样本有效性证据
- 当前 health 证据
- 当前 build 结果证据

### 8.3 直接阻断下一阶段的缺失证据

- active release / current / cwd 三者对照缺失
- `systemd` 证据缺失
- `nginx` 生效路径证据缺失
- `health/live` 证据缺失
- smoke 样本有效性证据缺失
- build 结果证据缺失

## 9. Veto Gates

- 不得从 workspace 目录直接运行 cloud active 进程
- 不得让 `current` 指向不透明或多重 release
- 不得接受 `source / dist` 双真相继续未澄清
- 不得复用 provider 限流污染样本做主联调样本
- 不得以缺失证据推进 release-prep 或 closure

## 10. No-Go 边界

- 不得把本轮写成 infra 平台化完成
- 不得把本轮写成 CI/CD 完成
- 不得把本轮写成业务功能完成
- 不得把样本池纪律写成业务 contract
- 不得把 release discipline 写成一次性热修经验
- 不得把当前 checklist / dispatch freeze 误写成 release-ready 结论

## 11. 下一步唯一动作

- 下一步唯一动作：
  - `把该 checklist 作为后续每个新业务阶段 prompt bundle 的并行硬门禁输入`

## 12. 裁决

- `《运行与发布稳定化 execution checklist / dispatch freeze》是否可入库：是`
