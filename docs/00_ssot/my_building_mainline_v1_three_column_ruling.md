---
owner: Codex 总控
status: frozen
purpose: 把“我的楼”主线拆为本轮必做、本轮冻结占位、战略保留三类，防止 scope 漂移、抢主线与把未来位提前落地。
layer: L0 SSOT
freeze_date_local: 2026-04-05
---

# 《我的楼专项主线 V1：本轮必做 / 本轮冻结占位 / 战略保留 三栏裁决表》

## 1. 三栏口径

- `本轮必做`：
  - 当前必须真实推进并形成下一轮派工依据的事项
- `本轮冻结占位`：
  - 当前允许保留入口、页面、状态位或受控占位，但不进入重型实现
- `战略保留`：
  - 当前只保留方向，不得直接落地为实现

## 2. 三栏裁决表

| 对象 | 本轮必做 | 本轮冻结占位 | 战略保留 | 裁决理由 |
|---|---|---|---|---|
| `我的楼` 首层 compact hub 语义对齐 | 是 |  |  | 当前唯一主线入口，且已有前端资产，必须统一口径而不是继续漂移 |
| `我的楼 -> 我的项目` 入口语义与 handoff | 是 |  |  | 当前主线的核心入口，必须明确与 `项目工作台` 的关系 |
| `我的项目` list/detail 的 route owner / page owner / truth owner 收口 | 是 |  |  | 当前最容易发生入口 owner 与 truth owner 混写 |
| `my-project` server presenter 从默认 `privateProgress` 占位补齐为既有真相读时聚合 | 是 |  |  | 现有源码存在，但私域进度语义仍未按上游 truth 补足 |
| `my-project` BFF shaping 与错误归一复核 | 是 |  |  | 已有源码存在，必须收口到冻结 contract，不能放任自定义状态名 |
| `my/projects` contracts projection drift 修复 | 是 |  |  | `openapi.yaml` 已入册，但生成投影仍滞后，必须消除 consumer 误导 |
| `我的公司` / 认证 current / 登录入口 与 `我的楼` 首层关系对齐 | 是 |  |  | 这些资产已存在，必须纳入当前母文件，而不是被旧链路散落管理 |
| `我的论坛` 维持单一首层入口与二层资产扩展 | 是 |  |  | 已有页面资产存在，必须明确其 bounded me-assets 边界 |
| 组织 create / join / switch happy path |  | 是 |  | 当前前端页面已存在，但明示待开放；本轮不扩成重型实现 |
| device list / revoke 真正开放 |  | 是 |  | Package 1 当前仍是 docs-frozen + 受控页面状态，不能误报已 fully open |
| certification submit / resubmit 的完整 happy path 打开 |  | 是 |  | 当前主线优先级先收口 current-user hub 与 my-project，不抢重型认证链 |
| `我的项目` 下游 CTA 矩阵与深层继续处理页扩张 |  | 是 |  | 本轮先冻结消费边界与 owner，不扩到完整工作流动作矩阵 |
| `我的项目` 正式附件列表 |  | 是 |  | 上游真源已明确继续独立立项，当前不得混入主线 |
| `profile/governance` 风控治理中心 |  | 是 |  | Package 4 仍停在 docs-frozen / implementation No-Go，不得借主线偷跑 |
| `我的楼` public author homepage |  |  | 是 | 与 compact hub 正式定义冲突，当前不得落地 |
| `我的楼` 第二论坛首页化 |  |  | 是 | 与当前主线正式定义冲突，属于显式非目标 |
| `我的楼` 第二工作台 dashboard 化 |  |  | 是 | 与 compact hub 真义冲突 |
| person-first 第二套 identity / certification truth |  |  | 是 | 与当前 organization-centered Package 1 truth 冲突 |
| hidden buildings visible 化 |  |  | 是 | 违背 `flutter_screen_map` 与架构门禁 |
| live / geo / map 深能力落地 |  |  | 是 | 当前仍属平台预埋与 flag-off 范围 |
| enterprise_hub 抢回默认主线 |  |  | 是 | 旧主线资产保留，但当前唯一主线已改为 `我的楼` |

## 3. 三栏裁决结论

- 本轮真正需要做的是：
  - 收口 `我的楼` 首层
  - 收口 `我的项目`
  - 吸收 Package 1 的 bounded consumption 资产
  - 清理 contracts projection drift
- 本轮不做的是：
  - 重型组织办理链
  - 完整设备安全链
  - `我的项目` 附件列表与深层 CTA 扩张
- 当前坚决不做的是：
  - 任何会把 `我的楼` 变成第二论坛首页、第二 dashboard、第二公共主页的落地

## 4. Formal Conclusion

- 当前正式结论如下：
  - `本轮必做` 已聚焦到 `我的楼` 首层、`我的项目`、Package 1 bounded consumption 以及 projection drift 修复
  - `本轮冻结占位` 只保留入口与状态位，不打开重型 happy path
  - `战略保留` 一律不得直接落地
