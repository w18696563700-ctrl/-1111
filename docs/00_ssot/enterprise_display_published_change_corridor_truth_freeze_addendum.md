---
owner: Codex 总控
status: active
purpose: Freeze the published-display change corridor truth before any implementation dispatch for enterprise display editing after publish.
layer: L0 SSOT
---

# 《enterprise display published change corridor truth freeze》

## 1. 目标

本单只冻结：

- `企业展示已发布后` 的正式修改通道真相

本单不实现：

- 修改频次规则
- 会员差异化配额
- 具体 contract / code

## 2. 当前问题

如果不先冻结这条通道，后面极易出现三种错误：

1. 把 `已发布展示` 的编辑直接覆盖线上公域
2. 在没有审核链的前提下让工作台伪装成“直接改线上”
3. 让 `案例继续编辑` 和 `已发布展示变更` 各自长出两条不兼容链路

## 3. 基本裁决

### 3.1 未发布态与已发布态必须分开

正式裁决：

#### 未发布态

- 当前展示档仍可直接编辑
- 保存后更新当前私域展示 truth
- 不进入公域变更治理

#### 已发布态

- 当前工作台不能被解释成“直接修改线上展示”
- 当前工作台编辑的语义必须变成：
  - `形成展示变更`

### 3.2 已发布态的正确动作是“提交变更”

正式裁决：

- 已发布展示下，用户的主动作不应是：
  - `保存即生效`
- 主动作应为：
  - `保存修改`
  - `提交变更`

其中：

- `保存修改` 只保存到当前 change draft / change request carrier
- `提交变更` 才进入治理流转

## 4. 对象真相

### 4.1 公域 listing 继续是唯一公开真相

正式裁决：

- 当前 `published + visible listing` 继续是唯一公域展示真相
- 已发布后的编辑不能直接写坏当前公域 listing

### 4.2 已发布修改必须锚定到 listing

正式裁决：

- `变更请求` 属于当前 `listing`
- 它不是新的第二个展示档
- 它也不是用户私有草稿

正式语义：

- `listing-owned change request`

### 4.3 同一 listing 同时只允许一条活动中的 change request

正式裁决：

- 同一个已发布展示档，在任意时点最多只允许 `1` 条活动中的变更请求

活动中包括：

- `draft`
- `submitted`
- `under_review`
- `revision_required`

不允许：

- 同一 listing 并行存在多条未结清修改单

## 5. 链路冻结

已发布态的正确主链冻结为：

1. 打开当前展示工作台
2. 基于已发布展示形成当前变更内容
3. `保存修改`
4. `提交变更`
5. Admin / 平台治理审核
6. 审核通过后再发布
7. 公域展示更新

明确禁止：

- 工作台保存动作直接覆盖当前公域可见展示

## 6. 案例与基础资料如何进入变更通道

正式裁决：

已发布态下，以下内容都属于 `展示变更` 的一部分：

- 基础资料
- 板块画像
- 联系人公开展示相关内容
- 案例库中的新增 / 删除 / 修改

也就是说：

- `案例继续编辑` 在未发布态可以直接进入 listing-owned case truth
- `案例继续编辑` 在已发布态必须进入 change corridor

不能允许：

- 基础资料走 change corridor
- 但案例库继续直接改线上

## 7. 用户侧语义

用户侧在已发布态只应看到下面这套语义：

- `当前展示已发布`
- `你可以继续编辑当前展示内容`
- `保存修改`
- `提交变更`
- `查看变更状态`

不应让用户看到或误解为：

- 改完立即上线
- 当前页保存就是公域立即生效

## 8. 当前阶段非目标

本单明确不冻结：

1. 一个自然月几次
2. 会员每天几次
3. 付费加速与附加额度
4. 特殊豁免规则

这些频次规则后续单独冻结，当前不得混入主链实现。

## 9. 下一步 contract 目标

本单之后，下一轮 contract 冻结应至少覆盖：

1. 打开当前活动中的 change carrier
2. 保存 change draft
3. 提交 change request
4. 查看 change status

本单之后仍不允许：

- 直接发 Flutter“已发布修改”实现包
- 直接发 BFF / Server“线上直接覆盖”实现包
- 在没有 Admin 承接的前提下伪装前台修改已闭环
