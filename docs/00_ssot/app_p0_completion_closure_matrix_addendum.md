# 全 App P0 六主线收口阶段门禁报告 Addendum

更新时间：2026-05-01

适用范围：本报告只覆盖本轮 P0-B / P0-C / P0-D / P0-E 收口，以及回归时暴露并已重新追平的 P0-A fail-close。禁止把本文结论扩展到支付后台、信用人工改分、会员配置后台、通用消息后台、工单重系统、settings / feature flags center、order / contract / fulfillment / settlement。

## 1. 总裁决

| 项 | 裁决 |
| --- | --- |
| 当前 P0 完整度评分 | 98 / 100 |
| 是否允许进入实质开发 | 允许进入下一轮 bounded hardening，不允许扩写新模块 |
| 是否允许声明 P0 100% full live pass | 不允许 |
| 当前 Go / No-Go | Go for bounded RC hardening；No-Go for 100% full live pass |
| 已关闭的强 veto | P0-A enterprise_hub Admin fail-close；P0-E `/template_config` 云端 404；P0-B runtime 口径；P0-C exhibition report route 404；有效 App session carrier 下的 exhibition report 成功入案；Admin reviewer-capable carrier 下 `/project_review` 案件可见 |
| 仍未关闭的 full-pass 证据缺口 | 真机/商店材料级合规核验 |
| 本轮 active release | Server `/srv/releases/server/20260501053918-p0-bcde-closure`；BFF `/srv/releases/bff/20260501053918-p0-bcde-closure/apps/bff`；Admin 仍为 `/srv/releases/admin/20260412160203` |

结论：本轮已经把 P0-A/B/C/E 的 runtime veto 缺口关闭，并已用受控 Server carrier 验证 exhibition report 成功入案且 Admin `/project_review` 可见。P0-D 已完成 iOS 相机/相册权限说明最小配置修复，但仍缺真机/商店材料证据，不能写成 P0 100% full live pass。

## 1.1 剩余缺口冻结表

| 编号 | 缺口 | 当前状态 | 是否阻塞 P0 100% | 证据来源 | 下一步 |
| --- | --- | --- | --- | --- | --- |
| G1 | Admin reviewer 登录后确认 `/project_review` 可见 exhibition report case | 已关闭 | 否 | runtime | 保留脱敏结果，不再重复使用账号或 token |
| G2 | P0-D 真机/商店材料核验 | 未关闭 | 是 | 代码 / 测试 / 待人工材料 | 提供真机截图、构建包权限清单、SDK 清单、应用商店隐私清单 |
| G3 | contracts/generated clean-window 本地一致性 | 已关闭 | 否 | contracts / generated / 本地校验 | 后续做 clean release hygiene |
| G4 | report case 与 Admin 案件台可追溯证据归档 | 已关闭 | 否 | runtime | 已脱敏记录，不写完整内部 ID |
| G5 | 最终 P0 门禁报告 | 未关闭 | 是 | 文书 | P0-D 证据闭合后更新最终 Go / No-Go |
| G6 | 脏工作区与 P0 clean release 边界隔离 | 未关闭但不阻塞业务 P0 | 否 | git status / 推断 | clean release 仅允许 contracts artifacts，不夹带无关业务变更 |

## 1.2 P0 100% 验收口径

| Gate | 100% 通过标准 | 当前裁决 |
| --- | --- | --- |
| P0-A Admin fail-close | 匿名 Admin Server API 先返回 401/403，不进入业务层 | Pass |
| P0-B contracts clean-window | formal OpenAPI、bundle、generated 与 runtime 口径一致；`message/index` 不再是 active 主线 | Pass |
| P0-C 举报闭环 | App submit 成功入案；Admin report-case API 和 `/project_review` 可见；不触发治理重系统 | Pass |
| P0-D 上架合规 | App 内入口可达；法律文书与 asset 一致；真机截图、SDK 清单、权限清单、商店隐私材料一致；iOS/Android 权限说明完整 | Conditional Pass |
| P0-E Admin runtime | `/template_config` 不再 404，未登录跳 `/login`，不扩成 runtime config 真源 | Pass |

## 2. P0-B Contracts Clean-Window

| 项 | 裁决 | 当前结果 | 依据类型 |
| --- | --- | --- | --- |
| `message/index` | 废弃 active 主线，保留历史兼容认知 | Runtime `GET /api/app/message/index` 返回 404，不再作为当前 P0 主线 | contracts / runtime |
| `message/interactions` | 当前消息楼正式主线 | Runtime 未登录返回 401 `AUTH_SESSION_INVALID`，说明路由存在且受保护 | 代码 / runtime |
| `appeals POST` | 从当前 P0 active 降级为 future reserved | Runtime `POST /api/app/profile/governance/appeals` 返回 404 | contracts / runtime |
| `password auth` | 保留为受控 auth capability，不是 Admin 登录方式 | Runtime 空 body 返回 400 `AUTH_CONSENT_REQUIRED`，不是 404 | 代码 / runtime |
| formal contracts / generated | 已在本地 clean-window 同步 | `pnpm contracts:generate` 与 `pnpm contracts:check` 通过；生成物含历史无关脏 diff，已记录 inherited dirty-worktree note | contracts / 代码 |

P0-B 裁决：`Pass for clean-window scope`。不得把 `message/index` 重新扩成主线，也不得把 appeals POST 扩成申诉重系统。

## 3. P0-C 举报闭环

| 链路 | 当前结果 | 依据类型 | 裁决 |
| --- | --- | --- | --- |
| Server submit input | 新增 `POST /server/exhibition/report/submit`，写入或复用 `exhibition_report_cases`，并记录 audit | 代码 / 测试 |
| BFF app-facing route | 新增 `POST /api/app/exhibition/report/submit`，只转发到 Server，不持有状态机 | 代码 / 测试 |
| App 项目详情入口 | 新增“举报该项目”最小入口，只提交 project target，不做举报历史中心 | 代码 / 测试 |
| Admin case queue | 复用既有 `/server/admin/exhibition/report-cases` 与 `/project_review` 案件台 | 代码 / runtime |
| 未登录 fail-close | 匿名 POST 返回 401 `AUTH_SESSION_INVALID`；actor hint 但无有效 carrier 也返回 401 | runtime |
| 有效登录成功入案 | password login 200；project list 200；`POST /api/app/exhibition/report/submit` 200，返回 `status=submitted`、`acceptMode=created`；账号、token、完整内部 ID 未记录 | runtime |
| Admin 登录后案件台可见 | reviewer-capable Server carrier 访问 Admin report-case API 返回 200，列表包含本轮 case；`/project_review` 页面返回 200，包含案件队列、target 与 reportCase，未出现鉴权错误；账号、token、完整内部 ID 未记录 | runtime |

P0-C 裁决：`Pass`。代码、BFF 转发、App 入口、未登录 fail-close、有效登录成功入案与 Admin 案件台可见性均已闭合。本轮仍禁止点击 request explanation / decide / escalate 等治理动作，避免把只读可见性验证扩成治理执行。

## 4. P0-D 上架合规

| 项 | 当前结果 | 依据类型 | 裁决 |
| --- | --- | --- | --- |
| 用户协议入口 | 登录页与设置页可达法律文书 | 代码 / 测试 |
| 隐私政策入口 | `docs/legal/privacy_policy.md` 与 `apps/mobile/assets/legal/privacy_policy.md` 完全一致 | 文书 / 代码 |
| 用户协议材料 | `docs/legal/user_agreement.md` 与 `apps/mobile/assets/legal/user_agreement.md` 完全一致 | 文书 / 代码 |
| 注销 / 删除账号 | 设置页提供受理说明，不承诺一键自助注销 | 代码 / 文书 |
| 客服 / 投诉 | 设置页与隐私权限页展示客服邮箱，电话标注暂未公示 | 代码 / 文书 |
| SDK / 权限 / 支付说明 | 隐私权限页有最小说明，明确需上架前逐项核对 | 代码 / 文书 |
| 真机 / 商店材料 | 未执行 | 待复核 |
| iOS 权限说明 | 已补 `NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription`，保留既有 `NSLocationWhenInUseUsageDescription`；`plutil -lint` 通过 | 代码 / 本地验证 |

P0-D 裁决：`Conditional Pass`。最低入口、文书 asset 一致性、iOS 权限用途说明配置与 Flutter 定向测试通过；真机截图、构建包 SDK 清单、应用商店隐私清单仍需人工验收。本轮只做 `Info.plist` 最小配置修复，不扩写法律文书、支付能力或业务功能。

## 5. P0-E Admin Runtime

| 项 | 当前结果 | 依据类型 | 裁决 |
| --- | --- | --- | --- |
| Admin active page | 云端 Admin 直连 3002 的 `/template_config` 返回 307 到 `/login` | runtime |
| Nginx route | `/template_config` 和 `/template_config/` 已补到 `/etc/nginx/conf.d/exhibition.conf` 并 reload | runtime |
| 公网隧道结果 | `GET http://127.0.0.1:8080/template_config` 返回 307 到 `/login?next=%2Ftemplate_config` | runtime |
| 页面定位 | 仍是模板治理台，不是 runtime config / flags center | 文书 / 代码 |

P0-E 裁决：`Pass`。本轮只追平入口，不做 Admin UI 大重构、不新增接口、不把 `template_config` 当 runtime 配置真源。

## 6. P0-A 回归修正

回归时发现：新 release 基线来自 `20260501045612-notification-preview-v1-rebase`，未包含 P0-A enterprise_hub fail-close patch，导致匿名 Admin 管理路径回退为 200 / 404。已从已验证 release `/srv/releases/server/20260501045239-p0-a-enterprise-hub-failclose` 只追平以下 P0-A 文件到当前 release：

- `enterprise-hub-admin.controller.*`
- `enterprise-hub-admin.service.*`

复核结果：

| 路径 | 方法 | 当前 runtime | 裁决 |
| --- | --- | --- | --- |
| `/server/admin/exhibition/enterprise-hub/recommendation-slots` | GET | 401 `AUTH_SESSION_INVALID` | Pass |
| `/server/admin/exhibition/enterprise-hub/recommendation-slots` | POST | 401 `AUTH_SESSION_INVALID` | Pass |
| `/server/admin/exhibition/enterprise-hub/enterprises/p0-failclose-probe/publish` | POST | 401 `AUTH_SESSION_INVALID` | Pass |
| `/server/admin/exhibition/enterprise-hub/enterprises/p0-failclose-probe/offline` | POST | 401 `AUTH_SESSION_INVALID` | Pass |
| `/server/admin/exhibition/enterprise-hub/enterprises/p0-failclose-probe/freeze` | POST | 401 `AUTH_SESSION_INVALID` | Pass |

P0-A 裁决：`Pass`。该项是本轮最终 Go 的硬前置。

## 7. 验证记录

| 范围 | 命令 / 操作 | 结果 |
| --- | --- | --- |
| Server build | `pnpm --filter @exhibition/server build` | 通过 |
| BFF build | `pnpm --filter @exhibition/bff build` | 通过 |
| Admin build | `pnpm --filter @exhibition/admin build` | 通过 |
| Contracts | `pnpm contracts:generate`；`pnpm contracts:check` | 通过 |
| Server P0-C test | `node --test apps/server/test/exhibition-report-case-admin.test.cjs` | 通过 |
| BFF P0-C test | `node --test apps/bff/test/exhibition-report-submit-transport.test.cjs` | 通过 |
| Mobile P0-C test | `flutter test test/exhibition_report_submit_test.dart` in `apps/mobile` | 通过 |
| Mobile P0-D test | `flutter test test/profile_page_test.dart --name "settings page opens privacy permissions and legal documents"` in `apps/mobile` | 通过 |
| Admin tests | `npm run --prefix apps/admin test:admin-side -- test/admin-template-config.test.cjs` | 通过，实际脚本跑 40 项 |
| Nginx | 云端 `nginx -t` | 通过 |
| 云端 Server/BFF release tests | 新 release 内 Server/BFF P0-C 定向 tests | 通过 |
| 云端 health | `/health/server/ready`、`/health/bff/ready` | 200 |
| Admin protected routes | `/template_config`、`/review`、`/project_review`、`/audit` | 307 到 `/login` |
| Admin Server API fail-close | enterprise_hub 与 report-cases admin paths | 401 |
| P0-C App submit | 有效 App session 提交 exhibition report | 200，`status=submitted`，`acceptMode=created/existing_active` |
| P0-C Admin API | reviewer-capable Server carrier 查询 report-cases | 200，包含本轮 report case |
| P0-C Admin page | reviewer-capable Server carrier 打开 `/project_review` | 200，页面包含案件队列、target 与 reportCase |
| P0-D iOS plist | `plutil -lint apps/mobile/ios/Runner/Info.plist`；`plutil -p ... | rg UsageDescription` | 通过；存在定位、相机、相册用途说明 |
| P0-D static test | `flutter test test/profile_page_test.dart --name "settings page opens privacy permissions and legal documents"` | 通过 |

## 8. 残余风险

| 风险 | 级别 | 说明 | 下一步 |
| --- | --- | --- | --- |
| 真机/商店材料未验 | P0 residual | 代码入口与文书一致，但不是应用商店 full compliance | 真机构建截图、SDK 清单、权限清单、隐私清单人工核对 |
| dirty worktree 大量历史变更 | P1 | 本地存在大量支付/会员/通知等无关脏变更，本轮部署使用“复制 active release + 覆盖限定文件”规避 | 下一轮先做 clean window 或隔离分支 |
| BFF active generated contracts 仍含历史 `message/index` | P1 | Runtime 已符合 P0-B，但云端 release 内生成物未作为本轮 runtime 目标完全替换 | 后续 clean release 统一追平 contracts/generated |

## 9. 回滚方式

| 范围 | 回滚方式 |
| --- | --- |
| Server | 将 `/srv/apps/server/current` 指回上一 active release `/srv/releases/server/20260501045612-notification-preview-v1-rebase`，再重启 `exhibition-server`；若只保留 P0-A，则改指 `/srv/releases/server/20260501045239-p0-a-enterprise-hub-failclose` |
| BFF | 将 `/srv/apps/bff/current` 指回 `/srv/releases/bff/20260501045612-notification-preview-v1-rebase/apps/bff`，再重启 `exhibition-bff` |
| Nginx | 用 `/srv/backups/p0-bcde-20260501053918-p0-bcde-closure/exhibition.conf` 覆盖 `/etc/nginx/conf.d/exhibition.conf`，执行 `nginx -t` 后 reload |
| Admin | 本轮未切 Admin release；无需 Admin rollback |

## 10. 最终 Go / No-Go

当前裁决：`Go for bounded RC hardening`，`No-Go for P0 100% full live pass`。

允许进入下一轮的最小范围：

1. 做真机/商店材料级 P0-D 合规验收。
2. 做一次 clean release，把 P0-B contracts/generated 与 active artifact 对齐。

下一轮唯一动作：提供 P0-D 真机截图、SDK 清单、权限清单、应用商店隐私材料。未完成前，不得声明 P0 100%。
