---
owner: Codex 总控
status: frozen
layer: L0 SSOT
scope: App Visual System V1
---

# App 视觉系统 V1 冻结补充单

## 1. 定位

本文冻结 `展览装修之家 App 视觉系统 V1` 的当前施工边界。

本轮不是全 App 一次性美化，不是业务流程重构，不是路由重构，也不是接口、状态机或云端改造。

V1 只解决：

- 全 App 基础视觉不 low、不杂、不乱。
- 首发可见楼具备统一、克制、干净的基础视觉语言。
- 后续页面迁移有可复用 token、组件和页面模板，不再按页面临时手写样式。

## 2. 当前真实入口冻结

当前首发可见楼冻结为：

- 展览
- 消息
- 我的

当前预埋但不进入首发底部导航的楼冻结为：

- 装修
- 全屋定制

如代码中存在其他实验入口，本轮只允许只读盘点，不得创建新入口、不得主导航化、不得做页面级精修。

## 3. 本轮允许范围

本轮允许：

- 新增或复用 Flutter 前端视觉 token。
- 新增最小共享 UI 组件。
- 冻结首页/频道页、列表页、详情页、表单/状态流页 4 类页面模板。
- 迁移第一批低风险页面：
  - 我的页未登录卡 / 登录页
  - 参与竞标申请 / 项目名称查看申请状态页
  - 项目展示列表页
- 截图、测试和阶段收口记录。

## 4. 本轮禁止范围

本轮禁止：

- 修改 `apps/bff/**`。
- 修改 `apps/server/**`。
- 修改 `docs/01_contracts/openapi.yaml`、接口契约、数据库、状态机。
- 修改业务路由规则。
- 新增假功能、假入口、假状态、假搜索、假通知、假天气数据。
- 对装修、全屋定制等隐藏楼做页面级精修。
- 全局重写 Theme 或一次性迁移所有页面。
- 为了视觉效果隐藏错误、待审批、已拒绝、未登录等真实状态。
- 把 debug ID、技术 ID 放到主视觉区。
- 每个页面自建一套颜色、按钮、卡片、badge。

## 5. V1 Token 命名冻结

颜色 token：

- `pageBackground`
- `cardBackground`
- `brandGold`
- `brandGoldDark`
- `brandGoldLight`
- `textPrimary`
- `textSecondary`
- `textTertiary`
- `borderSoft`
- `warningSoft`
- `successSoft`
- `dangerSoft`

字体 token：

- `pageTitle`
- `sectionTitle`
- `cardTitle`
- `body`
- `bodyStrong`
- `caption`
- `badgeText`
- `buttonText`

间距 token：

- `pagePadding`
- `cardPadding`
- `sectionGap`
- `itemGap`
- `chipGap`

圆角 token：

- `radiusSmall`
- `radiusMedium`
- `radiusLarge`
- `radiusXLarge`
- `radiusPill`

阴影 token：

- `shadowSoft`
- `shadowCard`
- `shadowFloating`

尺寸 token：

- `bottomNavHeight`
- `floatingButtonSize`
- `minTouchTarget`
- `inputHeight`
- `primaryButtonHeight`

## 6. 共享组件边界

V1 共享组件只负责 UI，不负责业务真值。

允许建立：

- `AppPageHeader`
- `AppCard`
- `AppSectionCard`
- `AppPrimaryButton`
- `AppSecondaryButton`
- `AppStatusBadge`
- `AppFilterChip`
- `AppInfoChip`
- `AppEmptyState`
- `AppBottomSafePadding`

以上组件不得：

- 调接口。
- 持有业务状态。
- 内置具体业务文案。
- 修改路由。
- 派生业务权限或状态。

## 7. 页面模板冻结

V1 冻结 4 类页面模板：

- 首页 / 频道页模板：用于展览首页、消息首页、我的首页。
- 列表页模板：用于项目展示、我的项目、企业 / 工厂 / 供应商列表。
- 详情页模板：用于项目详情、企业详情、申请详情、竞标详情。
- 表单 / 状态流页模板：用于登录页、认证页、参与竞标申请、审核状态页。

本轮只迁移第一批 3 个低风险页面；第二批、第三批只作为后续扩展位。

## 8. 第一批迁移门禁

第一批页面迁移必须同时满足：

- 不改 BFF / Server / OpenAPI / DB / 状态机。
- 不改业务路由。
- 不删除现有字段、入口和真实状态。
- 相关截图可验收。
- 相关 Flutter analyze / test 可解释。
- 如全量测试存在历史红灯，必须单独列出并证明不是本轮新增。

## 9. 后续扩展位

保留但本轮不实施：

- 展览首页、项目详情、我的项目页第二批精修。
- 消息楼、企业 / 工厂 / 供应商列表与详情第三批精修。
- Figma token 对齐。
- 截图回归自动化。
- 插画资产库。
- 暗色模式。
- 动效系统。

## 10. Formal Conclusion

`App 视觉系统 V1` 当前只授权 Flutter 前端展示层建立 token、组件和第一批低风险页面迁移。

任何 BFF、Server、contract、OpenAPI、数据库、状态机、云端部署或隐藏楼页面级精修，均不属于本轮授权范围。
