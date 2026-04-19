---
owner: Codex 总控
status: active
purpose: Freeze the stage gate checklist for the bounded round that promotes enterprise location into a first-class truth object with controlled Amap-backed resolve and public detail consumption.
layer: L0 SSOT
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_detail_surface_relayout_and_map_minimal_stage_gate_checklist_addendum.md
  - docs/02_backend/service_boundaries.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
---

# 《企业位置能力 V1 Stage Gate Checklist》

## 1. 当前目标包

- 当前目标包固定为：
  - `企业展示工作台` 新增企业位置能力 V1
  - `当前位置填入`
  - `文字地址解析`
  - `Server` 企业位置真值落库
  - `BFF` app-facing 位置 surface
  - `公司 / 工厂 / 供应商` 公开详情页地图卡与位置展示
- 当前明确不包含：
  - 路线规划
  - 导航
  - 周边搜索
  - 新地图搜索页
  - 多点选址
  - 复杂 POI 管理
  - 项目详情或项目创建的地图扩面

## 2. passed gates

- `真源门禁`：PASS
  - 当前对象、边界、非目标与文书目录均可先在本地 `docs/` 冻结后再实施。
- `架构边界门禁`：PASS
  - 当前仍保持：
    - 前端只在本地开发
    - `BFF` 与 `Server` 只在云端开发
    - `Flutter App -> BFF -> Server` 单链路不变
- `状态机门禁`：PASS WITH CONTROLLED DELTA
  - 本轮允许新增的是企业位置状态字段：
    - `geoStatus`
    - `geoSource`
  - 不允许新增第二套企业展示状态机或地图业务状态机。
- `阶段控制门禁`：PASS
  - 当前目标、非目标、角色边界与 docs-first 顺序可冻结。
- `文件长度与职责门禁`：PASS WITH SPLIT REQUIREMENT
  - 若补高德/地理编码 provider 适配，必须挂在受控 adapter/service，不得把 provider 代码散落进 `enterprise_hub` 读写服务。

## 3. failed gates

- 当前 failed gates 固定为：
  - 工作台现状只有：
    - 详细地址输入
    - `用当前位置回填`
    - 设备定位后的地址文案提示
  - 当前不存在：
    - 企业位置真值对象
    - `latitude / longitude`
    - `districtCode / districtName`
    - `geoSource / geoStatus / lastGeocodedAt`
    - `publicDisplayAddress`
  - 当前公开详情只有：
    - `provinceName`
    - `cityName`
    - `basicInfo.address`
    - `serviceAreas`
  - 当前公开详情不存在：
    - 真实地图卡 carrier
    - 地图静态图 URL
    - 公开详情的坐标真值
  - 当前仓库未提供企业位置专用的高德 / geocode adapter 落点与运行态证据。

## 4. veto gates

- 不得把当前的“详细地址辅助动作”误写成：
  - 已有地图能力
  - 已有企业位置真值
- 不得在本地修改：
  - `apps/bff/**`
  - `apps/server/**`
- 不得让 `BFF` 拥有第二套位置状态机或独立位置真值。
- 不得用：
  - 服务区域
  - 详细地址文本
  伪装成已接通地图。
- 不得在无真实坐标时展示可点击地图卡。
- 不得在 docs-first freeze 前直接开始实现代码。
- 不得把 `platform.map.*` pre-embed 配置投影误报成 end-user 已接通能力。
- 不得把高德控制台上的 `key`、安全配置、签名或密码写入任何文档、日志、口令、回执、脚本与注释。

## 5. stage go / no-go decision

- 当前 gate decision 正式固定为：
  - `Go for docs-first freeze`
  - `Go for enterprise location truth model introduction`
  - `Go for bounded Amap-backed geocode and reverse-geocode integration`
  - `Go for public detail location card and map card implementation`
  - `Conditional Go for cloud implementation only after Amap provider config gate is verified`
  - `No-Go for fake map`
  - `No-Go for deep map capability`
  - `No-Go for widening map to non-enterprise objects`

## 6. 高德控制台门禁

- 当前新增一条显式 provider gate：
  - 必须确认高德开发者控制台是否已有可用 `Web 服务 Key`
  - 若公开详情地图卡采用 provider 静态图或轻量 H5 卡，必须确认对应的前端可用 key / 安全域 / 包名签名条件
- 当前正式结论固定为：
  - 可由总控协助核对所需配置项与接入方式
  - 但控制台登录、验证码、账号授权与密钥创建属于操作者动作
  - 在未看到真实运行态 key/config 前，不得宣称高德已接通

## 7. 当前下一步唯一动作

- 当前下一步唯一动作固定为：
  - `由总控先完成 enterprise location capability V1 的五层冻结文书，再进入云端与前端实施`

## 8. Formal Conclusion

- 当前总控结论固定为：
  - 本轮允许继续推进
  - 但必须先补齐：
    - Stage Gate Checklist
    - L0 truth freeze
    - L2 contract freeze
    - backend truth freeze
    - BFF surface freeze
    - frontend surface freeze
  - 在 provider gate 未验证前：
    - 只允许实现准备与受控链路
    - 不允许把高德对外描述成已完成
