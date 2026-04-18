---
owner: Codex 总控
status: active
purpose: Freeze the frontend implementation dispatch prompt for the current factory-detail remediation round so local Flutter execution stays inside the bounded hero deduplication, summary, capability-layout, and copy-fix scope.
layer: L0 SSOT
freeze_date_local: 2026-04-18
based_on:
  - docs/00_ssot/factory_detail_optimization_remediation_dispatch_bundle_addendum_v1_1.md
  - docs/04_frontend/factory_detail_optimization_remediation_frontend_surface_addendum_v1_1.md
  - docs/03_bff/factory_detail_optimization_remediation_bff_surface_addendum_v1_1.md
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
---

# 《工厂详情优化修复 frontend implementation dispatch V1.1》

## 当前唯一动作

- 发给 `前端 Agent` 的唯一执行口令如下。

```text
你是前端 Agent（仅本地），本轮不是重做整套企业详情系统，而是只闭合《工厂详情优化修复》在 Flutter 侧已经冻结好的最小消费与展示范围。

【一、唯一目标】
你这轮只完成 8 件事：
1. 让工厂详情 Hero 对齐公司同类 overlay 结构。
2. 让正文独立“企业画册”区块隐藏。
3. 让 Hero 图源按冻结优先级消费：
   - showcaseImageUrls
   - visualGallery.albumImageUrls
   - fallback
4. 让首屏底部安全区只展示：
   - 地区
   - 认证
   - 厂房面积
   - 团队规模
5. 让首屏四指标按缺值规则自动重排，不留空卡槽。
6. 让页面内彻底移除“月产能”。
7. 让核心能力改成双列：
   - 左列：工艺类型 + 核心产品
   - 右列：设备清单
8. 让资质摘要去掉英文状态词，让 cases=[] 空态显示“暂无公开案例”。

【二、强制阅读】
- docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
- docs/04_frontend/factory_detail_optimization_remediation_frontend_surface_addendum_v1_1.md
- docs/03_bff/factory_detail_optimization_remediation_bff_surface_addendum_v1_1.md
- docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart

【三、只允许处理的范围】
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart
- apps/mobile/test/** 中证明本轮闭环所必需的最小测试

【四、禁止事项】
- 不得改 apps/bff/**
- 不得改 apps/server/**
- 不得重做公司详情 / 供应商详情
- 不得本地硬修地区文本
- 不得直接把 fileAssetId 当 imageUrl
- 不得把 cases=[] 写成“暂未接通”
- 不得为了对齐保留无意义空指标卡槽
- 不得扩到无关路由与无关模块

【五、必须落实的前端真义】
1. Hero 去重
- 首屏已经承接主视觉职责
- 正文不得再重复渲染独立企业画册
- 图下白卡不得再重复承接首屏摘要

2. Hero 图源
- showcaseImageUrls 有值时，必须优先使用 showcase
- 仅当 showcaseImageUrls 无值时，才允许回退到 album
- 仅当 showcase 与 album 都无值时，才允许 fallback
- 不得自行拼接临时图片地址

3. 首屏四指标
- 只允许：
  - 地区
  - 认证
  - 厂房面积
  - 团队规模
- 无值时隐藏并自动重排
- 不得显示“暂未补充”占位文案

4. 月产能
- 页面内任何位置都不得再出现“月产能”

5. 核心能力
- 双列结构必须成立
- 设备清单必须每列 3 个，超过后横向扩列
- 不得退化回单列长列表或流式乱排

6. 文案
- “营业执照 · approved” 这类英文尾巴必须消失
- cases=[] 时显示“暂无公开案例”

【六、测试要求】
- 至少补最小必要测试，证明：
1. 工厂详情正文不再出现独立企业画册
2. 工厂 Hero 出现 overlay 结构
3. 页面内不再出现月产能
4. 首屏四指标缺值时自动重排
5. 设备清单按每列 3 个横向扩列
6. cases=[] 时显示“暂无公开案例”

【七、回执要求】
回执至少包含：
1. 当前对象
2. 修改文件清单
3. Hero 图源当前实际消费情况
4. 去重 / 四指标 / 核心能力 / 文案各自如何收口
5. analyze / test 结果
6. 当前剩余非前端阻断项
7. 是否可移交结果校验 Agent
```
