---
owner: Codex 总控
status: active
purpose: Freeze the six-role dispatch bundle, package split, execution order, and acceptance matrix for the current round that turns enterprise detail windows into album-style pages and adds gated target-enterprise formal-info viewing.
layer: L0 SSOT
freeze_date_local: 2026-04-15
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_album_layout_and_target_enterprise_info_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/01_contracts/certification_license_field_collection_contracts_addendum.md
  - docs/04_frontend/profile_dual_certification_bid_guard_frontend_truth_note.md
---

# 企业展示详情画册化与目标企业信息查看 六角色派工单

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 让 `优秀公司 / 优秀工厂 / 优秀供应商` 三个展示窗口点进去以后呈现为企业画册式详情页
  - 在画册区底部提供一个 `查看企业信息` 入口
  - 该入口只允许双重认证通过的用户点击
  - 打开后只显示目标企业正式认证文字信息

## B. 当前轮明确非目标

- 不改筛选口径
- 不删减、不弱化、不重写现有筛选功能
- 不新开第二个企业认证中心
- 不把 `我的楼 -> 我的公司` 私域页面搬成公开企业详情页
- 不新增 Admin 审核工作台
- 不把 `工厂实景图` 直接偷换成跨三类统一画册真值而不先冻结契约

## C. 当前轮项目拓扑冻结

- 前端 Agent 只在本地开发，只允许写：
  - `apps/mobile/**`
- 后端 Agent 只在云端开发，只允许写：
  - `apps/server/**`
- BFF Agent 只在云端开发，只允许写：
  - `apps/bff/**`
- 本地验证云端服务时：
  - 统一通过既定隧道访问 `http://127.0.0.1:8080`
- 隧道命令允许进入流程文档
- 密码不得写入任何文档、日志、口令或回执

## D. 当前轮 package split

### D1. Package 0 | 总控 docs-first freeze

- owner：
  - `Codex 总控`
- allowed directories：
  - `docs/00_ssot/**`
  - `docs/01_contracts/**`
  - `docs/02_backend/**`
  - `docs/03_bff/**`
  - `docs/04_frontend/**`
- deliverables：
  - 阶段门禁核查表
  - 合同冻结单
  - backend truth 冻结单
  - BFF surface 冻结单
  - frontend surface 冻结单
- must not do：
  - 越过 docs-first 直接让前后端开工

### D2. Package 1 | 后端 Agent 云端真值包

- owner：
  - `后端 Agent`
- allowed directories：
  - 云端 `apps/server/**`
- unique goal：
  - 为目标企业正式信息查看提供真值 read path
  - 对该 path 施加双重认证硬门禁
  - 为统一企业画册真值补足持久化与公开读取承接
- must do：
  - 目标企业 formal-info 只返回正式认证文字字段
  - 不返回当前登录用户私域对象
  - 不返回 OCR preview 噪声字段
  - 不返回证照图片作为公开详情主体
- must not do：
  - 第二套认证状态机
  - 把 `fileAssetId` 暴露成业务真值
  - 本地伪装云端开发

### D3. Package 2 | BFF Agent 云端聚合包

- owner：
  - `BFF Agent`
- allowed directories：
  - 云端 `apps/bff/**`
- unique goal：
  - 提供 app-facing 目标企业 formal-info 读取入口
  - 对双重认证结果做聚合与错误归一
  - 对画册图片公开可见面做整形
- must do：
  - 只做 auth/session forward、organization scope、response shaping、visibility trim
  - 返回适合 Flutter 弹层直接消费的字段形状
- must not do：
  - 第二套后台真值
  - 第二套资格状态机
  - 本地判断替代后端硬门禁

### D4. Package 3 | 前端 Agent 本地展示包

- owner：
  - `前端 Agent`
- allowed directories：
  - 本地 `apps/mobile/**`
- unique goal：
  - 将三个企业详情页改成企业画册式版式
  - 在画册区底部加入 `查看企业信息` 入口
  - 只在双重认证通过时允许点击
  - 用底部弹层展示目标企业正式信息
- must do：
  - 保持现有筛选功能与相关代码不动
  - 优先消费已冻结 contract 字段
  - 按三种企业类型投影不同重点内容
  - 做图片空态、权限锁定态、加载态、失败态
- must not do：
  - 调后端裸接口
  - 直接复用当前用户的 `certification/current` 页面或路由
  - 引入本地 mock 成功态掩盖云端缺口

### D5. Package 4 | 结果校验 Agent 独立复核包

- owner：
  - `结果校验 Agent`
- unique goal：
  - 对前端、本地接线、云端门禁与字段裁剪做独立复核
- must check：
  - 三个企业类型详情页是否都已画册化
  - 画册滑动、图片占位、案例图卡是否成立
  - 现有筛选功能是否完全未被动过
  - 未双重认证用户是否只能看到锁定态
  - 已双重认证用户是否能看到目标企业正式信息
  - 是否出现当前用户自己企业信息串到对方企业详情中的泄漏
- must not do：
  - 代替实施
  - 代替联调发布

### D6. Package 5 | 联调发布 Agent

- owner：
  - `联调发布 Agent`
- unique goal：
  - 完成本地 Flutter 与云端 BFF/后端联调
  - 基于既定隧道完成最终发布前回归
- must check：
  - `http://127.0.0.1:8080` 访问链路正常
  - 三类详情页都能正确读取
  - 双账号验证通过：
    - 双重认证通过账号
    - 非双重认证账号
- must not do：
  - 在未拿到结果校验通过前直接发布

## E. 当前轮执行顺序

1. 总控完成 docs-first freeze。
2. 后端 Agent 在云端完成真值与权限硬门禁。
3. BFF Agent 在云端完成 app-facing 聚合与错误归一。
4. 前端 Agent 在本地完成画册化详情页与按钮/弹层接入。
5. 三个实施角色提交标准回执给总控。
6. 总控转交结果校验 Agent 做独立复核。
7. 只有复核通过后，联调发布 Agent 才允许进入隧道联调与发布流程。

## F. 当前轮前端最终页面骨架

- 详情页统一骨架固定为：
  - 头图首屏
  - 企业画册横滑区
  - `查看企业信息` 入口卡
  - 核心能力摘要区
  - 详细介绍区
  - 案例展示区
  - 联系方式区
- 三类企业重点内容固定为：
  - 公司：
    - 展会类型
    - 服务项目
    - 服务城市
    - 最大项目规模
    - 资质说明
  - 工厂：
    - 工厂名
    - 工艺类型
    - 核心产品
    - 设备
    - 厂房面积
    - 月产能
    - 仓储与运输
    - 配送半径
  - 供应商：
    - 供应品类
    - 供应模式
    - 核心产品/服务
    - 响应时效
    - 配送范围

## G. 当前轮目标企业信息字段冻结意图

- `查看企业信息` 弹层最终只展示：
  - 认证主体
  - 统一社会信用代码
  - 法定代表人
  - 企业类型
  - 住所
  - 注册资本
  - 成立日期
  - 营业期限
  - 经营范围
  - 当前认证状态
- 当前不展示：
  - 营业执照图片
  - OCR preview 原始噪声字段
  - 当前用户私域身份字段

## H. 当前轮验收通过标准

- 三个详情页都不再是“表单字段清单回显”视觉
- 画册区横向滑动成立，空态不丑陋
- `查看企业信息` 按钮始终可见，但权限态正确
- 双重认证用户点击后可看到目标企业正式信息
- 非双重认证用户不能进入目标企业信息弹层
- 现有筛选功能零改动
- 不出现当前用户企业信息串读到目标企业详情的错误

## I. 当前轮 Formal Conclusion

- 当前轮唯一合法推进路径固定为：
  - `总控 docs-first freeze -> 云端真值/BFF -> 本地前端 -> 独立校验 -> 联调发布`
- 任何跳过 docs-first、跳过云端硬门禁、或把当前用户私域认证读取直接复用为目标企业详情读取的做法，当前一律判定为不合规。
