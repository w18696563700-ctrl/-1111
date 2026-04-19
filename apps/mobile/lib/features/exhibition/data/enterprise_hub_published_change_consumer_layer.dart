import 'package:mobile/core/api/app_api_client.dart';
import 'dart:io';

import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';

part 'enterprise_hub_published_change_models.dart';
part 'enterprise_hub_published_change_paths.dart';
part 'enterprise_hub_published_change_parser.dart';
part 'enterprise_hub_published_change_transport.dart';

class EnterpriseHubPublishedChangeConsumerLayer {
  EnterpriseHubPublishedChangeConsumerLayer({AppApiClient? client})
    : _client = client ?? AppApiClient();

  final AppApiClient _client;

  static EnterpriseHubPublishedChangeConsumerLayer _instance =
      EnterpriseHubPublishedChangeConsumerLayer();

  static EnterpriseHubPublishedChangeConsumerLayer get instance => _instance;

  static void install(EnterpriseHubPublishedChangeConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = EnterpriseHubPublishedChangeConsumerLayer();
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubPublishedChangeWorkbenchData>>
  loadCurrentChangeWorkbench({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
  }) {
    final normalizedEnterpriseId = _normalized(enterpriseId);
    if (normalizedEnterpriseId == null) {
      return Future.value(
        EnterpriseHubLoadResult<EnterpriseHubPublishedChangeWorkbenchData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: EnterpriseHubPublishedChangeCanonicalPaths.workbench(boardType),
          message: '缺少 enterpriseId，当前无法读取已发布展示变更工作台。',
        ),
      );
    }

    final canonicalPath =
        EnterpriseHubPublishedChangeCanonicalPaths.workbenchWithEnterpriseId(
          boardType,
          normalizedEnterpriseId,
        );
    return _publishedChangeLoad(
      client: _client,
      method: 'GET',
      canonicalPath: canonicalPath,
      request: () => _client.get(canonicalPath),
      parser: parseEnterpriseHubPublishedChangeWorkbench,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateCurrentChangeBasic({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _publishedChangeAckPut(
      client: _client,
      canonicalPath: EnterpriseHubPublishedChangeCanonicalPaths.basic(
        boardType,
        enterpriseId,
      ),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateCurrentChangeCompanyProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _publishedChangeAckPut(
      client: _client,
      canonicalPath: EnterpriseHubPublishedChangeCanonicalPaths.profile(
        EnterpriseBoardType.company,
        enterpriseId,
      ),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateCurrentChangeFactoryProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _publishedChangeAckPut(
      client: _client,
      canonicalPath: EnterpriseHubPublishedChangeCanonicalPaths.profile(
        EnterpriseBoardType.factory,
        enterpriseId,
      ),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateCurrentChangeSupplierProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _publishedChangeAckPut(
      client: _client,
      canonicalPath: EnterpriseHubPublishedChangeCanonicalPaths.profile(
        EnterpriseBoardType.supplier,
        enterpriseId,
      ),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<EnterpriseHubCaseCreateData>>
  createCurrentChangeCase({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    final canonicalPath = EnterpriseHubPublishedChangeCanonicalPaths.createCase(
      boardType,
      enterpriseId,
    );
    return _publishedChangeSubmit(
      client: _client,
      method: 'POST',
      canonicalPath: canonicalPath,
      request: () => _client.post(canonicalPath, body: body),
      parser: parseEnterpriseHubCaseCreateData,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateCurrentChangeCase({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
    required String caseId,
    required Map<String, Object?> body,
  }) {
    final normalizedCaseId = _normalized(caseId);
    if (normalizedCaseId == null) {
      return Future.value(
        EnterpriseHubActionResult<bool>(
          isSuccess: false,
          method: 'PUT',
          path: EnterpriseHubPublishedChangeCanonicalPaths.workbench(boardType),
          controlledState: AppPageState.errorNonRetryable,
          message: '缺少 caseId，当前无法保存已发布展示案例修改。',
        ),
      );
    }
    return _publishedChangeAckPut(
      client: _client,
      canonicalPath: EnterpriseHubPublishedChangeCanonicalPaths.caseDetail(
        boardType,
        enterpriseId,
        normalizedCaseId,
      ),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> deleteCurrentChangeCase({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
    required String caseId,
  }) {
    return _publishedChangeAckDelete(
      client: _client,
      canonicalPath: EnterpriseHubPublishedChangeCanonicalPaths.caseDetail(
        boardType,
        enterpriseId,
        caseId,
      ),
    );
  }

  Future<EnterpriseHubActionResult<bool>> submitCurrentChange({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
  }) {
    final canonicalPath = EnterpriseHubPublishedChangeCanonicalPaths.submit(
      boardType,
      enterpriseId,
    );
    return _publishedChangeSubmit(
      client: _client,
      method: 'POST',
      canonicalPath: canonicalPath,
      request: () => _client.post(
        canonicalPath,
        body: const <String, Object?>{'confirm': true},
      ),
      parser: (_) => true,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubPublishedChangeStatusData>>
  loadCurrentChangeStatus({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
  }) {
    final normalizedEnterpriseId = _normalized(enterpriseId);
    if (normalizedEnterpriseId == null) {
      return Future.value(
        EnterpriseHubLoadResult<EnterpriseHubPublishedChangeStatusData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: EnterpriseHubPublishedChangeCanonicalPaths.status(boardType),
          message: '缺少 enterpriseId，当前无法读取已发布展示变更状态。',
        ),
      );
    }

    final canonicalPath =
        EnterpriseHubPublishedChangeCanonicalPaths.statusWithEnterpriseId(
          boardType,
          normalizedEnterpriseId,
        );
    return _publishedChangeLoad(
      client: _client,
      method: 'GET',
      canonicalPath: canonicalPath,
      request: () => _client.get(canonicalPath),
      parser: parseEnterpriseHubPublishedChangeStatus,
    );
  }
}
