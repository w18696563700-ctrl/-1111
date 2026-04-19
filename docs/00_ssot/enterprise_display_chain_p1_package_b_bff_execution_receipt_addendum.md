---
owner: BFF Agent
status: active
purpose: Record the bounded BFF execution result for enterprise display chain P1 package B contact write-path closure.
layer: execution receipt
receipt_date_local: 2026-04-11
---

# enterprise display chain P1 package B BFF execution receipt

## 1. 修改文件清单

- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/test/enterprise-hub-update-basic-contact-transport.test.cjs`

## 2. 每个修改点对应的冻结事实编号

- 冻结事实 `1`
  - `EnterpriseHubUpdateBasicRequest` 正式允许：
    - `contactName`
    - `contactMobile`
  - 对应修改：
    - 在 `normalizeBasicPayload()` 中补齐这两个字段透传
- 冻结事实 `2`
  - 当前 `BFF normalizeBasicPayload()` 尚未透传这两个字段
  - 对应修改：
    - 让 `updateBasic` 经由既有 canonical basic save path 向 Server 转发 `contactName / contactMobile`
- 冻结事实 `3`
  - 当前包只负责按 contract 转发，不发明字段或改写真相
  - 对应修改：
    - 未新增联系人字段族
    - 未改 `assertNoUrlTruth()`
    - 未改 canonical path
    - 未改错误码家族

## 3. contactName / contactMobile 透传说明

- `updateBasic()` 继续只走既有 canonical path：
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  - `-> /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
- 当前 `normalizeBasicPayload()` 现在会在 payload 中按正式 contract 透传：
  - `contactName`
  - `contactMobile`
- 透传行为：
  - 提供时原样进入 write path
  - 未提供时不伪造默认值
  - 仍由 `compact()` 控制 undefined 不出包

## 4. 未扩写其他 contact 字段的边界说明

- 本轮没有补齐：
  - `wechat`
  - `phone`
  - `email`
  - `position`
- 这些字段即使由 Flutter 传入，当前 BFF 也不会进入 `updateBasic` write payload。
- 本轮没有新建第二条 contact update family。
- 本轮没有在 BFF 自持 contact truth 或 contact 状态机。

## 5. 新增或更新的测试清单

- 新增：
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/test/enterprise-hub-update-basic-contact-transport.test.cjs`
- 覆盖项：
  1. `updateBasic` payload 能透传 `contactName`
  2. `updateBasic` payload 能透传 `contactMobile`
  3. 未提供这两个字段时，现有 payload 行为不被破坏
  4. 不会顺手接受 `wechat / phone / email / position`

## 6. build / test 结果

- build:
  - `cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/bff && npm run build`
  - `PASS`
- targeted test:
  - `cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/bff && node --test test/enterprise-hub-update-basic-contact-transport.test.cjs`
  - `PASS (3/3)`

## 7. 当前剩余未闭合项

- BFF package B 范围内：
  - `none`
- 当前联系人 write-path 仍未闭合到最终联调完成的剩余项：
  - Flutter package C 还需要把 `contactName / contactMobile` 真正发入 `updateBasic` 请求体
- 本轮未覆盖：
  - workbench truth 改写
  - Server 联系人真相扩展
  - 其他联系人字段扩写

## 8. 是否可移交 Flutter package C

- `yes`
- 当前结论含义：
  - BFF 已不再吞掉 `contactName / contactMobile`
  - 透传字段已与正式 contract 对齐
  - 当前联系人普通保存链剩余阻断已收敛到 `Flutter package C`
