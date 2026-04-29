---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-only presentation refinement for bid-submit template
  downloads, bidder material list-only rendering, fixed bid validity options,
  and user-readable platform service fee copy.
layer: L5 Frontend
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/bid_submit_material_access_template_grid_p0_pay_copy_ruling_addendum.md
  - docs/04_frontend/exhibition_bid_submit_template_download_and_uniform_attachment_cards_frontend_surface_addendum.md
  - docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md
---

## Pricing Override Note

本文件继续保留竞标提交页模板下载区、只读材料卡片和用户可读文案的页面结构价值。

但自 [platform_pricing_frontend_consumption_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md) 生效后，本文件不再拥有收费真源 authority。

当前正式补充冻结如下：

1. 用户文案即使不再显示 `P0-Pay`，也不得继续以内层旧 `P0-Pay` 真源驱动当前收费主链
2. 当前不得再把 `平台服务费率 / 预计服务费 / 旧预授权语义` 写成现行收费文案
3. 当前收费主线的文案与 CTA 只以 `platform_pricing_frontend_consumption_master_v1.md` 为准

# 《竞标提交页模板九宫格与平台服务费人话说明 frontend surface》

## 1. Scope

- 本文件只覆盖 Flutter `BidSubmitPage` 展示。
- 本文件不改：
  - `GET /api/app/file/access`
  - `GET /api/app/project/bid-materials`
  - `POST /api/app/bid/submit`
  - P0-Pay BFF / Server route family
- 本轮不开放：
  - 竞标方附件预览
  - 竞标方附件下载原文件
  - 支付账户绑定
  - BFF / Server 权限变更

## 2. Bidder Material List-only Rendering

- `项目附件` 在竞标方提交页只展示清单。
- 当前只读清单允许显示：
  - 附件类型：`效果图` / `施工图`
  - 文件名或资料标题
  - 文件数量
  - 只读标记
  - 无法预览时的受控提示
- 当前不得显示：
  - `预览`
  - `打开`
  - `查看原图`
  - `查看文件`
  - `下载原文件`
  - 任何会触发 `GET /api/app/file/access` 的入口
- 若 BFF 返回附件投影但 `file/access` 对竞标方仍不可用，Flutter 只显示清单和受控提示，不弹出失败预览、不伪装成网络错误。
- Flutter 不做本地权限猜测，不直连 Server，不直连 OSS objectKey。

## 3. Template Download Rendering

- `模板下载区` 在手机、平板、桌面都按三列网格渲染。
- 当前 3 个入口为第一行。
- 后续模板资源增加时，每行 3 个继续换行，形成九宫格承接。
- 单个入口必须保持紧凑：
  - 图标
  - 类别名
  - 当前资料标题或空态
  - 下载状态

## 4. Bid Validity Rendering

- `报价有效期` 使用固定选项控件，不使用自由输入框。
- 固定选项为：
  - `12 小时`
  - `24 小时`
  - `36 小时`
  - `48 小时`
  - `60 小时`
  - `72 小时`
- 新报价默认选中：
  - `48 小时`
- Flutter 提交时继续使用既有 `quoteValidUntil` 字段，不新增本地枚举真相。
- 当前不得增加：
  - 自定义有效期
  - 日期时间选择器
  - 后台可配置入口
  - 超出上述范围的隐藏选项

## 5. Platform Service Fee Copy Rendering

- 用户界面不显示 `P0-Pay` 作为板块名称、按钮名或状态名。
- 用户界面统一使用用户可理解命名：
  - `平台成交服务费确认`
  - `平台服务费说明`
  - `平台服务费规则`
  - `平台服务费预授权`
  - `预计平台服务费`
- 平台服务费顶部说明必须避免工程词堆叠。
- 说明应让用户直接理解：
  - 这是平台服务费规则确认
  - 当前不立即扣款
  - 未中标释放
  - 中标并合同确认后才按最终成交金额扣取
- 仍保留必要字段：
  - 报价有效期
  - 含税 / 含运输 / 含安装
  - 支付 / 预授权通道
  - 三项确认勾选

## 6. Service Fee Area Field Trimming

- 服务费区只展示用户完成当前动作所需的信息：
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
  - 内部状态机代码
  - 调试 JSON
  - 支付账户绑定入口
- 支付账户绑定不进入本轮：
  - 不展示绑定支付宝
  - 不展示绑定微信
  - 不展示绑定银行卡
  - 不展示默认支付账户
  - 不展示账户管理跳转
- 支付通道只作为本次订单级预授权 handoff，不保存或暗示平台已绑定用户支付账户。

## 7. Button Copy

- 主提交按钮：
  - `确认服务费规则并继续提交`
- 需要跳转支付通道时：
  - `去支付通道确认预授权`
- 预授权处理中：
  - `等待支付通道确认`
- 已预授权：
  - `已确认平台服务费预授权`
- 通道不可用：
  - `支付通道暂不可用`
- 按钮不得写成：
  - `P0-Pay`
  - `立即扣款`
  - `缴费报名`
  - `支付报名费`
  - `提交保证金`

## 8. Current Minimum Loop

- 当前 Flutter 最小闭环是：
  - 竞标方看见项目附件清单但没有预览入口
  - 填写报价和方案
  - 报价有效期从固定选项中选择，默认 `48 小时`
  - 上传三份必传竞标文档
  - 下载模板资料
  - 阅读并确认平台服务费规则
  - 按 BFF 返回状态进入本次订单级预授权 handoff

## 9. Keep But Do Not Open

- 保留但本轮不开通：
  - bidder 附件预览
  - bidder 附件原文件下载
  - 支付账户绑定
  - 钱包 / 余额 / 金币 / 资金池
  - 通用支付中心
  - 服务费率会员分层
  - 报价有效期后台配置

## 10. Later Extension Slots

- 后续若开放附件预览，Flutter 只能消费新冻结的 BFF projection，不得复用 owner-private `file/access` 入口强开。
- 后续若开放支付账户绑定，必须等 L0/L2/L3/L4 合规边界冻结后再进入 L5。
- 后续若有效期由 Server 配置，Flutter 只消费 BFF 返回选项，不本地生成规则真相。

## 11. Stability / Cost / Stage Fit

- 更稳：当前只显示附件清单，不展示预览入口，不改 BFF / Server 权限。
- 更省成本：只调整 Flutter 展示、选项和文案，继续沿用既有提交字段。
- 更适合当前阶段：附件清单只读 + 模板九宫格 + 有效期固定选项 + 平台服务费人话说明。
- 风险更大：直接开放竞标方预览、加入支付账户绑定，或把 P0-Pay 扩成通用支付中心。

## 12. Formal Conclusion

- 当前 Flutter surface 正式固定为：
  - 竞标方项目附件只展示清单，不显示预览入口
  - 模板下载区三列九宫格
  - `P0-Pay` 不作为用户可见名称，改用平台服务费用户可理解命名
  - 报价有效期固定为 `12/24/36/48/60/72 小时`，默认 `48 小时`
  - 支付账户绑定不进入本轮
  - 服务费区字段裁剪为用户必要信息
  - 按钮文案使用提交报价、确认服务费规则和支付通道预授权语义
  - 不改变后端权限和支付真相
