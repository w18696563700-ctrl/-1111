import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/trading_im_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

Widget _buildPage(FakeAppApiTransport transport) {
  final client = _client(transport);
  ExhibitionConsumerLayer.install(ExhibitionConsumerLayer(client: client));
  TradingImConsumerLayer.install(TradingImConsumerLayer(client: client));
  CounterpartConversationConsumerLayer.install(
    CounterpartConversationConsumerLayer(
      client: client,
      realtimeClient: const _NoopProjectCommunicationRealtimeClient(),
    ),
  );
  return MaterialApp(
    home: const Scaffold(
      body: CounterpartConversationPage(
        conversationId: 'conversation-1',
        projectId: 'project-1',
      ),
    ),
  );
}

Future<void> _ensureVisible(WidgetTester tester, Finder finder) async {
  await tester.pumpAndSettle();
  for (var i = 0; i < 14 && finder.evaluate().isEmpty; i += 1) {
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isEmpty) break;
    await tester.drag(scrollables.first, const Offset(0, -360));
    await tester.pumpAndSettle();
  }
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder.first);
  }
  await tester.pumpAndSettle();
}

Future<void> _enterProjectCommunication(WidgetTester tester) async {
  final entry = find.widgetWithText(FilledButton, '进入沟通').first;
  await _ensureVisible(tester, entry);
  await tester.tap(entry);
  await tester.pumpAndSettle();
}

Future<void> _expandWorkbenchGroup(WidgetTester tester, String label) async {
  if (find.text(label).evaluate().isEmpty) {
    await _openMaterialTools(tester);
  }
  final group = find.text(label);
  await _ensureVisible(tester, group);
  await tester.tap(group.first);
  await tester.pumpAndSettle();
}

Future<void> _openMaterialTools(WidgetTester tester) async {
  var tools = find.widgetWithText(OutlinedButton, '资料确认 · 10项');
  if (tools.evaluate().isEmpty) {
    tools = find.widgetWithText(OutlinedButton, '资料确认单');
  }
  await _ensureVisible(tester, tools);
  await tester.tap(tools);
  await tester.pumpAndSettle();
}

final class _NoopProjectCommunicationRealtimeClient
    implements ProjectCommunicationRealtimeClient {
  const _NoopProjectCommunicationRealtimeClient();

  @override
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  }) async {
    final controller =
        StreamController<ProjectCommunicationMessageCreatedEvent>.broadcast();
    return ProjectCommunicationRealtimeSubscription(
      events: controller.stream,
      done: controller.done,
      close: () async {
        await controller.close();
      },
    );
  }
}

Map<String, Object?> _detailPayload({String projectRelation = 'my_bid'}) {
  return <String, Object?>{
    'conversationId': 'conversation-1',
    'counterpart': const <String, Object?>{
      'organizationId': 'org-counterpart',
      'displayName': '重庆海川展览工厂',
      'nickname': '海川',
      'companyName': '重庆海川展览工厂',
      'avatarUrl': null,
      'role': 'counterpart',
    },
    'summary': const <String, Object?>{
      'focusProjectId': 'project-1',
      'title': '项目沟通',
      'text': '当前项目沟通。',
      'projectCount': 1,
      'latestCardType': 'project_communication',
    },
    'focusProjectId': 'project-1',
    'latestActivityAt': '2026-05-04T10:00:00Z',
    'conversationUnreadCount': 0,
    'myPublishedUnreadCount': 0,
    'myBidUnreadCount': 0,
    'projectGroups': <Object?>[
      <String, Object?>{
        'projectId': 'project-1',
        'projectDisplayTitle': '立嘉机械展·大族激光',
        'titleVisibility': 'visible',
        'projectRelation': projectRelation,
        'projectState': 'published',
        'projectPublishedAt': '2026-05-01T18:00:00',
        'projectUpdatedAt': '2026-05-04T17:00:00',
        'latestActivityAt': '2026-05-04T10:00:00Z',
        'projectUnreadCount': 0,
        'hasProjectUnread': false,
        'businessTodoSummary': _businessTodoSummary(
          publisherMaterialReviewPendingCount: 3,
        ),
        'cards': <Object?>[],
      },
    ],
  };
}

Map<String, Object?> _threadPayload() {
  return <String, Object?>{
    'threadId': 'thread-1',
    'projectId': 'project-1',
    'ownerOrganizationId': 'org-owner',
    'counterpartOrganizationId': 'org-counterpart',
    'chatAvailability': _chatAvailability(
      canSendMessage: false,
      lockReasonCode: 'publisher_material_confirmation_pending',
      lockReasonText: '请先确认发布方提供的报价依据资料。',
      requiredNextAction: 'confirm_publisher_materials',
    ),
    'threadState': 'active',
    'lastMessageId': null,
    'lastMessageAt': null,
    'createdAt': '2026-05-04T10:00:00Z',
    'updatedAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Object?> _businessTodoSummary({
  int bidParticipationReviewPendingCount = 0,
  int publisherMaterialReviewPendingCount = 0,
  int bidMaterialReviewPendingCount = 0,
  int dealConfirmationPendingCount = 0,
}) {
  final total =
      bidParticipationReviewPendingCount +
      publisherMaterialReviewPendingCount +
      bidMaterialReviewPendingCount +
      dealConfirmationPendingCount;
  return <String, Object?>{
    'bidParticipationReviewPendingCount': bidParticipationReviewPendingCount,
    'publisherMaterialReviewPendingCount': publisherMaterialReviewPendingCount,
    'bidMaterialReviewPendingCount': bidMaterialReviewPendingCount,
    'dealConfirmationPendingCount': dealConfirmationPendingCount,
    'totalPendingCount': total,
  };
}

Map<String, Object?> _chatAvailability({
  bool canSendMessage = true,
  String? lockReasonCode,
  String? lockReasonText,
  String requiredNextAction = 'none',
}) {
  return <String, Object?>{
    'canSendMessage': canSendMessage,
    'lockReasonCode': lockReasonCode,
    'lockReasonText': lockReasonText,
    'requiredNextAction': requiredNextAction,
  };
}

Map<String, Object?> _workbenchEntry({
  required String entryKey,
  required String group,
  required String label,
  String? reviewState = 'pending_review',
  String availabilityState = 'readable',
  String actionState = 'enabled',
  int attachmentCount = 1,
  String? materialKind,
  String? bidMaterialSlot,
  String? latestFeedbackText,
}) {
  final material = group != 'deal_confirmation';
  return <String, Object?>{
    'entryKey': entryKey,
    'group': group,
    'label': label,
    'summary': null,
    'projectId': 'project-1',
    'threadId': 'thread-1',
    'bidId': 'bid-1',
    'viewerRole': 'bidder',
    'subjectOwnerRole': group == 'bid_materials'
        ? 'bidder'
        : group == 'deal_confirmation'
        ? 'platform'
        : 'publisher',
    'availabilityState': material ? availabilityState : 'unavailable',
    'reviewState': material ? reviewState : null,
    'actionState': material ? actionState : 'blocked',
    'attachmentCount': material ? attachmentCount : 0,
    'badgeCount': material && reviewState == 'pending_review' ? 1 : 0,
    'disabledReason': material && attachmentCount == 0 ? '当前资料尚未提交。' : null,
    'latestFeedbackText': latestFeedbackText,
    'latestFeedbackAt': latestFeedbackText == null
        ? null
        : '2026-05-04T11:00:00Z',
    'reviewedAt': reviewState == 'confirmed' ? '2026-05-04T11:00:00Z' : null,
    'routeTarget': <String, Object?>{
      'actionKey': material
          ? 'project_communication_material_review.open'
          : 'project_deal_confirmation.open',
      'canonicalPath': material
          ? '/api/app/message/project-communication/workbench/material-review-detail'
          : '/api/app/project/{projectId}/deal-confirmations',
      'params': <String, Object?>{
        'projectId': 'project-1',
        'threadId': 'thread-1',
        'bidId': 'bid-1',
        'entryKey': entryKey,
      },
    },
    'truthAnchor': <String, Object?>{
      'truthOwner': 'server',
      'subjectType': group == 'bid_materials'
          ? 'bid_submission_material'
          : group == 'deal_confirmation'
          ? 'deal_confirmation'
          : 'publisher_quote_basis_material',
      'projectId': 'project-1',
      'threadId': 'thread-1',
      'bidId': 'bid-1',
      'subjectOwnerOrganizationId': material ? 'org-owner' : null,
      'reviewerOrganizationId': material ? 'org-counterpart' : null,
      'materialKind': materialKind,
      'bidMaterialSlot': bidMaterialSlot,
      'dealConfirmationId': null,
      'sourceVersionToken': material ? 'source-$entryKey' : null,
    },
  };
}

List<Map<String, Object?>> _workbenchEntries({
  String effectState = 'pending_review',
  String quoteState = 'pending_review',
}) {
  return <Map<String, Object?>>[
    _workbenchEntry(
      entryKey: 'publisher_effect_image_review',
      group: 'publisher_materials',
      label: '效果图确认',
      reviewState: effectState,
      materialKind: 'effect_image',
    ),
    _workbenchEntry(
      entryKey: 'publisher_construction_doc_review',
      group: 'publisher_materials',
      label: '尺寸图 / 施工图确认',
      reviewState: 'unsubmitted',
      availabilityState: 'unsubmitted',
      actionState: 'blocked',
      attachmentCount: 0,
      materialKind: 'construction_doc',
    ),
    _workbenchEntry(
      entryKey: 'publisher_material_sample_review',
      group: 'publisher_materials',
      label: '材质图 / 材料样板确认',
      reviewState: 'needs_supplement',
      materialKind: 'material_sample',
      latestFeedbackText: '缺少材料品牌说明',
    ),
    _workbenchEntry(
      entryKey: 'publisher_equipment_material_list_review',
      group: 'publisher_materials',
      label: '设备物料清单确认',
      materialKind: 'equipment_material_list',
    ),
    _workbenchEntry(
      entryKey: 'publisher_service_list_review',
      group: 'publisher_materials',
      label: '服务清单确认',
      materialKind: 'service_list',
    ),
    _workbenchEntry(
      entryKey: 'bid_project_understanding_review',
      group: 'bid_materials',
      label: '项目理解确认',
      bidMaterialSlot: 'project_understanding',
    ),
    _workbenchEntry(
      entryKey: 'bid_quote_sheet_review',
      group: 'bid_materials',
      label: '报价表确认',
      reviewState: quoteState,
      bidMaterialSlot: 'quote_sheet',
    ),
    _workbenchEntry(
      entryKey: 'bid_schedule_plan_review',
      group: 'bid_materials',
      label: '进度安排确认',
      bidMaterialSlot: 'schedule_plan',
    ),
    _workbenchEntry(
      entryKey: 'contract_confirmation',
      group: 'deal_confirmation',
      label: '合同确认',
      reviewState: null,
    ),
    _workbenchEntry(
      entryKey: 'final_confirmed_amount_confirmation',
      group: 'deal_confirmation',
      label: '最终成交金额确认',
      reviewState: null,
    ),
  ];
}

Map<String, Object?> _workbenchPayload({
  String effectState = 'pending_review',
  String quoteState = 'pending_review',
}) {
  return <String, Object?>{
    'projectId': 'project-1',
    'threadId': 'thread-1',
    'viewerRole': 'bidder',
    'businessTodoSummary': _businessTodoSummary(
      publisherMaterialReviewPendingCount: 3,
    ),
    'chatAvailability': _chatAvailability(
      canSendMessage: false,
      lockReasonCode: 'publisher_material_confirmation_pending',
      lockReasonText: '请先确认发布方提供的报价依据资料。',
      requiredNextAction: 'confirm_publisher_materials',
    ),
    'entries': _workbenchEntries(
      effectState: effectState,
      quoteState: quoteState,
    ),
    'generatedAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Object?> _bidMaterial({
  required String attachmentId,
  required String attachmentKind,
}) {
  return <String, Object?>{
    'attachmentId': attachmentId,
    'projectId': 'project-1',
    'fileAssetId': 'file-$attachmentId',
    'fileName': '$attachmentId.pdf',
    'attachmentKind': attachmentKind,
    'mimeType': 'application/pdf',
    'sortOrder': 0,
    'createdAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_baseHandlers({String projectRelation = 'my_bid'}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/message/counterpart-conversation/detail':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _detailPayload(projectRelation: projectRelation),
        ),
    'GET /api/app/message/project-communication/thread':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _threadPayload(),
        ),
    'GET /api/app/message/project-communication/messages':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'nextCursor': null,
          },
        ),
    'GET /api/app/message/project-communication/workbench':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _workbenchPayload(),
        ),
    'GET /api/app/project/bid-materials': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'projectId': 'project-1',
            'attachments': <Object?>[
              _bidMaterial(
                attachmentId: 'effect',
                attachmentKind: 'effect_image',
              ),
            ],
          },
        ),
    'GET /api/app/file/preview/access': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'fileAssetId':
                request.uri.queryParameters['fileAssetId'] ?? 'file-effect',
            'projectId': 'project-1',
            'threadId': 'thread-1',
            'previewType': 'image',
            'canPreview': true,
            'fileName': 'effect.pdf',
            'mimeType': 'image/png',
            'accessUrl': 'https://example.test/effect.png',
            'expiresAt': '2026-05-04T12:00:00Z',
            'contentLengthBytes': 1024,
            'downloadAvailable': true,
            'fallbackReason': null,
          },
        ),
    'GET /api/app/bid/submission/snapshot': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'projectId': 'project-1',
            'bidId': 'bid-1',
            'bidder': <String, Object?>{
              'organizationId': 'org-counterpart',
              'displayName': '重庆海川展览工厂',
              'avatarUrl': null,
            },
            'submittedAt': '2026-05-04T10:00:00Z',
            'quoteAmount': 12000,
            'proposalSummary': '报价说明',
            'attachmentSummary': <String, Object?>{'count': 3},
            'attachments': <Object?>[
              <String, Object?>{
                'slotKey': 'quote_sheet',
                'slotLabel': '报价表',
                'fileAssetId': 'file-quote',
                'fileKind': 'bid_quote_sheet',
                'mimeType': 'application/pdf',
              },
            ],
            'availability': <String, Object?>{'readable': true},
          },
        ),
  };
}

void main() {
  testWidgets('workbench folds groups by default and keeps 10 fixed entries', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(handlers: _baseHandlers());

    await tester.pumpWidget(_buildPage(transport));
    await tester.pumpAndSettle();
    await _enterProjectCommunication(tester);

    expect(find.text('资料确认 · 10项'), findsOneWidget);
    expect(find.text('发布方资料'), findsNothing);
    await _openMaterialTools(tester);
    await _ensureVisible(tester, find.text('发布方资料'));
    expect(find.text('发布方资料'), findsOneWidget);
    expect(find.text('竞标资料'), findsOneWidget);
    expect(find.text('成交确认'), findsOneWidget);
    expect(find.text('需补充'), findsOneWidget);
    expect(find.text('有待确认资料'), findsOneWidget);
    expect(find.text('2 项暂不可读'), findsOneWidget);
    expect(find.text('效果图确认'), findsNothing);
    expect(find.text('项目理解确认'), findsNothing);
    expect(find.text('合同确认'), findsNothing);

    await _expandWorkbenchGroup(tester, '发布方资料');
    expect(find.text('效果图确认'), findsOneWidget);
    expect(find.text('尺寸图 / 施工图确认'), findsOneWidget);
    expect(find.text('材质图 / 材料样板确认'), findsOneWidget);
    expect(find.text('设备物料清单确认'), findsOneWidget);
    expect(find.text('服务清单确认'), findsOneWidget);
    expect(find.text('未提交'), findsOneWidget);

    await _expandWorkbenchGroup(tester, '竞标资料');
    expect(find.text('项目理解确认'), findsOneWidget);
    expect(find.text('报价表确认'), findsOneWidget);
    expect(find.text('进度安排确认'), findsOneWidget);

    await _expandWorkbenchGroup(tester, '成交确认');
    expect(find.text('合同确认'), findsOneWidget);
    expect(find.text('最终成交金额确认'), findsOneWidget);
    expect(find.text('报价确认'), findsNothing);
    expect(find.text('排期确认'), findsNothing);
    expect(find.text('工艺材质确认'), findsNothing);
    expect(find.widgetWithText(TextButton, '确认'), findsNothing);
    expect(find.text('发送确认卡'), findsNothing);
  });

  testWidgets(
    'confirming publisher material turns entry green from server response',
    (WidgetTester tester) async {
      final handlers = _baseHandlers();
      handlers['POST /api/app/message/project-communication/workbench/material-review'] =
          (AppApiRequest request) async {
            final body = request.body! as Map<String, Object?>;
            expect(body['entryKey'], 'publisher_effect_image_review');
            return AppApiResponse(
              statusCode: 202,
              uri: request.uri,
              body: <String, Object?>{
                'entry': _workbenchEntries(effectState: 'confirmed').first,
                'entries': _workbenchEntries(effectState: 'confirmed'),
                'projectId': 'project-1',
                'threadId': 'thread-1',
                'viewerRole': 'bidder',
                'updatedAt': '2026-05-04T11:00:00Z',
              },
            );
          };
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);
      await _expandWorkbenchGroup(tester, '发布方资料');
      await _ensureVisible(tester, find.text('效果图确认'));
      await tester.tap(find.text('效果图确认'));
      await tester.pumpAndSettle();
      expect(find.text('effect.pdf'), findsOneWidget);
      await tester.tap(find.text('预览').first);
      await tester.pumpAndSettle();
      expect(find.text('图片预览'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认无误'));
      await tester.pumpAndSettle();

      expect(find.text('已确认。'), findsOneWidget);
      expect(find.text('已确认'), findsOneWidget);
      expect(
        transport.requests.where(
          (request) =>
              request.method.name.toUpperCase() == 'POST' &&
              request.canonicalPath ==
                  '/api/app/message/project-communication/messages',
        ),
        isEmpty,
      );
    },
  );

  testWidgets('feedback on bid quote sheet turns entry red', (
    WidgetTester tester,
  ) async {
    final handlers = _baseHandlers();
    handlers['POST /api/app/message/project-communication/workbench/material-review'] =
        (AppApiRequest request) async {
          final body = request.body! as Map<String, Object?>;
          expect(body['entryKey'], 'bid_quote_sheet_review');
          expect(body['reviewAction'], 'request_supplement');
          return AppApiResponse(
            statusCode: 202,
            uri: request.uri,
            body: <String, Object?>{
              'entry': _workbenchEntries(quoteState: 'needs_supplement')[6],
              'entries': _workbenchEntries(quoteState: 'needs_supplement'),
              'projectId': 'project-1',
              'threadId': 'thread-1',
              'viewerRole': 'bidder',
              'updatedAt': '2026-05-04T11:00:00Z',
            },
          );
        };
    final transport = FakeAppApiTransport(handlers: handlers);

    await tester.pumpWidget(_buildPage(transport));
    await tester.pumpAndSettle();
    await _enterProjectCommunication(tester);
    await _expandWorkbenchGroup(tester, '竞标资料');
    await _ensureVisible(tester, find.text('报价表确认'));
    await tester.tap(find.text('报价表确认'));
    await tester.pumpAndSettle();
    expect(find.text('报价表'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '请补充最终报价合计。');
    await tester.tap(find.text('需要补充'));
    await tester.pumpAndSettle();

    expect(find.text('反馈已提交。'), findsOneWidget);
    expect(find.text('需补充'), findsWidgets);
  });

  testWidgets('deal confirmation entry is visible but does not charge', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(handlers: _baseHandlers());

    await tester.pumpWidget(_buildPage(transport));
    await tester.pumpAndSettle();
    await _enterProjectCommunication(tester);
    await _expandWorkbenchGroup(tester, '成交确认');
    await _ensureVisible(tester, find.text('最终成交金额确认'));
    await tester.tap(find.text('最终成交金额确认'));
    await tester.pumpAndSettle();

    expect(find.textContaining('不触发支付'), findsOneWidget);
    expect(find.textContaining('deal-confirmations'), findsWidgets);
    expect(
      transport.requests.where(
        (request) =>
            request.method.name.toUpperCase() == 'POST' &&
            request.canonicalPath.contains('deal-confirmations'),
      ),
      isEmpty,
    );
  });
}
