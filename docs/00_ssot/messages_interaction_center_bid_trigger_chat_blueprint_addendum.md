---
owner: Codex 总控
status: active
purpose: >
  Freeze the docs-advance landing blueprint for turning the `messages`
  building into a trading interaction center, using bid submit as the seed
  event, reusing existing bid-thread truth, current profile avatar/nickname
  capability, and future participant-card reopening, without granting trading
  implementation unlock in the current round.
layer: L0 SSOT Blueprint
updated_at: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_stop_line_reentry_gate_path_independent_review_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/04_frontend/trading_im_round_a_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/personal_minimal_edit_boundary_freeze_addendum.md
  - docs/00_ssot/personal_minimal_edit_cloud_deployment_repair_execution_receipt_addendum.md
  - docs/00_ssot/factory_detail_optimization_result_verification_conclusion_addendum_v1_1.md
---

# 《消息楼互动中心 / 竞标触发聊天蓝图补充单》

## 1. Scope

- 本蓝图只回答一个问题：
  - 如何把 `消息楼` 从当前的弱提醒面，升级成你要的 `互动中心 / 留痕中心`
- 本蓝图当前只做 docs-advance 方案，不等于：
  - implementation unlock
  - dispatch send
  - cloud runtime completion
- 本蓝图服务的业务目标固定为：
  - `提交竞标 -> 消息楼生成聊天项 -> 打开聊天框 -> 查看竞标 -> 继续对接 -> 平台留痕`

## 2. User-Intent Freeze

当前用户意图冻结如下：

1. 供应方提交竞标后，需求方的 `消息楼` 里要立刻出现一条新的聊天项。
2. 点开该聊天项，进入一个聊天框，而不是停留在提醒卡片或二次跳转页。
3. 聊天框第一条必须是系统消息，语义固定为：
   - `谁谁谁给你发布的项目提交竞标了`
4. 这条系统消息必须带一个 `点击查看` 按钮，打开只读的竞标提交信息摘要。
5. 项目方认可后，可以直接在同一聊天框里回复，对接立即开始。
6. 平台当前目标不是强行防绕单，而是：
   - 先把关键沟通和关键确认留在平台
   - 让双方后续留微信、电话、线下沟通都不构成产品违背
7. 聊天框里点击对方头像，应能打开一个只读合作方名片。
8. 名片里要能看到最小认证信息，并固定带一条静态建议：
   - `合作前建议查看对方企查查信息`

## 3. Current Fact Base

### 3.1 Local source facts

当前本地源码已经具备以下基础：

- 已有交易 IM 真值入口：
  - `GET /api/app/project/clarification/list`
  - `POST /api/app/project/clarification/create`
  - `GET /api/app/bid/thread/detail`
  - `POST /api/app/bid/thread/message/send`
  - `POST /api/app/bid/thread/confirmation/create`
- 已有 Server 持久化实体：
  - `project_clarifications`
  - `bid_thread_messages`
  - `bid_thread_confirmation_cards`
- 已有 `messages` 侧注册表与回跳定义：
  - `project_clarification.open`
  - `bid_thread.open`
- 已有个人头像 / 昵称能力：
  - `POST /api/app/profile/personal/nickname`
  - `POST /api/app/profile/personal/avatar`
  - `POST /api/app/file/upload/init`
  - `个人头像` 页面
  - `设置昵称` 页面
- 已有目标企业 formal-info 既有路线：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

当前本地源码仍然缺失以下关键链路：

- 未找到当前 active 的 `GET /api/app/message/index` BFF / Server truth owner
- 未找到当前 active 的 `GET /api/app/my/bids` BFF / Server truth owner
- 未找到当前 active 的 `GET /api/app/exhibition/trading/participant-card` route family

### 3.2 Cloud runtime facts

于 `2026-04-23 22:24 CST` 通过隧道
`ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
复测，当前云上事实固定如下：

- `GET /health/bff/live -> 200`
- `GET /health/server/live -> 200`
- `GET /api/app/message/index -> 404`
- `GET /api/app/my/bids -> 404`
- `GET /api/app/exhibition/trading/participant-card?... -> 404`
- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info -> 401 AUTH_SESSION_INVALID`
- `POST /api/app/profile/personal/nickname -> 401 AUTH_SESSION_INVALID`
- `POST /api/app/profile/personal/avatar -> 401 AUTH_SESSION_INVALID`
- `POST /api/app/file/upload/init` for `businessType=profile` + `fileKind=avatar`
  with a minimally valid no-auth body -> `401 AUTH_SESSION_INVALID`

这意味着：

- `头像 / 昵称 / formal-info` 的现有路径在云上是活的
- `message/index / my_bids / participant-card` 当前仍未 materialize

## 4. Product Decision

如果要实现本轮目标，产品真相必须改成下面这套：

1. `消息楼` 必须从“弱提醒中心”升级成“互动中心”。
2. `项目沟通` 不再只是 `registered-entry reminder`，而是：
   - 一个真实可打开的交易会话列表
3. `forum lane` 继续独立存在，不并入交易会话列表。
4. 交易聊天真值不从零发明，而是复用既有：
   - `bid_thread`
   - `bid_thread_messages`
   - `bid_thread_confirmation_cards`
5. `提交竞标` 必须被定义为会话种子事件。
6. 会话建立后的第一条消息必须是系统种子消息，而不是等待人工先发第一句。
7. 平台目标固定为：
   - `证据留存优先`
   - `强防绕单不作为本轮核心目标`

## 5. Target Chain

目标链路冻结如下：

1. 供应方完成 `bid submit`。
2. Server 在同一业务链中：
   - 解析 `projectId + bidId`
   - resolve or create 对应 `bid thread`
   - 追加一条 `BidSubmittedSystemSeed` 系统消息
3. `消息楼 / 项目沟通` 列表立即出现一个新的会话项。
4. 项目方点击会话项，直接打开当前 `bid thread` 聊天框。
5. 聊天框首条系统消息展示：
   - 谁提交了竞标
   - 提交时间
   - `点击查看`
6. `点击查看` 打开一个只读 `竞标提交摘要`
   - 不跳回表单页
   - 不伪装成编辑页
7. 项目方如愿意继续沟通，直接在同一聊天框回复。
8. 双方后续交换微信、电话、线下协作都不阻断该链路。
9. 平台保留：
   - 首次竞标触发
   - 首轮沟通
   - 关键确认卡
10. 点击头像或公司名，打开只读合作方名片。
11. 名片固定显示：
   - 公司名 / 头像或 logo 摘要
   - 认证摘要
   - bounded formal-info 摘要
   - 静态提示：`合作前建议查看对方企查查信息`

## 6. Object Boundary

为避免把 scope 做炸，本轮对象边界固定如下：

### 6.1 Reuse, do not reinvent

- 聊天真值复用既有 `bid thread`
- 消息实体复用既有 `bid_thread_messages`
- 关键确认复用既有 `bid_thread_confirmation_cards`
- 个人头像 / 昵称继续留在既有 `profile personal edit` 真值族
- 企业认证摘要继续复用既有 `formal-info` truth family

### 6.2 New bounded child objects

本蓝图允许后续文书 authoring 的新增子对象只有 3 个：

1. `messages interaction list`
   - 交易会话列表投影
2. `bid submitted system seed`
   - 竞标提交后的系统首条消息投影
3. `bid submission snapshot`
   - 从聊天首条消息 `点击查看` 进入的只读竞标摘要

### 6.3 Separate object retained

- `participant-card minimum` 继续是单独 child object
- 它不并入本蓝图自动解锁
- 它仍受当前 stop-line 约束

## 7. Avatar / Nickname Relation

必须明确区分：

1. App 里已经存在的 `头像上传 / 昵称设置`
   - 是当前用户自己的 profile truth
   - 适合复用在消息项和线程头的 `displayName / avatarUrl` 投影
2. 你要的“点对方头像看认证信息”
   - 不是 profile edit
   - 不是 nickname/avatar write
   - 而是一个独立的只读合作方名片对象

所以当前最稳的做法是：

- `消息项 / 聊天头部` 先消费既有 `displayName / avatarUrl` 投影
- `头像点击` 再 handoff 到 `participant-card minimum`
- `企查查建议` 只做静态 copy，不做外部平台集成

## 8. Required Doc Packages

### 8.1 Package A | 消息楼互动中心主包

这是当前最应该 author 的下一包。

顺序固定为：

1. `L0 bounded-object ruling`
2. `L0 stage gate checklist`
3. `L0 truth freeze`
4. `L2 contracts freeze`
5. `L3 backend truth freeze`
6. `L4 BFF surface freeze`
7. `L5 frontend consumption freeze`

这个包要回答的唯一问题是：

- 如何让 `message/index` 从当前 placeholder / unresolved path，变成交易会话列表
- 同时不吞并 forum lane

### 8.2 Package B | 竞标提交摘要子包

这是 `点击查看` 必需的子包。

它要冻结：

- 只读 `bid submission snapshot`
- 可被 project owner 和当前 bidder 双方查看
- 不回到编辑表单
- 不扩成 full bid workspace

### 8.3 Package C | 合作方名片子包

这个包必须建立在已存在的 `participant-card minimum` 链上。

它当前不是从零开始，而是：

- 先更新 reentry fact base
- 把 `formal-info live = 404` 的旧事实更正成当前 live `401 AUTH_SESSION_INVALID`
- 再决定是否允许重开 docs-only reentry

## 9. What Can Advance Now

当前允许推进的是：

- docs-only product/route/object blueprint
- `messages interaction center` 主包 authoring
- `bid submission snapshot` 子包 authoring
- `participant-card minimum` 的事实基线纠偏 authoring

## 10. What Cannot Be Claimed Now

当前不得宣称：

- `message/index` 已成为 active runtime
- `my_bids` 已成为 active runtime
- `participant-card` 已可实现
- `消息楼互动中心` 已可上线

原因固定如下：

- 根护栏仍写明：
  - `No trading flow implementation`
- 当前 `message/index` 仍没有 active owner
- 当前 `participant-card minimum` 仍处于 stop-line

## 11. Recommended Next Unique Action

当前最稳的下一步固定为：

1. 不再沿用旧的 `D1-D23` 线性排期口径。
2. 先输出 `消息楼互动中心 / 竞标触发聊天` 的 bounded-object ruling。
3. 以该 ruling 为起点，重开一套独立的：
   - `L0 -> L2 -> L3 -> L4 -> L5`
   docs-only 链。
4. `participant-card` 不混入主包实施，只作为并行 child-object 保留。
5. 等 `Package A + Package B` 文书冻结完，再决定是否申请新的 trading bounded exception。

## 12. Formal Conclusion

- 当前产品方向正式收口为：
  - `消息楼 = 互动中心 / 留痕中心`
  - `竞标提交 = 触发会话的种子事件`
  - `bid thread = 当前唯一 admitted 聊天真值承载`
  - `平台留痕优先于强防绕单`
- 当前工程推进顺序正式收口为：
  - 先做 docs-only blueprint 与 freeze
  - 再决定是否申请 implementation unlock
- 当前不得把现有 `提醒投影`、`profile avatar/nickname`、`formal-info` 或
  `participant-card stop-line` 误写成已经闭合的互动中心实现。

## 13. Full-Score Landing Blueprint

本节给出可审阅的满分标准蓝图。

### 13.1 Final product positioning

`消息楼` 未来必须承接两个并行 lane：

1. `项目沟通`
   - 真实交易互动列表
   - 以 `bid thread` 为真值承载
   - 进入后是聊天框
2. `论坛互动`
   - 保持当前独立 lane
   - 不并入交易聊天列表

产品一句话定义固定为：

- `消息楼 = 互动中心`
- `我的项目 = 资产中心`
- `项目详情 = 首次进入与项目说明页`

### 13.2 First-release interaction contract

本轮目标不是“做一个完整 IM 产品”，而是做一个交易留痕闭环。

首发必须做到：

1. 有人提交竞标，项目方立即看到一条会话。
2. 点开直接进聊天，不再先看提醒卡。
3. 聊天第一条是系统种子消息，不等人工先打招呼。
4. 第一条消息能打开竞标提交摘要。
5. 项目方可立即回复。
6. 平台内保留首次触发、首次对接、关键确认。

首发明确不做：

- 未读/已读生命周期治理
- typing / online / push / realtime
- 群聊
- 陌生人会话
- 微信/电话拦截
- 外部企查查 API 集成

### 13.3 Target UX map

用户最终看到的路径固定如下：

#### A. 供应方视角

1. 进入项目详情
2. 点击 `立即参与竞标`
3. 完成竞标提交
4. 成功页给出：
   - `查看我的竞标`
   - `沟通与投标`
5. 若点 `沟通与投标`
   - 直接进入当前 `bid thread`
   - 顶部看到对方主体摘要

#### B. 需求方视角

1. 不在项目详情被动等
2. 在 `消息楼 -> 项目沟通` 看到一条新会话
3. 列表项文案固定类似：
   - `某某公司对你的项目提交了竞标`
4. 点开后进入聊天框
5. 第一条系统消息：
   - `某某公司已对你的项目提交竞标`
   - `点击查看`
6. 点击后打开只读 `竞标提交摘要`
7. 若认可，直接在聊天框中回复

#### C. 双方共同视角

1. 聊天框中头像/公司名可点击
2. 点击后打开 `合作方名片`
3. 名片里固定展示：
   - 企业名称
   - 当前认证摘要
   - bounded formal-info 摘要
   - 静态建议：`合作前建议查看对方企查查信息`

### 13.4 Object model

本轮完整对象图固定如下：

1. `Project`
   - 项目容器
2. `Bid`
   - 竞标提交容器
3. `BidThread`
   - 当前唯一私密沟通对象
4. `BidThreadMessage`
   - 私密消息对象
5. `BidThreadConfirmationCard`
   - 关键确认对象
6. `MessagesInteractionListItem`
   - 新增的消息楼互动列表投影对象
7. `BidSubmittedSystemSeed`
   - 新增的系统种子消息语义对象
8. `BidSubmissionSnapshot`
   - 新增的只读竞标摘要对象
9. `ParticipantCardMinimum`
   - 既有 stop-line child object，继续保留

### 13.5 Event chain

完整事件链固定如下：

1. `BidSubmitted`
   - 由 `bid submit` 成功触发
2. `BidThreadResolved`
   - 查找或创建 `bid thread`
3. `BidSubmittedSystemSeedCreated`
   - 生成首条系统消息
4. `MessagesInteractionProjectionUpserted`
   - 将该 thread 投影进 `消息楼 -> 项目沟通`
5. `ParticipantConversationStarted`
   - 任一方回复后成立
6. `ConfirmationCardCreated`
   - 关键结论需要沉淀时成立

### 13.6 Page map

需要落的页面 / 面板固定如下：

1. `MessagesPage`
   - 增加 `项目沟通 / 论坛互动` 两 lane
2. `BidThreadPage`
   - 承接真实聊天框
3. `BidSubmissionSnapshotSheet/Page`
   - 承接系统消息里的 `点击查看`
4. `ParticipantCardSheet/Page`
   - 承接头像点击
5. `MyProjectListPage`
   - `我的发布 / 我的竞标`
6. `BidSubmitResultSection`
   - 成功后直达 thread / my bids

### 13.7 Contract family

后续文书 authoring 时，推荐冻结以下 app-facing 家族：

#### Already existing and must be reused

- `GET /api/app/bid/thread/detail`
- `POST /api/app/bid/thread/message/send`
- `POST /api/app/bid/thread/confirmation/create`
- `GET /api/app/project/clarification/list`
- `POST /api/app/project/clarification/create`
- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

#### Must be newly frozen

1. `GET /api/app/message/interactions`
   - 替代当前“把 message/index 直接做成聊天中心”的模糊口径
   - 只承载交易互动列表
2. `GET /api/app/my/bids`
   - 只承载我的竞标列表
3. `GET /api/app/bid/submission/snapshot`
   - 只读竞标摘要
4. `GET /api/app/exhibition/trading/participant-card`
   - 继续沿用既有 minimum route family

### 13.8 Why use a new interaction-list route instead of overloading `message/index`

当前最稳的满分路线，不建议把所有东西重新压回 `message/index`。

原因：

1. `message/index` 当前历史包袱太重
   - placeholder
   - unresolved path
   - no active owner
2. 你现在要的不是“提醒列表”，而是“交易互动列表”
3. 如果硬把它继续叫 `message/index`，很容易把：
   - reminder projection
   - active conversation list
   - forum lane
   混成一个模糊对象

所以更稳的做法是：

- `message/index` 保留为 reminder/history reserve
- 新开 `message/interactions` 作为互动中心主列表

如果你坚持不想新开 route family，也可以 second-best：

- 把 `message/index` 正式改判成 `interaction center list`
- 但必须同步废掉“placeholder only”的旧口径

### 13.9 Thread first-message spec

系统种子消息的最小结构建议冻结为：

- `messageType = system_bid_submitted_seed`
- `threadId`
- `projectId`
- `bidId`
- `actorSummary`
- `organizationSummary`
- `submittedAt`
- `snapshotAction`

前台文案建议固定为：

- `某某公司已对你的项目提交竞标`
- `你可以先查看对方本次竞标摘要，再决定是否继续对接。`
- CTA：`点击查看`

### 13.10 Bid submission snapshot spec

`点击查看` 打开的只读摘要建议固定只看 6 类信息：

1. 提交主体
2. 提交时间
3. 报价金额
4. 方案摘要
5. 已确认附件清单
6. 当前可执行动作

本页明确不做：

- 重新编辑
- 重新提交
- 完整投标工作台 takeover

### 13.11 Participant card spec

首发版合作方名片建议只做：

1. 公司名
2. 头像 / logo 摘要
3. 组织角色摘要
4. 企业认证状态
5. 我的认证关联状态摘要
6. bounded formal-info 摘要
7. 静态提示：
   - `合作前建议查看对方企查查信息`

首发明确不做：

- 公开信用分
- 完整成交记录列表
- 外部风控接口聚合
- 对方联系方式扩面

### 13.12 Data ownership

真值归属必须写死：

- `Server`
  - Bid
  - BidThread
  - BidThreadMessage
  - BidThreadConfirmationCard
  - BidSubmissionSnapshot truth projection
  - ParticipantCardMinimum truth projection
- `BFF`
  - 只做 app-facing shaping
  - 不拥有任何第二状态机
- `Flutter`
  - 只消费
  - 不本地编造会话真值

### 13.13 Deployment topology constraints

必须继续按当前拓扑写方案：

- 本地只有前端源码可直接跑验
- `apps/server` 与 `apps/bff` 源码在仓里，但运行态在阿里云
- 云上验证必须继续通过：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 任何后续“已完成”口径都必须同时满足：
  - 本地 source 存在
  - 云上 app-facing route smoke 成立

### 13.14 Doc package order

这件事要按下面顺序走，不能再用旧的线性 D1-D23 混包：

#### Package A | Interaction Center main object

1. `bounded-object ruling`
2. `stage gate checklist`
3. `truth freeze`
4. `contracts freeze`
5. `backend truth freeze`
6. `bff surface freeze`
7. `frontend consumption freeze`

#### Package B | Bid submission snapshot

1. `bounded-object ruling`
2. `truth freeze`
3. `contracts freeze`
4. `backend truth freeze`
5. `bff surface freeze`
6. `frontend consumption freeze`

#### Package C | Participant card reopening

1. 先更新 live fact base
2. 再提 fresh `reentry stage gate checklist`
3. 通过后才能进入 docs-only authoring continuation

### 13.15 Acceptance standard

我按满分标准定义，最终验收必须至少满足：

1. 提交竞标后，需求方消息楼出现一条新会话。
2. 会话点开直接进入聊天框。
3. 首条系统消息正确出现并可 `点击查看`。
4. 竞标摘要是只读且信息完整。
5. 双方可直接继续聊天。
6. 头像点击能打开只读合作方名片。
7. 名片里有认证摘要和企查查提示。
8. `论坛互动` 仍保持独立 lane。
9. 本地 source 与云上 app-facing smoke 同时成立。
10. 不出现“提醒看起来有了，但真实 route 仍是 404”的假完成。

### 13.16 Current blocking summary

为什么现在还不能直接声称这条链已闭合，原因固定为：

1. `message/index` 当前仍未 materialize
2. `my_bids` 当前仍未 materialize
3. `participant-card` 当前仍在 stop-line
4. 根护栏仍是 `No trading flow implementation`

所以当前最优路径不是“跳过文书直接写代码”，而是：

- 先把上面三个包的蓝图和 freeze 链 author 完
- 再申请一轮新的 bounded trading exception
