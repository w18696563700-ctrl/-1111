import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/trading_im_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/evidence';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont(
      family: 'STHeiti',
      path: '/System/Library/Fonts/STHeiti Medium.ttc',
    );
    await _loadFont(
      family: 'MaterialIcons',
      path:
          '/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
    );
  });

  testWidgets('capture folded workbench refinement states', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(560, 900));
    final foldedKey = GlobalKey();
    await _pumpCapturePage(tester, foldedKey);
    await _enterProjectCommunication(tester);
    await _openMaterialWorkbench(tester);
    await _ensureVisible(tester, find.text('发布方资料'));
    await _capture(
      foldedKey,
      '20260503-project-communication-workbench-folded.png',
    );

    await tester.tap(find.text('发布方资料').first);
    await tester.pumpAndSettle();
    await _ensureVisible(tester, find.text('效果图确认'));
    await _capture(
      foldedKey,
      '20260503-project-communication-workbench-expanded.png',
    );
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    final narrowKey = GlobalKey();
    await _pumpCapturePage(tester, narrowKey);
    await _enterProjectCommunication(tester);
    await _openMaterialWorkbench(tester);
    await _ensureVisible(tester, find.text('发布方资料'));
    await _capture(
      narrowKey,
      '20260503-project-communication-workbench-narrow.png',
    );
    await tester.binding.setSurfaceSize(null);
  });
}

Future<void> _pumpCapturePage(
  WidgetTester tester,
  GlobalKey boundaryKey,
) async {
  final transport = FakeAppApiTransport(handlers: _handlers());
  final client = AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
  ExhibitionConsumerLayer.install(ExhibitionConsumerLayer(client: client));
  TradingImConsumerLayer.install(TradingImConsumerLayer(client: client));
  CounterpartConversationConsumerLayer.install(
    CounterpartConversationConsumerLayer(
      client: client,
      realtimeClient: const _NoopProjectCommunicationRealtimeClient(),
    ),
  );

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'STHeiti'),
        home: const Scaffold(
          body: CounterpartConversationPage(
            conversationId: 'conversation-1',
            projectId: 'project-1',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _loadFont({required String family, required String path}) async {
  final bytes = File(path).readAsBytesSync();
  final fontData = ByteData.view(Uint8List.fromList(bytes).buffer);
  await (FontLoader(family)..addFont(Future<ByteData>.value(fontData))).load();
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

Future<void> _openMaterialWorkbench(WidgetTester tester) async {
  final entry = find.textContaining('资料确认').last;
  await _ensureVisible(tester, entry);
  await tester.tap(entry);
  await tester.pumpAndSettle();
}

Future<void> _capture(GlobalKey boundaryKey, String filename) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_handlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/message/counterpart-conversation/detail':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _detailPayload(),
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
          body: <String, Object?>{
            'items': <Object?>[
              _messagePayload(messageId: 'msg-1', body: '在吗？'),
              _messagePayload(messageId: 'msg-2', body: '在吗？'),
              _messagePayload(messageId: 'msg-3', body: '?'),
            ],
            'nextCursor': null,
          },
        ),
    'GET /api/app/message/project-communication/workbench':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _workbenchPayload(),
        ),
  };
}

Map<String, Object?> _detailPayload() {
  return <String, Object?>{
    'conversationId': 'conversation-1',
    'counterpart': const <String, Object?>{
      'organizationId': 'org-counterpart',
      'displayName': '重庆海川展览工厂',
      'nickname': '江北喊鲲帅',
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
        'projectDisplayTitle': 'POPAY会员赛事受控测试-day10a-flagship',
        'titleVisibility': 'visible',
        'projectRelation': 'my_bid',
        'projectState': 'published',
        'projectPublishedAt': '2026-05-01T18:00:00',
        'projectUpdatedAt': '2026-05-04T17:00:00',
        'latestActivityAt': '2026-05-04T10:00:00Z',
        'projectUnreadCount': 0,
        'hasProjectUnread': false,
        'businessTodoSummary': _businessTodoSummary(),
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
    'chatAvailability': _chatAvailability(),
    'threadState': 'active',
    'lastMessageId': 'msg-3',
    'lastMessageAt': '2026-05-04T10:02:00Z',
    'createdAt': '2026-05-04T10:00:00Z',
    'updatedAt': '2026-05-04T10:02:00Z',
  };
}

Map<String, Object?> _businessTodoSummary() {
  return const <String, Object?>{
    'bidParticipationReviewPendingCount': 0,
    'publisherMaterialReviewPendingCount': 0,
    'bidMaterialReviewPendingCount': 0,
    'dealConfirmationPendingCount': 0,
    'totalPendingCount': 0,
  };
}

Map<String, Object?> _chatAvailability() {
  return const <String, Object?>{
    'canSendMessage': true,
    'lockReasonCode': null,
    'lockReasonText': null,
    'requiredNextAction': 'none',
  };
}

Map<String, Object?> _messagePayload({
  required String messageId,
  required String body,
}) {
  return <String, Object?>{
    'messageId': messageId,
    'threadId': 'thread-1',
    'projectId': 'project-1',
    'senderUserId': 'user-1',
    'senderActorId': 'actor-1',
    'senderOrganizationId': 'org-owner',
    'messageKind': 'text',
    'body': body,
    'payload': null,
    'clientMessageId': null,
    'messageState': 'active',
    'createdAt': '2026-05-04T10:02:00Z',
  };
}

Map<String, Object?> _workbenchPayload() {
  return <String, Object?>{
    'projectId': 'project-1',
    'threadId': 'thread-1',
    'viewerRole': 'bidder',
    'businessTodoSummary': _businessTodoSummary(),
    'chatAvailability': _chatAvailability(),
    'entries': <Object?>[
      _workbenchEntry(
        entryKey: 'publisher_effect_image_review',
        group: 'publisher_materials',
        label: '效果图确认',
      ),
      _workbenchEntry(
        entryKey: 'publisher_construction_doc_review',
        group: 'publisher_materials',
        label: '尺寸图 / 施工图确认',
      ),
      _workbenchEntry(
        entryKey: 'publisher_material_sample_review',
        group: 'publisher_materials',
        label: '材质图 / 材料样板确认',
      ),
      _workbenchEntry(
        entryKey: 'publisher_equipment_material_list_review',
        group: 'publisher_materials',
        label: '设备物料清单确认',
      ),
      _workbenchEntry(
        entryKey: 'publisher_service_list_review',
        group: 'publisher_materials',
        label: '服务清单确认',
      ),
      _workbenchEntry(
        entryKey: 'bid_project_understanding_review',
        group: 'bid_materials',
        label: '项目理解确认',
      ),
      _workbenchEntry(
        entryKey: 'bid_quote_sheet_review',
        group: 'bid_materials',
        label: '报价表确认',
      ),
      _workbenchEntry(
        entryKey: 'bid_schedule_plan_review',
        group: 'bid_materials',
        label: '进度安排确认',
      ),
      _workbenchEntry(
        entryKey: 'contract_confirmation',
        group: 'deal_confirmation',
        label: '合同确认',
      ),
      _workbenchEntry(
        entryKey: 'final_confirmed_amount_confirmation',
        group: 'deal_confirmation',
        label: '最终成交金额确认',
      ),
    ],
    'generatedAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Object?> _workbenchEntry({
  required String entryKey,
  required String group,
  required String label,
}) {
  return <String, Object?>{
    'entryKey': entryKey,
    'group': group,
    'label': label,
    'summary': null,
    'projectId': 'project-1',
    'threadId': 'thread-1',
    'bidId': 'bid-1',
    'viewerRole': 'bidder',
    'subjectOwnerRole': group == 'deal_confirmation' ? 'platform' : 'publisher',
    'availabilityState': 'unavailable',
    'reviewState': null,
    'actionState': 'blocked',
    'attachmentCount': 0,
    'badgeCount': 0,
    'disabledReason': '当前资料尚未提交。',
    'latestFeedbackText': null,
    'latestFeedbackAt': null,
    'reviewedAt': null,
    'routeTarget': null,
    'truthAnchor': const <String, Object?>{
      'truthOwner': 'server',
      'subjectType': 'publisher_quote_basis_material',
      'projectId': 'project-1',
      'threadId': 'thread-1',
      'bidId': 'bid-1',
      'subjectOwnerOrganizationId': null,
      'reviewerOrganizationId': null,
      'materialKind': null,
      'bidMaterialSlot': null,
      'dealConfirmationId': null,
      'sourceVersionToken': null,
    },
  };
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
