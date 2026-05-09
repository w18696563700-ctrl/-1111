import 'dart:async';
import 'dart:convert';

import 'package:archive/archive.dart';
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

List<int> _minimalOfficeDocxBytes(String body) {
  final archive = Archive()
    ..addFile(
      ArchiveFile.string(
        'word/document.xml',
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>$body</w:t></w:r></w:p></w:body></w:document>',
      ),
    );
  return ZipEncoder().encode(archive);
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
    onGenerateRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) =>
          Scaffold(body: Center(child: Text('业务入口：${settings.name}'))),
    ),
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
  if (label == '发布方资料' && find.text('效果图确认').evaluate().isNotEmpty) {
    return;
  }
  if (label == '竞标资料' && find.text('项目理解确认').evaluate().isNotEmpty) {
    return;
  }
  final group = find.text(label);
  await _ensureVisible(tester, group);
  await tester.tap(group.first);
  await tester.pumpAndSettle();
}

Future<void> _openMaterialTools(WidgetTester tester) async {
  var tools = find.widgetWithText(OutlinedButton, '资料确认 · 待处理3项');
  for (final label in const <String>['资料确认 · 待处理1项', '资料确认 · 8项', '资料确认单']) {
    if (tools.evaluate().isNotEmpty) {
      break;
    }
    tools = find.widgetWithText(OutlinedButton, label);
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

Map<String, Object?> _detailPayload({
  String projectRelation = 'my_bid',
  bool includeServiceFeeAuthorizationCard = false,
}) {
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
        'threadId': 'thread-1',
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
        'cards': <Object?>[
          if (includeServiceFeeAuthorizationCard)
            _serviceFeeAuthorizationBusinessCard(),
        ],
      },
    ],
  };
}

Map<String, Object?> _serviceFeeAuthorizationBusinessCard() {
  return <String, Object?>{
    'cardId': 'bid-participation:request-1',
    'cardType': 'bid_participation_request',
    'title': '参与竞标申请结果',
    'summary': '参与竞标申请已通过。',
    'status': 'approved',
    'updatedAt': '2026-05-04T10:00:00Z',
    'requesterCompanyName': '重庆海川展览工厂',
    'requesterOrganizationId': 'org-counterpart',
    'truthAnchor': <String, Object?>{
      'truthType': 'bid_participation_request',
      'projectId': 'project-1',
      'requestId': 'request-1',
      'bidId': 'bid-1',
      'threadId': 'request-1',
    },
    'detailRouteTarget': <String, Object?>{
      'objectType': 'bid_service_fee_authorization',
      'actionKey': 'bid_service_fee_authorization.open',
      'canonicalPath':
          '/api/app/project/{projectId}/bid-service-fee-authorizations',
      'params': <String, Object?>{
        'projectId': 'project-1',
        'bidParticipationRequestId': 'request-1',
        'bidId': 'bid-1',
      },
    },
    'decisionAvailability': null,
  };
}

Map<String, Object?> _threadPayload({
  String lockReasonCode = 'publisher_material_confirmation_pending',
  String lockReasonText = '请先确认发布方提供的报价依据资料。',
  String requiredNextAction = 'confirm_publisher_materials',
}) {
  return <String, Object?>{
    'threadId': 'thread-1',
    'projectId': 'project-1',
    'ownerOrganizationId': 'org-owner',
    'counterpartOrganizationId': 'org-counterpart',
    'chatAvailability': _chatAvailability(
      canSendMessage: false,
      lockReasonCode: lockReasonCode,
      lockReasonText: lockReasonText,
      requiredNextAction: requiredNextAction,
    ),
    'threadState': 'active',
    'lastMessageId': null,
    'lastMessageAt': null,
    'createdAt': '2026-05-04T10:00:00Z',
    'updatedAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Object?> _serviceFeeAuthorizationMessagePayload() {
  return <String, Object?>{
    'messageId': 'message-auth-required',
    'threadId': 'thread-1',
    'projectId': 'project-1',
    'senderUserId': 'publisher-user',
    'senderActorId': 'publisher-actor',
    'senderOrganizationId': 'org-counterpart',
    'messageKind': 'text',
    'body': '发布方已确认完你的资料：项目理解、报价表、进度安排。请完成 4000 元竞标服务费预授权额度；完成后项目级自由发送将开启。',
    'payload': <String, Object?>{
      'eventType': 'bid_materials_confirmed_service_fee_authorization_required',
      'sourceType': 'project_communication_material_review',
      'sourceId': 'bid-1',
      'bidId': 'bid-1',
      'group': 'bid_materials',
      'requiredNextAction': 'complete_service_fee_authorization',
      'routeTarget': <String, Object?>{
        'objectType': 'bid_service_fee_authorization',
        'actionKey': 'bid_service_fee_authorization.open',
        'canonicalPath':
            '/api/app/project/{projectId}/bid-service-fee-authorizations',
        'params': <String, Object?>{
          'projectId': 'project-1',
          'bidParticipationRequestId': 'request-1',
          'bidId': 'bid-1',
        },
      },
    },
    'clientMessageId': null,
    'messageState': 'active',
    'deliveryState': 'persisted',
    'readState': 'not_applicable',
    'readByCounterpartAt': null,
    'createdAt': '2026-05-04T11:00:00Z',
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
  String viewerRole = 'bidder',
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
    'viewerRole': viewerRole,
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
  String viewerRole = 'bidder',
  String effectState = 'pending_review',
  String materialSampleState = 'needs_supplement',
  String materialSampleActionState = 'enabled',
  String equipmentState = 'pending_review',
  String serviceState = 'pending_review',
  String projectUnderstandingState = 'pending_review',
  String quoteState = 'pending_review',
  String scheduleState = 'pending_review',
}) {
  return <Map<String, Object?>>[
    _workbenchEntry(
      entryKey: 'publisher_effect_image_review',
      group: 'publisher_materials',
      label: '效果图确认',
      viewerRole: viewerRole,
      reviewState: effectState,
      materialKind: 'effect_image',
    ),
    _workbenchEntry(
      entryKey: 'publisher_construction_doc_review',
      group: 'publisher_materials',
      label: '尺寸图 / 施工图确认',
      viewerRole: viewerRole,
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
      viewerRole: viewerRole,
      reviewState: materialSampleState,
      actionState: materialSampleActionState,
      materialKind: 'material_sample',
      latestFeedbackText: materialSampleState == 'needs_supplement'
          ? '缺少材料品牌说明'
          : null,
    ),
    _workbenchEntry(
      entryKey: 'publisher_equipment_material_list_review',
      group: 'publisher_materials',
      label: '设备物料清单确认',
      viewerRole: viewerRole,
      reviewState: equipmentState,
      materialKind: 'equipment_material_list',
    ),
    _workbenchEntry(
      entryKey: 'publisher_service_list_review',
      group: 'publisher_materials',
      label: '服务清单确认',
      viewerRole: viewerRole,
      reviewState: serviceState,
      materialKind: 'service_list',
    ),
    _workbenchEntry(
      entryKey: 'bid_project_understanding_review',
      group: 'bid_materials',
      label: '项目理解确认',
      viewerRole: viewerRole,
      reviewState: projectUnderstandingState,
      bidMaterialSlot: 'project_understanding',
    ),
    _workbenchEntry(
      entryKey: 'bid_quote_sheet_review',
      group: 'bid_materials',
      label: '报价表确认',
      viewerRole: viewerRole,
      reviewState: quoteState,
      bidMaterialSlot: 'quote_sheet',
    ),
    _workbenchEntry(
      entryKey: 'bid_schedule_plan_review',
      group: 'bid_materials',
      label: '进度安排确认',
      viewerRole: viewerRole,
      reviewState: scheduleState,
      bidMaterialSlot: 'schedule_plan',
    ),
    _workbenchEntry(
      entryKey: 'contract_confirmation',
      group: 'deal_confirmation',
      label: '合同确认',
      viewerRole: viewerRole,
      reviewState: null,
    ),
    _workbenchEntry(
      entryKey: 'final_confirmed_amount_confirmation',
      group: 'deal_confirmation',
      label: '最终成交金额确认',
      viewerRole: viewerRole,
      reviewState: null,
    ),
  ];
}

Map<String, Object?> _workbenchPayload({
  String viewerRole = 'bidder',
  String effectState = 'pending_review',
  String materialSampleState = 'needs_supplement',
  String materialSampleActionState = 'enabled',
  String equipmentState = 'pending_review',
  String serviceState = 'pending_review',
  String projectUnderstandingState = 'pending_review',
  String quoteState = 'pending_review',
  String scheduleState = 'pending_review',
  int materialReviewPendingCount = 3,
  int bidMaterialReviewPendingCount = 0,
}) {
  return <String, Object?>{
    'projectId': 'project-1',
    'threadId': 'thread-1',
    'viewerRole': viewerRole,
    'businessTodoSummary': _businessTodoSummary(
      publisherMaterialReviewPendingCount: materialReviewPendingCount,
      bidMaterialReviewPendingCount: bidMaterialReviewPendingCount,
    ),
    'chatAvailability': _chatAvailability(
      canSendMessage: false,
      lockReasonCode: 'publisher_material_confirmation_pending',
      lockReasonText: '请先确认发布方提供的报价依据资料。',
      requiredNextAction: 'confirm_publisher_materials',
    ),
    'entries': _workbenchEntries(
      viewerRole: viewerRole,
      effectState: effectState,
      materialSampleState: materialSampleState,
      materialSampleActionState: materialSampleActionState,
      equipmentState: equipmentState,
      serviceState: serviceState,
      projectUnderstandingState: projectUnderstandingState,
      quoteState: quoteState,
      scheduleState: scheduleState,
    ),
    'generatedAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Object?> _bidMaterial({
  required String attachmentId,
  required String attachmentKind,
  String? fileName,
  String mimeType = 'application/pdf',
}) {
  return <String, Object?>{
    'attachmentId': attachmentId,
    'projectId': 'project-1',
    'fileAssetId': 'file-$attachmentId',
    'fileName': fileName ?? '$attachmentId.pdf',
    'attachmentKind': attachmentKind,
    'mimeType': mimeType,
    'sortOrder': 0,
    'createdAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_baseHandlers({
  String projectRelation = 'my_bid',
  bool includeServiceFeeAuthorizationCard = false,
}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/message/counterpart-conversation/detail':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _detailPayload(
            projectRelation: projectRelation,
            includeServiceFeeAuthorizationCard:
                includeServiceFeeAuthorizationCard,
          ),
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
  setUp(() {
    ProjectAttachmentDebugOverrides.installRemoteImageBytesLoader((_) async {
      return base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=',
      );
    });
    ProjectAttachmentDebugOverrides.installExternalUrlOpener((_) async => true);
  });

  tearDown(ProjectAttachmentDebugOverrides.reset);

  testWidgets(
    'material confirmation entry opens publisher material list before detail',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(handlers: _baseHandlers());

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);

      expect(find.text('资料确认 · 待处理3项'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, '后续承接'));
      await tester.pumpAndSettle();
      expect(find.text('请先处理资料确认单，再进入后续承接。'), findsOneWidget);
      await _openMaterialTools(tester);
      expect(find.text('发布方资料'), findsOneWidget);
      expect(find.text('效果图确认'), findsOneWidget);
      expect(find.text('材质图 / 材料样板确认'), findsOneWidget);
      expect(find.text('设备物料清单确认'), findsOneWidget);
      expect(find.text('服务清单确认'), findsOneWidget);
      expect(find.text('确认无误'), findsNothing);
      await tester.tap(find.text('效果图确认'));
      await tester.pumpAndSettle();
      expect(find.text('effect.pdf'), findsOneWidget);
      expect(find.text('预览后确认'), findsOneWidget);
      expect(find.text('确认无误'), findsNothing);
    },
  );

  testWidgets(
    'service fee authorization lock CTA opens frozen card route target',
    (WidgetTester tester) async {
      final handlers = _baseHandlers(includeServiceFeeAuthorizationCard: true);
      handlers['GET /api/app/message/project-communication/thread'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _threadPayload(
              lockReasonCode: 'service_fee_authorization_pending',
              lockReasonText: '资料确认已通过，请先完成 4000 元竞标服务费预授权额度后开启项目级自由发送。',
              requiredNextAction: 'complete_service_fee_authorization',
            ),
          );
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);
      await _ensureVisible(tester, find.widgetWithText(TextButton, '去完成预授权'));
      await tester.tap(find.widgetWithText(TextButton, '去完成预授权').first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          '/exhibition/bids/submit?projectId=project-1&mode=service_fee_authorization&bidParticipationRequestId=request-1&bidId=bid-1',
        ),
        findsOneWidget,
      );
      expect(find.text('预授权入口暂不可用，请刷新后重试。'), findsNothing);
    },
  );

  testWidgets(
    'publisher waiting for service fee authorization does not show executable CTA',
    (WidgetTester tester) async {
      final handlers = _baseHandlers(projectRelation: 'my_published');
      handlers['GET /api/app/message/project-communication/thread'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _threadPayload(
              lockReasonCode: 'service_fee_authorization_pending',
              lockReasonText: '资料确认已通过，需等待竞标方完成 4000 元竞标服务费预授权额度后开启项目级自由发送。',
              requiredNextAction: 'complete_service_fee_authorization',
            ),
          );
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);

      expect(
        find.text('资料确认已通过，需等待竞标方完成 4000 元竞标服务费预授权额度后开启项目级自由发送。'),
        findsOneWidget,
      );
      expect(find.text('去完成预授权'), findsNothing);
    },
  );

  testWidgets(
    'material tools can still expand when there is no pending material',
    (WidgetTester tester) async {
      final handlers = _baseHandlers();
      handlers['GET /api/app/message/project-communication/workbench'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _workbenchPayload(
              effectState: 'confirmed',
              materialSampleState: 'confirmed',
              equipmentState: 'confirmed',
              serviceState: 'confirmed',
              projectUnderstandingState: 'confirmed',
              quoteState: 'confirmed',
              scheduleState: 'confirmed',
              materialReviewPendingCount: 0,
            ),
          );
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);

      expect(find.text('资料确认 · 8项'), findsOneWidget);
      await _openMaterialTools(tester);
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

      expect(find.text('成交确认'), findsNothing);
      expect(find.text('合同确认'), findsNothing);
      expect(find.text('最终成交金额确认'), findsNothing);
      expect(find.text('报价确认'), findsNothing);
      expect(find.text('排期确认'), findsNothing);
      expect(find.text('工艺材质确认'), findsNothing);
      expect(find.widgetWithText(TextButton, '确认'), findsNothing);
      expect(find.text('发送确认卡'), findsNothing);
    },
  );

  testWidgets(
    'confirming publisher material turns entry green from server response',
    (WidgetTester tester) async {
      final handlers = _baseHandlers();
      var effectState = 'pending_review';
      handlers['GET /api/app/message/project-communication/workbench'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _workbenchPayload(effectState: effectState),
          );
      handlers['POST /api/app/message/project-communication/workbench/material-review'] =
          (AppApiRequest request) async {
            final body = request.body! as Map<String, Object?>;
            expect(body['entryKey'], 'publisher_effect_image_review');
            effectState = 'confirmed';
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
      await _openMaterialTools(tester);
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

  testWidgets('failed preview does not unlock material confirmation', (
    WidgetTester tester,
  ) async {
    ProjectAttachmentDebugOverrides.installRemoteImageBytesLoader(
      (_) async => null,
    );
    final transport = FakeAppApiTransport(handlers: _baseHandlers());

    await tester.pumpWidget(_buildPage(transport));
    await tester.pumpAndSettle();
    await _enterProjectCommunication(tester);
    await _openMaterialTools(tester);
    await tester.tap(find.text('效果图确认'));
    await tester.pumpAndSettle();
    expect(find.text('effect.pdf'), findsOneWidget);

    await tester.tap(find.text('预览').first);
    await tester.pumpAndSettle();

    expect(find.text('当前图片资料暂时无法预览，请稍后再试。'), findsOneWidget);
    expect(find.text('预览后确认'), findsOneWidget);
    expect(find.text('确认无误'), findsNothing);
    expect(
      transport.requests.where(
        (request) =>
            request.method.name.toUpperCase() == 'POST' &&
            request.canonicalPath ==
                '/api/app/message/project-communication/workbench/material-review',
      ),
      isEmpty,
    );
  });

  testWidgets('docx material renders in app before confirmation', (
    WidgetTester tester,
  ) async {
    ProjectAttachmentDebugOverrides.installRemoteImageBytesLoader(
      (_) async => _minimalOfficeDocxBytes('报价依据资料正文'),
    );
    final handlers = _baseHandlers();
    handlers['GET /api/app/project/bid-materials'] =
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'projectId': 'project-1',
            'attachments': <Object?>[
              _bidMaterial(
                attachmentId: 'effect',
                attachmentKind: 'effect_image',
                fileName: '报价依据.docx',
                mimeType:
                    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              ),
            ],
          },
        );
    handlers['GET /api/app/file/preview/access'] =
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'fileAssetId': 'file-effect',
            'projectId': 'project-1',
            'threadId': 'thread-1',
            'previewType': 'unsupported',
            'canPreview': false,
            'fileName': '报价依据.docx',
            'mimeType':
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'accessUrl': 'https://signed.example/quote-basis.docx',
            'expiresAt': '2026-05-04T12:00:00Z',
            'contentLengthBytes': 4096,
            'downloadAvailable': true,
            'fallbackReason': 'unsupported_mime_type',
          },
        );
    final transport = FakeAppApiTransport(handlers: handlers);

    await tester.pumpWidget(_buildPage(transport));
    await tester.pumpAndSettle();
    await _enterProjectCommunication(tester);
    await _openMaterialTools(tester);
    await tester.tap(find.text('效果图确认'));
    await tester.pumpAndSettle();
    expect(find.text('报价依据.docx'), findsOneWidget);

    await tester.tap(find.text('预览').first);
    await tester.pumpAndSettle();

    expect(find.text('unsupported_mime_type'), findsNothing);
    expect(find.text('App 内资料预览'), findsOneWidget);
    expect(find.text('报价依据资料正文'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('确认无误'), findsOneWidget);
  });

  testWidgets(
    'pdf material does not unlock confirmation without embedded viewer',
    (WidgetTester tester) async {
      final handlers = _baseHandlers();
      handlers['GET /api/app/file/preview/access'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'fileAssetId': 'file-effect',
              'projectId': 'project-1',
              'threadId': 'thread-1',
              'previewType': 'pdf',
              'canPreview': true,
              'fileName': 'effect.pdf',
              'mimeType': 'application/pdf',
              'accessUrl': 'https://signed.example/effect.pdf',
              'expiresAt': '2026-05-04T12:00:00Z',
              'contentLengthBytes': 4096,
              'downloadAvailable': true,
              'fallbackReason': null,
            },
          );
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);
      await _openMaterialTools(tester);
      await tester.tap(find.text('效果图确认'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('预览').first);
      await tester.pumpAndSettle();

      expect(find.text('PDF 内嵌预览能力暂未接入，当前不能确认该资料。'), findsOneWidget);
      expect(find.text('预览后确认'), findsOneWidget);
      expect(find.text('确认无误'), findsNothing);
    },
  );

  testWidgets('feedback on bid quote sheet turns entry red', (
    WidgetTester tester,
  ) async {
    final handlers = _baseHandlers();
    var quoteState = 'pending_review';
    handlers['GET /api/app/message/project-communication/workbench'] =
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _workbenchPayload(
            effectState: 'confirmed',
            materialSampleState: 'confirmed',
            equipmentState: 'confirmed',
            serviceState: 'confirmed',
            projectUnderstandingState: 'confirmed',
            quoteState: quoteState,
            scheduleState: 'confirmed',
            materialReviewPendingCount: 1,
          ),
        );
    handlers['POST /api/app/message/project-communication/workbench/material-review'] =
        (AppApiRequest request) async {
          final body = request.body! as Map<String, Object?>;
          expect(body['entryKey'], 'bid_quote_sheet_review');
          expect(body['reviewAction'], 'request_supplement');
          quoteState = 'needs_supplement';
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
    await _openMaterialTools(tester);
    await _expandWorkbenchGroup(tester, '竞标资料');
    await _ensureVisible(tester, find.text('报价表确认'));
    await tester.tap(find.text('报价表确认'));
    await tester.pumpAndSettle();
    expect(find.text('报价表'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '请补充最终报价合计。');
    await tester.tap(find.text('需要补充'));
    await tester.pumpAndSettle();

    expect(find.text('反馈已提交。'), findsOneWidget);
  });

  testWidgets(
    'confirmed bid materials refresh messages and render service fee authorization CTA',
    (WidgetTester tester) async {
      final handlers = _baseHandlers(projectRelation: 'my_published');
      var completed = false;
      handlers['GET /api/app/message/project-communication/thread'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: completed
                ? _threadPayload(
                    lockReasonCode: 'service_fee_authorization_pending',
                    lockReasonText:
                        '资料确认已通过，需等待竞标方完成 4000 元竞标服务费预授权额度后开启项目级自由发送。',
                    requiredNextAction: 'complete_service_fee_authorization',
                  )
                : _threadPayload(
                    lockReasonCode: 'bid_material_confirmation_pending',
                    lockReasonText: '请先由发布方确认竞标报价资料。',
                    requiredNextAction: 'confirm_bid_materials',
                  ),
          );
      handlers['GET /api/app/message/project-communication/messages'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'items': completed
                  ? <Object?>[_serviceFeeAuthorizationMessagePayload()]
                  : <Object?>[],
              'nextCursor': null,
            },
          );
      handlers['GET /api/app/message/project-communication/workbench'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _workbenchPayload(
              viewerRole: 'publisher',
              effectState: 'confirmed',
              materialSampleState: 'confirmed',
              equipmentState: 'confirmed',
              serviceState: 'confirmed',
              projectUnderstandingState: 'confirmed',
              quoteState: 'confirmed',
              scheduleState: completed ? 'confirmed' : 'pending_review',
              materialReviewPendingCount: 0,
              bidMaterialReviewPendingCount: completed ? 0 : 1,
            ),
          );
      handlers['GET /api/app/bid/submission/snapshot'] =
          (AppApiRequest request) async => AppApiResponse(
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
                  'slotKey': 'schedule_plan',
                  'slotLabel': '进度安排',
                  'fileAssetId': 'file-schedule',
                  'fileKind': 'bid_schedule_plan',
                  'mimeType': 'image/png',
                },
              ],
              'availability': <String, Object?>{'readable': true},
            },
          );
      handlers['POST /api/app/message/project-communication/workbench/material-review'] =
          (AppApiRequest request) async {
            final body = request.body! as Map<String, Object?>;
            expect(body['entryKey'], 'bid_schedule_plan_review');
            expect(body['reviewAction'], 'confirm');
            completed = true;
            return AppApiResponse(
              statusCode: 202,
              uri: request.uri,
              body: <String, Object?>{
                'entry': _workbenchEntries(
                  viewerRole: 'publisher',
                  projectUnderstandingState: 'confirmed',
                  quoteState: 'confirmed',
                  scheduleState: 'confirmed',
                )[7],
                'entries': _workbenchEntries(
                  viewerRole: 'publisher',
                  projectUnderstandingState: 'confirmed',
                  quoteState: 'confirmed',
                  scheduleState: 'confirmed',
                ),
                'projectId': 'project-1',
                'threadId': 'thread-1',
                'viewerRole': 'publisher',
                'updatedAt': '2026-05-04T11:00:00Z',
              },
            );
          };
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);
      await _openMaterialTools(tester);
      await _expandWorkbenchGroup(tester, '竞标资料');
      await _ensureVisible(tester, find.text('进度安排确认'));
      await tester.tap(find.text('进度安排确认'));
      await tester.pumpAndSettle();
      if (find.text('预览').evaluate().isNotEmpty) {
        await tester.tap(find.text('预览').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
      }
      await _ensureVisible(tester, find.text('确认无误'));
      await tester.tap(find.text('确认无误'));
      await tester.pumpAndSettle();

      await _ensureVisible(tester, find.text('资料确认已通过'));
      expect(find.text('资料确认已通过'), findsOneWidget);
      expect(find.text('去完成预授权'), findsWidgets);
      await _ensureVisible(tester, find.widgetWithText(FilledButton, '去完成预授权'));
      await tester.tap(find.widgetWithText(FilledButton, '去完成预授权'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          '/exhibition/bids/submit?projectId=project-1&mode=service_fee_authorization&bidParticipationRequestId=request-1&bidId=bid-1',
        ),
        findsOneWidget,
      );
      expect(
        transport.requests
            .where(
              (request) =>
                  request.method.name.toUpperCase() == 'GET' &&
                  request.canonicalPath ==
                      '/api/app/message/project-communication/messages',
            )
            .length,
        greaterThanOrEqualTo(2),
      );
    },
  );

  testWidgets(
    'publisher supplement request keeps chat locked and opens real material page entry',
    (WidgetTester tester) async {
      final handlers = _baseHandlers(projectRelation: 'my_published');
      handlers['GET /api/app/message/project-communication/workbench'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _workbenchPayload(
              viewerRole: 'publisher',
              effectState: 'confirmed',
              materialSampleState: 'needs_supplement',
              materialSampleActionState: 'readonly',
              equipmentState: 'confirmed',
              serviceState: 'confirmed',
              projectUnderstandingState: 'confirmed',
              quoteState: 'confirmed',
              scheduleState: 'confirmed',
              materialReviewPendingCount: 1,
            ),
          );
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);
      await _openMaterialTools(tester);
      await _expandWorkbenchGroup(tester, '发布方资料');
      await _ensureVisible(tester, find.text('材质图 / 材料样板确认'));
      await tester.tap(find.text('材质图 / 材料样板确认'));
      await tester.pumpAndSettle();

      expect(find.text('最近反馈：缺少材料品牌说明'), findsOneWidget);
      expect(find.text('去补充该资料'), findsOneWidget);
      expect(find.textContaining('当前项目沟通仍处于锁定状态'), findsOneWidget);
      expect(find.text('确认无误'), findsNothing);
    },
  );

  testWidgets(
    'bidder supplement request opens bid submit from material detail',
    (WidgetTester tester) async {
      final handlers = _baseHandlers();
      handlers['GET /api/app/message/project-communication/workbench'] =
          (AppApiRequest request) async => AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _workbenchPayload(
              effectState: 'confirmed',
              materialSampleState: 'confirmed',
              equipmentState: 'confirmed',
              serviceState: 'confirmed',
              projectUnderstandingState: 'confirmed',
              quoteState: 'needs_supplement',
              scheduleState: 'confirmed',
              materialReviewPendingCount: 1,
            ),
          );
      final transport = FakeAppApiTransport(handlers: handlers);

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await _enterProjectCommunication(tester);
      await _openMaterialTools(tester);
      await _expandWorkbenchGroup(tester, '竞标资料');
      await _ensureVisible(tester, find.text('报价表确认'));
      await tester.tap(find.text('报价表确认'));
      await tester.pumpAndSettle();

      expect(find.text('去补充竞标资料'), findsOneWidget);
      expect(find.textContaining('请回到竞标提交页补充项目理解'), findsOneWidget);
      expect(find.text('当前账号只能查看该资料审阅结果。'), findsNothing);
      expect(find.text('请先补充竞标资料，补充成功后等待发布方重新确认。'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, '去补充竞标资料'));
      await tester.pumpAndSettle();

      expect(find.textContaining('/exhibition/bids/submit'), findsOneWidget);
      expect(find.textContaining('projectId=project-1'), findsOneWidget);
    },
  );

  testWidgets('deal confirmation entry is visible but does not charge', (
    WidgetTester tester,
  ) async {
    final handlers = _baseHandlers();
    handlers['GET /api/app/message/project-communication/workbench'] =
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _workbenchPayload(
            effectState: 'confirmed',
            materialSampleState: 'confirmed',
            equipmentState: 'confirmed',
            serviceState: 'confirmed',
            projectUnderstandingState: 'confirmed',
            quoteState: 'confirmed',
            scheduleState: 'confirmed',
            materialReviewPendingCount: 0,
          ),
        );
    final transport = FakeAppApiTransport(handlers: handlers);

    await tester.pumpWidget(_buildPage(transport));
    await tester.pumpAndSettle();
    await _enterProjectCommunication(tester);
    await _ensureVisible(tester, find.widgetWithText(OutlinedButton, '后续承接'));
    await tester.tap(find.widgetWithText(OutlinedButton, '后续承接'));
    await tester.pumpAndSettle();
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
