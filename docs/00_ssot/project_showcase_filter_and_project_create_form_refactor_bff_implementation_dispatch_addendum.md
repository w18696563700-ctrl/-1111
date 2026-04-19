---
owner: Codex 总控
status: active
purpose: Freeze the BFF implementation dispatch prompt for the project showcase filter and project create form refactor object so app-facing transport closes only the frozen dual-field create forward, list-filter handoff, and public expiry-unavailable shaping.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_backend_implementation_dispatch_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目展示筛选与创建表单重构 BFF implementation dispatch》

## 当前阶段

- 主对象：
  - `项目展示筛选与创建表单重构`
- 子阶段：
  - `bounded implementation dispatch / BFF`
- 当前只允许处理：
  - `project/create` 的 dual-field app-facing forward
  - `project/list` 的筛选 query handoff
  - `project/detail` 的 public expiry unavailable 承接

## 当前唯一动作

- 发给 `BFF Agent` 的唯一执行口令如下。

```text
你是 BFF Agent（仅云端），本轮不是重开 project 相关全量实现，而是只闭合《项目展示筛选与创建表单重构》在 BFF 侧已经冻结好的最小 transport / shaping 范围。

【一、唯一目标】
你这轮只完成 4 件事：
1. 让 `POST /api/app/project/create` 正确透传：
   - `exhibitionName`
   - `brandName`
   - `title`
   并同时支持：
   - `dual-field mode`
   - `legacy-title mode`
2. 让 `GET /api/app/project/list` 正确透传：
   - `provinceCode`
   - `cityCode`
   - `areaBucket`
   - `budgetBucket`
3. 让 `GET /api/app/project/detail` 正确承接 backend 已实现的：
   - dual-field detail
   - expired public continuation unavailable
4. 确保 formal `80/8080` chain 上：
   - `project/create`
   - `project/list`
   - `project/detail`
   的 app-facing 运行态稳定

【二、强制阅读】
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
- docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
- docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
- docs/01_contracts/openapi.yaml

【三、当前已知后端闭合事实】
后端 Agent 已确认：
- `project.exhibition_name / project.brand_name` 已落库
- Server create 已支持：
  - dual-field mode
  - legacy-title mode
- Server list 已支持：
  - `provinceCode / cityCode / areaBucket / budgetBucket`
- public `project/list` 已按 `planned_end_at` trimming
- expired public continuation `project/detail` 已返回受控 `404 AUTH_RESOURCE_UNAVAILABLE`

当前已知 BFF 剩余阻断：
- `/api/app/project/create` 仍截断 `exhibitionName / brandName`
- `/api/app/project/list` 仍截断 `provinceCode / cityCode / areaBucket / budgetBucket`
- 当前 `exhibition-bff.service` 运行态仍需以本轮真实 smoke 为准，不得拿旧成功回执冒充

【四、只允许处理的范围】
- apps/bff/src/routes/project/**
- apps/bff/src/core/** 中与 project route transport / auth context / error shaping 直接相关的最小 supporting touch
- 让当前 `apps/bff` build / formal runtime 对 project route family 恢复稳定所必需的最小 supporting fix

【五、禁止事项】
- 不得新增新 `/api/app/*` path family
- 不得改 `my_project` route family
- 不得改 workbench route family
- 不得新增第二套筛选真义
- 不得新增第二套过期状态机
- 不得在 BFF 本地伪造：
  - `exhibitionName`
  - `brandName`
  - `areaBucket`
  - `budgetBucket`
- 不得把企业所在地改写成项目落地城市
- 不得扩到附件公开、审核状态机、交易后链

【六、必须落实的 app-facing 真义】
1. `POST /api/app/project/create`
- 必须放行两种模式：
  - dual-field mode
  - legacy-title mode
- dual-field mode 下必须向 Server 透传：
  - `exhibitionName`
  - `brandName`
  - `title`
- legacy-title mode 下继续允许只传：
  - `title`
- 不得放行：
  - 只传 `exhibitionName`
  - 只传 `brandName`

2. `GET /api/app/project/list`
- 必须透传：
  - `provinceCode`
  - `cityCode`
  - `areaBucket`
  - `budgetBucket`
- 当调用方未显式给出城市 query 时，允许承接既有当前城市上下文
- 但不得新增：
  - `cityContextSource`
  - `nationalMode`
  - 任何新的 app-facing location meta schema

3. `GET /api/app/project/detail`
- 必须承接 backend 返回：
  - `exhibitionName`
  - `brandName`
  - `plannedStartAt`
  - `plannedEndAt`
  - `title` fallback
- 当 public continuation 命中过期项目时：
  - 必须保留受控 unavailable 语义
- 不得把过期 unavailable 偷转成正常 `200`

【七、完成标准】
- `apps/bff` build 通过
- formal `80/8080` chain 上：
  - `/api/app/project/create` dual-field mode 成功透传到 Server
  - `/api/app/project/create` legacy-title mode 继续成功
  - `/api/app/project/list` 能按四个 query 做过滤
  - `/api/app/project/detail` 能承接 expired unavailable
- 不再存在：
  - BFF 截断 dual-field payload
  - BFF 截断 filter query

【八、回执要求】
回执必须单独落盘，并给出云端绝对路径。回执至少包含：
1. 当前对象
2. 修改文件清单
3. build 命令与结果
4. `create / list / detail` 的 formal chain smoke 结果
5. dual-field mode 与 legacy-title mode 的 app-facing 样本说明
6. filtered list 的 app-facing 样本说明
7. expired detail unavailable 的 app-facing 样本说明
8. 当前剩余阻断项
9. 是否可移交 `前端 Agent`

【九、输出禁令】
- 不要写“应该可以”
- 不要把 Server 已闭合偷写成 BFF 已闭合
- 不要改 `my_project`
- 不要新增接口
- 只给真实代码修改与真实 smoke 结果
```

