import 'dart:convert';
import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/protected_app_request.dart';

part 'commands/bid_submit_command.dart';
part 'commands/bid_award_command.dart';
part 'commands/contract_amend_command.dart';
part 'commands/contract_confirm_command.dart';
part 'commands/dispute_open_command.dart';
part 'commands/dispute_withdraw_command.dart';
part 'commands/inspection_recheck_command.dart';
part 'commands/inspection_submit_command.dart';
part 'commands/milestone_submit_command.dart';
part 'commands/order_completion_command.dart';
part 'commands/project_attachment_bind_command.dart';
part 'commands/project_create_command.dart';
part 'commands/project_lifecycle_action_command.dart';
part 'commands/p0_pay_commands.dart';
part 'commands/project_save_command.dart';
part 'commands/rating_submit_command.dart';
part 'commands/upload_init_command.dart';
part 'models/exhibition_action_result.dart';
part 'models/exhibition_load_result.dart';
part 'models/p0_pay_payment_polling.dart';
part 'models/project_attachment_read_models.dart';
part 'models/project_bid_material_read_models.dart';
part 'models/project_public_resource_read_models.dart';
part 'models/upload_directive.dart';
part 'models/upload_flow_result.dart';
part 'services/exhibition_action_service.dart';
part 'services/exhibition_canonical_paths.dart';
part 'services/p0_pay_consumer_service.dart';
part 'services/exhibition_contract_mapper.dart';
part 'services/my_project_contract_mapper.dart';
part 'services/my_bid_contract_mapper.dart';
part 'services/exhibition_entry_contract_validation.dart';
part 'services/exhibition_contract_validation.dart';
part 'services/my_project_contract_validation.dart';
part 'services/my_bid_contract_validation.dart';
part 'services/exhibition_contract_validation_base.dart';
part 'services/exhibition_load_service.dart';
part 'services/my_bid_load_service.dart';
part 'services/exhibition_upload_service.dart';
part 'services/project_attachment_action_service.dart';
part 'services/project_attachment_contract_mapper.dart';
part 'services/project_attachment_contract_validation.dart';
part 'services/project_attachment_load_service.dart';
part 'services/project_bid_material_contract_mapper.dart';
part 'services/project_bid_material_contract_validation.dart';
part 'services/project_bid_material_load_service.dart';
part 'services/project_public_resource_action_service.dart';
part 'services/project_public_resource_contract_mapper.dart';
part 'services/project_public_resource_contract_validation.dart';
part 'services/project_public_resource_load_service.dart';

const String _bidSeatLockPath = '/api/app/bid/seat/lock';
const String _bidSeatReleasePath = '/api/app/bid/seat/release';
const String _bidSeatStatusPath = '/api/app/bid/seat/status';
const String _bidPackageCompletenessPath = '/api/app/bid/package-completeness';

String? _normalizeId(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class ExhibitionConsumerLayer {
  ExhibitionConsumerLayer._(this._client)
    : _loadService = _ExhibitionLoadService(_client),
      _actionService = _ExhibitionActionService(_client),
      _uploadService = _ExhibitionUploadService(_client);

  factory ExhibitionConsumerLayer({AppApiClient? client}) {
    return ExhibitionConsumerLayer._(client ?? AppApiClient());
  }

  static ExhibitionConsumerLayer _instance = ExhibitionConsumerLayer();

  static ExhibitionConsumerLayer get instance => _instance;

  static void install(ExhibitionConsumerLayer consumerLayer) {
    if (!identical(_instance, consumerLayer)) {
      _instance.dispose();
    }
    _instance = consumerLayer;
  }

  static void reset() {
    _instance.dispose();
    _instance = ExhibitionConsumerLayer();
  }

  final AppApiClient _client;
  final _ExhibitionLoadService _loadService;
  final _ExhibitionActionService _actionService;
  final _ExhibitionUploadService _uploadService;

  String get configuredBaseUrl => _client.config.baseUrl;

  void dispose() {}

  Future<ExhibitionLoadResult> loadProjectList({
    bool forceRefresh = false,
    String? provinceCode,
    String? cityCode,
    String? areaBucket,
    String? budgetBucket,
  }) {
    return _loadService.loadProjectList(
      forceRefresh: forceRefresh,
      provinceCode: provinceCode,
      cityCode: cityCode,
      areaBucket: areaBucket,
      budgetBucket: budgetBucket,
    );
  }

  Future<ExhibitionLoadResult> loadMyProjectList({bool forceRefresh = false}) {
    return _loadService.loadMyProjectList(forceRefresh: forceRefresh);
  }

  Future<ExhibitionLoadResult> loadMyBidList({bool forceRefresh = false}) {
    return _loadService.loadMyBidList(forceRefresh: forceRefresh);
  }

  void invalidateMyProjectList() {
    _loadService.invalidateMyProjectList();
  }

  Future<ExhibitionLoadResult> loadProjectDetail({
    required String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectDetail(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadProjectEditDetail({
    required String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectEditDetail(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadMyProjectDetail({
    required String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadMyProjectDetail(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionActionResult> deleteMyProject({required String? projectId}) {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return Future<ExhibitionActionResult>.value(
        ExhibitionActionResult(
          method: 'DELETE',
          path: ExhibitionCanonicalPaths.myProjectDetailPattern,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          errorCode: 'AUTH_RESOURCE_UNAVAILABLE',
          message: '当前项目不可用。',
        ),
      );
    }

    return _actionService.deleteMyProject(projectId: normalizedProjectId);
  }

  Future<ExhibitionLoadResult> loadProjectAttachments({
    required String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectAttachments(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  void invalidateProjectAttachments({required String? projectId}) {
    _loadService.invalidateProjectAttachments(projectId: projectId);
  }

  Future<ExhibitionLoadResult> loadProjectPublicResources({
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectPublicResources(forceRefresh: forceRefresh);
  }

  void invalidateProjectPublicResources() {
    _loadService.invalidateProjectPublicResources();
  }

  Future<ExhibitionLoadResult> loadProjectBidMaterials({
    required String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectBidMaterials(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  void invalidateProjectBidMaterials({required String? projectId}) {
    _loadService.invalidateProjectBidMaterials(projectId: projectId);
  }

  Future<ExhibitionLoadResult> loadOrderDetail({
    required String? orderId,
    String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadOrderDetail(
      orderId: orderId,
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadContractDetail({
    required String? orderId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadContractDetail(
      orderId: orderId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadMilestoneList({
    required String? orderId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadMilestoneList(
      orderId: orderId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadInspectionDetail({
    required String? milestoneId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadInspectionDetail(
      milestoneId: milestoneId,
      forceRefresh: forceRefresh,
    );
  }

  void invalidateInspectionDetail({required String? milestoneId}) {
    _loadService.invalidateInspectionDetail(milestoneId: milestoneId);
  }

  Future<ExhibitionLoadResult> loadRatingEntry({
    required String? orderId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadRatingEntry(
      orderId: orderId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadProjectCounterpartyRatingEntry({
    required String? orderId,
    required String? projectId,
    required String? rateeOrganizationId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectCounterpartyRatingEntry(
      orderId: orderId,
      projectId: projectId,
      rateeOrganizationId: rateeOrganizationId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadBidResult({
    required String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadBidResult(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadBidSeatStatus({
    required String? projectId,
    required String? bidId,
    bool forceRefresh = false,
  }) {
    return _loadBidProjection(
      _bidSeatStatusPath,
      projectId: projectId,
      bidId: bidId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadBidPackageCompleteness({
    required String? projectId,
    required String? bidId,
    bool forceRefresh = false,
  }) {
    return _loadBidProjection(
      _bidPackageCompletenessPath,
      projectId: projectId,
      bidId: bidId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionActionResult> createProject(ProjectCreateCommand command) {
    return _actionService.createProject(command);
  }

  Future<ExhibitionActionResult> saveProject(ProjectSaveCommand command) {
    return _actionService.saveProject(command);
  }

  Future<ExhibitionActionResult> submitProject(
    ProjectLifecycleActionCommand command,
  ) {
    return _actionService.submitProject(command);
  }

  Future<ExhibitionActionResult> publishProject(
    ProjectLifecycleActionCommand command,
  ) {
    return _actionService.publishProject(command);
  }

  Future<ExhibitionActionResult> withdrawProject({required String? projectId}) {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return Future<ExhibitionActionResult>.value(
        ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.projectWithdraw,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          errorCode: 'AUTH_RESOURCE_UNAVAILABLE',
          message: '当前项目不可用。',
        ),
      );
    }

    return _actionService.withdrawProject(
      ProjectLifecycleActionCommand(projectId: normalizedProjectId),
    );
  }

  Future<ExhibitionActionResult> archiveProject({required String? projectId}) {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return Future<ExhibitionActionResult>.value(
        ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.projectArchive,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          errorCode: 'AUTH_RESOURCE_UNAVAILABLE',
          message: '当前项目不可用。',
        ),
      );
    }

    return _actionService.archiveProject(
      ProjectLifecycleActionCommand(projectId: normalizedProjectId),
    );
  }

  Future<ExhibitionActionResult> closeProject({required String? projectId}) {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return Future<ExhibitionActionResult>.value(
        ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.projectClose,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          errorCode: 'AUTH_RESOURCE_UNAVAILABLE',
          message: '当前项目不可用。',
        ),
      );
    }

    return _actionService.closeProject(
      ProjectLifecycleActionCommand(projectId: normalizedProjectId),
    );
  }

  Future<ExhibitionActionResult> submitBid(BidSubmitCommand command) {
    return _actionService.submitBid(command);
  }

  Future<ExhibitionActionResult> lockBidSeat({
    required String projectId,
    required String bidId,
  }) {
    return _actionService.lockBidSeat(projectId: projectId, bidId: bidId);
  }

  Future<ExhibitionActionResult> releaseBidSeat({
    required String projectId,
    required String bidId,
  }) {
    return _actionService.releaseBidSeat(projectId: projectId, bidId: bidId);
  }

  Future<ExhibitionActionResult> awardBid(BidAwardCommand command) {
    return _actionService.awardBid(command);
  }

  Future<ExhibitionActionResult> selectBidAndCreateOrder(
    BidSelectAndCreateOrderCommand command,
  ) {
    return _actionService.selectBidAndCreateOrder(command);
  }

  Future<ExhibitionActionResult> confirmContract(
    ContractConfirmCommand command,
  ) {
    return _actionService.confirmContract(command);
  }

  Future<ExhibitionActionResult> amendContract(ContractAmendCommand command) {
    return _actionService.amendContract(command);
  }

  Future<ExhibitionActionResult> requestOrderCompletion(
    OrderCompletionRequestCommand command,
  ) {
    return _actionService.requestOrderCompletion(command);
  }

  Future<ExhibitionActionResult> confirmOrderCompletion(
    OrderCompletionConfirmCommand command,
  ) {
    return _actionService.confirmOrderCompletion(command);
  }

  Future<ExhibitionActionResult> rejectOrderCompletion(
    OrderCompletionRejectCommand command,
  ) {
    return _actionService.rejectOrderCompletion(command);
  }

  Future<ExhibitionActionResult> submitMilestone(
    MilestoneSubmitCommand command,
  ) {
    return _actionService.submitMilestone(command);
  }

  Future<ExhibitionActionResult> submitInspection(
    InspectionSubmitCommand command,
  ) {
    return _actionService.submitInspection(command);
  }

  Future<ExhibitionActionResult> recheckInspection(
    InspectionRecheckCommand command,
  ) {
    return _actionService.recheckInspection(command);
  }

  Future<ExhibitionActionResult> openDispute(DisputeOpenCommand command) {
    return _actionService.openDispute(command);
  }

  Future<ExhibitionActionResult> withdrawDispute(
    DisputeWithdrawCommand command,
  ) {
    return _actionService.withdrawDispute(command);
  }

  Future<ExhibitionActionResult> submitRating(RatingSubmitCommand command) {
    return _actionService.submitRating(command);
  }

  Future<ExhibitionActionResult> submitProjectCounterpartyRating(
    ProjectCounterpartyRatingSubmitCommand command,
  ) {
    return _actionService.submitProjectCounterpartyRating(command);
  }

  Future<ExhibitionActionResult> bindProjectAttachment({
    required String? projectId,
    required ProjectAttachmentBindCommand command,
  }) {
    return _actionService.bindProjectAttachment(
      projectId: projectId,
      command: command,
    );
  }

  Future<ExhibitionActionResult> deleteProjectAttachment({
    required String? projectId,
    required String? attachmentId,
  }) {
    return _actionService.deleteProjectAttachment(
      projectId: projectId,
      attachmentId: attachmentId,
    );
  }

  Future<ExhibitionActionResult> requestProjectAttachmentAccess({
    required String? fileAssetId,
    required String mode,
  }) {
    return _actionService.requestProjectAttachmentAccess(
      fileAssetId: fileAssetId,
      mode: mode,
    );
  }

  Future<ExhibitionActionResult> requestProjectPublicResourceDownload({
    required String? fileAssetId,
  }) {
    return _actionService.requestProjectPublicResourceDownload(
      fileAssetId: fileAssetId,
    );
  }

  Future<UploadFlowResult> uploadInit(UploadInitCommand command) {
    return _uploadService.uploadInit(command);
  }

  Future<UploadFlowResult> directUpload({
    required UploadDirective directive,
    required List<int> bodyBytes,
  }) {
    return _uploadService.directUpload(
      directive: directive,
      bodyBytes: bodyBytes,
    );
  }

  Future<UploadFlowResult> uploadConfirm({required UploadDirective directive}) {
    return _uploadService.uploadConfirm(directive: directive);
  }

  Future<ExhibitionLoadResult> _loadBidProjection(
    String canonicalPath, {
    required String? projectId,
    required String? bidId,
    bool forceRefresh = false,
  }) async {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: canonicalPath,
        message:
            'projectId is required from route context or page context before calling BFF',
      );
    }

    final normalizedBidId = _normalizeId(bidId);
    if (normalizedBidId == null) {
      return ExhibitionLoadResult(
        state: AppPageState.empty,
        method: 'GET',
        path: canonicalPath,
        payload: <String, Object?>{
          'surfaceState': 'not_visible',
          'projectId': normalizedProjectId,
        },
      );
    }

    try {
      final response = await runProtectedAppRequest(
        () => _client.get(
          canonicalPath,
          queryParameters: <String, String>{
            'projectId': normalizedProjectId,
            'bidId': normalizedBidId,
          },
        ),
      );
      return _mapBidProjectionResponse(response, canonicalPath);
    } on SocketException {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'network error while requesting canonical BFF path',
      );
    } on HttpException {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'http error while requesting canonical BFF path',
      );
    } on StateError {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'current fake transport did not provide this canonical path',
      );
    } on FormatException {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  ExhibitionLoadResult _mapBidProjectionResponse(
    AppApiResponse response,
    String canonicalPath,
  ) {
    final payload = response.body;
    final failurePayload = _sanitizeFailurePayload(payload);
    final failureCode = _extractErrorCode(failurePayload);
    final failureMessage = _failureMessage(
      payload,
      'canonical BFF request failed',
    );

    if (response.statusCode == 401) {
      return ExhibitionLoadResult(
        state: AppPageState.unauthorized,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode == 403) {
      return ExhibitionLoadResult(
        state: AppPageState.forbidden,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode == 404) {
      return ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode >= 500) {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode >= 400) {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    final validation = _sanitizeAndValidateSuccessPayload(
      'GET',
      canonicalPath,
      payload,
    );
    if (!validation.isValid) {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        payload: validation.payload,
        message: validation.message,
      );
    }

    if (_isEmptyPayload(validation.payload)) {
      return ExhibitionLoadResult(
        state: AppPageState.empty,
        method: 'GET',
        path: canonicalPath,
        payload: validation.payload,
      );
    }

    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: canonicalPath,
      payload: validation.payload,
    );
  }

  String prettyPayload(Object? payload) {
    if (payload == null) {
      return 'null';
    }

    if (payload is String) {
      return payload;
    }

    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
