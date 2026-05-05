---
owner: Codex 总控
status: active
purpose: Freeze the Flutter frontend surface for the company display workbench to public detail UI refinement.
layer: L5 Frontend
based_on:
  - docs/00_ssot/company_display_workbench_to_public_detail_ui_chain_truth_freeze_addendum.md
  - docs/00_ssot/company_display_workbench_to_public_detail_ui_chain_stage_gate_checklist_addendum.md
freeze_date_local: 2026-05-05
---

# 《公司展示工作台到公司详情页展示链路 frontend surface》

## 1. Allowed File Boundary

允许修改：

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_*.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_*.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`
- `apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
- `apps/mobile/test/enterprise_hub_trust_repair_stage1_test.dart`
- `apps/mobile/test/exhibition_home_test.dart`

禁止修改：

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- `packages/contracts/**`
- migrations / seeds / cloud deployment artifacts

## 2. Exhibition Home Company Recommendation Card

目标：

- 公司 Tab 下的推荐卡去掉 `优秀公司` badge。
- 推荐卡整卡可点击进入现有公司详情 route。
- 保留名称、简介、必要的地区/认证/案例摘要。
- 保留工厂、供应商现有语义，不因公司卡简化造成回归。

验收：

- 公司推荐卡不出现 `优秀公司` 文案。
- 用户点击卡片任意主体区域即可进入公司详情。
- 不新增假推荐字段。

## 3. Company Workbench Homepage

目标：

- 保留现有 module drill-in，不重写业务表单。
- 首页排序调整为：
  1. 信息完整度
  2. 公司展示预览
  3. 基础信息入口组
  4. 详细信息入口组
  5. 认证与状态
  6. 真实底部操作区
- 工作台继续说明 `preview / current change / live public detail` 的区别。

展示规则：

- 完整度基于 `readiness` 派生，只用于展示。
- 基础信息入口组：展示标识、基础资料、地址与服务区域、企业画册。
- 详细信息入口组：案例展示、联系人、认证与状态。
- 无真实数据看板和无真实动态时不展示。
- 底部操作只使用既有 submit disposition 和 published-change disposition。

## 4. Public Company Detail

目标：

- 页面更像公开展示页，不像工作台。
- 信息顺序为：
  1. Hero：封面/Logo、公司名称、认证 badge、标签、服务区域
  2. 信任背书：地区、认证、服务项目、团队规模或评价摘要
  3. 公司介绍：摘要优先，长文可展开
  4. 地址与服务区域：地区、详细地址、地图卡、服务区域 chips
  5. 核心优势：展会类型、服务项目、最大项目规模、合作方式等真实字段
  6. 案例展示：公开 cases，限制首屏数量
  7. 资质与口碑：公开 certifications / reviewSummary
  8. 基本信息：成立时间、团队规模、主营业务、合作方式
  9. 联系方式：只展示 public detail 返回 contacts

禁止：

- 禁止显示 workbench draft/current change 内部字段。
- 禁止显示 `changeRequestId`、内部审核说明、OCR 内部文案。
- 禁止用 workbench cases 过滤规则替代 public detail cases 真值。

## 5. Visual Rules

- 背景使用极浅暖白。
- 卡片白底、大圆角、轻阴影。
- 品牌金只用于主 CTA、关键状态和核心 icon。
- 技术字段弱化。
- 首页推荐卡、工作台、详情页三者视觉统一，但角色必须不同。
- bottom nav 不得遮挡内容。

## 6. Acceptance Criteria

- BFF / Server / OpenAPI / database / cloud 修改结果必须为否。
- 不新增假数据。
- 不删除现有字段，只重排、折叠、分组、入口化。
- `workbench / preview / public detail` 区分明确。
- 首页推荐卡公司卡不展示 `优秀公司`。
- 公司卡整卡点击进入详情。
- 公司工作台长度明显短于旧长表单。
- 公司详情页按公开展示逻辑重排。
- 联系方式权限保留。
- 案例消费 public detail 返回 cases。
- `flutter analyze` 和相关 widget tests 通过，或明确非本轮失败来源。
