# 企业展示三板块独立化 Flutter 测试债清理残余风险清单补遗

## 当前已关闭风险
- board-scoped canonical family 与测试假 transport 不一致
- published-change family 仍沿用 shared path 断言
- workbench / detail 标题与地图文案断言停留在旧口径
- case editor workbench 仍默认嵌套案例库动作

## 剩余风险
- 本轮只重建了 `enterprise_hub_routes_test.dart` 这一张大门，不代表 `apps/mobile/test/**` 其它套件已同步完成同等级的契约清理。
- 文件仍然较大，后续如果继续叠加新断言而不拆包，仍可能回到“局部改动牵连整文件噪音”的状态。
- 其中一条 create-route 用例现在校验的是 route-level 语义，而不是完整 content-hydration 终态；如果后续要加强这块，应单独补一条更窄的 case-editor hydration 测试，而不是再把大文件做重。

## 后续建议
1. 将企业展示大测试按 `list / detail / workbench / published-change / status` 拆成多个文件。
2. 对 `case editor` 和 `published-change` 单独补更窄的 hydration / action 测试，减少对超长页面文案的耦合。
3. 后续若删除 Flutter 旧私有 route alias 或 BFF shared bridge，应同步补一次 enterprise hub 测试债增量门禁，而不是等到大文件再次整体漂移。
