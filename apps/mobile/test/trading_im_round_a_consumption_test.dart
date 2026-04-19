import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/trading_im_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/trading_im_models.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
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
}
