---
owner: Codex 总控
status: active
purpose: Provide the single verification template for real-chain auditing across 项目发布工作台 / 项目发布 / 项目展示, separating real runtime evidence from demo fallback and development-stage-only closure.
layer: L0 SSOT
---

# 《三板块真实链路核查表 V1》

## 1. 适用范围

本核查表只适用于以下三块主线：

- `项目发布工作台`
- `项目发布`
- `项目展示`

本核查表只用于：

- 现有资产真实链路核查
- demo fallback 污染剥离
- development-stage 真实证据登记
- 联调发布前置条件判断

本核查表不用于：

- 新功能立项
- 扩主线
- 正式附件公开议题
- 独立 visibility / review state machine 议题
- production release signoff

## 2. 核查输出规则

- 每一段链路都必须标记为以下四类之一：
  - `真实命中`
  - `demo 承接`
  - `不稳定`
  - `未承接`
- 禁止把 `demo 承接` 记为“已打通”。
- 禁止把 `development-stage 已验证` 写成“已发布完成”。
- 禁止只收实现回执，不附独立复核结论。
- 如存在 demo fallback，必须同时写：
  - 触发条件
  - 当前真实链路状态
  - 是否阻断联调发布判断

## 3. 主链核查表

| 链路段 | 所属板块 | 预期行为 | 当前证据来源 | 当前判定 | 是否阻断联调发布 | 备注 |
|---|---|---|---|---|---|---|
| 首页发布入口 -> 工作台 | 项目发布工作台 | 从首页进入工作台或发布相关私域入口，不误导成公域展示页 | 待填写 | 待填写 | 待填写 | 待填写 |
| 工作台 -> 发布页 | 项目发布工作台 / 项目发布 | 工作台只做摘要与导流，可进入发布页 | 待填写 | 待填写 | 待填写 | 待填写 |
| 发布页加载 | 项目发布 | 发布页按既有冻结字段加载，不新增第二状态机 | 待填写 | 待填写 | 待填写 | 待填写 |
| 上传三步链 | 项目发布 | `init -> direct upload -> confirm` 正常承接 | 待填写 | 待填写 | 待填写 | 待填写 |
| create 提交 | 项目发布 | `POST /api/app/project/create -> 202 + projectId` | 待填写 | 待填写 | 待填写 | 待填写 |
| create 成功 -> 公域详情 | 项目发布 / 项目展示 | 使用返回 `projectId` 进入公域详情 | 待填写 | 待填写 | 待填写 | 待填写 |
| 公域项目列表 | 项目展示 | 列表读取已发布项目，不混入私域态 | 待填写 | 待填写 | 待填写 | 待填写 |
| 公域项目详情 | 项目展示 | 详情只读公开字段，owner 只做 handoff，不做私域真值 | 待填写 | 待填写 | 待填写 | 待填写 |
| 公域详情 -> 我的项目 | 项目展示 / 项目发布工作台 | owner 可回流到私域承接面 | 待填写 | 待填写 | 待填写 | 待填写 |
| 我的项目列表 | 项目发布工作台 | 展示当前组织项目分组，不替代工作台或展示页 | 待填写 | 待填写 | 待填写 | 待填写 |
| 我的项目详情 | 项目发布工作台 | 承接 owner 私域详情与 privateProgress | 待填写 | 待填写 | 待填写 | 待填写 |

## 4. demo fallback 剥离表

| 页面/接口 | 是否存在 demo fallback | 触发条件 | 当前真实链路状态 | 是否会误导为已打通 | 是否必须先清除 |
|---|---|---|---|---|---|
| `/exhibition/workbench` | 待填写 | 待填写 | 待填写 | 待填写 | 待填写 |
| `/exhibition/projects` | 待填写 | 待填写 | 待填写 | 待填写 | 待填写 |
| `/exhibition/projects/detail` | 待填写 | 待填写 | 待填写 | 待填写 | 待填写 |
| `/exhibition/my/projects` | 待填写 | 待填写 | 待填写 | 待填写 | 待填写 |
| `/exhibition/my/projects/detail` | 待填写 | 待填写 | 待填写 | 待填写 | 待填写 |

## 5. 真值边界核查表

| 对象 | 当前 owner | 允许语义 | 禁止语义 | 当前是否漂移 | 处理结论 |
|---|---|---|---|---|---|
| `project.state` | `Server project` | 公域生命周期 | visibility / review / 私域推进 | 待填写 | 待填写 |
| `publishedAt` | `Server project` | 公域准入 | 生命周期全语义 | 待填写 | 待填写 |
| `viewerProjectRelation` | `project/detail` 读投影 | owner/non-owner handoff | 权限真值 | 待填写 | 待填写 |
| `privateProgress` | `my/projects/{id}` 读投影 | 私域推进与完结投影 | 公域展示判断 | 待填写 | 待填写 |
| `workbench summary` | `exhibition/workbench` 摘要投影 | 私域摘要与 route handoff | 第二状态机 / 第二后台 | 待填写 | 待填写 |

## 6. 板块结论表

### 6.1 项目发布工作台

- 当前状态：
  - `待填写`
- 结论类型：
  - `真实闭环 / 仅页面闭环 / 仅文档闭环 / 伪闭环`
- 当前是否允许进入联调发布判断：
  - `待填写`
- 当前阻断项：
  - `待填写`

### 6.2 项目发布

- 当前状态：
  - `待填写`
- 结论类型：
  - `真实闭环 / 仅页面闭环 / 仅文档闭环 / 伪闭环`
- 当前是否允许进入联调发布判断：
  - `待填写`
- 当前阻断项：
  - `待填写`

### 6.3 项目展示

- 当前状态：
  - `待填写`
- 结论类型：
  - `真实闭环 / 仅页面闭环 / 仅文档闭环 / 伪闭环`
- 当前是否允许进入联调发布判断：
  - `待填写`
- 当前阻断项：
  - `待填写`

## 7. 总控裁决区

### 7.1 passed gates

- `待填写`

### 7.2 failed gates

- `待填写`

### 7.3 veto gates

- `待填写`

### 7.4 stage decision

- `Go / No-Go for 真实链路联调`
- `Go / No-Go for 联调发布前置准备`
- `Go / No-Go for production release`

## 8. 强制结论格式

最终结论必须严格包含以下 4 句：

1. `哪些链路是真实命中`
2. `哪些链路只是 demo 承接`
3. `当前是否仅为 development-stage 结论`
4. `当前是否允许进入联调发布`

## 9. 使用要求

- 前端、后端、BFF、结果校验的回执都必须复用本模板。
- 总控只接受带有“当前判定”和“是否阻断联调发布”两列已填结果的回执。
- 如某角色无法提供真实运行证据，必须明确写：
  - `无真实证据，仅代码/文档判断`
- 任一核心链路段被判定为 `demo 承接` 且会误导为已打通时，本轮默认：
  - `No-Go for 联调发布`
