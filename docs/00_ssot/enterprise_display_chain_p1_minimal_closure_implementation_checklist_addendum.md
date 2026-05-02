---
owner: Codex 总控
status: draft
purpose: Freeze the P1 minimal-closure implementation checklist for the enterprise display onboarding chain after truth freeze and contract convergence.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/**
  - apps/bff/src/routes/enterprise_hub/**
  - apps/mobile/lib/features/exhibition/**
---

# 企业展示入驻链 P1 最小闭环实施清单

## 1. P1 目标

- 本轮只做“最小真实闭环”，不做能力扩张。
- P1 完成标准只包括：
  - 工作台可编辑字段不再出现假可编辑
  - 公域列表、详情、首页推荐位的读取口径一致
  - 公域案例数字与公域案例内容口径一致
  - 图片从 `fileAssetId` 到展示投影闭环
  - 公域筛选只保留真实有效项

## 2. P1 非目标

- 不重构为“一个 organization 一条总 listing + 三板块投影”
- 不重写完整生命周期状态机
- 不新增新的企业展示入口
- 不新增新的推荐位策略或排序策略
- 不做 company / factory / supplier 的详情深化
- 不引入新的图片上传体系

## 3. P1 实施项

### 3.1 联系人真实保存闭环

- 目标：
  - workbench 上联系人字段要么真实持久化，要么改成只读
- 推荐实现：
  - 保持当前 UI 可编辑
  - 在基础资料保存链路中补齐联系人字段写入
  - readiness 继续只认持久化结果
- 约束：
  - 不允许再把联系人持久化只绑在 `createApplication`
- 主要影响目录：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
- 验收：
  - 修改联系人并点击保存后，刷新 workbench，联系人值不丢失
  - readiness 的 `hasContact` 与持久化结果一致

### 3.2 公域案例口径统一

- 目标：
  - 列表 `caseCount`、详情案例区、首页摘要统一只反映公域可见案例
- 当前冻结口径：
  - `caseStatus = approved`
- 推荐实现：
  - 统一 server query 层 case 统计和 case 明细过滤条件
  - BFF 与 Flutter 只消费统一投影，不自行补算
- 主要影响目录：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_*`
- 验收：
  - 列表显示的 `caseCount` 与详情可见案例数一致
  - 只有 `approved` 案例进入公域展示

### 3.3 图片展示投影闭环

- 目标：
  - 保持存储真相为 `fileAssetId`
  - 补齐公域 read model 的可展示图片投影
- 推荐实现：
  - 复用当前正式支持的展示字段，不新开第二套 URL 字段命名
  - 由 server presenter 或 server-owned shaping 输出最终展示值
- 约束：
  - Flutter 不得自行拼装图片展示 URL 规则
- 主要影响目录：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_*`
- 验收：
  - logo/封面在 workbench 保存后，刷新仍可展示
  - 公域列表和详情不再长期返回空图片投影

### 3.4 公域筛选去假动作

- 目标：
  - UI 只暴露真实落地的筛选
- 当前最小真实筛选集：
  - `keyword`
  - `provinceCode`
  - `cityCode`
  - `plantAreaRange` for `factory`
- 推荐实现：
  - 优先隐藏或删除未落地筛选
  - 不在 P1 补做大面积后端筛选扩张
- 主要影响目录：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
- 验收：
  - 用户可见筛选项与 server 实际生效筛选完全一致
  - 不再存在“点了但结果不变”的假筛选

### 3.5 公域 published + visible 规则统一核落

- 目标：
  - 首页三板块、列表、详情都只读 `published + visible`
- 推荐实现：
  - 统一核对 query service、presenter、BFF read model、Flutter 页面态
  - 不允许任何一个公域面绕开 listing 可见性规则
- 主要影响目录：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_*`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_*`
- 验收：
  - 已下架或不可见 listing 不进入首页、列表、详情
  - recommendation 只建立在已发布可见 listing 之上

## 4. 实施顺序

1. `Server`
   - 先修 contact persistence
   - 再修 case public projection
   - 再修 media display projection
   - 最后统一 published + visible 读取边界
2. `BFF`
   - 只做聚合对齐、字段透传、假筛选收口
   - 不新增第二状态机
3. `Flutter`
   - 最后做 workbench 保存行为、筛选 UI、图片展示消费对齐
4. 验证
   - 先做接口级核验
   - 再做工作台到公域的手工链路验证

## 5. 验证清单

- 联系人保存验证：
  - 新建申请后修改联系人并保存
  - 刷新 workbench
  - 检查联系人值与 readiness 是否一致
- 案例公域验证：
  - 新建 `draft` 案例时，列表 `caseCount` 不得虚增
  - 案例改为 `approved` 后，列表与详情同时可见
- 图片投影验证：
  - 保存 logo/封面
  - 刷新 workbench、列表、详情
  - 三处展示结果一致
- 筛选验证：
  - 逐项验证当前最小真实筛选集
  - 不存在无效筛选残留
- 发布可见性验证：
  - `published + visible` 出现在首页/列表/详情
  - 非该状态的 listing 不得进入任一公域面

## 6. 阶段门禁核查表

- 阶段目标：
  - 企业展示入驻链 P1 最小闭环修复
- 允许目录：
  - `docs/00_ssot/**`
  - `docs/01_contracts/**` 仅在确有 contract 漏项时补丁
  - `apps/server/src/modules/enterprise_hub/**`
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/mobile/lib/features/exhibition/**`

### 6.1 已通过门禁

- 真源门禁：已通过
  - 单一冻结文书、contract、generated owner 已收口
- 架构边界门禁：已通过
  - 本轮仍保持 Flutter -> BFF -> Server
- 契约门禁：已通过
  - `workbench.boardType` 与 delete case contract 已对齐
- 阶段控制门禁：已通过
  - 本轮目标、非目标、允许目录明确

### 6.2 当前未过但非 veto 项

- 文件长度与职责门禁：待实现时逐文件复核
- 审计门禁：本轮默认不新增高风险动作；若改动触达审核/发布命令，再单独复核

### 6.3 一票否决项

- 若实现过程中引入新的 contract 字段但未先补 `docs/01_contracts/openapi.yaml`
- 若 `BFF` 开始自持业务状态或业务真相
- 若 Flutter 直接拼接图片 truth 或绕开 `BFF`
- 若把未落地筛选继续留在可见 UI

### 6.4 阶段结论

- 当前阶段判断：
  - `Go for P1 minimal closure implementation`
- 前提：
  - 严格限定在本单范围内
  - 不引入新的 truth 扩张
  - 遇到 contract 新增时先停回 contract 层
