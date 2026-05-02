part of '../exhibition_trade_pages.dart';

class ProjectCreatePage extends StatefulWidget {
  const ProjectCreatePage({super.key, this.projectId});

  final String? projectId;

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

enum _ProjectCreateFieldId {
  title,
  brandName,
  buildingType,
  buildingTypeRemark,
  budgetAmount,
  areaSqm,
  provinceName,
  cityName,
  districtName,
  detailAddress,
  scopeSummary,
  plannedStartAt,
  plannedEndAt,
  scheduleDetail,
  description,
}

String _projectCreateFieldLabel(_ProjectCreateFieldId fieldId) {
  return switch (fieldId) {
    _ProjectCreateFieldId.title => '展会',
    _ProjectCreateFieldId.brandName => '品牌',
    _ProjectCreateFieldId.buildingType => '项目类型',
    _ProjectCreateFieldId.buildingTypeRemark => '项目类型说明',
    _ProjectCreateFieldId.budgetAmount => '预算金额',
    _ProjectCreateFieldId.areaSqm => '面积',
    _ProjectCreateFieldId.provinceName => '省份',
    _ProjectCreateFieldId.cityName => '城市',
    _ProjectCreateFieldId.districtName => '区/县',
    _ProjectCreateFieldId.detailAddress => '详细地址',
    _ProjectCreateFieldId.scopeSummary => '范围说明',
    _ProjectCreateFieldId.plannedStartAt => '计划开始日期',
    _ProjectCreateFieldId.plannedEndAt => '计划结束日期',
    _ProjectCreateFieldId.scheduleDetail => '详细时间',
    _ProjectCreateFieldId.description => '补充说明',
  };
}

String? _projectCreateValidationSummary(
  Map<_ProjectCreateFieldId, String> errors,
) {
  if (errors.isEmpty) {
    return null;
  }

  final messages = errors.entries
      .map(
        (MapEntry<_ProjectCreateFieldId, String> entry) =>
            _projectCreateValidationErrorText(entry.key, entry.value),
      )
      .where((String value) => value.trim().isNotEmpty)
      .toSet()
      .toList(growable: false);
  if (messages.isEmpty) {
    return '还有项目基本信息没有填完，请先补齐必填项后再保存。';
  }

  return '无法保存：${messages.join('；')}。';
}

String _projectCreateValidationErrorText(
  _ProjectCreateFieldId fieldId,
  String error,
) {
  final normalizedError = error.trim();
  if (normalizedError.isNotEmpty) {
    return normalizedError.replaceAll(RegExp(r'[。；;]+$'), '');
  }
  return '请补充${_projectCreateFieldLabel(fieldId)}';
}

class _ProjectCreateValidationResult {
  const _ProjectCreateValidationResult(this.errors);

  final Map<_ProjectCreateFieldId, String> errors;

  bool get isValid => errors.isEmpty;

  _ProjectCreateFieldId? get firstInvalidFieldId =>
      errors.isEmpty ? null : errors.keys.first;

  String? get formMessage => _projectCreateValidationSummary(errors);
}

class ProjectCreateFailureBarrier {
  const ProjectCreateFailureBarrier({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionRouteName,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String actionRouteName;
}

ProjectCreateFailureBarrier? resolveProjectCreateFailureBarrier({
  required AppPageState? state,
  required String? errorCode,
  required bool shellReportsNoOrganization,
  required bool missingOrganizationId,
  String? message,
}) {
  final normalizedErrorCode = errorCode?.trim();
  if (state == AppPageState.unauthorized ||
      normalizedErrorCode == 'AUTH_SESSION_INVALID') {
    return const ProjectCreateFailureBarrier(
      title: '请先登录',
      message: '当前登录状态已失效，先重新登录后再创建项目。',
      actionLabel: '去登录',
      actionRouteName: ProfileIdentityRoutes.login,
    );
  }

  final normalizedMessage = message?.trim().toLowerCase();
  final likelyOrganizationUnavailable =
      shellReportsNoOrganization ||
      missingOrganizationId ||
      normalizedMessage?.contains('组织') == true ||
      normalizedMessage?.contains('organization') == true ||
      normalizedMessage?.contains('org ') == true;
  if (normalizedErrorCode == 'AUTH_RESOURCE_UNAVAILABLE' &&
      likelyOrganizationUnavailable) {
    return const ProjectCreateFailureBarrier(
      title: '请先加入组织',
      message: '当前账号缺少组织信息，先完成组织承接后再创建项目。',
      actionLabel: '去完善组织',
      actionRouteName: ProfileIdentityRoutes.organizationHandoff,
    );
  }

  if (state == AppPageState.forbidden &&
      normalizedErrorCode == 'AUTH_PERMISSION_INSUFFICIENT') {
    return const ProjectCreateFailureBarrier(
      title: '当前角色不允许创建项目',
      message: '当前组织角色暂不允许创建项目，请先返回我的项目查看当前可继续入口。',
      actionLabel: '返回我的项目',
      actionRouteName: ExhibitionRoutes.myProjectList,
    );
  }

  return null;
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  static const String _roundABuildingType = 'exhibition';
  static const List<String> _projectTypeOptions = <String>[
    '会展',
    '展厅',
    '商业活动',
    '会议',
    '路演',
    '美陈',
    '纯安装',
    '其他',
  ];
  static final RegExp _canonicalDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp _visibleDatePattern = RegExp(
    r'^(\d{4})年(\d{1,2})月(\d{1,2})日$',
  );
  static final RegExp _areaSqmPattern = RegExp(r'^\d+(?:\.\d{1,2})?$');
  static const int _buildingTypeRemarkMaxLength = 100;
  static const int _scheduleDetailMaxLength = 200;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _buildingTypeController = TextEditingController();
  final TextEditingController _buildingTypeRemarkController =
      TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();
  final TextEditingController _areaSqmController = TextEditingController();
  final TextEditingController _provinceNameController = TextEditingController();
  final TextEditingController _cityNameController = TextEditingController();
  final TextEditingController _districtNameController = TextEditingController();
  final TextEditingController _detailAddressController =
      TextEditingController();
  final TextEditingController _scopeSummaryController = TextEditingController();
  final TextEditingController _plannedStartAtController =
      TextEditingController();
  final TextEditingController _plannedEndAtController = TextEditingController();
  final TextEditingController _scheduleDetailController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _p0PayMaterialFileAssetIdsController =
      TextEditingController();
  final TextEditingController _p0PayQuoteDeadlineAtController =
      TextEditingController();
  final TextEditingController _p0PayContactIdController = TextEditingController(
    text: 'primary-contact',
  );
  final Map<_ProjectCreateFieldId, GlobalKey> _fieldKeys =
      <_ProjectCreateFieldId, GlobalKey>{
        for (final fieldId in _ProjectCreateFieldId.values)
          fieldId: GlobalKey(),
      };
  final GlobalKey _editReviewSectionKey = GlobalKey();
  final GlobalKey _editReviewContentKey = GlobalKey();
  ChinaRegionCatalog? _regionCatalog;
  _ProjectStandardizedLocationOption? _selectedStandardizedLocation;
  String? _selectedDistrictCode;

  bool _guardLoading = true;
  _ProjectCreateAccessGuard _accessGuard =
      const _ProjectCreateAccessGuard.allowed();
  bool _guardInitialized = false;
  bool _editDetailLoading = false;
  ExhibitionLoadResult? _editDetailResult;
  int _guardRetryCount = 0;
  bool _submitting = false;
  bool _p0PaySubmitting = false;
  String _p0PayTaskType = _projectQuoteIntentionFixedPrice;
  bool _p0PayDemandExistsConfirmed = false;
  bool _p0PayAuthorizationConfirmed = false;
  bool _p0PayNoQuoteHarvestingConfirmed = false;
  bool _p0PayResultProcessingConfirmed = false;
  bool _p0PayCreditImpactAcknowledged = false;
  ExhibitionActionResult? _lastResult;
  ExhibitionActionResult? _p0PayTaskResult;
  ExhibitionActionResult? _p0PayDepositOrderResult;
  ExhibitionActionResult? _p0PayDepositInitResult;
  ExhibitionLoadResult? _p0PayDepositStatusResult;
  P0PayPaymentPollResult? _p0PayDepositPollResult;
  bool? _editReviewExpandedOverride;
  Map<_ProjectCreateFieldId, String> _fieldErrors =
      <_ProjectCreateFieldId, String>{};
  String? _formErrorMessage;

  String? get _selectedProjectTypeLabel {
    final value = _buildingTypeController.text.trim();
    return value.isEmpty ? null : value;
  }

  String? get _selectedStandardizedLocationLabel =>
      _selectedStandardizedLocation?.displayLabel;

  _ProjectStandardizedLocationDistrictOption? get _selectedDistrictOption {
    final districtCode = _selectedDistrictCode;
    final location = _selectedStandardizedLocation;
    if (districtCode == null || location == null) {
      return null;
    }
    return location.districtByCode(districtCode);
  }

  bool get _isEditMode {
    final projectId = widget.projectId;
    return projectId != null && projectId.trim().isNotEmpty;
  }

  String? get _editingProjectId {
    final projectId = widget.projectId?.trim();
    return projectId == null || projectId.isEmpty ? null : projectId;
  }

  @override
  void initState() {
    super.initState();
    _primeRegionCatalog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_guardInitialized) {
      return;
    }
    _guardInitialized = true;
    if (_isEditMode) {
      _loadProjectForEdit();
      return;
    }
    _loadAccessGuard();
  }

  @override
  void dispose() {
    _publishProjectEditHeaderStatus(_editingProjectId, null);
    _titleController.dispose();
    _brandNameController.dispose();
    _buildingTypeController.dispose();
    _buildingTypeRemarkController.dispose();
    _budgetAmountController.dispose();
    _areaSqmController.dispose();
    _provinceNameController.dispose();
    _cityNameController.dispose();
    _districtNameController.dispose();
    _detailAddressController.dispose();
    _scopeSummaryController.dispose();
    _plannedStartAtController.dispose();
    _plannedEndAtController.dispose();
    _scheduleDetailController.dispose();
    _descriptionController.dispose();
    _p0PayMaterialFileAssetIdsController.dispose();
    _p0PayQuoteDeadlineAtController.dispose();
    _p0PayContactIdController.dispose();
    super.dispose();
  }

  Future<void> _createP0PayTradeTask() async {
    FocusScope.of(context).unfocus();
    final validationMessage = _p0PayTradeTaskBlockerMessage();
    if (validationMessage != null) {
      setState(() {
        _p0PayTaskResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.p0PayTradeTaskCreate,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: validationMessage,
        );
      });
      return;
    }

    final standardizedLocation = _selectedStandardizedLocation!;
    final area = _parseAreaSqmInput(_areaSqmController.text.trim())!;
    final budgetAmount = double.parse(_budgetAmountController.text.trim());
    final buildStartAt =
        _normalizeDateInput(_plannedStartAtController.text.trim()) ?? '';
    final dismantleAt =
        _normalizeDateInput(_plannedEndAtController.text.trim()) ?? '';
    final projectName = _composeProjectTitle(
      _titleController.text.trim(),
      _brandNameController.text.trim(),
    );

    setState(() {
      _p0PaySubmitting = true;
      _p0PayTaskResult = null;
      _p0PayDepositOrderResult = null;
      _p0PayDepositInitResult = null;
      _p0PayDepositStatusResult = null;
      _p0PayDepositPollResult = null;
    });

    final taskResult = await ExhibitionConsumerLayer.instance
        .createP0PayTradeTask(
          P0PayTradeTaskCreateCommand(
            taskType: _p0PayTaskType,
            projectName: projectName,
            cityCode: standardizedLocation.cityCode,
            projectType: _normalizeBuildingTypeSelection(
              _buildingTypeController.text.trim(),
            ),
            exhibitionName: _titleController.text.trim(),
            area: area,
            buildStartAt: buildStartAt,
            dismantleAt: dismantleAt,
            requirementDescription: _p0PayRequirementDescription(),
            budgetAmount: budgetAmount,
            budgetRange: 'CNY ${budgetAmount.toStringAsFixed(2)}',
            quoteDeadlineAt: _p0PayQuoteDeadlineAtController.text.trim(),
            contactId: _p0PayContactIdController.text.trim(),
            authenticityMaterialFileAssetIds: _p0PayMaterialFileAssetIds(),
            authenticityDeclarations: _p0PayAuthenticityDeclarations(),
          ),
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _p0PayTaskResult = taskResult;
      _p0PaySubmitting =
          _p0PayTaskType == _projectQuoteIntentionInquiry &&
          taskResult.isSuccess;
    });

    final taskId = _taskIdFromPayload(taskResult.payload);
    if (!taskResult.isSuccess ||
        _p0PayTaskType != _projectQuoteIntentionInquiry ||
        taskId == null) {
      if (mounted) {
        setState(() {
          _p0PaySubmitting = false;
        });
      }
      return;
    }

    final depositResult = await ExhibitionConsumerLayer.instance
        .createP0PayInquiryDepositOrder(
          taskId: taskId,
          command: P0PayInquiryDepositOrderCommand(
            ruleVersion: 'p0-pay-v1.3',
            ruleSnapshotHash: 'p0-pay-v1.3-freeze',
          ),
        );

    if (!mounted) {
      return;
    }
    setState(() {
      _p0PayDepositOrderResult = depositResult;
    });

    final depositOrderId = _depositOrderIdFromPayload(depositResult.payload);
    if (!depositResult.isSuccess || depositOrderId == null) {
      setState(() {
        _p0PaySubmitting = false;
      });
      return;
    }

    final initResult = await ExhibitionConsumerLayer.instance
        .initP0PayInquiryDepositPayment(
          taskId: taskId,
          depositOrderId: depositOrderId,
          command: P0PayPayInitCommand(payChannel: 'alipay_candidate'),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _p0PayDepositInitResult = initResult;
    });
    if (!initResult.isSuccess) {
      setState(() {
        _p0PaySubmitting = false;
      });
      return;
    }
    await _openP0PayChannelPayload(initResult.payload);
    await _pollP0PayInquiryDepositStatus();
    if (mounted) {
      setState(() {
        _p0PaySubmitting = false;
      });
    }
  }

  Future<void> _submitCreate() async {
    FocusScope.of(context).unfocus();

    if (_guardLoading) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.projectCreate,
          isSuccess: false,
          controlledState: AppPageState.errorRetryable,
          message: '当前正在核对发布守卫，请稍候再试。',
        );
      });
      return;
    }

    if (_accessGuard.blocked) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.projectCreate,
          isSuccess: false,
          controlledState: AppPageState.forbidden,
          message: _accessGuard.message,
        );
      });
      return;
    }

    final selectedProjectType = _buildingTypeController.text.trim();
    final budgetText = _budgetAmountController.text.trim();
    final areaSqmText = _areaSqmController.text.trim();
    final plannedStartAtInput = _plannedStartAtController.text.trim();
    final plannedEndAtInput = _plannedEndAtController.text.trim();
    final budgetAmount = double.tryParse(budgetText);
    final areaSqm = _parseAreaSqmInput(areaSqmText);
    final standardizedLocation = _selectedStandardizedLocation;
    final districtOption = _selectedDistrictOption;
    final validation = _validateForm(
      exhibitionName: _titleController.text.trim(),
      brandName: _brandNameController.text.trim(),
      selectedProjectType: selectedProjectType,
      buildingTypeRemark: _buildingTypeRemarkController.text.trim(),
      budgetText: budgetText,
      budgetAmount: budgetAmount,
      areaSqmText: areaSqmText,
      areaSqm: areaSqm,
      provinceCode: standardizedLocation?.provinceCode,
      provinceName: _provinceNameController.text.trim(),
      cityCode: standardizedLocation?.cityCode,
      cityName: _cityNameController.text.trim(),
      districtCode: districtOption?.districtCode,
      districtName: _districtNameController.text.trim(),
      detailAddress: _detailAddressController.text.trim(),
      scopeSummary: _scopeSummaryController.text.trim(),
      plannedStartAt: plannedStartAtInput,
      plannedEndAt: plannedEndAtInput,
      scheduleDetail: _scheduleDetailController.text.trim(),
    );

    if (!validation.isValid) {
      _applyValidationFeedback(validation);
      return;
    }

    final plannedStartAt = _normalizeDateInput(plannedStartAtInput) ?? '';
    final plannedEndAt = _normalizeDateInput(plannedEndAtInput) ?? '';
    final exhibitionName = _titleController.text.trim();
    final brandName = _brandNameController.text.trim();
    final compatibleTitle = _composeProjectTitle(exhibitionName, brandName);

    setState(() {
      _submitting = true;
      _lastResult = null;
      _fieldErrors = <_ProjectCreateFieldId, String>{};
      _formErrorMessage = null;
    });

    final result = await ExhibitionConsumerLayer.instance.createProject(
      ProjectCreateCommand(
        title: compatibleTitle,
        exhibitionName: exhibitionName,
        brandName: brandName,
        buildingType: _normalizeBuildingTypeSelection(selectedProjectType),
        budgetAmount: budgetAmount!,
        areaSqm: areaSqm,
        buildingTypeRemark: _normalizeOptionalText(
          _buildingTypeRemarkController.text,
        ),
        provinceCode: standardizedLocation!.provinceCode,
        provinceName: _provinceNameController.text.trim(),
        cityCode: standardizedLocation.cityCode,
        cityName: _cityNameController.text.trim(),
        districtCode: districtOption?.districtCode,
        districtName: _districtNameController.text.trim(),
        detailAddress: _detailAddressController.text.trim(),
        scopeSummary: _normalizeOptionalText(_scopeSummaryController.text),
        plannedStartAt: plannedStartAt,
        plannedEndAt: plannedEndAt,
        scheduleDetail: _normalizeOptionalText(_scheduleDetailController.text),
        description: _descriptionController.text.trim(),
      ),
    );
    if (result.isSuccess) {
      final createdProjectId = _projectIdFromPayload(result.payload);
      final landingRoute = createdProjectId == null
          ? ExhibitionRoutes.myProjectListWithStage(
              workspace: 'published',
              stage: 'draft',
            )
          : ExhibitionRoutes.myProjectDraftboxWithProjectId(createdProjectId);
      ExhibitionConsumerLayer.instance.invalidateMyProjectList();
      await ExhibitionConsumerLayer.instance.loadMyProjectList(
        forceRefresh: true,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _submitting = false;
        _lastResult = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          landingRoute,
          (Route<dynamic> route) =>
              route.settings.name == AppBuilding.exhibition.routePath,
        );
      });
      return;
    }

    if (!mounted) {
      return;
    }

    final failureGuard = _guardFromCreateFailure(result);
    setState(() {
      _submitting = false;
      _lastResult = result;
      if (failureGuard != null) {
        _guardLoading = false;
        _accessGuard = failureGuard;
      }
    });

    final failureMessage = result.message?.trim();
    if (failureMessage != null && failureMessage.isNotEmpty) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  Future<void> _openProjectDetail(String projectId) async {
    await ExhibitionConsumerLayer.instance.loadProjectDetail(
      projectId: projectId,
      forceRefresh: true,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.projectDetailWithProjectId(projectId));
  }

  Future<void> _openMyProjectList() async {
    await ExhibitionConsumerLayer.instance.loadMyProjectList(
      forceRefresh: true,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(ExhibitionRoutes.myProjectList);
  }

  Future<void> _openMyProjectDetail(String projectId) async {
    await ExhibitionConsumerLayer.instance.loadMyProjectDetail(
      projectId: projectId,
      forceRefresh: true,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.myProjectDetailWithProjectId(projectId));
  }

  Future<void> _openProjectEdit(String projectId) async {
    await ExhibitionConsumerLayer.instance.loadProjectEditDetail(
      projectId: projectId,
      forceRefresh: true,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.projectEditWithProjectId(projectId));
  }

  _ProjectCreateAccessGuard? _guardFromCreateFailure(
    ExhibitionActionResult result,
  ) {
    final snapshot = AppShellScope.read(context).snapshot;
    final barrier = resolveProjectCreateFailureBarrier(
      state: result.controlledState,
      errorCode: result.errorCode,
      shellReportsNoOrganization:
          snapshot.blockingState == GlobalShellState.noOrganization,
      missingOrganizationId:
          snapshot.shellContext.organizationId?.trim().isEmpty ?? true,
      message: result.message,
    );
    if (barrier == null) {
      return null;
    }
    return _ProjectCreateAccessGuard.blocked(
      title: barrier.title,
      message: barrier.message,
      actionLabel: barrier.actionLabel,
      actionRouteName: barrier.actionRouteName,
    );
  }

  Future<void> _loadProjectForEdit({bool forceRefresh = false}) async {
    final projectId = _editingProjectId;
    if (projectId == null) {
      return;
    }

    setState(() {
      _editDetailLoading = true;
      _lastResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.loadProjectEditDetail(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      _hydrateProjectForm(
        _payloadMap(result.payload) ?? const <String, Object?>{},
      );
    }
    _publishProjectEditHeaderStatus(
      projectId,
      _stateFromPayload(result.payload),
    );

    setState(() {
      _editDetailResult = result;
      _editDetailLoading = false;
    });
  }

  void _hydrateProjectForm(Map<String, Object?> payload) {
    final exhibitionName = _projectExhibitionName(payload);
    final brandName = _projectBrandName(payload);
    final title = _normalizeId(payload['title'] as String?);
    final buildingType = _normalizeId(payload['buildingType'] as String?);
    final areaSqm = payload['areaSqm'] as num?;
    final standardizedLocation = _projectLocationOptionFromPayload(
      payload,
      catalog: _regionCatalog,
    );
    final districtCode = _normalizeId(payload['districtCode'] as String?);
    final districtName = _normalizeId(payload['districtName'] as String?);
    _titleController.text = exhibitionName ?? title ?? '';
    _brandNameController.text = brandName ?? '';
    _buildingTypeController.text = _buildingTypePickerLabel(buildingType);
    _buildingTypeRemarkController.text =
        _normalizeId(payload['buildingTypeRemark'] as String?) ?? '';
    _budgetAmountController.text = _projectBudgetAmountText(
      payload['budgetAmount'],
    );
    _areaSqmController.text = areaSqm == null
        ? ''
        : areaSqm.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    _selectedStandardizedLocation = standardizedLocation;
    _provinceNameController.text =
        _normalizeId(payload['provinceName'] as String?) ?? '';
    _cityNameController.text =
        _normalizeId(payload['cityName'] as String?) ?? '';
    _selectedDistrictCode = districtCode;
    _districtNameController.text = districtName ?? '';
    _detailAddressController.text =
        _normalizeId(payload['detailAddress'] as String?) ?? '';
    _scopeSummaryController.text =
        _normalizeId(payload['scopeSummary'] as String?) ?? '';
    _plannedStartAtController.text = _displayDateFromCanonical(
      payload['plannedStartAt'] as String?,
    );
    _plannedEndAtController.text = _displayDateFromCanonical(
      payload['plannedEndAt'] as String?,
    );
    _scheduleDetailController.text =
        _normalizeId(payload['scheduleDetail'] as String?) ?? '';
    _descriptionController.text =
        _normalizeId(payload['description'] as String?) ?? '';
    _fieldErrors = <_ProjectCreateFieldId, String>{};
    _formErrorMessage = null;
  }

  Future<void> _saveProject() async {
    await _runLifecycleMutation(
      action: () => ExhibitionConsumerLayer.instance.saveProject(
        _buildProjectSaveCommand(),
      ),
    );
  }

  Future<void> _submitProject() async {
    final projectId = _editingProjectId;
    if (projectId == null) {
      return;
    }
    await _runLifecycleMutation(
      action: () => ExhibitionConsumerLayer.instance.submitProject(
        ProjectLifecycleActionCommand(projectId: projectId),
      ),
    );
  }

  Future<void> _runLifecycleMutation({
    required Future<ExhibitionActionResult> Function() action,
  }) async {
    FocusScope.of(context).unfocus();
    final projectId = _editingProjectId;
    if (projectId == null) {
      return;
    }

    final validation = _validateCurrentForm();
    if (!validation.isValid) {
      _applyValidationFeedback(validation);
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
      _fieldErrors = <_ProjectCreateFieldId, String>{};
      _formErrorMessage = null;
    });

    final result = await action();
    if (result.isSuccess) {
      ExhibitionConsumerLayer.instance.invalidateMyProjectList();
      await Future.wait<void>(<Future<void>>[
        ExhibitionConsumerLayer.instance.loadProjectDetail(
          projectId: projectId,
          forceRefresh: true,
        ),
        ExhibitionConsumerLayer.instance.loadMyProjectDetail(
          projectId: projectId,
          forceRefresh: true,
        ),
      ]);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _lastResult = result;
    });

    if (result.isSuccess) {
      await _loadProjectForEdit(forceRefresh: true);
    }
  }

  _ProjectCreateValidationResult _validateCurrentForm() {
    final selectedProjectType = _buildingTypeController.text.trim();
    final budgetText = _budgetAmountController.text.trim();
    final areaSqmText = _areaSqmController.text.trim();
    final plannedStartAtInput = _plannedStartAtController.text.trim();
    final plannedEndAtInput = _plannedEndAtController.text.trim();
    final budgetAmount = double.tryParse(budgetText);
    final areaSqm = _parseAreaSqmInput(areaSqmText);
    final standardizedLocation = _selectedStandardizedLocation;
    final districtOption = _selectedDistrictOption;

    return _validateForm(
      exhibitionName: _titleController.text.trim(),
      brandName: _brandNameController.text.trim(),
      selectedProjectType: selectedProjectType,
      buildingTypeRemark: _buildingTypeRemarkController.text.trim(),
      budgetText: budgetText,
      budgetAmount: budgetAmount,
      areaSqmText: areaSqmText,
      areaSqm: areaSqm,
      provinceCode: standardizedLocation?.provinceCode,
      provinceName: _provinceNameController.text.trim(),
      cityCode: standardizedLocation?.cityCode,
      cityName: _cityNameController.text.trim(),
      districtCode: districtOption?.districtCode ?? _selectedDistrictCode,
      districtName: _districtNameController.text.trim(),
      detailAddress: _detailAddressController.text.trim(),
      scopeSummary: _scopeSummaryController.text.trim(),
      plannedStartAt: plannedStartAtInput,
      plannedEndAt: plannedEndAtInput,
      scheduleDetail: _scheduleDetailController.text.trim(),
    );
  }

  ProjectSaveCommand _buildProjectSaveCommand() {
    final selectedProjectType = _buildingTypeController.text.trim();
    final budgetAmount = double.parse(_budgetAmountController.text.trim());
    final areaSqm = _parseAreaSqmInput(_areaSqmController.text.trim());
    final standardizedLocation = _selectedStandardizedLocation!;
    final districtOption = _selectedDistrictOption;
    final plannedStartAt =
        _normalizeDateInput(_plannedStartAtController.text.trim()) ?? '';
    final plannedEndAt =
        _normalizeDateInput(_plannedEndAtController.text.trim()) ?? '';
    final exhibitionName = _titleController.text.trim();
    final brandName = _brandNameController.text.trim();
    return ProjectSaveCommand(
      projectId: _editingProjectId!,
      title: _composeProjectTitle(exhibitionName, brandName),
      exhibitionName: exhibitionName,
      brandName: brandName,
      buildingType: _normalizeBuildingTypeSelection(selectedProjectType),
      budgetAmount: budgetAmount,
      areaSqm: areaSqm,
      buildingTypeRemark: _normalizeOptionalText(
        _buildingTypeRemarkController.text,
      ),
      provinceCode: standardizedLocation.provinceCode,
      provinceName: _provinceNameController.text.trim(),
      cityCode: standardizedLocation.cityCode,
      cityName: _cityNameController.text.trim(),
      districtCode: districtOption?.districtCode ?? _selectedDistrictCode,
      districtName: _normalizeOptionalText(_districtNameController.text),
      detailAddress: _detailAddressController.text.trim(),
      scopeSummary: _normalizeOptionalText(_scopeSummaryController.text),
      plannedStartAt: plannedStartAt,
      plannedEndAt: plannedEndAt,
      scheduleDetail: _normalizeOptionalText(_scheduleDetailController.text),
      description: _normalizeOptionalText(_descriptionController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _isEditMode;
    final editResult = _editDetailResult;
    final editState = _stateFromPayload(editResult?.payload);
    final editContentReady =
        editResult?.state == AppPageState.content && _editingProjectId != null;

    return _SubmissionPageFrame(
      title: isEditMode ? '编辑项目' : '创建项目',
      summary: isEditMode
          ? '继续查看当前项目编辑回显，并按当前生命周期选择下一步。'
          : '先保存项目基本信息，成功后直接跳转到我的项目草稿箱继续处理。',
      canonicalPath: isEditMode
          ? ExhibitionCanonicalPaths.projectSave
          : ExhibitionCanonicalPaths.projectCreate,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submitCreate,
      submitButtonLabel: '保存并查看我的项目',
      submitHintText: isEditMode ? null : '保存后可在“我的项目”继续编辑和进入预发布核对。',
      bottomPadding: isEditMode ? 28 : 96,
      showSubmitButton: !isEditMode && !_guardLoading && !_accessGuard.blocked,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showSourceNotice: false,
      showActionContainer: false,
      hideResultPanelOnSuccess: true,
      resultSectionsBuilder: (ExhibitionActionResult result) =>
          _buildResultSections(result),
      body: isEditMode
          ? _buildProjectEditBody(
              editContentReady: editContentReady,
              editResult: editResult,
              currentState: editState,
            )
          : <Widget>[
              const _ProjectPublishProgressCard(
                currentStep: _ProjectPublishProgressStep.basic,
                basicInfoOnlyNote: true,
                useDraftLandingCopy: true,
              ),
              const SizedBox(height: 16),
              ..._buildProjectCreateRoundABody(
                context: context,
                guardLoading: _guardLoading,
                accessGuard: _accessGuard,
                formErrorMessage: _formErrorMessage,
                selectedProjectTypeLabel: _selectedProjectTypeLabel,
                selectedStandardizedLocationLabel:
                    _selectedStandardizedLocationLabel,
                selectedP0PayTaskType: _p0PayTaskType,
                showSupplementalSection: false,
                hasStandardizedLocationSelection:
                    _selectedStandardizedLocation != null,
                districtSelectionEnabled:
                    _selectedStandardizedLocation?.districts.isNotEmpty ??
                    false,
                exhibitionNameController: _titleController,
                brandNameController: _brandNameController,
                buildingTypeController: _buildingTypeController,
                buildingTypeRemarkController: _buildingTypeRemarkController,
                budgetAmountController: _budgetAmountController,
                areaSqmController: _areaSqmController,
                provinceNameController: _provinceNameController,
                cityNameController: _cityNameController,
                districtNameController: _districtNameController,
                detailAddressController: _detailAddressController,
                scopeSummaryController: _scopeSummaryController,
                plannedStartAtController: _plannedStartAtController,
                plannedEndAtController: _plannedEndAtController,
                scheduleDetailController: _scheduleDetailController,
                descriptionController: _descriptionController,
                fieldKeys: _fieldKeys,
                fieldErrors: _fieldErrors,
                onFieldInteracted: _handleFieldInteracted,
                onProjectTypePressed: _pickProjectType,
                onStandardizedLocationPressed: _pickStandardizedLocation,
                onDistrictPressed: _pickDistrict,
                onScopeSummaryPressed: _editScopeSummary,
                onP0PayTaskTypeChanged: _setP0PayTaskTypeFromCreateChoice,
                onPlannedStartDatePressed: () => _pickDate(
                  controller: _plannedStartAtController,
                  fieldId: _ProjectCreateFieldId.plannedStartAt,
                ),
                onPlannedEndDatePressed: () => _pickDate(
                  controller: _plannedEndAtController,
                  fieldId: _ProjectCreateFieldId.plannedEndAt,
                ),
                onPlannedStartDateCleared: () => _clearDate(
                  controller: _plannedStartAtController,
                  fieldId: _ProjectCreateFieldId.plannedStartAt,
                ),
                onPlannedEndDateCleared: () => _clearDate(
                  controller: _plannedEndAtController,
                  fieldId: _ProjectCreateFieldId.plannedEndAt,
                ),
              ),
            ],
    );
  }

  void _setP0PayTaskTypeFromCreateChoice(String? value) {
    if (value != _projectQuoteIntentionFixedPrice &&
        value != _projectQuoteIntentionInquiry) {
      return;
    }
    setState(() {
      _p0PayTaskType = value!;
      _p0PayTaskResult = null;
      _p0PayDepositOrderResult = null;
      _p0PayDepositInitResult = null;
      _p0PayDepositStatusResult = null;
      _p0PayDepositPollResult = null;
    });
  }

  // ignore: unused_element
  Widget _buildP0PayTradeTaskSection() {
    final declarationsCompleted = _p0PayDeclarationsCompleted;
    final materials = _p0PayMaterialFileAssetIds();
    final canSubmit =
        !_p0PaySubmitting &&
        declarationsCompleted &&
        materials.isNotEmpty &&
        _p0PayTradeTaskBlockerMessage() == null;
    final isInquiry = _p0PayTaskType == _projectQuoteIntentionInquiry;

    return _ActionCard(
      title: '发布收费承接',
      summary: '当前入口仅保留为历史兼容承接；普通项目发布请按预发布流程补资料，并完成项目真实性诚意金。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        const _StateMessage(
          title: '真实性资料与费用',
          body: '展开后补充项目真实性资料，并按平台规则继续处理当前项目的 200 元项目真实性诚意金。',
        ),
        ExpansionTile(
          initiallyExpanded:
              _p0PayTaskResult != null ||
              _p0PayDepositOrderResult != null ||
              _p0PayDepositInitResult != null ||
              _p0PayDepositStatusResult != null,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: const Text('展开发布收费承接'),
          children: <Widget>[
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: _projectQuoteIntentionFixedPrice,
                  label: Text('公开竞标'),
                  icon: Icon(Icons.gavel_outlined),
                ),
                ButtonSegment<String>(
                  value: _projectQuoteIntentionInquiry,
                  label: Text('报价咨询'),
                  icon: Icon(Icons.request_quote_outlined),
                ),
              ],
              selected: <String>{_p0PayTaskType},
              onSelectionChanged: (Set<String> value) {
                _setP0PayTaskTypeFromCreateChoice(value.first);
              },
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: _p0PayMaterialFileAssetIdsController,
              inputKey: const ValueKey<String>(
                'p0-pay-authenticity-material-ids',
              ),
              label: '真实性材料编号',
              hintText: '例如：file-1,file-2',
              helperText: '只填写已完成上传的资料编号，不填写存储路径。',
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            _InputField(
              controller: _p0PayQuoteDeadlineAtController,
              inputKey: const ValueKey<String>('p0-pay-quote-deadline-at'),
              label: '报价截止时间',
              hintText: '例如：2026-05-20T18:00:00+08:00',
              helperText: '报价截止后发布方必须处理选择、关闭或取消说明。',
              onChanged: (_) => setState(() {}),
            ),
            _InputField(
              controller: _p0PayContactIdController,
              inputKey: const ValueKey<String>('p0-pay-contact-id'),
              label: '联系人 ID',
              helperText: '用于项目发布后的联系承接，不在本页展示联系人详情。',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _buildP0PayDeclarationCheckbox(
              value: _p0PayDemandExistsConfirmed,
              title: '我确认本项目需求真实存在',
              onChanged: (bool value) =>
                  setState(() => _p0PayDemandExistsConfirmed = value),
            ),
            _buildP0PayDeclarationCheckbox(
              value: _p0PayAuthorizationConfirmed,
              title: '我确认已获得发布该项目需求的授权',
              onChanged: (bool value) =>
                  setState(() => _p0PayAuthorizationConfirmed = value),
            ),
            _buildP0PayDeclarationCheckbox(
              value: _p0PayNoQuoteHarvestingConfirmed,
              title: '我不会以套取报价、恶意比价、绕开平台交易为目的发布项目',
              onChanged: (bool value) =>
                  setState(() => _p0PayNoQuoteHarvestingConfirmed = value),
            ),
            _buildP0PayDeclarationCheckbox(
              value: _p0PayResultProcessingConfirmed,
              title: '我会在规定时间内处理报价或竞标结果',
              onChanged: (bool value) =>
                  setState(() => _p0PayResultProcessingConfirmed = value),
            ),
            _buildP0PayDeclarationCheckbox(
              value: _p0PayCreditImpactAcknowledged,
              title: '我知晓违规发布将影响企业信用，并可能限制后续发布权限',
              onChanged: (bool value) =>
                  setState(() => _p0PayCreditImpactAcknowledged = value),
            ),
            if (isInquiry) ...<Widget>[
              const SizedBox(height: 12),
              const _StateMessage(
                title: '项目真实性诚意金',
                body:
                    '这 200 元为当前项目的项目真实性诚意金，不是押金、罚款或平台服务费。项目成交成立或合规正式撤回后，将按平台记录进入原路退回流程。',
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey<String>('p0-pay-create-trade-task'),
              onPressed: canSubmit ? _createP0PayTradeTask : null,
              icon: _p0PaySubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(isInquiry ? '创建报价咨询并继续诚意金' : '创建公开竞标'),
            ),
            if (!canSubmit && !_p0PaySubmitting) ...<Widget>[
              const SizedBox(height: 8),
              _StateMessage(
                title: '提交条件未完成',
                body:
                    _p0PayTradeTaskBlockerMessage() ?? '请先补齐真实性材料，并勾选全部真实性声明。',
              ),
            ],
            ..._buildP0PayResultLines(),
          ],
        ),
      ],
    );
  }

  Widget _buildP0PayDeclarationCheckbox({
    required bool value,
    required String title,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      title: Text(title),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool? next) => onChanged(next ?? false),
    );
  }

  List<Widget> _buildP0PayResultLines() {
    final taskResult = _p0PayTaskResult;
    final depositResult = _p0PayDepositOrderResult;
    final initResult = _p0PayDepositInitResult;
    final statusResult = _p0PayDepositStatusResult;
    final pollResult = _p0PayDepositPollResult;
    if (taskResult == null &&
        depositResult == null &&
        initResult == null &&
        statusResult == null &&
        pollResult == null) {
      return const <Widget>[];
    }
    return <Widget>[
      const SizedBox(height: 12),
      if (taskResult != null)
        _DetailLine(
          label: '项目承接记录',
          value: taskResult.isSuccess
              ? '已创建：${_taskIdFromPayload(taskResult.payload) ?? '待回读'}'
              : taskResult.message ?? '创建失败',
          highlight: taskResult.isSuccess,
        ),
      if (depositResult != null)
        _DetailLine(
          label: '项目真实性诚意金订单',
          value: depositResult.isSuccess
              ? '已创建：${_depositOrderIdFromPayload(depositResult.payload) ?? '待回读'}'
              : depositResult.message ?? '创建失败',
          highlight: depositResult.isSuccess,
        ),
      if (initResult != null)
        _DetailLine(
          label: '支付通道',
          value: initResult.isSuccess
              ? '已拉起：${_paymentReferenceIdFromPayload(initResult.payload) ?? '等待通道确认'}'
              : _p0PayActionFailureText(initResult),
          highlight: initResult.isSuccess,
        ),
      if (statusResult != null)
        _DetailLine(
          label: '诚意金状态',
          value: _depositStatusText(statusResult),
          highlight:
              pollResult?.isSuccess ??
              statusResult.state == AppPageState.content,
        ),
      if (pollResult != null)
        _StateMessage(
          title: '支付结果',
          body: _p0PayPaymentPollResultText(pollResult),
        ),
      if (_depositOrderIdFromPayload(depositResult?.payload) != null)
        TextButton.icon(
          onPressed: _p0PaySubmitting ? null : _pollP0PayInquiryDepositStatus,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('重新轮询诚意金状态'),
        ),
    ];
  }

  Future<void> _pollP0PayInquiryDepositStatus() async {
    final taskId = _taskIdFromPayload(_p0PayTaskResult?.payload);
    final depositOrderId = _depositOrderIdFromPayload(
      _p0PayDepositOrderResult?.payload,
    );
    if (taskId == null || depositOrderId == null) {
      return;
    }
    final result = await ExhibitionConsumerLayer.instance
        .pollP0PayInquiryDepositStatus(
          taskId: taskId,
          depositOrderId: depositOrderId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _p0PayDepositPollResult = result;
      _p0PayDepositStatusResult = result.result;
    });
  }

  Future<void> _openP0PayChannelPayload(Object? payload) async {
    await _openPaymentChannelPayload(payload);
  }

  String? _p0PayTradeTaskBlockerMessage() {
    if (_guardLoading) {
      return '当前正在核对发布守卫，请稍候再试。';
    }
    if (_accessGuard.blocked) {
      return _accessGuard.message ?? '当前发布入口暂不可继续。';
    }
    if (_selectedStandardizedLocation == null) {
      return '请先选择项目所在省 / 市。';
    }
    if (_parseAreaSqmInput(_areaSqmController.text.trim()) == null) {
      return '当前项目需要填写项目面积。';
    }
    if (double.tryParse(_budgetAmountController.text.trim()) == null) {
      return '请先填写有效预算金额。';
    }
    if ((_normalizeDateInput(_plannedStartAtController.text.trim()) ?? '')
            .isEmpty ||
        (_normalizeDateInput(_plannedEndAtController.text.trim()) ?? '')
            .isEmpty) {
      return '请先填写搭建时间和撤展时间。';
    }
    if (_p0PayQuoteDeadlineAtController.text.trim().isEmpty) {
      return '请先填写报价截止时间。';
    }
    if (_p0PayContactIdController.text.trim().isEmpty) {
      return '请先填写联系人 ID。';
    }
    if (_p0PayMaterialFileAssetIds().isEmpty) {
      return '请先填写至少一个真实性材料编号。';
    }
    if (!_p0PayDeclarationsCompleted) {
      return '请先勾选全部真实性声明。';
    }
    return null;
  }

  bool get _p0PayDeclarationsCompleted =>
      _p0PayDemandExistsConfirmed &&
      _p0PayAuthorizationConfirmed &&
      _p0PayNoQuoteHarvestingConfirmed &&
      _p0PayResultProcessingConfirmed &&
      _p0PayCreditImpactAcknowledged;

  List<String> _p0PayMaterialFileAssetIds() {
    return _p0PayMaterialFileAssetIdsController.text
        .split(RegExp(r'[,，\s]+'))
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Map<String, bool> _p0PayAuthenticityDeclarations() {
    return <String, bool>{
      'demandExistsConfirmed': _p0PayDemandExistsConfirmed,
      'authorizationConfirmed': _p0PayAuthorizationConfirmed,
      'noQuoteHarvestingConfirmed': _p0PayNoQuoteHarvestingConfirmed,
      'resultProcessingConfirmed': _p0PayResultProcessingConfirmed,
      'creditImpactAcknowledged': _p0PayCreditImpactAcknowledged,
    };
  }

  String _p0PayRequirementDescription() {
    final parts = <String>[
      _scopeSummaryController.text.trim(),
      _descriptionController.text.trim(),
    ].where((String value) => value.isNotEmpty).toList(growable: false);
    return parts.isEmpty ? '项目需求待补充' : parts.join('\n');
  }

  List<Widget> _buildResultSections(ExhibitionActionResult result) {
    if (_isEditMode) {
      return _buildLifecycleResultSections(result);
    }

    final projectId = _projectIdFromPayload(result.payload);
    final state = _stateFromPayload(result.payload) ?? 'draft';
    final exhibitionName = _titleController.text.trim();
    final brandName = _brandNameController.text.trim();
    final title = _composeProjectTitle(exhibitionName, brandName);
    final budgetText = _budgetAmountController.text.trim();
    final buildingType = _normalizeBuildingTypeSelection(
      _buildingTypeController.text.trim(),
    );
    if (!result.isSuccess || projectId == null) {
      return const <Widget>[];
    }

    final canOpenPublicDetail = _canEnterProjectAttachmentCorridor(state);

    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '项目已创建，基本信息已保存',
        summary: canOpenPublicDetail
            ? '当前项目已进入预发布或后续链路，可进入项目详情继续确认基本信息、补充文书或查看回显。'
            : '当前项目已创建为草稿，下一步先进入我的项目详情确认刚保存的基本信息。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _DetailLine(
            label: '当前状态',
            value: _frontStageStateLabel(state),
            highlight: true,
          ),
          _DetailLine(
            label: '展会',
            value: exhibitionName.isNotEmpty ? exhibitionName : '未提供',
          ),
          _DetailLine(
            label: '品牌',
            value: brandName.isNotEmpty ? brandName : '未提供',
          ),
          _DetailLine(
            label: '兼容标题',
            value: title.isNotEmpty ? title : '项目 $projectId',
          ),
          _DetailLine(label: '项目编号', value: projectId),
          if (buildingType.isNotEmpty)
            _DetailLine(label: '项目类型', value: _buildingTypeLabel(buildingType)),
          if (budgetText.isNotEmpty)
            _DetailLine(label: '预算金额', value: '¥$budgetText'),
          _DetailLine(
            label: '下一步',
            value: canOpenPublicDetail
                ? '先进入我的项目详情确认刚保存的基本信息；预发布阶段已开放报价依据资料。'
                : '点击下方“下一步：进入我的项目详情”，先确认刚保存的基本信息；保存到草稿或预发布列表后报价依据资料会开放。',
          ),
          if (!canOpenPublicDetail) ...<Widget>[
            const SizedBox(height: 12),
            const _ActionCard(
              title: '报价依据资料',
              summary:
                  '效果图、尺寸图 / 施工图、材质图 / 材料样板、设备物料清单和服务清单；保存到预发布列表后开放为 owner-private 正式附件区。',
              children: <Widget>[
                _DetailLine(
                  label: '当前说明',
                  value: '当前项目仍是草稿，先保存到预发布列表，再进入我的项目详情继续补充资料。',
                ),
              ],
            ),
          ],
          if (canOpenPublicDetail) ...<Widget>[
            const SizedBox(height: 12),
            _buildPublishedProjectPreview(projectId),
            const SizedBox(height: 12),
            _ProjectAttachmentSection(
              key: ValueKey<String>('project-create-attachment-$projectId'),
              projectId: projectId,
              title: '继续补充报价依据资料',
              summary: '请补充效果图、尺寸图 / 施工图、材质图 / 材料样板、设备物料清单和服务清单。',
              emptyMessage: '当前还没有补充报价依据资料。',
              autoloadFormalList: false,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: canOpenPublicDetail
                ? <Widget>[
                    FilledButton(
                      onPressed: () => _openMyProjectDetail(projectId),
                      child: const Text('下一步：进入我的项目详情'),
                    ),
                    OutlinedButton(
                      onPressed: () => _openProjectDetail(projectId),
                      child: const Text('查看公域项目详情'),
                    ),
                    OutlinedButton(
                      onPressed: _openMyProjectList,
                      child: const Text('返回我的项目'),
                    ),
                  ]
                : <Widget>[
                    FilledButton(
                      onPressed: () => _openMyProjectDetail(projectId),
                      child: const Text('下一步：进入我的项目详情'),
                    ),
                    OutlinedButton(
                      onPressed: () => _openProjectEdit(projectId),
                      child: const Text('继续编辑项目'),
                    ),
                    OutlinedButton(
                      onPressed: _openMyProjectList,
                      child: const Text('返回我的项目'),
                    ),
                  ],
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildProjectEditBody({
    required bool editContentReady,
    required ExhibitionLoadResult? editResult,
    required String? currentState,
  }) {
    if (_editDetailLoading) {
      return const <Widget>[
        _ActionCard(
          title: '正在读取项目资料',
          summary: '正在加载当前项目的编辑真值。',
          tone: _ActionCardTone.emphasis,
          children: <Widget>[_DetailLine(label: '当前状态', value: '请稍候。')],
        ),
      ];
    }

    if (!editContentReady) {
      final failure = editResult;
      return <Widget>[
        _ActionCard(
          title: '当前暂时无法继续编辑项目',
          summary: failure == null
              ? '当前项目编辑真值仍在准备。'
              : _userFacingLoadFailureMessage(failure),
          tone: _ActionCardTone.emphasis,
          children: <Widget>[
            _DetailLine(label: '下一步', value: '先回到我的项目或重新载入当前项目编辑页。'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton(
                  onPressed: () => _loadProjectForEdit(forceRefresh: true),
                  child: const Text('重新载入'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.myProjectList),
                  child: const Text('回到我的项目'),
                ),
              ],
            ),
          ],
        ),
      ];
    }

    final projectId = _editingProjectId!;
    final canManageAttachments = _canEnterProjectAttachmentCorridor(
      currentState,
    );
    final reviewExpanded = _isEditReviewExpanded(currentState);
    final showBottomReturnToPrepublish = currentState == 'submitted';
    return <Widget>[
      _ProjectPublishProgressCard(
        currentStep: _projectPublishProgressStepForState(state: currentState),
        basicInfoOnlyNote: currentState == 'draft',
        useDraftLandingCopy: currentState == 'draft',
      ),
      const SizedBox(height: 16),
      _ActionCard(
        title: '当前生命周期',
        summary: _projectLifecycleSummary(currentState),
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _StateMessage(
            title: '当前任务',
            body: _projectLifecycleBody(currentState),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildLifecycleActionButtons(
              projectId: projectId,
              currentState: currentState,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      KeyedSubtree(
        key: _editReviewSectionKey,
        child: _ProjectEditReviewSectionCard(
          expanded: reviewExpanded,
          summary: _projectEditReviewSummary(currentState),
          titleBrandLabel: _projectEditTitleBrandSummary(),
          locationScheduleLabel: _projectEditLocationScheduleSummary(),
          budgetAreaLabel: _projectEditBudgetAreaSummary(),
          onToggle: () => _toggleEditReviewExpanded(currentState),
        ),
      ),
      if (reviewExpanded) ...<Widget>[
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _editReviewContentKey,
          child: Column(
            children: _buildProjectCreateRoundABody(
              context: context,
              guardLoading: false,
              accessGuard: const _ProjectCreateAccessGuard.allowed(),
              formErrorMessage: _formErrorMessage,
              selectedProjectTypeLabel: _selectedProjectTypeLabel,
              selectedStandardizedLocationLabel:
                  _selectedStandardizedLocationLabel,
              selectedP0PayTaskType: _p0PayTaskType,
              showSupplementalSection: true,
              hasStandardizedLocationSelection:
                  _selectedStandardizedLocation != null,
              districtSelectionEnabled:
                  _selectedStandardizedLocation?.districts.isNotEmpty ?? false,
              exhibitionNameController: _titleController,
              brandNameController: _brandNameController,
              buildingTypeController: _buildingTypeController,
              buildingTypeRemarkController: _buildingTypeRemarkController,
              budgetAmountController: _budgetAmountController,
              areaSqmController: _areaSqmController,
              provinceNameController: _provinceNameController,
              cityNameController: _cityNameController,
              districtNameController: _districtNameController,
              detailAddressController: _detailAddressController,
              scopeSummaryController: _scopeSummaryController,
              plannedStartAtController: _plannedStartAtController,
              plannedEndAtController: _plannedEndAtController,
              scheduleDetailController: _scheduleDetailController,
              descriptionController: _descriptionController,
              fieldKeys: _fieldKeys,
              fieldErrors: _fieldErrors,
              onFieldInteracted: _handleFieldInteracted,
              onProjectTypePressed: _pickProjectType,
              onStandardizedLocationPressed: _pickStandardizedLocation,
              onDistrictPressed: _pickDistrict,
              onScopeSummaryPressed: _editScopeSummary,
              onP0PayTaskTypeChanged: _setP0PayTaskTypeFromCreateChoice,
              onPlannedStartDatePressed: () => _pickDate(
                controller: _plannedStartAtController,
                fieldId: _ProjectCreateFieldId.plannedStartAt,
              ),
              onPlannedEndDatePressed: () => _pickDate(
                controller: _plannedEndAtController,
                fieldId: _ProjectCreateFieldId.plannedEndAt,
              ),
              onPlannedStartDateCleared: () => _clearDate(
                controller: _plannedStartAtController,
                fieldId: _ProjectCreateFieldId.plannedStartAt,
              ),
              onPlannedEndDateCleared: () => _clearDate(
                controller: _plannedEndAtController,
                fieldId: _ProjectCreateFieldId.plannedEndAt,
              ),
            ),
          ),
        ),
      ],
      const SizedBox(height: 16),
      if (canManageAttachments)
        _ProjectAttachmentSection(
          key: ValueKey<String>('project-edit-attachment-$projectId'),
          projectId: projectId,
          title: '报价依据资料',
          summary: '请补充效果图、尺寸图 / 施工图、材质图 / 材料样板、设备物料清单和服务清单。',
          emptyMessage: '当前还没有补充报价依据资料。',
          showIntroCopy: false,
          compactKindHints: true,
        )
      else if (currentState == 'draft')
        _ActionCard(
          title: '报价依据资料',
          children: <Widget>[
            const _DetailLine(label: '当前状态', value: '当前项目尚未进入预发布附件补充阶段。'),
            const _DetailLine(label: '当前提示', value: '请仔细核对上面信息，确认进入预发布列表。'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey<String>(
                  'project-edit-draft-submit-to-prepublish-bottom',
                ),
                onPressed: _submitting ? null : _submitProject,
                child: const Text('确认保存到预发布列表'),
              ),
            ),
          ],
        )
      else
        const _ActionCard(
          title: '报价依据资料',
          children: <Widget>[
            _DetailLine(label: '当前状态', value: '当前项目尚未进入预发布附件补充阶段。'),
          ],
        ),
      if (showBottomReturnToPrepublish) ...<Widget>[
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const ValueKey<String>(
              'project-edit-review-return-to-prepublish-bottom',
            ),
            onPressed: _submitting
                ? null
                : () => _openMyProjectDetail(projectId),
            child: const Text('信息核对无误，返回预发布列表详情'),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildLifecycleResultSections(ExhibitionActionResult result) {
    final projectId =
        _projectIdFromPayload(result.payload) ?? _editingProjectId;
    final state = _stateFromPayload(result.payload);
    if (!result.isSuccess || projectId == null) {
      return const <Widget>[];
    }

    final nextStep = switch (state) {
      'draft' => '当前项目仍在草稿，可继续留在编辑页完善信息，或稍后再保存到预发布列表。',
      'submitted' => '项目已进入预发布列表。请回到我的项目详情补充资料并检查无误后再正式发布。',
      'published' => '项目已正式发布，可继续查看公域详情或我的项目详情。',
      final String value =>
        '当前项目已进入 ${_frontStageStateLabel(value)}，请按真实状态继续处理。',
      _ => '当前项目已按真实状态刷新，可继续回看详情。',
    };
    final actionButtons = switch (state) {
      'submitted' => <Widget>[
        OutlinedButton(
          onPressed: () => _openMyProjectDetail(projectId),
          child: const Text('查看预发布列表详情'),
        ),
      ],
      'published' => <Widget>[
        OutlinedButton(
          onPressed: () => _openProjectDetail(projectId),
          child: const Text('查看公域项目详情'),
        ),
        OutlinedButton(
          onPressed: () => _openMyProjectDetail(projectId),
          child: const Text('查看我的项目详情'),
        ),
      ],
      _ => <Widget>[
        OutlinedButton(
          onPressed: () => _openMyProjectDetail(projectId),
          child: const Text('查看我的项目详情'),
        ),
      ],
    };

    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '当前生命周期结果',
        summary: '当前动作已受理，页面已按真实项目状态刷新。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _DetailLine(label: '项目编号', value: projectId),
          if (state != null)
            _DetailLine(
              label: '当前状态',
              value: _frontStageStateLabel(state),
              highlight: true,
            ),
          _DetailLine(label: '下一步', value: nextStep),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: actionButtons),
        ],
      ),
    ];
  }

  Widget _buildPublishedProjectPreview(String projectId) {
    final exhibitionName = _titleController.text.trim();
    final brandName = _brandNameController.text.trim();
    final compatibleTitle = _composeProjectTitle(exhibitionName, brandName);
    final regionLabel = _publishedProjectRegionLabel();
    final areaLabel = _publishedProjectAreaLabel();
    final previewDescription =
        _normalizeOptionalText(_scopeSummaryController.text) ??
        _normalizeOptionalText(_scheduleDetailController.text) ??
        '竞标中项目，可继续查看公开详情或补充资料。';
    final pills = <String>[];
    final projectTypeLabel = _selectedProjectTypeLabel;
    if (projectTypeLabel != null) {
      pills.add(
        _buildingTypeLabel(_normalizeBuildingTypeSelection(projectTypeLabel)),
      );
    }
    if (regionLabel != null) {
      pills.add(regionLabel);
    }
    if (areaLabel != null) {
      pills.add(areaLabel);
    }

    return _ActionCard(
      title: '竞标中项目预览',
      tone: _ActionCardTone.muted,
      children: <Widget>[
        _EntityCard(
          title: exhibitionName.isEmpty ? '项目 $projectId' : exhibitionName,
          description: previewDescription,
          statusLabel: '竞标中',
          detailLines: <Widget>[
            _DetailLine(
              label: '品牌',
              value: brandName.isEmpty ? '当前项目暂未提供' : brandName,
            ),
            _DetailLine(
              label: '兼容标题',
              value: compatibleTitle.isEmpty
                  ? '项目 $projectId'
                  : compatibleTitle,
            ),
            if (pills.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pills.map((String item) {
                  return _StatusPill(label: item, tone: _ActionCardTone.muted);
                }).toList(),
              ),
            if (pills.isNotEmpty) const SizedBox(height: 8),
            _DetailLine(
              label: '预算金额',
              value: _budgetAmountController.text.trim().isEmpty
                  ? '当前项目暂未提供'
                  : '¥${_budgetAmountController.text.trim()}',
              highlight: true,
            ),
            if (regionLabel != null)
              _DetailLine(label: '项目地点', value: regionLabel),
            if (areaLabel != null) _DetailLine(label: '项目面积', value: areaLabel),
            if (_scopeSummaryController.text.trim().isNotEmpty)
              _DetailLine(
                label: '范围说明',
                value: _scopeSummaryController.text.trim(),
              ),
            if (_plannedStartAtController.text.trim().isNotEmpty)
              _DetailLine(
                label: '计划开始日期',
                value: _plannedStartAtController.text.trim(),
              ),
            if (_plannedEndAtController.text.trim().isNotEmpty)
              _DetailLine(
                label: '计划结束日期',
                value: _plannedEndAtController.text.trim(),
              ),
            if (_scheduleDetailController.text.trim().isNotEmpty)
              _DetailLine(
                label: '详细时间',
                value: _scheduleDetailController.text.trim(),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickProjectType() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '选择项目类型',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '请选择一个更贴近当前项目的场景；当前入口会统一按会展发布。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _projectTypeOptions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final option = _projectTypeOptions[index];
                    return ListTile(
                      title: Text(option),
                      trailing: option == _selectedProjectTypeLabel
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) {
      return;
    }

    _updateFieldState(
      _ProjectCreateFieldId.buildingType,
      () => _buildingTypeController.text = selected,
    );
  }

  Future<void> _pickStandardizedLocation() async {
    final catalog = _regionCatalog ?? await ChinaRegionCatalogLoader.load();
    if (!mounted) {
      return;
    }
    if (_regionCatalog == null) {
      setState(() => _regionCatalog = catalog);
    }
    final picked = await showChinaCityPicker(
      context: context,
      catalog: catalog,
      title: '选择省 / 市',
      initialProvinceCode: _selectedStandardizedLocation?.provinceCode,
      initialCityCode: _selectedStandardizedLocation?.cityCode,
    );
    if (!mounted || picked == null) {
      return;
    }
    final selected = _projectLocationOptionFromChinaCity(picked);

    _updateFieldsState(
      <_ProjectCreateFieldId>{
        _ProjectCreateFieldId.provinceName,
        _ProjectCreateFieldId.cityName,
        _ProjectCreateFieldId.districtName,
      },
      () {
        _selectedStandardizedLocation = selected;
        _provinceNameController.text = selected.provinceName;
        _cityNameController.text = selected.cityName;
        final preservedDistrict = selected.districtByCode(
          _selectedDistrictCode,
        );
        if (preservedDistrict == null) {
          _selectedDistrictCode = null;
          _districtNameController.clear();
          return;
        }
        _selectedDistrictCode = preservedDistrict.districtCode;
        _districtNameController.text = preservedDistrict.districtName;
      },
    );
  }

  Future<void> _pickDistrict() async {
    final location = _selectedStandardizedLocation;
    if (location == null) {
      _showLocationSelectionNotice('请先选择项目所在省 / 市，再决定是否补充区/县。');
      return;
    }
    if (location.districts.isEmpty) {
      _showLocationSelectionNotice('当前所选地区暂未提供区/县选项，可直接继续填写详细地址。');
      return;
    }

    final selected =
        await showModalBottomSheet<_ProjectStandardizedLocationDistrictOption?>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '选择区/县',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '区/县为选填，如需补充，请选择更准确的项目位置。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: location.districts.length + 1,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('暂不补充区/县'),
                            trailing: _selectedDistrictCode == null
                                ? const Icon(Icons.check_rounded)
                                : null,
                            onTap: () => Navigator.of(context).pop(null),
                          );
                        }
                        final option = location.districts[index - 1];
                        return ListTile(
                          title: Text(option.districtName),
                          trailing: option.districtCode == _selectedDistrictCode
                              ? const Icon(Icons.check_rounded)
                              : null,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
    if (!mounted) {
      return;
    }

    _updateFieldState(_ProjectCreateFieldId.districtName, () {
      _selectedDistrictCode = selected?.districtCode;
      _districtNameController.text = selected?.districtName ?? '';
    });
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required _ProjectCreateFieldId fieldId,
  }) async {
    final currentDate = _parseDateInput(controller.text.trim());
    final pickedDate = await showChinaDatePicker(
      context: context,
      title: '选择日期',
      initialDate: currentDate ?? DateTime.now(),
      minimumDate: DateTime(2020, 1, 1),
      maximumDate: DateTime(2100, 12, 31),
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    _updateFieldState(
      fieldId,
      () => controller.text = _displayDate(pickedDate),
    );
  }

  Future<void> _editScopeSummary() async {
    final draftController = TextEditingController(
      text: _scopeSummaryController.text.trim(),
    );
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  draftController.text.trim().isEmpty ? '添加范围说明' : '编辑范围说明',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '一句话概括本次发布范围，方便快速理解需求；当前为选填，可稍后再补。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey<String>(
                    'project-create-scope-summary-input',
                  ),
                  controller: draftController,
                  maxLines: 4,
                  minLines: 3,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: '范围说明',
                    hintText: '例如：主舞台、医疗器械展区与灯光联动区进场搭建',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(''),
                      child: const Text('清空说明'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(draftController.text.trim()),
                      child: const Text('保存说明'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || result == null) {
      return;
    }
    _updateFieldState(
      _ProjectCreateFieldId.scopeSummary,
      () => _scopeSummaryController.text = result,
    );
  }

  void _clearDate({
    required TextEditingController controller,
    required _ProjectCreateFieldId fieldId,
  }) {
    if (controller.text.trim().isEmpty) {
      _handleFieldInteracted(fieldId);
      return;
    }
    _updateFieldState(fieldId, controller.clear);
  }

  void _handleFieldInteracted(_ProjectCreateFieldId fieldId) {
    if (!_fieldErrors.containsKey(fieldId) && _formErrorMessage == null) {
      return;
    }

    setState(() {
      _fieldErrors = Map<_ProjectCreateFieldId, String>.of(_fieldErrors)
        ..remove(fieldId);
      if (_fieldErrors.isEmpty) {
        _formErrorMessage = null;
      }
    });
  }

  void _updateFieldState(
    _ProjectCreateFieldId fieldId,
    VoidCallback updateValue,
  ) => _updateFieldsState(<_ProjectCreateFieldId>{fieldId}, updateValue);

  void _updateFieldsState(
    Iterable<_ProjectCreateFieldId> fieldIds,
    VoidCallback updateValue,
  ) {
    setState(() {
      updateValue();
      final nextErrors = Map<_ProjectCreateFieldId, String>.of(_fieldErrors);
      for (final fieldId in fieldIds) {
        nextErrors.remove(fieldId);
      }
      _fieldErrors = nextErrors;
      if (_fieldErrors.isEmpty) {
        _formErrorMessage = null;
      }
    });
  }

  void _showLocationSelectionNotice(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isEditReviewExpanded(String? currentState) {
    return _editReviewExpandedOverride ??
        _defaultEditReviewExpanded(currentState);
  }

  bool _defaultEditReviewExpanded(String? currentState) {
    return currentState == 'draft';
  }

  void _toggleEditReviewExpanded(String? currentState) {
    setState(() {
      _editReviewExpandedOverride = !_isEditReviewExpanded(currentState);
    });
  }

  void _continueReviewFlow(String? currentState) {
    if (!_isEditReviewExpanded(currentState)) {
      setState(() {
        _editReviewExpandedOverride = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final targetContext = _editReviewSectionKey.currentContext;
        if (targetContext == null) {
          return;
        }
        _scrollToEditReviewTarget(targetContext);
      });
      return;
    }
    final targetContext =
        _editReviewContentKey.currentContext ??
        _editReviewSectionKey.currentContext;
    if (targetContext == null) {
      return;
    }
    _scrollToEditReviewTarget(targetContext);
  }

  void _scrollToEditReviewTarget(BuildContext targetContext) {
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  List<Widget> _buildLifecycleActionButtons({
    required String projectId,
    required String? currentState,
  }) {
    return switch (currentState) {
      'draft' => <Widget>[
        FilledButton(
          onPressed: _submitting ? null : _submitProject,
          child: const Text('保存到预发布列表'),
        ),
        OutlinedButton(
          onPressed: _submitting ? null : _saveProject,
          child: const Text('仅保存草稿'),
        ),
        OutlinedButton(
          onPressed: _submitting ? null : () => _openMyProjectDetail(projectId),
          child: const Text('查看我的项目详情'),
        ),
      ],
      'submitted' => <Widget>[
        FilledButton(
          onPressed: _submitting ? null : () => _openMyProjectDetail(projectId),
          child: const Text('返回预发布列表详情'),
        ),
        OutlinedButton(
          onPressed: _submitting
              ? null
              : () => _continueReviewFlow(currentState),
          child: const Text('继续核对当前内容'),
        ),
      ],
      'published' => <Widget>[
        FilledButton(
          onPressed: _submitting ? null : () => _openProjectDetail(projectId),
          child: const Text('查看公域项目详情'),
        ),
        OutlinedButton(
          onPressed: _submitting ? null : () => _openMyProjectDetail(projectId),
          child: const Text('查看我的项目详情'),
        ),
      ],
      _ => <Widget>[
        OutlinedButton(
          onPressed: _submitting ? null : _saveProject,
          child: const Text('仅保存草稿'),
        ),
        OutlinedButton(
          onPressed: _submitting ? null : () => _openMyProjectDetail(projectId),
          child: const Text('查看我的项目详情'),
        ),
      ],
    };
  }

  String _projectLifecycleSummary(String? state) {
    return switch (state) {
      'draft' => '继续完善当前内容，准备进入预发布列表。',
      'submitted' => '先核对已保存内容，再补充报价依据资料。',
      'published' => '当前已进入竞标中，页面只保留回看和补资料入口。',
      final String value => '当前项目处于 ${_frontStageStateLabel(value)}。',
      _ => '当前项目生命周期正在读取。',
    };
  }

  String _projectLifecycleBody(String? state) {
    return switch (state) {
      'draft' => '先核对下方内容；准备好后保存到预发布列表。如只想暂存，继续使用“仅保存草稿”。',
      'submitted' =>
        '当前页只负责回看已保存内容和补充报价依据资料；最终发布确认回到“我的项目 -> 预发布列表 -> 单项目详情”完成。',
      'published' => '当前可继续回看编辑回显或补充报价依据资料；公域详情和我的项目详情会按真实状态同步回显。',
      final String value =>
        '当前项目处于 ${_frontStageStateLabel(value)}；页面只按真实状态承接下一步。',
      _ => '当前页只消费真实生命周期状态，不在本地伪造第二状态机。',
    };
  }

  String _projectEditReviewSummary(String? state) {
    return switch (state) {
      'draft' => '基础信息当前保持展开，可直接继续修改。',
      'submitted' => '已保存内容已收起，按需展开继续核对或修改。',
      'published' => '已保存内容已收起，按需展开回看当前编辑回显。',
      final String value => '当前内容已按 ${_frontStageStateLabel(value)} 阶段收敛。',
      _ => '已保存内容会按当前阶段决定默认展开方式。',
    };
  }

  String _projectEditTitleBrandSummary() {
    final title = _normalizeOptionalText(_titleController.text) ?? '待补充';
    final brand = _normalizeOptionalText(_brandNameController.text);
    return brand == null ? title : '$title / $brand';
  }

  String _projectEditLocationScheduleSummary() {
    final region = _publishedProjectRegionLabel();
    final address = _normalizeOptionalText(_detailAddressController.text);
    final start = _normalizeOptionalText(_plannedStartAtController.text);
    final end = _normalizeOptionalText(_plannedEndAtController.text);
    final scheduleDetail = _normalizeOptionalText(
      _scheduleDetailController.text,
    );

    final locationText = <String>[
      if (region case final String value) value,
      if (address case final String value) value,
    ].join(' · ');
    final scheduleText = switch ((start, end)) {
      (final String startValue?, final String endValue?) =>
        '$startValue 至 $endValue',
      (final String startValue?, null) => startValue,
      (null, final String endValue?) => endValue,
      _ => '',
    };

    final parts = <String>[
      if (locationText.isNotEmpty) locationText,
      if (scheduleText.isNotEmpty) scheduleText,
      if (scheduleDetail case final String value) value,
    ];
    return parts.isEmpty ? '待补充' : parts.join(' · ');
  }

  String _projectEditBudgetAreaSummary() {
    final budget = _normalizeOptionalText(_budgetAmountController.text);
    final area = _normalizeOptionalText(_areaSqmController.text);
    final parts = <String>[
      if (budget != null) '¥$budget',
      if (area != null) '$area㎡',
    ];
    return parts.isEmpty ? '待补充' : parts.join(' / ');
  }

  void _applyValidationFeedback(_ProjectCreateValidationResult validation) {
    setState(() {
      _fieldErrors = validation.errors;
      _formErrorMessage = validation.formMessage;
      _lastResult = null;
    });

    final message = validation.formMessage;
    if (message != null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }

    final firstInvalidFieldId = validation.firstInvalidFieldId;
    if (firstInvalidFieldId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToField(firstInvalidFieldId);
    });
  }

  Future<void> _scrollToField(_ProjectCreateFieldId fieldId) async {
    final targetContext = _fieldKeys[fieldId]?.currentContext;
    if (targetContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.24,
    );
  }

  Future<void> _loadAccessGuard() async {
    if (!AppSessionStore.instance.hasAnySession) {
      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.blocked(
          title: '请先登录',
          message: '当前账号未登录，先登录后再创建项目。',
          actionLabel: '去登录',
          actionRouteName: ProfileIdentityRoutes.login,
        );
      });
      return;
    }

    final snapshot = AppShellScope.read(context).snapshot;
    final blockingState = snapshot.blockingState;

    if (blockingState == GlobalShellState.booting) {
      if (_guardRetryCount >= 20) {
        setState(() {
          _guardLoading = false;
          _accessGuard = const _ProjectCreateAccessGuard.blocked(
            title: '当前暂时无法打开创建项目',
            message: '当前仍在确认是否可创建项目，请稍后再试。',
            actionLabel: '返回我的项目',
            actionRouteName: ExhibitionRoutes.myProjectList,
          );
        });
        return;
      }

      _guardRetryCount += 1;
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) {
          return;
        }
        _loadAccessGuard();
      });
      return;
    }

    _guardRetryCount = 0;

    if (blockingState == GlobalShellState.unauthenticated) {
      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.blocked(
          title: '请先登录',
          message: '当前账号未登录，先登录后再创建项目。',
          actionLabel: '去登录',
          actionRouteName: ProfileIdentityRoutes.login,
        );
      });
      return;
    }

    if (blockingState == GlobalShellState.noOrganization) {
      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.blocked(
          title: '请先加入组织',
          message: '当前账号还没有组织信息，先完成组织承接后再创建项目。',
          actionLabel: '去完善组织',
          actionRouteName: ProfileIdentityRoutes.organizationHandoff,
        );
      });
      return;
    }

    final certificationStatus = snapshot.shellContext.certificationStatus
        ?.trim();
    if (_hasExplicitProjectCreateCertificationStatus(certificationStatus) &&
        !_isProjectCreateCertificationApproved(certificationStatus)) {
      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.blocked(
          title: '当前认证未通过',
          message: '当前组织认证尚未通过，需先完成并通过认证后再创建项目。',
          actionLabel: '查看认证状态',
          actionRouteName: ProfileIdentityRoutes.certificationCurrent,
        );
      });
      return;
    }

    final shellEligibility = snapshot.shellContext.projectCreateEligibility;
    if (shellEligibility != null) {
      final canCreateProject = shellEligibility.canCreateProject;
      if (canCreateProject) {
        setState(() {
          _guardLoading = false;
          _accessGuard = const _ProjectCreateAccessGuard.allowed();
        });
        return;
      }

      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.allowed();
      });
      return;
    }

    setState(() {
      _guardLoading = false;
      _accessGuard = const _ProjectCreateAccessGuard.blocked(
        title: '当前暂时无法确认创建条件',
        message: '当前无法确认当前创建资格，请稍后再试。',
        actionLabel: '返回我的项目',
        actionRouteName: ExhibitionRoutes.myProjectList,
      );
    });
  }

  static bool _hasExplicitProjectCreateCertificationStatus(String? status) {
    return status != null && status.trim().isNotEmpty;
  }

  static bool _isProjectCreateCertificationApproved(String? status) {
    final normalized = status?.trim().toLowerCase();
    return normalized == 'verified' || normalized == 'approved';
  }

  static bool _canEnterProjectAttachmentCorridor(String? state) {
    return state == 'submitted' ||
        state == 'published' ||
        state == 'bidding_closed' ||
        state == 'awarded' ||
        state == 'converted_to_order';
  }

  static _ProjectCreateValidationResult _validateForm({
    required String exhibitionName,
    required String brandName,
    required String selectedProjectType,
    required String buildingTypeRemark,
    required String budgetText,
    required double? budgetAmount,
    required String areaSqmText,
    required double? areaSqm,
    required String? provinceCode,
    required String provinceName,
    required String? cityCode,
    required String cityName,
    required String? districtCode,
    required String districtName,
    required String detailAddress,
    required String scopeSummary,
    required String plannedStartAt,
    required String plannedEndAt,
    required String scheduleDetail,
  }) {
    final errors = <_ProjectCreateFieldId, String>{};
    final normalizedStartAt = _normalizeDateInput(plannedStartAt);
    final normalizedEndAt = _normalizeDateInput(plannedEndAt);
    final normalizedBuildingTypeRemark = _normalizeOptionalText(
      buildingTypeRemark,
    );
    final normalizedScheduleDetail = _normalizeOptionalText(scheduleDetail);

    if (exhibitionName.isEmpty) {
      errors[_ProjectCreateFieldId.title] = '请输入展会';
    }
    if (brandName.isEmpty) {
      errors[_ProjectCreateFieldId.brandName] = '请输入品牌';
    }
    if (selectedProjectType.isEmpty) {
      errors[_ProjectCreateFieldId.buildingType] = '请选择项目类型';
    }
    if (budgetText.isEmpty) {
      errors[_ProjectCreateFieldId.budgetAmount] = '请输入预算金额';
    } else if (budgetAmount == null) {
      errors[_ProjectCreateFieldId.budgetAmount] = '请输入有效的预算金额';
    }
    if (normalizedBuildingTypeRemark != null &&
        normalizedBuildingTypeRemark.length > _buildingTypeRemarkMaxLength) {
      errors[_ProjectCreateFieldId.buildingTypeRemark] = '类型备注最多填写 100 个字';
    }
    if (areaSqmText.isNotEmpty && areaSqm == null) {
      errors[_ProjectCreateFieldId.areaSqm] = '请输入有效的项目面积';
    }
    if (provinceCode == null ||
        provinceName.isEmpty ||
        cityCode == null ||
        cityName.isEmpty) {
      errors[_ProjectCreateFieldId.provinceName] = '请选择省 / 市';
    }
    final hasDistrictCode = _normalizeOptionalText(districtCode ?? '') != null;
    final hasDistrictName = _normalizeOptionalText(districtName) != null;
    if (hasDistrictCode != hasDistrictName) {
      errors[_ProjectCreateFieldId.districtName] = '请选择完整的区/县';
    }
    if (detailAddress.isEmpty) {
      errors[_ProjectCreateFieldId.detailAddress] = '请输入详细地址';
    }
    if (plannedStartAt.isNotEmpty && normalizedStartAt == null) {
      errors[_ProjectCreateFieldId.plannedStartAt] = '请选择有效的计划开始日期';
    }
    if (plannedEndAt.isNotEmpty && normalizedEndAt == null) {
      errors[_ProjectCreateFieldId.plannedEndAt] = '请选择有效的计划结束日期';
    }
    if (normalizedScheduleDetail != null &&
        normalizedScheduleDetail.length > _scheduleDetailMaxLength) {
      errors[_ProjectCreateFieldId.scheduleDetail] = '详细时间最多填写 200 个字';
    }

    return _ProjectCreateValidationResult(errors);
  }

  static String _normalizeBuildingTypeSelection(String selectedProjectType) {
    return selectedProjectType.trim().isEmpty ? '' : _roundABuildingType;
  }

  static String _composeProjectTitle(String exhibitionName, String brandName) {
    final normalizedExhibitionName = _normalizeOptionalText(exhibitionName);
    final normalizedBrandName = _normalizeOptionalText(brandName);
    if (normalizedExhibitionName == null && normalizedBrandName == null) {
      return '';
    }
    if (normalizedExhibitionName == null) {
      return normalizedBrandName!;
    }
    if (normalizedBrandName == null) {
      return normalizedExhibitionName;
    }
    return '$normalizedExhibitionName - $normalizedBrandName';
  }

  static double? _parseAreaSqmInput(String raw) {
    final value = raw.trim();
    if (value.isEmpty || !_areaSqmPattern.hasMatch(value)) {
      return null;
    }

    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  static String? _normalizeOptionalText(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static String? _normalizeDateInput(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return '';
    }

    if (_canonicalDatePattern.hasMatch(value)) {
      final parsed = DateTime.tryParse(value);
      return parsed == null ? null : _canonicalDate(parsed);
    }

    final visibleMatch = _visibleDatePattern.firstMatch(value);
    if (visibleMatch == null) {
      return null;
    }

    final year = int.tryParse(visibleMatch.group(1) ?? '');
    final month = int.tryParse(visibleMatch.group(2) ?? '');
    final day = int.tryParse(visibleMatch.group(3) ?? '');
    if (year == null || month == null || day == null) {
      return null;
    }

    final parsed = DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}',
    );
    return parsed == null ? null : _canonicalDate(parsed);
  }

  static DateTime? _parseDateInput(String raw) {
    final normalized = _normalizeDateInput(raw);
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }

  static String _canonicalDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static String _displayDate(DateTime value) {
    return '${value.year}年${value.month}月${value.day}日';
  }

  String? _publishedProjectRegionLabel() {
    final provinceName = _normalizeOptionalText(_provinceNameController.text);
    final cityName = _normalizeOptionalText(_cityNameController.text);
    final districtName = _normalizeOptionalText(_districtNameController.text);
    final parts = <String>[];
    if (provinceName != null) {
      parts.add(provinceName);
    }
    if (cityName != null && cityName != provinceName) {
      parts.add(cityName);
    }
    if (districtName != null) {
      parts.add(districtName);
    }
    return parts.isEmpty ? null : parts.join(' / ');
  }

  String? _publishedProjectAreaLabel() {
    final areaSqm = _parseAreaSqmInput(_areaSqmController.text);
    if (areaSqm == null) {
      return null;
    }
    final normalized = areaSqm
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$normalized ㎡';
  }

  static _ProjectStandardizedLocationOption? _projectLocationOptionFromPayload(
    Map<String, Object?> payload, {
    ChinaRegionCatalog? catalog,
  }) {
    final provinceCode = _normalizeId(payload['provinceCode'] as String?);
    final provinceName = _normalizeId(payload['provinceName'] as String?);
    final cityCode = _normalizeId(payload['cityCode'] as String?);
    final cityName = _normalizeId(payload['cityName'] as String?);
    if (provinceCode == null ||
        provinceName == null ||
        cityCode == null ||
        cityName == null) {
      return null;
    }

    final catalogCity = catalog?.cityByCode(cityCode);
    if (catalogCity != null) {
      return _projectLocationOptionFromChinaCity(catalogCity);
    }

    return _ProjectStandardizedLocationOption(
      provinceCode: provinceCode,
      provinceName: provinceName,
      cityCode: cityCode,
      cityName: cityName,
    );
  }

  Future<void> _primeRegionCatalog() async {
    final catalog = await ChinaRegionCatalogLoader.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _regionCatalog = catalog;
      _selectedStandardizedLocation = _backfilledLocationFromCatalog(
        current: _selectedStandardizedLocation,
        catalog: catalog,
      );
      if (_selectedDistrictCode != null &&
          _selectedStandardizedLocation?.districtByCode(
                _selectedDistrictCode,
              ) ==
              null) {
        _selectedDistrictCode = null;
        _districtNameController.clear();
      }
    });
  }

  _ProjectStandardizedLocationOption? _backfilledLocationFromCatalog({
    required _ProjectStandardizedLocationOption? current,
    required ChinaRegionCatalog catalog,
  }) {
    if (current == null) {
      return null;
    }
    final catalogCity = catalog.cityByCode(current.cityCode);
    if (catalogCity == null) {
      return current;
    }
    return _projectLocationOptionFromChinaCity(catalogCity);
  }

  static String _buildingTypePickerLabel(String? buildingType) {
    final normalized = _normalizeId(buildingType);
    if (normalized == null || normalized == _roundABuildingType) {
      return '会展';
    }
    return normalized;
  }

  static String _projectBudgetAmountText(Object? rawValue) {
    if (rawValue is! num) {
      return '';
    }
    final fixed = rawValue.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String _displayDateFromCanonical(String? rawValue) {
    final normalized = _normalizeId(rawValue);
    if (normalized == null) {
      return '';
    }
    final parsed = DateTime.tryParse(normalized);
    return parsed == null ? normalized : _displayDate(parsed);
  }
}

class _ProjectCreateAccessGuard {
  const _ProjectCreateAccessGuard._({
    required this.blocked,
    this.title,
    this.message,
    this.actionLabel,
    this.actionRouteName,
  });

  const _ProjectCreateAccessGuard.allowed() : this._(blocked: false);

  const _ProjectCreateAccessGuard.blocked({
    required String this.title,
    required String this.message,
    this.actionLabel,
    this.actionRouteName,
  }) : blocked = true;

  final bool blocked;
  final String? title;
  final String? message;
  final String? actionLabel;
  final String? actionRouteName;
}
