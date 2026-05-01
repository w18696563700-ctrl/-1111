# App P0 Runtime 结果汇总与回归判断 Addendum

更新时间：2026-05-01

适用范围：记录本轮 P0-A / P0-B / P0-C / P0-E 云端 runtime 回归事实，以及 P0-D 本地材料核验事实。本文不记录真实账号、token、session carrier 或隐私数据。

## 1. Active Artifact

| 服务 | 当前 active | 状态 | 依据类型 |
| --- | --- | --- | --- |
| Server | `/srv/releases/server/20260501053918-p0-bcde-closure` | active | runtime |
| BFF | `/srv/releases/bff/20260501053918-p0-bcde-closure/apps/bff` | active | runtime |
| Admin | `/srv/releases/admin/20260412160203` | active | runtime |
| Nginx | `/etc/nginx/conf.d/exhibition.conf` 已补 `/template_config` | `nginx -t` pass，已 reload | runtime |

## 2. Runtime 回归矩阵

| Gate | 路径 / 操作 | 结果 | 裁决 | 依据类型 |
| --- | --- | --- | --- | --- |
| Health | `/health/server/ready` | 200 | Pass | runtime |
| Health | `/health/bff/ready` | 200 | Pass | runtime |
| Admin protected | `/template_config` | 307 到 `/login?next=%2Ftemplate_config` | Pass | runtime |
| Admin protected | `/review` | 307 到 `/login?next=%2Freview` | Pass | runtime |
| Admin protected | `/project_review` | 307 到 `/login?next=%2Fproject_review` | Pass | runtime |
| Admin protected | `/audit` | 307 到 `/login?next=%2Faudit` | Pass | runtime |
| Admin API fail-close | `/server/admin/exhibition/report-cases` | 401 `AUTH_SESSION_INVALID` | Pass | runtime |
| P0-A enterprise_hub | `GET /server/admin/exhibition/enterprise-hub/recommendation-slots` | 401 `AUTH_SESSION_INVALID` | Pass | runtime |
| P0-A enterprise_hub | `POST /server/admin/exhibition/enterprise-hub/recommendation-slots` | 401 `AUTH_SESSION_INVALID` | Pass | runtime |
| P0-A enterprise_hub | `POST /server/admin/exhibition/enterprise-hub/enterprises/p0-failclose-probe/publish` | 401 `AUTH_SESSION_INVALID` | Pass | runtime |
| P0-A enterprise_hub | `POST /server/admin/exhibition/enterprise-hub/enterprises/p0-failclose-probe/offline` | 401 `AUTH_SESSION_INVALID` | Pass | runtime |
| P0-A enterprise_hub | `POST /server/admin/exhibition/enterprise-hub/enterprises/p0-failclose-probe/freeze` | 401 `AUTH_SESSION_INVALID` | Pass | runtime |
| P0-B message/index | `GET /api/app/message/index` | 404 | Pass for deprecated path | runtime / contracts |
| P0-B message/interactions | `GET /api/app/message/interactions?lane=project_communication` | 401 `AUTH_SESSION_INVALID` | Pass for protected active path | runtime / contracts |
| P0-B appeals POST | `POST /api/app/profile/governance/appeals` | 404 | Pass for reserved/future path | runtime / contracts |
| P0-B password auth | `POST /api/app/auth/password/login` empty body | 400 `AUTH_CONSENT_REQUIRED` | Pass for active auth path | runtime / contracts |
| P0-C exhibition report | Anonymous `POST /api/app/exhibition/report/submit` | 401 from BFF | Pass for fail-close and route exists | runtime |
| P0-C exhibition report | actor hint without valid carrier | 401 from Server | Pass for Server carrier enforcement | runtime |
| P0-C exhibition report | valid App session submit | password login 200；project list 200；`POST /api/app/exhibition/report/submit` 200，返回 `status=submitted`、`acceptMode=created`；账号、token、完整内部 ID 未记录 | Pass for App submit to Server report case input | runtime |
| P0-C Admin visibility | reviewer-capable Server carrier 访问 `/server/admin/exhibition/report-cases?status=submitted&targetType=project&keyword=<masked>` | 200，返回 1 条；包含本轮 report case；账号、token、完整内部 ID 未记录 | Pass for Admin Server API承接 | runtime |
| P0-C Admin visibility | reviewer-capable Server carrier 访问 `/project_review?status=submitted&targetType=project&keyword=<masked>` | 200，页面包含案件队列、target 与 reportCase，未出现鉴权错误 | Pass for Admin 页面承接 | runtime |

## 3. 本地验证记录

| 范围 | 命令 | 结果 |
| --- | --- | --- |
| Server build | `pnpm --filter @exhibition/server build` | 通过 |
| BFF build | `pnpm --filter @exhibition/bff build` | 通过 |
| Admin build | `pnpm --filter @exhibition/admin build` | 通过 |
| Contracts | `pnpm contracts:generate`；`pnpm contracts:check` | 通过 |
| Server P0-C | `node --test apps/server/test/exhibition-report-case-admin.test.cjs` | 通过 |
| BFF P0-C | `node --test apps/bff/test/exhibition-report-submit-transport.test.cjs` | 通过 |
| Mobile P0-C | `flutter test test/exhibition_report_submit_test.dart` in `apps/mobile` | 通过 |
| Mobile P0-D | `flutter test test/profile_page_test.dart --name "settings page opens privacy permissions and legal documents"` in `apps/mobile` | 通过 |
| Admin tests | `npm run --prefix apps/admin test:admin-side -- test/admin-template-config.test.cjs` | 通过 |
| Legal sync | `cmp docs/legal/privacy_policy.md apps/mobile/assets/legal/privacy_policy.md` | 一致 |
| Legal sync | `cmp docs/legal/user_agreement.md apps/mobile/assets/legal/user_agreement.md` | 一致 |
| P0-D iOS plist | `plutil -lint apps/mobile/ios/Runner/Info.plist` | 通过 |
| P0-D iOS plist | `plutil -p apps/mobile/ios/Runner/Info.plist` | 存在 `NSLocationWhenInUseUsageDescription`、`NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription` |

## 4. 残余待复核项

| 编号 | 待复核项 | 必要性 |
| --- | --- | --- |
| R1 | 真机构建截图与应用商店材料核对：协议、隐私、注销受理、客服、SDK 清单、权限说明、支付说明 | P0-D full pass 必需 |
| R2 | 下一次 clean release 统一追平 active artifact 内 contracts/generated，避免运行包中仍保留历史 `message/index` 生成物 | P0-B release hygiene |

## 5. Runtime 裁决

当前 runtime 裁决：P0-A、P0-B、P0-C、P0-E 已关闭本轮 runtime veto；P0-D 已补齐 iOS 相机/相册权限说明配置，但仍缺真机/商店材料证据。P0-B contracts clean-window 本地已对齐，active release 追平属于 release hygiene，不再作为业务功能 veto。

因此只能写 `Go for bounded RC hardening`，不能写 `P0 100% full live pass`。
