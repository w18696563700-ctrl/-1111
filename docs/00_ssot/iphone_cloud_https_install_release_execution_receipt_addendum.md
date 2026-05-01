---
owner: Codex 总控
status: frozen
purpose: Freeze the Day-1 to Day-4 execution truth for the iPhone cloud-direct installation round, without counting uninstalled or runtime-unverified functions as passed.
layer: L0 SSOT
---

# 《iPhone 云端 HTTPS 直连安装发布执行回执》

## 1. 总裁决

本轮最终裁决：`NO-GO for final iPhone acceptance`。

已通过的最小闭环：

- 云端 `Nginx 443` 已可用。
- App 线上请求入口已从 `http` 收敛到 `https`。
- iOS build / archive / development export 已成功。
- 当前可导出的包已注入 `APP_RUNTIME_ENTRY_MODE=cloud` 与 `https://47.108.180.198/api/app`，不会依赖本地隧道。

未通过的最终验收项：

- 未完成正式 `Ad Hoc` 或 `TestFlight` 分发。
- 未完成 iPhone 真机安装。
- 未完成关闭本地电脑和隧道后的蜂窝网络真机 smoke。
- 未取得有效登录态，因此不得把登录后业务操作计入通过项。

## 2. 分发路径选择

本轮正式分发路径选择：`Ad Hoc` 优先，`TestFlight` 后置。

选择理由：

- 当前目标是安装到已知单台 iPhone 并做蜂窝网络 smoke，`Ad Hoc` 的流程更短。
- `TestFlight` 需要 App Store Connect app record、App Store/TestFlight provisioning、上传处理与测试员分发，当前 blocker 更多。
- `Ad Hoc` 只需要 Apple Distribution 证书、`com.zhanlandingzhijia.mobile` 的 release-testing provisioning profile，并包含目标 iPhone UDID。
- 当前已有 development profile 包含目标 iPhone UDID，可用于临时开发安装 smoke；但它不是正式 Ad Hoc，也不能冒充 TestFlight。

成本与风险判断：

| 路径 | 稳定性 | 成本 | 当前阶段适配 | 风险 |
| --- | --- | --- | --- | --- |
| Ad Hoc | 更稳于单机验收 | 更省 | 最适合当前阶段 | 依赖证书/profile 精确匹配 |
| TestFlight | 更适合多人扩展 | 更高 | 适合后续扩展 | 当前 App Store Connect 与上传链路 blocker 更多 |
| Development install | 只适合本机临时 smoke | 最省 | 可作为当前断点续装路径 | 不是正式分发，不满足最终发布验收 |

## 3. Day-by-Day 执行事实

| Day | 谁做 | 做什么 | 产出 | 验收 | 风险 | 下一天门禁 |
| --- | --- | --- | --- | --- | --- | --- |
| Day 1 | 总控 + 云端 | 启用 Nginx 443，部署可被 iOS 校验的 HTTPS 证书，更新正式云端入口 | `https://47.108.180.198/api/app` | `curl https://47.108.180.198/health/bff/ready = 200`；`GET /api/app/project/list = 200`；证书 SAN 包含 `IP Address:47.108.180.198` | 正式域名仍受 ICP / CA blocker；IP 证书为短期证书 | HTTPS 入口可被 iOS ATS 接受 |
| Day 2 | iOS | 构建 cloud-direct iOS 包，核对 ATS 与签名 | `build/ios/export-development/展览定制之家.ipa` | `flutter build ios --profile`、`xcodebuild archive`、development export 均成功 | 缺 Apple Distribution 与 Ad Hoc profile，不能导出正式 IPA | 仅允许进入临时 development install；正式 Ad Hoc 需补签名材料 |
| Day 3 | iPhone 联调 | 安装 IPA 并蜂窝网络 smoke | 未产出真机证据 | `王巍威的iPhone` 在 CoreDevice / xctrace 中仍为 offline / unavailable，install 被阻断 | 设备未被 Mac 当前会话识别；登录态不可用 | iPhone 必须 available，且有有效登录凭证后才能进入业务 smoke |
| Day 4 | 总控 | 结果校验与回执冻结 | 本回执 | blocker 未全清 | runtime、证书和签名材料均可能漂移 | 不允许进入 TestFlight 扩展，允许先补 Ad Hoc 与真机门禁 |

## 4. iOS 打包与签名 Blocker

| Blocker | 当前证据 | 影响 | 最小修复 |
| --- | --- | --- | --- |
| 缺 Apple Distribution identity | 本机 codesigning identity 只有 `Apple Development` | 无法导出正式 Ad Hoc / TestFlight IPA | 在 Apple Developer 创建并安装 Apple Distribution 证书 |
| 缺 `com.zhanlandingzhijia.mobile` Ad Hoc profile | 当前 archive 使用 `iOS Team Provisioning Profile: *`，`get-task-allow=true` | 当前 IPA 是 development signed | 创建 `release-testing` / Ad Hoc profile，包含目标 iPhone UDID |
| TestFlight 资料未就绪 | 当前未见 App Store Connect 上传链路和 App Store profile | 不能走 TestFlight | 建 app record、配置 bundle、App Store Connect signing profile 后再上传 |
| iPhone 不可用 | `王巍威的iPhone` 显示 offline / unavailable | 不能安装 | 解锁、信任电脑、更换线缆或端口，直到 Xcode/CoreDevice 显示 available |

## 5. 云端直连 Blocker

| Blocker | 当前证据 | 影响 | 最小修复 |
| --- | --- | --- | --- |
| 正式域名不可用 | `zhanlan.ddup-ddup.com` 当前公开访问受 ICP / 证书链阻断 | 不能冻结品牌域名为正式线上地址 | 完成备案/接入与域名证书后切换 `FORMAL_CLOUD_HOST` |
| IP SAN 证书有效期短 | 当前 HTTPS 证书为短期 IP SAN 证书 | 可做本轮真机 smoke，不适合长期发布 | 建续签自动化，或尽快替换为正式域名证书 |
| 登录态未取得 | `otp/login` 样本返回 `AUTH_LOGIN_INVALID` | 登录后消息、我的、私域业务不能计入通过项 | 提供有效测试账号/验证码/密码，或打开受控非生产测试会话 |
| 受保护接口未登录返回 401 | `/message/interactions`、`/profile/index`、`/shell/context` 未登录均返回 401 | 这是受控行为，不是功能通过 | 取得 session 后再做登录态业务 smoke |

## 6. 当前 Runtime 可验功能冻结

可计入当前 cloud-direct smoke 的功能：

- App 启动入口使用云端 HTTPS。
- 展览首页公共读：`GET /api/app/exhibition/home = 200`。
- 项目列表公共读：`GET /api/app/project/list = 200`。
- 企业展示推荐公共读：`GET /api/app/exhibition/enterprise-hub/recommendations?boardType=company = 200`。
- 企业展示列表公共读：`GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1 = 200`。
- Board-scoped 企业展示公共读：`GET /api/app/exhibition/enterprise-hub/company/recommendations = 200`。
- Board-scoped 企业列表公共读：`GET /api/app/exhibition/enterprise-hub/company/enterprises?page=1&pageSize=1 = 200`。
- 未登录保护：`/message/interactions`、`/profile/index`、`/shell/context` 返回受控 `401 AUTH_SESSION_INVALID`。

不得计入通过的功能：

- 未安装到 iPhone 的任何真机行为。
- 未蜂窝网络验证的任何 App 内业务操作。
- 未登录状态下的消息、我的、会员、私域工作台操作。
- 404、文书冻结但 runtime 未通、或非 canonical path 的能力。
- `renovation`、`custom_furniture` 预埋楼，不进入首发通过项。

## 7. iPhone 安装步骤

当前临时续装路径：

1. 解锁 `王巍威的iPhone`。
2. 使用数据线直连 Mac，iPhone 弹窗时选择信任/允许。
3. 在 Mac 上确认设备变为 available：
   - `xcrun devicectl list devices`
   - `flutter devices`
4. 安装当前 development-signed App：
   - `xcrun devicectl device install app --device 00008130-000A0D313620001C apps/mobile/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app`
5. iPhone 打开展览定制之家，关闭 Wi-Fi，保留蜂窝网络。
6. 进行公共读 smoke 与登录页 smoke。

正式 Ad Hoc 路径：

1. 补齐 Apple Distribution 证书。
2. 创建 `com.zhanlandingzhijia.mobile` Ad Hoc / release-testing profile，包含 `00008130-000A0D313620001C`。
3. 使用 `method=release-testing` 重新 export IPA。
4. 安装导出的 Ad Hoc IPA。
5. 重跑蜂窝网络 smoke。

## 8. 蜂窝网络联调验证清单

| 验证项 | 预期 |
| --- | --- |
| 本地电脑关闭或不提供隧道 | App 仍能启动 |
| iPhone Wi-Fi 关闭 | App 仍通过蜂窝访问云端 |
| App 请求地址 | 只允许 `https://47.108.180.198/api/app` 或后续正式 HTTPS 域名 |
| ATS | 不允许 `NSAllowsArbitraryLoads=true` |
| 展览首页 | 可加载公共首页 |
| 项目列表 | 可加载公共项目列表 |
| 企业展示 | 可加载 company 推荐/列表 |
| 登录页 | 协议勾选与登录错误提示正常 |
| 登录态消息/我的 | 只有取得有效 session 后才能验收 |

## 9. 最终回执

`Day 1 = Conditional Pass`：云端 HTTPS 可用，但正式域名未闭环，IP 证书需续签或替换。

`Day 2 = Conditional Pass`：iOS archive/export 可用，但当前是 development signed，不是正式 Ad Hoc/TestFlight。

`Day 3 = No-Go`：iPhone 当前不可用，未安装，未完成蜂窝网络 smoke。

`Day 4 = No-Go`：blocker 未全清，不允许声称正式通过；允许进入下一轮最小补齐：设备 available、Ad Hoc signing、有效登录态。

## 10. 后续补证：云端 OTA 兜底入口

在用户确认 iPhone 已解锁并接入数据线后，Mac 侧仍显示：

- `xcrun devicectl list devices`：`王巍威的iPhone = unavailable`
- `xcrun xctrace list devices`：`王巍威的iPhone = Devices Offline`
- USB 物理扫描未稳定发现 iPhone 数据通道

因此本轮追加一个不依赖本地电脑、不依赖 localhost、不依赖局域网的云端 HTTPS OTA 兜底入口：

- 安装页：`https://47.108.180.198/ios-install/`
- Manifest：`https://47.108.180.198/ios-install/manifest.plist`
- IPA：`https://47.108.180.198/ios-install/exhibition-custom-home.ipa`

当前云端验证：

| Item | Result |
| --- | --- |
| `GET /ios-install/index.html` | `200`, `Content-Type: text/html` |
| `GET /ios-install/manifest.plist` | `200`, `Content-Type: text/xml` |
| `GET /ios-install/exhibition-custom-home.ipa` | `200`, `Content-Length=9926684` |
| `GET /ios-install/` | `302 -> /ios-install/index.html` |

边界裁决：

- 该入口只能作为当前 development-signed 包的安装兜底。
- 该入口不改变 Day 2 的正式签名 blocker。
- 若 iOS 拒绝 development-signed OTA 安装，仍必须回到 USB/Xcode 安装或补齐正式 Ad Hoc。
- 未看到 iPhone 成功安装与蜂窝 smoke 前，Day 3 / Day 4 仍保持 `No-Go`。
