import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';

enum ExhibitionWorkbenchSourceKind { demo, futureReal }

class ExhibitionWorkbenchSourceResult {
  const ExhibitionWorkbenchSourceResult({
    required this.kind,
    required this.state,
    this.summary,
    this.message,
  });

  final ExhibitionWorkbenchSourceKind kind;
  final AppPageState state;
  final ExhibitionWorkbenchSummaryData? summary;
  final String? message;
}

abstract interface class ExhibitionWorkbenchSource {
  Future<ExhibitionWorkbenchSourceResult> load({bool forceRefresh = false});
}

class ExhibitionWorkbenchAutoSource implements ExhibitionWorkbenchSource {
  ExhibitionWorkbenchAutoSource({
    required ExhibitionConsumerLayer consumerLayer,
    ExhibitionWorkbenchSource? demoSource,
    ExhibitionWorkbenchSource? futureRealSource,
  }) : _demoSource = demoSource ?? const ExhibitionWorkbenchDemoSource(),
       _futureRealSource =
           futureRealSource ??
           ExhibitionWorkbenchFutureRealSource(consumerLayer: consumerLayer);

  final ExhibitionWorkbenchSource _demoSource;
  final ExhibitionWorkbenchSource _futureRealSource;

  @override
  Future<ExhibitionWorkbenchSourceResult> load({
    bool forceRefresh = false,
  }) async {
    final futureReal = await _futureRealSource.load(forceRefresh: forceRefresh);
    if (_acceptFutureReal(futureReal)) {
      return futureReal;
    }

    if (!_shouldUseDemoFallback(futureReal)) {
      return futureReal;
    }

    return _demoSource.load(forceRefresh: forceRefresh);
  }

  bool _acceptFutureReal(ExhibitionWorkbenchSourceResult result) {
    return result.summary != null &&
        (result.state == AppPageState.content ||
            result.state == AppPageState.empty ||
            result.state == AppPageState.unauthorized ||
            result.state == AppPageState.forbidden);
  }

  bool _shouldUseDemoFallback(ExhibitionWorkbenchSourceResult result) {
    return result.state == AppPageState.errorRetryable &&
        result.message ==
            'current fake transport did not provide this canonical path';
  }
}

class ExhibitionWorkbenchFutureRealSource implements ExhibitionWorkbenchSource {
  ExhibitionWorkbenchFutureRealSource({
    required ExhibitionConsumerLayer consumerLayer,
  }) : _consumerLayer = consumerLayer;

  final ExhibitionConsumerLayer _consumerLayer;

  @override
  Future<ExhibitionWorkbenchSourceResult> load({
    bool forceRefresh = false,
  }) async {
    final result = await _consumerLayer.loadWorkbench(
      forceRefresh: forceRefresh,
    );
    return ExhibitionWorkbenchSourceResult(
      kind: ExhibitionWorkbenchSourceKind.futureReal,
      state: result.state,
      summary: ExhibitionWorkbenchSummaryData.fromPayload(result.payload),
      message: result.message,
    );
  }
}

class ExhibitionWorkbenchDemoSource implements ExhibitionWorkbenchSource {
  const ExhibitionWorkbenchDemoSource();

  static const ExhibitionWorkbenchSummaryData _demoSummary =
      ExhibitionWorkbenchSummaryData(
        projectChain: ExhibitionWorkbenchProjectChainData(
          hasProjects: true,
          recentProjectId: 'project-demo-2026',
          recentProjectTitle: '首发演示展台项目',
          canCreateProject: true,
          canOpenProjectPool: true,
        ),
        orderChain: ExhibitionWorkbenchOrderChainData(
          activeOrderId: null,
          activeOrderNo: null,
          activeOrderState: null,
          canOpenOrderDetail: false,
          canOpenContractDetail: false,
          canOpenDisputeOpen: false,
        ),
        fulfillmentChain: ExhibitionWorkbenchFulfillmentChainData(
          activeMilestoneId: null,
          activeMilestoneTitle: null,
          inspectionState: null,
          canOpenMilestoneList: false,
          canOpenMilestoneSubmit: false,
          canOpenInspectionDetail: false,
          canOpenInspectionSubmit: false,
        ),
        extensionBoundary: ExhibitionWorkbenchExtensionBoundaryData(
          canOpenContractDetail: false,
          ratingEntryState: 'controlled_unavailable',
          canOpenDisputeOpen: false,
          disputeWithdrawState: 'frozen',
        ),
      );

  @override
  Future<ExhibitionWorkbenchSourceResult> load({
    bool forceRefresh = false,
  }) async {
    return const ExhibitionWorkbenchSourceResult(
      kind: ExhibitionWorkbenchSourceKind.demo,
      state: AppPageState.content,
      summary: _demoSummary,
      message: '当前工作台先按演示内容展示工作排布。',
    );
  }
}

class ExhibitionWorkbenchSummaryData {
  const ExhibitionWorkbenchSummaryData({
    required this.projectChain,
    required this.orderChain,
    required this.fulfillmentChain,
    required this.extensionBoundary,
  });

  factory ExhibitionWorkbenchSummaryData.fromPayload(Object? payload) {
    final raw = _payloadMap(payload);
    return ExhibitionWorkbenchSummaryData(
      projectChain: ExhibitionWorkbenchProjectChainData.fromPayload(
        raw?['project_chain'],
      ),
      orderChain: ExhibitionWorkbenchOrderChainData.fromPayload(
        raw?['order_chain'],
      ),
      fulfillmentChain: ExhibitionWorkbenchFulfillmentChainData.fromPayload(
        raw?['fulfillment_chain'],
      ),
      extensionBoundary: ExhibitionWorkbenchExtensionBoundaryData.fromPayload(
        raw?['extension_boundary'],
      ),
    );
  }

  static const ExhibitionWorkbenchSummaryData empty =
      ExhibitionWorkbenchSummaryData(
        projectChain: ExhibitionWorkbenchProjectChainData.empty,
        orderChain: ExhibitionWorkbenchOrderChainData.empty,
        fulfillmentChain: ExhibitionWorkbenchFulfillmentChainData.empty,
        extensionBoundary: ExhibitionWorkbenchExtensionBoundaryData.empty,
      );

  final ExhibitionWorkbenchProjectChainData projectChain;
  final ExhibitionWorkbenchOrderChainData orderChain;
  final ExhibitionWorkbenchFulfillmentChainData fulfillmentChain;
  final ExhibitionWorkbenchExtensionBoundaryData extensionBoundary;
}

class ExhibitionWorkbenchProjectChainData {
  const ExhibitionWorkbenchProjectChainData({
    required this.hasProjects,
    required this.recentProjectId,
    required this.recentProjectTitle,
    required this.canCreateProject,
    required this.canOpenProjectPool,
  });

  factory ExhibitionWorkbenchProjectChainData.fromPayload(Object? payload) {
    final raw = _payloadMap(payload);
    return ExhibitionWorkbenchProjectChainData(
      hasProjects: raw?['hasProjects'] as bool? ?? false,
      recentProjectId: _stringOrNull(raw?['recentProjectId']),
      recentProjectTitle: _stringOrNull(raw?['recentProjectTitle']),
      canCreateProject: raw?['canCreateProject'] as bool? ?? false,
      canOpenProjectPool: raw?['canOpenProjectPool'] as bool? ?? false,
    );
  }

  static const ExhibitionWorkbenchProjectChainData empty =
      ExhibitionWorkbenchProjectChainData(
        hasProjects: false,
        recentProjectId: null,
        recentProjectTitle: null,
        canCreateProject: false,
        canOpenProjectPool: false,
      );

  final bool hasProjects;
  final String? recentProjectId;
  final String? recentProjectTitle;
  final bool canCreateProject;
  final bool canOpenProjectPool;
}

class ExhibitionWorkbenchOrderChainData {
  const ExhibitionWorkbenchOrderChainData({
    required this.activeOrderId,
    required this.activeOrderNo,
    required this.activeOrderState,
    required this.canOpenOrderDetail,
    required this.canOpenContractDetail,
    required this.canOpenDisputeOpen,
  });

  factory ExhibitionWorkbenchOrderChainData.fromPayload(Object? payload) {
    final raw = _payloadMap(payload);
    return ExhibitionWorkbenchOrderChainData(
      activeOrderId: _stringOrNull(raw?['activeOrderId']),
      activeOrderNo: _stringOrNull(raw?['activeOrderNo']),
      activeOrderState: _stringOrNull(raw?['activeOrderState']),
      canOpenOrderDetail: raw?['canOpenOrderDetail'] as bool? ?? false,
      canOpenContractDetail: raw?['canOpenContractDetail'] as bool? ?? false,
      canOpenDisputeOpen: raw?['canOpenDisputeOpen'] as bool? ?? false,
    );
  }

  static const ExhibitionWorkbenchOrderChainData empty =
      ExhibitionWorkbenchOrderChainData(
        activeOrderId: null,
        activeOrderNo: null,
        activeOrderState: null,
        canOpenOrderDetail: false,
        canOpenContractDetail: false,
        canOpenDisputeOpen: false,
      );

  final String? activeOrderId;
  final String? activeOrderNo;
  final String? activeOrderState;
  final bool canOpenOrderDetail;
  final bool canOpenContractDetail;
  final bool canOpenDisputeOpen;
}

class ExhibitionWorkbenchFulfillmentChainData {
  const ExhibitionWorkbenchFulfillmentChainData({
    required this.activeMilestoneId,
    required this.activeMilestoneTitle,
    required this.inspectionState,
    required this.canOpenMilestoneList,
    required this.canOpenMilestoneSubmit,
    required this.canOpenInspectionDetail,
    required this.canOpenInspectionSubmit,
  });

  factory ExhibitionWorkbenchFulfillmentChainData.fromPayload(Object? payload) {
    final raw = _payloadMap(payload);
    return ExhibitionWorkbenchFulfillmentChainData(
      activeMilestoneId: _stringOrNull(raw?['activeMilestoneId']),
      activeMilestoneTitle: _stringOrNull(raw?['activeMilestoneTitle']),
      inspectionState: _stringOrNull(raw?['inspectionState']),
      canOpenMilestoneList: raw?['canOpenMilestoneList'] as bool? ?? false,
      canOpenMilestoneSubmit: raw?['canOpenMilestoneSubmit'] as bool? ?? false,
      canOpenInspectionDetail:
          raw?['canOpenInspectionDetail'] as bool? ?? false,
      canOpenInspectionSubmit:
          raw?['canOpenInspectionSubmit'] as bool? ?? false,
    );
  }

  static const ExhibitionWorkbenchFulfillmentChainData empty =
      ExhibitionWorkbenchFulfillmentChainData(
        activeMilestoneId: null,
        activeMilestoneTitle: null,
        inspectionState: null,
        canOpenMilestoneList: false,
        canOpenMilestoneSubmit: false,
        canOpenInspectionDetail: false,
        canOpenInspectionSubmit: false,
      );

  final String? activeMilestoneId;
  final String? activeMilestoneTitle;
  final String? inspectionState;
  final bool canOpenMilestoneList;
  final bool canOpenMilestoneSubmit;
  final bool canOpenInspectionDetail;
  final bool canOpenInspectionSubmit;
}

class ExhibitionWorkbenchExtensionBoundaryData {
  const ExhibitionWorkbenchExtensionBoundaryData({
    required this.canOpenContractDetail,
    required this.ratingEntryState,
    required this.canOpenDisputeOpen,
    required this.disputeWithdrawState,
  });

  factory ExhibitionWorkbenchExtensionBoundaryData.fromPayload(
    Object? payload,
  ) {
    final raw = _payloadMap(payload);
    return ExhibitionWorkbenchExtensionBoundaryData(
      canOpenContractDetail: raw?['canOpenContractDetail'] as bool? ?? false,
      ratingEntryState:
          _stringOrNull(raw?['ratingEntryState']) ?? 'controlled_unavailable',
      canOpenDisputeOpen: raw?['canOpenDisputeOpen'] as bool? ?? false,
      disputeWithdrawState:
          _stringOrNull(raw?['disputeWithdrawState']) ?? 'frozen',
    );
  }

  static const ExhibitionWorkbenchExtensionBoundaryData empty =
      ExhibitionWorkbenchExtensionBoundaryData(
        canOpenContractDetail: false,
        ratingEntryState: 'controlled_unavailable',
        canOpenDisputeOpen: false,
        disputeWithdrawState: 'frozen',
      );

  final bool canOpenContractDetail;
  final String ratingEntryState;
  final bool canOpenDisputeOpen;
  final String disputeWithdrawState;
}

Map<String, Object?>? _payloadMap(Object? payload) {
  if (payload is Map<String, Object?>) {
    return payload;
  }
  if (payload is Map) {
    return payload.cast<String, Object?>();
  }
  return null;
}

String? _stringOrNull(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
