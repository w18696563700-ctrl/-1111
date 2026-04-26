---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L0 correction for the messages building information
  architecture: one counterpart subject owns one container, the container only
  lists project entries, and chat starts only after a concrete project entry is
  selected.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_field_table_addendum.md
  - docs/00_ssot/counterpart_conversation_route_table_addendum.md
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_field_table_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
---

# 《对方主体会话容器项目切片 IA 修订冻结》

## 1. Scope

- 本冻结单只修订并冻结：
  - 消息楼一级的 `一个对方主体一个总框`
  - 点进总框后只显示该对方主体下的项目入口列表
  - 点某个项目入口后才进入 `此项目竞标沟通` 页
  - 聊天必须绑定 `projectId + threadId`
  - 竞标沟通页内的字段与按钮边界
- 本冻结单不覆盖：
  - generic DM / group chat
  - 跨项目聊天合并
  - 新统一聊天状态机
  - BFF / Server 业务真值迁移
  - 支付 / 结算 / 订单履约状态机扩展

## 2. Final IA Truth

- 消息楼一级正式固定为：
  - 一个对方主体一个总框
- 正式锚点沿用既有冻结：
  - `viewerOrganizationId + counterpartOrganizationId`
- 展示语义允许按账号视角表达为：
  - 一个当前账号看到一个对方主体一个总框
- 业务真值语义不得改写为：
  - 一个账号直接拥有聊天 truth
  - 一个对方主体总框拥有聊天 truth
- `CounterpartConversationContainer` 的正式语义固定为：
  - 对方主体聚合入口容器
  - 项目入口列表容器
  - 非聊天容器
  - 非业务状态机

## 3. Container Page Rule

- 点进对方主体总框后，只允许显示该对方主体下的项目入口列表。
- 示例：
  - `西洽会泸州`
  - `西洽会成都`
- 每个项目入口必须清楚表达：
  - 当前项目名称或受控遮罩名称
  - 当前项目的轻量业务状态
  - `进入此项目竞标沟通`
- 总框页不得显示：
  - 聊天记录
  - 聊天输入框
  - 项目订单状态展开卡
  - 项目相册展开内容
  - 任何跨项目合并状态
- 总框页不得自动加载：
  - `ProjectCommunicationThread`
  - 项目聊天 messages
  - 项目实时 WebSocket
  - 项目相册照片列表
  - 项目订单详情

## 4. Project Entry Rule

- 项目入口的正式锚点必须是：
  - `projectId`
- 进入项目沟通页的动作必须同时携带：
  - `conversationId`
  - `counterpartOrganizationId`
  - `projectId`
- `focusProjectId` 或列表默认聚焦项目只允许承担：
  - 列表排序
  - 默认高亮
  - 从一级入口进入后的视觉定位
- `focusProjectId` 不等于已选择聊天项目。
- 未点击具体项目入口前，Flutter 不得创建或消费项目聊天上下文。

## 5. Project Communication Page Rule

- 点某个项目入口后，才进入 `此项目竞标沟通` 页。
- 此项目沟通页按以下顺序展示：
  1. `竞标沟通`
     - 对方头像
     - 对方昵称或主体展示名
     - 认证公司字段，必须来自真实 projection，不能本地伪造
  2. `项目名称查看申请 / 审核`
     - 改为按钮入口
     - 点击后进入既有申请 / 审核页面或受控详情页
  3. `订单状态卡`
     - 改为按钮入口
     - 当前页默认不展开
     - 点击后进入订单状态详情或受控页
  4. `项目相册`
     - 改为按钮入口
     - 当前页默认不展开
     - 点击后进入项目相册详情或受控页
  5. `聊天记录和输入框`
     - 只在 `projectId + threadId` 已建立后显示

## 6. Chat Truth Boundary

- 聊天必须绑定：
  - `projectId + threadId`
- `threadId` 必须来自项目沟通 thread truth。
- `conversationId` 只允许作为对方主体总框容器 id 或路由上下文。
- `conversationId` 不得被当作聊天 thread truth。
- 所有发送消息命令必须携带：
  - `projectId`
  - `threadId`
- 所有消息列表缓存 key 必须至少包含：
  - `projectId`
  - `threadId`
- 明确禁止：
  - 把多个项目的消息合并到一个对方主体总框下
  - 在未选项目时显示或发送聊天消息
  - 只用 `counterpartOrganizationId` 作为聊天上下文
  - 只用 `conversationId` 作为聊天上下文

## 7. Field Boundary Freeze

- 当前已稳定可消费的对方主体字段按既有 projection 口径为：
  - `organizationId`
  - `displayName`
  - `avatarUrl`
  - `role`
- 当前项目沟通页可先按最低闭环展示：
  - `displayName` 作为主体展示名或昵称位
  - `avatarUrl` 作为头像
- 以下字段属于保留扩展位，未进入正式 projection 前不得由 Flutter 假造：
  - `counterpartNickname`
  - `certifiedCompanyName`
  - `certificationStatus`
  - `certifiedOrganizationId`
- 若产品要求 `昵称 + 认证公司` 必须真实分开展示，则必须先补：
  - L2 contract 字段冻结
  - L3 Server projection 字段来源
  - L4 BFF response shaping
  - L5 Flutter consumption 更新
- 在上述字段未冻结前，前端只能：
  - 隐藏认证公司行
  - 或显示受控空态
  - 或用 `displayName` 作为唯一主体名

## 8. Data, Album, And Upload Boundary

- 项目相册仍按既有冻结绑定：
  - `projectId`
  - `fileAssetId`
- `objectKey` 仍不得成为业务真值。
- 上传仍是：
  - `init -> direct upload -> confirm`
- 项目沟通页的相册入口不得把相册照片当聊天图片消息。
- 项目相册详情是否开通、展示分类和 50 张上限，继续以后续已冻结的相册文书和 BFF / Server contract 为准。

## 9. BFF / Server Boundary

- Flutter App 只允许访问 BFF。
- BFF 只做：
  - auth consolidation
  - aggregation
  - response shaping
  - upload signing
  - visibility trimming
- Server 继续拥有：
  - thread truth
  - message truth
  - order truth
  - audit
  - state machines
- 本 Day-1 文书不授权改动云上 BFF / Server。
- 本 Day-1 文书不等于云上 UAT 通过。

## 10. Current Minimum Loop

- 当前最小闭环固定为：
  1. 消息楼一级打开某对方主体总框
  2. 总框只列出该对方主体下项目入口
  3. 点击项目入口进入此项目竞标沟通页
  4. 项目页按钮化承接名称申请 / 订单状态 / 项目相册
  5. 项目页在拿到 `projectId + threadId` 后显示聊天记录和输入框

## 11. Reserved But Closed

- 当前保留但暂不开通：
  - generic DM
  - group chat
  - 图片聊天消息
  - 语音 / 表情 / typing / presence
  - 跨项目统一聊天
  - 跨项目统一订单状态
  - Flutter 本地生成认证公司字段

## 12. Expansion Slots

- 后续扩展位：
  - 独立 `certifiedCompanyName` projection
  - 项目相册独立详情页
  - 订单状态独立详情页
  - 项目沟通接收侧 WebSocket 稳定化
  - 多项目 unread summary，但不得合并消息 truth

## 13. Strategy Judgment

- 更稳：
  - 先按本 L0 修订冻结 IA，再进入 Flutter 拆页实现和云上 UAT。
- 更省成本：
  - 只在本地 Flutter 做总框去聊天化和项目页拆分，暂不扩展 BFF / Server 字段。
- 更适合当前阶段：
  - 先冻结 `总框只列项目，项目页才聊天`，同时把 `认证公司` 字段列为受控扩展位。
- 风险更大：
  - 直接在现有 `CounterpartConversationPage` 上继续堆聊天、订单、相册展开内容。
  - 未冻结字段来源就展示假的认证公司。
  - 跳过双账号多项目验证。

## 14. Stage Conclusion

- `对方主体会话容器项目切片 IA` 现正式冻结。
- 下一步允许：
  - L5 frontend consumption freeze
  - Flutter IA implementation within this boundary
- 当前仍：
  - No-Go for BFF / Server projection expansion without a separate field freeze
  - No-Go for cloud release judgment
