import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_api_entry_mode.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

ExhibitionMobileApp buildVisualDemoApp({required String initialRoute}) {
  const demoBaseUrl = AppApiEntryTarget.sshTunnelBaseUrl;
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapManifest: AppConfigManifest.bootstrapDefaults(),
    bootstrapShellContext: AppShellContextData(
      userId: 'demo-user',
      organizationId: 'org-demo',
      roleKeys: const <String>['buyer_admin'],
      certificationStatus: 'verified',
      membershipStatus: 'active',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
      unreadSummary: const <String, Object?>{'todo': 3, 'notice': 2},
    ),
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(handlers: _exhibitionHandlers()),
      ),
    ),
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(handlers: _messagesHandlers()),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(handlers: _profileHandlers()),
      ),
    ),
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_exhibitionHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/project/detail': _handleProjectDetail,
    'POST /api/app/file/upload/init': _handleUploadInit,
    'POST /api/app/file/upload/confirm': _handleUploadConfirm,
    'GET /api/app/contract/detail': _handleContractDetail,
    'POST /api/app/contract/confirm': _handleContractConfirm,
    'POST /api/app/dispute/open': _handleDisputeOpen,
    'GET /api/app/rating/entry': _handleRatingEntry,
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_messagesHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/message/index': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            _todoItem(
              todoId: 'todo-contract-confirm',
              objectType: 'contract',
              instanceId: 'contract-1',
              actionKey: 'contract.confirm',
              title: '确认合同',
              summary: '请在合同确认页完成这次生效承接。',
              canonicalPath: '/api/app/contract/detail',
              localEntryKey: 'registered.contract.confirm',
              requiredParams: const <String>['orderId'],
              routeParams: const <String, String>{'orderId': 'order-1'},
            ),
            _todoItem(
              todoId: 'todo-rating-submit',
              objectType: 'rating',
              instanceId: 'rating-entry-order-1',
              actionKey: 'rating.submit',
              title: '补齐评价提交',
              summary: '当前评价入口已承接，可继续进入评价提交。',
              canonicalPath: '/api/app/rating/entry',
              localEntryKey: 'registered.rating.submit',
              requiredParams: const <String>['orderId'],
              routeParams: const <String, String>{'orderId': 'order-1'},
            ),
            _todoItem(
              todoId: 'todo-dispute-open',
              objectType: 'dispute',
              instanceId: 'dispute-entry-order-1',
              actionKey: 'dispute.open',
              title: '开启争议入口',
              summary: '当前订单已允许进入争议开启边界页。',
              canonicalPath: '/api/app/order/detail',
              localEntryKey: 'registered.dispute.open',
              requiredParams: const <String>['orderId'],
              routeParams: const <String, String>{'orderId': 'order-1'},
            ),
          ],
          'unreadCount': 5,
        },
      );
    },
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_profileHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/profile/index': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'organization': <String, Object?>{
            'organizationId': 'org-demo',
            'roleKeys': const <String>['buyer_admin'],
            'visibleBuildings': const <String>[
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
  };
}

Future<AppApiResponse> _handleContractDetail(AppApiRequest request) async {
  final orderId = request.uri.queryParameters['orderId'] ?? 'order-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: _contractPayload(
      contractId: 'contract-1',
      orderId: orderId,
      state: 'pending_confirm',
      summaryHeading: '合同重点已整理完成',
    ),
  );
}

Future<AppApiResponse> _handleProjectDetail(AppApiRequest request) async {
  final projectId = request.uri.queryParameters['projectId'] ?? 'project-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'projectId': projectId,
      'projectNo': 'PROJ-20260327-01',
      'title': '上海品牌快闪展台',
      'buildingType': 'exhibition',
      'budgetAmount': 1888,
      'state': 'published',
      'summary': _summary('项目关键信息已承接'),
    },
  );
}

Future<AppApiResponse> _handleContractConfirm(AppApiRequest request) async {
  return AppApiResponse(
    statusCode: 202,
    uri: request.uri,
    body: _contractPayload(
      contractId: 'contract-1',
      orderId: 'order-1',
      state: 'active',
      summaryHeading: '合同确认已完成',
    ),
  );
}

Future<AppApiResponse> _handleDisputeOpen(AppApiRequest request) async {
  final body = request.body;
  final orderId = body is Map<String, Object?> && body['orderId'] is String
      ? body['orderId']! as String
      : 'order-1';
  return AppApiResponse(
    statusCode: 202,
    uri: request.uri,
    body: <String, Object?>{
      'disputeId': 'dispute-1',
      'orderId': orderId,
      'state': 'opened',
      'summary': _summary('争议开启结果已承接'),
    },
  );
}

Future<AppApiResponse> _handleRatingEntry(AppApiRequest request) async {
  final orderId = request.uri.queryParameters['orderId'] ?? 'order-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'orderId': orderId,
      'state': 'draft',
      'summary': _summary('评价入口已就位'),
    },
  );
}

Future<AppApiResponse> _handleUploadInit(AppApiRequest request) async {
  final body = request.body;
  final businessId =
      body is Map<String, Object?> && body['businessId'] is String
      ? body['businessId']! as String
      : 'project-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'uploadSessionId': 'visual-upload-$businessId',
      'directUpload': <String, Object?>{
        'url': 'https://oss.example.com/upload/$businessId',
        'method': 'PUT',
      },
      'confirm': <String, Object?>{'endpoint': '/api/app/file/upload/confirm'},
    },
  );
}

Future<AppApiResponse> _handleUploadConfirm(AppApiRequest request) async {
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: const <String, Object?>{'status': 'bound'},
  );
}

Map<String, Object?> _todoItem({
  required String todoId,
  required String objectType,
  required String instanceId,
  required String actionKey,
  required String title,
  required String summary,
  required String canonicalPath,
  required String localEntryKey,
  required List<String> requiredParams,
  required Map<String, String> routeParams,
}) {
  return <String, Object?>{
    'todoId': todoId,
    'messageType': 'instance_todo',
    'instanceRef': <String, Object?>{
      'objectType': objectType,
      'instanceId': instanceId,
    },
    'actionKey': actionKey,
    'title': title,
    'summary': summary,
    'routeTarget': <String, Object?>{
      'canonicalPath': canonicalPath,
      'localEntryKey': localEntryKey,
      'requiredParams': requiredParams,
      'state': 'enabled',
      'routeParams': routeParams,
    },
    'state': 'pending',
  };
}

Map<String, Object?> _contractPayload({
  required String contractId,
  required String orderId,
  required String state,
  required String summaryHeading,
}) {
  return <String, Object?>{
    'contractId': contractId,
    'orderId': orderId,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

Map<String, Object?> _summary(String heading) {
  return <String, Object?>{'heading': heading};
}
