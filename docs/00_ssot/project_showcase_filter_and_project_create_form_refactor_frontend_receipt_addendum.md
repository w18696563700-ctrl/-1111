---
owner: Frontend Agent
status: draft
purpose: Record the local frontend receipt for the project showcase chain closure so result verification can use concrete mobile-side evidence for list/detail/create consumption, my-project stage carry, bid entry and result guard alignment, and related certification-bound frontend surfaces.
layer: L0 SSOT
freeze_date_local: 2026-04-11
updated_at_local: 2026-04-14
---

# 项目展示筛选与创建表单重构前端回执补充单

## 1. 当前对象

- 当前对象：
  - `project showcase chain closure`
- 当前文件名沿用历史对象命名：
  - `project_showcase_filter_and_project_create_form_refactor_frontend_receipt_addendum.md`
  - 但本轮正文 scope 以当前链路收口为准，不再只限于 `project/list + project/detail + project/create`
- 当前 scope：
  - `Flutter bounded consumption closure`
- 当前执行角色：
  - `前端 Agent`
- 当前执行范围：
  - `apps/mobile`
- 当前完成目标：
  - `project/list`
  - `project/detail`
  - `project/create`
  - `my-project published carry`
  - `bid submit / bid result guard alignment`
  及其最小 consumer / support touch

## 2. 修改文件清单

- [project_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart)
- [project_showcase_card_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_showcase_card_widgets.dart)
- [project_list_filter_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_list_filter_widgets.dart)
- [exhibition_trade_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart)
- [project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart)
- [project_create_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart)
- [project_create_round_a_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart)
- [bid_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart)
- [exhibition_status_messages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart)
- [exhibition_home_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart)
- [bid_submit_guard_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart)
- [my_project_stage_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart)
- [exhibition_payload_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart)
- [exhibition_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart)
- [exhibition_load_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart)
- [exhibition_contract_mapper.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart)
- [project_create_command.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/commands/project_create_command.dart)
- [exhibition_mainline_flow_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/exhibition_mainline_flow_test.dart)
- [showcase_cloud_handoff_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/showcase_cloud_handoff_test.dart)
- [shell_app_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/shell_app_test.dart)
- [my_project_private_carry_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/my_project_private_carry_test.dart)
- [bid_award_bridge_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/bid_award_bridge_test.dart)
- [project_showcase_filter_create_refactor_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/project_showcase_filter_create_refactor_test.dart)

## 2.1 相关承接与复核面

- 以下对象属于本轮一致性收口的相关承接面或复核输入，不等于本轮全部都发生代码修改：
  - [my_project_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart)
  - [my_project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart)
  - [bid_submit_sections_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_sections_support.dart)
  - [my_project_private_progress_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_private_progress_support.dart)
  - [project_create_command_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/project_create_command_test.dart)
  - [latest_user_confirmed_change_ledger.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/latest_user_confirmed_change_ledger.md)
  - [project_showcase_trade_language_and_guard_alignment_frontend_truth_note.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/project_showcase_trade_language_and_guard_alignment_frontend_truth_note.md)
  - [account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md)
- 这组文件的作用是：
  - 证明 `我的项目` 与 `项目展示` 的阶段词和动作词没有重新打架
  - 证明竞标守卫继续依赖既有 `公司认证与我的身份` 单链消费
  - 防止把本轮 `apps/mobile` 统一口径误写成新增后端权限模型

## 3. 当前修正前的问题

- `project/list`
  - 还没有消费：
    - `provinceCode`
    - `cityCode`
    - `areaBucket`
    - `budgetBucket`
  - 卡片仍偏旧的：
    - `title + buildingType + summary`
    结构，不符合当前冻结后的主信息顺序
  - `200 + items=[]` 在视觉上容易和正常 content-state 混在一起
- `project/detail`
  - 仍是 `title` 单字段优先
  - 对 expired public continuation unavailable 的语义未说清
- `project/create`
  - 仍是单一“项目名称”输入
  - 未把新表单主输入升级为：
    - `展会`
    - `品牌`

## 4. 当前修正后的收口方式

### 4.1 筛选消费

- `project/list` 当前已通过 app-facing consumer 正式带出：
  - `provinceCode`
  - `cityCode`
  - `areaBucket`
  - `budgetBucket`
- 默认优先级继续保持：
  1. 手动城市
  2. 当前城市上下文
  3. 全国兜底
- 当前没有新增：
  - 企业所在地筛选
  - `districtCode` 主筛选

### 4.2 列表状态区分

- 当前已区分：
  - real content-state
  - real empty-state
  - blocker / failure state
- `200 + items=[]` 现在按真实 empty-state 呈现，不再借 content 壳伪装成“已接通成功”

### 4.3 列表卡片结构

- 列表卡当前主展示顺序收口为：
  1. 展会
  2. 品牌
  3. 金额
  4. 面积
  5. 地点
  6. 时间
- `title` 只保留 fallback 身份，不再当唯一主展示位
- 当前已显式压缩单卡纵向占用
- `2026-04-14` 当前用户进一步确认：
  - `展会 / 品牌 / 金额 / 面积 / 地点` 必须继续保持更大的主信息字号
  - `金额` 在主信息区内继续强调
  - `时间 + 查看详情` 固定合并为同一底部行
  - 不再恢复成“时间一行 + 查看详情再下一行”的旧高卡结构
- 为满足 `Flutter App AGENTS` 文件长度门禁，当前同步把：
  - 卡片组件
  - 筛选子组件
  从 `project_list_page.dart` 拆出到独立 part 文件；这不是另起新对象，而是当前对象的边界内整理。

### 4.4 详情页结构

- `project/detail` 当前改为双字段优先：
  - 有 `exhibitionName` 时优先展示 `展会`
  - 有 `brandName` 时优先展示 `品牌`
  - `title` 只作 fallback / compatibility
- 对 `404 AUTH_RESOURCE_UNAVAILABLE` 已按受控 unavailable 承接：
  - 明确是“退出公域展示”
  - 不暗示“项目不存在”
  - 不暗示 owner 私域也不可见
- `2026-04-14` 当前用户进一步确认：
  - real-content 顶部“已接通内容”提示卡隐藏
  - `公开项目说明` 与 `公开资料边界` 隐藏
  - 详情主区收口为：
    - `核心信息`
    - `地点与安排`
    - `当前状态 / 继续竞标 / 继续处理`
  - `核心信息` 当前进一步收口为：
    - 项目名称字号下调一档
    - `项目编号` 独占一行
    - 其余核心字段继续双列排列
  - `省 / 市 / 区县 / 详细地址` 合并成 `项目地点`
  - `开始日期 / 结束日期` 合并成 `计划时间`
  - 只对有值字段继续显示，减少空占位行数

### 4.5 创建表单结构

- 创建页当前已从一格升级为两格：
  - `展会`
  - `品牌`
- 前端提交当前优先走 dual-field mode
- `title` 由前端组合为 compatibility carrier 一并提交
- 没有扩新字段，也没有破坏 legacy-title mode

### 4.6 状态词、筛选与竞标动作统一

- 当前 `project.state` 前端可见词已统一为：
  - `published` -> `竞标中`
  - `bidding_closed` -> `投标已结束`
  - `awarded` -> `已授标`
  - `converted_to_order` -> `已被承接`
- `我的项目` 中原 `已发布` 阶段当前同步改为：
  - `竞标中`
- 详情动作文案当前统一为：
  - `继续竞标` -> `立即参与竞标`
  - `查看投标结果` -> `查看竞标结果`
- `项目展示` 列表当前新增本地筛选：
  - `状态`
  - `类型`
- 当前列表筛选组合正式为：
  - `城市 / 状态 / 类型 / 面积 / 金额`
- `project/detail` 中原 `建筑类型` 标签当前统一改为：
  - `项目类型`
- canonical `buildingType` 当前前端可见词统一为：
  - `exhibition` -> `会展`
  - `renovation` -> `装修`
  - `custom_furniture` -> `定制`
- 创建页场景选择入口当前继续保留：
  - `会展 / 展厅 / 商业活动 / 会议 / 路演 / 美陈 / 纯安装 / 其他`
  作为发布时更细的前端选择面
- `立即参与竞标` 与 `查看竞标结果` 当前统一先过：
  - 登录
  - 组织
  - 企业认证
  - 我的认证
  - 供应商身份
  这一套前端守卫
- 守卫失败时当前优先回：
  - 登录入口
  - `公司认证与我的身份`
  - 当前项目详情
  而不是默认静默打回项目展示列表
- `个人认证 + 企业认证` 双重认证当前已作为正式能力承接：
  - `公司认证与我的身份` 中展示：
    - `当前我的认证`
    - `我的认证真值`
    - `提交我的认证`
  - `shell/context` 当前承接：
    - `personalCertificationStatus`
    - `personalCertificationQualified`
    - `personalCertificationLockedToOtherActor`
  - 当前写链固定为：
    - `init -> direct upload -> confirm -> OCR -> submit`
  - 当前不得再把双重认证写成 future-only freeze；正式运行时对齐见：
    - `docs/00_ssot/dual_certification_cloud_runtime_alignment_receipt_addendum.md`
    - `docs/04_frontend/profile_dual_certification_bid_guard_frontend_truth_note.md`
- `我的项目` 中 `竞标中` 阶段当前继续保持：
  - 列表卡 / 摘要卡只显示：
    - `查看详情 / 补充资料`
  - 详情摘要只显示：
    - `优先补充资料；当前详情页不再单独展示阶段动作。`
  - 不再把 `下架关闭` 混入当前下一步文案

## 5. 本地验证结果

- `flutter analyze`
  - 目标：
    - `lib/features/exhibition/presentation/pages/project_detail_page.dart`
    - `lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart`
    - `test/my_project_private_carry_test.dart`
  - 结果：
    - `通过`
- `flutter test test/project_showcase_filter_create_refactor_test.dart`
  - 结果：
    - `通过`
- `flutter test test/exhibition_mainline_flow_test.dart test/project_showcase_filter_create_refactor_test.dart test/exhibition_home_test.dart`
  - 结果：
    - `通过`
- `flutter test test/exhibition_mainline_flow_test.dart test/showcase_cloud_handoff_test.dart test/shell_app_test.dart test/my_project_private_carry_test.dart test/bid_award_bridge_test.dart`
  - 结果：
    - `通过`
- `flutter test test/exhibition_mainline_flow_test.dart test/showcase_cloud_handoff_test.dart test/shell_app_test.dart test/my_project_private_carry_test.dart test/bid_award_bridge_test.dart test/project_showcase_filter_create_refactor_test.dart test/project_create_command_test.dart`
  - 结果：
    - `通过`
- `2026-04-14` 最新独立复查回合
  - 复查焦点：
    - `我的项目 -> 竞标中` 阶段当前下一步文案
    - receipt 范围是否覆盖相关承接面与文书
    - `flutter analyze` 与 receipt 记录是否一致
  - 复查结论：
    - 上一轮 3 个 `No-Go` 争议点全部撤销
    - 当前按 `Go` 口径承接
  - anti-revert 说明：
    - 后续线程不得再依据已失效的旧复查结论，把本轮统一口径误判成未收口或误改

## 6. 本轮测试覆盖点

- list filter query 参数消费
- list real content-state / real empty-state / blocker state 区分
- list 紧凑卡主信息渲染
- detail dual-field 优先
- expired unavailable 受控承接
- create dual-field body + legacy `title` compatibility
- create page 两格表单可见
- 统一后的状态词、详情动作词与我的项目阶段词
- 列表 `状态 / 类型` 本地筛选
- `项目类型` 可见标签与 canonical type 展示词
- 竞标入口 / 竞标结果入口守卫与回流路径

## 7. 当前剩余非前端阻断项

- 当前没有新的 Flutter 代码阻断。
- 当前剩余项属于结果校验阶段：
  - 真实云端当前城市上下文命中后的列表效果校验
  - 真实 `areaBucket / budgetBucket` 返回命中校验
  - 真实 expired public continuation 是否稳定返回 `404 AUTH_RESOURCE_UNAVAILABLE`

## 8. 是否可移交下一角色

- 结论：
  - `yes`
- 当前可移交对象：
  - `结果校验 Agent`
- 当前可移交含义：
  - Flutter 侧本轮 bounded consumption closure 已闭合
  - 但仍需独立 runtime 复核，不能直接写成 integration pass 或 total closure
