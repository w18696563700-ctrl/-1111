# Project Communication Unread/Read Day 7 Partial Receipt Addendum

## Verdict

Conditional Pass.

This receipt only proves the station-internal message write and unread truth were triggered for the target project. It does not prove full two-device user acceptance, APNs/FCM delivery, or vibration.

After owner-phone manual verification, this remains `Conditional Pass` rather than `Pass`:

- The counterpart conversation card showed an unread indicator.
- The target project card showed an unread indicator.
- Opening the concrete target project communication cleared the unread state.
- The bottom shell `消息` tab did not show a red badge/count.
- The project-card unread indicator was visible but not prominent enough.
- Device vibration did not happen, which is expected because APNs/FCM/vibration is out of this phase.

## Runtime Scope

- Runtime: Aliyun BFF/Server through `http://127.0.0.1:8080`
- BFF health: 200
- Server health: 200
- Target project: `54c3e384-5774-4f2e-9ff1-a3cee1c1851e`
- Target thread: `9a37dfdd-c458-42ca-a74e-633cf41ad516`
- Owner organization: `e6bf4567-016e-45f9-9420-9c950237690e`
- Counterpart organization: `bdfb4523-aeb7-4b56-89a1-992170fb5d98`

## Computer Use Evidence

Desktop Flutter entered:

- Counterpart conversation: `重庆海川展览工厂 / 重庆坤特展览展示有限公司`
- Relation tab: `我的竞标`
- Project: `科技博览会 - 苹果手机`
- Page: project communication detail

The first Chinese test message input was affected by the desktop IME and was written as short punctuation/time text. Follow-up send attempts created additional short test messages. This is recorded as test noise and must not be treated as product copy or acceptance content.

## Read-Only DB Evidence

Messages created on the target project:

- `b5fd23ea-b335-44cf-98c5-f63459382a69`, sender organization `bdfb4523-aeb7-4b56-89a1-992170fb5d98`, body `：，2026-05-02 1806`
- `45436b24-10a8-4905-81a0-c0ff38f67a50`, sender organization `bdfb4523-aeb7-4b56-89a1-992170fb5d98`, body `？`
- `28a805ed-0375-4d53-bf0e-ca53a3b64529`, sender organization `bdfb4523-aeb7-4b56-89a1-992170fb5d98`, body `？`

Notification rows were created for owner organization `e6bf4567-016e-45f9-9420-9c950237690e` with:

- `type=project_communication_message`
- `source=project_communication`
- `project_id=54c3e384-5774-4f2e-9ff1-a3cee1c1851e`
- `thread_id=9a37dfdd-c458-42ca-a74e-633cf41ad516`
- `notification_state=active`

Read cursor state:

- Counterpart organization cursor advanced to the latest message.
- Owner organization cursor was behind the latest message.

Derived DB check:

- Owner unread after cursor: `2`
- Counterpart unread after cursor: `0`

## Boundary

This receipt does not include:

- APNs/FCM push notification
- device vibration
- phone OS notification banner
- full phone-side visual confirmation
- read-clear acceptance

Those require the phone-side account to open the target project communication page and report/verify the badge clear behavior.

## Next Required Manual Step

On the owner phone account, open:

`消息 -> 重庆海川展览工厂/项目沟通入口 -> 我的发布 or corresponding project card -> 科技博览会 - 苹果手机 -> 项目沟通`

Expected before opening the project chat:

- Message tab or project communication entry shows unread.
- Target project card shows unread.

Expected after opening the concrete project chat:

- The unread count clears for the project.
- The upper-level badges clear after refresh/sync.
- Sender side later shows read state after the owner cursor passes the message.

## Owner Phone Verification

User-reported phone-side result:

- Bottom shell message tab badge/count: not visible.
- Project communication main conversation unread indicator: visible.
- Target project-card unread indicator: visible, but not prominent.
- Unread clear after entering target project communication: yes.
- Test messages visible in the target project communication: yes.
- Device vibration: no.

## Remaining Blocking Defects

- `D7-FE-001`: Bottom shell `消息` tab is not consuming or refreshing the project-communication unread aggregate reliably.
- `D7-FE-002`: Target project-card unread indicator is too weak for production UX.

## Next Minimal Fix Scope

Frontend only unless a fresh probe proves BFF does not expose the shell unread aggregate:

- Verify shell context/message-tab unread source.
- Ensure project-communication unread changes refresh shell state after message arrival and after read cursor writes.
- Strengthen project-card unread badge visual weight.
- Keep APNs/FCM/vibration deferred to phase 2.
