#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'yaml'

module ContractsGeneration
  module_function

  WORKSPACE_ROOT = File.expand_path('../../..', __dir__)
  OPENAPI_PATH = File.join(WORKSPACE_ROOT, 'docs/01_contracts/openapi.yaml')
  ERROR_CODES_PATH = File.join(WORKSPACE_ROOT, 'docs/01_contracts/error_codes.yaml')
  ROOT_PACKAGE_JSON_PATH = File.join(WORKSPACE_ROOT, 'package.json')
  OUTPUT_ROOT = File.join(WORKSPACE_ROOT, 'packages/contracts')
  OPENAPI_BUNDLE_PATH = File.join(OUTPUT_ROOT, 'openapi/openapi.bundle.json')
  APP_API_TYPES_PATH = File.join(OUTPUT_ROOT, 'src/generated/app-api.types.ts')
  ERROR_CODES_TS_PATH = File.join(OUTPUT_ROOT, 'src/generated/error-codes.ts')
  INDEX_TS_PATH = File.join(OUTPUT_ROOT, 'src/generated/index.ts')
  MANIFEST_PATH = File.join(OUTPUT_ROOT, 'contracts-manifest.json')

  EXPECTED_INPUTS = [
    'docs/01_contracts/openapi.yaml',
    'docs/01_contracts/error_codes.yaml'
  ].freeze
  EXPECTED_OUTPUTS = [
    'packages/contracts/contracts-manifest.json',
    'packages/contracts/openapi/openapi.bundle.json',
    'packages/contracts/src/generated/app-api.types.ts',
    'packages/contracts/src/generated/error-codes.ts',
    'packages/contracts/src/generated/index.ts'
  ].freeze
  EXPECTED_GENERATE_ENTRY = 'pnpm contracts:generate'
  EXPECTED_CHECK_ENTRY = 'pnpm contracts:check'
  EXPECTED_OUTPUT_ROOT = 'packages/contracts'
  EXPECTED_DIRECT_BINDING = ['apps/server', 'apps/bff'].freeze
  EXPECTED_NOT_DIRECT_BINDING = ['apps/mobile', 'apps/admin'].freeze
  EXPECTED_PRIMARY_ERROR_OUTPUTS = ['error-codes.ts', 'index.ts'].freeze
  EXPECTED_SHARED_OUTPUTS = [
    'contracts-manifest.json',
    'openapi.bundle.json',
    'app-api.types.ts'
  ].freeze

  def generate!
    openapi, error_codes = load_truth
    validate_truth_metadata!(openapi, error_codes)

    bundle_content = JSON.pretty_generate(openapi) + "\n"
    app_api_types_content = "#{build_app_api_types(openapi).rstrip}\n"
    error_codes_content = build_error_codes_ts(error_codes)
    index_content = build_index_ts

    write_file(OPENAPI_BUNDLE_PATH, bundle_content)
    write_file(APP_API_TYPES_PATH, app_api_types_content)
    write_file(ERROR_CODES_TS_PATH, error_codes_content)
    write_file(INDEX_TS_PATH, index_content)

    manifest_content = build_manifest(
      openapi: openapi,
      error_codes: error_codes,
      bundle_content: bundle_content,
      app_api_types_content: app_api_types_content,
      error_codes_content: error_codes_content,
      index_content: index_content
    )
    write_file(MANIFEST_PATH, manifest_content)
  end

  def load_truth
    ensure_inputs_exist!
    [YAML.load_file(OPENAPI_PATH), YAML.load_file(ERROR_CODES_PATH)]
  end

  def validate_truth_metadata!(openapi, error_codes)
    generation_meta = openapi.fetch('x-contracts-generation')
    error_meta = error_codes.fetch('generation_input_boundary')

    assert_equal(EXPECTED_INPUTS, generation_meta.fetch('formal_inputs'), 'openapi formal_inputs')
    assert_equal(EXPECTED_INPUTS, error_meta.fetch('paired_formal_inputs'), 'error_codes paired_formal_inputs')
    assert_equal(EXPECTED_GENERATE_ENTRY, generation_meta.fetch('single_generation_entry'), 'openapi single_generation_entry')
    assert_equal(EXPECTED_GENERATE_ENTRY, error_meta.fetch('single_generation_entry'), 'error_codes single_generation_entry')
    assert_equal(EXPECTED_CHECK_ENTRY, generation_meta.fetch('single_drift_check_entry'), 'openapi single_drift_check_entry')
    assert_equal(EXPECTED_CHECK_ENTRY, error_meta.fetch('single_drift_check_entry'), 'error_codes single_drift_check_entry')
    assert_equal(EXPECTED_OUTPUT_ROOT, generation_meta.fetch('output_root'), 'openapi output_root')
    assert_equal(EXPECTED_OUTPUT_ROOT, error_meta.fetch('output_root'), 'error_codes output_root')
    assert_equal(EXPECTED_OUTPUTS.map { |path| File.basename(path) }, generation_meta.fetch('first_batch_outputs'), 'openapi first_batch_outputs')
    assert_equal(EXPECTED_PRIMARY_ERROR_OUTPUTS, error_meta.fetch('first_batch_output_coverage').fetch('primary_projection'), 'error_codes primary_projection')
    assert_equal(EXPECTED_SHARED_OUTPUTS, error_meta.fetch('first_batch_output_coverage').fetch('shared_manifest_set'), 'error_codes shared_manifest_set')
    assert_equal(EXPECTED_DIRECT_BINDING, generation_meta.fetch('direct_consumer_binding'), 'openapi direct_consumer_binding')
    assert_equal(EXPECTED_DIRECT_BINDING, error_meta.fetch('direct_consumer_binding'), 'error_codes direct_consumer_binding')
    assert_equal(EXPECTED_NOT_DIRECT_BINDING, generation_meta.fetch('not_directly_bound_in_first_batch'), 'openapi not_directly_bound_in_first_batch')
    assert_equal(EXPECTED_NOT_DIRECT_BINDING, error_meta.fetch('not_directly_bound_in_first_batch'), 'error_codes not_directly_bound_in_first_batch')
  end

  def ensure_inputs_exist!
    EXPECTED_INPUTS.each do |relative_path|
      absolute_path = File.join(WORKSPACE_ROOT, relative_path)
      raise "missing formal input: #{relative_path}" unless File.file?(absolute_path)
    end
  end

  def ensure_expected_outputs_exist!
    EXPECTED_OUTPUTS.each do |relative_path|
      absolute_path = File.join(WORKSPACE_ROOT, relative_path)
      raise "missing expected output: #{relative_path}" unless File.file?(absolute_path)
    end
  end

  def ensure_outputs_not_misplaced!
    expected_by_name = EXPECTED_OUTPUTS.each_with_object({}) do |relative_path, memo|
      memo[File.basename(relative_path)] = File.join(WORKSPACE_ROOT, relative_path)
    end

    expected_by_name.each do |basename, expected_path|
      Dir.glob(File.join(WORKSPACE_ROOT, '**', basename), File::FNM_DOTMATCH).each do |path|
        next if path.include?('/node_modules/')
        next if File.expand_path(path) == expected_path

        raise "generated output is misplaced outside packages/contracts: #{path}"
      end
    end
  end

  def ensure_single_formal_entries!
    package_files = Dir.glob(File.join(WORKSPACE_ROOT, '**/package.json')).reject do |path|
      path.include?('/node_modules/')
    end

    generate_entries = []
    check_entries = []

    package_files.each do |package_path|
      package_json = JSON.parse(File.read(package_path))
      scripts = package_json.fetch('scripts', {})
      generate_entries << package_path if scripts.key?('contracts:generate')
      check_entries << package_path if scripts.key?('contracts:check')
    end

    unless generate_entries == [ROOT_PACKAGE_JSON_PATH]
      raise "multiple generation entries present: #{generate_entries.join(', ')}"
    end
    unless check_entries == [ROOT_PACKAGE_JSON_PATH]
      raise "multiple drift-check entries present: #{check_entries.join(', ')}"
    end
  end

  def snapshot_outputs
    EXPECTED_OUTPUTS.each_with_object({}) do |relative_path, memo|
      absolute_path = File.join(WORKSPACE_ROOT, relative_path)
      memo[relative_path] = File.file?(absolute_path) ? sha256(File.binread(absolute_path)) : nil
    end
  end

  def manifest_hash_valid?
    manifest = JSON.parse(File.read(MANIFEST_PATH))
    expected_hash = manifest.delete('manifestHash')
    sha256(JSON.generate(manifest)) == expected_hash
  end

  def build_manifest(openapi:, error_codes:, bundle_content:, app_api_types_content:, error_codes_content:, index_content:)
    body = {
      'schemaVersion' => 1,
      'formalInputs' => [
        { 'path' => EXPECTED_INPUTS[0], 'sha256' => sha256(File.binread(OPENAPI_PATH)) },
        { 'path' => EXPECTED_INPUTS[1], 'sha256' => sha256(File.binread(ERROR_CODES_PATH)) }
      ],
      'generationEntry' => openapi.fetch('x-contracts-generation').fetch('single_generation_entry'),
      'driftCheckEntry' => openapi.fetch('x-contracts-generation').fetch('single_drift_check_entry'),
      'outputRoot' => openapi.fetch('x-contracts-generation').fetch('output_root'),
      'outputs' => [
        { 'path' => EXPECTED_OUTPUTS[0], 'kind' => 'manifest' },
        { 'path' => EXPECTED_OUTPUTS[1], 'kind' => 'bundle', 'sha256' => sha256(bundle_content) },
        { 'path' => EXPECTED_OUTPUTS[2], 'kind' => 'types', 'sha256' => sha256(app_api_types_content) },
        { 'path' => EXPECTED_OUTPUTS[3], 'kind' => 'error-codes', 'sha256' => sha256(error_codes_content) },
        { 'path' => EXPECTED_OUTPUTS[4], 'kind' => 'barrel', 'sha256' => sha256(index_content) }
      ],
      'directConsumerBinding' => error_codes.fetch('generation_input_boundary').fetch('direct_consumer_binding'),
      'notDirectlyBoundInFirstBatch' => error_codes.fetch('generation_input_boundary').fetch('not_directly_bound_in_first_batch'),
      'idempotency' => {
        'sameInputSameOutputRequired' => true,
        'contentIdentical' => true,
        'pathSetIdentical' => true,
        'exportOrderIdentical' => true,
        'manifestHashIdentical' => true,
        'forbiddenNondeterministicContent' => ['timestamp', 'machine_path', 'username', 'random_value']
      }
    }

    manifest = body.merge('manifestHash' => sha256(JSON.generate(body)))
    JSON.pretty_generate(manifest) + "\n"
  end

  def build_app_api_types(openapi)
    app_api_paths = openapi.fetch('paths').keys.select { |path| path.start_with?('/api/app/') }
    registry_entries = openapi.fetch('x-unified-instance-entry-registry').fetch('first_batch')
    schemas = openapi.fetch('components').fetch('schemas')
    instance_ref_schema = openapi.fetch('components').fetch('schemas').fetch('InstanceRef')
    instance_todo_item_schema = openapi.fetch('components').fetch('schemas').fetch('InstanceTodoItem')
    route_target_schema = openapi.fetch('components').fetch('schemas').fetch('InstanceTodoRouteTarget')
    registered_entry_schema = openapi.fetch('components').fetch('schemas').fetch('RegisteredInstanceEntryItem')

    object_types = instance_ref_schema.fetch('properties').fetch('objectType').fetch('enum')
    action_keys = instance_todo_item_schema.fetch('properties').fetch('actionKey').fetch('enum')
    message_types = instance_todo_item_schema.fetch('properties').fetch('messageType').fetch('enum')
    item_states = instance_todo_item_schema.fetch('properties').fetch('state').fetch('enum')
    canonical_paths = route_target_schema.fetch('properties').fetch('canonicalPath').fetch('enum')
    required_params = route_target_schema.fetch('properties').fetch('requiredParams').fetch('items').fetch('enum')
    route_target_states = route_target_schema.fetch('properties').fetch('state').fetch('enum')
    consumer_buildings = registered_entry_schema.fetch('properties').fetch('consumerBuilding').fetch('enum')
    registered_entry_states = registered_entry_schema.fetch('properties').fetch('state').fetch('enum')
    entry_keys = registry_entries.map { |entry| entry.fetch('entryKey') }
    local_entry_keys = registry_entries.map { |entry| entry.fetch('localEntryKey') }

    registry_literal = JSON.pretty_generate(registry_entries)
    project_type_block = build_project_contract_types(schemas)
    trading_type_block = build_trading_contract_types(schemas)

    <<~TS
      // Generated by pnpm contracts:generate. Do not edit by hand.

      export const APP_API_PATHS = #{json_array(app_api_paths)} as const;
      export type AppApiPath = (typeof APP_API_PATHS)[number];

      export const INSTANCE_TODO_MESSAGE_TYPES = #{json_array(message_types)} as const;
      export type InstanceTodoMessageType = (typeof INSTANCE_TODO_MESSAGE_TYPES)[number];

      export const REGISTERED_ENTRY_OBJECT_TYPES = #{json_array(object_types)} as const;
      export type RegisteredEntryObjectType = (typeof REGISTERED_ENTRY_OBJECT_TYPES)[number];

      export const REGISTERED_ENTRY_ACTION_KEYS = #{json_array(action_keys)} as const;
      export type RegisteredEntryActionKey = (typeof REGISTERED_ENTRY_ACTION_KEYS)[number];

      export const REGISTERED_ENTRY_CANONICAL_PATHS = #{json_array(canonical_paths)} as const;
      export type RegisteredEntryCanonicalPath = (typeof REGISTERED_ENTRY_CANONICAL_PATHS)[number];

      export const REGISTERED_ENTRY_REQUIRED_PARAMS = #{json_array(required_params)} as const;
      export type RegisteredEntryRequiredParam = (typeof REGISTERED_ENTRY_REQUIRED_PARAMS)[number];

      export const REGISTERED_ENTRY_LOCAL_KEYS = #{json_array(local_entry_keys)} as const;
      export type RegisteredEntryLocalKey = (typeof REGISTERED_ENTRY_LOCAL_KEYS)[number];

      export const REGISTERED_ENTRY_KEYS = #{json_array(entry_keys)} as const;
      export type RegisteredEntryKey = (typeof REGISTERED_ENTRY_KEYS)[number];

      export const REGISTERED_ENTRY_BUILDINGS = #{json_array(consumer_buildings)} as const;
      export type RegisteredEntryBuilding = (typeof REGISTERED_ENTRY_BUILDINGS)[number];

      export const REGISTERED_ENTRY_STATES = #{json_array(registered_entry_states)} as const;
      export type RegisteredEntryState = (typeof REGISTERED_ENTRY_STATES)[number];

      export const INSTANCE_TODO_ITEM_STATES = #{json_array(item_states)} as const;
      export type InstanceTodoItemState = (typeof INSTANCE_TODO_ITEM_STATES)[number];

      export const INSTANCE_TODO_ROUTE_TARGET_STATES = #{json_array(route_target_states)} as const;
      export type InstanceTodoRouteTargetState = (typeof INSTANCE_TODO_ROUTE_TARGET_STATES)[number];

      export interface InstanceRef {
        objectType: RegisteredEntryObjectType;
        instanceId: string;
      }

      export interface InstanceTodoRouteTarget {
        canonicalPath: RegisteredEntryCanonicalPath;
        localEntryKey: RegisteredEntryLocalKey;
        requiredParams: RegisteredEntryRequiredParam[];
        state: InstanceTodoRouteTargetState;
        routeParams: Record<string, string>;
      }

      export interface InstanceTodoItem {
        todoId: string;
        messageType: InstanceTodoMessageType;
        instanceRef: InstanceRef;
        actionKey: RegisteredEntryActionKey;
        title: string;
        summary: string;
        routeTarget: InstanceTodoRouteTarget;
        state: InstanceTodoItemState;
      }

      export interface RegisteredInstanceEntryItem {
        entryKey: RegisteredEntryKey;
        objectType: RegisteredEntryObjectType;
        actionKey: RegisteredEntryActionKey;
        canonicalPath: RegisteredEntryCanonicalPath;
        requiredParams: RegisteredEntryRequiredParam[];
        consumerBuilding: RegisteredEntryBuilding;
        localEntryKey: RegisteredEntryLocalKey;
        state: RegisteredEntryState;
      }

      export const REGISTERED_INSTANCE_ENTRY_REGISTRY =
      #{indent_block(registry_literal, 2)} as const satisfies readonly RegisteredInstanceEntryItem[];

      #{project_type_block}

      #{trading_type_block}
    TS
  end

  def build_project_contract_types(schemas)
    project_states = schemas.fetch('ProjectState').fetch('enum')
    viewer_relations = schemas.fetch('ProjectViewerRelation').fetch('enum')
    completion_statuses = schemas.fetch('MyProjectFormalCompletionStatus').fetch('enum')
    evaluation_statuses = schemas.fetch('MyProjectEvaluationStatus').fetch('enum')

    <<~TS
      export type ProjectSummary = Record<string, unknown>;

      export const PROJECT_STATES = #{json_array(project_states)} as const;
      export type ProjectState = (typeof PROJECT_STATES)[number];

      export const PROJECT_VIEWER_RELATIONS = #{json_array(viewer_relations)} as const;
      export type ProjectViewerRelation = (typeof PROJECT_VIEWER_RELATIONS)[number];

      export interface ProjectCreateRequest {
        title?: string | null;
        exhibitionName?: string | null;
        brandName?: string | null;
        buildingType: string;
        budgetAmount: number;
        areaSqm?: number | null;
        buildingTypeRemark?: string | null;
        provinceCode: string;
        provinceName: string;
        cityCode: string;
        cityName: string;
        districtCode?: string | null;
        districtName?: string | null;
        detailAddress: string;
        scopeSummary: string;
        plannedStartAt?: string | null;
        plannedEndAt?: string | null;
        scheduleDetail?: string | null;
        description?: string | null;
      }

      export interface ProjectCreateAcceptedResponse {
        projectId: string;
        state: ProjectState;
      }

      export interface ProjectListQuery {
        provinceCode?: string;
        cityCode?: string;
        areaBucket?: string;
        budgetBucket?: string;
        page?: number;
        pageSize?: number;
      }

      export interface ProjectSaveRequest extends ProjectCreateRequest {
        projectId: string;
      }

      export interface ProjectLifecycleActionRequest {
        projectId: string;
      }

      export interface ProjectLifecycleAcceptedResponse {
        projectId: string;
        state: ProjectState;
      }

      export type ProjectNameAccessStatus = 'visible' | 'requestable' | 'pending' | 'rejected';

      export interface ProjectListNameAccessReadModel {
        status: ProjectNameAccessStatus;
        canRequest: boolean;
      }

      export interface ProjectDetailNameAccessReadModel extends ProjectListNameAccessReadModel {
        requestId: string | null;
      }

      export interface ProjectShowcaseListItemReadModel {
        projectId: string;
        projectNo: string;
        title: string;
        displayTitle: string;
        exhibitionName: string | null;
        brandName: string | null;
        buildingType: string;
        budgetAmount: number;
        areaSqm: number | null;
        provinceCode: string | null;
        provinceName: string | null;
        cityCode: string | null;
        cityName: string | null;
        plannedStartAt: string | null;
        plannedEndAt: string | null;
        publishedAt: string;
        state: ProjectState;
        nameAccess: ProjectListNameAccessReadModel;
        summary: ProjectSummary;
      }

      export interface ProjectReadModel extends ProjectShowcaseListItemReadModel {
        buildingTypeRemark: string | null;
        districtCode: string | null;
        districtName: string | null;
        detailAddress: string | null;
        scopeSummary: string | null;
        scheduleDetail: string | null;
        viewerProjectRelation: ProjectViewerRelation;
        nameAccess: ProjectDetailNameAccessReadModel;
        currentViewerBid?: ProjectCurrentViewerBid | null;
        description: string | null;
      }

      export interface ProjectCurrentViewerBid {
        bidId: string;
        state: string;
      }

      export interface ProjectListPagination {
        page: number;
        pageSize: number;
        total: number;
        hasMore: boolean;
      }

      export interface ProjectListResponse {
        items: ProjectShowcaseListItemReadModel[];
        pagination: ProjectListPagination;
      }

      export const MY_PROJECT_FORMAL_COMPLETION_STATUSES = #{json_array(completion_statuses)} as const;
      export type MyProjectFormalCompletionStatus =
        (typeof MY_PROJECT_FORMAL_COMPLETION_STATUSES)[number];

      export const MY_PROJECT_EVALUATION_STATUSES = #{json_array(evaluation_statuses)} as const;
      export type MyProjectEvaluationStatus =
        (typeof MY_PROJECT_EVALUATION_STATUSES)[number];

      export interface MyProjectPrivateProgressSummaryReadModel {
        hasAcceptedOrder: boolean;
        orderStatus: string | null;
        contractStatus: string | null;
        fulfillmentStatus: string | null;
        acceptanceStatus: string | null;
        afterSalesOrDisputeStatus: string | null;
        formalCompletionStatus: MyProjectFormalCompletionStatus;
        evaluationStatus: MyProjectEvaluationStatus;
      }

      export interface MyProjectListItemReadModel {
        projectCreatedAt: string | null;
        publicProject: ProjectShowcaseListItemReadModel;
        privateSummary: MyProjectPrivateProgressSummaryReadModel;
      }

      export interface MyProjectListResponse {
        ongoingProjects: MyProjectListItemReadModel[];
        historicalProjects: MyProjectListItemReadModel[];
      }

      export interface MyProjectPrivateProgressReadModel {
        hasAcceptedOrder: boolean;
        orderStatus: string | null;
        contractStatus: string | null;
        fulfillmentStatus: string | null;
        acceptanceStatus: string | null;
        afterSalesOrDisputeStatus: string | null;
        formalCompletionStatus: MyProjectFormalCompletionStatus;
        evaluationStatus: MyProjectEvaluationStatus;
      }

      export interface MyProjectDetailReadModel {
        publicProject: ProjectReadModel;
        privateProgress: MyProjectPrivateProgressReadModel;
      }
    TS
  end

  def build_trading_contract_types(schemas)
    contract_confirm_states = schemas.fetch('ContractConfirmAcceptedResponse')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    contract_amend_states = schemas.fetch('ContractAmendAcceptedResponse')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    inspection_recheck_states = schemas.fetch('InspectionRecheckAcceptedResponse')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    dispute_withdraw_states = schemas.fetch('DisputeWithdrawAcceptedResponse')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    bid_award_states = schemas.fetch('BidAwardAcceptedResponse')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    bid_participation_request_statuses = schemas.fetch('BidParticipationRequestStatus').fetch('enum')
    bid_result_states = schemas.fetch('BidResultReadModel')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    bid_result_outcomes = schemas.fetch('BidResultReadModel')
      .fetch('properties')
      .fetch('result')
      .fetch('enum')
    deal_confirmation_statuses = schemas.fetch('DealConfirmationStatus').fetch('enum')
    pricing_currency_codes = schemas.fetch('PricingCurrencyCode').fetch('enum')
    project_bid_material_kinds = schemas.fetch('ProjectBidMaterialKind').fetch('enum')
    workbench_entry_keys = schemas.fetch('ProjectCommunicationWorkbenchEntryKey').fetch('enum')
    workbench_groups = schemas.fetch('ProjectCommunicationWorkbenchGroup').fetch('enum')
    material_review_states = schemas.fetch('ProjectCommunicationMaterialReviewState').fetch('enum')
    rating_entry_states = schemas.fetch('RatingEntryReadModel')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    rating_submit_states = schemas.fetch('RatingSubmitAcceptedResponse')
      .fetch('properties')
      .fetch('state')
      .fetch('enum')
    workbench_rating_entry_states = schemas.fetch('WorkbenchRatingEntryState').fetch('enum')

    <<~TS
      export const CONTRACT_CONFIRM_STATES = #{json_array(contract_confirm_states)} as const;
      export type ContractConfirmState = (typeof CONTRACT_CONFIRM_STATES)[number];

      export interface ContractConfirmRequest {
        orderId: string;
      }

      export interface ContractConfirmAcceptedResponse {
        contractId: string;
        orderId: string;
        state: ContractConfirmState;
        summary: Record<string, unknown>;
      }

      export const CONTRACT_AMEND_STATES = #{json_array(contract_amend_states)} as const;
      export type ContractAmendState = (typeof CONTRACT_AMEND_STATES)[number];

      export interface ContractAmendRequest {
        orderId: string;
      }

      export interface ContractAmendAcceptedResponse {
        contractId: string;
        orderId: string;
        state: ContractAmendState;
        summary: Record<string, unknown>;
      }

      export const INSPECTION_RECHECK_STATES = #{json_array(inspection_recheck_states)} as const;
      export type InspectionRecheckState = (typeof INSPECTION_RECHECK_STATES)[number];

      export interface InspectionRecheckRequest {
        inspectionId: string;
      }

      export interface InspectionRecheckAcceptedResponse {
        inspectionId: string;
        milestoneId: string;
        state: InspectionRecheckState;
        summary: Record<string, unknown>;
      }

      export const DISPUTE_WITHDRAW_STATES = #{json_array(dispute_withdraw_states)} as const;
      export type DisputeWithdrawState = (typeof DISPUTE_WITHDRAW_STATES)[number];

      export interface DisputeWithdrawRequest {
        orderId: string;
      }

      export interface DisputeWithdrawAcceptedResponse {
        disputeId: string;
        orderId: string;
        state: DisputeWithdrawState;
        summary: Record<string, unknown>;
      }

      export const BID_AWARD_STATES = #{json_array(bid_award_states)} as const;
      export type BidAwardState = (typeof BID_AWARD_STATES)[number];

      export interface BidAwardRequest {
        projectId: string;
        winningBidId: string;
        reasonCode: string;
        reasonText: string;
      }

      export interface BidAwardAcceptedResponse {
        bidAwardId: string;
        projectId: string;
        winningBidId: string;
        orderId: string | null;
        contractId: string | null;
        state: BidAwardState;
      }

      export const BID_PARTICIPATION_REQUEST_STATUSES = #{json_array(bid_participation_request_statuses)} as const;
      export type BidParticipationRequestStatus =
        (typeof BID_PARTICIPATION_REQUEST_STATUSES)[number];

      export interface BidParticipationRequestCreateRequest {
        projectId: string;
      }

      export interface BidParticipationRequestAcceptedResponse {
        requestId: string;
        projectId: string;
        status: BidParticipationRequestStatus;
        threadId: string;
      }

      export interface BidParticipationRequesterReadModel {
        organizationId: string;
        displayName: string;
        avatarUrl: string | null;
      }

      export interface BidParticipationPrimaryReviewAction {
        actionKey: 'bid_participation.review';
        enabled: boolean;
        availableDecisions: Array<'approve' | 'reject'>;
      }

      export interface BidParticipationThreadDetailReadModel {
        threadId: string;
        threadType: 'bid_participation_review';
        projectId: string;
        requestId: string;
        requestStatus: BidParticipationRequestStatus;
        displayTitle: string;
        requesterOrganization: BidParticipationRequesterReadModel;
        items: Array<Record<string, unknown>>;
        primaryReviewAction: BidParticipationPrimaryReviewAction;
      }

      export interface BidParticipationPendingListResponse {
        projectId: string;
        requests: BidParticipationThreadDetailReadModel[];
      }

      export interface BidParticipationReviewAcceptedResponse {
        requestId: string;
        projectId: string;
        status: 'approved' | 'rejected';
      }

      export interface BidSubmitRequest {
        projectId: string;
        quoteAmount: number;
        proposalSummary: string;
        projectUnderstandingFileAssetId: string;
        quoteSheetFileAssetId: string;
        schedulePlanFileAssetId: string;
      }

      export interface BidSubmitAcceptedResponse {
        bidId: string;
      }

      export const PROJECT_BID_MATERIAL_KINDS = #{json_array(project_bid_material_kinds)} as const;
      export type ProjectBidMaterialKind = (typeof PROJECT_BID_MATERIAL_KINDS)[number];

      export interface ProjectBidMaterialReadModel {
        attachmentId: string;
        projectId: string;
        fileAssetId: string;
        fileName: string;
        attachmentKind: ProjectBidMaterialKind;
        mimeType: string;
        sortOrder: number;
        createdAt: string;
      }

      export interface ProjectBidMaterialListResponse {
        projectId: string;
        attachments: ProjectBidMaterialReadModel[];
      }

      export const DEAL_CONFIRMATION_STATUSES = #{json_array(deal_confirmation_statuses)} as const;
      export type DealConfirmationStatus = (typeof DEAL_CONFIRMATION_STATUSES)[number];

      export const PRICING_CURRENCY_CODES = #{json_array(pricing_currency_codes)} as const;
      export type PricingCurrencyCode = (typeof PRICING_CURRENCY_CODES)[number];

      export interface PricingServiceFeeCalculation {
        ruleVersion: string;
        baseFeeAmount: number;
        membershipTierApplied: string | null;
        membershipDiscountRate: number | null;
        capAmount: number;
        discountedFeeAmount: number;
        finalFeeAmount: number;
        pricingSnapshotHash: string;
        feeCalculatedAt: string;
      }

      export interface DealConfirmationCreateRequest {
        selectedBidId: string;
        finalConfirmedAmount: number;
        currency: PricingCurrencyCode;
        contractFileAssetIds: string[];
        confirmationRole: 'publisher' | 'factory';
        platformServiceFeeRecalculationAwarenessConfirmed: boolean;
        idempotencyKey: string;
      }

      export interface DealConfirmationAcceptedResponse {
        dealConfirmationId: string;
        dealStatus: DealConfirmationStatus;
        selectedBidId: string;
        finalConfirmedAmount: number;
        platformServiceFeeCalculation: PricingServiceFeeCalculation;
        serviceFeeChargeStatus: string;
        updatedAt: string;
      }

      export interface DealConfirmationReadModel extends DealConfirmationAcceptedResponse {
        publisherConfirmedAt: string | null;
        factoryConfirmedAt: string | null;
        publisherAuthenticitySincerityStatus: string | null;
      }

      export const PROJECT_COMMUNICATION_WORKBENCH_ENTRY_KEYS = #{json_array(workbench_entry_keys)} as const;
      export type ProjectCommunicationWorkbenchEntryKey =
        (typeof PROJECT_COMMUNICATION_WORKBENCH_ENTRY_KEYS)[number];

      export const PROJECT_COMMUNICATION_WORKBENCH_GROUPS = #{json_array(workbench_groups)} as const;
      export type ProjectCommunicationWorkbenchGroup =
        (typeof PROJECT_COMMUNICATION_WORKBENCH_GROUPS)[number];

      export const PROJECT_COMMUNICATION_MATERIAL_REVIEW_STATES = #{json_array(material_review_states)} as const;
      export type ProjectCommunicationMaterialReviewState =
        (typeof PROJECT_COMMUNICATION_MATERIAL_REVIEW_STATES)[number];

      export interface ProjectCommunicationWorkbenchRouteTarget {
        actionKey: string;
        canonicalPath: string;
        params: Record<string, string>;
      }

      export interface ProjectCommunicationWorkbenchTruthAnchor {
        truthOwner: 'server';
        subjectType: 'publisher_quote_basis_material' | 'bid_submission_material' | 'deal_confirmation';
        projectId: string;
        threadId: string;
        bidId: string | null;
        dealConfirmationId: string | null;
      }

      export interface ProjectCommunicationWorkbenchEntry {
        entryKey: ProjectCommunicationWorkbenchEntryKey;
        group: ProjectCommunicationWorkbenchGroup;
        label: string;
        summary: string | null;
        projectId: string;
        threadId: string;
        bidId: string | null;
        viewerRole: 'publisher' | 'bidder' | 'unknown';
        subjectOwnerRole: 'publisher' | 'bidder' | 'platform';
        availabilityState: 'unsubmitted' | 'readable' | 'unavailable';
        reviewState: ProjectCommunicationMaterialReviewState | null;
        actionState: 'enabled' | 'readonly' | 'blocked';
        attachmentCount: number;
        latestFeedbackText: string | null;
        latestFeedbackAt: string | null;
        reviewedAt: string | null;
        routeTarget: ProjectCommunicationWorkbenchRouteTarget | null;
        truthAnchor: ProjectCommunicationWorkbenchTruthAnchor;
      }

      export interface ProjectCommunicationWorkbenchReadModel {
        projectId: string;
        threadId: string;
        viewerRole: 'publisher' | 'bidder' | 'unknown';
        entries: ProjectCommunicationWorkbenchEntry[];
        generatedAt: string;
      }

      export interface ProjectCommunicationMaterialReviewRequest {
        projectId: string;
        threadId: string;
        bidId?: string | null;
        entryKey: ProjectCommunicationWorkbenchEntryKey;
        reviewAction: 'confirm' | 'request_supplement';
        feedbackReasonCodes?: string[];
        feedbackText?: string | null;
        sourceVersionToken?: string | null;
        idempotencyKey: string;
      }

      export interface ProjectCommunicationMaterialReviewAcceptedResponse {
        entry: ProjectCommunicationWorkbenchEntry;
        entries?: ProjectCommunicationWorkbenchEntry[];
      }

      export const BID_RESULT_STATES = #{json_array(bid_result_states)} as const;
      export type BidResultState = (typeof BID_RESULT_STATES)[number];

      export const BID_RESULT_OUTCOMES = #{json_array(bid_result_outcomes)} as const;
      export type BidResultOutcome = (typeof BID_RESULT_OUTCOMES)[number];

      export interface BidResultQuery {
        projectId: string;
      }

      export interface BidResultReadModel {
        bidId: string;
        projectId: string;
        state: BidResultState;
        result: BidResultOutcome;
        reasonCode: string;
        reasonText: string;
        decidedAt: string;
      }

      export const RATING_ENTRY_STATES = #{json_array(rating_entry_states)} as const;
      export type RatingEntryState = (typeof RATING_ENTRY_STATES)[number];

      export interface RatingEntryReadModel {
        ratingId: string;
        orderId: string;
        state: RatingEntryState;
        summary: Record<string, unknown>;
      }

      export const RATING_SUBMIT_STATES = #{json_array(rating_submit_states)} as const;
      export type RatingSubmitState = (typeof RATING_SUBMIT_STATES)[number];

      export interface RatingSubmitRequest {
        orderId: string;
      }

      export interface RatingSubmitAcceptedResponse {
        ratingId: string;
        orderId: string;
        state: RatingSubmitState;
        summary: Record<string, unknown>;
      }

      export const WORKBENCH_RATING_ENTRY_STATES = #{json_array(workbench_rating_entry_states)} as const;
      export type WorkbenchRatingEntryState = (typeof WORKBENCH_RATING_ENTRY_STATES)[number];
    TS
  end

  def build_error_codes_ts(error_codes)
    namespaces = error_codes.fetch('namespaces')
    code_definitions = error_codes.fetch('codes')
    codes = code_definitions.map { |entry| entry.fetch('code') }
    owners = code_definitions.map { |entry| entry.fetch('owner') }.uniq
    definitions_hash = code_definitions.each_with_object({}) do |entry, memo|
      memo[entry.fetch('code')] = {
        'owner' => entry.fetch('owner'),
        'meaning' => entry.fetch('meaning')
      }
    end

    <<~TS
      // Generated by pnpm contracts:generate. Do not edit by hand.

      export const ERROR_CODE_NAMESPACES = #{json_array(namespaces)} as const;
      export type ErrorCodeNamespace = (typeof ERROR_CODE_NAMESPACES)[number];

      export const ERROR_CODE_VALUES = #{json_array(codes)} as const;
      export type ErrorCode = (typeof ERROR_CODE_VALUES)[number];

      export const ERROR_CODE_OWNERS = #{json_array(owners)} as const;
      export type ErrorCodeOwner = (typeof ERROR_CODE_OWNERS)[number];

      export type ErrorCodeDefinition = {
        readonly owner: ErrorCodeOwner;
        readonly meaning: string;
      };

      export const ERROR_CODE_DEFINITIONS =
      #{indent_block(JSON.pretty_generate(definitions_hash), 2)} as const satisfies Record<ErrorCode, ErrorCodeDefinition>;
    TS
  end

  def build_index_ts
    <<~TS
      // Generated by pnpm contracts:generate. Do not edit by hand.

      export * from './app-api.types';
      export * from './error-codes';
    TS
  end

  def write_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def sha256(content)
    Digest::SHA256.hexdigest(content)
  end

  def assert_equal(expected, actual, label)
    return if expected == actual

    raise "#{label} mismatch: expected #{expected.inspect}, got #{actual.inspect}"
  end

  def json_array(values)
    JSON.generate(values)
  end

  def indent_block(content, spaces)
    prefix = ' ' * spaces
    content.each_line.map { |line| "#{prefix}#{line}" }.join.rstrip
  end
end
