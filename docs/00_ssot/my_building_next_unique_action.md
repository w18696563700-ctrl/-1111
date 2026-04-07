---
owner: Codex 总控
status: frozen
purpose: 明确“我的楼”主线当前下一轮唯一动作、目标线程、允许输出边界与进入下一阶段的触发条件，防止多线程并行抢跑。
layer: L0 SSOT
freeze_date_local: 2026-04-05
---

# 《下一轮唯一动作》

## 1. 当前唯一动作

- 下一步先发口令给：
  - `总控文书冻结` 线程

## 2. 当前应发送的口令

```text
基于以下当前现行文书：
1. docs/00_ssot/new_workflow_v3_takeover_declaration.md
2. docs/00_ssot/seven_role_organization_freeze_v3.md
3. docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md
4. docs/00_ssot/my_building_effective_truth_mother_file_v1.md
5. docs/00_ssot/my_building_asset_route_page_truth_owner_stage_status_table_v1.md
6. docs/00_ssot/my_building_mainline_v1_three_column_ruling.md
7. docs/00_ssot/my_building_round1_increment_dispatch.md
8. docs/00_ssot/my_building_next_unique_action.md

只做《我的楼文书收口正式版 V1》：
- 修订母文件正式版
- 修订总表正式版
- 输出阅读顺序
- 输出真源挂图
- 输出引用链变更清单

严格禁止：
- 新增任何 scope
- 新增任何 package
- 发 implementation unlock
- 改写三栏裁决
- 改写 Round 1 派工边界
- 把 docs-frozen 写成 runtime fully open

回执只允许提交：
- 正式版文书包
- 引用链修订清单
- 阅读顺序
- 真源挂图
```

## 3. 对方当前只允许输出什么

- 只允许输出：
  - 文书正式版收口结果
  - 引用链、阅读顺序、挂图、索引
- 不允许输出：
  - 新主线
  - 新 implementation unlock
  - 执行角色施工方案
  - release 口径

## 4. 触发下一阶段的条件

- 只有同时满足以下条件，才允许进入下一阶段：
  1. `总控文书冻结` 线程已回正式版文书包
  2. 总控基于现行文书输出《阶段门禁核查表》
  3. 《阶段门禁核查表》确认以下门禁无 veto failure：
     - 真源门禁
     - 架构边界门禁
     - 契约门禁
     - 阶段控制门禁
     - 文件长度与职责门禁
  4. 总控明确写出：
     - 可以向 `前端 Agent`
     - `后端 Agent`
     - `BFF Agent`
     发 Round 1 执行口令

## 5. 下一阶段之后的顺序

- 下一阶段开启后，顺序只能是：
  1. 前端 / 后端 / BFF 按 `my_building_round1_increment_dispatch.md` 施工
  2. 结果校验 Agent 独立复核
  3. 总控裁决是否允许联调发布
  4. 联调发布 Agent 最后介入

## 6. Formal Conclusion

- 当前正式结论如下：
  - 下一轮唯一动作不是直接开工
  - 下一轮唯一动作是先让 `总控文书冻结` 线程完成文书收口正式版
  - 只有文书收口完成且阶段门禁通过后，才允许进入执行角色派工阶段
