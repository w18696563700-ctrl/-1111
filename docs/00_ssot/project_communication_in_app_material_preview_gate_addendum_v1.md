---
owner: Codex 总控
status: frozen
purpose: Freeze in-app preview and confirmation gate for project communication material reviews.
layer: L0 SSOT
freeze_scope: Project communication material preview UX and confirmation gate only
---

# 《项目沟通资料 App 内嵌预览与确认门禁 Addendum V1》

## 1. 总裁决

五份发布方报价依据资料与三份竞标资料在提交确认前，必须先完成 App 内预览。

`OpenFilex`、系统文件打开、浏览器打开、外部下载、分享面板或文件管理器打开，均不得被计为本 Addendum 中的“App 内预览成功”。这些能力可以作为后续下载 / 保存 / 外部查看 fallback，但不得解锁“确认无误”。

本 Addendum 只冻结资料确认页的预览成功定义、确认门禁和失败提示；不修改项目创建到发布主链路、不修改上传三步流、不扩展支付、预授权、BidAward、Order / Contract seed、最终合同金额确认。

## 2. 当前最小闭环

| 资料范围 | 数量 | 入口 | 真值 owner | 本轮裁决 |
|---|---:|---|---|---|
| 发布方报价依据资料 | 5 | 竞标提交页 / 消息楼资料确认 | Server `FileAsset` / `ProjectAttachment` / `project_communication material review` | 必须 App 内预览后才能确认。 |
| 竞标方提交资料 | 3 | 消息楼资料确认 | Server `Bid` / `FileAsset` / `project_communication material review` | 必须 App 内预览后才能确认。 |

五份发布方报价依据资料包括：

| 顺序 | attachmentKind | 展示名 |
|---:|---|---|
| 1 | `effect_image` | 效果图 |
| 2 | `construction_doc` | 尺寸图 / 施工图 |
| 3 | `material_sample` | 材质图 / 材料样板 |
| 4 | `equipment_material_list` | 设备物料清单 |
| 5 | `service_list` | 服务清单 |

## 3. 文件类型 P0 策略

| 文件类型 | P0 App 内预览策略 | 是否可解锁确认 | 说明 |
|---|---|---:|---|
| 图片 `image/*` | 复用现有图片 bytes 加载与 App 内图片弹窗 | 是 | 图片解码成功并展示后才算预览成功。 |
| 文本 `text/*` / `application/json` | App 内文本预览弹窗 | 是 | 文本解码成功并展示后才算预览成功。 |
| DOCX | App 内解析文档正文并展示只读预览 | 是 | 优先复用当前受控 `accessUrl` 下载 bytes，解析失败不得确认。 |
| XLSX | App 内解析工作表文字并展示只读预览 | 是 | 只作为报价依据阅读预览，不提供编辑能力。 |
| PPTX | App 内解析幻灯片文字并展示只读预览 | 是 | 只作为资料文字预览，不提供播放能力。 |
| PDF | 当前无已冻结 Flutter 内嵌 PDF 渲染器时，不得用系统打开计为成功 | 否 | 后续如接入 PDF viewer 或 Server 转图片 / PDF 预览，需要单独裁决。 |
| 其他格式 | 展示不可预览原因 | 否 | 不得因为有下载链接而解锁确认。 |

## 4. 预览成功定义

`previewSucceeded=true` 只能在以下条件满足后成立：

1. Flutter 通过 BFF / Server 返回的受控 `accessUrl` 获取资料 bytes。
2. Flutter 在当前 App 页面、弹层或路由中成功展示内容。
3. 用户明确看到预览内容后关闭或返回。
4. 失败、空文件、无法解析、unsupported mime、外部打开成功、系统下载成功均不得计为成功。

## 5. 确认门禁

| 状态 | 确认按钮 |
|---|---|
| 资料未加载 | 禁用 |
| 资料不可读 | 禁用 |
| 资料可读但未 App 内预览成功 | 禁用，文案为“预览后确认” |
| 全部 sourceFiles 均 App 内预览成功 | 开放，文案为“确认无误” |
| 提交确认成功 | 刷新 Server / BFF projection，以 Server 返回状态变绿 |

Flutter 不得根据本地点击、系统打开回执、下载成功或缓存状态伪造 `confirmed`。

## 6. 分层边界

| 层级 | 裁决 |
|---|---|
| Server | 继续持有 FileAsset、资料确认状态、补充反馈和权限真值。 |
| BFF | 继续透出 file preview access、workbench entries、routeTarget，不创造业务状态。 |
| Flutter | 负责 App 内预览、失败提示、确认门禁和刷新展示。 |
| OpenAPI | 本轮优先不新增字段；现有 `FilePreviewAccessReadModel` 足够表达受控访问 URL、previewType、fallbackReason。 |
| generated | OpenAPI 不变时不生成。 |
| 云端 | 只有 BFF / Server 确实改动时才申请部署；纯 Flutter 改动只需 debug 包 UAT。 |

## 7. No-Go

本轮不得：

- 把系统外部打开计为 App 内预览成功。
- 把下载成功计为 App 内预览成功。
- 把 unsupported mime 计为 App 内预览成功。
- 让 Flutter 本地保存资料确认真值。
- 让 BFF 根据文件名或 mime 猜测业务确认状态。
- 为了预览扩展支付、钱包、保证金、结算、发票或最终合同金额确认。

## 8. 四类判断

| 判断项 | 裁决 |
|---|---|
| 最稳 | Server 后续提供统一转 PDF / 图片预览资源，Flutter 只做内嵌展示。 |
| 最省成本 | 当前阶段先复用受控 `accessUrl` + Flutter bytes 加载，支持图片 / 文本 / Office 文字预览。 |
| 最适合当前阶段 | 先关闭“系统打开也能确认”的 P0 漏洞，PDF 作为明确不可确认状态保留专项。 |
| 风险最大 | 继续用 `OpenFilex` 或外部浏览器打开，并把打开成功当作确认前置。 |
