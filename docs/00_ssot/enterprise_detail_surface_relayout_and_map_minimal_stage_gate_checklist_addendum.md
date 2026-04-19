---
owner: Codex 总控
status: active
purpose: Freeze the stage gate checklist for the bounded round that upgrades company/factory/supplier detail pages into a unified, higher-signal detail surface while keeping map as a minimal truth-only feasibility object.
layer: L0 SSOT
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/00_ssot/enterprise_display_album_layout_and_target_enterprise_info_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_hub_v1_implementation_unlock_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
---

# 《企业详情页重排与最小地图判定 Stage Gate Checklist》

## 1. 当前目标包

- 当前目标包固定为：
  - `公司 / 工厂 / 供应商详情页` 的统一 IA 重排
  - 首屏层级与模块节奏升级
  - 地址可信与服务范围的展示增强
  - 地图能力的最小可行性判定
- 当前明确不包含：
  - 新的企业认证链路
  - 新的入驻工作台链路
  - 新的产品管理系统
  - 新的相册上传体系
  - 新的 IM / 收藏 / 分享 / 在线询价主流程
  - 新的地图业务系统
  - 目标企业正式信息查看链路扩面

## 2. passed gates

- `真源门禁`：PASS
  - 当前边界、目标和非目标可先在本地 `docs/` 冻结后再实施。
- `架构边界门禁`：PASS
  - 本轮仍保持：
    - 前端只在本地开发
    - `BFF` 与后端只在云端开发
    - `Flutter App -> BFF -> Server` 单链路不变
- `契约门禁`：PASS WITH NO CONTRACT DELTA
  - 当前 detail read surface 已有：
    - `header`
    - `basicInfo`
    - `boardProfile`
    - `serviceAreas`
    - `cases`
    - `certifications`
    - `reviewSummary`
    - `contacts`
  - 本轮不新造 app-facing path、不追加新字段作为前端实施前提。
- `状态机门禁`：PASS
  - 本轮不新增任何企业展示状态机、认证状态机、地图状态机。
- `前端体验门禁`：PASS
  - 当前问题明确属于 IA 和视觉层级不足，不需要靠 fake success 或 debug path 掩盖后端缺口。
- `阶段控制门禁`：PASS
  - 当前目标、非目标、角色边界和推进顺序均可冻结。

## 3. failed gates

- 当前 failed gates 固定为：
  - 现有详情页虽然已有 `hero / 画册 / 能力 / 案例 / 联系方式` 雏形，但整体仍偏字段卡片堆叠，未达到成熟详情页的阅读效率和成交感。
  - 现有首屏没有把：
    - 企业是什么
    - 擅长什么
    - 在哪里
    - 规模如何
    - 为什么可信
    作为第一时间信息优先级清晰呈现。
  - 现有公开 read chain 没有企业级经纬度或公开地图 path：
    - 已见 `province / city / address / serviceAreas`
    - 未见 detail-facing `lat / lng / mapUrl / mapSnapshot`
  - 现有“查看企业信息”入口属于另一条已冻结对象，不能混入本轮作为地图或详情升级的依赖前提。

## 4. veto gates

- 不得把：
  - 参考 App 的业务语义
  - 工厂专属 CTA
  - 竞品字段分组
  直接照抄进当前详情页。
- 不得把入驻工作台字段顺序直接当作详情展示顺序。
- 不得在本地修改：
  - `apps/bff/**`
  - `apps/server/**`
- 不得因为用户提到地图，就把 `platform.map.*` pre-embed 误写成已接通 end-user 功能。
- 不得伪造：
  - 地图跳转
  - 经纬度
  - 地图静态图
  - 外部地图 URL
- 不得把“查看企业信息”或其他旧 blocker 偷混为本轮目标。
- 不得借本轮删除现有 detail read 真值、列表链路或企业展示主入口。

## 5. stage go / no-go decision

- 当前 gate decision 正式固定为：
  - `Go for docs-first freeze`
  - `Go for bounded frontend detail-surface relayout`
  - `Go for address-and-service-area prominence upgrade`
  - `Go for formal map feasibility judgment`
  - `No-Go for deep map capability`
  - `No-Go for new backend/BFF truth requirement in this round`
  - `No-Go for target-enterprise formal-info expansion in this round`

## 6. 当前下一步唯一动作

- 当前下一步唯一动作固定为：
  - `由总控先冻结前端 IA / 模块映射 / 地图判定文书，再实施本地前端改版`

## 7. Formal Conclusion

- 当前总控结论固定为：
  - 本轮可以继续推进
  - 但范围必须锁定为：
    - 详情页结构重排
    - 视觉层级升级
    - 地址与服务范围增强
    - 地图能力正式判定
  - 本轮不是地图功能解锁轮
  - 本轮不是目标企业正式信息扩面轮
  - 任何“真地图已接通”的表述都必须以独立运行态证据为前提；在没有该证据前，只能记为 `未接通`
