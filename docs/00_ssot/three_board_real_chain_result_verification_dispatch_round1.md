---
owner: Codex 总控
status: active
purpose: Dispatch the independent verification round for 项目发布工作台 / 项目发布 / 项目展示 after the frontend language and demo-isolation patch, without treating implementation receipt as release evidence.
layer: L0 SSOT
---

# 《三板块真实链路独立复核派工单 Round 1》

## 1. 派工目标

本轮派工只交给 `结果校验 Agent`。

目标只有一个：

- 对 `项目发布工作台 / 项目发布 / 项目展示` 三块主线做一次
  - `不信施工回执`
  - `只认真实证据`
  的独立复核

本轮明确不做：

- 新开发
- 新修复
- 新功能扩面
- 生产发布

## 2. 本轮输入依据

结果校验 Agent 必须先阅读：

- `docs/00_ssot/three_board_real_chain_verification_checklist_v1.md`
- `docs/00_ssot/three_board_real_chain_verification_checklist_v1_draft_round0.md`
- `docs/00_ssot/project_publish_minimum_corridor_integration_validation_signoff.md`
- `docs/00_ssot/project_publish_board_closure_conclusion_addendum.md`
- `docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md`
- `docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md`
- `docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md`

前端回执只可作为：

- `待核对输入`

不得直接作为：

- `已通过证据`

## 3. 核查范围

只核以下页面与链路：

- `/exhibition/workbench`
- `/exhibition/projects`
- `/exhibition/projects/detail?projectId=...`
- `/exhibition/my/projects`
- `/exhibition/my/projects/detail?projectId=...`
- `/exhibition/projects/create`
- `POST /api/app/project/create`
- `GET /api/app/project/detail`

统一通过既定隧道验证：

- `http://127.0.0.1:8080`

## 4. 必核问题

### 4.1 demo fallback 是否已被正确隔离

必须回答：

- 页面在 demo 承接时，是否明确显示：
  - `当前展示：演示内容`
  或同等级别、不会误判的清晰标识
- 页面在真实命中时，是否明确显示：
  - `当前展示：已接通内容`
  或同等级别标识
- 是否还存在“真实未通但页面看起来像已通”的情况

### 4.2 三块主线语言是否已收口

必须回答：

- `项目工作台` 是否只被表达为：
  - 私域摘要
  - 续接入口
  - 非完整后台
- `项目展示` 是否只被表达为：
  - 公域只读展示
- `我的项目` 是否只被表达为：
  - 当前组织项目私域列表与详情承接
- `项目发布页` 成功态是否仍保持：
  - 业务成功优先

### 4.3 哪些链路是真实命中，哪些仍然只是演示承接

必须逐段判断：

- `真实命中`
- `demo 承接`
- `不稳定`
- `未承接`

不得使用：

- `差不多`
- `基本可用`
- `看起来没问题`

## 5. 强制方法

结果校验 Agent 必须：

- 优先走真实链路
- 记录每个页面的来源标识
- 明确区分：
  - 真实后端/BFF返回
  - demo fallback
- 如遇到真实链路失败，不得自动接受 demo 页面作为通过

如无法拿到某条真实链路证据，必须写：

- `无真实证据，仅代码/页面判断`

## 6. 输出格式

结果校验 Agent 输出必须复用：

- `docs/00_ssot/three_board_real_chain_verification_checklist_v1.md`

并至少填写：

- 主链核查表
- demo fallback 剥离表
- 板块结论表
- 总控裁决区建议

## 7. 放行规则

本轮独立复核通过的最低条件是：

1. `项目发布` 最小走廊继续保持真实命中
2. `项目发布工作台` 不再因为 demo 承接而被误判为真实打通
3. `项目展示` 不再因为 demo 承接而被误判为真实打通
4. 三块主线的页面语言不再混淆：
   - 工作台
   - 我的项目
   - 项目展示
   - 发布成功后的继续动作

若以下任一项成立，则本轮默认：

- `No-Go for 联调发布`

阻断条件：

- 任一关键页面仍会把 demo 承接伪装成真实已接通
- 任一关键链路没有真实证据却被写成“已打通”
- 任一页面语言仍明显混淆私域工作台、公域展示和 owner 私域详情

## 8. 总控当前结论

当前只接受以下升级路径：

- `前端施工回执`
  ->
- `结果校验 Agent 独立复核`
  ->
- `总控重新裁决是否允许联调发布 Agent 介入`

当前明确不接受：

- `前端施工回执`
  ->
- `直接判定联调发布可进入`

