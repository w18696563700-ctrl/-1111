---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the current bid-submit follow-up ruling for project-material preview
  permission diagnosis, nine-grid template download presentation, and natural
  language platform service fee copy, including bidder attachment list-only
  visibility, fixed bid validity options, service-fee field trimming, and
  account-binding exclusion, without changing backend permission truth or
  payment truth in this round.
layer: L0 SSOT
freeze_date_local: 2026-04-27
based_on:
  - AGENTS.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/00_ssot/exhibition_bid_submit_full_version_truth_freeze_addendum.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/04_frontend/project_attachment_prepublish_and_bid_materials_frontend_surface_addendum.md
  - docs/04_frontend/exhibition_bid_submit_template_download_and_uniform_attachment_cards_frontend_surface_addendum.md
---

# 《竞标提交页材料权限、模板九宫格与平台服务费文案 ruling》

## 1. 当前最小闭环

- 竞标提交页继续保持：
  - 项目附件只读清单
  - 报价与方案说明
  - 三份必传竞标文档
  - 模板下载区
  - 平台服务费规则确认与预授权扩展位
- 本轮 bidder 侧附件最小闭环只到：
  - 展示 `effect_image / construction_doc` 附件清单
  - 展示文件名、类型、数量、只读状态或不可预览提示
  - 不展示预览入口
  - 不触发 `file/access`
- 本轮报价有效期最小闭环固定为用户可选项：
  - `12 小时`
  - `24 小时`
  - `36 小时`
  - `48 小时`
  - `60 小时`
  - `72 小时`
- 新报价默认值为：
  - `48 小时`

## 2. 项目附件预览权限诊断

- 当前 `GET /api/app/project/bid-materials` 可以让竞标方读取：
  - `effect_image`
  - `construction_doc`
  的只读列表投影。
- 当前点击预览实际复用：
  - `GET /api/app/file/access`
- 当前 Server `file/access` 对项目附件仍按 owner-private 规则判断：
  - 必须已登录
  - 当前组织必须等于项目发布方组织
  - 当前组织必须具备该项目 owner scope
  - `FileAsset` 必须绑定到同一项目、同一发布方组织、`fileKind=project_attachment`
- 因此当前竞标方能看到列表，但不一定能打开附件。
- 本轮只冻结诊断结论，不直接放宽 BFF / Server 权限。
- 本轮正式裁决为：
  - 竞标方当前只展示附件清单
  - 竞标方当前不显示预览入口
  - 竞标方当前不显示“打开 / 查看 / 预览 / 下载原文件”等会暗示已获授权的 CTA
  - Flutter 不用隐藏入口的方式伪装权限已解决
  - Flutter 不绕过 BFF 直连 Server 或对象存储
- 若要允许竞标方预览，需要后续单独冻结：
  - bid-material 专用访问规则
  - project state / bidder eligibility / owner relation 的权限边界
  - 对应 L2/L3/L4 合同与后端实现

## 3. 模板下载九宫格

- 竞标提交页 `模板下载区` 改为三列网格。
- 当前 3 个模板入口先占第一行：
  - 合同模板
  - 流程图与说明
  - 公共资料
- 后续新增模板资源时，继续按每行 3 个自动换行。
- 当前不新增新的模板 contract category。
- 当前不把模板区扩成公共资料中心、编辑器或上传入口。

## 4. 平台服务费用户可理解命名

- `P0-Pay` 只作为内部工程名、文书索引名和阶段代号保留。
- Flutter 用户界面不得把板块标题、按钮或提示直接写成：
  - `P0-Pay`
  - `P0 Pay`
  - `竞标服务费`
  - `报名费`
  - `席位费`
  - `保证金`
- 用户可见命名统一使用：
  - `平台成交服务费确认`
  - `平台服务费说明`
  - `平台服务费规则`
  - `平台服务费预授权`
  - `预计平台服务费`
- 平台服务费板块当前用途用自然语言解释为：
  - 在工厂提交明价竞标报价时，提前确认平台服务费规则。
  - 当前不是报名费、占位费，也不是马上扣款。
  - 未中标时预授权释放。
  - 中标并完成合同确认后，才按最终成交金额计算并扣取平台服务费。
- Flutter 只展示说明、提交报价、拉起通道预授权、读取 BFF/Server 状态。
- Flutter 不本地生成资金真相，不保存支付账户，不做钱包或资金池。

## 5. 报价有效期固定选项

- `报价有效期` 本轮不再使用自由输入。
- 固定选项为：
  - `12 小时`
  - `24 小时`
  - `36 小时`
  - `48 小时`
  - `60 小时`
  - `72 小时`
- 默认选中：
  - `48 小时`
- Flutter 提交时仍按既有合同字段 `quoteValidUntil` 表达，不新增新的后端枚举真相。
- Flutter 不新增：
  - 自定义小时数
  - 日期时间选择器
  - 后台可配置有效期规则
  - BFF / Server 规则改造

## 6. 支付账户绑定排除

- 支付账户绑定不进入本轮。
- 当前不得新增：
  - 支付宝账户绑定
  - 微信账户绑定
  - 银行卡绑定
  - 默认支付账户
  - 账户管理页
  - 长期自动扣款授权
- 本轮只保留订单级支付 / 订单级预授权 handoff。
- 若支付通道需要用户确认，用户在外部合规支付通道内完成，不在平台内保存支付账户真相。

## 7. 服务费区字段裁剪与按钮文案

- 服务费区本轮只展示以下必要字段：
  - `本次报价`
  - `平台服务费率`
  - `预计平台服务费`
  - `费用说明`
  - `确认项`
  - 当前可用 `支付通道` 或通道不可用提示
- 服务费区不得展示：
  - `authorizationId`
  - 商户订单号
  - 支付 / 授权订单号
  - 回调地址
  - `channelPayload`
  - 账户绑定入口
  - 资金状态机内部码
  - BFF / Server 调试字段
- 用户可见按钮文案固定为：
  - 主提交按钮：`确认服务费规则并继续提交`
  - 需要跳转支付通道时：`去支付通道确认预授权`
  - 预授权处理中：`等待支付通道确认`
  - 已预授权：`已确认平台服务费预授权`
  - 通道不可用：`支付通道暂不可用`
- 按钮文案不得写成：
  - `P0-Pay`
  - `扣款`
  - `缴费报名`
  - `支付报名费`
  - `提交保证金`

## 8. 需要保留但暂不开通

- 需要保留但本轮暂不开通：
  - bid-material 专用附件预览权限
  - 竞标方附件下载原文件
  - 支付账户绑定
  - 通用支付中心
  - 钱包 / 余额 / 金币 / 资金池
  - 履约保证金
  - 服务费率会员分层
  - 后台配置报价有效期选项

## 9. 后续扩展位

- 后续若开放竞标方附件预览，必须先补齐：
  - L0 权限 ruling
  - L2 contract
  - L3 Server permission truth
  - L4 BFF surface
  - L5 Flutter preview surface
- 后续若开放支付账户绑定，必须单独冻结：
  - 合规支付通道能力
  - 账户授权范围
  - 数据保存边界
  - 解绑、失效、风控和审计规则
- 后续若开放报价有效期配置，必须明确：
  - Server 是否拥有规则真相
  - BFF 是否只做投影
  - Flutter 是否只消费可选项

## 10. 哪个更稳 / 更省成本 / 更适合当前阶段

- 更稳：先把模板区改为三列网格，把平台服务费文案讲清楚；附件预览权限只做诊断，不直接放权。
- 更省成本：只改 Flutter 展示密度、有效期选项和说明文案，不改 BFF / Server 权限。
- 更适合当前阶段：模板区九宫格 + 平台服务费人话说明 + 报价有效期固定选项 + 竞标方附件清单只读。
- 风险更大：未经 L2/L3/L4 冻结，直接把 owner-private 附件访问放给所有竞标方。
- 风险更大：把支付账户绑定、钱包、资金池或通用支付中心塞进本轮。

## 11. Formal Conclusion

- 当前正式冻结为：
  - 附件预览失败原因是 `file/access` owner-private 权限边界
  - 本轮不改 BFF / Server 权限
  - 本轮不开放竞标方附件预览
  - 竞标方当前只展示附件清单，不显示预览入口
  - 模板下载区改三列九宫格承接
  - `P0-Pay` 在用户界面改为平台服务费用户可理解命名
  - 报价有效期固定为 `12/24/36/48/60/72 小时`，默认 `48 小时`
  - 支付账户绑定不进入本轮
  - 服务费区裁剪为用户必要字段，按钮使用平台服务费规则和预授权语义
