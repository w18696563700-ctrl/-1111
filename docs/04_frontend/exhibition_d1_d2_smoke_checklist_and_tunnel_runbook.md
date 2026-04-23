# 展览 D1 / D2 Smoke Checklist 与联调启动说明

## 1. 适用范围
- 当前文档只覆盖 `项目`、`论坛`、`公司`、`工厂`、`供应商` 五个栏目。
- `天气` 与 `团队` 不在本轮 D1 / D2 smoke 范围内。
- 本地只有 `apps/mobile`，BFF 和后端跑在阿里云；默认联调方式是本地 macOS Flutter + SSH 隧道。

## 2. 当前基线提醒
- 首页企业频道现状以当前 UI 为准：Tab 文案是 `公司` / `工厂` / `供应商`，入口按钮是 `进入公司列表` / `进入工厂列表` / `进入供应商列表`。
- 旧测试里仍有一处断言老文案 `优秀公司` / `查看公司`；手工 smoke 不要按旧文案验。
- `APP_BFF_ACTOR_ID` / `APP_BFF_USER_ID` 只能补充调试头，不替代真实登录态。涉及保护接口时，仍要在 App 内完成登录，让 `accessToken` / `refreshToken` 建立会话。
- 正式云端主机、端口、SSH 用户基线以 `infra/env/formal_cloud_target.env` 为准；脚本默认会从该文件派生云端直连和隧道目标。

## 3. 联调账号准备
不要把手机号、密码、验证码写进脚本或文档。建议只通过 shell 环境变量临时注入。

推荐最小账号矩阵：

| 用途 | 建议能力 | 推荐环境变量 |
| --- | --- | --- |
| 论坛登录动作 smoke | 普通已注册账号，可发帖/评论/点赞/收藏/举报 | `FORUM_SMOKE_MOBILE` `FORUM_SMOKE_PASSWORD` |
| 项目发布 smoke | 已登录、已认证、具备 `projectCreateEligibility.canCreateProject=true` 的账号 | `PROJECT_SMOKE_MOBILE` `PROJECT_SMOKE_PASSWORD` |
| 公司工作台 smoke | 已登录、公司侧组织管理员、认证通过 | `COMPANY_SMOKE_MOBILE` `COMPANY_SMOKE_PASSWORD` |
| 工厂工作台 smoke | 已登录、工厂侧组织管理员、认证通过 | `FACTORY_SMOKE_MOBILE` `FACTORY_SMOKE_PASSWORD` |
| 供应商工作台 smoke | 已登录、供应商侧组织管理员、认证通过 | `SUPPLIER_SMOKE_MOBILE` `SUPPLIER_SMOKE_PASSWORD` |

单次运行时，可以把某一套账号映射到脚本通用变量：

```zsh
export SMOKE_ACCOUNT_LABEL="project-publisher"
export SMOKE_LOGIN_MOBILE="$PROJECT_SMOKE_MOBILE"
export SMOKE_LOGIN_PASSWORD="$PROJECT_SMOKE_PASSWORD"
```

脚本只会脱敏回显 `SMOKE_ACCOUNT_LABEL` / `SMOKE_LOGIN_MOBILE`，不会打印密码或验证码。

## 4. 启动方式

### 4.1 推荐方式：本地起 App + 自动建隧道

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_ACCOUNT_LABEL="anonymous-read" \
APP_INITIAL_ROUTE="/" \
./apps/mobile/scripts/run_macos_exhibition_smoke.sh
```

默认行为：
- 自动执行 `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 自动把 `APP_BFF_BASE_URL` 设为 `http://127.0.0.1:8080/api/app`
- 自动把 `APP_RUNTIME_ENTRY_MODE` 设为 `ssh_tunnel`
- 复用现有 `apps/mobile/scripts/run_macos_formal.sh` 完成 Flutter macOS build + launch

### 4.2 只开隧道，不起 App

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_TUNNEL_ONLY=1 \
./apps/mobile/scripts/run_macos_exhibition_smoke.sh
```

适合你想手动运行 `flutter run -d macos` 或者先用别的工具探活接口。

### 4.3 复用已有隧道

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_SKIP_TUNNEL=1 \
APP_BFF_BASE_URL="http://127.0.0.1:8080/api/app" \
./apps/mobile/scripts/run_macos_exhibition_smoke.sh
```

### 4.4 直连云端，不走隧道

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
./apps/mobile/scripts/run_macos_cloud.sh
```

只适合做快速只读验证；本轮 D1 / D2 仍推荐隧道方式，和当前本地默认配置一致。

当前 `run_macos_formal.sh` 是统一入口；若你要显式声明模式，也可以直接使用：

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
APP_RUNTIME_ENTRY_MODE=cloud \
./apps/mobile/scripts/run_macos_formal.sh
```

### 4.5 staging app-facing BFF 隧道

`staging` 的 app-facing BFF 当前走远端 `3100` 端口，不再是首页正式端口 `80`。

只开 staging 隧道：

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_TUNNEL_LOCAL_PORT=3100 \
SMOKE_TUNNEL_REMOTE_PORT=3100 \
SMOKE_TUNNEL_ONLY=1 \
./apps/mobile/scripts/run_macos_exhibition_smoke.sh
```

本地起 App 并指向 staging app-facing BFF：

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_TUNNEL_LOCAL_PORT=3100 \
SMOKE_TUNNEL_REMOTE_PORT=3100 \
APP_BFF_BASE_URL="http://127.0.0.1:3100/api/app" \
./apps/mobile/scripts/run_macos_exhibition_smoke.sh
```

### 4.6 staging app-facing HTTP smoke 脚本

新增脚本：`apps/mobile/scripts/run_staging_app_facing_smoke.sh`

默认行为：
- 自动建立 `3100 -> 3100` staging 隧道
- 默认调用 `http://127.0.0.1:3100/api/app`
- 先执行真实登录，再读取 `shell/context`
- 输出 `organizationType / roleKeys / certificationStatus / projectCreateEligibility.canCreateProject`
- 执行可复跑 forum 写链路 smoke
- 只有 `SMOKE_ALLOW_PROJECT_WRITE=1` 时才会尝试 `project create`
- 当 `SMOKE_ALLOW_PROJECT_WRITE=1` 且 `projectCreateEligibility.canCreateProject != true` 时，`project create` 记为 `BLOCKED`，不是硬失败
- 最终以 `PASS / WARN / BLOCKED / SKIPPED / FAIL` 汇总

OTP 登录示例：

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_ACCOUNT_LABEL="staging-forum-otp" \
SMOKE_LOGIN_MOBILE="$FORUM_SMOKE_MOBILE" \
SMOKE_LOGIN_OTP="$FORUM_SMOKE_OTP" \
./apps/mobile/scripts/run_staging_app_facing_smoke.sh
```

密码登录示例：

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_ACCOUNT_LABEL="staging-forum-password" \
SMOKE_LOGIN_METHOD=password \
SMOKE_LOGIN_MOBILE="$FORUM_SMOKE_MOBILE" \
SMOKE_LOGIN_PASSWORD="$FORUM_SMOKE_PASSWORD" \
./apps/mobile/scripts/run_staging_app_facing_smoke.sh
```

复用已有 staging 隧道：

```zsh
cd /Users/wangweiwei/Desktop/展览装修之家总控
SMOKE_SKIP_TUNNEL=1 \
APP_BFF_BASE_URL="http://127.0.0.1:3100/api/app" \
SMOKE_LOGIN_MOBILE="$FORUM_SMOKE_MOBILE" \
SMOKE_LOGIN_OTP="$FORUM_SMOKE_OTP" \
./apps/mobile/scripts/run_staging_app_facing_smoke.sh
```

项目写链默认不会执行。只有在你明确打开：

```zsh
SMOKE_ALLOW_PROJECT_WRITE=1
```

且当前 shell 返回 `projectCreateEligibility.canCreateProject=true` 时，脚本才会真的触发 `POST /api/app/project/create`。否则脚本会打印 `BLOCKED`，不把当前不可写身份误判成前端故障。

## 5. 可用环境变量

| 变量 | 作用 | 默认值 |
| --- | --- | --- |
| `SMOKE_SSH_HOST` | SSH 主机 | `47.108.180.198` |
| `SMOKE_SSH_USER` | SSH 用户 | `root` |
| `SMOKE_SSH_PORT` | SSH 端口 | `22` |
| `SMOKE_SSH_IDENTITY_FILE` | SSH 私钥路径 | 空 |
| `SMOKE_SSH_STRICT_HOST_KEY_CHECKING` | SSH host key 策略 | `accept-new` |
| `SMOKE_TUNNEL_LOCAL_PORT` | 本地映射端口 | `8080` |
| `SMOKE_TUNNEL_REMOTE_HOST` | 远端转发目标 host | `127.0.0.1` |
| `SMOKE_TUNNEL_REMOTE_PORT` | 远端转发目标 port | `80` |
| `SMOKE_SKIP_TUNNEL` | 复用已有隧道 | `0` |
| `SMOKE_TUNNEL_ONLY` | 只建隧道不拉起 App | `0` |
| `APP_BFF_BASE_URL` | BFF 基础地址 | `http://127.0.0.1:8080/api/app` |
| `APP_RUNTIME_ENTRY_MODE` | App 入口模式 | `ssh_tunnel` |
| `APP_INITIAL_ROUTE` | App 初始路由 | `/` |
| `APP_BFF_ACTOR_ID` | 调试 actor 头 | 空 |
| `APP_BFF_USER_ID` | 调试 user 头 | 空 |
| `SMOKE_ACCOUNT_LABEL` | 本次 smoke 账号标签 | 空 |
| `SMOKE_LOGIN_MOBILE` | 本次 smoke 登录手机号 | 空 |
| `SMOKE_LOGIN_PASSWORD` | 本次 smoke 登录密码 | 空 |
| `SMOKE_LOGIN_OTP` | 本次 smoke 验证码 | 空 |

## 5.1 staging app-facing smoke 额外环境变量

| 变量 | 作用 | 默认值 |
| --- | --- | --- |
| `SMOKE_LOGIN_METHOD` | `auto / otp / password`；`auto` 优先用 OTP，其次密码 | `auto` |
| `SMOKE_DEVICE_ID` | staging 登录 deviceId | 自动生成 UUID |
| `SMOKE_DEVICE_NAME` | staging 登录 deviceName | `Codex Staging Smoke` |
| `SMOKE_OS_TYPE` | staging 登录 osType | `macos` |
| `SMOKE_CONSENT_ACCEPTED` | 登录 consent 开关 | `true` |
| `SMOKE_RUN_FORUM` | 是否执行 forum 写链路 smoke | `1` |
| `SMOKE_ALLOW_PROJECT_WRITE` | 是否尝试 `project/create` | `0` |
| `SMOKE_FORUM_TOPIC_ID` | 固定 forum smoke topicId；为空时取 `topic/metadata` 第一个 | 空 |
| `SMOKE_FORUM_TITLE` | forum 草稿标题 | 自动带时间戳 |
| `SMOKE_FORUM_BODY` | forum 草稿正文 | 自动带时间戳 |
| `SMOKE_FORUM_COMMENT_BODY` | forum 评论正文 | 自动带时间戳 |
| `SMOKE_REPORT_REASON_CODE` | forum 举报 reasonCode | `other` |
| `SMOKE_REPORT_REASON_DETAIL` | forum 举报补充说明 | 自动带时间戳 |
| `SMOKE_PROJECT_EXHIBITION_NAME` | project create 展会名 | 自动带时间戳 |
| `SMOKE_PROJECT_BRAND_NAME` | project create 品牌名 | `Codex smoke` |
| `SMOKE_PROJECT_TITLE` | project create 兼容 title | `${SMOKE_PROJECT_EXHIBITION_NAME} - ${SMOKE_PROJECT_BRAND_NAME}` |
| `SMOKE_PROJECT_BUILDING_TYPE` | project create buildingType | `exhibition` |
| `SMOKE_PROJECT_BUDGET_AMOUNT` | project create budgetAmount | `180000` |
| `SMOKE_PROJECT_PROVINCE_CODE` | project create provinceCode | `510000` |
| `SMOKE_PROJECT_PROVINCE_NAME` | project create provinceName | `Sichuan` |
| `SMOKE_PROJECT_CITY_CODE` | project create cityCode | `510100` |
| `SMOKE_PROJECT_CITY_NAME` | project create cityName | `Chengdu` |
| `SMOKE_PROJECT_DISTRICT_CODE` | project create districtCode | 空 |
| `SMOKE_PROJECT_DISTRICT_NAME` | project create districtName | 空 |
| `SMOKE_PROJECT_DETAIL_ADDRESS` | project create detailAddress | 默认 staging smoke 地址 |
| `SMOKE_PROJECT_SCOPE_SUMMARY` | project create scopeSummary | 自动带时间戳 |

## 6. D1 / D2 Smoke Checklist

### 6.1 项目

#### 匿名读链路
- [ ] 首页 `/` 切到 `项目` Tab，看到 `进入项目大厅` 与 `发布项目`，无英文 transport 错误文案。
- [ ] 打开 `/exhibition/projects`，列表能正常加载，项目卡片展示标题、预算、地区，不出现空壳占位或原始 JSON 字段。
- [ ] 从列表进入 `/exhibition/projects/detail?projectId=...`，详情页展示标题、预算、地点、计划时间；已承接项目显示受控提示，不暴露错误态。
- [ ] 对 `converted_to_order` 项目，详情页不再出现 `立即参与竞标`，而是展示只读引导。

#### 登录态动作
- [ ] 用项目发布账号登录后，从首页 `发布项目` 或 `/exhibition/projects/create` 进入创建页。
- [ ] 录入最小必填字段：`项目名称`、`品牌`、`项目类型`、`预算金额`、`省/市/区`、`详细地址`、`范围说明`、`计划开始日期`、`计划结束日期`。
- [ ] 保存草稿或提交后再次进入，字段回填正确，省市区和计划日期没有回退成旧字段。
- [ ] 发布成功后能在 `我的项目` 或项目详情链路回流；已发布项目的附件走廊仍可继续读取。

#### 关键回归点
- [ ] 未登录创建项目时，提示必须是受控中文原因，不直接把 `401` 或英文文案暴露给用户。
- [ ] 创建页仍保留 `exhibitionName + brandName` 的拆分录入，不回退成旧版单标题表单。
- [ ] 附件链路仍遵守 `init -> direct upload -> confirm`，没有漂移到错误的内部确认端点。

自动化锚点：
- `apps/mobile/test/exhibition_mainline_flow_test.dart`
- `apps/mobile/test/project_publish_round_a_productization_test.dart`
- `apps/mobile/test/project_attachment_corridor_test.dart`
- `apps/mobile/test/project_publish_minimum_corridor_alignment_test.dart`
- `apps/mobile/test/project_showcase_filter_create_refactor_test.dart`

### 6.2 论坛

#### 匿名读链路
- [ ] 打开 `/exhibition/forum`，看到 `广场`、`关注`、`本地` 三个 feed 入口；首屏以内容为中心，不出现旧版总览入口文案。
- [ ] 切换话题筛选后，帖子列表发生可见变化，筛选状态不丢失。
- [ ] 进入 `/exhibition/forum/posts/{postId}`，正文、作者、互动区正常展示；评论链 `/exhibition/forum/comments?postId=...` 可打开。
- [ ] 作者头像和作者信息都能进入 `/exhibition/forum/authors/{authorId}`；搜索 `/exhibition/forum/search` 可用。

#### 登录态动作
- [ ] 用论坛账号登录后，进入 `/exhibition/forum/publish`，完成发帖。
- [ ] 发帖包含：选择话题、输入正文、保存草稿、重新打开草稿继续编辑。
- [ ] 在帖子详情执行 `点赞`、`收藏`、`评论`，结果与服务端 authoritative 响应保持一致。
- [ ] 进入 `我的帖子`、`我的评论`、`我的收藏`、`我的关注`、`我的举报记录`，都能读取受控列表。
- [ ] 举报帖子或评论后，结果页和详情页均为中文受控文案。

#### 关键回归点
- [ ] 发帖 AI 审核返回 `supplement_required` / `restricted` / `ticket_required` 时，必须留在草稿走廊，不误跳详情页。
- [ ] 话题选择器不能露出原始 topic label 或 UUID。
- [ ] 未登录举报、文件访问失败、外部打开失败时，都保持受控中文提示，不泄漏英文 transport 错误。
- [ ] 已发布附件的图片、视频、文件访问都仍可用，失败时有 fallback sheet。

自动化锚点：
- `apps/mobile/test/forum_routes_test.dart`
- `apps/mobile/test/forum_interaction_loop_test.dart`
- `apps/mobile/test/forum_content_governance_and_report_test.dart`
- `apps/mobile/test/forum_publish_ai_review_gate_test.dart`
- `apps/mobile/test/forum_rich_publish_media_hotfix_test.dart`
- `apps/mobile/test/forum_rich_publish_file_attachment_test.dart`
- `apps/mobile/test/forum_published_attachment_access_test.dart`

### 6.3 公司

#### 匿名读链路
- [ ] 首页切到 `公司` Tab，确认按钮文案为 `进入公司列表`，不是旧文案 `查看公司`。
- [ ] 打开 `/exhibition/companies`，列表正常展示；本省过滤和城市过滤行为受控，不误触发无效筛选。
- [ ] 从首页或列表进入 `/exhibition/companies/detail?enterpriseId=...`，详情页可见 `详细介绍`、`地址与服务区域`、`案例展示`、`联系方式`。
- [ ] 企业信息抽屉可打开，展示认证主体、统一社会信用代码、法定代表人、认证状态。

#### 登录态动作
- [ ] 用公司管理员账号登录，进入 `/exhibition/company-display/workbench` 或已有企业的 published change 工作台。
- [ ] 校验基础资料、画册、案例、联系人能够读取现状并保存。
- [ ] 提交后可打开 `/exhibition/company-display/status?applicationId=...`，状态页不暴露上游 truth 字段。

#### 关键回归点
- [ ] 公司首页推荐位即使没有数据，也必须显示受控空态或被隐藏，不出现半截卡片。
- [ ] 详情页没有重复的独立画册区、没有裸露图片 URL、没有英文错误信息。
- [ ] 没有坐标时只展示文字地址，不展示 `查看地图`。
- [ ] 当前手工 smoke 应以新首页 copy 为准；旧测试中 `优秀公司` / `查看公司` 是过期断言。

自动化锚点：
- `apps/mobile/test/exhibition_home_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`
- `apps/mobile/test/enterprise_hub_trust_repair_stage1_test.dart`
- `apps/mobile/test/enterprise_hub_board_scoped_transport_test.dart`

### 6.4 工厂

#### 匿名读链路
- [ ] 首页切到 `工厂` Tab，验证 `进入工厂列表` 可打开 `/exhibition/factories`。
- [ ] 工厂列表可读，推荐、本省、综合三个来源的数据切换不串板。
- [ ] 进入 `/exhibition/factories/detail?enterpriseId=...`，顶部 hero、基础信息、设备能力、地址与服务区域、案例或空态文案均正常。
- [ ] 工厂详情没有重复画廊；空案例时展示受控空态，不显示旧样板文案。

#### 登录态动作
- [ ] 用工厂管理员账号登录，进入 `/exhibition/factory-display/workbench`。
- [ ] 验证工艺类型、核心产品、设备列表、工厂实景、案例编辑都能读取并保存。
- [ ] 提交申请后打开 `/exhibition/factory-display/status?applicationId=...`，状态页受控。

#### 关键回归点
- [ ] 详情页 hero overlay 与相册顺序保持稳定，不因重复媒体导致画册重复。
- [ ] 地址无坐标时只展示文字地址，不跳地图。
- [ ] 列表卡片评分逻辑保持不变；禁用状态的城市筛选按钮不能触发回调。
- [ ] 403 / 404 页面仍为中文受控错误，不外漏上游字段。

自动化锚点：
- `apps/mobile/test/exhibition_home_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`
- `apps/mobile/test/enterprise_hub_trust_repair_stage1_test.dart`
- `apps/mobile/test/enterprise_hub_board_surface_stage2_test.dart`

### 6.5 供应商

#### 匿名读链路
- [ ] 首页切到 `供应商` Tab，确认入口按钮为 `进入供应商列表`。
- [ ] 打开 `/exhibition/suppliers`，列表 copy 与公司/工厂明显区分，不串用别的板块文案。
- [ ] 进入 `/exhibition/suppliers/detail?enterpriseId=...`，详情页至少要能稳定展示简介、地址与服务区域、联系方式；字段缺失时不能渲染出 `null`。
- [ ] 首页推荐位如果无数据，界面必须受控，不允许显示破损占位。

#### 登录态动作
- [ ] 用供应商管理员账号登录，进入 `/exhibition/supplier-display/workbench`。
- [ ] 校验基础资料、服务范围、媒体、案例、联系人可以读取、保存、再次打开。
- [ ] 提交后可打开 `/exhibition/supplier-display/status?applicationId=...`，状态页受控。

#### 关键回归点
- [ ] 供应商详情不能回退成公司/工厂字段布局，也不能显示空 URL、空媒体数组的原始占位。
- [ ] 推荐位空数据时保持受控；推荐位有数据时点击能进入正确详情。
- [ ] board-scoped transport 必须仍指向 supplier 自己的 canonical family，不串 company / factory。
- [ ] 403 / 404 页面仍为中文受控错误。

自动化锚点：
- `apps/mobile/test/exhibition_home_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`
- `apps/mobile/test/enterprise_hub_board_scoped_transport_test.dart`

## 7. 推荐执行顺序
1. 先跑匿名读链路，确认 5 个栏目没有路由级或只读渲染级阻断。
2. 再切论坛账号，完成发帖 / 评论 / 举报 / 收藏 smoke。
3. 再切项目发布账号，完成创建 / 保存 / 发布 / 回流 smoke。
4. 最后按 `公司 -> 工厂 -> 供应商` 顺序切企业管理员账号，验证工作台和状态页。

## 8. D1 交付边界
- 本文档负责 D1 / D2 smoke 执行手册和联调启动方式，不替代业务修复。
- 已知代码级基线问题需要在允许改动范围外单独处理时，再由对应 Agent 继续推进。

## 9. 当前已知 staging 结论
- staging app-facing BFF 当前可通过 `3100` 隧道访问，适合做登录态 API smoke，不需要改本地业务代码。
- 当前已验证可登录的 staging 白名单 actor，`shell/context` 读到的最小资格是：
  - `organizationType = platform`
  - `roleKeys` 含 `platform_reviewer`
  - `certificationStatus = not_submitted`
  - `projectCreateEligibility.canCreateProject = false`
- 因此当前 staging 的 `project create` 在这类 actor 下应判为 `BLOCKED`，这表示账号资格不足，不应被误判成前端硬失败。
- forum 写链路当前已验证可走通的最小 corridor 包括：
  - `topic/metadata`
  - `me/index`
  - `draft/list`
  - `draft/save`
  - `draft/detail`
  - `publish`
  - `post/detail`
  - `post/comment`
  - `report/submit`
  - `post/comments`
  - `me/posts`
  - `me/comments`
  - `reports/mine`
- 当前 staging 仍有一个已知读取回流异常：
  - `post/like` 与 `post/bookmark` 接口会先返回接受态，但紧接着 reread `post/detail` 或 `me/bookmarks` 时，`viewerHasLiked / viewerHasBookmarked / bookmark list` 可能还是旧值。
  - `run_staging_app_facing_smoke.sh` 会把这类现状记为 `WARN`，不吞掉结果，也不把整个 smoke 提前打断。

## 9. 2026-04-21 当前 staging 结论
- `forum` app-facing staging 已实测通过：`topic metadata -> me index -> draft save -> publish -> post detail -> comment -> like -> bookmark -> report -> mine lists` 全部命中过真实 `200/202`。
- 当前 staging 还存在一处真实一致性滞后：`like/bookmark` 已返回 `202 accepted` 后，紧接着 reread `post/detail` 仍可能返回 `viewerHasLiked=false` / `viewerHasBookmarked=false`，`me/bookmarks` 也可能暂时看不到 fresh post。这个现象现在已经被前端本地保护逻辑和回归测试覆盖，不能再把它误判成按钮没生效。
- `project` staging 写链本轮仍是 `BLOCKED`，不是 `FAILED`。原因不是前端 transport，而是当前可用的 staging 白名单身份在 `shell/context` 下返回的 `projectCreateEligibility.canCreateProject=false`，无法合法触发 `project/create` smoke。
- 因此，D2 当前能正式签收的是：
  - `forum 登录态动作 smoke` 已完成并可复跑
  - `project 发布链 smoke` 已完成脚本与阻塞识别，但仍缺一个合法可写的 staging 身份
