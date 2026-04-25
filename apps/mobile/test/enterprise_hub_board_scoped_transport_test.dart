import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';

void main() {
  tearDown(() {
    EnterpriseHubConsumerLayer.reset();
    EnterpriseHubPublishedChangeConsumerLayer.reset();
    EnterpriseHubWorkbenchConsumerLayer.reset();
  });

  test('company enterprise list uses board-scoped canonical family', () async {
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
        'GET /api/app/exhibition/enterprise-hub/company/enterprises':
            (AppApiRequest request) async {
              expect(request.uri.queryParameters['boardType'], isNull);
              expect(request.uri.queryParameters['keyword'], '搭建');
              expect(request.uri.queryParameters['page'], '1');
              expect(request.uri.queryParameters['pageSize'], '10');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'recommended': <Object?>[
                    <String, Object?>{
                      'enterpriseId': 'company-1',
                      'boardType': 'company',
                      'name': '西南展览公司',
                      'provinceName': '四川',
                      'cityName': '成都',
                      'primaryBoardLabel': '设计搭建',
                      'secondaryCapabilityLabels': <String>['主场服务'],
                      'shortIntro': '承接设计搭建',
                      'certificationLabel': '已认证',
                      'caseCount': 1,
                      'boardHighlights': <String, Object?>{},
                    },
                  ],
                  'items': <Object?>[
                    <String, Object?>{
                      'enterpriseId': 'company-1',
                      'boardType': 'company',
                      'name': '西南展览公司',
                      'provinceName': '四川',
                      'cityName': '成都',
                      'primaryBoardLabel': '设计搭建',
                      'secondaryCapabilityLabels': <String>['主场服务'],
                      'shortIntro': '承接设计搭建',
                      'certificationLabel': '已认证',
                      'caseCount': 1,
                      'boardHighlights': <String, Object?>{},
                    },
                  ],
                  'pagination': <String, Object?>{
                    'page': 1,
                    'pageSize': 10,
                    'total': 1,
                    'hasMore': false,
                  },
                },
              );
            },
      },
    );
    final consumer = EnterpriseHubConsumerLayer(
      client: AppApiClient(transport: transport),
    );

    final result = await consumer.loadEnterprises(
      const EnterpriseHubListQuery(
        boardType: EnterpriseBoardType.company,
        keyword: '搭建',
      ),
    );

    expect(result.state, AppPageState.content);
    expect(
      result.path,
      '/api/app/exhibition/enterprise-hub/company/enterprises',
    );
  });

  test(
    'supplier enterprise list sends canonical supplyCategory filter',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/exhibition/enterprise-hub/supplier/enterprises':
              (AppApiRequest request) async {
                expect(request.uri.queryParameters['boardType'], isNull);
                expect(
                  request.uri.queryParameters['supplyCategory'],
                  '桁架舞台搭建厂',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'recommended': <Object?>[],
                    'items': <Object?>[],
                    'pagination': <String, Object?>{
                      'page': 1,
                      'pageSize': 10,
                      'total': 0,
                      'hasMore': false,
                    },
                  },
                );
              },
        },
      );
      final consumer = EnterpriseHubConsumerLayer(
        client: AppApiClient(transport: transport),
      );

      final result = await consumer.loadEnterprises(
        const EnterpriseHubListQuery(
          boardType: EnterpriseBoardType.supplier,
          supplyCategory: '桁架舞台搭建厂',
        ),
      );

      expect(result.state, AppPageState.empty);
      expect(
        result.path,
        '/api/app/exhibition/enterprise-hub/supplier/enterprises',
      );
    },
  );

  test(
    'factory application draft create omits applyBoardType in body',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'POST /api/app/exhibition/enterprise-hub/factory/applications':
              (AppApiRequest request) async {
                final body = request.body as Map<String, Object?>;
                expect(body.containsKey('applyBoardType'), isFalse);
                expect(body['applicantName'], '王伟伟');
                expect(body['applicantMobile'], '13800000000');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'applicationId': 'app-1',
                    'enterpriseId': 'factory-1',
                    'applicationStatus': 'draft',
                  },
                );
              },
        },
      );
      final consumer = EnterpriseHubConsumerLayer(
        client: AppApiClient(transport: transport),
      );

      final result = await consumer.createApplication(
        boardType: EnterpriseBoardType.factory,
        applicantName: '王伟伟',
        applicantMobile: '13800000000',
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.path,
        '/api/app/exhibition/enterprise-hub/factory/applications',
      );
    },
  );

  test('supplier workbench uses board-scoped canonical family', () async {
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
        'GET /api/app/exhibition/enterprise-hub/supplier/workbench':
            (AppApiRequest request) async {
              expect(request.uri.queryParameters['boardType'], isNull);
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _buildWorkbenchPayload(boardType: 'supplier'),
              );
            },
      },
    );
    final consumer = EnterpriseHubWorkbenchConsumerLayer(
      client: AppApiClient(transport: transport),
    );

    final result = await consumer.loadWorkbench(
      boardType: EnterpriseBoardType.supplier,
    );

    expect(result.state, AppPageState.content);
    expect(
      result.path,
      '/api/app/exhibition/enterprise-hub/supplier/workbench',
    );
  });

  test(
    'supplier published-change status uses board-scoped canonical family',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/exhibition/enterprise-hub/supplier/enterprises/supplier-1/changes/current/status':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'enterpriseId': 'supplier-1',
                    'changeRequestId': 'change-1',
                    'changeStatus': 'draft',
                  },
                );
              },
        },
      );
      final consumer = EnterpriseHubPublishedChangeConsumerLayer(
        client: AppApiClient(transport: transport),
      );

      final result = await consumer.loadCurrentChangeStatus(
        boardType: EnterpriseBoardType.supplier,
        enterpriseId: 'supplier-1',
      );

      expect(result.state, AppPageState.content);
      expect(
        result.path,
        '/api/app/exhibition/enterprise-hub/supplier/enterprises/supplier-1/changes/current/status',
      );
    },
  );
}

Map<String, Object?> _buildWorkbenchPayload({required String boardType}) {
  return <String, Object?>{
    'organizationId': 'org-1',
    'enterpriseId': 'ent-1',
    'boardType': boardType,
    'latestApplication': const <String, Object?>{
      'applicationId': 'app-1',
      'applicationStatus': 'draft',
    },
    'basic': const <String, Object?>{
      'name': '西南展示档',
      'provinceName': '四川',
      'cityName': '成都',
      'contactVisible': true,
    },
    'boardProfile': const <String, Object?>{},
    'primaryContact': const <String, Object?>{
      'contactName': '王伟伟',
      'isPrimary': true,
      'visibleToPublic': true,
    },
    'cases': const <Object?>[],
    'certification': const <String, Object?>{'certificationStatus': 'approved'},
    'readiness': const <String, Object?>{
      'hasApplication': true,
      'draftEditable': true,
      'basicCompleted': true,
      'profileCompleted': true,
      'hasCase': false,
      'hasContact': true,
      'certificationApproved': true,
      'submitReady': false,
      'blockers': <String>[],
    },
  };
}
