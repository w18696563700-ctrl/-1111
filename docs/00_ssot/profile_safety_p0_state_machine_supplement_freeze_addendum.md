---
title: Profile Safety P0 State Machine Supplement Freeze
status: frozen
owner: Codex Control
scope: docs-only
created_at: 2026-04-07
---

# Profile Safety P0 状态机补充冻结单

## 1. Purpose

本文件冻结 Profile Safety P0 中“账号资料先审后显”的最小状态机，避免破坏当前已完成的昵称 / 头像编辑体验。

## 2. Current Runtime Baseline

当前 `profile` 昵称 / 头像链路已具备最小编辑与回读能力，但当前实现语义是直接保存，不是先审后显。

因此，Profile Safety P0 不得简单把当前保存链改成“提交后立刻消失”或“用户资料不可见”。

## 3. State Machine Object

Profile Safety P0 账号资料审核对象至少覆盖：

- 昵称
- 头像
- 简介

签名、封面、认证展示信息继续保留在母版中，是否进入 P0 由子包冻结单继续细化。

## 4. Frozen State Model

账号资料提交项的最小状态冻结为：

- `current_approved`
- `pending_review`
- `approved`
- `rejected`
- `resubmitted`

说明：

- `current_approved`：当前对外展示的旧值。
- `pending_review`：用户提交的新值，处于审核中，不替换旧值。
- `approved`：新值审核通过，替换旧值。
- `rejected`：新值审核拒绝，旧值继续展示，并回显拒绝原因。
- `resubmitted`：用户基于拒绝原因重新提交。

## 5. Old Value and New Value Relationship

先审后显规则冻结为：

- 旧资料继续显示。
- 新提交项进入待审。
- 新提交项待审期间不得对外公开替换旧资料。
- 新提交项通过后才替换旧资料。
- 新提交项拒绝后旧资料不变。
- 用户可基于拒绝原因继续重提。

该规则适用于昵称、头像、简介。

## 6. User-facing Prompt Rules

用户端提示规则冻结为：

- 提交成功但未审核通过时，提示“审核中”。
- 审核中状态下，明确说明当前公开展示仍为旧资料。
- 审核拒绝时，展示受控拒绝原因。
- 拒绝后允许重新提交。
- 不允许把审核中误写成“已生效”。
- 不允许把拒绝误写成“保存失败”。
- 不允许因审核中隐藏用户已有资料。

## 7. Safety Audit Dependency

Profile Safety P0 必须依赖 Safety Audit P0 的最小留痕能力。

至少需要留痕：

- submit action
- rule result
- manual review result
- replacement action
- reject reason
- resubmit action

## 8. Explicit Non-goals

本状态机补充不包括：

- AI 审核 runtime
- 头像 OCR
- 头像二维码检测
- 处罚台
- 申诉台
- 完整用户违规分
- 存量复扫
- 私信治理

## 9. Gate Result

### Passed Gates

- 旧值继续显示与新值待审关系已冻结。
- 通过 / 拒绝 / 重提路径已冻结。
- 用户端提示规则已冻结。

### Failed Gates

- 该状态机尚未实现。
- 对应实体与 migration 尚未冻结。
- Admin Review P0 尚未提供人工复核面。

### Veto Gates

- 若提交新头像后立即公开替换旧头像，veto。
- 若待审时隐藏旧头像或旧昵称，veto。
- 若拒绝后不给原因且不允许重提，veto。
- 若把 AI 写成 P0 必须依赖，veto。

## 10. Next Unique Action

文书冻结线程必须在 Profile Safety P0 冻结单中引用本状态机补充，并把状态机映射到 CS-004、CS-005、CS-006。
