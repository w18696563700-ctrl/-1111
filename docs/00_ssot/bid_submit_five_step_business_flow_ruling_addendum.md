---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bid-submit five-step business flow ruling for the current
  Flutter-only restructuring round, including project review, bidder material
  list, quote and platform service fee confirmation, proposal package upload,
  and final unified bid submission.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/00_ssot/bid_submit_material_access_template_grid_p0_pay_copy_ruling_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/04_frontend/bid_submit_template_grid_and_p0_pay_copy_frontend_surface_addendum.md
---

# 《竞标提交页五步业务流 ruling》

## 0. 结论

竞标提交页本轮正式重排为五步业务流：

1. `第一步 核对项目`
2. `第二步 查看项目详情材料`
3. `第三步 填写竞标价格与服务费确认`
4. `第四步 上传文档和方案说明`
5. `最后 提交竞标`

本轮只改 Flutter 展示和提交入口编排，不改 BFF / Server 权限、合同、状态机或持久化。

## 1. 当前最小闭环

当前最小闭环是：

1. 竞标方从项目详情进入竞标提交页。
2. Flutter 读取并展示项目核心信息，用户先核对项目。
3. 用户确认后，Flutter 读取竞标方可见材料清单。
4. 用户填写竞标价格，并阅读平台成交服务费说明。
5. Flutter 基于当前报价展示预计服务费提示，但最终服务费金额以后端提交后返回的 `platformServiceFeeRequirement` 为准。
6. 用户填写方案说明并上传三份必传文档。
7. 页面只保留一个最终提交动作。
8. 若当前项目具备 P0-Pay 明价竞标任务承接，则最终提交走 P0-Pay fixed-price bid route family；否则保持既有 `POST /api/app/bid/submit` 兼容路径。

## 2. 五步职责冻结

### 2.1 第一步：核对项目

- 只负责确认当前项目是否无误。
- 读取链路：
  - Flutter：`BidSubmitPage`
  - BFF：`GET /api/app/project/detail?projectId={projectId}`
  - Server：`GET /server/projects/{projectId}`
- 展示内容：
  - 项目名称
  - 项目编号
  - 当前状态
  - 地点
  - 计划时间
  - 预算 / 范围 / 说明等当前 detail 已返回字段
- 核对完成后折叠成确认摘要，不再占用后续步骤主体空间。

### 2.2 第二步：查看项目详情材料

- 只负责展示当前对竞标方开放的项目材料清单。
- 读取链路：
  - Flutter：`ProjectBidMaterialLoadService`
  - BFF：`GET /api/app/project/bid-materials?projectId={projectId}`
  - Server：`GET /server/projects/{projectId}/bid-materials`
- 当前 Server 可见范围只包含：
  - `effect_image`
  - `construction_doc`
- 当前不得把 `other_material` / 材质图加入竞标方材料清单。
- 当前不得展示：
  - 预览
  - 打开
  - 下载原文件
  - 上传
  - 删除
  - 绑定
- 当前不得调用：
  - `GET /api/app/file/access`

### 2.3 第三步：填写竞标价格与服务费确认

- 只负责：
  - 填写竞标报价
  - 选择报价有效期
  - 展示预计平台成交服务费
  - 展示平台服务费规则说明
  - 勾选三项服务费确认
- 报价有效期固定为：
  - `12 小时`
  - `24 小时`
  - `36 小时`
  - `48 小时`
  - `60 小时`
  - `72 小时`
- 默认值为：
  - `48 小时`
- Flutter 可以按 `quoteAmount * 3%` 展示前端预计服务费，用于用户理解。
- 最终服务费金额以 Server 在 P0-Pay fixed-price bid 提交后返回的 `platformServiceFeeRequirement.estimatedFeeAmount` 为准。
- 当前第三步不展示支付 / 预授权通道选择，不展示含税 / 含运输 / 含安装开关；Flutter 仅保留既有内部默认值兼容现有 P0-Pay 合同字段。
- 本步骤不得出现独立提交按钮，不得在中途创建 bid 或拉起预授权。

### 2.4 第四步：上传文档和方案说明

- 只负责接单方提交给发布方的完整方案包。
- `方案说明` 归属本步骤。
- `方案说明` 定义为：
  - 接单方给发布方的总体方案概述。
- 三份必传文档：
  - `项目理解`
  - `报价表`
  - `进度安排`
- 上传链路继续保持：
  - `POST /api/app/file/upload/init`
  - direct upload to object storage
  - `POST /api/app/file/upload/confirm`
- `FileAsset` 仍只是上传资产真相，最终竞标材料由提交 route 绑定。

### 2.5 最后：提交竞标

- 页面只保留一个最终主提交按钮：
  - `提交竞标`
- 当前不得同时出现：
  - 服务费区独立提交按钮
  - 页面底部提交按钮
- P0-Pay 明价竞标链路：
  - `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids`
  - `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations`
  - `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init`
  - `GET /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}`
- 兼容竞标提交链路：
  - `POST /api/app/bid/submit`
- Flutter 只做互斥分流，不本地生成资金真相。

## 3. 本轮不改内容

本轮不改：

- BFF 权限。
- Server 权限。
- `GET /api/app/file/access`。
- `GET /server/projects/{projectId}/bid-materials` 的附件种类范围。
- P0-Pay 合同字段。
- `POST /api/app/bid/submit` 合同字段。
- 文件上传三步链路。
- 支付账户绑定。
- 钱包 / 余额 / 资金池 / 通用支付中心。

## 4. 材质图边界

- 用户语言里的 `材质图` 当前不得直接等同于后端 `other_material` 对竞标方开放。
- 当前 Server `bid-materials` 只开放 `effect_image / construction_doc`。
- 若要让竞标方看到材质图，必须另开 `bid-material kind expansion`：
  - L0 ruling
  - L2 contract
  - L3 Server truth
  - L4 BFF surface
  - L5 Flutter surface

## 5. 服务费真相边界

- Flutter 可以展示前端预计服务费，用于用户理解。
- Flutter 预计值不是收费真相。
- Server 返回的 `platformServiceFeeRequirement` 才是本次提交后服务费预授权金额真相。
- 支付 / 预授权订单、状态、释放、扣取均由 Server 持有。
- BFF 只做 app-facing shaping、auth consolidation、错误归一和转发。

## 6. 需要保留但暂不开通

- 竞标方附件预览。
- 竞标方附件下载原文件。
- 材质图纳入竞标方材料清单。
- Server 提交前权威服务费预估接口。
- 支付账户绑定。
- 钱包 / 余额 / 通用支付中心。

## 7. 后续扩展位

- `bid-material access`：竞标方附件预览。
- `bid-material kind expansion`：材质图是否开放给竞标方。
- `service-fee estimate`：提交前由 Server 返回权威预计服务费。
- `payment account binding`：企业支付账户绑定。

## 8. 哪个更稳 / 更省成本 / 更适合当前阶段

- 更稳：只重排 Flutter 五步结构，不改 BFF / Server 权限和合同。
- 更省成本：复用现有 `project/detail`、`project/bid-materials`、upload、P0-Pay fixed-price bid 和旧 bid submit route。
- 更适合当前阶段：先消除页面业务顺序错误、重复材料区和中途提交误导。
- 风险更大：本轮同时开放附件预览、材质图、Server 预估接口或支付账户绑定。

## 9. Formal Decision

当前正式裁决：

- `竞标提交页五步业务流` 进入 Flutter-only 重排。
- 本轮不改 BFF / Server。
- 本轮不开放附件预览。
- 本轮不把材质图纳入竞标方材料范围。
- 服务费最终金额以 Server 返回为准。
- 服务费区不再有独立提交按钮。
- 页面最终只保留一个 `提交竞标` 主动作。
