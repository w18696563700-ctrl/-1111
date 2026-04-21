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

  final labels = errors.keys
      .map(_projectCreateFieldLabel)
      .where((String value) => value.trim().isNotEmpty)
      .toSet()
      .toList();
  if (labels.isEmpty) {
    return '还有项目基本信息没有填完，请先补齐必填项后再保存。';
  }

  return '这些项目基本信息还没有填完或需要修正：${labels.join('、')}。';
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
  final Map<_ProjectCreateFieldId, GlobalKey> _fieldKeys =
      <_ProjectCreateFieldId, GlobalKey>{
        for (final fieldId in _ProjectCreateFieldId.values)
          fieldId: GlobalKey(),
      };
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
  ExhibitionActionResult? _lastResult;
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
    super.dispose();
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
          ExhibitionRoutes.myProjectList,
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
          : '先保存项目基本信息，成功后直接跳转到我的项目继续处理。',
      canonicalPath: isEditMode
          ? ExhibitionCanonicalPaths.projectSave
          : ExhibitionCanonicalPaths.projectCreate,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submitCreate,
      submitButtonLabel: '保存项目基本信息并跳转至我的项目',
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
          : _buildProjectCreateRoundABody(
              context: context,
              guardLoading: _guardLoading,
              accessGuard: _accessGuard,
              formErrorMessage: _formErrorMessage,
              selectedProjectTypeLabel: _selectedProjectTypeLabel,
              selectedStandardizedLocationLabel:
                  _selectedStandardizedLocationLabel,
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
    );
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
            ? '当前项目已创建并进入竞标中链路，可进入项目详情继续确认基本信息、补充文书或查看公域回显。'
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
                ? '先进入我的项目详情确认刚保存的基本信息；项目详情文书已开放，可继续补充效果图、施工图和其他资料。'
                : '点击下方“下一步：进入我的项目详情”，先确认刚保存的基本信息；保存到预发布列表后项目详情文书会开放。',
          ),
          if (!canOpenPublicDetail) ...<Widget>[
            const SizedBox(height: 12),
            const _ActionCard(
              title: '项目详情文书',
              summary: '效果图、施工图以及其他资料会在进入预发布列表后开放为 owner-private 正式附件区。',
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
              title: '继续补充资料',
              summary: '如需补充效果图、施工图或其他资料，可继续在这里完成。',
              emptyMessage: '当前还没有补充项目附件。',
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
    return <Widget>[
      _ActionCard(
        title: '当前生命周期',
        summary: _projectLifecycleSummary(currentState),
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _DetailLine(
            label: '当前状态',
            value: currentState == null
                ? '未提供'
                : _frontStageStateLabel(currentState),
            highlight: true,
          ),
          _DetailLine(label: '说明', value: _projectLifecycleBody(currentState)),
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
      ..._buildProjectCreateRoundABody(
        context: context,
        guardLoading: false,
        accessGuard: const _ProjectCreateAccessGuard.allowed(),
        formErrorMessage: _formErrorMessage,
        selectedProjectTypeLabel: _selectedProjectTypeLabel,
        selectedStandardizedLocationLabel: _selectedStandardizedLocationLabel,
        hasStandardizedLocationSelection: _selectedStandardizedLocation != null,
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
      const SizedBox(height: 16),
      if (canManageAttachments)
        _ProjectAttachmentSection(
          key: ValueKey<String>('project-edit-attachment-$projectId'),
          projectId: projectId,
          title: '项目详情文书区',
          summary: '进入预发布列表后，可继续在这里补充效果图、施工图和其他资料。',
          emptyMessage: '当前还没有项目文书。',
        )
      else
        const _ActionCard(
          title: '项目详情文书区',
          summary: '保存到预发布列表后，这里会开放 owner-private 正式附件补充区。',
          children: <Widget>[
            _DetailLine(label: '当前状态', value: '当前项目尚未进入预发布附件补充阶段。'),
          ],
        ),
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
                  '一句话概括本次发布范围，方便快速理解需求。当前云端发布链路要求先补齐这个字段。',
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
              : () => _scrollToField(_ProjectCreateFieldId.title),
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
      'draft' => '当前项目还在草稿态，主动作是保存到预发布列表。',
      'submitted' => '当前项目已进入预发布列表，当前可先补充项目详情文书，再回到我的项目详情完成正式发布确认。',
      'published' => '当前项目已进入竞标中，页面继续保留编辑与回显入口。',
      final String value => '当前项目处于 ${_frontStageStateLabel(value)}。',
      _ => '当前项目生命周期正在读取。',
    };
  }

  String _projectLifecycleBody(String? state) {
    return switch (state) {
      'draft' => '点击“保存到预发布列表”后，项目会先进入发布前核对阶段，不会立即进入公域展示；如只想暂存，请使用“仅保存草稿”。',
      'submitted' =>
        '当前页只继续核对预发布内容并补充项目详情文书；最终发布请回到“我的项目 -> 预发布列表 -> 单项目详情”点击“检查无误，确定发布”。',
      'published' => '当前项目已进入竞标中；公域详情与我的项目详情会继续按真实状态回显。',
      final String value =>
        '当前项目处于 ${_frontStageStateLabel(value)}，页面只按真实状态承接。',
      _ => '当前页只消费真实生命周期状态，不在本地伪造第二状态机。',
    };
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

      final roleAllowed = _isProjectCreateRoleExplicitlyAllowed(
        snapshot.shellContext.roleKeys,
      );
      if (roleAllowed == false) {
        setState(() {
          _guardLoading = false;
          _accessGuard = const _ProjectCreateAccessGuard.blocked(
            title: '当前角色不允许创建项目',
            message: '当前组织角色暂不允许创建项目；最终是否可继续仍以当前创建资格返回结果为准，请先返回我的项目查看当前可继续入口。',
            actionLabel: '返回我的项目',
            actionRouteName: ExhibitionRoutes.myProjectList,
          );
        });
        return;
      }

      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.blocked(
          title: '当前创建资格未通过',
          message: '当前创建资格未通过，请先返回我的项目查看当前可继续入口，或先补齐认证与组织状态。',
          actionLabel: '返回我的项目',
          actionRouteName: ExhibitionRoutes.myProjectList,
        );
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

  static bool? _isProjectCreateRoleExplicitlyAllowed(List<String> roleKeys) {
    final normalizedRoles = roleKeys
        .map((String role) => role.trim().toLowerCase())
        .where((String role) => role.isNotEmpty)
        .toList(growable: false);
    if (normalizedRoles.isEmpty) {
      return null;
    }

    for (final role in normalizedRoles) {
      if (role.contains('admin')) {
        return true;
      }
    }

    return false;
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
    if (_normalizeOptionalText(scopeSummary) == null) {
      errors[_ProjectCreateFieldId.scopeSummary] = '请补充范围说明';
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
