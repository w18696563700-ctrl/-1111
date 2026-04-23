import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_stage_sources.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';

void main() {
  group('stage load auto source', () {
    test(
      'uses demo only when fake transport is missing the canonical path',
      () async {
        final source = ExhibitionStageLoadAutoSource(
          futureRealLoader: ({bool forceRefresh = false}) async =>
              ExhibitionLoadResult(
                state: AppPageState.errorRetryable,
                method: 'GET',
                path: ExhibitionCanonicalPaths.contractDetail,
                message:
                    'current fake transport did not provide this canonical path',
              ),
          demoBuilder: () => ExhibitionLoadResult(
            state: AppPageState.content,
            method: 'GET',
            path: ExhibitionCanonicalPaths.contractDetail,
            payload: const <String, Object?>{
              'summary': <String, Object?>{'heading': 'demo'},
            },
          ),
        );

        final snapshot = await source.load();

        expect(snapshot.origin, ExhibitionStageDataOrigin.demo);
        expect(snapshot.showsFallbackNotice, isTrue);
        expect(snapshot.futureRealResult?.state, AppPageState.errorRetryable);
        expect(snapshot.result.state, AppPageState.content);
      },
    );

    test(
      'keeps forbidden and unauthorized as future-real controlled states',
      () async {
        for (final state in <AppPageState>[
          AppPageState.forbidden,
          AppPageState.unauthorized,
          AppPageState.notFound,
        ]) {
          final source = ExhibitionStageLoadAutoSource(
            futureRealLoader: ({bool forceRefresh = false}) async =>
                ExhibitionLoadResult(
                  state: state,
                  method: 'GET',
                  path: ExhibitionCanonicalPaths.inspectionDetail,
                  message: 'controlled state',
                ),
            demoBuilder: () => ExhibitionLoadResult(
              state: AppPageState.content,
              method: 'GET',
              path: ExhibitionCanonicalPaths.inspectionDetail,
              payload: const <String, Object?>{
                'summary': <String, Object?>{'heading': 'demo'},
              },
            ),
          );

          final snapshot = await source.load();
          expect(snapshot.origin, ExhibitionStageDataOrigin.futureReal);
          expect(snapshot.result.state, state);
          expect(snapshot.showsFallbackNotice, isFalse);
        }
      },
    );
  });

  group('messages route target registry', () {
    test(
      'keeps inspection and dispute read corridor canonical targets frozen',
      () {
        final inspectionSubmit =
            messagesRegisteredEntryByActionKey['inspection.submit']!;
        final disputeOpen = messagesRegisteredEntryByActionKey['dispute.open']!;
        final clarificationOpen =
            messagesRegisteredEntryByActionKey['project_clarification.open']!;
        final bidThreadOpen =
            messagesRegisteredEntryByActionKey['bid_thread.open']!;
        expect(
          inspectionSubmit.canonicalPath,
          ExhibitionCanonicalPaths.inspectionDetail,
        );
        expect(disputeOpen.canonicalPath, ExhibitionCanonicalPaths.orderDetail);
        expect(
          clarificationOpen.canonicalPath,
          '/api/app/project/clarification/list',
        );
        expect(bidThreadOpen.canonicalPath, '/api/app/bid/thread/detail');
        expect(
          clarificationOpen.localEntryKey,
          'registered.project_clarification.open',
        );
        expect(bidThreadOpen.localEntryKey, 'registered.bid_thread.open');
        expect(clarificationOpen.requiredParams, <String>['projectId']);
        expect(bidThreadOpen.requiredParams, <String>['projectId', 'bidId']);
        expect(
          inspectionSubmit.buildRouteLocation(const <String, String>{
            'milestoneId': 'milestone-1',
          }),
          ExhibitionRoutes.inspectionSubmitWithMilestoneId('milestone-1'),
        );
        expect(
          disputeOpen.buildRouteLocation(const <String, String>{
            'orderId': 'order-1',
          }),
          ExhibitionRoutes.disputeOpenWithOrderId('order-1'),
        );
        expect(
          clarificationOpen.buildRouteLocation(const <String, String>{
            'projectId': 'project-1',
          }),
          ExhibitionRoutes.projectClarificationWithProjectId('project-1'),
        );
        expect(
          bidThreadOpen.buildRouteLocation(const <String, String>{
            'projectId': 'project-1',
            'bidId': 'bid-1',
          }),
          ExhibitionRoutes.bidThreadWithIds(
            projectId: 'project-1',
            bidId: 'bid-1',
          ),
        );
      },
    );
  });
}
