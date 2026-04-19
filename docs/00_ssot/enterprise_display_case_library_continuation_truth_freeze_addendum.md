---
owner: Codex 总控
status: active
purpose: Freeze the continuation truth for listing-owned enterprise display case libraries before any case-edit contract or implementation dispatch.
layer: L0 SSOT
---

# 《enterprise display case library continuation truth freeze》

## 1. 目标

本单只冻结一件事：

- `案例库` 在第一段“保存案例”闭环之后，如何进入第二段“继续编辑案例”闭环

本单不实现：

- 已发布展示的正式 `变更提交通道`
- 修改频次治理

## 2. 当前已知现状

当前仓库已经具备：

- `案例编辑器 + 保存案例`
- `案例库`
- `listing-owned` 案例归属
- `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases`
- `DELETE /api/app/exhibition/enterprise-hub/cases/{caseId}`

当前仍缺：

1. 从 `案例库` 回填 `案例编辑器` 的正式继续编辑链
2. 正式的 `update case` canonical contract
3. 单案例继续编辑所需的稳定 read carrier

## 3. 对象真相

### 3.1 案例仍然属于展示档，不属于用户

正式裁决：

- `案例` 继续属于当前 `board 级 enterprise listing`
- `案例继续编辑` 不改变案例归属
- `案例继续编辑` 不得被实现成“某个创建用户自己的编辑草稿箱”

### 3.2 案例编辑器正式进入双模式

`案例编辑器` 正式冻结为两种模式：

1. `新建模式`
2. `编辑模式`

#### 新建模式

- 由空白编辑器进入
- 主要动作：`保存案例`

#### 编辑模式

- 从 `案例库` 中选择某条已保存案例进入
- 编辑器回填当前案例的真实内容
- 主要动作：`保存修改`

### 3.3 案例库正式具备“继续编辑”入口

正式裁决：

- `案例库` 中的每条案例卡都应提供：
  - `继续编辑`
  - `删除案例`

`继续编辑` 的语义是：

- 把当前案例的真实内容回填到 `案例编辑器`
- 当前页进入 `编辑模式`

## 4. 读写真相边界

### 4.1 案例库列表不是编辑草稿本身

正式裁决：

- `案例库` 列表承担的是：
  - 展示当前展示档下的已保存案例摘要
- `案例库` 列表不应被硬解释为：
  - 完整编辑草稿载体

也就是说：

- 列表卡可以展示标题、摘要、状态、日期、重点标记
- 但继续编辑所需的完整内容，应由正式 edit carrier 承接

### 4.2 单案例继续编辑必须有正式 edit carrier

正式裁决：

- `案例继续编辑` 不应依赖前端从列表摘要“拼”出完整编辑体
- 必须存在正式的单案例编辑承接载体

下一轮 contract 冻结时，正式方向定为：

1. `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
2. `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`

原因：

- `GET /cases/{caseId}` 让前端拿到完整 edit carrier
- `PUT /cases/{caseId}` 让“保存修改”有明确的 canonical path
- 这样不会把 `workbench cases[]` 列表 carrier 不断膨胀成第二个详情载体

## 5. 用户侧语义冻结

### 5.1 前台继续不暴露草稿箱心智

正式裁决：

- 后台可以继续保留 `caseStatus = draft`
- 但用户侧继续不以“草稿箱”作为主心智

第二段用户语言正式收口为：

- `保存案例`
- `保存修改`
- `继续编辑`
- `案例库`
- `已保存到案例库`

不要求用户理解：

- `draft`
- `edit draft`
- `case draft`

### 5.2 提交门槛仍只认已保存案例

正式裁决：

- `提交入驻申请` 继续只认 `Server` 已持久化的案例数量
- `编辑模式` 里尚未保存的修改，不得被前端误算成已满足提交门槛

## 6. 当前阶段非目标

以下内容明确不在本单实现范围内：

1. 已发布展示案例修改如何进入审核
2. 会员频次治理
3. 变更额度限制
4. 已发布案例修改的 Admin 审核面

这些问题统一交给：

- [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)

## 7. 下一步 contract 目标

本单之后，只允许进入：

1. `case detail / case update` contract freeze
2. 然后才允许：
   - `Server`
   - `BFF`
   - `Flutter`

本单之后仍不允许：

- 直接前端拼 case edit body
- 先改 Flutter 再补 contract
- 把继续编辑做成用户私有草稿箱
