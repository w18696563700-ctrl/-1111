import 'dart:convert';
import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';

part 'commands/bid_submit_command.dart';
part 'commands/contract_amend_command.dart';
part 'commands/contract_confirm_command.dart';
part 'commands/dispute_open_command.dart';
part 'commands/dispute_withdraw_command.dart';
part 'commands/inspection_recheck_command.dart';
part 'commands/inspection_submit_command.dart';
part 'commands/milestone_submit_command.dart';
part 'commands/order_create_command.dart';
part 'commands/project_create_command.dart';
part 'commands/rating_submit_command.dart';
part 'commands/upload_init_command.dart';
part 'models/exhibition_action_result.dart';
part 'models/exhibition_load_result.dart';
part 'models/upload_directive.dart';
part 'models/upload_flow_result.dart';
part 'services/exhibition_action_service.dart';
part 'services/exhibition_canonical_paths.dart';
part 'services/exhibition_contract_mapper.dart';
part 'services/my_project_contract_mapper.dart';
part 'services/exhibition_workbench_contract_mapper.dart';
part 'services/exhibition_entry_contract_validation.dart';
part 'services/exhibition_contract_validation.dart';
part 'services/my_project_contract_validation.dart';
part 'services/exhibition_workbench_contract_validation.dart';
part 'services/exhibition_contract_validation_base.dart';
part 'services/exhibition_load_service.dart';
part 'services/exhibition_upload_service.dart';

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

  Future<ExhibitionLoadResult> loadWorkbench({bool forceRefresh = false}) {
    return _loadService.loadWorkbench(forceRefresh: forceRefresh);
  }

  Future<ExhibitionLoadResult> loadProjectList({bool forceRefresh = false}) {
    return _loadService.loadProjectList(forceRefresh: forceRefresh);
  }

  Future<ExhibitionLoadResult> loadMyProjectList({bool forceRefresh = false}) {
    return _loadService.loadMyProjectList(forceRefresh: forceRefresh);
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

  Future<ExhibitionLoadResult> loadMyProjectDetail({
    required String? projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadMyProjectDetail(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadOrderDetail({
    required String? orderId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadOrderDetail(
      orderId: orderId,
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

  Future<ExhibitionLoadResult> loadRatingEntry({
    required String? orderId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadRatingEntry(
      orderId: orderId,
      forceRefresh: forceRefresh,
    );
  }

  void invalidateInspectionDetail({required String? milestoneId}) {
    _loadService.invalidateInspectionDetail(milestoneId: milestoneId);
  }

  Future<ExhibitionActionResult> createProject(ProjectCreateCommand command) {
    return _actionService.createProject(command);
  }

  Future<ExhibitionActionResult> submitBid(BidSubmitCommand command) {
    return _actionService.submitBid(command);
  }

  Future<ExhibitionActionResult> createOrder(OrderCreateCommand command) {
    return _actionService.createOrder(command);
  }

  Future<ExhibitionActionResult> confirmContract(
    ContractConfirmCommand command,
  ) {
    return _actionService.confirmContract(command);
  }

  Future<ExhibitionActionResult> amendContract(ContractAmendCommand command) {
    return _actionService.amendContract(command);
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

  Future<ExhibitionActionResult> submitRating(RatingSubmitCommand command) {
    return _actionService.submitRating(command);
  }

  Future<ExhibitionActionResult> openDispute(DisputeOpenCommand command) {
    return _actionService.openDispute(command);
  }

  Future<ExhibitionActionResult> withdrawDispute(
    DisputeWithdrawCommand command,
  ) {
    return _actionService.withdrawDispute(command);
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
