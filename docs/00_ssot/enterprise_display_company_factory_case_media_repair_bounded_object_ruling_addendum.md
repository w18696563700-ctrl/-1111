---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded maintenance object for enterprise-display company/factory board separation, case-media echo repair, and live route-alignment correction after user-reported runtime defects were reconfirmed from code and tunnel verification.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_hub_v1_reentry_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_company_workbench_and_exhibition_surface_current_state_protection_record_addendum.md
  - docs/00_ssot/enterprise_display_factory_workbench_and_exhibition_surface_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md
  - 用户截图与 2026-04-19 隧道取证结果
---

# 《企业展示 company/factory 串板块与案例媒体回显维修边界裁决单》

## 1. 裁决目的

- 当前正式重开一个新的 bounded maintenance object。
- 当前对象只处理：
  - `company / factory` 公开与私有展示口径混淆
  - case 串板块
  - 工厂案例继续编辑图片不回显
  - `public-cases` live route drift
  - company / factory detail gallery fallback 死链
- 当前对象不等于：
  - 新一轮 enterprise display 扩面
  - 新状态机
  - release-prep
  - production release

## 2. 当前唯一 active bounded object

- 当前唯一 active bounded object 正式锁定为：
  - `enterprise display / company-factory board separation and case-media repair`
- 当前对象覆盖：
  - `docs/**` 真值与合同冻结
  - `apps/server/src/modules/enterprise_hub/**` 真值修复
  - `apps/bff/src/routes/enterprise_hub/**` app-facing route 与 shaping 修复
  - `apps/mobile/lib/features/exhibition/**enterprise_hub**` 消费与兜底修复
  - 对应测试与隧道运行态验证
- 当前对象明确不覆盖：
  - 新 board type
  - 新筛选能力
  - 新地图 contract
  - Admin review 流程重写
  - 第二套 case 发布状态机
  - 非 `enterprise_hub` 对象扩面

## 3. 当前已确认的问题族

### 3.1 命名真值漂移

- 同一工厂在公开列表 / 推荐 / 详情 / workbench 下存在不同展示名来源。
- 当前已确认存在：
  - factory 列表与推荐优先展示公司主体名
  - factory 详情又优先展示 `factoryName`
  - workbench 再优先展示认证主体名
- 当前问题属于：
  - 真值口径不一致
  - 不是单纯文案问题

### 3.2 case 串板块

- 当前 `Server` 多条 case 读取、approved 提升、published-change snapshot / apply 链路只按 `enterpriseId` 收口。
- 当线上历史数据已存在错挂 case 时：
  - 公司 case 会被工厂详情与工厂工作台读到
  - 工厂 case 也可能污染 company 板块

### 3.3 工厂案例继续编辑图片不回显

- 当前 Flutter 继续编辑只要拿不到 `caseImageUrlMap`，就会退成空占位图。
- 当前仓库代码表明：
  - widget 并非不会显示远端图
  - 根因更接近私有 case detail / workbench carrier 未稳定带回 URL map

### 3.4 live route drift

- 当前仓库内已存在：
  - `GET /api/app/exhibition/enterprise-hub/public-cases/{caseId}`
- 但当前 live tunnel 取证显示该 app-facing path 返回 `404`。
- 当前问题被正式定性为：
  - 部署或网关对齐问题
  - 不是“源码中不存在该 route”

### 3.5 detail gallery fallback 死链

- company / factory detail 页面虽然本地已计算 fallback gallery images，
  但：
  - gallery section 当前只对 supplier 开放
  - fallback 参数在 widget 内又被直接丢弃
- 当前问题属于：
  - 前端消费与展示收口缺失
  - 非真值 owner 漂移

## 4. 当前阶段拆分裁决

### 4.1 Stage A

- 当前 stage-A 只负责：
  - SSOT / contract / backend / BFF / Flutter repair scope 冻结
  - runtime evidence 对齐
  - implementation task sheet authoring
- 当前 stage-A 不允许：
  - 绕过 docs 直接改代码
  - 先修线上数据再反推 truth

### 4.2 Stage B

- 当前 stage-B 只负责：
  - `Server` 根修
  - `BFF` route 对齐与 read-model 收口
  - `Flutter` continuation fallback 与展示语义修复
  - 回归测试补强

### 4.3 Stage C

- 当前 stage-C 只负责：
  - 线上数据修复
  - tunnel smoke
  - bounded rollout judgment

## 5. Allowed Directories

- 当前允许：
  - `docs/**`
  - `apps/server/src/modules/enterprise_hub/**`
  - `apps/server/test/enterprise-hub-*.test.cjs`
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/bff/test/enterprise-hub-*.test.cjs`
  - `apps/mobile/lib/features/exhibition/data/enterprise_hub*`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub*`
  - `apps/mobile/test/enterprise_hub*.dart`
- 当前不允许：
  - `enterprise_hub` 之外的业务对象扩面
  - 新建与本次问题无关的跨域基础设施

## 6. Anti-revert

- 不得只改 Flutter 文案来掩盖 `Server` 的 case 串板块问题。
- 不得把 `public-cases` 的 live `404` 解释成“接口本来就没有”。
- 不得继续允许同一企业的异板块 case 被统一快照、统一 apply。
- 不得把工厂标题再次退回公司主体名唯一展示。
- 不得继续把 `caseImageUrlMap = {}` 当作“图片正常为空”的成功态。
- 不得借修复之名引入第二套 case 状态机。

## 7. Formal Conclusion

- 当前 enterprise display 已正式进入：
  - `company-factory board separation and case-media repair`
    bounded maintenance object
- 当前下一步必须先完成：
  - bounded object ruling
  - stage gate checklist
  - contract freeze
  - backend / BFF / frontend scope freeze
- 在上述文书冻结前：
  - 不允许直接进入实现派工

