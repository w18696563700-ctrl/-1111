---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter frontend surface for the bid-submit five-step business
  flow restructuring round.
layer: L5 Frontend
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/bid_submit_five_step_business_flow_ruling_addendum.md
  - docs/04_frontend/bid_submit_template_grid_and_p0_pay_copy_frontend_surface_addendum.md
  - docs/04_frontend/project_attachment_prepublish_and_bid_materials_frontend_surface_addendum.md
  - docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md
---

# 《竞标提交页五步业务流 frontend surface》

## 1. Scope

本文件只覆盖 Flutter `BidSubmitPage` 的页面结构、字段归属、按钮位置、最终提交分流和文案错误态。

本轮不改：

- BFF。
- Server。
- contracts。
- 文件上传三步链路。
- 项目附件预览权限。
- 竞标方材料种类范围。

## 2. Page Section Order

Flutter 页面顺序固定为：

1. `第一步 核对项目`
2. `第二步 查看项目详情材料`
3. `第三步 填写竞标价格与服务费确认`
4. `第四步 上传文档和方案说明`
5. bottom primary action：`提交竞标`

页面不得再出现：

- 两个 `项目附件` 区块。
- `第二步 填写报价与方案说明`。
- 服务费区独立提交按钮。
- 报价区内的 `方案说明` 输入。

## 3. Step One Rendering

`第一步 核对项目`：

- 展示当前项目 detail。
- 用户点击 `继续竞标` 后，后续步骤才展开。
- 展开后核对区折叠成摘要。
- 摘要保留：
  - 核对状态
  - 项目名称
  - 项目编号
  - 当前状态
  - 项目地点
  - 计划时间
  - `重新展开核对`

## 4. Step Two Rendering

`第二步 查看项目详情材料`：

- 只展示竞标方可见材料清单。
- 卡片字段：
  - 文件名
  - 资料类型
  - 文件类型
  - 创建时间
  - `当前阶段仅展示清单，预览尚未开放。`
- 空态：
  - `当前项目还没有开放材料`
- 异常态：
  - `当前项目材料清单暂不可读，请稍后再试。`
- 不展示：
  - 预览图片
  - 预览文书
  - 打开
  - 下载原文件
  - 选择项目附件
  - 上传并形成正式附件
  - 删除当前文书

当前用户可见材料命名：

- `effect_image`：效果图
- `construction_doc`：尺寸图

`材质图` 不在本轮渲染范围。

## 5. Step Three Rendering

`第三步 填写竞标价格与服务费确认`：

- 第一字段为：
  - `竞标报价`
- 服务费确认字段：
  - 平台服务费率
  - 预计平台服务费
  - 报价有效期
  - 三个确认勾选
- 报价有效期固定为：
  - `12小时`
  - `24小时`
  - `36小时`
  - `48小时`
  - `60小时`
  - `72小时`
- 默认值：
  - `48小时`
- 文案必须明确：
  - 页面预计服务费用于理解。
  - 最终金额以平台提交后返回为准。
- 本区不得出现：
  - `方案说明`
  - `工艺说明`
  - `搭建流程`
  - `交付节点`
  - `风险说明`
  - `补充报价附件 ID`
  - `含税 / 含运输 / 含安装`
  - `支付 / 预授权通道`
  - `P0-Pay`
  - 独立提交按钮
- 当前 Flutter 保留既有内部默认值以兼容 P0-Pay 请求体，但不得把这些默认值渲染成第三步用户可操作项。

## 6. Step Four Rendering

`第四步 上传文档和方案说明`：

- 先展示 `方案说明` 输入。
- helper 文案说明：
  - `接单方给发布方的总体方案概述。`
- 再展示模板下载区。
- 再展示三份必传文档：
  - 项目理解
  - 报价表
  - 进度安排
- 上传动作沿用现有 slot 和文件校验。

## 7. Final Submit Rendering

页面底部只保留一个主按钮：

- `提交竞标`

按钮禁用条件：

- 未完成项目核对。
- 竞标报价无效。
- 服务费确认项未勾选。
- 方案说明为空。
- 三份必传文档未确认上传。
- 竞标守卫未通过。

错误文案必须指向用户下一步需要补齐的内容，不得使用技术错误作为主体验。

## 8. Final Submit Routing

Flutter 最终提交采用互斥分流：

- 若当前项目可承接 P0-Pay 明价竞标 route：
  - `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids`
  - `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations`
  - `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init`
  - `GET /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}`
- 否则走兼容提交：
  - `POST /api/app/bid/submit`

Flutter 不得同时触发两条提交链。

## 9. Error Copy

材料清单：

- `项目材料暂不可读`
- `当前项目材料清单暂不可读，请稍后再试。`

报价：

- `请先填写有效的竞标报价。`

服务费确认：

- `请先勾选全部平台服务费确认项。`

方案说明：

- `请先填写方案说明。`

上传文档：

- `请先完成并确认附件：项目理解、报价表、进度安排。`

## 10. Test Expectations

Flutter test 必须覆盖：

- 五步顺序存在。
- `项目附件` 不重复。
- 第二步标题为 `第二步 查看项目详情材料`。
- 材料卡片无预览、打开、下载、上传、删除、绑定入口。
- `方案说明` 位于第四步，不在第三步报价区。
- 服务费区无独立提交按钮。
- 页面底部只有一个 `提交竞标` 主按钮。
- 默认有效期为 `48小时`。
- 最终提交体仍保留既有字段：
  - `quoteValidUntil` for P0-Pay
  - 三份 `FileAsset` id
  - `proposalSummary` / proposal snapshot

## 11. Current Fit

- 更稳：只改 Flutter 结构，不改云上 BFF / Server。
- 更省成本：复用现有 load、upload、submit 和 P0-Pay consumer service。
- 更适合当前阶段：先消除用户看到的业务顺序错误。
- 风险更大：同时打开预览、材质图、Server 预估接口或支付账户绑定。

## 12. Formal Conclusion

Flutter 本轮实现必须按本文件执行。任何把方案说明放回报价区、把服务费确认做成独立提交、重复展示项目附件、或在材料卡片恢复预览入口的实现，均视为回退。
