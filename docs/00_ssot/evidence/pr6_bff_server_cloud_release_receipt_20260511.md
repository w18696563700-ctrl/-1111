# PR #6 BFF + Server Cloud Release Receipt

归档时间：2026-05-11

## 一、总裁决

Cloud release result：**Conditional Pass**

- BFF release：**PASS**
- Server release：**PASS**
- Admin：**unchanged**
- Read-only smoke：**PASS**
- Write smoke：**NOT RUN**
- Payment / APNs / Alipay runtime：**NOT RUN**
- Migration：**NOT RUN**
- RC full release：**NOT SIGNED**

本回执只证明 PR #6 已完成 BFF + Server 云端只读发布闭环，不等于 App 已上线完成，不等于支付已上线，不等于 APNs 已上线，也不等于 RC Go。

## 二、发布基线

- main HEAD：`5e7a2bbe29228394c0ae5c7fd81c087f26b2797c`
- PR：`#6 Merge RC guarded bid attachment material review candidate`
- BFF new active release：`/srv/releases/bff/20260511001102-pr6-5e7a2bbe`
- Server new active release：`/srv/releases/server/20260511001102-pr6-5e7a2bbe`
- Admin unchanged release：`/srv/releases/admin/20260503034500-d97a3f2-main-phase-a3`
- BFF rollback release：`/srv/releases/bff/20260510115427-message-interactions-p1-controlled`
- Server rollback release：`/srv/releases/server/20260510193954-message-interactions-p1-unread-seed-4files`
- Rejected BFF artifact：`/srv/releases/bff/20260511000153-pr6-5e7a2bbe`，**do not use**
- Rejected Server artifact：`/srv/releases/server/20260511000153-pr6-5e7a2bbe`，**do not use**

## 三、阶段结果

- Phase 0：只读云端 runtime smoke 通过。
- Phase 1：本地 build / artifact 审查通过。
- Phase 1b：本地 staging 初版因 pnpm `node_modules` symlink 断链，No-Go。
- Phase 1c：Linux-safe dependency strategy 通过。
- Phase 2：首次 inactive upload 因 AppleDouble `._*` forbidden files，No-Go。
- Phase 2 corrective：clean inactive upload 通过。
- Phase 3：pre-switch read-only check 通过。
- Phase 4：BFF switch 通过。
- Phase 5：Server switch 初次 No-Go，rollback 后 health 曾短暂 502。
- Server rollback-after-502 diagnosis：Conditional Pass，判断为 restart readiness window。
- Stability recheck：PASS。
- Phase 5 retry：Conditional Pass，Server 切换成功，但记录短暂 `000/502` 与 BFF PID 变化。
- Phase 6：read-only smoke PASS。
- Phase 7：receipt only，未执行任何新命令。

## 四、Health / Smoke 结果

- BFF health：`10/10 = 200`
- Server health：`10/10 = 200`
- Project list/detail GET：`200`
- Forum / message / profile / membership 等未登录 GET：`401`，按 fail-closed 记录。
- bid thread / bid-service-fee / authenticity-sincerity 相关 GET：`403`，按 RC guard disabled 记录。
- 没有把 `401/403` 解释为开放能力。

## 五、边界确认

本次没有执行：

- `POST / PUT / PATCH / DELETE`
- 登录写入
- read-cursor
- 支付
- Alipay handoff
- APNs token 注册
- 项目发布
- 文件上传
- Admin 审核写入
- migration
- env 修改
- Nginx 修改
- DB 修改

## 六、风险记录

1. Phase 5 初次 Server switch 后 health 502，已 rollback。
2. rollback 后短时 502，后续诊断为 restart readiness window。
3. Phase 5 retry 第 1 轮出现 Server direct `000`、Server Nginx `502`、BFF Nginx `502`。
4. Phase 5 retry 第 2 轮恢复 `200`，stable confirmation `3/3 = 200`。
5. BFF PID 在发布窗口发生变化；虽未主动 restart BFF，但必须作为风险记录。
6. Phase 6 后未再出现 502 / upstream refused。
7. APNs / Alipay / real payment 未验证，不能宣称上线。

## 七、回滚策略

- BFF rollback target：`/srv/releases/bff/20260510115427-message-interactions-p1-controlled`
- Server rollback target：`/srv/releases/server/20260510193954-message-interactions-p1-unread-seed-4files`
- 如仅 Server 失败，优先 rollback Server。
- 如 BFF + Server 兼容异常，再双回滚。
- Rejected artifact 不得作为 rollback target。
- rollback 后必须重新 health + read-only smoke。

## 八、最终裁决

- `BFF + Server cloud release: Conditional Pass`
- `Read-only runtime smoke: PASS`
- `Write-path runtime: NOT VERIFIED`
- `Payment runtime: NOT VERIFIED`
- `APNs runtime: NOT VERIFIED`
- `Alipay runtime: NOT VERIFIED`
- `Admin deploy: NOT INCLUDED`
- `App Store / RC release: No-Go until separate full RC audit`

## 九、下一步建议

1. 归档 release receipt。
2. 单独开写路径 smoke 门禁。
3. 单独开 APNs 真机专项。
4. 单独开 Alipay 真实支付专项。
5. 后续再做上线 RC 全量复核。

准确结论：**PR #6 已完成主线合并与 BFF/Server 云端只读发布闭环；上线 RC 仍需后续专项门禁。**
