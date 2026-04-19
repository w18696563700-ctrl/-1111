import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _summary([String heading = 'summary']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _publicProjectDetail({
  required String projectId,
  required String state,
  required String viewerProjectRelation,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': 'PROJ-1',
    'title': '展会项目 1',
    'buildingType': 'exhibition',
    'budgetAmount': 1200,
    'state': state,
    'summary': _summary('project'),
    'viewerProjectRelation': viewerProjectRelation,
  };
}

Map<String, Object?> _privateProgress({
  required bool hasAcceptedOrder,
  String? orderStatus,
  String? contractStatus,
}) {
  return <String, Object?>{
    'hasAcceptedOrder': hasAcceptedOrder,
    'orderStatus': orderStatus,
    'contractStatus': contractStatus,
    'fulfillmentStatus': null,
    'acceptanceStatus': null,
    'afterSalesOrDisputeStatus': null,
    'formalCompletionStatus': 'not_formally_completed',
    'evaluationStatus': 'not_eligible',
  };
}

Map<String, Object?> _myProjectDetailPayload({
  required String projectId,
  required String state,
  required bool hasAcceptedOrder,
  String? orderStatus,
  String? contractStatus,
}) {
  return <String, Object?>{
    'publicProject': _publicProjectDetail(
      projectId: projectId,
      state: state,
      viewerProjectRelation: 'owner',
    ),
    'privateProgress': _privateProgress(
      hasAcceptedOrder: hasAcceptedOrder,
      orderStatus: orderStatus,
      contractStatus: contractStatus,
    ),
  };
}

Map<String, Object?> _myProjectListPayload({
  required String projectId,
  required String projectState,
}) {
  return <String, Object?>{
    'ongoingProjects': <Object?>[
      <String, Object?>{
        'publicProject': <String, Object?>{
          'projectId': projectId,
          'projectNo': 'PROJ-1',
          'title': '展会项目 1',
          'buildingType': 'exhibition',
          'budgetAmount': 1200,
          'state': projectState,
          'summary': _summary('my-project'),
        },
        'privateSummary': _privateProgress(
          hasAcceptedOrder: false,
          orderStatus: null,
          contractStatus: null,
        ),
      },
    ],
    'historicalProjects': <Object?>[],
  };
}

Map<String, Object?> _projectListPayload({
  required String projectId,
  required String state,
  required String viewerProjectRelation,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': 'PROJ-1',
    'title': '展会项目 1',
    'buildingType': 'exhibition',
    'budgetAmount': 1200,
    'state': state,
    'summary': _summary('project'),
    'viewerProjectRelation': viewerProjectRelation,
  };
}

Map<String, Object?> _seatPayload({
  required String projectId,
  required String bidId,
  required String state,
  String? seatId,
  String? releasedAt,
}) {
  return <String, Object?>{
    'seatId': seatId,
    'projectId': projectId,
    'bidId': bidId,
    'state': state,
    'expiresAt': '2026-04-01T12:00:00Z',
    'releasedAt': releasedAt,
  };
}

Map<String, Object?> _completenessPayload({
  required String projectId,
  required String bidId,
  required String state,
  required List<String> missingItems,
}) {
  return <String, Object?>{
    'bidId': bidId,
    'projectId': projectId,
    'state': state,
    'missingItems': missingItems,
    'quoteAmountReady': !missingItems.contains('quoteAmount'),
    'proposalSummaryReady': !missingItems.contains('proposalSummary'),
  };
}

Map<String, Object?> _projectAttachmentsPayload({required String projectId}) {
  return <String, Object?>{'projectId': projectId, 'attachments': <Object?>[]};
}

Map<String, Object?> _submitBidPayload({
  required String projectId,
  required String bidId,
}) {
  return <String, Object?>{'projectId': projectId, 'bidId': bidId};
}

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required FakeAppApiTransport transport,
  required List<String> roleKeys,
}) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'bid-seat-access',
      refreshToken: 'bid-seat-refresh',
      expiresInSeconds: 3600,
      deviceId: 'bid-seat-device',
    );

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapShellContext: AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      roleKeys: roleKeys,
      certificationStatus: 'approved',
      membershipStatus: 'active',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    ),
    sessionStore: sessionStore,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_ownerHandlers({
  required String seatState,
  required String completenessState,
  required List<String> missingItems,
}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/my/projects/project-1': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _myProjectDetailPayload(
            projectId: 'project-1',
            state: 'published',
            hasAcceptedOrder: false,
          ),
        ),
    'GET /api/app/my/projects/project-1/attachments':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _projectAttachmentsPayload(projectId: 'project-1'),
        ),
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_bidderHandlers({
  required String seatState,
  required String completenessState,
  required List<String> missingItems,
  String? releasedAt,
}) {
  var currentSeatState = seatState;
  var currentReleasedAt = releasedAt;

  AppApiResponse seatStatusResponse(AppApiRequest request) {
    return AppApiResponse(
      statusCode: 200,
      uri: request.uri,
      body: _seatPayload(
        projectId: 'project-1',
        bidId: 'bid-1',
        state: currentSeatState,
        seatId: currentSeatState == 'available' ? null : 'seat-1',
        releasedAt: currentReleasedAt,
      ),
    );
  }

  AppApiResponse lockResponse(AppApiRequest request) {
    currentSeatState = 'locked';
    currentReleasedAt = null;
    return AppApiResponse(
      statusCode: 200,
      uri: request.uri,
      body: _seatPayload(
        projectId: 'project-1',
        bidId: 'bid-1',
        state: 'locked',
        seatId: 'seat-1',
        releasedAt: null,
      ),
    );
  }

  AppApiResponse releaseResponse(AppApiRequest request) {
    currentSeatState = 'released';
    currentReleasedAt = '2026-04-01T12:30:00Z';
    return AppApiResponse(
      statusCode: 200,
      uri: request.uri,
      body: _seatPayload(
        projectId: 'project-1',
        bidId: 'bid-1',
        state: 'released',
        seatId: 'seat-1',
        releasedAt: currentReleasedAt,
      ),
    );
  }

  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/project/detail': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _projectListPayload(
            projectId: 'project-1',
            state: 'published',
            viewerProjectRelation: 'non_owner',
          ),
        ),
    'POST /api/app/bid/submit': (AppApiRequest request) async => AppApiResponse(
      statusCode: 200,
      uri: request.uri,
      body: _submitBidPayload(projectId: 'project-1', bidId: 'bid-1'),
    ),
    'GET /api/app/bid/seat/status': (AppApiRequest request) async =>
        seatStatusResponse(request),
    'POST /api/app/bid/seat/lock': (AppApiRequest request) async =>
        lockResponse(request),
    'POST /api/app/bid/seat/release': (AppApiRequest request) async =>
        releaseResponse(request),
    'GET /api/app/bid/package-completeness': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _completenessPayload(
            projectId: 'project-1',
            bidId: 'bid-1',
            state: completenessState,
            missingItems: missingItems,
          ),
        ),
    'GET /api/app/my/projects': (AppApiRequest request) async => AppApiResponse(
      statusCode: 200,
      uri: request.uri,
      body: _myProjectListPayload(
        projectId: 'project-1',
        projectState: 'published',
      ),
    ),
  };
}

Future<void> _pumpRoute(
  WidgetTester tester, {
  required String initialRoute,
  required FakeAppApiTransport transport,
  required List<String> roleKeys,
}) async {
  await tester.pumpWidget(
    _buildApp(
      initialRoute: initialRoute,
      transport: transport,
      roleKeys: roleKeys,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  final finder = find.text(text, skipOffstage: false);
  final scrollables = find.byType(Scrollable);
  final count = scrollables.evaluate().length;
  for (var index = 0; index < count; index += 1) {
    try {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: scrollables.at(index),
      );
      await tester.pumpAndSettle();
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    } on TestFailure {
      continue;
    }
  }
}

Future<void> _submitBid(WidgetTester tester) async {
  final textFields = find.byType(TextField);
  expect(textFields, findsNWidgets(2));
  await tester.enterText(textFields.at(0), '1200');
  await tester.enterText(textFields.at(1), '先完成展台结构、照明和基础安装');
  await _scrollToText(tester, '提交竞标');
  final submitButton = find.text('提交竞标', skipOffstage: false);
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> _tapSeatAction(WidgetTester tester, String label) async {
  final finder = find.text(label, skipOffstage: false);
  await _scrollToText(tester, label);
  expect(finder, findsWidgets);
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'buyer/detail page surfaces compare not ready instead of fake seat completeness consumption',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: _ownerHandlers(
          seatState: 'available',
          completenessState: 'incomplete',
          missingItems: const <String>['quoteAmount', 'proposalSummary'],
        ),
      );

      await _pumpRoute(
        tester,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-1',
        ),
        transport: transport,
        roleKeys: const <String>['buyer_admin'],
      );

      await _scrollToText(tester, '当前比选未准备好');
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        isNot(contains('GET /api/app/bid/result')),
      );
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        isNot(contains('GET /api/app/bid/seat/status')),
      );
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        isNot(contains('GET /api/app/bid/package-completeness')),
      );
      expect(find.text('当前比选状态', skipOffstage: false), findsWidgets);
      expect(
        find.textContaining(
          'compare_not_ready / not_visible',
          skipOffstage: false,
        ),
        findsWidgets,
      );
      expect(find.text('当前候选席位不可见', skipOffstage: false), findsWidgets);
      expect(find.text('席位状态', skipOffstage: false), findsNothing);
      expect(find.text('资料完整度', skipOffstage: false), findsNothing);
    },
  );

  testWidgets(
    'bidder submit page consumes explicit bid id and tolerates available seat without seat id',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: _bidderHandlers(
          seatState: 'available',
          completenessState: 'incomplete',
          missingItems: const <String>['proposalSummary'],
        ),
      );

      await _pumpRoute(
        tester,
        initialRoute: ExhibitionRoutes.bidSubmitWithProjectId('project-1'),
        transport: transport,
        roleKeys: const <String>['supplier_admin'],
      );

      await _submitBid(tester);
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        contains('POST /api/app/bid/submit'),
      );
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        contains('GET /api/app/bid/seat/status'),
      );
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        contains('GET /api/app/bid/package-completeness'),
      );
      final initialSeatProjection = await ExhibitionConsumerLayer.instance
          .loadBidSeatStatus(
            projectId: 'project-1',
            bidId: 'bid-1',
            forceRefresh: true,
          );
      expect(initialSeatProjection.state, AppPageState.content);
      final initialSeatProjectionPayload =
          initialSeatProjection.payload as Map<String, Object?>;
      expect(initialSeatProjectionPayload['seatId'], isNull);
      expect(initialSeatProjectionPayload['state'], 'available');
      await _scrollToText(tester, '锁定候选席位');
      expect(find.text('锁定候选席位', skipOffstage: false), findsWidgets);
      await _tapSeatAction(tester, '锁定候选席位');
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        contains('POST /api/app/bid/seat/lock'),
      );
      final refreshedSeatProjection = await ExhibitionConsumerLayer.instance
          .loadBidSeatStatus(
            projectId: 'project-1',
            bidId: 'bid-1',
            forceRefresh: true,
          );
      expect(refreshedSeatProjection.state, AppPageState.content);
      expect(
        (refreshedSeatProjection.payload as Map<String, Object?>)['state'],
        'locked',
      );
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.method.name.toUpperCase() == 'GET' &&
                  request.canonicalPath == '/api/app/bid/seat/status',
            )
            .length,
        greaterThanOrEqualTo(2),
      );
      expect(find.text('释放候选席位', skipOffstage: false), findsWidgets);
      final completenessProjection = await ExhibitionConsumerLayer.instance
          .loadBidPackageCompleteness(
            projectId: 'project-1',
            bidId: 'bid-1',
            forceRefresh: true,
          );
      expect(completenessProjection.state, AppPageState.content);
      final completenessProjectionPayload =
          completenessProjection.payload as Map<String, Object?>;
      expect(completenessProjectionPayload['state'], 'incomplete');
      expect(
        (completenessProjectionPayload['missingItems'] as List<Object?>)
            .cast<String>(),
        contains('proposalSummary'),
      );
      await _scrollToText(tester, '席位状态');
      expect(find.text('席位状态', skipOffstage: false), findsWidgets);
      expect(find.text('席位 ID', skipOffstage: false), findsNothing);
      expect(find.text('资料完整度', skipOffstage: false), findsWidgets);
    },
  );

  testWidgets(
    'bidder submit page exposes release seat CTA for locked seat and refreshes after release',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: _bidderHandlers(
          seatState: 'locked',
          completenessState: 'incomplete',
          missingItems: const <String>['proposalSummary'],
        ),
      );

      await _pumpRoute(
        tester,
        initialRoute: ExhibitionRoutes.bidSubmitWithProjectId('project-1'),
        transport: transport,
        roleKeys: const <String>['supplier_admin'],
      );

      await _submitBid(tester);
      await _scrollToText(tester, '释放候选席位');
      expect(find.text('释放候选席位', skipOffstage: false), findsWidgets);
      await _tapSeatAction(tester, '释放候选席位');
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        contains('POST /api/app/bid/seat/release'),
      );
      final refreshedSeatProjection = await ExhibitionConsumerLayer.instance
          .loadBidSeatStatus(
            projectId: 'project-1',
            bidId: 'bid-1',
            forceRefresh: true,
          );
      expect(refreshedSeatProjection.state, AppPageState.content);
      expect(
        (refreshedSeatProjection.payload as Map<String, Object?>)['state'],
        'released',
      );
      expect(find.text('重新锁定候选席位', skipOffstage: false), findsWidgets);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.method.name.toUpperCase() == 'GET' &&
                  request.canonicalPath == '/api/app/bid/seat/status',
            )
            .length,
        greaterThanOrEqualTo(2),
      );
      expect(find.text('重新锁定候选席位', skipOffstage: false), findsWidgets);
    },
  );

  testWidgets(
    'bidder submit page surfaces timed out seat state after explicit bid submit',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: _bidderHandlers(
          seatState: 'timed_out',
          completenessState: 'incomplete',
          missingItems: const <String>['proposalSummary'],
        ),
      );

      await _pumpRoute(
        tester,
        initialRoute: ExhibitionRoutes.bidSubmitWithProjectId('project-1'),
        transport: transport,
        roleKeys: const <String>['supplier_admin'],
      );

      await _submitBid(tester);
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        contains('GET /api/app/bid/seat/status'),
      );
      final seatProjection = await ExhibitionConsumerLayer.instance
          .loadBidSeatStatus(
            projectId: 'project-1',
            bidId: 'bid-1',
            forceRefresh: true,
          );
      expect(seatProjection.state, AppPageState.content);
      final seatProjectionPayload =
          seatProjection.payload as Map<String, Object?>;
      expect(seatProjectionPayload['state'], 'timed_out');
      await _scrollToText(tester, '席位状态');
      expect(find.text('席位状态', skipOffstage: false), findsWidgets);
      expect(find.text('锁定候选席位', skipOffstage: false), findsNothing);
      expect(find.text('释放候选席位', skipOffstage: false), findsNothing);
      expect(find.text('重新读取席位状态', skipOffstage: false), findsWidgets);
      expect(find.text('资料完整度', skipOffstage: false), findsWidgets);
    },
  );

  testWidgets(
    'bidder submit page surfaces released seat state after explicit bid submit',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: _bidderHandlers(
          seatState: 'released',
          completenessState: 'complete',
          missingItems: const <String>[],
          releasedAt: '2026-04-01T12:30:00Z',
        ),
      );

      await _pumpRoute(
        tester,
        initialRoute: ExhibitionRoutes.bidSubmitWithProjectId('project-1'),
        transport: transport,
        roleKeys: const <String>['supplier_admin'],
      );

      await _submitBid(tester);
      expect(
        transport.requests.map(
          (AppApiRequest request) =>
              '${request.method.name.toUpperCase()} ${request.canonicalPath}',
        ),
        contains('GET /api/app/bid/seat/status'),
      );
      final seatProjection = await ExhibitionConsumerLayer.instance
          .loadBidSeatStatus(
            projectId: 'project-1',
            bidId: 'bid-1',
            forceRefresh: true,
          );
      expect(seatProjection.state, AppPageState.content);
      final seatProjectionPayload =
          seatProjection.payload as Map<String, Object?>;
      expect(seatProjectionPayload['state'], 'released');
      await _scrollToText(tester, '席位状态');
      expect(find.text('锁定候选席位', skipOffstage: false), findsNothing);
      expect(find.text('释放候选席位', skipOffstage: false), findsNothing);
      expect(find.text('资料完整度', skipOffstage: false), findsWidgets);
    },
  );
}
