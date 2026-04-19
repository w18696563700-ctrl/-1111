---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-side company-detail de-duplication patch and the home enterprise-module sync rule without reopening BFF or Server scope.
layer: L3 Frontend
freeze_date_local: 2026-04-18
inputs_canonical:
  - AGENTS.md
  - docs/04_frontend/enterprise_detail_surface_relayout_and_map_minimal_frontend_truth_note.md
  - docs/04_frontend/enterprise_display_album_and_target_enterprise_info_frontend_surface_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page_sections.dart
---

# 公司样本首屏去重与首页三卡同步 Frontend Addendum

## 1. Scope

- 本轮只覆盖：
  - `公司详情`
  - 首页六模块入口中的：
    - `优秀公司`
    - `优秀工厂`
    - `优秀供应商`
- 本轮不覆盖：
  - BFF `home/modules` 真值改写
  - Server 首页模块文案改写
  - 工厂详情与供应商详情主骨架重做

## 2. 公司详情主轴调整

- `公司详情` 当前正式主轴改为：
  - `公司样本封面`
  - `地址与服务区域`
  - `资质与口碑`
  - `案例展示`
  - `详细介绍`
  - `联系方式`
- `公司样本封面` 内直接承接：
  - `公司名`
  - `地区`
  - `认证`
  - `服务项目`
- 上述主信息当前统一浮于封面图之上，不再落回封面下方白色摘要块。
- 当前 `公司详情` 封面摘要固定只保留 `3` 个 pill：
  - `地区`
  - `认证`
  - `服务项目`
- 这 `3` 个 pill 当前只展示值本身，不再展示 `地区 / 认证 / 服务项目` 字段名。
- `项目规模` 当前不再出现在公司详情封面 pill 中。
- 这 `3` 个 pill 必须固定单排，并压在封面图最底边的安全区内。

## 3. 公司详情去重规则

- 当前 `公司详情` 不再额外保留独立 `核心能力` 大卡。
- 原 `核心能力` 中公司板块字段必须并回首屏封面层。
- `企业画册` 在 `公司详情` 中不再默认作为第二个主信息块重复首屏职责。
- `公司详情` 的 `企业画册` 正式定义为首屏顶部图片本身。
- 当前前端不再为 `公司详情` 额外渲染独立 `企业画册` 区。
- 首屏顶部图片同时承担：
  - 公司样本封面
  - 企业画册主视觉
- 原首屏下方白色公司摘要块当前对 `公司详情` 隐藏，不再重复承载标题、摘要或能力标签。
- 原顶部 `优秀公司` badge 对 `公司详情` 隐藏。

## 4. 工厂与供应商保持规则

- `工厂详情`
  - 继续保留独立 `核心能力`
  - 继续保留独立 `企业画册`
- `供应商详情`
  - 继续保留独立 `核心能力`
  - 继续保留独立 `企业画册`

## 5. 首页三卡同步规则

- 首页六模块入口中的：
  - `优秀公司`
  - `优秀工厂`
  - `优秀供应商`
  必须由同一套前端配置驱动。
- 同步范围固定为：
  - 卡片阅读顺序
  - 卡片结构框架
  - status label
  - action label
  - 云端 projection 消费路径
  - 本地 fallback 策略
- 三张卡必须保持同一阅读节奏：
  - 状态
  - 标题
  - 简述
  - 动作
- 三张卡不得被做成完全同文案、同字段的机械复制。
- 差异化只允许来自类型本身：
  - 标题
  - 云端 summary
  - 动作去向
- 当前前端不得继续以三段手写实例化方式分别渲染这三张卡。
- `项目展示`
  - 继续保留高亮特例
- `展览论坛`
  - 继续保留独立入口卡
- `优秀团队员工`
  - 继续保留占位卡

## 6. Cloud Boundary

- 当前首页三卡仍只读消费 `GET /api/app/exhibition/home` 返回的 `modules[]`。
- Flutter 只负责：
  - 统一结构
  - 统一 fallback
  - 统一渲染配置
- Flutter 不得本轮自行改写云端模块语义为另一套真值。

## 7. Anti-revert

- 后续线程不得把 `公司详情` 再改回：
  - 首屏摘要和 `核心能力` 同时重复展示 `服务项目 / 项目规模`
  - 首屏封面与下方大图画册共同承担同一主信息职责
- 后续线程不得把首页三卡再拆回三段独立手写卡片实例。
