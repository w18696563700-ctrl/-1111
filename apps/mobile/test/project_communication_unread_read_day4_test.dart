import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_parser.dart';
import 'package:mobile/features/messages/data/messages_interaction_parser.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';

void main() {
  test('message interactions parse conversation unread projection fields', () {
    final definition =
        messagesRegisteredEntryByActionKey['counterpart_conversation.open']!;

    final result = parseMessageInteractionPayload(<String, Object?>{
      'lane': 'project_communication',
      'items': <Object?>[
        <String, Object?>{
          'interactionId': 'interaction-1',
          'interactionType': 'counterpart_conversation',
          'conversationId': 'conversation-1',
          'projectId': 'project-1',
          'counterpart': <String, Object?>{
            'organizationId': 'org-counterpart',
            'displayName': '江北嘴嘴帅',
            'companyName': '重庆展宏展览展示有限公司',
            'role': 'counterpart',
          },
          'summary': <String, Object?>{
            'focusProjectId': 'project-1',
            'title': '项目沟通',
            'text': '有新的项目消息。',
            'projectCount': 2,
            'latestCardType': 'project_order',
          },
          'conversationUnreadCount': 3,
          'hasUnread': true,
          'latestUnreadMessageAt': '2026-05-04T10:03:00Z',
          'updatedAt': '2026-05-04T10:04:00Z',
          'routeTarget': <String, Object?>{
            'objectType': definition.objectType,
            'actionKey': definition.actionKey,
            'canonicalPath': definition.canonicalPath,
            'params': const <String, Object?>{
              'conversationId': 'conversation-1',
              'projectId': 'project-1',
            },
          },
        },
      ],
    });

    expect(result.state, AppPageState.content);
    expect(result.items.single.conversationUnreadCount, 3);
    expect(result.items.single.hasUnread, isTrue);
    expect(result.items.single.latestUnreadMessageAt, '2026-05-04T10:03:00Z');
  });

  test('counterpart detail parses relation and project unread fields', () {
    final detail = parseCounterpartConversationDetail(<String, Object?>{
      'conversationId': 'conversation-1',
      'counterpart': <String, Object?>{
        'organizationId': 'org-counterpart',
        'displayName': '江北嘴嘴帅',
        'companyName': '重庆展宏展览展示有限公司',
        'role': 'counterpart',
      },
      'summary': <String, Object?>{
        'focusProjectId': 'project-1',
        'title': '项目沟通',
        'text': '有新的项目消息。',
        'projectCount': 2,
        'latestCardType': 'project_order',
      },
      'focusProjectId': 'project-1',
      'latestActivityAt': '2026-05-04T10:04:00Z',
      'conversationUnreadCount': 5,
      'hasUnread': true,
      'latestUnreadMessageAt': '2026-05-04T10:03:00Z',
      'myPublishedUnreadCount': 3,
      'myBidUnreadCount': 2,
      'projectGroups': <Object?>[
        <String, Object?>{
          'projectId': 'project-1',
          'projectDisplayTitle': '西洽会 - 泸州',
          'titleVisibility': 'visible',
          'projectRelation': 'my_published',
          'projectState': 'converted_to_order',
          'projectPublishedAt': '2026-05-01T18:00:00Z',
          'projectUpdatedAt': '2026-05-04T10:04:00Z',
          'latestActivityAt': '2026-05-04T10:04:00Z',
          'latestUnreadMessageAt': '2026-05-04T10:03:00Z',
          'projectUnreadCount': 3,
          'hasProjectUnread': true,
          'cards': const <Object?>[],
        },
      ],
    });

    expect(detail.conversationUnreadCount, 5);
    expect(detail.hasUnread, isTrue);
    expect(detail.myPublishedUnreadCount, 3);
    expect(detail.myBidUnreadCount, 2);
    expect(detail.projectGroups.single.projectUnreadCount, 3);
    expect(detail.projectGroups.single.hasProjectUnread, isTrue);
    expect(
      detail.projectGroups.single.latestUnreadMessageAt,
      '2026-05-04T10:03:00Z',
    );
  });

  test('project communication message status fields default safely', () {
    final message = parseProjectCommunicationMessage(<String, Object?>{
      'messageId': 'message-1',
      'threadId': 'thread-1',
      'projectId': 'project-1',
      'senderUserId': 'user-1',
      'senderOrganizationId': 'org-1',
      'messageKind': 'text',
      'body': '在吗？',
      'messageState': 'active',
      'createdAt': '2026-05-04T10:00:00Z',
    });

    expect(message.deliveryState, 'persisted');
    expect(message.readState, 'not_applicable');
    expect(message.readByCounterpartAt, isNull);
  });

  test('project communication message status fields parse read state', () {
    final messages = parseProjectCommunicationMessages(<String, Object?>{
      'items': <Object?>[
        <String, Object?>{
          'messageId': 'message-1',
          'threadId': 'thread-1',
          'projectId': 'project-1',
          'senderUserId': 'user-1',
          'senderOrganizationId': 'org-1',
          'messageKind': 'text',
          'body': '在吗？',
          'clientMessageId': 'client-1',
          'messageState': 'active',
          'deliveryState': 'persisted',
          'readState': 'read_by_counterpart',
          'readByCounterpartAt': '2026-05-04T10:01:00Z',
          'createdAt': '2026-05-04T10:00:00Z',
        },
      ],
      'nextCursor': null,
    });

    expect(messages.items.single.deliveryState, 'persisted');
    expect(messages.items.single.readState, 'read_by_counterpart');
    expect(messages.items.single.readByCounterpartAt, '2026-05-04T10:01:00Z');
  });
}
