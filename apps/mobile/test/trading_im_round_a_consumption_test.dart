import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/trading_im_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/trading_im_models.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

Map<String, Object?> _projectDetailPayload({
  required String projectId,
  required String state,
  String? bidId,
  String? tradeTaskId,
}) {
  final payload = <String, Object?>{
    'projectId': projectId,
    'projectNo': 'PROJ-1',
    'title': '展览项目 1',
    'buildingType': 'exhibition',
    'budgetAmount': 1888,
    'state': state,
    'viewerProjectRelation': 'public_viewer',
    'summary': const <String, Object?>{'heading': '当前项目说明'},
  };
  if (bidId != null) {
    payload['bidId'] = bidId;
  }
  if (tradeTaskId != null) {
    payload['tradeTaskId'] = tradeTaskId;
  }
  return payload;
}

void main() {
  test('project clarification consumes frozen list contract', () async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET ${TradingImCanonicalPaths.projectClarificationList}':
                (AppApiRequest request) async {
                  expect(request.uri.queryParameters['projectId'], 'project-1');
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'projectId': 'project-1',
                      'availability': <String, Object?>{
                        'canCreate': true,
                        'reason': 'participant_allowed',
                      },
                      'items': <Object?>[
                        <String, Object?>{
                          'clarificationId': 'clarification-1',
                          'projectId': 'project-1',
                          'authorRole': 'project_owner',
                          'body': '请确认进场时间。',
                          'attachmentFileAssetIds': <Object?>['file-1'],
                          'state': 'active',
                          'createdAt': '2026-04-16T00:00:00Z',
                        },
                      ],
                    },
                  );
                },
          },
    );
    final consumer = TradingImConsumerLayer(client: _client(transport));

    final result = await consumer.loadClarifications(projectId: 'project-1');

    expect(result.state, AppPageState.content);
    expect(result.data?.projectId, 'project-1');
    expect(result.data?.canCreate, isTrue);
    expect(result.data?.items.single.attachmentFileAssetIds, <String>[
      'file-1',
    ]);
  });

  test(
    'bid thread sends only projectId bidId body and FileAsset ids',
    () async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST ${TradingImCanonicalPaths.bidThreadMessageSend}':
                  (AppApiRequest request) async {
                    expect(request.body, <String, Object?>{
                      'projectId': 'project-1',
                      'bidId': 'bid-1',
                      'body': '报价单已更新。',
                      'attachmentFileAssetIds': <String>['file-1'],
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'messageId': 'message-1',
                        'threadId': 'thread-1',
                        'projectId': 'project-1',
                        'bidId': 'bid-1',
                        'senderRole': 'bidder',
                        'body': '报价单已更新。',
                        'attachmentFileAssetIds': <Object?>['file-1'],
                        'createdAt': '2026-04-16T00:01:00Z',
                      },
                    );
                  },
            },
      );
      final consumer = TradingImConsumerLayer(client: _client(transport));

      final result = await consumer.sendBidThreadMessage(
        projectId: 'project-1',
        bidId: 'bid-1',
        body: '报价单已更新。',
        attachmentFileAssetIds: const <String>['file-1'],
      );

      expect(result.isSuccess, isTrue);
      expect(result.data?.messageId, 'message-1');
    },
  );

  test('bid thread detail consumes bounded system seed supplement', () async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET ${TradingImCanonicalPaths.bidThreadDetail}':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'threadId': 'thread-1',
                      'projectId': 'project-1',
                      'bidId': 'bid-1',
                      'participants': <Object?>[
                        <String, Object?>{
                          'participantRole': 'project_owner',
                          'organizationId': 'org-owner-1',
                          'displayName': '重庆项目方',
                          'avatarUrl': null,
                        },
                        <String, Object?>{
                          'participantRole': 'bidder',
                          'organizationId': 'org-bidder-1',
                          'displayName': '杭州搭建公司',
                          'avatarUrl': 'https://example.com/bidder-avatar.png',
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
                          'projectId': 'project-1',
                          'bidId': 'bid-1',
                          'senderRole': 'system_seed',
                          'messageKind': 'system_seed',
                          'systemSeedType': 'bid_submitted',
                          'systemSeedAction': <String, Object?>{
                            'objectType': 'bid_submission_snapshot',
                            'actionKey': 'bid_submission_snapshot.open',
                            'canonicalPath': '/api/app/bid/submission/snapshot',
                            'params': <String, Object?>{
                              'projectId': 'project-1',
                              'bidId': 'bid-1',
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
          },
    );
    final consumer = TradingImConsumerLayer(client: _client(transport));

    final result = await consumer.loadBidThread(
      projectId: 'project-1',
      bidId: 'bid-1',
    );

    expect(result.state, AppPageState.content);
    expect(result.data?.participants.first.displayName, '重庆项目方');
    expect(
      result.data?.participants.last.avatarUrl,
      'https://example.com/bidder-avatar.png',
    );
    expect(result.data?.messages.single.messageKind, 'system_seed');
    expect(result.data?.messages.single.systemSeedType, 'bid_submitted');
    expect(
      result.data?.messages.single.systemSeedAction?.actionKey,
      'bid_submission_snapshot.open',
    );
  });

  test('participant-card consumes bounded read-only contract', () async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET ${TradingImCanonicalPaths.participantCard}':
                (AppApiRequest request) async {
                  expect(request.uri.queryParameters['projectId'], 'project-1');
                  expect(request.uri.queryParameters['bidId'], 'bid-1');
                  expect(
                    request.uri.queryParameters['participantOrganizationId'],
                    'org-bidder-1',
                  );
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'projectId': 'project-1',
                      'bidId': 'bid-1',
                      'participantOrganizationId': 'org-bidder-1',
                      'participantRole': 'bidder',
                      'enterpriseSummary': <String, Object?>{
                        'enterpriseId': 'enterprise-1',
                        'displayName': '杭州搭建公司',
                        'logoUrl': null,
                        'primaryBoardType': 'supplier',
                        'provinceName': '浙江省',
                        'cityName': '杭州市',
                        'verificationStatus': 'approved',
                      },
                      'reviewSummary': <String, Object?>{
                        'avgScore': 4.8,
                        'reviewCount': 12,
                        'keywordTags': <Object?>['响应快', '沟通顺'],
                      },
                      'formalInfoSummary': <String, Object?>{
                        'legalName': '杭州搭建展示有限公司',
                        'businessType': '有限责任公司',
                        'registeredCapital': '500 万人民币',
                        'establishedAt': '2020-04-09',
                        'businessScope': '展览搭建',
                        'certificationStatus': 'approved',
                      },
                    },
                  );
                },
          },
    );
    final consumer = TradingImConsumerLayer(client: _client(transport));

    final result = await consumer.loadParticipantCard(
      projectId: 'project-1',
      bidId: 'bid-1',
      participantOrganizationId: 'org-bidder-1',
    );

    expect(result.state, AppPageState.content);
    expect(result.data?.enterpriseSummary.displayName, '杭州搭建公司');
    expect(result.data?.reviewSummary.keywordTags, <String>['响应快', '沟通顺']);
    expect(result.data?.formalInfoSummary.legalName, '杭州搭建展示有限公司');
  });

  test('unknown contract state enters controlled failure', () async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET ${TradingImCanonicalPaths.projectClarificationList}':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'projectId': 'project-1',
                      'items': <Object?>[
                        <String, Object?>{
                          'clarificationId': 'clarification-1',
                          'projectId': 'project-1',
                          'authorRole': 'project_owner',
                          'body': '内容',
                          'attachmentFileAssetIds': <Object?>[],
                          'state': 'mystery',
                          'createdAt': '2026-04-16T00:00:00Z',
                        },
                      ],
                    },
                  );
                },
          },
    );
    final consumer = TradingImConsumerLayer(client: _client(transport));

    final result = await consumer.loadClarifications(projectId: 'project-1');

    expect(result.state, AppPageState.errorNonRetryable);
    expect(result.message, contains('outside frozen contract'));
  });

  testWidgets('project detail keeps a single bid CTA before bidId exists', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'project-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectDetailPayload(
                  projectId: 'project-1',
                  state: 'published',
                ),
              );
            },
          },
    );
    ExhibitionConsumerLayer.install(
      ExhibitionConsumerLayer(client: _client(transport)),
    );
    addTearDown(ExhibitionConsumerLayer.reset);

    await tester.pumpWidget(
      const MaterialApp(home: ProjectDetailPage(projectId: 'project-1')),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsOneWidget);
    expect(find.text('先参与竞标'), findsNothing);
    expect(find.text('项目沟通'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '项目澄清'), findsNothing);
    expect(find.textContaining('当前请使用上方主入口继续参与竞标'), findsNothing);
  });

  testWidgets('project detail renders P0-Pay read-only status from summary', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/project/detail': (AppApiRequest request) async {
          expect(request.uri.queryParameters['projectId'], 'project-1');
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _projectDetailPayload(
              projectId: 'project-1',
              state: 'published',
              tradeTaskId: 'task-1',
            ),
          );
        },
        'GET ${ExhibitionCanonicalPaths.p0PaySummary('task-1')}':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'taskId': 'task-1',
                  'taskType': 'fixed_price_bid',
                  'platformServiceFee': <String, Object?>{
                    'status': 'authorized',
                    'estimatedFeeAmount': '2400.00',
                  },
                  'inquiryDeposit': null,
                  'contractConfirmation': <String, Object?>{
                    'contractStatus': 'pending',
                  },
                  'messageDisplaySummary': <String, Object?>{
                    'displayAllowed': true,
                    'readOnly': true,
                    'statusTextKey': 'platform_service_fee_authorized',
                    'routeTarget': <String, Object?>{
                      'objectType': 'trade_task',
                      'actionKey': 'p0_pay_summary.read',
                      'canonicalPath':
                          '/api/app/exhibition/trade-tasks/task-1/p0-pay-summary',
                    },
                  },
                  'updatedAt': '2026-05-15T00:00:00Z',
                },
              );
            },
      },
    );
    ExhibitionConsumerLayer.install(
      ExhibitionConsumerLayer(client: _client(transport)),
    );
    addTearDown(ExhibitionConsumerLayer.reset);

    await tester.pumpWidget(
      const MaterialApp(home: ProjectDetailPage(projectId: 'project-1')),
    );
    await tester.pumpAndSettle();
    final requestedPaths = transport.requests.map(
      (AppApiRequest request) => request.canonicalPath,
    );
    expect(requestedPaths, contains(ExhibitionCanonicalPaths.projectDetail));
    expect(
      requestedPaths,
      contains(ExhibitionCanonicalPaths.p0PaySummary('task-1')),
    );

    expect(find.text('P0-Pay 只读状态'), findsOneWidget);
    expect(find.textContaining('平台服务费：已预授权'), findsOneWidget);
    expect(find.textContaining('合同确认：待处理'), findsOneWidget);
    expect(find.textContaining('不执行支付'), findsOneWidget);
    expect(find.textContaining('只读 routeTarget'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '支付'), findsNothing);
  });

  testWidgets(
    'bid thread renders a bounded system seed card and opens bid submission snapshot',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET ${TradingImCanonicalPaths.bidThreadDetail}':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'threadId': 'thread-1',
                        'projectId': 'project-1',
                        'bidId': 'bid-1',
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
                            'projectId': 'project-1',
                            'bidId': 'bid-1',
                            'senderRole': 'system_seed',
                            'messageKind': 'system_seed',
                            'systemSeedType': 'bid_submitted',
                            'systemSeedAction': <String, Object?>{
                              'objectType': 'bid_submission_snapshot',
                              'actionKey': 'bid_submission_snapshot.open',
                              'canonicalPath':
                                  '/api/app/bid/submission/snapshot',
                              'params': <String, Object?>{
                                'projectId': 'project-1',
                                'bidId': 'bid-1',
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
              'GET ${TradingImCanonicalPaths.bidSubmissionSnapshot}':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    expect(request.uri.queryParameters['bidId'], 'bid-1');
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'projectId': 'project-1',
                        'bidId': 'bid-1',
                        'bidder': <String, Object?>{
                          'organizationId': 'org-bidder-1',
                          'displayName': '杭州搭建公司',
                          'avatarUrl': null,
                        },
                        'submittedAt': '2026-04-16T00:00:00Z',
                        'quoteAmount': 8800,
                        'proposalSummary': '先做结构、灯光与现场安装。',
                        'attachmentSummary': <String, Object?>{'count': 3},
                        'attachments': <Object?>[
                          <String, Object?>{
                            'slotKey': 'project_understanding',
                            'slotLabel': '项目理解',
                            'fileAssetId': 'file-understanding-1',
                            'fileKind': 'bid_project_understanding',
                            'mimeType': 'application/pdf',
                          },
                          <String, Object?>{
                            'slotKey': 'quote_sheet',
                            'slotLabel': '报价表',
                            'fileAssetId': 'file-quote-1',
                            'fileKind': 'bid_quote_sheet',
                            'mimeType': 'application/vnd.ms-excel',
                          },
                          <String, Object?>{
                            'slotKey': 'schedule_plan',
                            'slotLabel': '进度安排',
                            'fileAssetId': 'file-schedule-1',
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
              'GET ${TradingImCanonicalPaths.participantCard}':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'projectId': 'project-1',
                        'bidId': 'bid-1',
                        'participantOrganizationId': 'org-bidder-1',
                        'participantRole': 'bidder',
                        'enterpriseSummary': <String, Object?>{
                          'enterpriseId': 'enterprise-bidder-1',
                          'displayName': '杭州搭建公司',
                          'logoUrl': null,
                          'primaryBoardType': 'supplier',
                          'provinceName': '浙江省',
                          'cityName': '杭州市',
                          'verificationStatus': 'approved',
                        },
                        'reviewSummary': <String, Object?>{
                          'avgScore': 4.8,
                          'reviewCount': 12,
                          'keywordTags': <Object?>['响应快'],
                        },
                        'formalInfoSummary': <String, Object?>{
                          'legalName': '杭州搭建展示有限公司',
                          'businessType': '有限责任公司',
                          'registeredCapital': '500 万人民币',
                          'establishedAt': '2020-04-09',
                          'businessScope': '展览搭建',
                          'certificationStatus': 'approved',
                        },
                      },
                    );
                  },
            },
      );
      TradingImConsumerLayer.install(
        TradingImConsumerLayer(client: _client(transport)),
      );
      addTearDown(TradingImConsumerLayer.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidThreadPage(projectId: 'project-1', bidId: 'bid-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('点击查看'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      final viewSnapshotFinder = find.widgetWithText(FilledButton, '点击查看');
      expect(viewSnapshotFinder, findsOneWidget);

      await tester.ensureVisible(viewSnapshotFinder);
      await tester.pumpAndSettle();
      await tester.tap(viewSnapshotFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('竞标摘要'), findsOneWidget);
      expect(find.text('杭州搭建公司'), findsOneWidget);
      expect(find.textContaining('报价金额：¥8800'), findsOneWidget);
      expect(find.textContaining('附件摘要：已确认 3 份附件'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('项目理解'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('项目理解'), findsOneWidget);
      expect(find.text('报价表'), findsOneWidget);
      expect(find.text('进度安排'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, '查看竞标方名片'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(OutlinedButton, '查看竞标方名片'));
      await tester.pumpAndSettle();
      expect(find.text('合作方名片'), findsOneWidget);
      await tester.tap(find.byTooltip('关闭').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, '查看附件').first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.widgetWithText(OutlinedButton, '查看附件'), findsNWidgets(3));
    },
  );

  testWidgets('bid thread participant click opens bounded participant-card', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET ${TradingImCanonicalPaths.bidThreadDetail}':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'threadId': 'thread-1',
                      'projectId': 'project-1',
                      'bidId': 'bid-1',
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
                      'messages': <Object?>[],
                      'confirmationCards': <Object?>[],
                    },
                  );
                },
            'GET ${TradingImCanonicalPaths.participantCard}':
                (AppApiRequest request) async {
                  final participantOrganizationId =
                      request.uri.queryParameters['participantOrganizationId'];
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'projectId': 'project-1',
                      'bidId': 'bid-1',
                      'participantOrganizationId': participantOrganizationId,
                      'participantRole':
                          participantOrganizationId == 'org-owner-1'
                          ? 'project_owner'
                          : 'bidder',
                      'enterpriseSummary': <String, Object?>{
                        'enterpriseId':
                            participantOrganizationId == 'org-owner-1'
                            ? 'enterprise-owner-1'
                            : 'enterprise-bidder-1',
                        'displayName':
                            participantOrganizationId == 'org-owner-1'
                            ? '重庆项目方'
                            : '杭州搭建公司',
                        'logoUrl': null,
                        'primaryBoardType':
                            participantOrganizationId == 'org-owner-1'
                            ? 'company'
                            : 'supplier',
                        'provinceName':
                            participantOrganizationId == 'org-owner-1'
                            ? '重庆市'
                            : '浙江省',
                        'cityName': participantOrganizationId == 'org-owner-1'
                            ? '重庆市'
                            : '杭州市',
                        'verificationStatus': 'approved',
                      },
                      'reviewSummary': <String, Object?>{
                        'avgScore': 4.8,
                        'reviewCount': 12,
                        'keywordTags': <Object?>['响应快'],
                      },
                      'formalInfoSummary': <String, Object?>{
                        'legalName': participantOrganizationId == 'org-owner-1'
                            ? '重庆项目管理有限公司'
                            : '杭州搭建展示有限公司',
                        'businessType': '有限责任公司',
                        'registeredCapital': '500 万人民币',
                        'establishedAt': '2020-04-09',
                        'businessScope': '展览搭建',
                        'certificationStatus': 'approved',
                      },
                    },
                  );
                },
          },
    );
    TradingImConsumerLayer.install(
      TradingImConsumerLayer(client: _client(transport)),
    );
    addTearDown(TradingImConsumerLayer.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: BidThreadPage(projectId: 'project-1', bidId: 'bid-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('杭州搭建公司'), findsOneWidget);
    await tester.tap(find.text('杭州搭建公司'));
    await tester.pumpAndSettle();

    expect(find.text('合作方名片'), findsOneWidget);
    expect(find.text('平台类型：供应方'), findsOneWidget);
    expect(find.text('所在地区：浙江省 / 杭州市'), findsOneWidget);
    expect(find.text('认证状态：认证通过'), findsOneWidget);
    expect(find.textContaining('法定名称：杭州搭建展示有限公司'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('正式认证摘要'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('正式认证摘要'), findsOneWidget);
    expect(find.text('工商类型：有限责任公司'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('企查查'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('企查查'), findsOneWidget);
    expect(find.text('合作前建议先查看对方的'), findsOneWidget);
    expect(find.text('信息，'), findsOneWidget);
    expect(find.text('并在平台内保留关键沟通证据记录。'), findsOneWidget);
  });
}
