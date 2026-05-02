---
owner: Codex 总控
status: frozen
layer: L4 Flutter Frontend
freeze_date_local: 2026-05-03
purpose: Freeze the Flutter-only UI refinement boundary for folding the project communication workbench entries while preserving Server-owned material confirmation truth.
inputs_canonical:
  - AGENTS.md
  - apps/mobile/AGENTS.md
  - docs/04_frontend/project_communication_workbench_role_split_rework_day2_flutter_structure_addendum.md
  - docs/04_frontend/project_communication_workbench_ten_entry_review_day4_flutter_structure_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart
---

# 项目沟通页工作入口折叠精修前端施工冻结单

## 0. 总裁决

- 本轮是否允许修改 Flutter 展示层：`Go`。
- 本轮是否允许修改 BFF：`No-Go`。
- 本轮是否允许修改 Server：`No-Go`。
- 本轮是否允许修改 OpenAPI / generated contracts：`No-Go`。
- 本轮是否允许写数据库或动云端服务：`No-Go`。
- 本轮是否允许新增资料确认真值：`No-Go`。
- 本轮是否允许把灰色状态改成可确认或已确认：`No-Go`。

本轮目标不是让十个入口强行可用，而是把当前项目沟通页 `项目工作入口` 中的十项资料 / 成交确认入口改为默认折叠摘要，降低首屏高度，让 `项目沟通记录` 更早出现。

## 1. 当前真相

### 1.1 十项入口来源

当前项目沟通页 `项目工作入口` 内的十项入口来自 `ProjectCommunicationWorkbenchEntryView`：

| 分组 | 数量 | 入口 |
|---|---:|---|
| `发布方资料` | 5 | 效果图确认、尺寸图 / 施工图确认、材质图 / 材料样板确认、设备物料清单确认、服务清单确认 |
| `竞标资料` | 3 | 项目理解确认、报价表确认、进度安排确认 |
| `成交确认` | 2 | 合同确认、最终成交金额确认 |

Flutter 当前只读取 `entry.group`、`entry.entryKey`、`entry.reviewState`、`entry.availabilityState` 并渲染入口，不拥有业务真值。

### 1.2 灰色状态来源

当前灰色弱化不是前端随意禁用，而是由上游 read-model 状态驱动：

| 上游状态 | 当前展示 | 本轮含义 |
|---|---|---|
| `unsubmitted` | `未提交` | 对应资料或确认对象尚未提交 |
| `unavailable` | `暂不可读` | 当前资料 / 确认状态不可读 |
| `blocked` | `暂不可读` | 当前阶段或权限不允许读取 |
| unknown fallback | `暂不可读` | 受控不可读，不吞掉未知状态 |

以下状态不得在 Flutter 本地伪造：

| 上游状态 | 展示 | 禁止事项 |
|---|---|---|
| `pending_review` | `待确认` | 不得仅因用户希望可点而本地改成待确认 |
| `confirmed` | `已确认` | 不得本地改绿，不得持久化假确认 |
| `needs_supplement` | `需补充` | 不得本地造红色风险态 |

## 2. 本轮允许范围

只允许改 Flutter 展示层：

1. 把三组 workbench 改为默认折叠摘要。
2. 每组摘要展示：
   - 分组标题
   - 项数
   - 当前最高优先级状态
   - 轻量说明
   - 展开 / 收起图标
3. 展开后复用现有十项入口 tile。
4. 保留现有状态 badge 文案：
   - `未提交`
   - `待确认`
   - `已确认`
   - `需补充`
   - `暂不可读`
5. 允许轻量调整状态 badge 视觉，使 `暂不可读` 不像错误。
6. 允许减少 section 间距和 tile 默认占用高度。
7. 允许为灰色状态点击保留既有只读详情或受控提示。
8. 允许补定向 Flutter widget test。
9. 允许输出折叠态、展开态、窄屏态截图。

## 3. 本轮禁止范围

本轮不做：

1. 不新增 BFF route。
2. 不新增 Server route。
3. 不修改 OpenAPI。
4. 不修改 generated contracts。
5. 不修改数据库。
6. 不新增云端部署。
7. 不新增 WebSocket / 实时 IM。
8. 不新增附件上传能力。
9. 不修改消息发送接口。
10. 不新增资料确认业务真值。
11. 不新增本地假状态。
12. 不把 `unsubmitted / unavailable / blocked` 改成 `pending_review / confirmed`。
13. 不删除十项入口。
14. 不删除状态 badge。

## 4. 默认折叠规则

默认折叠粒度冻结为三组，不合并成单条总摘要：

1. `发布方资料`
2. `竞标资料`
3. `成交确认`

理由：

1. 当前业务真值已经按三组返回。
2. 三组摘要比十个 tile 占用高度低。
3. 三组摘要保留业务层级，不把成交确认混入普通资料。
4. 后续若 Server 真值扩展，可继续挂在原分组下。

默认状态：

| 场景 | 默认行为 |
|---|---|
| 全部 `未提交 / 暂不可读` | 默认折叠，只显示摘要 |
| 存在 `待确认` | 仍默认折叠，摘要提示 `有待确认资料` |
| 存在 `需补充` | 仍默认折叠，摘要提示 `需补充`，但不大面积红色警告 |
| 全部 `已确认` | 默认折叠，摘要提示 `已确认完成` |

## 5. 摘要状态优先级

同一组内摘要状态按以下优先级计算：

1. `needs_supplement` -> `需补充`
2. `pending_review` -> `有待确认资料`
3. `confirmed` 且该组全部 confirmed -> `已确认完成`
4. `unsubmitted` -> `未提交`
5. `unavailable / blocked / unknown` -> `暂不可读`

状态优先级只用于摘要展示，不改变每个入口的真实状态。

## 6. 聊天区域验收口径

本轮验收不以像素绝对值作为唯一标准，而以可观察体验为准：

1. 首屏中 `项目沟通记录` 必须比当前全展开版本更早出现。
2. 默认折叠态不得一次性铺满十个入口。
3. 展开任一组后，十项入口仍完整可达。
4. 底部输入栏不得遮挡最后一条消息。
5. 窄屏下文字不得横向溢出。

## 7. 文件边界

允许修改：

1. `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart`
2. 必要时少量修改 `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart`
3. 必要时新增或调整 `apps/mobile/test/project_communication_five_material_confirmation_entry_test.dart`
4. 本冻结单及后续前端验收回执
5. `docs/00_ssot/evidence/**` 截图证据

不允许修改：

1. `apps/bff/**`
2. `apps/server/**`
3. `docs/01_contracts/**`
4. `packages/contracts/**`
5. 数据库、云端进程、Nginx、systemd

## 8. 验收标准

实现完成后必须输出：

1. `changed_files` 清单。
2. 每个文件改动说明。
3. BFF / Server / OpenAPI / 数据库 / 消息接口 / 资料确认真值是否修改，答案必须为 `否`。
4. 资料 / 成交确认入口是否默认折叠。
5. 十项状态是否仍保留。
6. 项目沟通记录区域是否上移。
7. 底部输入栏是否遮挡消息。
8. `flutter analyze` 结果。
9. 相关 Flutter test 结果。
10. 折叠态截图路径。
11. 展开态截图路径。
12. 窄屏截图路径。

## 9. 四类判断

| 判断 | 结论 |
|---|---|
| 最稳 | 三组默认折叠摘要，展开复用原十项入口 |
| 最低成本 | 只在现有 workbench widget 内加折叠状态和摘要，不改模型、不改接口 |
| 最适合当前阶段 | 最低成本方案 + 灰色状态受控反馈 + 真实页面截图验收 |
| 风险最大 | 前端本地伪造 `待确认 / 已确认`，或为了点亮入口新增假业务状态 |

## 10. 下一阶段门禁

本冻结单通过后，允许进入 Flutter 最小 UI patch。

若实现中发现需要新增字段、修改接口、修改状态机、写云端数据或新增资料确认真值，必须停止并回到 contracts / BFF / Server 冻结阶段。
