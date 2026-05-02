# Platform Pricing Cloud Parity Deployment And Day11 Rerun Receipt

## 1. Stage Scope

本阶段单独处理“云端部署一致性 / 路由对齐”问题。

本阶段只做：

- 将包含新 pricing route family 的 Server release 部署到阿里云。
- 将包含新 pricing route family 的 BFF release 部署到阿里云。
- 对齐 Nginx 后的 app-facing routes 与 Server canonical routes。
- 重跑 Day11 云端验真。
- 记录部署、进程收敛、路由修复、验真结果和剩余风险。

本阶段不做：

- 不新增收费业务规则。
- 不改 Flutter。
- 不改数据库业务数据结构。
- 不开通真实支付 runtime。
- 不做 release-prep。
- 不做生产流量切换之外的额外云端治理。

## 2. Release Information

- Release id: `20260430012927-platform-pricing-cloud-parity`
- Server current: `/srv/releases/server/20260430012927-platform-pricing-cloud-parity`
- BFF current: `/srv/releases/bff/20260430012927-platform-pricing-cloud-parity/apps/bff`
- PM2 Server process: `server-s6-r6`
- PM2 BFF process: `bff-s6-r4`
- App tunnel validation base: `http://127.0.0.1:8080`

Previous cloud targets recorded before switch:

- Previous Server: `/srv/releases/server/20260429182729-bid-participation-source-cleanup`
- Previous BFF: `/srv/releases/bff/20260429182729-bid-participation-source-cleanup/apps/bff`

## 3. Pre-Deploy Verification

Local pre-deploy checks passed before upload:

- Server build: passed.
- BFF build: passed.
- Server targeted tests: `40/40` passed.
- BFF targeted tests: `40/40` passed.

The deployed tarballs were built from the local workspace after the platform pricing Server and BFF changes were present.

## 4. Deployment Actions

Deployment actions completed:

- Packaged Server release tarball.
- Packaged BFF release tarball.
- Uploaded both tarballs to Aliyun.
- Created new release directories under `/srv/releases/server` and `/srv/releases/bff`.
- Copied existing cloud `.env` files into the new release directories.
- Reused existing Linux `node_modules` via symlink.
- Wrote release-local `start.sh` for Server and BFF.
- Switched `/srv/apps/server/current` and `/srv/apps/bff/current` symlinks.
- Restarted PM2 processes.

Process convergence issue found and fixed:

- Symptom: Server PM2 process entered restart loop because port `3001` was still held by an old Server node process from the previous release.
- Fix: stopped `server-s6-r6`, killed the old `3001` owner process, restarted `server-s6-r6`.
- Final state: BFF owns `3000`, Server owns `3001`, both PM2 processes are online.

## 5. Route Parity Result

Before this stage:

- `/api/app/project/:projectId/pricing-summary` returned router-level `404` in cloud.
- Cloud BFF did not contain the new `app-project-pricing.controller` route family.

After this stage:

- BFF app-facing pricing summary route returns `200`.
- Server canonical pricing summary route returns `200`.
- App-facing response carries new pricing summary fields:
  - `publisherPricing.authenticitySincerityAmount = 200.00`
  - `publisherPricing.publishGateStatus = required`
  - `bidderPricing.authorizationQuotaAmount = 4000.00`
  - `bidderPricing.bidSubmissionEligible = false`
  - `readOnly = true`

## 6. Day11 Rerun Result

Day11 rerun was executed through the tunnel against Aliyun BFF and Server.

| Area | Result | Evidence |
| --- | --- | --- |
| Login/session | Passed | `/api/app/shell/context` returned `200` with authenticated shell context. |
| Profile organization | Passed | `/api/app/profile/organization/mine` returned `200`. |
| Project list | Passed | `/api/app/project/list?page=1&pageSize=5` returned `200` with 5 items. |
| Pricing summary route | Passed | `/api/app/project/a541e9ac-1c0f-4224-a399-25c6b8a7f310/pricing-summary` returned `200`. |
| Publish 200 gate | Passed | Publishing project `204daf45-f26f-4675-b9a5-bab3303dafea` without 200 freeze returned `409 PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`. |
| Bid 4000 gate | Passed | Submitting bid on approved-participation project `5beb03bf-9489-4892-a641-23ec60f395ff` without frozen 4000 returned `409 BID_SERVICE_FEE_AUTHORIZATION_REQUIRED`. |
| Company home/list/recommend/detail | Passed | Company workbench/list/recommendation/detail all returned `200`. |
| Factory home/list/recommend/detail | Passed | Factory workbench/list/recommendation/detail all returned `200`. |
| Supplier home/list/recommend/detail | Passed | Supplier workbench/list/recommendation/detail all returned `200`. |
| Forum feed/topic/me/inbox | Passed | Feed, topic list, me index, replies, likes, follows all returned `200`. |
| Forum logged-in actions | Passed | Post like/unlike and bookmark/add-remove returned `202`; final post detail restored to unliked and unbookmarked. |
| Message interactions | Passed | `/api/app/message/interactions?page=1&pageSize=5` returned `200`. |

## 7. Validation Details

Project publish gate evidence:

- Project: `204daf45-f26f-4675-b9a5-bab3303dafea`
- Result: `409`
- Code: `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`
- Message: `发布项目需先完成 200 元项目真实性诚意金冻结。`

Bid submit gate evidence:

- Project: `5beb03bf-9489-4892-a641-23ec60f395ff`
- Existing participation state: approved
- Existing authorization state: failed
- Required quota shown by pricing summary: `4000.00`
- Result: `409`
- Code: `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED`
- Message: `竞标申请已通过后需先冻结 4000 元竞标服务费预授权额度，冻结成功后才能提交竞标。`

Forum action evidence:

- Post: `ac2e788d-4d5e-4b0d-a0e4-ca708927d963`
- Initial state: `viewerHasLiked=false`, `viewerHasBookmarked=false`
- Like action: `202 liked`
- Unlike action: `202 unliked`
- Bookmark add action: `202 bookmarked`
- Bookmark remove action: `202 unbookmarked`
- Final post detail: `viewerHasLiked=false`, `viewerHasBookmarked=false`

Enterprise detail samples:

- Company: `e2a016f4-0b6a-497d-902c-409413858ca9`
- Factory: `a9b46040-956e-44fd-8e35-e3c533687e27`
- Supplier: `c0576f5c-854c-4b78-9f93-6d57e55d8b47`

## 8. Stage Gate Conclusion

Passed gates:

- Cloud BFF and Server are on the same platform pricing release.
- BFF route family no longer lags behind Server.
- Pricing summary app route is materialized in cloud.
- Publish chain now fails closed on missing 200 freeze.
- Bid submit chain now fails closed on missing frozen 4000 authorization.
- Forum logged-in action chain is still usable after deployment.
- Company, factory, supplier read surfaces are still usable after deployment.
- Message interactions did not regress.

Failed gates:

- None for this stage.

Veto gates:

- None for this stage.

Decision:

- Go for focused product/UAT validation on the deployed cloud build.
- Go for reopening release-prep discussion if the next stage is desired.
- No-Go for claiming real payment runtime readiness; this stage only proves route parity, gates, and cloud behavior under current feature boundary.
