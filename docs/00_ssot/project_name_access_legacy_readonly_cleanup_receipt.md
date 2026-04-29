# 旧项目名称申请历史只读收口执行回执

## 0. 总裁决

- 旧项目名称申请历史只读收口：Pass
- 是否改 Server：No
- 是否改 BFF：No
- 是否改 Flutter：Yes
- 是否改 contracts：No
- 是否改 migration：No
- 是否触发支付链路：No

当前裁决：Pass。

## 1. 本轮改动

| 文件 | 改动 |
|---|---|
| `docs/00_ssot/project_name_access_legacy_readonly_cleanup_addendum.md` | 新增历史只读收口冻结单 |
| `apps/mobile/lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart` | 旧 `project_name_access` 详情页改为历史只读展示，隐藏旧审批动作 |
| `apps/mobile/test/project_name_access_day45_test.dart` | 新增旧详情页只读 widget test，确认旧 review action 不展示 |

## 2. 关键行为

| 行为 | 结果 |
|---|---|
| 旧详情页标题 | 显示为“历史项目名称查看申请” |
| 旧详情页主说明 | 明确旧能力已合并到申请参与竞标 |
| 旧主审批按钮 | 不展示 |
| 旧系统卡 `project_name_access.review` action | 不展示 |
| 新参与竞标申请页 | 继续保留审批能力 |
| 新 approved 结果 CTA | 继续保留 `bid_submit.open` |

## 3. 本地验证

| 命令 | 结果 |
|---|---|
| `dart format lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart test/project_name_access_day45_test.dart` | PASS |
| `flutter analyze lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart test/project_name_access_day45_test.dart` | PASS |
| `flutter test test/project_name_access_day45_test.dart` | PASS，4 tests |
| `flutter test test/counterpart_conversation_chat_test.dart test/project_name_access_day45_test.dart` | PASS，20 tests |

## 4. 云端只读核查

| 检查项 | 结果 |
|---|---|
| `GET /health/bff/live` | 200 |
| `GET /health/server/live` | 200 |
| 旧 `project/name-access/thread/detail` | 200，历史 route 仍可读 |
| 新 `project/bid-participation/thread/detail` approved 样本 | 200，items 中仍有 `bid_submit.open` |

## 5. 风险

| 风险 | 结论 |
|---|---|
| 旧 Server 仍可能返回 `project_name_access.review` | 不阻塞；Flutter 已按冻结单隐藏旧动作 |
| 旧历史数据仍保留 | 不阻塞；本轮明确不迁移、不删除 |
| 云端 Flutter 用户需重启/重装才看到新 UI | 不阻塞；这是前端包发布问题，不涉及 BFF/Server |

## 6. 下一轮唯一动作

做 Flutter macOS 真实点击走查：打开历史项目名称申请详情，确认只读说明出现且不再出现“处理申请”；再打开参与竞标申请详情，确认审批和通过后提交竞标入口仍正常。
