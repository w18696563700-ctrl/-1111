---
owner: Codex 总控
status: active
purpose: Record why the current enterprise-display trust repair round is a bounded maintenance reopening rather than a reuse of old stage-1/stage-2 conclusions.
layer: L0 SSOT
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_hub_v1_current_active_sub_object_ruling_addendum.md
  - docs/04_frontend/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
  - docs/04_frontend/enterprise_display_stage2_public_card_and_album_frontend_consumption_addendum.md
  - 用户本轮截图与反馈
---

# 《企业展示工作台与公域列表可信度修复漂移说明》

## 1. 为什么旧结论不能直接沿用

- 旧裁决明确写明：
  - `enterprise_hub V1 当前没有新的 active sub-object`
- 本轮用户已提供新的运行态证据，说明当前不再是“没有新对象”的状态，而是出现了新的 bounded maintenance object：
  - Logo-only 维护被联系人拦截
  - 顶部 truth-derived 字段仍可能空缺
  - 城市筛选存在死控件风险
  - 列表 Logo 与既有消费冻结不一致
  - asset raw error 泄漏到页面

## 2. 与旧 stage-1 / stage-2 文书的关系

- stage-1 relayout freeze 解决的是：
  - 工作台骨架顺序
  - company 主编辑字段裁决
  - published-change corridor continuity
- stage-2 public card freeze 解决的是：
  - company 公域卡片使用 `serviceItems`
  - company 公域卡片使用信用占位
  - workbench album 回读 continuity
- 本轮并不是要推翻上述文书，而是确认当前实现和运行态还存在下面这些未被前述文书自动保证的问题：
  - `Logo 用于列表和详情页识别` 的承诺与列表卡片实现不一致
  - 城市筛选控件的交互可信度不足
  - workbench 保存/提交的解释链在异常态下不够稳定

## 3. 为什么这轮不直接并入 founded-time filter

- founded-time filter 不是现有冻结对象里的运行态坏链，而是新的筛选能力新增。
- 它明确需要：
  - 新 query 语义
  - BFF / Server 过滤逻辑
  - Flutter 控件与消费
- 若把它与当前 blocker repair 混在一轮，会直接破坏“先修坏链，再补新能力”的门禁纪律。

## 4. 对平台主线的影响裁决

- 当前 bounded repair 不改写：
  - `Admin 最小运营与治理闭环` 作为平台唯一主线的裁决
- 当前只是 enterprise-display 的 maintenance reopening，不是平台阶段跳转。

## 5. Formal Conclusion

- 旧文书与当前用户证据之间的漂移已经正式记录。
- 从现在开始：
  - 不能再直接援引“当前没有新的 active sub-object”
  - 必须以本轮新的 bounded object 与新门禁为准继续派工
  - founded-time filter 继续后置到下一阶段判断
