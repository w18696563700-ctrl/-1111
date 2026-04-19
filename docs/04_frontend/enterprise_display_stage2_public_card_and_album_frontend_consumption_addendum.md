---
owner: Codex 总控
status: frozen
purpose: Freeze the frontend consumption patch for stage-2 so company public cards consume serviceItems and render a credit placeholder while the workbench keeps using the cloud-backed album carrier.
layer: L4 Frontend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/04_frontend/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
  - docs/01_contracts/enterprise_display_stage2_public_card_and_album_contract_freeze_addendum.md
  - docs/03_bff/enterprise_display_stage2_public_card_and_album_bff_surface_addendum.md
  - apps/mobile/lib/features/exhibition/data/**
  - apps/mobile/lib/features/exhibition/presentation/**
---

# 企业展示 Stage 2 公域卡片与画册补链 Frontend Consumption 冻结单

## 1. Scope

- 当前 frontend freeze 只补：
  - company 公域列表卡片消费切换
  - workbench album 基础回读 continuity
- 当前不补：
  - 详情页整体重排
  - 新信用系统
  - release-prep

## 2. Company Public Card Rule

- company 公域列表卡片当前主消费结果固定为：
  - Logo
  - 企业名称
  - 省市
  - 展会类型
  - 服务项目
  - 信用评分占位
- 当前 company 卡片不得再把：
  - `serviceCities`
  - `avgScore`
  - `caseCount`
  作为底部主摘要的默认替代。

## 3. Credit Placeholder Rule

- 当前 company 卡片必须明确渲染：
  - `信用评分：建设中`
  - 或等价文案
- 当前不得：
  - 显示 `0 分`
  - 把评论均分文案伪装成信用评分

## 4. Workbench Album Rule

- 当前 Flutter workbench 继续消费：
  - `basic.albumImageFileAssetIds`
- 当前若云端已补链完成：
  - 前端不得保留“仅本地结构占位”语义
- 当前若云端仍缺字段：
  - 前端必须受控失败，不得静默吞掉 critical field drift

## 5. Formal Conclusion

- 当前 stage-2 frontend 消费正式固定为：
  - company list card 改为消费 `serviceItems`
  - company list card 渲染信用评分占位
  - workbench 继续正式消费 cloud-backed `albumImageFileAssetIds`
