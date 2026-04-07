---
owner: 结果校验 Agent
status: active
purpose: Read-only closure assessment for veto blocker BLK-R0-FILE-LENGTH and its Round 1 admission impact.
layer: L0 SSOT
---

# File Length Governance Blocker Closure Assessment Addendum

## 1. 问题定义

本文件是对 `BLK-R0-FILE-LENGTH` 的只读关闭评估，不包含任何代码修改、拆分、重构、配置变更、迁移、部署或发版动作。

本轮核验范围仅限：
- `AGENTS.md` 与各应用 `AGENTS.md`
- `docs/00_ssot/gate_register_v1.md`
- `docs/00_ssot/project_asset_register_v1.md`
- `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md`
- `docs/00_ssot/round0_inventory_validation_signoff.md`
- `docs/00_ssot/codegen_policy.md`
- `docs/00_ssot/repo_cleanliness_constitution.md`
- `apps/mobile/lib/**`
- `apps/bff/src/**`
- `apps/server/src/**`
- `apps/admin/src/**`

本轮结论先行：
- `BLK-R0-FILE-LENGTH` 当前未关闭，仅完成评估。
- 当前至少存在一组非豁免、无 formal exemption、且混合多重职责的 handwritten business source，仍然构成 Gate 11 veto。
- 当前不允许将 Gate 11 从 veto 降级。

## 2. 规则基线

本轮评估按以下正式规则执行：

| 基线来源 | 只读结论 |
| --- | --- |
| `AGENTS.md` | handwritten business source 默认硬门禁为 `450` 行；默认豁免类仅限 generated code、migrations、generated schema / OpenAPI outputs、fixtures / seeds / mock data、localization copy、route registry files、explicitly registered constant lookup tables。 |
| `apps/mobile/AGENTS.md`、`apps/bff/AGENTS.md`、`apps/server/AGENTS.md`、`apps/admin/AGENTS.md` | 各应用沿用相同 gate，不允许 verbal waiver。 |
| `docs/00_ssot/gate_register_v1.md` | Gate 11 对 handwritten source `>=450` 行、职责混合、未定位 formal exemption 的情形直接判为 veto。 |
| `docs/00_ssot/project_asset_register_v1.md` | `BLK-R0-FILE-LENGTH` 仍登记为 open；formal exemption 暂未定位到。 |
| `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md` | Round 0 exit 时 Gate 11 已被登记为 failed / veto。 |
| `docs/00_ssot/round0_inventory_validation_signoff.md` | 已记录前端存在多份 `>=450` 行 handwritten source，且 formal exemption 未定位。 |
| `docs/00_ssot/codegen_policy.md`、`docs/00_ssot/repo_cleanliness_constitution.md` | 仅文件类别规则已冻结；未发现任何本次超线文件的 file-specific formal exemption truth。 |

统计方法：
- 对 `apps/mobile/lib/**`、`apps/bff/src/**`、`apps/server/src/**`、`apps/admin/src/**` 运行 `wc -l`
- 仅统计 `*.dart`、`*.ts`、`*.tsx`、`*.js`、`*.jsx`
- 统计时间：`2026-04-02`（Asia/Shanghai）

## 3. 超线文件清单

只读统计结果显示，当前命中 `>=450` 行的 handwritten source 共 `20` 个，全部集中在 `apps/mobile` 与 `apps/bff`；`apps/server/src` 与 `apps/admin/src` 当前无命中项。

| 行数 | 所属应用 | 绝对路径 | 豁免类判定 | 当前是否已找到 formal exemption | 当前判定 |
| --- | --- | --- | --- | --- | --- |
| 1166 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart` | 否 | 否 | veto |
| 999 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_creator_page_sections.dart` | 否 | 否 | veto |
| 848 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_creator_pages.dart` | 否 | 否 | veto |
| 837 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_detail_pages.dart` | 否 | 否 | veto |
| 773 | bff | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts` | 否 | 否 | veto |
| 692 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_apply_pages.dart` | 否 | 否 | veto |
| 658 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_draft_search_pages.dart` | 否 | 否 | veto |
| 608 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/forum_consumer_item_parsers.dart` | 否 | 否 | blocker |
| 592 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/data/profile_identity_consumer_layer.dart` | 否 | 否 | blocker |
| 583 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart` | 否 | 否 | blocker |
| 583 | bff | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts` | 否 | 否 | blocker |
| 576 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart` | 否 | 否 | veto |
| 508 | bff | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/forum/forum-command-error.service.ts` | 否 | 否 | blocker |
| 504 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart` | 否 | 否 | blocker |
| 503 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart` | 否 | 否 | blocker |
| 501 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart` | 否 | 否 | blocker |
| 501 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/dev/visual_demo/forum_formal_nav_rollout_demo_app.dart` | 否 | 否 | risk |
| 494 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart` | 候选：route registry file | 否 | risk |
| 463 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/forum_consumer_layer.dart` | 否 | 否 | blocker |
| 451 | mobile | `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_detail_surface_widgets.dart` | 否 | 否 | blocker |

### 前 10 个最大文件的职责判断

1. `enterprise_hub_consumer_layer.dart` 同时承载 DTO / view model、canonical paths、transport wrapper、load / submit / ack 流程与多个企业黄页接口，已明显超出单一 consumer-layer 责任。
2. `forum_creator_page_sections.dart` 在一个 extension 内同时承载发帖页 section 组装、话题选择、媒体预览、临时文件写入与本地打开，混合 UI 与本地 I/O。
3. `forum_creator_pages.dart` 统一管理加载、保存草稿、发布、媒体上传、状态恢复与页面状态机，属于页面控制与上传编排混合。
4. `forum_detail_pages.dart` 将话题详情页、帖子详情页、评论互动、附件打开、点赞收藏等交互堆叠在单文件中，职责混合明显。
5. `enterprise-hub.service.ts` 在同一 BFF service 内承载多条 route contract、聚合转发、payload 成型与错误处理边界，已超出单一端点服务职责。
6. `enterprise_hub_apply_pages.dart` 同时包含申请页、状态页、草稿创建、资料保存、案例创建、提交动作与守卫组件，属于多页面多动作混合。
7. `forum_draft_search_pages.dart` 将草稿页、搜索页、滑删卡片、结果卡片混合在单文件中，既包含页面状态，又包含手势与卡片组件。
8. `forum_consumer_item_parsers.dart` 主要是论坛读取模型解析器族，责任相对单一，但体量过大且未归入任何已登记豁免类。
9. `profile_identity_consumer_layer.dart` 同时放置 canonical paths、view model、组织切换与认证 / 设备 API 调用，属于相对同域但仍过宽的 consumer-layer。
10. `project_create_page.dart` 同时承载项目创建表单、访问守卫、提交流程与 AI hint 交互，尚未达到 route-registry 或 generated 类豁免条件。

## 4. 豁免类与非豁免类区分

本轮对照默认豁免类后的结论如下：

| 豁免类 | 当前命中数 | 结论 |
| --- | --- | --- |
| generated code | 0 | 本轮超线文件均不在 `generated/`，也不含 `*.g.dart`、`*.freezed.dart` 等典型生成物命名。 |
| migrations | 0 | 本轮超线文件均不位于 migration 路径。 |
| generated schema / OpenAPI outputs | 0 | 本轮超线文件均不是 `docs/01_contracts` 投影输出，也不是生成契约文件。 |
| fixtures / seeds / mock data | 0 | `forum_formal_nav_rollout_demo_app.dart` 虽含 fake handler，但当前路径与类别并未被 formal truth 注册为 fixture / mock data。 |
| localization copy | 0 | 无。 |
| route registry files | 1 个候选 | `app_router.dart` 从内容上看确属集中路由注册与分发文件，但当前未找到 file-specific formal exemption truth，因此仍不能视为已关闭。 |
| explicitly registered constant lookup tables | 0 | `forum-command-error.service.ts`、`enterprise-hub.read-model.ts` 都含方法逻辑与转换流程，不属于纯常量查找表。 |

本轮判定：
- 当前 `20` 个超线文件中，只有 `app_router.dart` 具备较强的默认豁免候选属性。
- 其余 `19` 个文件当前均应按非豁免 handwritten source 对待。
- `forum_formal_nav_rollout_demo_app.dart` 虽非 active runtime 主链，但当前 formal truth 未把 `lib/dev/visual_demo/**` 注册为单独治理类别，因此不能直接视为豁免。

## 5. 当前 formal exemption 缺口

本轮未定位到任何一个超线文件的 file-specific formal exemption truth。

已核验到的当前事实：
- `docs/00_ssot/project_asset_register_v1.md` 已明确写明 formal exemption 暂未定位到。
- `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md` 已将 Gate 11 维持在 failed / veto。
- `docs/00_ssot/round0_inventory_validation_signoff.md` 已登记多份前端超线文件，但未把任何一份登记为已豁免。
- `docs/00_ssot/codegen_policy.md` 与 `docs/00_ssot/repo_cleanliness_constitution.md` 只冻结了“可豁免类别规则”，没有把 `app_router.dart` 或其他具体文件登记为已豁免。

因此，本轮 formal exemption 缺口是：
- 缺少 `route registry file` 的 file-specific formal exemption truth。
- 缺少对 dev / visual demo 类 handwritten source 的正式治理口径。
- 缺少对 BFF 纯 mapper / translator 是否可单列治理规则的正式口径；在正式口径出现前，只能按非豁免类处理。

## 6. 候选关闭方案对比

### 方案 A：精准豁免冻结 + 非豁免分阶段治理包

| 项目 | 结论 |
| --- | --- |
| 是否需要新增 formal exemption 文书 | 需要。至少需要把 `app_router.dart` 的 route registry 身份冻结进 formal truth；如未来要给其他文件类别单列规则，也必须先补 formal truth。 |
| 是否需要后续代码拆分 | 需要。除 `app_router.dart` 这类高置信度豁免候选外，其余非豁免超线文件仍需后续拆分或职责切片。 |
| 是否影响 active runtime | 当前评估文书不影响 active runtime；后续拆分应限定为 source 结构治理，不允许引入契约漂移。 |
| 是否影响 contracts / docs | 影响 docs；contracts 原则上不应被此类治理直接改写。 |
| 风险等级 | 中 |
| 推荐原因 | 只把真正符合规则的文件纳入豁免，把真正需要拆分的文件留在治理包内，规则最一致，误伤最小。 |
| 不推荐原因 | 需要一次额外的 formal truth 冻结与一次后续治理包安排，流程比“口头放行”更慢。 |

### 方案 B：全量先拆后入场

| 项目 | 结论 |
| --- | --- |
| 是否需要新增 formal exemption 文书 | 可选；若不使用任何豁免，formal exemption 可不新增。 |
| 是否需要后续代码拆分 | 需要，而且是对全部 `20` 个超线文件统一拆分。 |
| 是否影响 active runtime | 高于方案 A；触达面大，容易引入页面、BFF 聚合或 parser 回归。 |
| 是否影响 contracts / docs | docs 仍需更新治理状态；contracts 原则上不应变化，但大规模拆分更容易误触实现边界。 |
| 风险等级 | 高 |
| 推荐原因 | 规则最“干净”，关闭后不再依赖豁免。 |
| 不推荐原因 | 对 Round 1 节奏冲击最大，且会把 route registry 候选与 dev/demo 文件也纳入统一拆分，性价比偏低。 |

### 方案 C：全量 formal exemption 冻结后直接降级 Gate 11

| 项目 | 结论 |
| --- | --- |
| 是否需要新增 formal exemption 文书 | 需要，而且需要为大量并不符合默认豁免类的文件新增例外。 |
| 是否需要后续代码拆分 | 不需要。 |
| 是否影响 active runtime | 表面不影响，但会把结构性问题直接固化。 |
| 是否影响 contracts / docs | docs 会被大量“例外化”，formal truth 可信度下降。 |
| 风险等级 | 极高 |
| 推荐原因 | 无。 |
| 不推荐原因 | 这会把真正的多职责超线文件直接洗白，违反 Gate 11 的本意。 |

## 7. 唯一推荐方案

唯一推荐方案：`方案 A：精准豁免冻结 + 非豁免分阶段治理包`

推荐口径如下：
- 第一步，只冻结高置信度合法豁免候选。当前仅建议把 `app_router.dart` 作为 `route registry file` 候选进入 formal truth 评审，不建议对其他超线文件批量发放豁免。
- 第二步，把其余非豁免超线文件纳入后续治理包，按“页面编排 / shared widget / consumer parser / BFF service / BFF read-model”分组，逐步做责任切片。
- 第三步，治理包完成后重新跑 line-count 核验；仅当非豁免 handwritten source 全部回到 `450` 以下，且已登记豁免类文件具有 formal truth，才允许关闭 `BLK-R0-FILE-LENGTH`。

该方案优于其他方案的原因：
- 它不把“route registry”与“明显多职责业务源文件”混为一谈。
- 它不把文书补丁当作结构治理替代品。
- 它保留了后续 Round 1 之前的真问题清单，避免先降级再返工。

## 8. 不允许采用的方案

以下方案不允许采用：
- 口头豁免或聊天回执豁免。任何 exemption 都必须进入 formal truth。
- 先把 Gate 11 从 veto 降级，再回头治理。顺序错误。
- 把 `infra` 样例、历史回执、旧结论当作当前 formal exemption 证据。
- 对 `forum-command-error.service.ts`、`enterprise-hub.read-model.ts` 这类含逻辑文件强行按“constant lookup table”洗白。
- 对 `forum_formal_nav_rollout_demo_app.dart` 直接以“不是 active runtime”为由跳过治理，而不补 formal truth 或不做后续缩减。

## 9. 关闭验收条件

`BLK-R0-FILE-LENGTH` 未来若要被判定为已关闭，至少应同时满足以下条件：
- 重新统计后，不再存在任何未登记豁免的 handwritten business source `>=450` 行。
- 每一份被视为豁免的文件，都已在 formal truth 中登记具体文件或具体文件类、owner、理由、适用边界和单独治理规则。
- 不存在用机械拆分掩盖责任混合的情形。
- `docs/00_ssot/project_asset_register_v1.md`、阶段门禁核查表与独立签收文书三者口径一致。
- 结果校验角色完成二次只读复核并重新签收。

## 10. 对 Round 1 准入的影响

当前对 Round 1 admission 的判定如下：

### 当前 `BLK-R0-FILE-LENGTH` 是否已关闭

结论：未关闭，仅完成评估。

### 当前哪些文件是真正的 veto 来源

高置信度 veto 来源如下：
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_creator_page_sections.dart`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_creator_pages.dart`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_detail_pages.dart`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_apply_pages.dart`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_draft_search_pages.dart`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart`

这些文件共同特征是：
- 非豁免 handwritten source
- formal exemption 未找到
- 体量显著超线
- 已可见多职责混合

### 当前哪些超线项只是治理风险

本轮更接近治理风险、但尚不足以单独构成“可放行”依据的项目：
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart`
  - 原因：内容上高度接近 route registry file，但 formal truth 尚未冻结。
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/dev/visual_demo/forum_formal_nav_rollout_demo_app.dart`
  - 原因：更像 dev/demo 支撑文件，不在 active runtime 主链，但当前仍不属于已登记豁免类。

### 当前是否允许总控把 Gate 11 从 veto 降级

结论：不允许。

原因如下：
- 非豁免 handwritten source 超线项并非只剩“候选豁免文件”，而是仍有多份 active runtime 文件构成高置信度 veto。
- 当前 formal exemption truth 仍未补齐。
- `project_asset_register_v1.md`、Round 0 exit checklist 与既有 signoff 目前都把 Gate 11 保持在 failed / veto。

### 对 Round 1 admission 的直接影响

结论：当前不满足将 Gate 11 降级后放行 Round 1 的条件。

## 11. 修订记录

| 日期 | 动作 | 说明 |
| --- | --- | --- |
| 2026-04-02 | 新增 | 结果校验 Agent 基于只读统计、规则对照与 formal exemption 搜索，首次形成 `BLK-R0-FILE-LENGTH` 关闭评估文书。 |
