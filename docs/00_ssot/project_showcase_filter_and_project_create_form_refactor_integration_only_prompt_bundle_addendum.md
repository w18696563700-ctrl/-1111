---
owner: Codex 总控
status: active
purpose: Freeze the integration-only prompt bundle for the project showcase filter and project create form refactor object so the release-integration role verifies only the current development-stage canonical chain and does not drift into release-prep or production-release language.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_integration_release_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_result_verification_review_conclusion_addendum.md
  - docs/00_ssot/project_topology_and_tunnel_rules_round0.md
---

# 《项目展示筛选与创建表单重构 integration-only prompt bundle》

## 当前阶段

- 主对象：
  - `项目展示筛选与创建表单重构`
- 子阶段：
  - `development-stage integration release verification`
- 当前只允许处理：
  - 当前 canonical chain 的联调验证

## 当前唯一动作

- 发给 `联调发布 Agent` 的唯一执行口令如下。

```text
你是联调发布 Agent，现在进入《项目展示筛选与创建表单重构》的 integration-only 阶段，但只限 current development-stage canonical chain，不得偷换为 release-prep 或 production release。

【一、当前总控放行结论】
当前已放行范围只限：
- `project/create` dual-field mode
- `project/create` legacy-title mode
- `project/list` 的：
  - `provinceCode`
  - `cityCode`
  - `areaBucket`
  - `budgetBucket`
- `project/detail` 的双字段优先读取
- expired public continuation unavailable

当前边界必须写死：
- 这是 development-stage integration verification
- 不是 release-prep
- 不是 production release
- 不扩到：
  - `my/projects`
  - workbench
  - 附件公开
  - 审核状态机
  - 交易后链

【二、固定验证入口】
- host:
  - `47.108.180.198`
- tunnel:
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- local validation base:
  - `http://127.0.0.1:8080`

【三、固定登录样本】
- mobile:
  - `18696563700`
- otpCode:
  - `000000`
- organizationId:
  - `e6bf4567-016e-45f9-9420-9c950237690e`

【四、你必须覆盖的联调链路】
按这个顺序执行并记录：

1. 登录
- `POST /api/app/auth/otp/login`

2. 切组织
- `POST /api/app/profile/organization/switch`

3. dual-field create
- `POST /api/app/project/create`

4. dual-field detail
- `GET /api/app/project/detail?projectId=<freshDualFieldProjectId>`

5. legacy-title create
- `POST /api/app/project/create`

6. legacy-title detail
- `GET /api/app/project/detail?projectId=<freshLegacyProjectId>`

7. filtered list
- `GET /api/app/project/list?provinceCode=650000&cityCode=650100&areaBucket=36_sqm&budgetBucket=8_10w`

8. expired list trimming
- 使用 expired 对应 query 复核 public list 不再承接 expired 样本

9. expired detail unavailable
- `GET /api/app/project/detail?projectId=66f189e3-864a-4802-8cab-2e031857e8a2`

【五、你必须回答的问题】
A. 当前 canonical chain 是否真实跑通
B. dual-field 与 legacy-title 两种 create 模式是否都被真实承接
C. `project/list` 四个 query 是否都在真实联调链中生效
D. expired public continuation unavailable 是否在联调链中稳定保留
E. 当前是否允许把这一对象标记为 `development-stage integration verified`

【六、强制规则】
- 只认 canonical API
- 不得把 demo/fake transport 当联调证据
- 不得把当前结论升格成 release-prep 或 production release
- 若任一 canonical 步骤失败，必须原样记录状态码与错误码

【七、输出要求】
只输出以下内容：
1. 联调执行环境
2. 主链执行结果
3. 双模式 create + detail 闭环结论
4. filtered list / expired unavailable 结论
5. 阶段结论
6. 风险保留

【八、输出禁令】
- 不要写泛总结
- 不要给开发建议
- 不要写“理论上”
- 只给执行证据和阶段结论
```
