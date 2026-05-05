---
owner: Codex 总控
status: frozen
layer: L0 SSOT addendum
recorded_at_local: 2026-05-03
scope: My project detail prepublish todo workbench UI refine
---

# 我的项目详情：预发布待办工作台 UI 精修冻结单

## 1. 总裁决

本轮裁决为 `Pass for Flutter display-layer refine only`。

本轮只允许把 `我的项目详情（预发布补资料并发布页）` 从多张长卡片堆叠，收敛成更短的 `发布前待办工作台`。本轮不改变业务真相，不改变接口合同，不改变云端运行形态。

## 2. 本轮最小闭环

| 项目 | 冻结结论 |
| --- | --- |
| 页面对象 | `我的项目详情（预发布补资料并发布页）` |
| 路由对象 | 继续使用现有 `MyProjectDetailPage` 和现有项目详情入口 |
| 主施工层 | Flutter 展示层 |
| 目标体验 | 顶部摘要更短，发布进度轻量化，诚意金、报价依据资料、发布确认合并为发布前待办，长说明默认折叠，公共资源默认折叠 |
| 不变能力 | 项目详情读取、定价/诚意金读取、诚意金继续处理、附件上传三步流、正式附件绑定、正式附件查看/删除、公共资源读取/下载、发布动作 |

## 3. 本轮不做事项

| 不做事项 | 冻结原因 |
| --- | --- |
| 不改 BFF | BFF 只读确认，不新增聚合字段，不新增 route，不裁剪业务真相 |
| 不改 Server | Server 继续作为项目状态、诚意金状态、附件、公共资源、发布动作唯一真相 |
| 不改 OpenAPI / contracts | 现有合同已覆盖本轮读写能力，本轮只是展示层重排 |
| 不改数据库 | 不新增字段、不迁移、不修改业务数据 |
| 不改状态机 | `draft / submitted / published / active / archived` 等状态解释继续沿用现有代码和合同 |
| 不新增假状态 | 不制造 `待确认`、`已满足`、`待处理` 等后端没有承载的新业务状态 |
| 不新增假资料 | checklist 只能根据真实附件列表派生 |
| 不新增假发布能力 | 底部 CTA 只能调用现有发布 / 诚意金 / 附件入口 |
| 不删除功能 | 只允许重排、合并、弱化、折叠、分组 |

## 4. 字段真源表

| 展示项 | 真源 | 前端允许动作 |
| --- | --- | --- |
| 项目名称 | `GET /api/app/my/projects/{projectId}` -> `publicProject.title` | 只展示 |
| 项目编号 | `GET /api/app/my/projects/{projectId}` -> `publicProject.projectNo` | 只展示 |
| 当前阶段 | `GET /api/app/my/projects/{projectId}` -> `publicProject.state`，前端使用既有阶段映射 | 只展示 |
| 待处理事项摘要 | 当前项目阶段、诚意金状态、附件完整度的展示层派生 | 只生成提示文案，不写回 |
| 诚意金金额 | `GET /api/app/project/{projectId}/pricing-summary` -> `publisherPricing.authenticitySincerityAmount` 或诚意金对象 amount | 只展示 |
| 诚意金状态 | `pricing-summary` -> `authenticitySincerityStatus / publishGateStatus / orderStatus / status` | 只展示和决定现有按钮显隐 |
| 诚意金继续处理 | 现有 create order / pay-init / order status 读写链路 | 只复用现有 action |
| 报价依据资料列表 | `GET /api/app/my/projects/{projectId}/attachments` -> `attachments[]` | 只展示、查看、删除、刷新 |
| 报价依据资料分类 | `attachments[].attachmentKind` | 只按 V1 五类归组 |
| 报价依据资料上传 | init -> direct upload -> confirm -> `POST /api/app/my/projects/{projectId}/attachments` | 不绕过三步流 |
| 公共资源列表 | `GET /api/app/project/public-resources` -> `resources[]` | 只展示和分类计数 |
| 公共资源下载 | 现有 public resource download file-access 链路 | 只复用真实链接 |
| 发布动作 | `POST /api/app/project/publish` | 只在现有允许状态下调用 |

## 5. 展示层派生规则

| 派生项 | 冻结规则 |
| --- | --- |
| 报价依据资料总数 | 固定为 V1 五类：效果图、尺寸图 / 施工图、材质图 / 材料样板、设备物料清单、服务清单 |
| 已补充数量 | 按真实 `attachments[].attachmentKind` 去重后命中的 V1 分类数计算 |
| checklist 状态 | 命中真实附件分类显示 `已上传`；未命中显示 `待补充` |
| checklist 操作 | 已上传只能展示真实查看入口；未上传展示真实添加入口 |
| “更换” | 如无真实替换 route 或替换 action，不显示为主能力，降级为 `查看 / 添加` |
| 公共资源数量 | 只能按真实 `resources[]` 的 `resourceCategory` 分组计数 |
| 发布确认状态 | 只能由当前状态、诚意金是否满足、报价依据资料是否满足组合派生 |
| 底部 CTA | 优先级：诚意金未处理 -> 继续处理诚意金；必传效果图缺失 -> 补充报价依据资料；现有发布门禁满足 -> 检查无误，提交发布；状态读取不足或条件不满足 -> 置灰并提示缺失项 |
| 五类资料未满 | 展示为 `建议继续补齐`，不得把 5/5 伪造成后端发布门禁；现有发布动作仍按既有真实校验执行 |

## 6. UI 收敛边界

| 区块 | 本轮处理 |
| --- | --- |
| 顶部项目摘要 | 只展示项目名称、项目编号、当前阶段、待处理事项摘要、展开全部信息 |
| 发布进度 | 保留五步，只作为状态提示，不铺长说明 |
| 项目真实性诚意金 | 进入 `发布前待办`；真实状态保留；规则说明默认折叠 |
| 当前阶段动作 | 合并或弱化到 `发布前待办`，不再独立占用主视觉 |
| 报价依据资料 | checklist 化，保留上传、查看、删除、刷新能力 |
| 空状态 | 合并为一张 `暂无报价依据资料` 空态 |
| 公共资源下载区 | 默认只展示分类摘要，展开后展示真实下载卡 |
| 底部 CTA | 按真实状态动态显示，不固定写 `资料已补齐，提交发布` |

## 7. 验收标准

1. 只修改 Flutter 展示层和本冻结文书。
2. 不修改 BFF、Server、OpenAPI、数据库、状态机。
3. 不新增 mock 数据、不新增接口字段、不新增假状态。
4. 诚意金规则、上传三步流、公共资源下载规则不变。
5. checklist 数量和状态只来自真实附件数据。
6. 公共资源数量只来自真实公共资源列表。
7. 折叠内容仍可展开查看。
8. 底部 CTA 不遮挡、不替代真实发布逻辑。
9. `flutter analyze` 无本轮新增问题，相关测试通过或清楚标注既有问题。
10. 标准宽度与窄屏截图能证明页面更短、更清晰。

## 8. No-Go 条件

| 条件 | 处理 |
| --- | --- |
| 真实字段不足以支撑展示项 | 降级为现有字段展示，不造字段 |
| SSOT 与代码状态冲突 | 停止实现，输出修正文书建议 |
| 发布动作需要新增后端能力 | 停止在解锁建议，不在本轮施工 |
| 公共资源或附件真实列表不可用 | 只展示真实空态或读取失败态 |

## 9. 进入下一天判断

本冻结单通过后，允许进入第 2 天 Flutter 展示层最小改造。BFF、Server、contracts、数据库、云端写操作仍保持锁定。
