---
title: Project Communication Realtime WebSocket Field Table
date: 2026-05-18
stage: L1
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket Field Table

## 1. Server Event Envelope

| Field | Required | Source | Rule |
|---|---:|---|---|
| `eventId` | yes | Server generated | Unique per derived event. |
| `eventType` | yes | constant | Fixed to `project_communication.message.created`. |
| `messageId` | yes | `ProjectCommunicationMessage.id` | Must identify persisted truth. |
| `threadId` | yes | `ProjectCommunicationMessage.threadId` | Required subscription boundary. |
| `projectId` | yes | `ProjectCommunicationMessage.projectId` | Required business boundary. |
| `senderOrganizationId` | yes | `ProjectCommunicationMessage.senderOrganizationId` | Required sender boundary. |
| `messageKind` | yes | `ProjectCommunicationMessage.messageKind` | Current phase allows `text`. |
| `body` | yes | `ProjectCommunicationMessage.body` | Text body, max length follows Server command rule. |
| `clientMessageId` | no | `ProjectCommunicationMessage.clientMessageId` | Used for client de-duplication. |
| `createdAt` | yes | `ProjectCommunicationMessage.createdAt` | ISO timestamp. |

## 2. BFF Subscription Request

| Field | Required | Rule |
|---|---:|---|
| `action` | yes | Fixed to `project_communication.subscribe`. |
| `threadId` | yes | Non-empty string. |
| `projectId` | yes | Non-empty string. |
| `counterpartOrganizationId` | conditional | Required when the route already has counterpart boundary. |

## 3. Flutter Realtime Event

Flutter consumes the Server event envelope without inventing new state names.
Unknown `eventType` values must be ignored only after logging/controlled
handling; unknown critical fields must be treated as contract drift.

