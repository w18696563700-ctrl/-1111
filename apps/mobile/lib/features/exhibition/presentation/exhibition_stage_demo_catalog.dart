part of 'exhibition_stage_sources.dart';

final class ExhibitionStageDemoCatalog {
  const ExhibitionStageDemoCatalog._();

  static const String demoProjectId = 'project-demo-2026';
  static const String demoBidId = 'bid-demo-2026';
  static const String demoOrderId = 'order-demo-2026';
  static const String demoContractId = 'contract-demo-2026';
  static const String demoMilestoneId = 'milestone-demo-1';
  static const String demoInspectionId = 'inspection-demo-1';
  static const String demoDisputeId = 'dispute-demo-1';

  static ExhibitionLoadResult projectList() {
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.projectList,
      payload: <String, Object?>{
        'items': <Object?>[
          _projectItem(
            projectId: demoProjectId,
            projectNo: 'EXH-2026-001',
            title: '春季品牌展岛台升级',
            budgetAmount: 186000,
            state: 'published',
          ),
          _projectItem(
            projectId: 'project-demo-2026-vip',
            projectNo: 'EXH-2026-002',
            title: '贵宾洽谈区灯光重做',
            budgetAmount: 92000,
            state: 'published',
          ),
        ],
        'summary': _summary('project-list-demo'),
      },
    );
  }

  static ExhibitionLoadResult projectDetail({String? projectId}) {
    final currentProjectId = _idOrFallback(projectId, demoProjectId);
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.projectDetail,
      payload: _projectItem(
        projectId: currentProjectId,
        projectNo: 'EXH-2026-001',
        title: '春季品牌展岛台升级',
        budgetAmount: 186000,
        state: 'published',
      ),
    );
  }

  static ExhibitionLoadResult myProjectList() {
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.myProjectList,
      payload: <String, Object?>{
        'ongoingProjects': <Object?>[
          _myProjectItem(
            publicProject: _projectItem(
              projectId: 'project-demo-draft',
              projectNo: 'EXH-2026-DRAFT',
              title: '春季新品展台草稿',
              budgetAmount: 86000,
              state: 'draft',
            ),
            privateProgress: _myProjectPrivateProgress(
              hasAcceptedOrder: false,
              formalCompletionStatus: 'not_formally_completed',
              evaluationStatus: 'not_eligible',
            ),
          ),
          _myProjectItem(
            publicProject: _projectItem(
              projectId: 'project-demo-submitted',
              projectNo: 'EXH-2026-SUBMIT',
              title: '快闪活动项目发布前核对',
              budgetAmount: 118000,
              state: 'submitted',
            ),
            privateProgress: _myProjectPrivateProgress(
              hasAcceptedOrder: false,
              formalCompletionStatus: 'not_formally_completed',
              evaluationStatus: 'not_eligible',
            ),
          ),
          _myProjectItem(
            publicProject: _projectItem(
              projectId: demoProjectId,
              projectNo: 'EXH-2026-001',
              title: '春季品牌展岛台升级',
              budgetAmount: 186000,
              state: 'published',
            ),
            privateProgress: _myProjectPrivateProgress(
              hasAcceptedOrder: false,
              formalCompletionStatus: 'not_formally_completed',
              evaluationStatus: 'not_eligible',
            ),
          ),
        ],
        'historicalProjects': <Object?>[
          _myProjectItem(
            publicProject: <String, Object?>{
              ..._projectItem(
                projectId: 'project-demo-2025-archive',
                projectNo: 'EXH-2025-018',
                title: '秋季器械展标准展位升级',
                budgetAmount: 128000,
                state: 'converted_to_order',
              ),
              'areaSqm': 420,
              'provinceName': '四川',
              'cityName': '成都',
            },
            privateProgress: _myProjectPrivateProgress(
              hasAcceptedOrder: true,
              formalCompletionStatus: 'formally_completed',
              evaluationStatus: 'submitted',
            ),
          ),
          _myProjectItem(
            publicProject: <String, Object?>{
              ..._projectItem(
                projectId: 'project-demo-2026-archived',
                projectNo: 'EXH-2026-ARCHIVE',
                title: '已归档演示项目',
                budgetAmount: 93000,
                state: 'archived',
              ),
              'areaSqm': 260,
              'provinceName': '浙江',
              'cityName': '杭州',
            },
            privateProgress: _myProjectPrivateProgress(
              hasAcceptedOrder: false,
              formalCompletionStatus: 'not_formally_completed',
              evaluationStatus: 'not_eligible',
            ),
          ),
        ],
      },
    );
  }

  static ExhibitionLoadResult myProjectDetail({String? projectId}) {
    final currentProjectId = _idOrFallback(projectId, demoProjectId);
    final currentState = _demoMyProjectState(currentProjectId);
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.myProjectDetail(currentProjectId),
      payload: <String, Object?>{
        'publicProject': <String, Object?>{
          ..._projectItem(
            projectId: currentProjectId,
            projectNo: 'EXH-2026-001',
            title: '春季品牌展岛台升级',
            budgetAmount: 186000,
            state: currentState,
          ),
          'buildingTypeRemark': '医疗器械展区主舞台与灯光联动搭建',
          'areaSqm': 350.5,
          'provinceName': '四川',
          'cityName': '成都',
          'districtName': '武侯区',
          'detailAddress': '世纪城新国际会展中心 6 号馆西门',
          'scopeSummary': '主舞台、器械展区与接待区同步进场',
          'plannedStartAt': '2026-04-10',
          'plannedEndAt': '2026-04-18',
          'scheduleDetail': '4 月 10 日晚进场，4 月 18 日撤场',
          'description': '当前项目仍按最小私域基线承接，不补造更丰富后链路。',
          'viewerProjectRelation': 'owner',
        },
        'privateProgress': _myProjectPrivateProgress(
          hasAcceptedOrder: currentState == 'converted_to_order',
          formalCompletionStatus: currentState == 'archived'
              ? 'formally_completed'
              : 'not_formally_completed',
          evaluationStatus: currentState == 'archived'
              ? 'submitted'
              : 'not_eligible',
        ),
      },
    );
  }

  static String _demoMyProjectState(String projectId) {
    if (projectId.contains('draft')) {
      return 'draft';
    }
    if (projectId.contains('submit')) {
      return 'submitted';
    }
    if (projectId.contains('archive')) {
      return 'archived';
    }
    if (projectId.contains('order')) {
      return 'converted_to_order';
    }
    return 'published';
  }

  static ExhibitionLoadResult orderDetail({
    String? orderId,
    String? projectId,
  }) {
    final currentOrderId = _idOrFallback(orderId, demoOrderId);
    final currentProjectId = _idOrFallback(projectId, demoProjectId);
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.orderDetail,
      payload: <String, Object?>{
        'orderId': currentOrderId,
        'orderNo': 'ORD-2026-018',
        'projectId': currentProjectId,
        'bidId': demoBidId,
        'state': 'active',
        'summary': _summary('order-detail-demo'),
        'milestones': <Object?>[
          _milestoneItem(
            milestoneId: demoMilestoneId,
            orderId: currentOrderId,
            title: '结构搭建与主材进场',
            amount: 62000,
            state: 'pending_submission',
          ),
          _milestoneItem(
            milestoneId: 'milestone-demo-2',
            orderId: currentOrderId,
            title: '灯光联调与软装收口',
            amount: 38000,
            state: 'draft',
          ),
        ],
      },
    );
  }

  static ExhibitionLoadResult contractDetail({String? orderId}) {
    final currentOrderId = _idOrFallback(orderId, demoOrderId);
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.contractDetail,
      payload: <String, Object?>{
        'contractId': demoContractId,
        'orderId': currentOrderId,
        'state': 'pending_confirm',
        'summary': _summary('contract-detail-demo'),
      },
    );
  }

  static ExhibitionLoadResult milestoneList({String? orderId}) {
    final currentOrderId = _idOrFallback(orderId, demoOrderId);
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.milestoneList,
      payload: <String, Object?>{
        'orderId': currentOrderId,
        'items': <Object?>[
          _milestoneItem(
            milestoneId: demoMilestoneId,
            orderId: currentOrderId,
            title: '结构搭建与主材进场',
            amount: 62000,
            state: 'pending_submission',
          ),
          _milestoneItem(
            milestoneId: 'milestone-demo-2',
            orderId: currentOrderId,
            title: '灯光联调与软装收口',
            amount: 38000,
            state: 'draft',
          ),
        ],
        'summary': _summary('milestone-list-demo'),
      },
    );
  }

  static ExhibitionLoadResult inspectionDetail({String? milestoneId}) {
    final currentMilestoneId = _idOrFallback(milestoneId, demoMilestoneId);
    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: ExhibitionCanonicalPaths.inspectionDetail,
      payload: <String, Object?>{
        'inspectionId': demoInspectionId,
        'milestoneId': currentMilestoneId,
        'state': 'draft',
        'summary': _summary('inspection-detail-demo'),
      },
    );
  }

  static ExhibitionActionResult projectCreate({
    required String title,
    required String buildingType,
    required double budgetAmount,
  }) {
    return ExhibitionActionResult(
      method: 'POST',
      path: ExhibitionCanonicalPaths.projectCreate,
      isSuccess: true,
      payload: <String, Object?>{
        'projectId': '$demoProjectId-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'buildingType': buildingType,
        'budgetAmount': budgetAmount,
        'state': 'published',
        'summary': _summary('project-create-demo'),
      },
      controlledState: AppPageState.content,
      message: '当前结果来自演示内容。',
    );
  }

  static ExhibitionActionResult bidSubmit({required String projectId}) {
    return ExhibitionActionResult(
      method: 'POST',
      path: ExhibitionCanonicalPaths.bidSubmit,
      isSuccess: true,
      payload: <String, Object?>{
        'bidId': demoBidId,
        'projectId': _idOrFallback(projectId, demoProjectId),
        'state': 'submitted',
        'summary': _summary('bid-submit-demo'),
      },
      controlledState: AppPageState.content,
      message: '当前结果来自演示内容。',
    );
  }

  static ExhibitionActionResult milestoneSubmit({required String milestoneId}) {
    return ExhibitionActionResult(
      method: 'POST',
      path: ExhibitionCanonicalPaths.milestoneSubmit,
      isSuccess: true,
      payload: <String, Object?>{
        'milestoneId': _idOrFallback(milestoneId, demoMilestoneId),
        'state': 'submitted',
        'summary': _summary('milestone-submit-demo'),
      },
      controlledState: AppPageState.content,
      message: '当前结果来自演示内容。',
    );
  }

  static ExhibitionActionResult inspectionSubmit({
    required String milestoneId,
  }) {
    return ExhibitionActionResult(
      method: 'POST',
      path: ExhibitionCanonicalPaths.inspectionSubmit,
      isSuccess: true,
      payload: <String, Object?>{
        'inspectionId': demoInspectionId,
        'milestoneId': _idOrFallback(milestoneId, demoMilestoneId),
        'state': 'submitted',
        'summary': _summary('inspection-submit-demo'),
      },
      controlledState: AppPageState.content,
      message: '当前结果来自演示内容。',
    );
  }

  static ExhibitionActionResult disputeOpen({required String orderId}) {
    return ExhibitionActionResult(
      method: 'POST',
      path: ExhibitionCanonicalPaths.disputeOpen,
      isSuccess: true,
      payload: <String, Object?>{
        'disputeId': demoDisputeId,
        'orderId': _idOrFallback(orderId, demoOrderId),
        'state': 'opened',
        'summary': _summary('dispute-open-demo'),
      },
      controlledState: AppPageState.content,
      message: '当前结果来自演示内容。',
    );
  }

  static Map<String, Object?> _summary(String heading) {
    return <String, Object?>{'heading': heading};
  }

  static Map<String, Object?> _projectItem({
    required String projectId,
    required String projectNo,
    required String title,
    required num budgetAmount,
    required String state,
  }) {
    return <String, Object?>{
      'projectId': projectId,
      'projectNo': projectNo,
      'title': title,
      'buildingType': 'exhibition',
      'budgetAmount': budgetAmount,
      'state': state,
      'summary': _summary('project-item-demo'),
    };
  }

  static Map<String, Object?> _milestoneItem({
    required String milestoneId,
    required String orderId,
    required String title,
    required num amount,
    required String state,
  }) {
    return <String, Object?>{
      'milestoneId': milestoneId,
      'orderId': orderId,
      'title': title,
      'amount': amount,
      'state': state,
      'summary': _summary('milestone-item-demo'),
    };
  }

  static Map<String, Object?> _myProjectItem({
    required Map<String, Object?> publicProject,
    required Map<String, Object?> privateProgress,
  }) {
    return <String, Object?>{
      'publicProject': publicProject,
      'privateSummary': privateProgress,
    };
  }

  static Map<String, Object?> _myProjectPrivateProgress({
    required bool hasAcceptedOrder,
    required String formalCompletionStatus,
    required String evaluationStatus,
  }) {
    return <String, Object?>{
      'hasAcceptedOrder': hasAcceptedOrder,
      'orderStatus': null,
      'contractStatus': null,
      'fulfillmentStatus': null,
      'acceptanceStatus': null,
      'afterSalesOrDisputeStatus': null,
      'formalCompletionStatus': formalCompletionStatus,
      'evaluationStatus': evaluationStatus,
    };
  }

  static String _idOrFallback(String? value, String fallback) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }
    return trimmed;
  }
}
