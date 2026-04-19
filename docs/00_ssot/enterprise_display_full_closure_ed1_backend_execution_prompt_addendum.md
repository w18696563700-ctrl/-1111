---
owner: Codex 总控
status: frozen
purpose: Provide the single backend execution prompt for ED-1 of the enterprise-display full-closure mainline, so the next step starts from upstream truth repair only.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_mainline_ruling_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md
---

# 《enterprise display full closure ED-1 backend execution prompt》

## 1. 当前唯一任务

- 你现在是：
  - `enterprise display full closure mainline`
  - `ED-1 backend execution owner`
- 你的唯一目标是：
  - 修复 `enterprise display` 主线的上游真值阻断
  - 让 workbench 后续可以真实发出 `PUT basic`
- 这一步只做：
  - `organization` 有效省市真值修复
  - `certification` 的 `establishedAt/address` 真值修复
- 这一步不做：
  - mobile 绕过
  - BFF 兼容补丁
  - workbench 新功能扩写
  - admin publish/review
  - release / deploy

## 2. 当前阻断事实

- 当前 active runtime 已确认：
  - `organization.provinceCode = 000000`
  - `organization.cityCode = 000000`
  - `certification.establishedAt = null`
  - `certification.address = null`
- 当前直接后果：
  - mobile workbench 因无效城市真值，不发 `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  - workbench `basic.*` 为空
  - `submitReady = false`
- 当前明确不是根因：
  - 不是 BFF 转发丢字段
  - 不是 Server factory profile save 链故障
  - 不是“只要切本地 Server 版就能解决”

## 3. 允许修改范围

- 只允许修改：
  - `apps/server/src/modules/organization/**`
  - 与 `organization/certification` 真值读取直接相关的最小 `apps/server` carrier
  - 必要时最小修补 `apps/server/src/modules/enterprise_hub/**` 中直接消费上述真值的部分
- 不允许修改：
  - `apps/mobile/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - 无关主线文件

## 4. 你必须完成

1. 查明为什么当前 active organization 真值允许 `provinceCode/cityCode = 000000` 落入正式对象。
2. 在 organization create/update 真值写链中，阻断 `000000` 这类无效占位值继续写入。
3. 为当前出问题的 active organization 提供受控修复方案，使 `organization mine` 返回有效省市 code。
4. 查明 `certification.establishedAt/address = null` 的真实原因：
   - OCR 未识别
   - 已识别但未持久化
   - 已持久化但未正确回读
5. 在不引入第二真源的前提下，把 workbench 依赖的 `foundedAt/address` 修回到可消费状态。

## 5. 你必须遵守

1. 不得让前端新增第二套注册城市选择器。
2. 不得让前端新增第二套成立日期输入源。
3. 不得把 `000000` 当合法城市真值继续保留。
4. 不得为了让按钮亮起来而放松 Server readiness 真值要求。
5. 不得把问题重写成 BFF 或 mobile 的容错逻辑。
6. 不得改成“无论真值是否有效，都允许先保存 basic”。

## 6. 完成标准

- 结果必须证明：
  - `GET /api/app/profile/organization/mine` 不再返回 `000000`
  - workbench 不再因“注册城市真值不可用”而在本地直接 return
  - workbench 后续真实操作下，`PUT basic` 可以发出
  - `certification.establishedAt/address` 已能被 workbench 正确消费
- 这一步不要求你证明：
  - application submit 已闭环
  - admin review/publish 已闭环
  - 公域 list/detail 已闭环

## 7. 交付回执要求

- 你完成后必须给出：
  1. 修改文件清单
  2. 根因说明
  3. 修复策略说明
  4. 至少一个编译/测试/接口验证结果
  5. 仍未覆盖的非目标清单

## 8. 当前下一步

- 当前阶段完成度：
  - `dispatch 完成`
- 当前下一步唯一动作：
  - 发出本口令给 `后端`
- 下一步执行角色：
  - `后端`
- 下一步进入条件：
  - 本口令文书已冻结
