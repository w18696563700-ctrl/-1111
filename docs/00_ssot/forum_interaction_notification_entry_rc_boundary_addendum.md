---
owner: Codex 总控
status: frozen
purpose: Freeze the RC boundary for forum interaction notification entry routing.
layer: L0 SSOT
---

# Forum Interaction Notification Entry RC Boundary Addendum

## 1. Ruling

`forum_interaction.open` is a messages-building read-only notification entry.

It may open the messages building Forum Interaction tab so the user can review
forum replies, likes, and follows that were already projected by Server-owned
notification truth.

It is not a Forum write command and must not be blocked by the release flag that
guards Forum user commands such as publishing, replying, liking, following, or
other mutable Forum actions.

## 2. Scope

This reopening covers only:

- Bell notification routeTarget consumption for `forum_interaction.open`.
- Messages building Forum Interaction tab positioning.
- Server-owned `forum_interaction` notification source visibility.
- Controlled Chinese fallback when a notification cannot be positioned.

This reopening does not cover:

- Enabling Forum write commands.
- Enabling Forum publishing.
- Enabling generic IM, private chat, group chat, or AI workflow messages.
- Creating a new notification platform.
- Android FCM.
- Firebase.
- Custom vibration.
- Notification preferences.
- Marketing push.
- Payment, settlement, wallet, invoice, contract amount, or fulfillment.

## 3. Release Flag Boundary

`RcReleaseFlags.forumUserCommandsEnabled = false` may continue to block mutable
Forum actions.

It must not block `forum_interaction.open`, because that routeTarget is a
read-only notification review entry in the messages building.

Changing this boundary must not silently unlock:

- post publish
- comment submit
- like / unlike
- follow / unfollow
- bookmark
- report
- any other Forum write command

## 4. Layer Responsibilities

| Layer | Responsibility |
| --- | --- |
| Server | Owns `app_notifications`, `source=forum_interaction`, unread buckets, routeTarget, and delivery attempts. |
| BFF | Only forwards and shapes notification list/read/register responses. It must not create unread truth. |
| Flutter | Opens the messages Forum Interaction tab for `forum_interaction.open`; it must not infer notification truth. |

## 5. Acceptance

The minimum closure for this reopening is:

1. A `forum_interaction.open` notification routeTarget opens `/messages?tab=forum_interaction&interactionTab=...`.
2. The same routeTarget does not open Forum write commands.
3. Invalid `tab` values remain controlled errors.
4. Forum comments, likes, and follows are still Server-owned notification events.
5. No OpenAPI path, generated contract, database schema, or cloud configuration is changed by this reopening.
