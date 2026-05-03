import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/trading_im_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/shell/navigation/app_building.dart';
import 'package:mobile/shell/shell_app.dart';

import 'support/exhibition_home_test_doubles.dart';

Map<String, Object?> _summary([String heading = 'summary']) {
  return <String, Object?>{'heading': heading};
}

CounterpartConversationConsumerLayer _counterpartConsumerWithNoopRealtime(
  FakeAppApiTransport transport,
) {
  return CounterpartConversationConsumerLayer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: transport,
    ),
    realtimeClient: const _NoopProjectCommunicationRealtimeClient(),
  );
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
      done: Completer<void>().future,
      close: () async {
        await controller.close();
      },
    );
  }
}

Map<String, Object?> _publicResourceItem({
  required String resourceId,
  required String resourceCategory,
  required String title,
  required String fileAssetId,
  required String fileName,
  required String mimeType,
  required int sortOrder,
  String? summary,
}) {
  return <String, Object?>{
    'resourceId': resourceId,
    'resourceCategory': resourceCategory,
    'title': title,
    'summary': summary,
    'fileAssetId': fileAssetId,
    'fileName': fileName,
    'mimeType': mimeType,
    'visibility': 'app_shared',
    'sortOrder': sortOrder,
    'publishedAt': '2026-04-14T09:30:00Z',
  };
}

Map<String, Object?> _publicResourceListResponse(
  List<Map<String, Object?>> resources,
) {
  return <String, Object?>{'resources': resources};
}

Map<String, Object?> _projectPayload({
  required String projectId,
  String projectNo = 'PROJ-1',
  String title = '展览项目',
  String buildingType = 'exhibition',
  num budgetAmount = 1000,
  String viewerProjectRelation = 'non_owner',
  String state = 'published',
  String summaryHeading = 'project',
  num? areaSqm,
  String? buildingTypeRemark,
  String? description,
  String? provinceCode,
  String? provinceName,
  String? cityCode,
  String? cityName,
  String? districtCode,
  String? districtName,
  String? detailAddress,
  String? scopeSummary,
  String? plannedStartAt,
  String? plannedEndAt,
  String? scheduleDetail,
  String? taskId,
  String? tradeTaskId,
  Map<String, Object?>? currentViewerBid,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': projectNo,
    'title': title,
    if (taskId case final String value) 'taskId': value,
    if (tradeTaskId case final String value) 'tradeTaskId': value,
    if (currentViewerBid case final Map<String, Object?> value)
      'currentViewerBid': value,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    if (areaSqm case final num value) 'areaSqm': value,
    if (buildingTypeRemark case final String value) 'buildingTypeRemark': value,
    if (description case final String value) 'description': value,
    if (provinceCode case final String value) 'provinceCode': value,
    if (provinceName case final String value) 'provinceName': value,
    if (cityCode case final String value) 'cityCode': value,
    if (cityName case final String value) 'cityName': value,
    if (districtCode case final String value) 'districtCode': value,
    if (districtName case final String value) 'districtName': value,
    if (detailAddress case final String value) 'detailAddress': value,
    if (scopeSummary case final String value) 'scopeSummary': value,
    if (plannedStartAt case final String value) 'plannedStartAt': value,
    if (plannedEndAt case final String value) 'plannedEndAt': value,
    if (scheduleDetail case final String value) 'scheduleDetail': value,
    'viewerProjectRelation': viewerProjectRelation,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

Map<String, Object?> _orderPayload({
  required String orderId,
  required String projectId,
  required String bidId,
  String orderNo = 'ORD-1',
  String state = 'active',
  String summaryHeading = 'order',
  List<Object?> milestones = const <Object?>[],
}) {
  return <String, Object?>{
    'orderId': orderId,
    'orderNo': orderNo,
    'projectId': projectId,
    'bidId': bidId,
    'state': state,
    'summary': _summary(summaryHeading),
    'milestones': milestones,
  };
}

Map<String, Object?> _myProjectPrivateSummary({
  bool hasAcceptedOrder = false,
  String? orderStatus,
  String? contractStatus,
  String? fulfillmentStatus,
  String? acceptanceStatus,
  String? afterSalesOrDisputeStatus,
  String formalCompletionStatus = 'not_formally_completed',
  String evaluationStatus = 'not_eligible',
}) {
  return <String, Object?>{
    'hasAcceptedOrder': hasAcceptedOrder,
    'orderStatus': orderStatus,
    'contractStatus': contractStatus,
    'fulfillmentStatus': fulfillmentStatus,
    'acceptanceStatus': acceptanceStatus,
    'afterSalesOrDisputeStatus': afterSalesOrDisputeStatus,
    'formalCompletionStatus': formalCompletionStatus,
    'evaluationStatus': evaluationStatus,
  };
}

Map<String, Object?> _myProjectListItem({
  required String projectId,
  required String title,
  String state = 'published',
}) {
  return <String, Object?>{
    'publicProject': _projectPayload(
      projectId: projectId,
      title: title,
      state: state,
      viewerProjectRelation: 'owner',
    ),
    'privateSummary': _myProjectPrivateSummary(),
  };
}

Map<String, Object?> _myBidItem({
  required String bidId,
  required String projectId,
  required String projectNo,
  required String projectTitle,
  required num quoteAmount,
  required String proposalSummaryPreview,
  required String submittedAt,
  required String outcomeState,
  required bool canOpenBidThread,
  required bool canOpenBidResult,
}) {
  return <String, Object?>{
    'bidId': bidId,
    'projectId': projectId,
    'projectNo': projectNo,
    'projectTitle': projectTitle,
    'quoteAmount': quoteAmount,
    'proposalSummaryPreview': proposalSummaryPreview,
    'submittedAt': submittedAt,
    'outcomeState': outcomeState,
    'canOpenBidThread': canOpenBidThread,
    'canOpenBidResult': canOpenBidResult,
  };
}

Map<String, Object?> _messageInteractionItem({
  required String interactionId,
  required String projectId,
  required String bidId,
  required String counterpartName,
  required String summary,
  required String lastMessageText,
}) {
  final definition =
      messagesRegisteredEntryByActionKey['counterpart_conversation.open']!;
  return <String, Object?>{
    'interactionId': interactionId,
    'interactionType': 'counterpart_conversation',
    'conversationId': 'org-$interactionId',
    'projectId': projectId,
    'counterpart': <String, Object?>{
      'organizationId': 'org-$interactionId',
      'displayName': counterpartName,
      'avatarUrl': null,
      'role': 'counterpart',
    },
    'summary': <String, Object?>{
      'focusProjectId': projectId,
      'title': '新的竞标已提交',
      'text': lastMessageText.isEmpty ? summary : lastMessageText,
      'projectCount': 1,
      'latestCardType': 'bid_thread',
    },
    'updatedAt': '2026-04-20T10:00:00Z',
    'routeTarget': <String, Object?>{
      'objectType': definition.objectType,
      'actionKey': definition.actionKey,
      'canonicalPath': definition.canonicalPath,
      'params': <String, String>{
        'conversationId': 'org-$interactionId',
        'projectId': projectId,
      },
    },
  };
}

Map<String, Object?> _counterpartConversationBidDetailPayload({
  required String interactionId,
  required String projectId,
  required String bidId,
  required String counterpartName,
}) {
  final bidThreadDefinition =
      messagesRegisteredEntryByActionKey['bid_thread.open']!;
  return <String, Object?>{
    'conversationId': 'org-$interactionId',
    'counterpart': <String, Object?>{
      'organizationId': 'org-$interactionId',
      'displayName': counterpartName,
      'avatarUrl': null,
      'role': 'counterpart',
    },
    'summary': <String, Object?>{
      'focusProjectId': projectId,
      'title': counterpartName,
      'text': '当前竞标已提交，可继续进入沟通。',
      'projectCount': 1,
      'latestCardType': 'bid_thread',
    },
    'focusProjectId': projectId,
    'latestActivityAt': '2026-04-20T10:00:00Z',
    'projectGroups': <Object?>[
      <String, Object?>{
        'projectId': projectId,
        'projectDisplayTitle': '展览项目 1',
        'titleVisibility': 'visible',
        'projectState': 'published',
        'latestActivityAt': '2026-04-20T10:00:00Z',
        'cards': <Object?>[
          <String, Object?>{
            'cardId': 'card-$interactionId-bid',
            'cardType': 'bid_thread',
            'title': '新的竞标已提交',
            'summary': '$counterpartName 已对当前项目提交竞标。',
            'status': 'submitted',
            'updatedAt': '2026-04-20T10:00:00Z',
            'truthAnchor': <String, Object?>{
              'truthType': 'bid_thread',
              'projectId': projectId,
              'bidId': bidId,
              'threadId': 'thread-$interactionId',
            },
            'detailRouteTarget': <String, Object?>{
              'objectType': bidThreadDefinition.objectType,
              'actionKey': bidThreadDefinition.actionKey,
              'canonicalPath': bidThreadDefinition.canonicalPath,
              'params': <String, Object?>{
                'projectId': projectId,
                'bidId': bidId,
              },
            },
          },
        ],
      },
    ],
  };
}

Map<String, Object?> _bidThreadDetailPayload({
  required String threadId,
  required String projectId,
  required String bidId,
}) {
  return <String, Object?>{
    'threadId': threadId,
    'projectId': projectId,
    'bidId': bidId,
    'participants': const <Object?>[
      <String, Object?>{
        'participantRole': 'project_owner',
        'organizationId': 'org-owner-1',
      },
      <String, Object?>{
        'participantRole': 'bidder',
        'organizationId': 'org-bidder-1',
      },
    ],
    'viewerParticipantRole': 'project_owner',
    'state': 'open',
    'availability': const <String, Object?>{
      'canSendMessage': true,
      'canCreateConfirmation': true,
      'reason': 'participant_allowed',
    },
    'messages': const <Object?>[
      <String, Object?>{
        'messageId': 'message-1',
        'threadId': 'thread-1',
        'projectId': 'project-1',
        'bidId': 'bid-1',
        'senderRole': 'bidder',
        'body': '报价单已更新。',
        'attachmentFileAssetIds': <Object?>[],
        'createdAt': '2026-04-16T00:01:00Z',
      },
    ],
    'confirmationCards': const <Object?>[],
  };
}

Map<String, Object?> _shellContextPayload({
  String userId = 'user-1',
  String? organizationId = 'org-1',
  String? organizationType,
  List<String> roleKeys = const <String>[],
  String? certificationStatus,
  String? personalCertificationStatus = 'approved',
  bool? personalCertificationQualified = true,
  bool? personalCertificationLockedToOtherActor = false,
  String? membershipStatus,
  bool? canCreateProject,
  List<String> visibleBuildings = const <String>[
    'exhibition',
    'messages',
    'profile',
  ],
  String featureFlagsVersion = 'ffv-20260328',
  Map<String, Object?> unreadSummary = const <String, Object?>{},
}) {
  return <String, Object?>{
    'userId': userId,
    'organizationId': organizationId,
    'organizationType': organizationType,
    'roleKeys': roleKeys,
    'certificationStatus': certificationStatus,
    'personalCertificationStatus': personalCertificationStatus,
    'personalCertificationQualified': personalCertificationQualified,
    'personalCertificationLockedToOtherActor':
        personalCertificationLockedToOtherActor,
    'membershipStatus': membershipStatus,
    if (canCreateProject case final bool value)
      'projectCreateEligibility': <String, Object?>{'canCreateProject': value},
    'visibleBuildings': visibleBuildings,
    'featureFlagsVersion': featureFlagsVersion,
    'unreadSummary': unreadSummary,
  };
}

Future<void> _scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pumpAndSettle();
}

Finder _textFieldByLabel(String label) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is TextField && widget.decoration?.labelText == label,
  );
}

Future<void> _expandBidSubmitFlowIfNeeded(WidgetTester tester) async {
  final continueFinder = find.widgetWithText(FilledButton, '查看报价依据资料');
  if (continueFinder.evaluate().isEmpty) {
    return;
  }
  await _scrollAndTap(tester, continueFinder.first);
}

Future<void> _enterVisibleTextField(
  WidgetTester tester, {
  required String label,
  required String value,
}) async {
  await _expandBidSubmitFlowIfNeeded(tester);
  final fieldFinder = _textFieldByLabel(label);
  await tester.scrollUntilVisible(
    fieldFinder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.enterText(fieldFinder, value);
}

Future<void> _expectVisibleText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  expect(find.text(text), findsOneWidget);
}

Future<void> _expectVisibleTextContaining(
  WidgetTester tester,
  String text,
) async {
  await tester.scrollUntilVisible(
    find.textContaining(text),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  expect(find.textContaining(text), findsOneWidget);
}

int _textFieldIndexByLabel(WidgetTester tester, String label) {
  final widgets = tester.allWidgets.toList(growable: false);
  return widgets.indexWhere(
    (Widget widget) =>
        widget is TextField && widget.decoration?.labelText == label,
  );
}

Future<void> _uploadBidAttachment(WidgetTester tester, String label) async {
  await _expandBidSubmitFlowIfNeeded(tester);
  await _scrollAndTap(tester, find.widgetWithText(FilledButton, '上传$label'));
}

Future<void> _confirmBidSubmitServiceFeeRules(WidgetTester tester) async {
  await _expandBidSubmitFlowIfNeeded(tester);
  await _scrollAndTap(tester, find.text('我已阅读并同意平台成交服务费规则'));
  await _scrollAndTap(tester, find.text('我知晓未中标自动释放，中标并合同确认后正式扣款'));
  await _scrollAndTap(tester, find.text('我知晓发布方毁约或项目条件重大变化时，预授权应按规则释放'));
}

Finder _projectCreateField(String label) {
  final key = switch (label) {
    '项目名称' => 'project-create-title',
    '品牌' => 'project-create-brand-name',
    '项目类型' => 'project-create-building-type',
    '类型备注（选填）' => 'project-create-building-type-remark',
    '预算金额' => 'project-create-budget-amount',
    '项目面积' => 'project-create-area-sqm',
    '省' => 'project-create-province',
    '市' => 'project-create-city',
    '区/县' => 'project-create-district',
    '详细地址' => 'project-create-detail-address',
    '范围说明' => 'project-create-scope-summary',
    '计划开始日期' => 'project-create-planned-start-at',
    '计划结束日期' => 'project-create-planned-end-at',
    '详细时间（选填）' => 'project-create-schedule-detail',
    '补充说明' => 'project-create-description',
    _ => throw ArgumentError('Unknown project create field: $label'),
  };
  return find.byKey(ValueKey<String>(key));
}

Finder _projectCreateSubmitLabel() {
  return find.text('保存并查看我的项目');
}

Finder _projectCreateSubmitButton() {
  return find.ancestor(
    of: _projectCreateSubmitLabel(),
    matching: find.byType(FilledButton),
  );
}

Map<String, Object?> _projectCreateAddressRangeBody({
  String title = '展览项目',
  String buildingType = 'exhibition',
  double budgetAmount = 1000,
  double? areaSqm,
  String? buildingTypeRemark,
  String provinceCode = '510000',
  String provinceName = '四川',
  String cityCode = '510100',
  String cityName = '成都',
  String? districtCode = '510107',
  String? districtName = '武侯区',
  String detailAddress = '世纪城新国际会展中心 6 号馆西门',
  String scopeSummary = '主舞台、医疗器械展区与灯光联动区进场搭建',
  String? plannedStartAt = '2026-04-10',
  String? plannedEndAt = '2026-04-18',
  String? scheduleDetail,
  String? description,
}) {
  return <String, Object?>{
    'title': title,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    if (areaSqm case final double value) 'areaSqm': value,
    if (buildingTypeRemark case final String value) 'buildingTypeRemark': value,
    'provinceCode': provinceCode,
    'provinceName': provinceName,
    'cityCode': cityCode,
    'cityName': cityName,
    if (districtCode case final String value) 'districtCode': value,
    if (districtName case final String value) 'districtName': value,
    'detailAddress': detailAddress,
    'scopeSummary': scopeSummary,
    if (plannedStartAt case final String value) 'plannedStartAt': value,
    if (plannedEndAt case final String value) 'plannedEndAt': value,
    if (scheduleDetail case final String value) 'scheduleDetail': value,
    if (description case final String value) 'description': value,
  };
}

void main() {
  setUp(() {
    ProjectAttachmentDebugOverrides.reset();
    ProjectPublicResourceDebugOverrides.reset();
    BidSubmitAttachmentDebugOverrides.reset();
    AppApiConfig.resetRuntimeBaseUrlOverride();
  });
  tearDown(() {
    ProjectAttachmentDebugOverrides.reset();
    ProjectPublicResourceDebugOverrides.reset();
    BidSubmitAttachmentDebugOverrides.reset();
    AppApiConfig.resetRuntimeBaseUrlOverride();
  });

  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  defaultHandlers() {
    return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
      'GET /api/app/project/list': (AppApiRequest request) async {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{'items': <Object?>[]},
        );
      },
      'GET /api/app/project/public-resources': (AppApiRequest request) async {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _publicResourceListResponse(const <Map<String, Object?>>[]),
        );
      },
    };
  }

  ExhibitionMobileApp buildApp({
    String initialRoute = '/',
    AppConfigManifest? bootstrapManifest,
    AppShellContextData? bootstrapShellContext,
    AppShellContextConsumer? shellContextConsumer,
    FakeAppApiTransport? transport,
    FakeAppApiTransport? forumTransport,
    FakeAppApiTransport? messagesTransport,
    FakeAppApiTransport? profileTransport,
    TradingImConsumerLayer? tradingImConsumerLayer,
    CounterpartConversationConsumerLayer? counterpartConversationConsumerLayer,
    AuthConsumerLayer? authConsumerLayer,
    ProfileIdentityConsumerLayer? profileIdentityConsumerLayer,
    ExhibitionHomeAggregationClient? exhibitionHomeAggregationClient,
    DeviceLocationService? deviceLocationService,
    AppSessionStore? sessionStore,
  }) {
    final exhibitionTransport =
        transport ?? FakeAppApiTransport(handlers: defaultHandlers());
    final resolvedMessagesTransport =
        messagesTransport ??
        FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        );
    final resolvedForumTransport =
        forumTransport ??
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/interaction/inbox':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'items': <Object?>[],
                          'page': <String, Object?>{
                            'nextCursor': null,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'GET /api/app/forum/me/posts': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  );
                },
                'GET /api/app/forum/me/comments':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'items': <Object?>[],
                          'page': <String, Object?>{
                            'nextCursor': null,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'GET /api/app/forum/me/bookmarks':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'items': <Object?>[],
                          'page': <String, Object?>{
                            'nextCursor': null,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'GET /api/app/forum/me/follows': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  );
                },
                'GET /api/app/forum/draft/list': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  );
                },
              },
        );
    final resolvedProfileTransport =
        profileTransport ??
        FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        );

    return ExhibitionMobileApp(
      initialRoute: initialRoute,
      bootstrapManifest: bootstrapManifest,
      bootstrapShellContext: bootstrapShellContext,
      shellContextConsumer: shellContextConsumer,
      exhibitionConsumerLayer: ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: exhibitionTransport,
        ),
      ),
      exhibitionHomeAggregationClient:
          exhibitionHomeAggregationClient ??
          FakeExhibitionHomeAggregationClient(),
      forumConsumerLayer: ForumConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: resolvedForumTransport,
        ),
      ),
      tradingImConsumerLayer: tradingImConsumerLayer,
      messagesConsumerLayer: MessagesConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: resolvedMessagesTransport,
        ),
      ),
      counterpartConversationConsumerLayer:
          counterpartConversationConsumerLayer ??
          CounterpartConversationConsumerLayer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: resolvedMessagesTransport,
            ),
          ),
      profileConsumerLayer: ProfileConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: resolvedProfileTransport,
        ),
      ),
      authConsumerLayer: authConsumerLayer,
      profileIdentityConsumerLayer: profileIdentityConsumerLayer,
      deviceLocationService:
          deviceLocationService ?? FakeDeviceLocationService(),
      sessionStore: sessionStore,
    );
  }

  AppShellContextConsumer buildShellContextConsumer({
    Duration requestTimeout = const Duration(milliseconds: 300),
    String userId = 'user-1',
    String? organizationId = 'org-1',
    String? organizationType,
    List<String> roleKeys = const <String>[],
    String? certificationStatus,
    String? personalCertificationStatus = 'approved',
    bool? personalCertificationQualified = true,
    bool? personalCertificationLockedToOtherActor = false,
    String? membershipStatus,
    bool? canCreateProject,
    List<String> visibleBuildings = const <String>[
      'exhibition',
      'messages',
      'profile',
    ],
  }) {
    return AppShellContextConsumer(
      client: AppApiClient(
        config: AppApiConfig(
          baseUrl: 'http://127.0.0.1:8080/api/app',
          requestTimeout: requestTimeout,
        ),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/shell/context': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _shellContextPayload(
                      userId: userId,
                      organizationId: organizationId,
                      organizationType: organizationId == null
                          ? null
                          : (organizationType ?? 'supplier'),
                      roleKeys: roleKeys,
                      certificationStatus: certificationStatus,
                      personalCertificationStatus: personalCertificationStatus,
                      personalCertificationQualified:
                          personalCertificationQualified,
                      personalCertificationLockedToOtherActor:
                          personalCertificationLockedToOtherActor,
                      membershipStatus: membershipStatus,
                      canCreateProject: canCreateProject,
                      visibleBuildings: visibleBuildings,
                    ),
                  );
                },
              },
        ),
      ),
    );
  }

  Future<void> expectNoDefaultTechnicalDisclosure(
    WidgetTester tester, {
    required ExhibitionMobileApp app,
    required String pageTitle,
    List<String> visibleTexts = const <String>[],
  }) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.textContaining(pageTitle, findRichText: true), findsWidgets);
    final scrollable = find.byType(Scrollable).first;
    for (final text in visibleTexts) {
      final finder = find.textContaining(text, findRichText: true);
      if (finder.evaluate().isEmpty) {
        await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
        await tester.pumpAndSettle();
      }
      expect(finder, findsWidgets);
    }
    expect(find.textContaining('当前连接信息（次级）'), findsNothing);
    expect(find.textContaining('协议承接信息（次级）'), findsNothing);
    expect(find.textContaining('payload snapshot'), findsNothing);
    expect(find.textContaining('route context'), findsNothing);
    expect(find.textContaining('page state:'), findsNothing);
    expect(find.textContaining('BFF base URL'), findsNothing);
  }

  Future<void> tapBottomDestination(WidgetTester tester, String label) async {
    final navigationBar = find.byType(NavigationBar);
    final labelFinder = find.descendant(
      of: navigationBar,
      matching: find.text(label),
    );
    await tester.tap(labelFinder.last);
    await tester.pump();
    await tester.pumpAndSettle();
  }

  int selectedBottomDestinationIndex(WidgetTester tester) {
    return tester
        .widget<NavigationBar>(find.byType(NavigationBar).last)
        .selectedIndex;
  }

  Future<void> dragFrom(
    WidgetTester tester, {
    required Offset start,
    required Offset offset,
  }) async {
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(offset);
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  NavigatorState rootNavigator(WidgetTester tester) {
    return tester.state<NavigatorState>(find.byType(Navigator).first);
  }

  Future<void> pushNamedRoute(WidgetTester tester, String routeName) async {
    rootNavigator(tester).pushNamed(routeName);
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> popRoute(WidgetTester tester) async {
    rootNavigator(tester).pop();
    await tester.pump();
    await tester.pumpAndSettle();
  }

  AppSessionStore buildAuthenticatedSessionStore({
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    String deviceId = 'test-device-id',
    String? localLoginSource,
  }) {
    final store = AppSessionStore();
    store.establishSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSeconds: 3600,
      deviceId: deviceId,
      localLoginSource: localLoginSource,
    );
    return store;
  }

  testWidgets(
    'shell context timeout falls back to bootstrap defaults and leaves booting',
    (WidgetTester tester) async {
      final hangingCompleter = Completer<AppApiResponse>();
      final shellContextConsumer = AppShellContextConsumer(
        client: AppApiClient(
          config: AppApiConfig(
            baseUrl: 'http://127.0.0.1:8080/api/app',
            requestTimeout: const Duration(milliseconds: 100),
          ),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) {
                    return hangingCompleter.future;
                  },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        buildApp(shellContextConsumer: shellContextConsumer),
      );
      await tester.pump();

      expect(find.text('Shell 启动中').evaluate().length <= 1, isTrue);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Shell 启动中'), findsNothing);

      final navigationBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navigationBar, matching: find.text('展览')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navigationBar, matching: find.text('消息')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navigationBar, matching: find.text('我的')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'unauthenticated users can view exhibition public home while other buildings stay guarded',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('天气与定位'), findsOneWidget);
      expect(find.text('尚未登录'), findsNothing);

      await tapBottomDestination(tester, '消息');
      expect(find.text('尚未登录'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '进入登录入口'), findsOneWidget);

      await tapBottomDestination(tester, '我的');
      expect(find.text('登录后管理项目与企业身份'), findsOneWidget);
      expect(find.text('认证、发布、沟通和会员能力将在登录后开放'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '立即登录'), findsOneWidget);
      expect(find.text('创建组织入口'), findsNothing);
      expect(find.text('加入组织入口'), findsNothing);
      expect(find.text('查看认证状态'), findsNothing);

      await tapBottomDestination(tester, '展览');
      expect(find.text('天气与定位'), findsOneWidget);
    },
  );

  testWidgets(
    'authenticated users without organization can still view exhibition while other buildings stay guarded',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          shellContextConsumer: buildShellContextConsumer(organizationId: null),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-no-org',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('天气与定位'), findsOneWidget);
      expect(find.text('尚未加入组织'), findsNothing);

      await tapBottomDestination(tester, '消息');
      expect(find.text('尚未加入组织'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '查看组织状态'), findsOneWidget);

      await tapBottomDestination(tester, '我的');
      expect(find.text('尚未加入组织'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '查看组织状态'), findsOneWidget);

      await tapBottomDestination(tester, '展览');
      expect(find.text('天气与定位'), findsOneWidget);
      expect(find.text('尚未加入组织'), findsNothing);
    },
  );

  testWidgets(
    'unauthenticated exhibition publish action stays tappable on compact desktop viewport and routes to login entry',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildApp(
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, '去发布项目'));
      await tester.pumpAndSettle();

      expect(find.text('欢迎登录'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '验证码登录'), findsOneWidget);
      expect(find.text('发送验证码'), findsOneWidget);
    },
  );

  testWidgets(
    'login entry stays public-facing and hides test credential shortcut',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ProfileIdentityRoutes.login,
          shellContextConsumer: buildShellContextConsumer(
            userId: 'user-dev',
            organizationId: 'org-dev',
          ),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('测试通道直接进入'), findsNothing);
      expect(find.text('开发态测试通道'), findsNothing);
      expect(find.textContaining('不会调用 OTP send/login'), findsNothing);
      expect(find.text('填入联调测试账号'), findsNothing);
      expect(find.text('验证码登录'), findsWidgets);
      expect(find.text('账号密码登录'), findsOneWidget);
      expect(find.text('发送验证码'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '验证码登录'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('《用户协议》'), findsOneWidget);
      expect(find.text('《隐私政策》'), findsOneWidget);
      expect(find.text('请输入手机号'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('微信'), findsNothing);
      expect(find.text('一键登录'), findsNothing);
      expect(find.text('password login'), findsNothing);
      expect(find.text('登录后管理项目、企业身份与沟通协作'), findsOneWidget);
      expect(AppSessionStore.instance.hasAnySession, isFalse);
      expect(
        AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app').effectiveBaseUrl,
        'http://127.0.0.1:8080/api/app',
      );
    },
  );

  testWidgets('login entry keeps otp and password segmented dual entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ProfileIdentityRoutes.login,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: AppSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('验证码登录'), findsWidgets);
    expect(find.text('账号密码登录'), findsOneWidget);
    expect(find.text('发送验证码'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '验证码登录'), findsOneWidget);
    expect(find.text('密码登录'), findsNothing);
    expect(find.widgetWithText(TextButton, '忘记密码'), findsNothing);

    await tester.tap(find.text('账号密码登录'));
    await tester.pumpAndSettle();

    expect(find.text('密码'), findsOneWidget);
    expect(find.text('请输入登录密码'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '账号密码登录'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '忘记密码'), findsOneWidget);
    expect(find.text('发送验证码'), findsNothing);
    expect(find.widgetWithText(FilledButton, '验证码登录'), findsNothing);
  });

  testWidgets(
    'login entry user agreement handoff page stays locally routable',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ProfileIdentityRoutes.userAgreement,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('用户协议'), findsWidgets);
      expect(find.text('展览装修之家用户协议'), findsOneWidget);
      expect(find.textContaining('当前展示的是仓库内可直接使用的法务正文'), findsOneWidget);
    },
  );

  testWidgets(
    'login entry privacy policy handoff page stays locally routable',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ProfileIdentityRoutes.privacyPolicy,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('隐私政策'), findsWidgets);
      expect(find.text('展览装修之家隐私政策'), findsOneWidget);
      expect(find.textContaining('当前展示的是仓库内可直接使用的法务正文'), findsOneWidget);
    },
  );

  testWidgets(
    'login entry requires legal consent before otp or password auth unlock',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ProfileIdentityRoutes.login,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      final TextButton sendButtonBefore = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '发送验证码'),
      );
      final FilledButton otpLoginBefore = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '验证码登录'),
      );
      expect(sendButtonBefore.onPressed, isNull);
      expect(otpLoginBefore.onPressed, isNull);

      await tester.tap(find.text('账号密码登录'));
      await tester.pumpAndSettle();

      final FilledButton passwordLoginBefore = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '账号密码登录'),
      );
      expect(passwordLoginBefore.onPressed, isNull);

      final checkboxFinder = find.byType(Checkbox);
      final Checkbox checkboxBefore = tester.widget<Checkbox>(checkboxFinder);
      checkboxBefore.onChanged?.call(true);
      await tester.pumpAndSettle();

      final Checkbox checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isTrue);
      final FilledButton passwordLoginAfter = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '账号密码登录'),
      );
      expect(passwordLoginAfter.onPressed, isNotNull);

      await tester.tap(find.text('验证码登录'));
      await tester.pumpAndSettle();

      final TextButton sendButtonAfter = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '发送验证码'),
      );
      final FilledButton otpLoginAfter = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '验证码登录'),
      );
      expect(sendButtonAfter.onPressed, isNotNull);
      expect(otpLoginAfter.onPressed, isNotNull);
    },
  );

  testWidgets(
    'forgot password reset uses password_reset scene and does not auto login',
    (WidgetTester tester) async {
      final authTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/otp/send': (AppApiRequest request) async {
                final body = request.body! as Map<Object?, Object?>;
                expect(body['mobile'], '13800000000');
                expect(body['scene'], 'password_reset');
                expect(body['deviceId'], isA<String>());
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'cooldownSeconds': 60,
                    'traceId': 'trace-reset-send',
                  },
                );
              },
              'POST /api/app/auth/password/reset':
                  (AppApiRequest request) async {
                    expect(request.body, <String, Object?>{
                      'mobile': '13800000000',
                      'otpCode': '654321',
                      'newPassword': 'Password456!',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ok': true,
                        'traceId': 'trace-reset-finish',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ProfileIdentityRoutes.login,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
          authConsumerLayer: AuthConsumerLayer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: authTransport,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('账号密码登录'));
      await tester.pumpAndSettle();
      await _scrollAndTap(tester, find.widgetWithText(TextButton, '忘记密码'));

      await tester.enterText(find.byType(TextField).at(0), '13800000000');
      await tester.enterText(find.byType(TextField).at(1), '654321');
      await tester.enterText(find.byType(TextField).at(2), 'Password456!');

      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '发送验证码'));
      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '重置密码'));

      expect(find.text('密码已重置'), findsOneWidget);
      expect(find.textContaining('页面不会自动登录'), findsOneWidget);
      expect(AppSessionStore.instance.hasAnySession, isFalse);
    },
  );

  testWidgets('set password entry only appears for otp login session', (
    WidgetTester tester,
  ) async {
    final sessionStore = buildAuthenticatedSessionStore(
      accessToken: 'access-otp',
      refreshToken: 'refresh-otp',
      deviceId: 'device-otp',
      localLoginSource: AppSessionLoginSource.otpLogin,
    );
    final profileIdentityConsumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/security/devices':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{'items': <Object?>[]},
                      );
                    },
              },
        ),
      ),
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ProfileIdentityRoutes.sessionCenter,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: sessionStore,
        profileIdentityConsumerLayer: profileIdentityConsumer,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, '设置登录密码'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, '设置登录密码'), findsOneWidget);
  });

  testWidgets('password login session does not expose set password entry', (
    WidgetTester tester,
  ) async {
    final sessionStore = buildAuthenticatedSessionStore(
      accessToken: 'access-password',
      refreshToken: 'refresh-password',
      deviceId: 'device-password',
      localLoginSource: AppSessionLoginSource.passwordLogin,
    );
    final profileIdentityConsumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/security/devices':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{'items': <Object?>[]},
                      );
                    },
              },
        ),
      ),
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ProfileIdentityRoutes.sessionCenter,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: sessionStore,
        profileIdentityConsumerLayer: profileIdentityConsumer,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '设置登录密码'), findsNothing);
  });

  testWidgets('set password entry disappears after session clear', (
    WidgetTester tester,
  ) async {
    final sessionStore = buildAuthenticatedSessionStore(
      accessToken: 'access-clear',
      refreshToken: 'refresh-clear',
      deviceId: 'device-clear',
      localLoginSource: AppSessionLoginSource.otpLogin,
    );
    final profileIdentityConsumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/security/devices':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{'items': <Object?>[]},
                      );
                    },
              },
        ),
      ),
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ProfileIdentityRoutes.sessionCenter,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: sessionStore,
        profileIdentityConsumerLayer: profileIdentityConsumer,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, '设置登录密码'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, '设置登录密码'), findsOneWidget);

    sessionStore.clearSession();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '设置登录密码'), findsNothing);
  });

  testWidgets(
    'set password surface stays post-otp and does not act as registration',
    (WidgetTester tester) async {
      final sessionStore = buildAuthenticatedSessionStore(
        accessToken: 'access-post-otp',
        refreshToken: 'refresh-post-otp',
        deviceId: 'device-post-otp',
        localLoginSource: AppSessionLoginSource.otpLogin,
      );
      final authTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/password/set': (AppApiRequest request) async {
                expect(
                  request.headers['authorization'],
                  'Bearer access-post-otp',
                );
                expect(request.body, <String, Object?>{
                  'newPassword': 'Password789!',
                });
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'ok': true,
                    'traceId': 'trace-password-set',
                  },
                );
              },
            },
      );

      final profileIdentityConsumer = ProfileIdentityConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/security/devices':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{'items': <Object?>[]},
                        );
                      },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ProfileIdentityRoutes.sessionCenter,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: sessionStore,
          authConsumerLayer: AuthConsumerLayer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: authTransport,
            ),
          ),
          profileIdentityConsumerLayer: profileIdentityConsumer,
        ),
      );
      await tester.pumpAndSettle();

      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '设置登录密码'));

      expect(find.text('设置登录密码'), findsWidgets);
      expect(find.textContaining('不作为注册入口'), findsWidgets);

      await tester.enterText(find.byType(TextField).first, 'Password789!');
      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '设置密码'));

      expect(find.text('密码已设置'), findsOneWidget);
      expect(find.textContaining('不作为注册入口'), findsWidgets);
    },
  );

  test('bootstrap shell context defaults follow manifest visibility flags', () {
    final manifest = AppConfigManifest.bootstrapDefaults()
        .copyWithFlag(ConfigFlagKeys.buildingMessagesVisible, false)
        .copyWithFlag(ConfigFlagKeys.buildingProfileVisible, false);

    final shellContext = AppShellContextData.bootstrapDefaults(
      manifest: manifest,
    );

    expect(shellContext.visibleBuildings, const <String>['exhibition']);
  });

  testWidgets('first release bottom navigation only shows three buildings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);

    expect(
      find.descendant(of: navigationBar, matching: find.text('展览')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('消息')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('我的')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('装修')),
      findsNothing,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('全屋定制')),
      findsNothing,
    );
  });

  testWidgets(
    'root shell horizontal swipes switch bottom buildings without cycling',
    (WidgetTester tester) async {
      final profileTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'organization': <String, Object?>{
                      'organizationId': 'org-1',
                      'roleKeys': <Object?>[],
                      'visibleBuildings': <Object?>[
                        'exhibition',
                        'messages',
                        'profile',
                      ],
                    },
                    'certification': <String, Object?>{'status': 'verified'},
                    'membership': <String, Object?>{'status': 'active'},
                    'settingsEntry': <String, Object?>{'state': 'visible'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(profileTransport: profileTransport));
      await tester.pumpAndSettle();

      expect(selectedBottomDestinationIndex(tester), 0);

      await dragFrom(
        tester,
        start: const Offset(420, 300),
        offset: const Offset(-260, 0),
      );
      expect(selectedBottomDestinationIndex(tester), 1);

      await dragFrom(
        tester,
        start: const Offset(420, 300),
        offset: const Offset(-260, 0),
      );
      expect(selectedBottomDestinationIndex(tester), 2);

      await dragFrom(
        tester,
        start: const Offset(420, 300),
        offset: const Offset(-260, 0),
      );
      expect(selectedBottomDestinationIndex(tester), 2);

      await dragFrom(
        tester,
        start: const Offset(420, 300),
        offset: const Offset(260, 0),
      );
      expect(selectedBottomDestinationIndex(tester), 1);

      await dragFrom(
        tester,
        start: const Offset(420, 300),
        offset: const Offset(260, 0),
      );
      expect(selectedBottomDestinationIndex(tester), 0);

      await dragFrom(
        tester,
        start: const Offset(420, 300),
        offset: const Offset(260, 0),
      );
      expect(selectedBottomDestinationIndex(tester), 0);
    },
  );

  testWidgets('shell back button keeps hover tooltip hidden', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'contractId': 'contract-1',
                  'orderId': 'order-1',
                  'state': 'pending_confirm',
                  'summary': _summary('contract'),
                },
              );
            },
          },
    );

    await tester.pumpWidget(buildApp(transport: transport));
    await tester.pumpAndSettle();
    await pushNamedRoute(
      tester,
      ExhibitionRoutes.contractDetailWithOrderId('order-1'),
    );

    final backButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.arrow_back_ios_new_rounded).first,
    );
    expect(backButton.tooltip, isNull);

    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.arrow_back_ios_new_rounded).first,
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('合同详情'), findsNothing);
    expect(find.text('发现优质项目，把握商机'), findsOneWidget);
  });

  testWidgets('left edge drag pops stacked shell routes', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'contractId': 'contract-1',
                  'orderId': 'order-1',
                  'state': 'pending_confirm',
                  'summary': _summary('contract'),
                },
              );
            },
          },
    );

    await tester.pumpWidget(buildApp(transport: transport));
    await tester.pumpAndSettle();
    await pushNamedRoute(
      tester,
      ExhibitionRoutes.contractDetailWithOrderId('order-1'),
    );

    expect(find.text('合同详情'), findsOneWidget);

    await dragFrom(
      tester,
      start: const Offset(4, 260),
      offset: const Offset(96, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('合同详情'), findsNothing);
    expect(find.text('发现优质项目，把握商机'), findsOneWidget);
  });

  testWidgets('exhibition root presents a clean weather shell home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('发现优质项目，把握商机'), findsOneWidget);
    expect(find.text('秩序化首页'), findsNothing);
    expect(find.text('展览首页'), findsNothing);
    expect(find.text('当前定位：重庆'), findsNothing);
    expect(find.text('当前环境：联调环境'), findsNothing);
    expect(find.text('定位状态待确认'), findsWidgets);
    expect(find.text('公开入口'), findsOneWidget);
    expect(find.text('推荐频道'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '去发布项目'), findsOneWidget);
    expect(find.byTooltip('回到顶部'), findsOneWidget);
    expect(find.byTooltip('展开天气卡'), findsOneWidget);
    expect(find.text('手动选择地区'), findsOneWidget);
    expect(find.text('项目'), findsOneWidget);
    expect(find.text('论坛'), findsOneWidget);
    expect(find.text('公司'), findsOneWidget);
    expect(find.text('工厂'), findsOneWidget);
    expect(find.text('供应商'), findsOneWidget);
    expect(find.text('团队'), findsOneWidget);
    expect(find.text('进入项目列表'), findsWidgets);
    expect(find.text('进入发布项目工作台'), findsNothing);
    expect(find.text('发布项目'), findsNothing);
    expect(find.text('当前进度'), findsNothing);
    expect(find.text('继续当前工作'), findsNothing);
    expect(find.text('创建项目'), findsNothing);
    expect(find.textContaining('BFF base URL'), findsNothing);
    expect(find.textContaining('开发工作面'), findsNothing);
  });

  testWidgets(
    'shell no longer exposes environment banner on non-home buildings',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.messages.routePath,
          messagesTransport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/message/interactions':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'lane': 'project_communication',
                            'items': <Object?>[],
                          },
                        );
                      },
                },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前环境：联调环境'), findsNothing);
      expect(find.textContaining('127.0.0.1'), findsNothing);
      expect(find.textContaining('/api/app'), findsNothing);
    },
  );

  testWidgets(
    'shell keeps my bids and message interactions refreshed across building switches',
    (WidgetTester tester) async {
      var messageInteractionRequestCount = 0;
      final exhibitionTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/my/projects': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'ongoingProjects': <Object?>[
                      _myProjectListItem(
                        projectId: 'project-1',
                        title: '我的发布项目',
                      ),
                    ],
                    'historicalProjects': const <Object?>[],
                  },
                );
              },
              'GET /api/app/my/bids': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _myBidItem(
                        bidId: 'bid-1',
                        projectId: 'project-1',
                        projectNo: 'BID-PROJ-1',
                        projectTitle: '供应商竞标记录',
                        quoteAmount: 8800,
                        proposalSummaryPreview: '报价方案已提交，等待后续沟通。',
                        submittedAt: '2026-04-20T10:00:00Z',
                        outcomeState: 'published',
                        canOpenBidThread: true,
                        canOpenBidResult: false,
                      ),
                    ],
                  },
                );
              },
            },
      );
      final messagesTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async {
                    messageInteractionRequestCount += 1;
                    final title = messageInteractionRequestCount == 1
                        ? '第一次项目沟通会话'
                        : '第二次项目沟通会话';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'lane': 'project_communication',
                        'items': <Object?>[
                          _messageInteractionItem(
                            interactionId:
                                'interaction-$messageInteractionRequestCount',
                            projectId: 'project-1',
                            bidId: 'bid-1',
                            counterpartName: title,
                            summary: '$title 已生成。',
                            lastMessageText: '$title 最近有更新。',
                          ),
                        ],
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.myProjectList,
          transport: exhibitionTransport,
          messagesTransport: messagesTransport,
        ),
      );
      await tester.pumpAndSettle();

      await _scrollAndTap(tester, find.widgetWithText(ChoiceChip, '我的竞标'));
      expect(find.text('供应商竞标记录'), findsOneWidget);
      expect(find.text('沟通与投标'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('消息'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目沟通'), findsOneWidget);
      expect(find.text('第一次项目沟通会话'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('展览'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('消息'),
        ),
      );
      await tester.pumpAndSettle();

      expect(messageInteractionRequestCount, greaterThanOrEqualTo(2));
      expect(find.text('第二次项目沟通会话'), findsOneWidget);
    },
  );

  testWidgets(
    'messages building auto-refreshes project communication while staying on messages',
    (WidgetTester tester) async {
      var messageInteractionRequestCount = 0;
      final messagesTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async {
                    messageInteractionRequestCount += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'lane': 'project_communication',
                        'items': <Object?>[
                          _messageInteractionItem(
                            interactionId:
                                'interaction-$messageInteractionRequestCount',
                            projectId: 'project-1',
                            bidId: 'bid-1',
                            counterpartName:
                                '项目沟通会话 $messageInteractionRequestCount',
                            summary: '会话已刷新。',
                            lastMessageText:
                                '最近更新时间 $messageInteractionRequestCount',
                          ),
                        ],
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.messages.routePath,
          messagesTransport: messagesTransport,
        ),
      );
      await tester.pumpAndSettle();

      expect(messageInteractionRequestCount, 1);
      expect(find.text('项目沟通会话 1'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(messageInteractionRequestCount, greaterThanOrEqualTo(2));
      expect(find.text('项目沟通会话 2'), findsOneWidget);
    },
  );

  testWidgets(
    'messages interactions jump stably to project communication page',
    (WidgetTester tester) async {
      final messagesTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'lane': 'project_communication',
                        'items': <Object?>[
                          _messageInteractionItem(
                            interactionId: 'interaction-1',
                            projectId: 'project-1',
                            bidId: 'bid-1',
                            counterpartName: '杭州搭建公司',
                            summary: '杭州搭建公司已对当前项目提交竞标。',
                            lastMessageText: '项目方在沟通与投标里回复了新的交付问题。',
                          ),
                        ],
                      },
                    );
                  },
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['conversationId'],
                      'org-interaction-1',
                    );
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _counterpartConversationBidDetailPayload(
                        interactionId: 'interaction-1',
                        projectId: 'project-1',
                        bidId: 'bid-1',
                        counterpartName: '杭州搭建公司',
                      ),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    expect(
                      request.uri.queryParameters['counterpartOrganizationId'],
                      'org-interaction-1',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'threadId': 'project-thread-1',
                        'projectId': 'project-1',
                        'ownerOrganizationId': 'org-owner',
                        'counterpartOrganizationId': 'org-interaction-1',
                        'threadState': 'open',
                        'lastMessageId': null,
                        'lastMessageAt': null,
                        'createdAt': '2026-04-20T10:00:00Z',
                        'updatedAt': '2026-04-20T10:00:00Z',
                      },
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['threadId'],
                      'project-thread-1',
                    );
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
            },
      );
      final tradingImConsumerLayer = TradingImConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/clarification/list':
                      (AppApiRequest request) async =>
                          throw UnimplementedError(),
                  'GET /api/app/bid/thread/detail':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: _bidThreadDetailPayload(
                            threadId: 'thread-1',
                            projectId: 'project-1',
                            bidId: 'bid-1',
                          ),
                        );
                      },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.messages.routePath,
          messagesTransport: messagesTransport,
          tradingImConsumerLayer: tradingImConsumerLayer,
          counterpartConversationConsumerLayer:
              _counterpartConsumerWithNoopRealtime(messagesTransport),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目沟通'), findsOneWidget);

      await _scrollAndTap(
        tester,
        find.widgetWithText(FilledButton, '进入项目沟通').first,
      );
      expect(find.text('展览项目 1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(selectedBottomDestinationIndex(tester), 1);

      await _scrollAndTap(
        tester,
        find.widgetWithText(FilledButton, '进入沟通').first,
      );
      expect(find.text('返回项目列表'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.arrow_back_ios_new_rounded).first,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('返回项目列表'), findsNothing);
      expect(find.text('展览项目 1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('messages building can be hidden by manifest and stays guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: AppBuilding.messages.routePath,
        bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
          ConfigFlagKeys.buildingMessagesVisible,
          false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    expect(
      find.descendant(of: navigationBar, matching: find.text('展览')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('我的')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('消息')),
      findsNothing,
    );
    expect(find.text('消息入口当前不可见'), findsOneWidget);
    expect(find.textContaining('首发阶段暂未开放到当前主路径'), findsWidgets);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets('profile building can be hidden by manifest and stays guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: AppBuilding.profile.routePath,
        bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
          ConfigFlagKeys.buildingProfileVisible,
          false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    expect(
      find.descendant(of: navigationBar, matching: find.text('展览')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('消息')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('我的')),
      findsNothing,
    );
    expect(find.text('我的入口当前不可见'), findsOneWidget);
    expect(find.textContaining('首发阶段暂未开放到当前主路径'), findsWidgets);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets(
    'messages building shows controlled unreadSummary badge from shell context',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          bootstrapShellContext: AppShellContextData(
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
            unreadSummary: <String, Object?>{'messages': 4, 'profileNotice': 3},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navigationBar, matching: find.text('7')),
        findsNothing,
      );
      expect(
        find.descendant(of: navigationBar, matching: find.text('4')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navigationBar, matching: find.text('消息')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'messages page reloads shell unread badge after project communication refresh',
    (WidgetTester tester) async {
      var shellContextLoads = 0;
      final shellContextConsumer = AppShellContextConsumer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) async {
                    shellContextLoads += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _shellContextPayload(
                        unreadSummary: <String, Object?>{
                          'messages': shellContextLoads <= 1 ? 0 : 2,
                        },
                      ),
                    );
                  },
                },
          ),
        ),
      );
      final definition =
          messagesRegisteredEntryByActionKey['counterpart_conversation.open']!;
      final messagesTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'lane': 'project_communication',
                        'items': <Object?>[
                          <String, Object?>{
                            'interactionId': 'interaction-1',
                            'interactionType': 'counterpart_conversation',
                            'conversationId': 'conversation-1',
                            'projectId': 'project-1',
                            'counterpart': const <String, Object?>{
                              'organizationId': 'org-counterpart',
                              'displayName': '重庆海川展览工厂',
                              'companyName': '重庆坤特展览展示有限公司',
                              'role': 'counterpart',
                            },
                            'summary': const <String, Object?>{
                              'focusProjectId': 'project-1',
                              'title': '项目沟通',
                              'text': '有 2 条项目沟通未读消息。',
                              'projectCount': 1,
                              'latestCardType': 'system_notice',
                            },
                            'conversationUnreadCount': 2,
                            'hasUnread': true,
                            'latestUnreadMessageAt': '2026-05-02T10:18:00Z',
                            'updatedAt': '2026-05-02T10:18:00Z',
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
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        buildApp(
          shellContextConsumer: shellContextConsumer,
          messagesTransport: messagesTransport,
          sessionStore: buildAuthenticatedSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navigationBar, matching: find.text('2')),
        findsNothing,
      );

      await tapBottomDestination(tester, '消息');

      expect(shellContextLoads, greaterThanOrEqualTo(2));
      expect(
        find.descendant(of: navigationBar, matching: find.text('2')),
        findsOneWidget,
      );
      expect(find.text('重庆坤特展览展示有限公司'), findsOneWidget);
    },
  );

  testWidgets(
    'messages page clears stale shell unread badge after project communication refresh',
    (WidgetTester tester) async {
      var shellContextLoads = 0;
      final shellContextConsumer = AppShellContextConsumer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) async {
                    shellContextLoads += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _shellContextPayload(
                        unreadSummary: const <String, Object?>{'messages': 2},
                      ),
                    );
                  },
                },
          ),
        ),
      );
      final messagesTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'lane': 'project_communication',
                      'items': <Object?>[],
                    },
                  ),
            },
      );

      await tester.pumpWidget(
        buildApp(
          shellContextConsumer: shellContextConsumer,
          messagesTransport: messagesTransport,
          sessionStore: buildAuthenticatedSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navigationBar, matching: find.text('2')),
        findsOneWidget,
      );

      await tapBottomDestination(tester, '消息');

      expect(shellContextLoads, greaterThanOrEqualTo(2));
      expect(
        find.descendant(of: navigationBar, matching: find.text('2')),
        findsNothing,
      );
      expect(find.text('当前没有新的项目沟通'), findsOneWidget);
    },
  );

  testWidgets(
    'messages tab keeps forum inbox opt-in on first entry and refreshes the selected inbox after returning',
    (WidgetTester tester) async {
      final forumTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/interaction/inbox':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'page': <String, Object?>{
                          'nextCursor': null,
                          'hasMore': false,
                        },
                      },
                    );
                  },
              'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/bookmarks':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
            },
      );
      final profileTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'organization': <String, Object?>{
                      'organizationId': 'org-1',
                      'roleKeys': <Object?>[],
                      'visibleBuildings': <Object?>[
                        'exhibition',
                        'messages',
                        'profile',
                      ],
                    },
                    'certification': <String, Object?>{'status': 'verified'},
                    'membership': <String, Object?>{'status': 'active'},
                    'settingsEntry': <String, Object?>{'state': 'visible'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          forumTransport: forumTransport,
          profileTransport: profileTransport,
        ),
      );
      await tester.pumpAndSettle();

      expect(forumTransport.requests, isEmpty);
      expect(profileTransport.requests, isEmpty);

      await tapBottomDestination(tester, '消息');
      expect(
        forumTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ForumCanonicalPaths.interactionInbox,
            )
            .length,
        0,
      );
      await tester.tap(find.text('回复我的').last);
      await tester.pumpAndSettle();
      expect(
        forumTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ForumCanonicalPaths.interactionInbox,
            )
            .length,
        1,
      );

      await tapBottomDestination(tester, '我的');
      expect(
        profileTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ProfileCanonicalPaths.profileIndex,
            )
            .length,
        1,
      );

      await tapBottomDestination(tester, '消息');
      await tester.pumpAndSettle();
      expect(find.text('选择一个分类查看'), findsOneWidget);
      expect(
        forumTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ForumCanonicalPaths.interactionInbox,
            )
            .length,
        1,
      );
      await tester.tap(find.text('回复我的').last);
      await tester.pumpAndSettle();
      expect(
        forumTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ForumCanonicalPaths.interactionInbox,
            )
            .length,
        2,
      );
    },
  );

  testWidgets(
    'forum post detail back button returns to interaction center when opened from message reminder',
    (WidgetTester tester) async {
      final forumTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/interaction/inbox':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'notificationId': 'notice-reply-1',
                            'tab': 'replies',
                            'actor': <String, Object?>{
                              'authorId': 'member-1',
                              'displayName': '王监理',
                              'organizationName': '现场协作组',
                            },
                            'targetType': 'forum_post',
                            'targetId': 'post-1',
                            'title': '回复了你在《材料交接节点》里的问题',
                            'preview': '建议先锁定吊装批次。',
                            'createdAt': '2026-03-27T10:00:00Z',
                            'unread': true,
                            'canQuickReply': true,
                          },
                        ],
                        'page': const <String, Object?>{
                          'nextCursor': null,
                          'hasMore': false,
                        },
                      },
                    );
                  },
              'GET /api/app/forum/post/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'postId': 'post-1',
                    'topicId': 'expo-materials',
                    'topicTitle': '布展进场',
                    'state': 'published',
                    'author': <String, Object?>{
                      'authorId': 'member-1',
                      'displayName': '赵工',
                    },
                    'content': '正式帖子正文',
                    'attachmentRefs': <Object?>[],
                    'engagement': <String, Object?>{
                      'replyCount': 1,
                      'likeCount': 2,
                      'viewCount': 3,
                    },
                    'publishedAt': '2026-03-27T09:30:00Z',
                    'viewerHasLiked': false,
                    'viewerHasBookmarked': false,
                    'viewerFollowsTopic': true,
                  },
                );
              },
              'GET /api/app/forum/post/comments':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'page': <String, Object?>{
                          'nextCursor': null,
                          'hasMore': false,
                        },
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(buildApp(forumTransport: forumTransport));
      await tester.pumpAndSettle();

      await tapBottomDestination(tester, '消息');
      await tester.tap(find.text('回复我的').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('回复了你在《材料交接节点》里的问题'));
      await tester.pumpAndSettle();

      expect(find.text('帖子详情'), findsOneWidget);
      expect(find.text('正式帖子正文'), findsOneWidget);

      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.arrow_back_ios_new_rounded).first,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('帖子详情'), findsNothing);
      expect(find.text('互动中心'), findsOneWidget);
      expect(find.text('回复了你在《材料交接节点》里的问题'), findsOneWidget);
    },
  );

  testWidgets(
    'profile tab keeps its first loaded page alive across tab switches',
    (WidgetTester tester) async {
      final forumTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/interaction/inbox':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'page': <String, Object?>{
                          'nextCursor': null,
                          'hasMore': false,
                        },
                      },
                    );
                  },
              'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/bookmarks':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
            },
      );
      final profileTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'organization': <String, Object?>{
                      'organizationId': 'org-1',
                      'roleKeys': <Object?>['buyer_admin'],
                      'visibleBuildings': <Object?>[
                        'exhibition',
                        'messages',
                        'profile',
                      ],
                    },
                    'certification': <String, Object?>{'status': 'verified'},
                    'membership': <String, Object?>{'status': 'active'},
                    'settingsEntry': <String, Object?>{'state': 'visible'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          forumTransport: forumTransport,
          profileTransport: profileTransport,
        ),
      );
      await tester.pumpAndSettle();

      await tapBottomDestination(tester, '我的');
      expect(
        profileTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ProfileCanonicalPaths.profileIndex,
            )
            .length,
        1,
      );

      await tapBottomDestination(tester, '展览');
      expect(find.text('天气与定位'), findsOneWidget);

      await tapBottomDestination(tester, '我的');
      expect(
        profileTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ProfileCanonicalPaths.profileIndex,
            )
            .length,
        1,
      );
    },
  );

  testWidgets('hidden building route stays registered and guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(initialRoute: '/renovation'));
    await tester.pumpAndSettle();

    expect(find.text('装修入口当前不可见'), findsOneWidget);
    expect(find.text('回到展览'), findsWidgets);

    await tester.tap(find.text('回到展览').first);
    await tester.pumpAndSettle();

    expect(find.text('天气与定位'), findsOneWidget);
  });

  testWidgets(
    'hidden building can render its skeleton when manifest enables it',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.renovation.routePath,
          bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
            ConfigFlagKeys.buildingRenovationVisible,
            true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('装修楼预埋骨架'), findsOneWidget);
      expect(find.text('预埋楼层'), findsOneWidget);
    },
  );

  testWidgets('custom furniture route stays registered and guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(initialRoute: AppBuilding.customFurniture.routePath),
    );
    await tester.pumpAndSettle();

    expect(find.text('全屋定制入口当前不可见'), findsOneWidget);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets(
    'custom furniture can render its skeleton when manifest enables it',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.customFurniture.routePath,
          bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
            ConfigFlagKeys.buildingCustomFurnitureVisible,
            true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('全屋定制楼预埋骨架'), findsOneWidget);
      expect(find.text('预埋楼层'), findsOneWidget);
    },
  );

  testWidgets('unknown route enters explicit not_found state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(initialRoute: '/unknown-route'));
    await tester.pumpAndSettle();

    expect(find.text('路由不可用'), findsWidgets);
    expect(find.textContaining('page state'), findsNothing);
    expect(find.textContaining('requested route'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
    expect(find.textContaining('/unknown-route'), findsNothing);
    expect(find.text('展览入口骨架'), findsNothing);

    await tester.tap(find.text('回到展览').first);
    await tester.pumpAndSettle();

    expect(find.text('天气与定位'), findsOneWidget);
  });

  testWidgets(
    'project list repeated entry reuses session read result without a second GET',
    (WidgetTester tester) async {
      var projectListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/list': (AppApiRequest request) async {
                projectListRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[_projectPayload(projectId: 'project-1')],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(tester, ExhibitionRoutes.projectList);
      expect(projectListRequestCount, 1);
      expect(find.text('项目列表'), findsWidgets);

      await popRoute(tester);
      await pushNamedRoute(tester, ExhibitionRoutes.projectList);

      expect(projectListRequestCount, 1);
      expect(find.text('项目列表'), findsWidgets);
    },
  );

  testWidgets(
    'project detail repeated entry reuses session read result for the same projectId',
    (WidgetTester tester) async {
      var projectDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                projectDetailRequestCount += 1;
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(projectId: 'project-1'),
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.projectDetailWithProjectId('project-1'),
      );
      expect(projectDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.projectDetailWithProjectId('project-1'),
      );

      expect(projectDetailRequestCount, 1);
      expect(find.text('项目详情'), findsWidgets);
    },
  );

  testWidgets(
    'project detail cache is separated by session state for optional-auth owner handoff',
    (WidgetTester tester) async {
      var projectDetailRequestCount = 0;
      final sessionStore = AppSessionStore();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                projectDetailRequestCount += 1;
                final authorization = request.headers['authorization'];
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    viewerProjectRelation: authorization == null
                        ? 'non_owner'
                        : 'owner',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(transport: transport, sessionStore: sessionStore),
      );
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.projectDetailWithProjectId('project-1'),
      );
      await tester.pumpAndSettle();

      expect(projectDetailRequestCount, 1);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, '立即参与竞标'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '进入我的项目'), findsNothing);

      sessionStore.establishSession(
        accessToken: 'access-token-1',
        refreshToken: 'refresh-token-1',
        expiresInSeconds: 3600,
        deviceId: 'device-1',
      );
      await tester.pumpAndSettle();

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.projectDetailWithProjectId('project-1'),
      );
      await tester.pumpAndSettle();

      expect(projectDetailRequestCount, 2);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, '进入我的项目'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsNothing);
      expect(find.widgetWithText(FilledButton, '进入我的项目'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '打开发布项目工作台'), findsNothing);
    },
  );

  testWidgets('project detail current viewer bid closes repeat bid entry', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'project-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'project-1',
                  currentViewerBid: <String, Object?>{
                    'bidId': 'bid-current',
                    'state': 'submitted',
                  },
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectDetailWithProjectId('project-1'),
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-project-current-bid',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expectVisibleText(tester, '已提交竞标');
    expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsNothing);
    expect(find.widgetWithText(FilledButton, '沟通与投标'), findsOneWidget);
  });

  testWidgets(
    'project detail reload button bypasses cached result and sends a fresh GET',
    (WidgetTester tester) async {
      var projectDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                projectDetailRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    projectNo: 'PROJ-$projectDetailRequestCount',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(projectDetailRequestCount, 1);
      await tester.scrollUntilVisible(
        find.text('项目编号：PROJ-1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('项目编号：PROJ-1'), findsOneWidget);

      expect(find.widgetWithText(FilledButton, '重试'), findsNothing);
      expect(find.text('项目详情'), findsWidgets);
      expect(projectDetailRequestCount, 1);
    },
  );

  testWidgets(
    'order detail repeated entry reuses session read result for the same orderId',
    (WidgetTester tester) async {
      var orderDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                orderDetailRequestCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderPayload(
                    orderId: 'order-1',
                    projectId: 'project-1',
                    bidId: 'bid-1',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.orderDetailWithOrderId('order-1'),
      );
      expect(orderDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.orderDetailWithOrderId('order-1'),
      );

      expect(orderDetailRequestCount, 1);
      expect(find.text('订单详情'), findsWidgets);
    },
  );

  testWidgets(
    'milestone list repeated entry reuses session read result for the same orderId',
    (WidgetTester tester) async {
      var milestoneListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/milestone/list': (AppApiRequest request) async {
                milestoneListRequestCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.milestoneListWithOrderId('order-1'),
      );
      expect(milestoneListRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.milestoneListWithOrderId('order-1'),
      );

      expect(milestoneListRequestCount, 1);
      expect(find.text('里程碑列表'), findsWidgets);
    },
  );

  testWidgets(
    'contract detail repeated entry reuses session read result for the same orderId',
    (WidgetTester tester) async {
      var contractDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                contractDetailRequestCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': <String, Object?>{'heading': 'contract'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.contractDetailWithOrderId('order-1'),
      );
      expect(contractDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.contractDetailWithOrderId('order-1'),
      );

      expect(contractDetailRequestCount, 1);
      expect(find.text('合同详情'), findsWidgets);
    },
  );

  testWidgets(
    'contract detail compact content omits route-only reload controls and technical ids',
    (WidgetTester tester) async {
      var contractDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                contractDetailRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': <String, Object?>{'heading': 'contract'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.contractDetailWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(contractDetailRequestCount, 1);
      expect(find.text('合同概览'), findsOneWidget);
      expect(find.text('合同状态：待确认'), findsOneWidget);
      expect(find.text('页面操作'), findsNothing);
      expect(find.text('重新读取当前合同'), findsNothing);
      expect(find.textContaining('contract-1'), findsNothing);
    },
  );

  testWidgets(
    'inspection detail repeated entry reuses session read result for the same milestoneId',
    (WidgetTester tester) async {
      var inspectionDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                inspectionDetailRequestCount += 1;
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'inspectionId': 'inspection-1',
                    'milestoneId': 'milestone-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'inspection'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.inspectionDetailWithMilestoneId('milestone-1'),
      );
      expect(inspectionDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.inspectionDetailWithMilestoneId('milestone-1'),
      );

      expect(inspectionDetailRequestCount, 1);
      expect(find.text('验收详情'), findsWidgets);
    },
  );

  testWidgets(
    'counterparty rating entry route reaches the new app-facing read request',
    (WidgetTester tester) async {
      var ratingEntryRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project-counterparty-rating/entry':
                  (AppApiRequest request) async {
                    ratingEntryRequestCount += 1;
                    expect(request.uri.queryParameters['orderId'], 'order-1');
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    expect(
                      request.uri.queryParameters['rateeOrganizationId'],
                      'org-counterpart',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'orderId': 'order-1',
                        'projectId': 'project-1',
                        'raterOrganizationId': 'org-owner',
                        'rateeOrganizationId': 'org-counterpart',
                        'canRate': true,
                        'reason': null,
                        'ratingState': 'eligible',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        '/exhibition/ratings/entry?orderId=order-1&projectId=project-1&rateeOrganizationId=org-counterpart',
      );
      await tester.pumpAndSettle();

      expect(ratingEntryRequestCount, 1);
      expect(find.text('双方互评入口'), findsWidgets);
      expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('rating_submit_button')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const ValueKey<String>('rating_submit_button')),
        findsOneWidget,
      );
      expect(find.text('路由不可用'), findsNothing);
    },
  );

  testWidgets('canonical path is assembled for project list request', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/list': (AppApiRequest request) async {
              expect(
                request.uri.toString(),
                'http://127.0.0.1:8080/api/app/project/list',
              );
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'items': <Object?>[
                    _projectPayload(
                      projectId: 'proj-1',
                      projectNo: 'PROJ-1',
                      title: '展览项目 1',
                    ),
                  ],
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectList,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('项目列表'), findsWidgets);
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == ExhibitionCanonicalPaths.projectList,
          )
          .length,
      1,
    );
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == ExhibitionCanonicalPaths.projectList,
          )
          .single
          .canonicalPath,
      ExhibitionCanonicalPaths.projectList,
    );
    await tester.scrollUntilVisible(
      find.text('展览项目 1'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('展览项目 1'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '查看详情'), findsNothing);
  });

  testWidgets(
    'project list card consumes area and standardized province city without leaking detail-only fields',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _projectPayload(
                        projectId: 'proj-showcase-1',
                        projectNo: 'PROJ-SHOWCASE-1',
                        title: '展示对齐项目',
                        buildingType: 'exhibition',
                        budgetAmount: 2200,
                        areaSqm: 350.5,
                        provinceCode: '510000',
                        provinceName: '四川',
                        cityCode: '510100',
                        cityName: '成都',
                        districtCode: '510107',
                        districtName: '武侯区',
                        detailAddress: '世纪城新国际会展中心 6 号馆西门',
                        scopeSummary: '主舞台与医疗器械展区联动搭建',
                        description: '这段补充说明不应进入项目列表卡片',
                        summaryHeading: '展示摘要',
                      ),
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectList,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('展示对齐项目'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('项目列表'), findsWidgets);
      expect(find.text('展示摘要'), findsNothing);
      expect(find.textContaining('成都'), findsWidgets);
      expect(find.textContaining('350.5 ㎡'), findsWidgets);
      expect(find.textContaining('展览装修'), findsNothing);
      expect(find.text('竞标中'), findsWidgets);
      expect(find.text('武侯区'), findsNothing);
      expect(find.textContaining('世纪城新国际会展中心 6 号馆西门'), findsNothing);
      expect(find.textContaining('这段补充说明不应进入项目列表卡片'), findsNothing);
      expect(find.textContaining('scopeSummary'), findsNothing);
      expect(find.textContaining('正式附件'), findsNothing);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.textContaining('奖励金额'), findsNothing);
      expect(find.textContaining('单位平方面积金额'), findsNothing);
    },
  );

  testWidgets(
    'project detail without projectId enters user-facing recovery state',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{'id': 'proj-1'},
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectDetail,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final missingProjectMessage = find.textContaining(
        '当前入口还没有承接到所需项目',
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(
        missingProjectMessage.first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前入口还没有承接到所需项目'), findsOneWidget);
      expect(find.textContaining('route context'), findsNothing);
      expect(find.text('回到项目展示'), findsOneWidget);
      expect(
        transport.requests.where(
          (AppApiRequest request) =>
              request.canonicalPath == ExhibitionCanonicalPaths.projectDetail,
        ),
        isEmpty,
      );
      expect(find.widgetWithText(TextField, 'projectId'), findsNothing);

      await tester.tap(find.text('回到项目展示').first);
      await tester.pumpAndSettle();

      expect(find.text('项目列表'), findsWidgets);
    },
  );

  testWidgets(
    'order detail network failure stays user-facing and recoverable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                throw const SocketException('offline');
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.orderDetail}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final failureMessage = find.textContaining(
        '当前内容暂时没有成功返回',
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(
        failureMessage,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前内容暂时没有成功返回'), findsOneWidget);
      expect(find.textContaining('network error'), findsNothing);
      expect(find.text('回到展览'), findsWidgets);
    },
  );

  testWidgets('contract detail http failure hides raw transport wording', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              throw const HttpException('bad gateway');
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.contractDetail}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final failureMessage = find.textContaining(
      '当前内容暂时没有成功返回',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      failureMessage,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('当前内容暂时没有成功返回'), findsOneWidget);
    expect(find.textContaining('http error'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets('inspection detail decoding failure hides raw decoding wording', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/inspection/detail': (AppApiRequest request) async {
              throw const FormatException('bad payload');
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute:
            '${ExhibitionRoutes.inspectionDetail}?milestoneId=milestone-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final failureMessage = find.textContaining(
      '当前内容暂时没有成功返回',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      failureMessage,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('当前内容暂时没有成功返回'), findsOneWidget);
    expect(find.textContaining('response decoding failed'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets(
    'project detail consumes shared showcase detail ProjectReadModel fields only',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'proj-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    ..._projectPayload(
                      projectId: 'proj-1',
                      projectNo: 'PROJ-1',
                      title: '展览项目 1',
                      buildingType: 'exhibition',
                      budgetAmount: 1888,
                      areaSqm: 350.5,
                      buildingTypeRemark: '医疗器械展区特装搭建',
                      provinceCode: '510000',
                      provinceName: '四川',
                      cityCode: '510100',
                      cityName: '成都',
                      districtCode: '510107',
                      districtName: '武侯区',
                      detailAddress: '世纪城新国际会展中心 6 号馆西门',
                      scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
                      plannedStartAt: '2026-04-10',
                      plannedEndAt: '2026-04-18',
                      scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
                      description: '现场先完成基础施工与设备进场，重点关注主舞台区域。',
                      summaryHeading: 'project',
                    ),
                    'buyerOrganizationId': 'buyer-1',
                    'detailOnlyField': 'should-be-ignored',
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.projectDetail}?projectId=proj-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目详情'), findsWidgets);
      expect(find.text('项目概要'), findsOneWidget);
      expect(find.text('展览项目 1'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('项目编号：PROJ-1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('项目编号：PROJ-1'), findsOneWidget);
      expect(find.text('项目类型：会展'), findsOneWidget);
      expect(find.text('预算金额：¥1888'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('项目面积：350.5 ㎡'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('项目面积：350.5 ㎡'), findsOneWidget);
      expect(find.text('类型备注：医疗器械展区特装搭建'), findsOneWidget);
      expect(find.text('项目摘要：project'), findsOneWidget);
      expect(
        find.text('项目地点：四川 / 成都 / 武侯区 · 世纪城新国际会展中心 6 号馆西门'),
        findsOneWidget,
      );
      expect(find.text('范围说明：主舞台、医疗器械展区与灯光联动区进场搭建'), findsOneWidget);
      expect(find.text('计划时间：2026-04-10 至 2026-04-18'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('时间说明：4 月 10 日晚进场，4 月 18 日撤场'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('时间说明：4 月 10 日晚进场，4 月 18 日撤场'), findsOneWidget);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.text('510107'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('补充说明：现场先完成基础施工与设备进场，重点关注主舞台区域。'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('补充说明：现场先完成基础施工与设备进场，重点关注主舞台区域。'), findsOneWidget);
      expect(find.text('buyer-1'), findsNothing);
      expect(find.text('should-be-ignored'), findsNothing);
      expect(find.widgetWithText(TextField, 'projectId'), findsNothing);
    },
  );

  testWidgets(
    'project detail keeps legacy location names visible when standardized codes are absent',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'legacy-location-project-1',
                    projectNo: 'PROJ-LEGACY-LOC-1',
                    title: '旧地点项目',
                    provinceName: '四川',
                    cityName: '成都',
                    districtName: '武侯区',
                    detailAddress: '世纪城新国际会展中心 6 号馆西门',
                    budgetAmount: 980,
                  ),
                );
              },
              'GET /api/app/project/public-resources':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{'resources': <Object?>[]},
                    );
                  },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.projectDetail}?projectId=legacy-location-project-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('项目地点：四川 / 成都 / 武侯区 · 世纪城新国际会展中心 6 号馆西门'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('项目地点：四川 / 成都 / 武侯区 · 世纪城新国际会展中心 6 号馆西门'),
        findsOneWidget,
      );
      expect(find.textContaining('标准地区'), findsNothing);
      expect(find.textContaining('省 code'), findsNothing);
      expect(find.textContaining('区县 code'), findsNothing);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.text('510107'), findsNothing);
    },
  );

  testWidgets(
    'project detail bid continuation redirects unauthenticated actor to login entry',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'proj-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'proj-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目 1',
                    buildingType: 'exhibition',
                    budgetAmount: 1888,
                    state: 'published',
                    summaryHeading: 'project',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.projectDetail}?projectId=proj-1',
          transport: transport,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '立即参与竞标'));
      expect(find.text('欢迎登录'), findsOneWidget);
      expect(find.text('验证码登录'), findsWidgets);
      expect(find.text('账号密码登录'), findsOneWidget);
    },
  );

  testWidgets('bid submit blocks unauthenticated actor with login handoff', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: AppSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '进入登录入口'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
    await _scrollAndTap(tester, find.widgetWithText(FilledButton, '进入登录入口'));
    expect(find.text('欢迎登录'), findsOneWidget);
  });

  testWidgets('bid submit blocks actor without organization with handoff', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        shellContextConsumer: buildShellContextConsumer(
          organizationId: null,
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-no-organization',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '前往组织承接'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
  });

  testWidgets(
    'bid submit blocks non-approved certification with controlled handoff',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'pending',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-cert-pending',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, '前往公司认证与我的身份'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
    },
  );

  testWidgets(
    'bid submit blocks missing personal certification with dual-cert handoff',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'not_submitted',
            personalCertificationQualified: false,
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-personal-cert-missing',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前我的认证未通过'), findsOneWidget);
      expect(find.textContaining('企业认证和我的认证同时通过'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '前往公司认证与我的身份'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
    },
  );

  testWidgets(
    'bid submit blocks personal certification locked to another actor',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: false,
            personalCertificationLockedToOtherActor: true,
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-personal-cert-locked',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前我的认证已锁定其他账号'), findsOneWidget);
      expect(find.textContaining('不支持换人'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
    },
  );

  testWidgets(
    'bid submit allows both organization with buyer role after dual certification passes',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'proj-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'proj-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目 1',
                    buildingType: 'exhibition',
                    budgetAmount: 1888,
                    state: 'published',
                    viewerProjectRelation: 'public_viewer',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          transport: transport,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            organizationType: 'both',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-both-buyer-admin',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _expandBidSubmitFlowIfNeeded(tester);
      await _expectVisibleText(tester, '提交竞标');
      expect(find.text('当前组织类型未开放竞标资格'), findsNothing);
    },
  );

  testWidgets(
    'bid submit blocks demand-only organization with controlled handoff',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            organizationType: 'demand',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-role-guard',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前组织类型未开放竞标资格'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '前往公司与组织'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
    },
  );

  testWidgets('bid submit blocks owner route from executable mainline', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'proj-owner');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'proj-owner',
                  projectNo: 'PROJ-OWNER',
                  title: 'Owner 项目',
                  budgetAmount: 1800,
                  state: 'published',
                  viewerProjectRelation: 'owner',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-owner',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-owner-guard',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expectVisibleText(tester, '当前项目属于你方发布');
    expect(find.widgetWithText(FilledButton, '进入我的项目'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
  });

  testWidgets('bid submit blocks project that is no longer bid-open', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'proj-closed');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'proj-closed',
                  projectNo: 'PROJ-CLOSED',
                  title: 'Closed 项目',
                  budgetAmount: 1800,
                  state: 'bidding_closed',
                  viewerProjectRelation: 'public_viewer',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-closed',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-state-guard',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expectVisibleText(tester, '当前项目暂不可参与竞标');
    await _expectVisibleText(tester, '当前项目竞标已结束，暂时不能提交竞标。');
    expect(find.widgetWithText(FilledButton, '回到项目详情'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '提交竞标'), findsNothing);
  });

  testWidgets(
    'project create page surfaces admitted Round B richer fields only',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-create-round-b-fields',
          ),
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
            canCreateProject: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_projectCreateField('类型备注（选填）'), findsOneWidget);
      expect(_projectCreateField('项目面积'), findsOneWidget);
      await tester.scrollUntilVisible(
        _projectCreateField('详细时间（选填）'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('详细时间（选填）'), findsOneWidget);
      expect(find.text('预算区间'), findsNothing);
      expect(find.text('奖励金额'), findsNothing);
    },
  );

  testWidgets(
    'project create default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          shellContextConsumer: buildShellContextConsumer(
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-content',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('创建项目'), findsWidgets);
      expect(find.text('先看这五步'), findsNothing);
      expect(find.text('第二步 地址与范围'), findsNothing);
      expect(find.text('第三步 文件资料'), findsNothing);
      expect(find.text('第四步 文字说明与 AI 辅助'), findsNothing);
      expect(find.text('第五步 预览、支付与一键发布'), findsNothing);
      expect(find.textContaining('BFF base URL'), findsNothing);
      expect(find.text('当前连接信息（次级）'), findsNothing);
      expect(find.text('协议承接信息（次级）'), findsNothing);
      expect(find.text('payload snapshot'), findsNothing);
      expect(find.text('基础信息'), findsWidgets);
      await tester.scrollUntilVisible(
        _projectCreateField('项目名称'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('项目名称'), findsOneWidget);
      expect(_projectCreateField('项目类型'), findsOneWidget);
      expect(_projectCreateField('预算金额'), findsOneWidget);
      await tester.scrollUntilVisible(
        _projectCreateField('省'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('省'), findsOneWidget);
      expect(_projectCreateField('市'), findsOneWidget);
      expect(_projectCreateField('区/县'), findsOneWidget);
      expect(find.textContaining('标准地区'), findsNothing);
      expect(find.textContaining('省 code'), findsNothing);
      expect(find.textContaining('城市 code'), findsNothing);
      expect(find.textContaining('districtCode'), findsNothing);
      expect(find.textContaining('区县 code'), findsNothing);
      expect(_projectCreateField('详细地址'), findsOneWidget);
      expect(_projectCreateField('范围说明'), findsOneWidget);
      await tester.scrollUntilVisible(
        _projectCreateField('计划结束日期'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('计划开始日期'), findsOneWidget);
      expect(_projectCreateField('计划结束日期'), findsOneWidget);
      expect(find.byTooltip('选择计划开始日期'), findsOneWidget);
      expect(find.byTooltip('选择计划结束日期'), findsOneWidget);
      expect(find.text('补充说明与附件', skipOffstage: false), findsNothing);
      expect(_projectCreateField('补充说明'), findsNothing);
      expect(find.text('资料补充', skipOffstage: false), findsNothing);
      expect(find.text('title'), findsNothing);
      expect(find.text('buildingType'), findsNothing);
      expect(find.text('budgetAmount'), findsNothing);
      expect(find.textContaining('create 必填'), findsNothing);
      expect(find.textContaining('detail address contract'), findsNothing);
      expect(find.textContaining('detailAddress'), findsNothing);
      expect(find.textContaining('scopeSummary'), findsNothing);
      expect(find.textContaining('旧项目可为空'), findsNothing);
      expect(find.textContaining('默认行政区'), findsNothing);
      expect(find.textContaining('当前仍复用现有项目类型字段承接'), findsNothing);
      expect(find.textContaining('YYYY-MM-DD'), findsNothing);
      expect(find.textContaining('code + name'), findsNothing);
      expect(find.textContaining('carrier'), findsNothing);
    },
  );

  testWidgets('project create local validation stays user-facing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-validation',
        ),
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
          canCreateProject: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = _projectCreateSubmitButton();
    await tester.scrollUntilVisible(
      _projectCreateSubmitLabel(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
    await tester.pumpAndSettle();

    final titleField = tester.widget<TextField>(_projectCreateField('项目名称'));
    expect(titleField.decoration?.errorText, '请输入展会');
    expect(find.textContaining('title'), findsNothing);
    expect(find.textContaining('buildingType'), findsNothing);
    expect(find.textContaining('budgetAmount'), findsNothing);
  });

  testWidgets('project create blocks unauthenticated actor with login hint', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: AppSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    final loginEntryButton = find.ancestor(
      of: find.text('去登录', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );
    final submitButton = find.ancestor(
      of: find.text('发布项目', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );

    expect(loginEntryButton, findsOneWidget);
    expect(submitButton, findsNothing);

    await _scrollAndTap(tester, find.text('去登录', skipOffstage: false));
    expect(find.text('欢迎登录'), findsOneWidget);
    expect(find.text('验证码登录'), findsWidgets);
    expect(find.text('账号密码登录'), findsWidgets);
  });

  testWidgets('project create blocks no-organization actor with handoff hint', (
    WidgetTester tester,
  ) async {
    final sessionStore = AppSessionStore();
    sessionStore.establishSession(
      accessToken: 'token-active',
      refreshToken: 'token-refresh',
      expiresInSeconds: 3600,
      deviceId: 'device-1',
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        shellContextConsumer: buildShellContextConsumer(organizationId: null),
        sessionStore: sessionStore,
      ),
    );
    await tester.pumpAndSettle();

    final organizationHandoffButton = find.ancestor(
      of: find.text('去完善组织', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );
    final submitButton = find.ancestor(
      of: find.text('发布项目', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );

    expect(organizationHandoffButton, findsOneWidget);
    expect(submitButton, findsNothing);

    await _scrollAndTap(tester, find.text('去完善组织', skipOffstage: false));
    expect(find.text('创建组织'), findsOneWidget);
    expect(find.text('加入组织'), findsOneWidget);
  });

  testWidgets('shell context not found stays unavailable instead of offline', (
    WidgetTester tester,
  ) async {
    final shellContextConsumer = AppShellContextConsumer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/shell/context': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 404,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'code': 'SHELL_CONTEXT_UNAVAILABLE',
                      'message': 'shell context unavailable',
                    },
                  );
                },
              },
        ),
      ),
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: AppBuilding.messages.routePath,
        shellContextConsumer: shellContextConsumer,
        sessionStore: buildAuthenticatedSessionStore(deviceId: 'device-shell'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前上下文暂不可用'), findsOneWidget);
    expect(find.text('当前离线'), findsNothing);
    expect(find.widgetWithText(FilledButton, '重试承接'), findsOneWidget);
  });

  testWidgets(
    'project create blocks certification-not-approved actor before workbench qualification',
    (WidgetTester tester) async {
      final sessionStore = AppSessionStore();
      sessionStore.establishSession(
        accessToken: 'token-active',
        refreshToken: 'token-refresh',
        expiresInSeconds: 3600,
        deviceId: 'device-2a',
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'not_submitted',
          ),
          sessionStore: sessionStore,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前认证未通过'), findsOneWidget);
      expect(find.text('当前组织认证尚未通过，需先完成并通过认证后再创建项目。'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '查看认证状态'), findsOneWidget);
    },
  );

  testWidgets(
    'project create keeps role guard controlled by shell create-eligibility projection',
    (WidgetTester tester) async {
      final sessionStore = AppSessionStore();
      sessionStore.establishSession(
        accessToken: 'token-active',
        refreshToken: 'token-refresh',
        expiresInSeconds: 3600,
        deviceId: 'device-2',
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
            canCreateProject: false,
          ),
          sessionStore: sessionStore,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前角色不允许创建项目'), findsNothing);
      expect(find.text('返回我的项目'), findsNothing);
      expect(find.text('当前组织角色暂不允许创建项目'), findsNothing);
    },
  );

  test(
    'project create submits admitted Round B richer fields while success result keeps required create acceptance fields',
    () async {
      Object? capturedBody;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/project/create':
                      (AppApiRequest request) async {
                        capturedBody = request.body;
                        return AppApiResponse(
                          statusCode: 202,
                          uri: request.uri,
                          body: <String, Object?>{
                            'projectId': 'project-1',
                            'projectNo': 'PROJ-1',
                            'title': 'raw project',
                            'buildingType': 'exhibition',
                            'budgetAmount': 1200,
                            'state': 'published',
                            'summary': <String, Object?>{'heading': 'project'},
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.createProject(
        ProjectCreateCommand(
          title: '展览项目',
          buildingType: 'exhibition',
          budgetAmount: 1200,
          areaSqm: 350.5,
          buildingTypeRemark: '医疗器械展区特装搭建',
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          districtCode: '510107',
          districtName: '武侯区',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
          plannedStartAt: '2026-04-10',
          plannedEndAt: '2026-04-18',
          scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
        ),
      );

      expect(
        capturedBody,
        _projectCreateAddressRangeBody(
          budgetAmount: 1200,
          areaSqm: 350.5,
          buildingTypeRemark: '医疗器械展区特装搭建',
          scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
          description: null,
        ),
      );
      expect(result.isSuccess, isTrue);
      expect(result.controlledState, isNull);
      expect(result.payload, <String, Object?>{
        'projectId': 'project-1',
        'state': 'published',
      });
    },
  );

  test(
    'project create omits districtCode and districtName together when district is not separately selected',
    () async {
      Object? capturedBody;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/project/create':
                      (AppApiRequest request) async {
                        capturedBody = request.body;
                        return AppApiResponse(
                          statusCode: 202,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'projectId': 'project-2',
                          },
                        );
                      },
                },
          ),
        ),
      );

      await consumer.createProject(
        ProjectCreateCommand(
          title: '不单独提供区县的项目',
          buildingType: 'exhibition',
          budgetAmount: 980,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 5 号馆北门',
          scopeSummary: '不单独提供区县时的最小标准地区提交流程',
        ),
      );

      expect(capturedBody, <String, Object?>{
        'title': '不单独提供区县的项目',
        'buildingType': 'exhibition',
        'budgetAmount': 980.0,
        'provinceCode': '510000',
        'provinceName': '四川',
        'cityCode': '510100',
        'cityName': '成都',
        'detailAddress': '世纪城新国际会展中心 5 号馆北门',
        'scopeSummary': '不单独提供区县时的最小标准地区提交流程',
      });
    },
  );

  testWidgets(
    'project detail keeps legacy null address-range fields controlled',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    ..._projectPayload(
                      projectId: 'legacy-project-1',
                      projectNo: 'PROJ-LEGACY-1',
                      title: '旧项目',
                      buildingType: 'exhibition',
                      budgetAmount: 980,
                    ),
                    'provinceName': null,
                    'cityName': null,
                    'districtName': null,
                    'detailAddress': null,
                    'scopeSummary': null,
                    'plannedStartAt': null,
                    'plannedEndAt': null,
                    'areaSqm': null,
                    'buildingTypeRemark': null,
                    'scheduleDetail': null,
                    'description': null,
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.projectDetail}?projectId=legacy-project-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('项目面积：当前项目暂未提供'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('项目面积：当前项目暂未提供'), findsOneWidget);
      expect(find.text('类型备注：当前项目暂未提供'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('当前暂无地点与安排信息'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('当前暂无地点与安排信息'), findsOneWidget);
      expect(find.text('当前项目暂未提供地点、范围、说明或时间安排。'), findsOneWidget);
      expect(find.text('范围说明：当前项目暂未提供'), findsNothing);
      expect(find.text('计划时间：当前项目暂未提供 至 当前项目暂未提供'), findsNothing);
      expect(find.text('补充说明：当前项目暂未提供'), findsNothing);
    },
  );

  testWidgets('bid submit success stays in minimum bid continuation only', (
    WidgetTester tester,
  ) async {
    final uploadedKinds = <String>[];
    final previewPngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
      'AAAADUlEQVR42mP8z8BQDwAFgwJ/lOSv0wAAAABJRU5ErkJggg==',
    );
    BidSubmitAttachmentDebugOverrides.installPicker(() async {
      final nextFile = switch (uploadedKinds.length) {
        0 => 'project-understanding.png',
        1 => 'quote-sheet.xlsx',
        _ => 'schedule-plan.docx',
      };
      return BidSubmitAttachmentDraft(
        fileName: nextFile,
        bytes: nextFile.endsWith('.png')
            ? previewPngBytes
            : utf8.encode('mock-$nextFile'),
      );
    });
    final transport = FakeAppApiTransport(
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'proj-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'proj-1',
                  projectNo: 'PROJ-1',
                  title: '展览项目 1',
                  buildingType: 'exhibition',
                  budgetAmount: 1888,
                  state: 'published',
                  viewerProjectRelation: 'public_viewer',
                  summaryHeading: 'project',
                ),
              );
            },
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{'resources': <Object?>[]},
                  );
                },
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              final fileKind = '${body['fileKind']}';
              uploadedKinds.add(fileKind);
              expect(body['businessType'], 'project');
              expect(body['businessId'], 'proj-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'uploadSessionId': 'session-$fileKind',
                  'directUpload': <String, Object?>{
                    'url': 'https://upload.test/$fileKind',
                    'method': 'PUT',
                    'headers': <String, Object?>{},
                  },
                  'confirm': <String, Object?>{
                    'endpoint': '/api/app/file/upload/confirm',
                  },
                },
              );
            },
            'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'fileAssetId': 'fa-${body['uploadSessionId']}',
                },
              );
            },
            'POST /api/app/bid/submit': (AppApiRequest request) async {
              expect(request.body, <String, Object?>{
                'projectId': 'proj-1',
                'quoteAmount': 1200.0,
                'proposalSummary': 'phase 2.1 bid',
                'projectUnderstandingFileAssetId':
                    'fa-session-bid_project_understanding',
                'quoteSheetFileAssetId': 'fa-session-bid_quote_sheet',
                'schedulePlanFileAssetId': 'fa-session-bid_schedule_plan',
              });
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: <String, Object?>{'bidId': 'bid-123'},
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(deviceId: 'device-bid'),
      ),
    );
    await tester.pumpAndSettle();

    await _enterVisibleTextField(tester, label: '竞标报价', value: '1200');
    await _confirmBidSubmitServiceFeeRules(tester);
    await _enterVisibleTextField(tester, label: '方案说明', value: 'phase 2.1 bid');
    await _uploadBidAttachment(tester, '项目理解');
    await _scrollAndTap(
      tester,
      find.widgetWithText(TextButton, '预览检查已上传附件').first,
    );
    expect(find.text('图片预览'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await _uploadBidAttachment(tester, '报价表');
    await _uploadBidAttachment(tester, '进度安排');
    final submitButton = find.widgetWithText(FilledButton, '提交竞标');
    await _scrollAndTap(tester, submitButton);

    expect(find.text('竞标已提交'), findsOneWidget);
    expect(find.text('竞标 ID：bid-123'), findsOneWidget);
    final submittedButton = find.widgetWithText(FilledButton, '已提交竞标');
    expect(submittedButton, findsOneWidget);
    expect(tester.widget<FilledButton>(submittedButton).onPressed, isNull);
    expect(find.widgetWithText(FilledButton, '继续创建订单'), findsNothing);
    expect(find.widgetWithText(FilledButton, '查看订单详情'), findsNothing);
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath.contains('/api/app/exhibition/trade-tasks/'),
      ),
      isEmpty,
    );
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == '/api/app/order/create',
          )
          .isEmpty,
      isTrue,
    );
  });

  testWidgets(
    'core v1 local chain runs from bid submit to my bids, interactions, thread and snapshot',
    (WidgetTester tester) async {
      final uploadedKinds = <String>[];
      final previewPngBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
        'AAAADUlEQVR42mP8z8BQDwAFgwJ/lOSv0wAAAABJRU5ErkJggg==',
      );
      BidSubmitAttachmentDebugOverrides.installPicker(() async {
        final nextFile = switch (uploadedKinds.length) {
          0 => 'project-understanding.png',
          1 => 'quote-sheet.xlsx',
          _ => 'schedule-plan.docx',
        };
        return BidSubmitAttachmentDraft(
          fileName: nextFile,
          bytes: nextFile.endsWith('.png')
              ? previewPngBytes
              : utf8.encode('mock-$nextFile'),
        );
      });

      final exhibitionTransport = FakeAppApiTransport(
        uploadHandler: (AppApiUploadRequest request) async {
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'proj-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目 1',
                    buildingType: 'exhibition',
                    budgetAmount: 1888,
                    state: 'published',
                    viewerProjectRelation: 'public_viewer',
                    summaryHeading: 'project',
                  ),
                );
              },
              'GET /api/app/project/public-resources':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{'resources': <Object?>[]},
                    );
                  },
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                final body = request.body as Map<String, Object?>;
                final fileKind = '${body['fileKind']}';
                uploadedKinds.add(fileKind);
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'uploadSessionId': 'session-$fileKind',
                    'directUpload': <String, Object?>{
                      'url': 'https://upload.test/$fileKind',
                      'method': 'PUT',
                      'headers': <String, Object?>{},
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async {
                    final body = request.body as Map<String, Object?>;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'fileAssetId': 'fa-${body['uploadSessionId']}',
                      },
                    );
                  },
              'POST /api/app/bid/submit': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: <String, Object?>{
                    'bidId': 'bid-123',
                    'systemSeed': <String, Object?>{
                      'seedType': 'bid_submitted',
                      'threadId': 'thread-1',
                    },
                    'interactionSeed': <String, Object?>{
                      'threadId': 'thread-1',
                      'projectId': 'proj-1',
                      'bidId': 'bid-123',
                    },
                  },
                );
              },
              'GET /api/app/my/bids': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _myBidItem(
                        bidId: 'bid-123',
                        projectId: 'proj-1',
                        projectNo: 'BID-PROJ-1',
                        projectTitle: '展览项目 1',
                        quoteAmount: 1200,
                        proposalSummaryPreview: 'phase 2.1 bid',
                        submittedAt: '2026-04-20T10:00:00Z',
                        outcomeState: 'published',
                        canOpenBidThread: true,
                        canOpenBidResult: false,
                      ),
                    ],
                  },
                );
              },
            },
      );
      final messagesTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'lane': 'project_communication',
                        'items': <Object?>[
                          _messageInteractionItem(
                            interactionId: 'interaction-1',
                            projectId: 'proj-1',
                            bidId: 'bid-123',
                            counterpartName: '杭州搭建公司',
                            summary: '杭州搭建公司已对当前项目提交竞标。',
                            lastMessageText: '当前竞标已提交，可继续进入沟通。',
                          ),
                        ],
                      },
                    );
                  },
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['conversationId'],
                      'org-interaction-1',
                    );
                    expect(request.uri.queryParameters['projectId'], 'proj-1');
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _counterpartConversationBidDetailPayload(
                        interactionId: 'interaction-1',
                        projectId: 'proj-1',
                        bidId: 'bid-123',
                        counterpartName: '杭州搭建公司',
                      ),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    expect(request.uri.queryParameters['projectId'], 'proj-1');
                    expect(
                      request.uri.queryParameters['counterpartOrganizationId'],
                      'org-interaction-1',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'threadId': 'project-thread-proj-1',
                        'projectId': 'proj-1',
                        'ownerOrganizationId': 'org-owner',
                        'counterpartOrganizationId': 'org-interaction-1',
                        'threadState': 'open',
                        'lastMessageId': null,
                        'lastMessageAt': null,
                        'createdAt': '2026-04-20T10:00:00Z',
                        'updatedAt': '2026-04-20T10:00:00Z',
                      },
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['threadId'],
                      'project-thread-proj-1',
                    );
                    expect(request.uri.queryParameters['projectId'], 'proj-1');
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
            },
      );
      final tradingImConsumerLayer = TradingImConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/bid/thread/detail':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: <String, Object?>{
                            'threadId': 'thread-1',
                            'projectId': 'proj-1',
                            'bidId': 'bid-123',
                            'participants': <Object?>[
                              <String, Object?>{
                                'participantRole': 'project_owner',
                                'organizationId': 'org-owner-1',
                              },
                              <String, Object?>{
                                'participantRole': 'bidder',
                                'organizationId': 'org-bidder-1',
                              },
                            ],
                            'viewerParticipantRole': 'project_owner',
                            'state': 'open',
                            'availability': <String, Object?>{
                              'canSendMessage': true,
                              'canCreateConfirmation': true,
                              'reason': 'participant_allowed',
                            },
                            'messages': <Object?>[
                              <String, Object?>{
                                'messageId': 'message-seed-1',
                                'threadId': 'thread-1',
                                'projectId': 'proj-1',
                                'bidId': 'bid-123',
                                'senderRole': 'system_seed',
                                'messageKind': 'system_seed',
                                'systemSeedType': 'bid_submitted',
                                'systemSeedAction': <String, Object?>{
                                  'objectType': 'bid_submission_snapshot',
                                  'actionKey': 'bid_submission_snapshot.open',
                                  'canonicalPath':
                                      '/api/app/bid/submission/snapshot',
                                  'params': <String, Object?>{
                                    'projectId': 'proj-1',
                                    'bidId': 'bid-123',
                                  },
                                },
                                'body': '杭州搭建公司已对当前项目提交竞标。',
                                'attachmentFileAssetIds': <Object?>[],
                                'createdAt': '2026-04-16T00:00:00Z',
                              },
                            ],
                            'confirmationCards': <Object?>[],
                          },
                        );
                      },
                  'GET /api/app/bid/submission/snapshot':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'projectId': 'proj-1',
                            'bidId': 'bid-123',
                            'bidder': <String, Object?>{
                              'organizationId': 'org-bidder-1',
                              'displayName': '杭州搭建公司',
                              'avatarUrl': null,
                            },
                            'submittedAt': '2026-04-16T00:00:00Z',
                            'quoteAmount': 1200,
                            'proposalSummary': 'phase 2.1 bid',
                            'attachmentSummary': <String, Object?>{'count': 3},
                            'attachments': <Object?>[
                              <String, Object?>{
                                'slotKey': 'project_understanding',
                                'slotLabel': '项目理解',
                                'fileAssetId':
                                    'fa-session-bid_project_understanding',
                                'fileKind': 'bid_project_understanding',
                                'mimeType': 'application/pdf',
                              },
                              <String, Object?>{
                                'slotKey': 'quote_sheet',
                                'slotLabel': '报价表',
                                'fileAssetId': 'fa-session-bid_quote_sheet',
                                'fileKind': 'bid_quote_sheet',
                                'mimeType': 'application/vnd.ms-excel',
                              },
                              <String, Object?>{
                                'slotKey': 'schedule_plan',
                                'slotLabel': '进度安排',
                                'fileAssetId': 'fa-session-bid_schedule_plan',
                                'fileKind': 'bid_schedule_plan',
                                'mimeType': 'application/pdf',
                              },
                            ],
                            'availability': <String, Object?>{
                              'canOpenBidThread': true,
                              'participantCardReadable': true,
                            },
                          },
                        );
                      },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          transport: exhibitionTransport,
          messagesTransport: messagesTransport,
          tradingImConsumerLayer: tradingImConsumerLayer,
          counterpartConversationConsumerLayer:
              _counterpartConsumerWithNoopRealtime(messagesTransport),
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-core-v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _enterVisibleTextField(tester, label: '竞标报价', value: '1200');
      await _confirmBidSubmitServiceFeeRules(tester);
      await _enterVisibleTextField(
        tester,
        label: '方案说明',
        value: 'phase 2.1 bid',
      );
      await _uploadBidAttachment(tester, '项目理解');
      await _uploadBidAttachment(tester, '报价表');
      await _uploadBidAttachment(tester, '进度安排');
      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '提交竞标'));

      expect(find.text('竞标已提交'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '查看我的竞标'), findsOneWidget);

      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '查看我的竞标'));
      expect(find.byType(MyProjectListPage), findsOneWidget);
      final myBidsChip = find.widgetWithText(ChoiceChip, '我的竞标');
      if (myBidsChip.evaluate().isNotEmpty) {
        await _scrollAndTap(tester, myBidsChip.first);
      }
      expect(find.text('phase 2.1 bid'), findsOneWidget);
      expect(find.text('沟通与投标'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('消息'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目沟通'), findsOneWidget);
      expect(find.text('杭州搭建公司'), findsOneWidget);

      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '进入项目沟通'));
      expect(find.text('展览项目 1'), findsOneWidget);

      await _scrollAndTap(
        tester,
        find.widgetWithText(FilledButton, '进入此项目竞标沟通'),
      );
      expect(find.text('竞标沟通'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('聊天'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('聊天'), findsOneWidget);
      expect(find.text('想跟TA说点什么...'), findsOneWidget);
    },
  );

  testWidgets(
    'order detail enters read-only content from route orderId and exposes contract detail plus rating entry continuation actions',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderPayload(
                    orderId: 'order-1',
                    projectId: 'project-1',
                    bidId: 'bid-1',
                    milestones: <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.orderDetail}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('订单详情'), findsWidgets);
      expect(find.text('当前订单 ID：order-1'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('订单编号：ORD-1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('订单编号：ORD-1'), findsOneWidget);
      expect(find.text('关联项目 ID：project-1'), findsNothing);
      expect(find.text('关联投标 ID：bid-1'), findsNothing);
      expect(find.text('订单状态：进行中'), findsWidgets);
      expect(find.text('当前说明：订单最小读模型已经承接完成，当前页不会扩成订单后台或履约指挥台。'), findsNothing);
      expect(find.text('完工处理'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('查看合同详情'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('查看合同详情'), findsOneWidget);
      expect(find.text('双方互评暂不可从订单页进入'), findsNothing);
      expect(find.text('订单完成后开放双方互评。'), findsOneWidget);
      expect(find.text('查看双方互评入口'), findsNothing);
      expect(find.text('查看里程碑列表'), findsNothing);
      expect(find.text('去提交 initial delivery'), findsNothing);
      expect(find.text('开启争议入口'), findsNothing);
      expect(find.text('去争议撤回'), findsNothing);
    },
  );

  testWidgets(
    'order detail contract continuation enters contract detail with the same orderId',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderPayload(
                    orderId: 'order-1',
                    projectId: 'project-1',
                    bidId: 'bid-1',
                    milestones: <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  ),
                );
              },
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': _summary('contract'),
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.orderDetail}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('查看合同详情'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pumpAndSettle();

      final contractDetailButton = find.widgetWithText(FilledButton, '查看合同详情');
      await tester.ensureVisible(contractDetailButton);
      await tester.tap(contractDetailButton);
      await tester.pumpAndSettle();
      expect(find.text('合同详情'), findsWidgets);
      expect(find.text('合同概览'), findsOneWidget);

      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.contractDetail,
            )
            .length,
        1,
      );
    },
  );

  testWidgets(
    'milestone list enters content from route orderId and exposes only approved continuation action',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/milestone/list': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.milestoneList}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('里程碑列表'), findsWidgets);
      expect(find.text('当前订单 ID：order-1'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('initial delivery'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前里程碑数：1 个'), findsOneWidget);
      expect(find.text('initial delivery'), findsOneWidget);
      expect(find.text('里程碑 ID：milestone-1'), findsOneWidget);
      expect(find.text('所属订单：order-1'), findsOneWidget);
      expect(find.text('节点金额：¥1200'), findsOneWidget);
      expect(find.text('当前状态：待提交'), findsOneWidget);
      expect(find.text('下一步动作：继续查看当前里程碑对应的验收详情。'), findsOneWidget);
      expect(find.text('去提交 initial delivery'), findsNothing);
      expect(find.text('查看 initial delivery 验收详情'), findsOneWidget);
      expect(find.text('inspection detail'), findsNothing);
      expect(find.text('inspection submit'), findsNothing);
      expect(find.text('inspection recheck'), findsNothing);
    },
  );

  testWidgets(
    'bid submit default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      final resources = <Map<String, Object?>>[
        _publicResourceItem(
          resourceId: 'resource-contract-1',
          resourceCategory: 'contract_template',
          title: '标准合同模板',
          summary: '用于统一合同模板口径。',
          fileAssetId: 'file-resource-contract-1',
          fileName: 'standard-contract-template.pdf',
          mimeType: 'application/pdf',
          sortOrder: 0,
        ),
        _publicResourceItem(
          resourceId: 'resource-process-1',
          resourceCategory: 'process_guide',
          title: '发布流程图与说明',
          summary: '用于核对提交流程。',
          fileAssetId: 'file-resource-process-1',
          fileName: 'publish-process-guide.pdf',
          mimeType: 'application/pdf',
          sortOrder: 1,
        ),
        _publicResourceItem(
          resourceId: 'resource-other-1',
          resourceCategory: 'other_resource',
          title: '公共资料汇编',
          summary: '用于补充共享资料。',
          fileAssetId: 'file-resource-other-1',
          fileName: 'public-resource-bundle.docx',
          mimeType:
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          sortOrder: 2,
        ),
      ];
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'proj-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'proj-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目 1',
                    buildingType: 'exhibition',
                    budgetAmount: 1888,
                    state: 'published',
                    viewerProjectRelation: 'public_viewer',
                    summaryHeading: 'project',
                  ),
                );
              },
              'GET /api/app/project/public-resources':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _publicResourceListResponse(resources),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          transport: transport,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-content',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('竞标提交'), findsWidgets);
      expect(find.text('已承接项目'), findsOneWidget);
      await _expandBidSubmitFlowIfNeeded(tester);
      expect(find.textContaining('项目信息已承接'), findsOneWidget);
      final reopenProjectReview = find.widgetWithText(OutlinedButton, '复核项目信息');
      expect(reopenProjectReview, findsOneWidget);
      tester.widget<OutlinedButton>(reopenProjectReview).onPressed!.call();
      await tester.pumpAndSettle();
      await _expectVisibleText(tester, '核心信息');
      await _expectVisibleText(tester, '地点与安排');
      expect(find.widgetWithText(OutlinedButton, '收起项目信息'), findsOneWidget);
      await _expectVisibleText(tester, '查看报价依据资料');
      await _expectVisibleText(tester, '填写报价与预授权确认');
      await _expectVisibleText(tester, '竞标服务费预授权额度确认');
      await _expectVisibleTextContaining(tester, '成交后按平台规则扣取服务费');
      await _expectVisibleText(tester, '你需要做什么');
      await _expectVisibleText(tester, '48小时');
      await _expectVisibleText(tester, '上传方案');
      final fourthStepIndex = tester.allWidgets
          .toList(growable: false)
          .indexWhere(
            (Widget widget) => widget is Text && widget.data == '上传方案',
          );
      final proposalFieldIndex = _textFieldIndexByLabel(tester, '方案说明');
      expect(fourthStepIndex, isNonNegative);
      expect(proposalFieldIndex, greaterThan(fourthStepIndex));
      await _expectVisibleText(tester, '模板下载区');
      await _expectVisibleText(tester, '必传资料');
      await _expectVisibleText(tester, '合同模板');
      await _expectVisibleText(tester, '流程图与说明');
      await _expectVisibleText(tester, '公共资料');
      await _expectVisibleText(tester, '项目理解');
      await _expectVisibleText(tester, '报价表');
      await _expectVisibleText(tester, '进度安排');
      await _expectVisibleText(tester, '提交竞标');
      expect(find.widgetWithText(FilledButton, '提交竞标'), findsOneWidget);
      expect(find.text('项目附件', skipOffstage: false), findsNothing);
      expect(find.widgetWithText(OutlinedButton, '预览图片'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, '预览文书'), findsNothing);
      expect(find.text('打开', skipOffstage: false), findsNothing);
      expect(find.text('下载原文件', skipOffstage: false), findsNothing);
      expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
      expect(find.text('上传并形成正式附件', skipOffstage: false), findsNothing);
      expect(find.text('删除当前文书', skipOffstage: false), findsNothing);
      expect(find.text('绑定', skipOffstage: false), findsNothing);
      expect(find.text('确认服务费规则并继续提交'), findsNothing);
      expect(find.textContaining('P0-Pay'), findsNothing);
      expect(find.text('工艺说明'), findsNothing);
      expect(find.text('搭建流程'), findsNothing);
      expect(find.text('交付节点'), findsNothing);
      expect(find.text('风险说明'), findsNothing);
      expect(find.text('补充报价附件 ID（可选）'), findsNothing);
      expect(find.text('当前说明'), findsNothing);
      expect(find.text('资料分类'), findsNothing);
      expect(find.text('当前公共资源目录暂不可用，请稍后再试。'), findsNothing);
      expect(find.text('席位状态'), findsNothing);
      expect(find.text('资料完整度'), findsNothing);
      expect(find.textContaining('BFF base URL'), findsNothing);
      expect(find.text('当前连接信息（次级）'), findsNothing);
      expect(find.text('协议承接信息（次级）'), findsNothing);
      expect(find.text('payload snapshot'), findsNothing);
    },
  );

  testWidgets('bid submit keeps compact template download actions available', (
    WidgetTester tester,
  ) async {
    String? downloadedAccessUrl;
    ProjectPublicResourceDebugOverrides.installLocalDownloader((
      ProjectPublicResourceFileAccessReadModel access,
      ProjectPublicResourceReadModel resource,
    ) async {
      downloadedAccessUrl = access.accessUrl;
      return ProjectPublicResourceDownloadedFile(
        path: '/tmp/${access.fileName ?? resource.fileName}',
        fileName: access.fileName ?? resource.fileName,
        mimeType: access.mimeType ?? resource.mimeType,
        sizeBytes: access.contentLengthBytes ?? 2048,
      );
    });

    final resources = <Map<String, Object?>>[
      _publicResourceItem(
        resourceId: 'resource-contract-1',
        resourceCategory: 'contract_template',
        title: '标准合同模板',
        summary: '用于统一合同模板口径。',
        fileAssetId: 'file-resource-contract-1',
        fileName: 'standard-contract-template.pdf',
        mimeType: 'application/pdf',
        sortOrder: 0,
      ),
      _publicResourceItem(
        resourceId: 'resource-process-1',
        resourceCategory: 'process_guide',
        title: '发布流程图与说明',
        summary: '用于核对提交流程。',
        fileAssetId: 'file-resource-process-1',
        fileName: 'publish-process-guide.pdf',
        mimeType: 'application/pdf',
        sortOrder: 1,
      ),
      _publicResourceItem(
        resourceId: 'resource-other-1',
        resourceCategory: 'other_resource',
        title: '公共资料汇编',
        summary: '用于补充共享资料。',
        fileAssetId: 'file-resource-other-1',
        fileName: 'public-resource-bundle.docx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        sortOrder: 2,
      ),
    ];
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        ...defaultHandlers(),
        'GET /api/app/project/detail': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _projectPayload(
              projectId: 'proj-1',
              projectNo: 'PROJ-1',
              title: '展览项目 1',
              taskId: 'proj-1',
              buildingType: 'exhibition',
              budgetAmount: 1888,
              state: 'published',
              viewerProjectRelation: 'public_viewer',
              summaryHeading: 'project',
            ),
          );
        },
        'GET /api/app/project/public-resources': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _publicResourceListResponse(resources),
          );
        },
        'GET /api/app/file/access': (AppApiRequest request) async {
          expect(
            request.uri.queryParameters['fileAssetId'],
            'file-resource-contract-1',
          );
          expect(request.uri.queryParameters['mode'], 'download');
          expect(request.uri.queryParameters['accessScope'], 'public_resource');
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'accessUrl':
                  'https://files.example.com/public-resource-contract-1.pdf',
              'fileAssetId': 'file-resource-contract-1',
              'mode': 'download',
              'fileName': 'standard-contract-template.pdf',
              'mimeType': 'application/pdf',
            },
          );
        },
      },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-template-download',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expandBidSubmitFlowIfNeeded(tester);
    await _expectVisibleText(tester, '模板下载区');
    await _expectVisibleText(tester, '合同模板');
    await _expectVisibleText(tester, '流程图与说明');
    await _expectVisibleText(tester, '公共资料');
    final contractTile = find.byKey(
      const ValueKey<String>(
        'bid-submit-template-download-resource-contract-1',
      ),
    );
    final processTile = find.byKey(
      const ValueKey<String>('bid-submit-template-download-resource-process-1'),
    );
    final otherTile = find.byKey(
      const ValueKey<String>('bid-submit-template-download-resource-other-1'),
    );
    await tester.ensureVisible(contractTile);
    await tester.pumpAndSettle();
    final contractTopLeft = tester.getTopLeft(contractTile);
    final processTopLeft = tester.getTopLeft(processTile);
    final otherTopLeft = tester.getTopLeft(otherTile);
    expect((contractTopLeft.dy - processTopLeft.dy).abs(), lessThan(1));
    expect((contractTopLeft.dy - otherTopLeft.dy).abs(), lessThan(1));
    expect(processTopLeft.dx, greaterThan(contractTopLeft.dx));
    expect(otherTopLeft.dx, greaterThan(processTopLeft.dx));
    await _scrollAndTap(
      tester,
      find.byKey(
        const ValueKey<String>(
          'bid-submit-template-download-resource-contract-1',
        ),
      ),
    );

    expect(
      downloadedAccessUrl,
      'https://files.example.com/public-resource-contract-1.pdf',
    );
    expect(find.text('资料已下载到 App 本地。'), findsOneWidget);
    expect(find.text('下载完成'), findsOneWidget);
  });

  testWidgets('bid submit service fee uses fixed validity and user-facing copy', (
    WidgetTester tester,
  ) async {
    final uploadedKinds = <String>[];
    Map<String, Object?>? bidSubmitBody;
    BidSubmitAttachmentDebugOverrides.installPicker(() async {
      final nextFile = switch (uploadedKinds.length) {
        0 => 'project-understanding.pdf',
        1 => 'quote-sheet.xlsx',
        _ => 'schedule-plan.docx',
      };
      return BidSubmitAttachmentDraft(
        fileName: nextFile,
        bytes: utf8.encode('mock-$nextFile'),
      );
    });

    final transport = FakeAppApiTransport(
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        ...defaultHandlers(),
        'GET /api/app/project/detail': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _projectPayload(
              projectId: 'proj-1',
              projectNo: 'PROJ-1',
              title: '展览项目 1',
              taskId: 'proj-1',
              buildingType: 'exhibition',
              budgetAmount: 1888,
              state: 'published',
              viewerProjectRelation: 'public_viewer',
              summaryHeading: 'project',
            ),
          );
        },
        'GET /api/app/project/public-resources': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{'resources': <Object?>[]},
          );
        },
        'POST /api/app/file/upload/init': (AppApiRequest request) async {
          final body = request.body as Map<String, Object?>;
          final fileKind = '${body['fileKind']}';
          uploadedKinds.add(fileKind);
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'uploadSessionId': 'session-$fileKind',
              'directUpload': <String, Object?>{
                'url': 'https://upload.test/$fileKind',
                'method': 'PUT',
                'headers': <String, Object?>{},
              },
              'confirm': <String, Object?>{
                'endpoint': '/api/app/file/upload/confirm',
              },
            },
          );
        },
        'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
          final body = request.body as Map<String, Object?>;
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'fileAssetId': 'fa-${body['uploadSessionId']}',
            },
          );
        },
        'GET ${ExhibitionCanonicalPaths.projectPricingSummary('proj-1')}':
            (AppApiRequest request) async => AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'projectId': 'proj-1',
                'bidderPricing': <String, Object?>{
                  'bidServiceFeeAuthorizationStatus': 'required',
                  'quotaAmount': '4000.00',
                },
                'readOnly': true,
              },
            ),
        'POST ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizations('proj-1')}':
            (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              expect(body['bidParticipationRequestId'], 'bpr-1');
              expect(body['expectedAmount'], 4000);
              expect(body, isNot(contains('estimatedFeeAmount')));
              return AppApiResponse(
                statusCode: 201,
                uri: request.uri,
                body: const <String, Object?>{
                  'authorizationId': 'auth-1',
                  'authorizationStatus': 'pending_freeze',
                  'quotaAmount': '4000.00',
                  'currency': 'CNY',
                  'channelCandidates': <Object?>['alipay_candidate'],
                },
              );
            },
        'POST ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationFreezeInit('proj-1', 'auth-1')}':
            (AppApiRequest request) async => AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'freezeInitStatus': 'started',
                'authorizationId': 'auth-1',
                'paymentReferenceId': 'auth-ref-1',
                'callbackAwaiting': true,
              },
            ),
        'GET ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus('proj-1', 'auth-1')}':
            (AppApiRequest request) async => AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'authorizationId': 'auth-1',
                'authorizationStatus': 'frozen',
                'quotaAmount': '4000.00',
                'currency': 'CNY',
              },
            ),
        'POST ${ExhibitionCanonicalPaths.bidSubmit}':
            (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              bidSubmitBody = body;
              expect(body['projectId'], 'proj-1');
              expect(body['quoteAmount'], 1200.0);
              expect(body['proposalSummary'], 'phase 2.1 bid');
              expect(
                body['projectUnderstandingFileAssetId'],
                'fa-session-bid_project_understanding',
              );
              expect(
                body['quoteSheetFileAssetId'],
                'fa-session-bid_quote_sheet',
              );
              expect(
                body['schedulePlanFileAssetId'],
                'fa-session-bid_schedule_plan',
              );
              return AppApiResponse(
                statusCode: 201,
                uri: request.uri,
                body: const <String, Object?>{'bidId': 'bid-1'},
              );
            },
        'POST ${ExhibitionCanonicalPaths.p0PayFixedPriceBids('proj-1')}':
            (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              bidSubmitBody = body;
              final parsed = DateTime.parse('${body['quoteValidUntil']}');
              final remaining = parsed.difference(DateTime.now());
              expect(body['quoteAmount'], 1200.0);
              expect(body['constructionPlan'], 'phase 2.1 bid');
              expect(body['taxIncluded'], isTrue);
              expect(body['transportIncluded'], isTrue);
              expect(body['installationIncluded'], isTrue);
              expect(remaining.inHours, inInclusiveRange(47, 48));
              expect(body['attachmentFileAssetIds'], <String>[
                'fa-session-bid_project_understanding',
                'fa-session-bid_quote_sheet',
                'fa-session-bid_schedule_plan',
              ]);
              expect('${body['materialDescription']}', contains('第四步方案说明'));
              expect('${body['craftDescription']}', contains('必传文档'));
              return AppApiResponse(
                statusCode: 201,
                uri: request.uri,
                body: const <String, Object?>{
                  'bidId': 'bid-1',
                  'bidStatus': 'pending_authorization',
                  'platformServiceFeeRequirement': <String, Object?>{
                    'feeRate': '0.030',
                    'feeRateLabel': '标准会员 9折（作用于 baseFeeAmount）',
                    'feeRateSource': 'paid_membership_tier',
                    'membershipTierSnapshot': 'standard',
                    'feeRateRuleVersion': 'membership-fee-linkage-v1',
                    'feeRateSnapshotHash': 'hash-standard-09',
                    'quotedAmount': '1200.00',
                    'baseFeeAmount': '200.00',
                    'membershipDiscountRate': '0.9000',
                    'capAmount': '3600.00',
                    'estimatedFeeAmount': '180.00',
                    'authorizationQuotaAmount': '4000.00',
                    'quotaAmount': '4000.00',
                    'currency': 'CNY',
                    'authorizationRequired': true,
                    'authorizationStatus': 'pending_authorization',
                  },
                },
              );
            },
        'POST ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizations('proj-1', 'bid-1')}':
            (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              expect(body['expectedQuotedAmount'], 1200);
              expect(body['expectedFeeRate'], '0.030');
              expect(body['expectedAuthorizationAmount'], '4000.00');
              return AppApiResponse(
                statusCode: 201,
                uri: request.uri,
                body: const <String, Object?>{
                  'authorizationId': 'auth-1',
                  'authorizationStatus': 'pending_authorization',
                  'estimatedFeeAmount': '30.00',
                  'currency': 'CNY',
                },
              );
            },
        'POST ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizeInit('proj-1', 'bid-1', 'auth-1')}':
            (AppApiRequest request) async => AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'authorizationInitStatus': 'started',
                'authorizationId': 'auth-1',
                'paymentReferenceId': 'auth-ref-1',
                'callbackAwaiting': true,
              },
            ),
        'GET ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizationStatus('proj-1', 'bid-1', 'auth-1')}':
            (AppApiRequest request) async => AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'authorizationId': 'auth-1',
                'authorizationStatus': 'authorized',
                'quotedAmount': '1200.00',
                'feeRate': '0.030',
                'feeRateLabel': '标准会员 9折（作用于 baseFeeAmount）',
                'membershipTierSnapshot': 'standard',
                'baseFeeAmount': '200.00',
                'membershipDiscountRate': '0.9000',
                'capAmount': '3600.00',
                'estimatedFeeAmount': '180.00',
                'authorizationQuotaAmount': '4000.00',
                'currency': 'CNY',
                'updatedAt': '2026-05-13T00:03:00Z',
              },
            ),
      },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute:
            '${ExhibitionRoutes.bidSubmit}?projectId=proj-1&bidParticipationRequestId=bpr-1',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-p0-pay-fixed-validity',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _enterVisibleTextField(tester, label: '竞标报价', value: '1200');
    await _expectVisibleText(tester, '竞标服务费预授权额度确认');
    expect(find.textContaining('固定 4000 元', findRichText: true), findsWidgets);
    expect(find.textContaining('成交后以平台记录处理', findRichText: true), findsWidgets);
    await _expectVisibleText(tester, '48小时');
    expect(find.textContaining('成交金额的 3%'), findsNothing);
    expect(find.text('含税'), findsNothing);
    expect(find.text('含运输'), findsNothing);
    expect(find.text('含安装'), findsNothing);
    expect(find.text('支付宝'), findsNothing);
    expect(find.text('微信'), findsNothing);
    await _scrollAndTap(
      tester,
      find.widgetWithText(CheckboxListTile, '我已阅读并同意平台成交服务费规则'),
    );
    await _scrollAndTap(
      tester,
      find.widgetWithText(CheckboxListTile, '我知晓未中标自动释放，中标并合同确认后正式扣款'),
    );
    await _scrollAndTap(
      tester,
      find.widgetWithText(CheckboxListTile, '我知晓发布方毁约或项目条件重大变化时，预授权应按规则释放'),
    );
    await _enterVisibleTextField(tester, label: '方案说明', value: 'phase 2.1 bid');
    await _uploadBidAttachment(tester, '项目理解');
    await _uploadBidAttachment(tester, '报价表');
    await _uploadBidAttachment(tester, '进度安排');
    expect(find.textContaining('P0-Pay'), findsNothing);
    expect(find.text('工艺说明'), findsNothing);
    expect(find.text('搭建流程'), findsNothing);
    expect(find.text('交付节点'), findsNothing);
    expect(find.text('风险说明'), findsNothing);
    expect(find.text('补充报价附件 ID（可选）'), findsNothing);
    await _scrollAndTap(tester, find.widgetWithText(FilledButton, '提交竞标'));

    expect(bidSubmitBody, isNotNull);
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath == ExhibitionCanonicalPaths.bidSubmit,
      ),
      isNotEmpty,
    );
  });

  testWidgets(
    'bid submit disabled copy points to missing quote and service fee confirmations',
    (WidgetTester tester) async {
      Future<void> pumpBidSubmit(String deviceId) async {
        final transport = FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                ...defaultHandlers(),
                'GET /api/app/project/detail': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _projectPayload(
                      projectId: 'proj-1',
                      projectNo: 'PROJ-1',
                      title: '展览项目 1',
                      buildingType: 'exhibition',
                      budgetAmount: 1888,
                      state: 'published',
                      viewerProjectRelation: 'public_viewer',
                      summaryHeading: 'project',
                    ),
                  );
                },
                'GET /api/app/project/public-resources':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{'resources': <Object?>[]},
                      );
                    },
              },
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          buildApp(
            initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
            transport: transport,
            shellContextConsumer: buildShellContextConsumer(
              organizationId: 'org-1',
              roleKeys: const <String>['supplier_admin'],
              certificationStatus: 'verified',
            ),
            sessionStore: buildAuthenticatedSessionStore(deviceId: deviceId),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpBidSubmit('device-bid-disabled-copy-quote');
      await _expandBidSubmitFlowIfNeeded(tester);
      await _expectVisibleTextContaining(tester, '请先填写有效的竞标报价。');
      var submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '提交竞标'),
      );
      expect(submitButton.onPressed, isNull);

      await pumpBidSubmit('device-bid-disabled-copy-fee');
      await _expandBidSubmitFlowIfNeeded(tester);
      await _enterVisibleTextField(tester, label: '竞标报价', value: '1200');
      await _expectVisibleTextContaining(tester, '请先勾选全部平台服务费确认项。');
      submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '提交竞标'),
      );
      expect(submitButton.onPressed, isNull);
      expect(find.textContaining('账号'), findsNothing);
      expect(find.textContaining('权限'), findsNothing);
    },
  );

  testWidgets(
    'bid submit rejects project understanding spreadsheet before upload init',
    (WidgetTester tester) async {
      var uploadInitCalled = false;
      BidSubmitAttachmentDebugOverrides.installPicker(() async {
        return BidSubmitAttachmentDraft(
          fileName: 'project-understanding.xlsx',
          bytes: utf8.encode('project-understanding-xlsx'),
        );
      });

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'proj-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目 1',
                    buildingType: 'exhibition',
                    budgetAmount: 1888,
                    state: 'published',
                    viewerProjectRelation: 'public_viewer',
                    summaryHeading: 'project',
                  ),
                );
              },
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                uploadInitCalled = true;
                return AppApiResponse(
                  statusCode: 400,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'FILE_UPLOAD_INIT_INVALID',
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          transport: transport,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-project-understanding-xlsx',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _uploadBidAttachment(tester, '项目理解');

      expect(uploadInitCalled, isFalse);
      await _expectVisibleText(tester, '项目理解只支持图片、PDF、DOC、DOCX 文件。');
    },
  );

  testWidgets(
    'bid submit attachment slots switch to three columns on wide viewport',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'proj-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'proj-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目 1',
                    buildingType: 'exhibition',
                    budgetAmount: 1888,
                    state: 'published',
                    viewerProjectRelation: 'public_viewer',
                    summaryHeading: 'project',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          transport: transport,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-layout',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _expandBidSubmitFlowIfNeeded(tester);
      final projectUnderstandingCard = find.byKey(
        const ValueKey<String>(
          'bid-submit-attachment-card-project-understanding',
        ),
      );
      final quoteSheetCard = find.byKey(
        const ValueKey<String>('bid-submit-attachment-card-quote-sheet'),
      );
      final schedulePlanCard = find.byKey(
        const ValueKey<String>('bid-submit-attachment-card-schedule-plan'),
      );

      await tester.scrollUntilVisible(
        projectUnderstandingCard,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final projectRect = tester.getRect(projectUnderstandingCard);
      final quoteRect = tester.getRect(quoteSheetCard);
      final scheduleRect = tester.getRect(schedulePlanCard);

      expect((projectRect.top - quoteRect.top).abs(), lessThan(1));
      expect((quoteRect.top - scheduleRect.top).abs(), lessThan(1));
      expect(projectRect.left, lessThan(quoteRect.left));
      expect(quoteRect.left, lessThan(scheduleRect.left));
      expect((projectRect.width - quoteRect.width).abs(), lessThan(2));
      expect((quoteRect.width - scheduleRect.width).abs(), lessThan(2));
      expect((projectRect.height - quoteRect.height).abs(), lessThan(2));
      expect((quoteRect.height - scheduleRect.height).abs(), lessThan(2));
    },
  );

  test('bid submit success sanitizes to minimum command body only', () async {
    final consumer = ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/bid/submit': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 202,
                    uri: request.uri,
                    body: <String, Object?>{
                      'bidId': 'bid-1',
                      'bidNo': 'BID-1',
                      'projectId': 'project-1',
                      'quoteAmount': 1200,
                      'state': 'submitted',
                      'summary': <String, Object?>{'heading': 'bid'},
                    },
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.submitBid(
      const BidSubmitCommand(
        projectId: 'project-1',
        quoteAmount: 1200,
        proposalSummary: 'phase 2.1 bid',
        projectUnderstandingFileAssetId: 'fa-1',
        quoteSheetFileAssetId: 'fa-2',
        schedulePlanFileAssetId: 'fa-3',
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(result.controlledState, isNull);
    expect(result.payload, <String, Object?>{'bidId': 'bid-1'});
  });

  testWidgets(
    'bid submit blocks submission when any required attachment is missing',
    (WidgetTester tester) async {
      final uploadedKinds = <String>[];
      BidSubmitAttachmentDebugOverrides.installPicker(() async {
        final nextFile = switch (uploadedKinds.length) {
          0 => 'project-understanding.pdf',
          _ => 'quote-sheet.xlsx',
        };
        return BidSubmitAttachmentDraft(
          fileName: nextFile,
          bytes: utf8.encode('mock-$nextFile'),
        );
      });

      final transport = FakeAppApiTransport(
        uploadHandler: (AppApiUploadRequest request) async {
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          ...defaultHandlers(),
          'GET /api/app/project/detail': (AppApiRequest request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: _projectPayload(
                projectId: 'proj-1',
                projectNo: 'PROJ-1',
                title: '展览项目 1',
                buildingType: 'exhibition',
                budgetAmount: 1888,
                state: 'published',
                viewerProjectRelation: 'public_viewer',
                summaryHeading: 'project',
              ),
            );
          },
          'GET /api/app/project/public-resources':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{'resources': <Object?>[]},
                );
              },
          'POST /api/app/file/upload/init': (AppApiRequest request) async {
            final body = request.body as Map<String, Object?>;
            final fileKind = '${body['fileKind']}';
            uploadedKinds.add(fileKind);
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: <String, Object?>{
                'uploadSessionId': 'session-$fileKind',
                'directUpload': <String, Object?>{
                  'url': 'https://upload.test/$fileKind',
                  'method': 'PUT',
                  'headers': <String, Object?>{},
                },
                'confirm': <String, Object?>{
                  'endpoint': '/api/app/file/upload/confirm',
                },
              },
            );
          },
          'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
            final body = request.body as Map<String, Object?>;
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: <String, Object?>{
                'fileAssetId': 'fa-${body['uploadSessionId']}',
              },
            );
          },
          'POST /api/app/bid/submit': (AppApiRequest request) async {
            fail(
              'submit should be blocked until all required attachments confirm',
            );
          },
        },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          transport: transport,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-miss',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _enterVisibleTextField(tester, label: '竞标报价', value: '1200');
      await _confirmBidSubmitServiceFeeRules(tester);
      await _enterVisibleTextField(
        tester,
        label: '方案说明',
        value: 'phase 2.1 bid',
      );
      await _uploadBidAttachment(tester, '项目理解');
      await _uploadBidAttachment(tester, '报价表');
      await _expectVisibleTextContaining(tester, '请先完成并确认附件');
      final submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '提交竞标'),
      );
      expect(submitButton.onPressed, isNull);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ExhibitionCanonicalPaths.bidSubmit,
            )
            .isEmpty,
        isTrue,
      );
    },
  );

  testWidgets(
    'milestone submit default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('里程碑提交'), findsWidgets);
      expect(find.text('当前里程碑 ID：milestone-1'), findsOneWidget);
      expect(find.textContaining('BFF base URL'), findsNothing);
      expect(find.text('当前连接信息（次级）'), findsNothing);
      expect(find.text('协议承接信息（次级）'), findsNothing);
      expect(find.text('payload snapshot'), findsNothing);
      expect(find.text('上传承接字段（次级）'), findsNothing);
    },
  );

  testWidgets(
    'remaining read pages default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': <String, Object?>{'heading': 'contract'},
                  },
                );
              },
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'inspectionId': 'inspection-1',
                    'milestoneId': 'milestone-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'inspection'},
                  },
                );
              },
            },
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.contractDetail}?orderId=order-1',
          transport: transport,
        ),
        pageTitle: '合同详情',
        visibleTexts: const <String>['合同概览', '合同状态：待确认'],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute:
              '${ExhibitionRoutes.inspectionDetail}?milestoneId=milestone-1',
          transport: transport,
        ),
        pageTitle: '验收详情',
        visibleTexts: const <String>[
          '当前里程碑 ID：milestone-1',
          '当前验收 ID：inspection-1',
        ],
      );
    },
  );

  testWidgets(
    'allowed action pages default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'inspectionId': 'inspection-1',
                    'milestoneId': 'milestone-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'inspection'},
                  },
                );
              },
            },
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute:
              '${ExhibitionRoutes.inspectionSubmit}?milestoneId=milestone-1',
          transport: transport,
        ),
        pageTitle: '验收提交',
        visibleTexts: const <String>[
          '当前里程碑 ID：milestone-1',
          '当前验收 ID：inspection-1',
        ],
      );
    },
  );

  testWidgets(
    'allowed dispute page default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.disputeOpen}?orderId=order-1',
        ),
        pageTitle: '争议开启入口',
        visibleTexts: const <String>['当前订单 ID：order-1'],
      );
    },
  );

  testWidgets(
    'frozen workbench extension routes enter route unavailable page',
    (WidgetTester tester) async {
      final routes = <String>[
        '/exhibition/workbench',
        '/exhibition/contracts/confirm?orderId=order-1',
        '/exhibition/contracts/amend?orderId=order-1',
        '/exhibition/inspections/recheck?milestoneId=milestone-1',
        '/exhibition/ratings/submit?orderId=order-1',
      ];

      for (final route in routes) {
        await tester.pumpWidget(buildApp(initialRoute: route));
        await tester.pumpAndSettle();

        expect(find.text('路由不可用'), findsWidgets);
        expect(
          find.text('当前页面暂时不可进入，应用已经把你带到受控承接页，不会静默跳回其他页面。'),
          findsOneWidget,
        );
        expect(find.text('回到展览'), findsOneWidget);
      }
    },
  );

  testWidgets('dispute withdraw route enters the minimal withdraw page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.disputeWithdraw}?orderId=order-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('争议撤回入口'), findsWidgets);
    expect(find.text('当前订单 ID：order-1'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '继续争议撤回'), findsOneWidget);
    expect(find.text('路由不可用'), findsNothing);
  });

  testWidgets('upload confirm shows user-facing upload completion only', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'uploadSessionId': 'upload-session-1',
                  'directUpload': <String, Object?>{
                    'url': 'https://oss.example.com/upload/object-1',
                    'method': 'PUT',
                    'headers': <String, Object?>{
                      'x-oss-meta-source': 'flutter-test',
                    },
                  },
                  'confirm': <String, Object?>{
                    'endpoint': '/api/app/file/upload/confirm',
                  },
                },
              );
            },
            'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
              expect(
                request.canonicalPath,
                ExhibitionCanonicalPaths.uploadConfirm,
              );
              expect(request.body, <String, Object?>{
                'uploadSessionId': 'upload-session-1',
              });
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{'status': 'bound'},
              );
            },
          },
      uploadHandler: (AppApiUploadRequest request) async {
        expect(request.method, 'PUT');
        expect(request.url, 'https://oss.example.com/upload/object-1');
        expect(request.headers['x-oss-meta-source'], 'flutter-test');
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute:
            '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final uploadSummaryField = find.widgetWithText(TextField, '凭证摘要');
    await tester.ensureVisible(uploadSummaryField);
    await tester.pumpAndSettle();
    await tester.enterText(uploadSummaryField, '现场照片与节点确认单');
    final uploadButton = find.widgetWithText(FilledButton, '补充当前凭证');

    await tester.ensureVisible(uploadButton);
    await tester.pumpAndSettle();
    await tester.tap(uploadButton);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('上传已完成'), findsOneWidget);
    expect(find.textContaining('upload-session-1'), findsNothing);
    expect(find.textContaining('x-oss-meta-source'), findsNothing);
    expect(transport.uploads, hasLength(1));

    expect(find.text('上传已完成'), findsOneWidget);
    expect(find.textContaining('upload state'), findsNothing);
    expect(find.textContaining('uploadSessionId'), findsNothing);
    expect(find.textContaining('directMethod'), findsNothing);
    expect(find.textContaining('confirmEndpoint'), findsNothing);
    expect(
      transport.requests
          .map((AppApiRequest request) => request.canonicalPath)
          .contains(ExhibitionCanonicalPaths.uploadConfirm),
      isTrue,
    );
    expect(transport.uploads, hasLength(1));
  });

  testWidgets(
    'project detail keeps public materials read-only and strips private attachment controls',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目',
                    budgetAmount: 1200,
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.projectDetail}?projectId=project-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('公开资料边界'), findsNothing);
      expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
      expect(find.text('上传并形成正式附件', skipOffstage: false), findsNothing);
      expect(find.text('本次上传确认记录'), findsNothing);
      expect(transport.uploads, isEmpty);
    },
  );

  testWidgets('unauthorized response enters controlled unauthorized state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/list': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 401,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'AUTH_SESSION_INVALID',
                  'message': 'missing auth headers',
                  'source': 'bff',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectList,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('missing auth headers'), findsOneWidget);
    expect(find.textContaining('error code'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets('duplicate bid submission stays controlled and visible', (
    WidgetTester tester,
  ) async {
    var submitRequestCount = 0;
    final uploadedKinds = <String>[];
    BidSubmitAttachmentDebugOverrides.installPicker(() async {
      final nextFile = switch (uploadedKinds.length) {
        0 => 'project-understanding.png',
        1 => 'quote-sheet.xlsx',
        _ => 'schedule-plan.docx',
      };
      return BidSubmitAttachmentDraft(
        fileName: nextFile,
        bytes: utf8.encode('mock-$nextFile'),
      );
    });
    final transport = FakeAppApiTransport(
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'proj-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'proj-1',
                  projectNo: 'PROJ-1',
                  title: '展览项目 1',
                  buildingType: 'exhibition',
                  budgetAmount: 1888,
                  state: 'published',
                  viewerProjectRelation: 'public_viewer',
                  summaryHeading: 'project',
                ),
              );
            },
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{'resources': <Object?>[]},
                  );
                },
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              final fileKind = '${body['fileKind']}';
              uploadedKinds.add(fileKind);
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'uploadSessionId': 'session-$fileKind',
                  'directUpload': <String, Object?>{
                    'url': 'https://upload.test/$fileKind',
                    'method': 'PUT',
                    'headers': <String, Object?>{},
                  },
                  'confirm': <String, Object?>{
                    'endpoint': '/api/app/file/upload/confirm',
                  },
                },
              );
            },
            'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
              final body = request.body as Map<String, Object?>;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'fileAssetId': 'fa-${body['uploadSessionId']}',
                },
              );
            },
            'POST /api/app/bid/submit': (AppApiRequest request) async {
              submitRequestCount += 1;
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'BID_DUPLICATE_SUBMISSION',
                  'message': 'duplicate bid',
                  'source': 'server',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-duplicate',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _enterVisibleTextField(tester, label: '竞标报价', value: '1200');
    await _confirmBidSubmitServiceFeeRules(tester);
    await _enterVisibleTextField(
      tester,
      label: '方案说明',
      value: 'phase 2.2 duplicate bid',
    );
    await _uploadBidAttachment(tester, '项目理解');
    await _uploadBidAttachment(tester, '报价表');
    await _uploadBidAttachment(tester, '进度安排');
    final submitButton = find.widgetWithText(FilledButton, '提交竞标');
    await _scrollAndTap(tester, submitButton);
    await tester.pumpAndSettle();

    final submittedButton = find.widgetWithText(FilledButton, '已提交竞标');
    expect(submittedButton, findsOneWidget);
    expect(tester.widget<FilledButton>(submittedButton).onPressed, isNull);
    await _scrollAndTap(tester, submittedButton);
    expect(submitRequestCount, 1);

    expect(find.textContaining('controlled state'), findsNothing);
    expect(find.textContaining('error code'), findsNothing);
    await _expectVisibleTextContaining(tester, '当前项目已提交过竞标');
    await _expectVisibleTextContaining(tester, '这不是本次新提交成功');
    expect(find.text('回到项目展示'), findsWidgets);
  });

  testWidgets('bid submit current viewer bid starts locked without POST', (
    WidgetTester tester,
  ) async {
    var submitRequestCount = 0;
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'proj-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'proj-1',
                  projectNo: 'PROJ-1',
                  title: '展览项目 1',
                  buildingType: 'exhibition',
                  budgetAmount: 1888,
                  state: 'published',
                  viewerProjectRelation: 'non_owner',
                  summaryHeading: 'project',
                  currentViewerBid: <String, Object?>{
                    'bidId': 'bid-current',
                    'state': 'submitted',
                  },
                ),
              );
            },
            'POST /api/app/bid/submit': (AppApiRequest request) async {
              submitRequestCount += 1;
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: <String, Object?>{'bidId': 'should-not-submit'},
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-current-viewer',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final submittedButton = find.widgetWithText(FilledButton, '已提交竞标');
    await tester.scrollUntilVisible(
      submittedButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(submittedButton, findsOneWidget);
    expect(tester.widget<FilledButton>(submittedButton).onPressed, isNull);
    await _scrollAndTap(tester, submittedButton);
    expect(submitRequestCount, 0);
  });

  testWidgets('submitted milestone stays in controlled invalid_state failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/milestone/submit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'MILESTONE_INVALID_STATE',
                  'message':
                      'Only pending_submission milestones may be submitted.',
                  'source': 'server',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute:
            '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(FilledButton, '继续里程碑提交');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('controlled state'), findsNothing);
    expect(find.textContaining('error code'), findsNothing);
    expect(
      find.textContaining(
        'Only pending_submission milestones may be submitted.',
      ),
      findsOneWidget,
    );
    expect(find.text('回到展览'), findsWidgets);
  });

  test(
    'milestone submit success sanitizes to minimum command body only',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/milestone/submit':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 202,
                          uri: request.uri,
                          body: <String, Object?>{
                            'milestoneId': 'milestone-1',
                            'orderId': 'order-1',
                            'title': 'initial delivery',
                            'amount': 1200,
                            'state': 'submitted',
                            'summary': <String, Object?>{
                              'heading': 'milestone',
                            },
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.submitMilestone(
        const MilestoneSubmitCommand(
          milestoneId: 'milestone-1',
          submissionNote: 'phase 2 milestone',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.controlledState, isNull);
      expect(result.payload, <String, Object?>{'milestoneId': 'milestone-1'});
    },
  );

  testWidgets(
    'upload confirm required stays user-facing without technical upload tokens',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'uploadSessionId': 'upload-session-2',
                    'directUpload': <String, Object?>{
                      'url': 'https://oss.example.com/upload/object-2',
                      'method': 'PUT',
                      'headers': <String, Object?>{
                        'x-oss-meta-source': 'flutter-test',
                      },
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'uploadSessionId': 'upload-session-2',
                });
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: <String, Object?>{
                    'code': 'FILE_UPLOAD_CONFIRM_REQUIRED',
                    'message':
                        'Upload confirm is required before binding the file.',
                    'source': 'bff',
                  },
                );
              },
            },
        uploadHandler: (AppApiUploadRequest request) async {
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, '凭证摘要'),
        '第二批现场照片与节点说明',
      );
      final uploadButton = find.widgetWithText(FilledButton, '补充当前凭证');
      await tester.ensureVisible(uploadButton);
      await tester.pumpAndSettle();
      await tester.tap(uploadButton);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final uploadFailureTitle = find.text('上传确认暂未完成', skipOffstage: false);
      await tester.scrollUntilVisible(
        uploadFailureTitle.first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('上传确认暂未完成'), findsOneWidget);
      expect(find.textContaining('upload state'), findsNothing);
      expect(find.textContaining('error code'), findsNothing);
      expect(find.textContaining('uploadSessionId'), findsNothing);
      expect(find.textContaining('directMethod'), findsNothing);
      expect(find.textContaining('confirmEndpoint'), findsNothing);
    },
  );

  test(
    'consumer layer sanitizes success payload to frozen minimum fields',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/order/detail': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'orderId': 'order-1',
                        'orderNo': 'ORD-1',
                        'projectId': 'project-1',
                        'bidId': 'bid-1',
                        'buyerOrganizationId': 'buyer-1',
                        'supplierOrganizationId': 'supplier-1',
                        'title': 'raw title',
                        'totalAmount': 1200,
                        'state': 'active',
                        'milestones': <Object?>[
                          <String, Object?>{
                            'milestoneId': 'milestone-1',
                            'orderId': 'order-1',
                            'title': 'initial delivery',
                            'amount': 1200,
                            'state': 'pending_submission',
                            'submittedBy': 'someone',
                            'summary': <String, Object?>{'heading': 'initial'},
                          },
                        ],
                        'summary': <String, Object?>{'heading': 'order'},
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadOrderDetail(orderId: 'order-1');
      final payload = result.payload as Map<String, Object?>;

      expect(result.state, AppPageState.content);
      expect(payload, <String, Object?>{
        'orderId': 'order-1',
        'orderNo': 'ORD-1',
        'projectId': 'project-1',
        'bidId': 'bid-1',
        'state': 'active',
        'summary': <String, Object?>{'heading': 'order'},
        'milestones': <Map<String, Object?>>[
          <String, Object?>{
            'milestoneId': 'milestone-1',
            'orderId': 'order-1',
            'title': 'initial delivery',
            'amount': 1200,
            'state': 'pending_submission',
            'summary': <String, Object?>{'heading': 'initial'},
          },
        ],
      });
    },
  );

  test(
    'project list and detail sanitize to aligned showcase read models only',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/list': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'projectId': 'project-1',
                            'projectNo': 'PROJ-1',
                            'title': 'raw project',
                            'buildingType': 'exhibition',
                            'budgetAmount': 1200,
                            'areaSqm': 350.5,
                            'provinceCode': '510000',
                            'provinceName': '四川',
                            'cityCode': '510100',
                            'cityName': '成都',
                            'districtCode': '510107',
                            'districtName': '武侯区',
                            'detailAddress': '世纪城新国际会展中心 6 号馆西门',
                            'description': 'list must not own description',
                            'state': 'published',
                            'summary': <String, Object?>{'heading': 'project'},
                            'detailOnlyField': 'ignored',
                          },
                        ],
                        'summary': <String, Object?>{'heading': 'ignored-list'},
                      },
                    );
                  },
                  'GET /api/app/project/detail': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'projectId': 'project-1',
                        'projectNo': 'PROJ-1',
                        'title': 'raw project',
                        'buildingType': 'exhibition',
                        'budgetAmount': 1200,
                        'provinceCode': '510000',
                        'provinceName': '四川',
                        'cityCode': '510100',
                        'cityName': '成都',
                        'districtCode': '510107',
                        'districtName': '武侯区',
                        'detailAddress': '世纪城新国际会展中心 6 号馆西门',
                        'scopeSummary': '主舞台、医疗器械展区与灯光联动区进场搭建',
                        'plannedStartAt': '2026-04-10',
                        'plannedEndAt': '2026-04-18',
                        'areaSqm': 350.5,
                        'buildingTypeRemark': '医疗器械展区特装搭建',
                        'scheduleDetail': '4 月 10 日晚进场，4 月 18 日撤场',
                        'description': 'shared detail description',
                        'state': 'published',
                        'summary': <String, Object?>{'heading': 'project'},
                        'detailOnlyField': 'ignored',
                      },
                    );
                  },
                },
          ),
        ),
      );

      final listResult = await consumer.loadProjectList();
      final detailResult = await consumer.loadProjectDetail(
        projectId: 'project-1',
      );

      expect(listResult.state, AppPageState.content);
      expect(detailResult.state, AppPageState.content);
      expect(listResult.payload, <String, Object?>{
        'items': <Map<String, Object?>>[
          <String, Object?>{
            'projectId': 'project-1',
            'projectNo': 'PROJ-1',
            'title': 'raw project',
            'buildingType': 'exhibition',
            'budgetAmount': 1200,
            'areaSqm': 350.5,
            'provinceCode': '510000',
            'provinceName': '四川',
            'cityCode': '510100',
            'cityName': '成都',
            'state': 'published',
            'summary': <String, Object?>{'heading': 'project'},
          },
        ],
      });
      expect(detailResult.payload, <String, Object?>{
        'projectId': 'project-1',
        'projectNo': 'PROJ-1',
        'title': 'raw project',
        'buildingType': 'exhibition',
        'budgetAmount': 1200,
        'provinceCode': '510000',
        'provinceName': '四川',
        'cityCode': '510100',
        'cityName': '成都',
        'districtCode': '510107',
        'districtName': '武侯区',
        'detailAddress': '世纪城新国际会展中心 6 号馆西门',
        'scopeSummary': '主舞台、医疗器械展区与灯光联动区进场搭建',
        'plannedStartAt': '2026-04-10',
        'plannedEndAt': '2026-04-18',
        'areaSqm': 350.5,
        'buildingTypeRemark': '医疗器械展区特装搭建',
        'scheduleDetail': '4 月 10 日晚进场，4 月 18 日撤场',
        'description': 'shared detail description',
        'state': 'published',
        'summary': <String, Object?>{'heading': 'project'},
      });
    },
  );

  test(
    'session read cache keeps different projectId and orderId requests isolated',
    () async {
      var projectDetailRequestCount = 0;
      var orderDetailRequestCount = 0;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/detail': (AppApiRequest request) async {
                    projectDetailRequestCount += 1;
                    final projectId = request.uri.queryParameters['projectId']!;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _projectPayload(
                        projectId: projectId,
                        projectNo: 'NO-$projectId',
                        title: 'title-$projectId',
                      ),
                    );
                  },
                  'GET /api/app/order/detail': (AppApiRequest request) async {
                    orderDetailRequestCount += 1;
                    final orderId = request.uri.queryParameters['orderId']!;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _orderPayload(
                        orderId: orderId,
                        projectId: 'project-$orderId',
                        bidId: 'bid-$orderId',
                      ),
                    );
                  },
                },
          ),
        ),
      );

      final projectOne = await consumer.loadProjectDetail(
        projectId: 'project-1',
      );
      final projectTwo = await consumer.loadProjectDetail(
        projectId: 'project-2',
      );
      final projectOneAgain = await consumer.loadProjectDetail(
        projectId: 'project-1',
      );
      final orderOne = await consumer.loadOrderDetail(orderId: 'order-1');
      final orderTwo = await consumer.loadOrderDetail(orderId: 'order-2');
      final orderOneAgain = await consumer.loadOrderDetail(orderId: 'order-1');

      expect(projectDetailRequestCount, 2);
      expect(orderDetailRequestCount, 2);
      expect(
        (projectOne.payload as Map<String, Object?>)['projectId'],
        'project-1',
      );
      expect(
        (projectTwo.payload as Map<String, Object?>)['projectId'],
        'project-2',
      );
      expect(
        (projectOneAgain.payload as Map<String, Object?>)['projectId'],
        'project-1',
      );
      expect((orderOne.payload as Map<String, Object?>)['orderId'], 'order-1');
      expect((orderTwo.payload as Map<String, Object?>)['orderId'], 'order-2');
      expect(
        (orderOneAgain.payload as Map<String, Object?>)['orderId'],
        'order-1',
      );
    },
  );

  test(
    'new session read cache keeps contract and inspection instances isolated',
    () async {
      var contractDetailRequestCount = 0;
      var inspectionDetailRequestCount = 0;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/contract/detail':
                      (AppApiRequest request) async {
                        contractDetailRequestCount += 1;
                        final orderId = request.uri.queryParameters['orderId']!;
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: <String, Object?>{
                            'contractId': 'contract-$orderId',
                            'orderId': orderId,
                            'state': 'pending_confirm',
                            'summary': <String, Object?>{'heading': orderId},
                          },
                        );
                      },
                  'GET /api/app/inspection/detail':
                      (AppApiRequest request) async {
                        inspectionDetailRequestCount += 1;
                        final milestoneId =
                            request.uri.queryParameters['milestoneId']!;
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: <String, Object?>{
                            'inspectionId': 'inspection-$milestoneId',
                            'milestoneId': milestoneId,
                            'state': 'draft',
                            'summary': <String, Object?>{
                              'heading': milestoneId,
                            },
                          },
                        );
                      },
                },
          ),
        ),
      );

      final contractOne = await consumer.loadContractDetail(orderId: 'order-1');
      final contractTwo = await consumer.loadContractDetail(orderId: 'order-2');
      final contractOneAgain = await consumer.loadContractDetail(
        orderId: 'order-1',
      );
      final inspectionOne = await consumer.loadInspectionDetail(
        milestoneId: 'milestone-1',
      );
      final inspectionTwo = await consumer.loadInspectionDetail(
        milestoneId: 'milestone-2',
      );
      final inspectionOneAgain = await consumer.loadInspectionDetail(
        milestoneId: 'milestone-1',
      );

      expect(contractDetailRequestCount, 2);
      expect(inspectionDetailRequestCount, 2);
      expect(
        (contractOne.payload as Map<String, Object?>)['contractId'],
        'contract-order-1',
      );
      expect(
        (contractTwo.payload as Map<String, Object?>)['contractId'],
        'contract-order-2',
      );
      expect(
        (contractOneAgain.payload as Map<String, Object?>)['contractId'],
        'contract-order-1',
      );
      expect(
        (inspectionOne.payload as Map<String, Object?>)['inspectionId'],
        'inspection-milestone-1',
      );
      expect(
        (inspectionTwo.payload as Map<String, Object?>)['inspectionId'],
        'inspection-milestone-2',
      );
      expect(
        (inspectionOneAgain.payload as Map<String, Object?>)['inspectionId'],
        'inspection-milestone-1',
      );
    },
  );

  test(
    'force refresh bypasses cached read result and sends a fresh request',
    () async {
      var projectDetailRequestCount = 0;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/detail': (AppApiRequest request) async {
                    projectDetailRequestCount += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _projectPayload(
                        projectId: 'project-1',
                        projectNo: 'PROJ-$projectDetailRequestCount',
                      ),
                    );
                  },
                },
          ),
        ),
      );

      final first = await consumer.loadProjectDetail(projectId: 'project-1');
      final second = await consumer.loadProjectDetail(projectId: 'project-1');
      final refreshed = await consumer.loadProjectDetail(
        projectId: 'project-1',
        forceRefresh: true,
      );

      expect(projectDetailRequestCount, 2);
      expect((first.payload as Map<String, Object?>)['projectNo'], 'PROJ-1');
      expect((second.payload as Map<String, Object?>)['projectNo'], 'PROJ-1');
      expect(
        (refreshed.payload as Map<String, Object?>)['projectNo'],
        'PROJ-2',
      );
    },
  );

  test(
    'session read optimization dedupes in-flight project detail requests',
    () async {
      var projectDetailRequestCount = 0;
      final responseCompleter = Completer<AppApiResponse>();
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/detail': (AppApiRequest request) {
                    projectDetailRequestCount += 1;
                    return responseCompleter.future;
                  },
                },
          ),
        ),
      );

      final firstFuture = consumer.loadProjectDetail(projectId: 'project-1');
      final secondFuture = consumer.loadProjectDetail(projectId: 'project-1');

      expect(projectDetailRequestCount, 1);

      responseCompleter.complete(
        AppApiResponse(
          statusCode: 200,
          uri: Uri.parse('http://127.0.0.1:8080/api/app/project/detail'),
          body: _projectPayload(projectId: 'project-1'),
        ),
      );

      final results = await Future.wait<ExhibitionLoadResult>(
        <Future<ExhibitionLoadResult>>[firstFuture, secondFuture],
      );

      expect(projectDetailRequestCount, 1);
      expect(results[0].state, AppPageState.content);
      expect(results[1].state, AppPageState.content);
    },
  );

  test(
    'unsupported stable state enters controlled failure instead of content',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/order/detail': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _orderPayload(
                        orderId: 'order-1',
                        projectId: 'project-1',
                        bidId: 'bid-1',
                        state: 'draft',
                      ),
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadOrderDetail(orderId: 'order-1');

      expect(result.state, AppPageState.errorNonRetryable);
      expect(
        result.message,
        contains('unsupported state "draft" for Phase 2.2'),
      );
    },
  );
}
