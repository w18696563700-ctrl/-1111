---
owner: Codex 总控
status: frozen
purpose: Freeze the next unique repair dispatch for enterprise display workbench V1 after the current-runtime blocker verdict, so execution starts from upstream truth repair instead of masking the issue in mobile or misrouting blame to BFF transport.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
  - apps/server/src/modules/organization/organization-write.service.ts
  - apps/server/src/modules/organization/entities/organization.entity.ts
  - apps/server/src/modules/organization/entities/organization-certification.entity.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
---

# 企业展示工作台 V1 真值修复派工单

## 1. 阶段目标

- 当前阶段只解决：
  - `organization` 省市真值无效
  - `certification` 补充真值缺失
  - `enterprise display workbench` 因上游真值无效而无法发出 `PUT basic`
- 当前阶段不解决：
  - workbench 新功能扩写
  - BFF route 扩容
  - Admin publish / offline
  - 直接发布现网

## 2. 阶段前置

- 以下条件已成立：
  - [enterprise_display_workbench_v1_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md) 已冻结 workbench 真值边界
  - [enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md) 已冻结当前“不通过”裁决
  - [exhibition_app_full_function_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_app_full_function_register_v1.md) 已把 `EXH-006A` 登记为 `阻断中`

## 3. 当前主阻塞

- 当前第一阻塞固定为：
  - `organization.provinceCode = 000000`
  - `organization.cityCode = 000000`
- 当前第二阻塞固定为：
  - `certification.establishedAt = null`
  - `certification.address = null`
- 当前第三阻塞固定为：
  - mobile 依据上述真值正确拦截，导致 `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic` 未发出
- 当前明确不是主阻塞：
  - BFF 转发
  - Server profile save 链
  - “直接切本地 Server 版”

## 4. judgment

- 当前裁决：
  - `允许进入 repair dispatch`
- 当前唯一主线：
  - `enterprise display workbench upstream truth repair`
- 当前禁止抢跑：
  - 不允许先改 mobile 去绕过 `000000`
  - 不允许先改 BFF 去伪造城市/成立日期
  - 不允许在 workbench 页内新增第二套城市选择器或成立日期输入源

## 5. dispatch

- 当前第一执行角色：
  - `后端`
- 当前第一执行范围：
  - [organization-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/organization-write.service.ts)
  - [organization.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/entities/organization.entity.ts)
  - [organization-certification.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/entities/organization-certification.entity.ts)
  - 与组织/认证真值读取直接相关的 current active carrier
- 当前第二执行角色暂不进入：
  - `BFF`
  - `前端`
- 原因固定为：
  - 这轮先修真值 owner，避免下游消费层继续围绕无效真值打补丁

## 6. implementation

- 后端本轮必须完成：
  - 查明当前 active organization 真值为什么允许 `provinceCode/cityCode = 000000` 落入正式对象
  - 在 organization create/update 真值写链中，阻断已知无效占位值 `000000`
  - 对当前出问题的 active organization 做一次受控真值修复，使 `organization mine` 返回有效省市 code
  - 查明 `certification` 补充真值里 `establishedAt/address` 为空的真实原因，是 OCR 未识别、未持久化，还是未正确回读
  - 在不引入第二真源的前提下，把 workbench 依赖的 `foundedAt/address` 真值修回到可消费状态
- 后端本轮禁止做：
  - 不得把 `000000` 当成可接受城市真值继续放行
  - 不得把 workbench 改成可手填第二套注册城市
  - 不得为了“先让按钮亮起来”而放松 submit/readiness 的真值要求
  - 不得把问题伪装成 BFF 字段兼容问题
- 前端本轮只允许：
  - 保持当前 guard，不私自绕过
  - 在真值修复完成后配合复测

## 7. verification

- 结果校验必须逐条通过：
  - `GET /api/app/profile/organization/mine` 返回的 `provinceCode/cityCode` 不再是 `000000`
  - mobile 我的公司页能把当前组织的注册城市解析成真实地区名
  - workbench 页面不再弹出“当前还没有同步到可用的注册城市真值”
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic` 在真实操作下确实发出，而不是本地 return
  - `GET /api/app/exhibition/enterprise-hub/workbench?boardType=factory` 回读后，`basic.provinceCode/cityCode` 与 `basic.provinceName/cityName` 不再为空
  - 若用户已填写名称与简介，则 `readiness.basicCompleted = true`
- 当前不以以下结果作为通过标准：
  - 仅靠截图看到按钮变亮
  - 仅靠本地 repo 编译通过
  - 仅靠 BFF 日志 `200`

## 8. closure

- 本阶段完成后，正式收口成以下结论：
  - workbench 当前主阻断已从“上游真值无效”转入“下游真实行为复测”
  - `enterprise display workbench V1` 允许进入下一轮 result verification
  - 仍不等于 release pass

## 9. next route

- 当前阶段完成度：
  - `dispatch 完成`
- 当前下一步唯一动作：
  - 向 `后端` 发出 `organization/certification upstream truth repair` 执行任务
- 下一步执行角色：
  - `后端`
- 下一步进入条件：
  - 本派工单已落盘，且当前“不通过”裁决没有新增反证
