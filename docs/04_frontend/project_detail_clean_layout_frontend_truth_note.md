---
owner: Codex 总控
status: active
purpose: >
  Record the current Flutter-side clean layout and anti-revert rule for the
  public project detail page, including which noise panels stay hidden, how
  the core info is compacted, and how real-content versus demo fallback source
  notices are handled.
layer: L5 Frontend
decision_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/current_publish_experience_optimization_truth_freeze_addendum.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_detail_compact_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart
---

# 项目详情页清爽排版 frontend truth note

## 1. Scope

- 本说明只覆盖当前 `展览楼 -> 项目详情` 的公域详情排版：
  - 顶部来源提示
  - 核心信息区
  - 地点与安排区
  - 状态承接区
- 本说明不改写：
  - `my-project detail`
  - owner-private 文书区
  - `BFF / Server` read contract
  - `继续竞标 / 查看投标结果 / 进入我的项目` 的业务边界

## 2. 当前执行边界

- 本次开发执行环境固定为：
  - 本地只修改 `apps/mobile`
  - `BFF / Server` 继续以云上 active runtime 为准
- 当前默认联调隧道固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 后续线程不得因为本地未起 `BFF / Server`，就把这次详情页清爽化改动误判为漂移。

## 3. 当前已确认详情页结构

- real-content 项目详情当前默认隐藏：
  - 顶部 `当前展示：已接通内容` 提示卡
  - `公开项目说明`
  - `公开资料边界`
- demo fallback 当前继续显式保留：
  - `当前展示：演示内容`
  - `当前真实内容暂未返回`
- 主内容当前固定收口为：
  1. `核心信息`
  2. `地点与安排`
  3. `当前状态 / 继续竞标 / 继续处理`

## 4. 当前排版规则

- `核心信息` 当前必须使用：
  - 主标题
  - 次标题
  - 状态 pill
  - 双列紧凑信息块
- `核心信息` 当前进一步固定为：
  - 项目名称较上一轮再降一个字号规格
  - `项目编号` 独占一行
  - 其余核心字段继续按两列排列
- `核心信息` 当前不再恢复成逐行长列表：
  - 项目名称
  - 建筑类型
  - 预算金额
  - 项目面积
  - 项目状态
  各自单独占一整行
- `地点与安排` 当前必须收口为：
  - `项目地点` 合并 `省 / 市 / 区县 / 详细地址`
  - `计划时间` 合并 `计划开始日期 / 计划结束日期`
  - `范围说明 / 时间说明 / 补充说明` 只在有值时显示
- 缺省字段当前不再逐条输出：
  - `当前项目暂未提供`
  的重复占位行

## 5. Anti-revert Rule

- 后续线程当前不得把以下行为当成“误改”直接回退：
  - 恢复 real-content 顶部“已接通内容”提示卡
  - 恢复 `公开项目说明` 独立卡
  - 恢复 `公开资料边界` 独立卡
  - 把地点重新拆回 `省 / 市 / 区县 / 详细地址` 多条长列表
  - 把计划时间重新拆回 `开始日期 / 结束日期` 两条长列表
  - 对所有空字段重新批量输出 `当前项目暂未提供`
- 原因固定为：
  - 这些改动已经由当前用户明确确认
  - 当前目标就是：
    - 页面整洁
    - 行数更少
    - 信息层级更清楚

## 6. 本地执行证据

- 当前修改文件：
  - [project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart)
  - [project_detail_compact_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_detail_compact_widgets.dart)
  - [exhibition_trade_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart)
- 当前已验证命名用例：
  - `showcase project detail keeps business sections and downranks boundary noise`
  - `owner project detail hands off to private continuation surfaces`
  - `project detail keeps demo fallback explicit instead of pretending public detail is connected`
  - `showcase detail keeps public materials read-only while published projects can still continue bid`
  - `showcase keeps converted projects in read-only guidance instead of bid continuation`
  - `public project detail stays fail-closed for owner-private attachments`
  - `project detail consumes shared showcase detail ProjectReadModel fields only`
  - `project detail keeps legacy location names visible when standardized codes are absent`
  - `project detail keeps legacy null address-range fields controlled`

## 7. Formal Conclusion

- 当前 `项目详情` 页正式记为：
  - `hide real-content source notice`
  - `hide public explanation/boundary cards`
  - `compact core info`
  - `merge location and schedule fields`
- 后续若用户要求再次改版，不得只改代码不改文书；至少必须同步更新：
  - 本说明
  - `docs/00_ssot/latest_user_confirmed_change_ledger.md`
