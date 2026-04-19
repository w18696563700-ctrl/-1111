# enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum

## 1. 目的

本附录冻结 `2026-04-19` 通过阿里云线上主机只读核查得到的真实运行态结论，用于关闭以下争议：

- `public-cases` 线上 `404` 是网关问题还是发布包问题
- `company/factory` 案例是否真的发生了跨板块错挂
- 工厂工作台“继续编辑”案例图片不回显是前端问题还是私有读链缺字段
- 公司详情案例为空到底是展示串板块，还是业务状态尚未进入公开面

本附录只记录事实，不替代修复实施单。

## 2. 云端运行态事实

### 2.1 进程与端口

- 云端主机可直连，主机名为 `iZ2vcby8q8surr2okzyepzZ`。
- `nginx` 监听 `0.0.0.0:80`。
- 活跃 `Server` 进程监听 `0.0.0.0:3001`。
- 活跃 `BFF` 进程监听 `0.0.0.0:3000`。

### 2.2 活跃发布目录

- 活跃 `Server` 运行目录：
  `/srv/releases/server/20260419013125-enterprise-hub-case-repair-r1`
- 活跃 `BFF` 运行目录：
  `/srv/releases/bff/20260418235914-factory-detail-optimization-remediation/apps/bff`

### 2.3 线上 `public-cases` 路由结论

直接在线上主机核查得到：

- `curl http://127.0.0.1:3000/api/app/exhibition/enterprise-hub/public-cases/{caseId}` 返回 `404 Cannot GET ...`
- `curl http://127.0.0.1:3001/server/exhibition/enterprise-hub/public-cases/{caseId}` 返回 `404 Cannot GET ...`

进一步在活跃发布目录内核对源码与编译产物：

- 活跃 `BFF` 发布目录只包含 `cases/:caseId`，不包含 `public-cases/:caseId`
- 活跃 `Server` 发布目录只包含 `cases/:caseId`，不包含 `public-cases/:caseId`

结论：

- 当前生产 `404` 不是单纯 `nginx` 转发错误
- 当前生产 `404` 的直接根因是活跃 `BFF/Server` 发布包都没有带上 `public-cases` 路由
- 本地仓库源码与当前线上活跃发布包仍然存在 runtime drift

## 3. 私有案例详情读链事实

活跃 `Server` 发布目录中的
[enterprise-hub-case-continuation.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.query.service.ts:1)
对应线上旧发布实现，经只读核查确认其 `getCaseDetail(caseId)` 返回字段为：

- `caseId`
- `enterpriseId`
- `boardType`
- `title`
- `exhibitionType`
- `city`
- `eventTime`
- `summary`
- `caseCoverFileAssetId`
- `caseMediaFileAssetIds`
- `isFeatured`
- `caseStatus`

线上旧实现没有返回 `caseImageUrlMap`。

同时，活跃 `BFF` 发布目录的
[enterprise-hub.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts:190)
与 service 侧仍然按合同透传 `caseImageUrlMap`。

结论：

- 工厂工作台“继续编辑”案例图片不回显的直接根因在 `Server` 私有案例详情旧发布包
- 不是 `BFF` read-model 主动丢字段
- 不是 `Flutter` 图片控件本身无法显示远程图

## 4. 线上库表与真值事实

### 4.1 enterprise_hub 相关主表

在线上数据库中确认存在：

- `enterprise_listing`
- `enterprise_application`
- `enterprise_case`
- `enterprise_change_request`
- `enterprise_profile_company`
- `enterprise_profile_factory`
- `enterprise_profile_supplier`
- `file_asset`

### 4.2 串板块硬脏数据结论

只读核查 SQL：

```sql
select count(*)
from enterprise_case c
join enterprise_listing l on l.id = c.enterprise_id
where c.board_type is distinct from l.primary_board_type;
```

结果：

- `mismatch_count = 0`

结论：

- 当前线上数据库中，不存在 `enterprise_case.board_type != enterprise_listing.primary_board_type` 的硬串板块真值
- “公司案例直接挂到了工厂 listing” 这一说法，按 `2026-04-19` 线上库表真值不成立

### 4.3 图片真值完整性

只读核查结果：

- `missing_cover_asset = 0`
- `missing_media_assets = 0`

结论：

- 当前线上 `enterprise_case` 所引用的 `file_asset` 不存在缺失
- “图片不回显” 不是由 `file_asset` 丢失导致

## 5. 目标企业线上真值

### 5.1 listing

当前与“重庆坤特 / 重庆海川展览工厂”相关的线上 listing 如下：

- `company`
  - `enterprise_id = e2a016f4-0b6a-497d-902c-409413858ca9`
  - `name = 重庆坤特展览展示有限公司`
  - `enterprise_status = published`
  - `display_status = visible`
- `factory`
  - `enterprise_id = a9b46040-956e-44fd-8e35-e3c533687e27`
  - `name = 重庆坤特展览展示有限公司`
  - `factory_name = 重庆海川展览工厂`
  - `enterprise_status = published`
  - `display_status = visible`
- `supplier`
  - `enterprise_id = c0576f5c-854c-4b78-9f93-6d57e55d8b47`
  - `name = 重庆坤特展览展示有限公司`
  - `enterprise_status = published`
  - `display_status = visible`

### 5.2 case 真值

- `factory` listing 下存在 1 条 `approved` 案例
  - `case_id = e3940909-b9ec-4f21-a150-7d34dafce31c`
  - `title = 机械展`
  - `case_status = approved`
- `company` listing 下存在 1 条 `draft` 案例
  - `case_id = a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64`
  - `title = 坦克`
  - `case_status = draft`

### 5.3 application 与 current change

`factory`：

- 历史已存在 1 条 `approved` application
- 最新 application 为 `submitted`
- 最新 current change 为 `draft`

`company`：

- 历史已存在 1 条 `approved` application
- 最新 application 为 `submitted`
- 最新 current change 为 `submitted`

### 5.4 公开详情真实输出

直接读取 `Server` 公开详情接口得到：

- `company` 详情：`casesState = empty`，`cases = 0`
- `factory` 详情：`casesState = available`，`cases = 1`

结论：

- 公司公开详情为空，不是工厂案例把它挤掉了
- 公司公开详情为空，是因为公司当前新增案例仍停留在 `current change submitted` / `draft case`，尚未进入公开可见态
- 工厂公开详情展示工厂自己的 `approved` 案例，符合当前数据库真值

## 6. current change 快照事实

只读核查 `enterprise_change_request.draft_cases` 后得到：

- `factory` 最新 `draft` change request 中已有 `caseImageUrlMap`
- `company` 最新 `submitted` change request 中存在 1 条案例快照，但该快照当前不含 `caseImageUrlMap`

结论：

- 公司变更走廊中的案例快照也存在媒体合同不完整问题
- 即使未来公开链正确，若继续编辑 / 预览直接消费这条 change snapshot，仍有概率出现图片不完整

## 7. 综合定性

截至 `2026-04-19`，这批问题应拆成三类：

### 7.1 已确认的线上发布缺陷

- 生产 `BFF/Server` 活跃发布包都缺少 `public-cases` 路由
- 生产 `Server` 私有 `getCaseDetail` 不返回 `caseImageUrlMap`

### 7.2 已确认的线上业务状态事实

- 公司 listing 公开详情为空，是因为当前只有 `draft` / `submitted current change` 案例，尚未到公开可见态
- 工厂 listing 公开详情显示工厂自己的 `approved` 案例

### 7.3 当前不成立的推断

- 按 `2026-04-19` 线上数据库真值，不存在 company case 被直接写到 factory listing 的硬串板块数据

## 8. 执行含义

后续修复必须拆成两条线并行：

1. 发布线
   - 重新发布包含 `public-cases` 和私有 `caseImageUrlMap` 的 `Server/BFF`
2. 数据/状态线
   - 对公司与工厂当前 `application/change_request/case_status` 做运营确认
   - 明确公司当前 `submitted current change` 是否应继续等待审核，还是需要人工驳回/重提/直接批准应用

如果不先分清“发布缺陷”和“业务状态”，继续把“公司详情为空”一概归因为串板块，会导致错误修库。
