# 《enterprise display submit chain runtime drift repair backend execution prompt》

## 角色

你现在是：
- `enterprise display full closure mainline`
- `submit chain runtime drift repair backend owner`

## 唯一目标

你的唯一目标是：
- 修掉 enterprise display submit chain 当前已确认的两条 `Server runtime drift`
- 让后续“真实补齐资料 -> 真实提交成功”建立在干净对象上，而不是建立在脏 draft 与脏 certification snapshot 上

## 当前已冻结事实

根据 [enterprise_display_submit_chain_runtime_scan_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_submit_chain_runtime_scan_receipt_addendum.md)：

1. 当前 organization certification 已被清空。
2. 当前 organization 注册城市真值仍未成立。
3. 当前 listing `basic/profile/case` 都未完成，因此 final submit 现在不应该成功。
4. 当前 runtime 还存在两条额外 drift：
   - 同一 listing 下已累计 `19` 条 `draft application`
   - organization certification 清空后，`enterprise_certification_snapshot` 仍残留 `approved`

## 这一步只做

- `createApplication` draft 去重 / 复用
- `certificationSyncService` 在 certification 删除场景下的 snapshot 清理
- 当前 active dirty listing 的受控数据修复

## 这一步不做

- 不改 `apps/mobile/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不放宽 submit 条件
- 不删除 `basic/profile/case/contact/certification` 任一 submit gate
- 不扩到 review/publish/list/detail
- 不做 release / deploy

## 允许修改范围

- `apps/server/src/modules/enterprise_hub/**`
- 与本轮 drift repair 直接相关的最小测试文件
- 如必须存在一次性 repair unit，可采用最小 migration 或最小受控 repair script，但必须只围绕当前 drift，不得扩成通用数据库清洗工具

## 你必须完成

### 1. 收掉 draft application 重复创建

- 当前 `createApplication()` 在 listing 已存在时，仍会继续创建新 draft。
- 你必须改成：
  - 若当前 listing 下已存在可编辑 draft application，则直接复用该 draft
  - 不得为同一 listing 无限制累积新的 draft application

### 2. 收掉 certification snapshot stale drift

- 当前 `certificationSyncService.syncForListing()` 在 organization certification 不存在时：
  - 会把 listing `verificationStatusSnapshot` 写成 `null`
  - 但不会删除已有 `enterprise_certification_snapshot`
- 你必须改成：
  - 当当前 organization certification 不存在时，listing verification snapshot 与 certification snapshot 都回到一致的“无当前认证”状态
  - 不得继续保留 stale `approved business_license snapshot`

### 3. 对当前 active dirty listing 做受控修复

- 当前 active listing：
  - `enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
  - `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`
- 当前必须交付一份受控 repair 方案，使它满足：
  - 多余 draft application 被收敛
  - stale certification snapshot 被清理
- repair 必须是可复核的，不得手工黑盒“改完就算”

### 4. 补测试

至少补以下覆盖：

1. listing 已有 draft application 时，`createApplication()` 不再创建第二条 draft，而是返回现有 draft
2. 当前 organization certification 不存在时，`syncForListing()` 会清理 stale certification snapshot
3. 当前 organization certification 存在且 approved 时，`syncForListing()` 仍能正常生成 / 更新 snapshot

## 你必须遵守

1. 不得把问题转嫁给前端“不要重复点”。
2. 不得通过放宽 `submitReady` 或 submit write gate 来伪装成功。
3. 不得保留“无当前认证，但 snapshot 仍 approved”的双真相漂移。
4. 不得继续允许同一 listing 无限堆积 draft application。
5. 不得顺手扩到其他对象家族。

## 完成标准

结果必须证明：

1. 同 listing 的 draft application 不再无限增长
2. 当前 certification 被清空后，listing 与 certification snapshot 都回到一致状态
3. 当前 active dirty listing 有明确 repair 结果
4. 后续用户重新补：
   - 我的公司注册城市
   - 企业认证
   - basic
   - factory profile
   - case
   后，final submit 才是在干净状态上进行

## 交付回执要求

1. 修改文件清单
2. 为什么当前会出现重复 draft application
3. 为什么当前会出现 stale certification snapshot
4. 代码修复策略
5. 当前 active listing 的受控 repair 结果
6. 新增或更新的测试结果
7. 仍未覆盖的非目标清单
