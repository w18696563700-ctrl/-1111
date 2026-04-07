part of '../exhibition_trade_pages.dart';

class ProjectCreatePage extends StatefulWidget {
  const ProjectCreatePage({super.key});

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

enum _ProjectCreateFieldId {
  title,
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

class _ProjectCreateValidationResult {
  const _ProjectCreateValidationResult(this.errors);

  final Map<_ProjectCreateFieldId, String> errors;

  bool get isValid => errors.isEmpty;

  _ProjectCreateFieldId? get firstInvalidFieldId =>
      errors.isEmpty ? null : errors.keys.first;

  String? get formMessage => errors.isEmpty ? null : '请先完善标星字段或修正错误项后再发布项目。';
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
  _ProjectStandardizedLocationOption? _selectedStandardizedLocation;
  String? _selectedDistrictCode;

  bool _guardLoading = true;
  _ProjectCreateAccessGuard _accessGuard =
      const _ProjectCreateAccessGuard.allowed();
  bool _guardInitialized = false;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_guardInitialized) {
      return;
    }
    _guardInitialized = true;
    _loadAccessGuard();
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  Future<void> _submit() async {
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
      title: _titleController.text.trim(),
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

    setState(() {
      _submitting = true;
      _lastResult = null;
      _fieldErrors = <_ProjectCreateFieldId, String>{};
      _formErrorMessage = null;
    });

    final result = await ExhibitionConsumerLayer.instance.createProject(
      ProjectCreateCommand(
        title: _titleController.text.trim(),
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
        scopeSummary: _scopeSummaryController.text.trim(),
        plannedStartAt: plannedStartAt,
        plannedEndAt: plannedEndAt,
        scheduleDetail: _normalizeOptionalText(_scheduleDetailController.text),
        description: _descriptionController.text.trim(),
      ),
    );
    final projectId = _projectIdFromPayload(result.payload);
    if (result.isSuccess && projectId != null) {
      ExhibitionConsumerLayer.instance.invalidateMyProjectList();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _lastResult = result;
    });
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

  Future<void> _openProjectList() async {
    await ExhibitionConsumerLayer.instance.loadProjectList(forceRefresh: true);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(ExhibitionRoutes.projectList);
  }

  Future<void> _openWorkbench() async {
    await ExhibitionConsumerLayer.instance.loadWorkbench(forceRefresh: true);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(ExhibitionRoutes.workbench);
  }

  @override
  Widget build(BuildContext context) {
    final publishSucceeded =
        _lastResult?.isSuccess == true &&
        _projectIdFromPayload(_lastResult?.payload) != null;

    return _SubmissionPageFrame(
      title: '创建项目',
      summary: '填写项目信息并发布。',
      canonicalPath: ExhibitionCanonicalPaths.projectCreate,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submit,
      submitButtonLabel: '发布项目',
      showSubmitButton:
          !_guardLoading && !_accessGuard.blocked && !publishSucceeded,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showSourceNotice: false,
      showActionContainer: false,
      hideResultPanelOnSuccess: true,
      resultSectionsBuilder: (ExhibitionActionResult result) =>
          _buildResultSections(result),
      body: publishSucceeded
          ? const <Widget>[]
          : _buildProjectCreateRoundABody(
              context: context,
              guardLoading: _guardLoading,
              accessGuard: _accessGuard,
              formErrorMessage: _formErrorMessage,
              selectedProjectTypeLabel: _selectedProjectTypeLabel,
              selectedStandardizedLocationLabel:
                  _selectedStandardizedLocationLabel,
              titleController: _titleController,
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
    final projectId = _projectIdFromPayload(result.payload);
    final title = _titleController.text.trim();
    final budgetText = _budgetAmountController.text.trim();
    final buildingType = _normalizeBuildingTypeSelection(
      _buildingTypeController.text.trim(),
    );
    if (!result.isSuccess || projectId == null) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '已成功发布',
        summary: '当前项目已经发布，接下来可查看详情或继续补充资料。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _DetailLine(
            label: '当前项目',
            value: title.isNotEmpty ? title : '项目 $projectId',
            highlight: true,
          ),
          _DetailLine(label: '项目编号', value: projectId),
          if (buildingType.isNotEmpty)
            _DetailLine(label: '项目类型', value: _buildingTypeLabel(buildingType)),
          if (budgetText.isNotEmpty)
            _DetailLine(label: '预算金额', value: '¥$budgetText'),
          _DetailLine(label: '下一步', value: '先查看项目详情确认信息，或回到项目工作台继续处理。'),
          const SizedBox(height: 12),
          _buildPublishedProjectPreview(projectId),
          const SizedBox(height: 12),
          _ProjectAttachmentSection(
            key: ValueKey<String>('project-create-attachment-$projectId'),
            projectId: projectId,
            title: '继续补充资料',
            summary: '如需补充效果图、施工图或其他资料，可继续在这里完成。',
            emptyMessage: '当前还没有补充项目附件。',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed: () => _openProjectDetail(projectId),
                child: const Text('查看项目详情'),
              ),
              FilledButton.tonal(
                onPressed: _openProjectList,
                child: const Text('查看项目列表'),
              ),
              FilledButton.tonal(
                onPressed: _openWorkbench,
                child: const Text('项目工作台'),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Widget _buildPublishedProjectPreview(String projectId) {
    final regionLabel = _publishedProjectRegionLabel();
    final areaLabel = _publishedProjectAreaLabel();
    final previewDescription =
        _normalizeOptionalText(_scopeSummaryController.text) ??
        _normalizeOptionalText(_scheduleDetailController.text) ??
        '已发布项目，可继续查看详情或补充资料。';
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
      title: '已发布项目预览',
      tone: _ActionCardTone.muted,
      children: <Widget>[
        _EntityCard(
          title: _titleController.text.trim().isEmpty
              ? '项目 $projectId'
              : _titleController.text.trim(),
          description: previewDescription,
          statusLabel: '已发布',
          detailLines: <Widget>[
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
                      '请选择一个更贴近当前项目的场景；当前入口会统一按展览项目发布。',
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
    final selected =
        await showModalBottomSheet<_ProjectStandardizedLocationOption>(
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
                          '选择项目所在地区',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '先选择项目所在城市；如需补充区/县，可在下一步继续选择。',
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
                      itemCount: _projectStandardizedLocationOptions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final option =
                            _projectStandardizedLocationOptions[index];
                        return ListTile(
                          title: Text(option.displayLabel),
                          subtitle: Text(option.pickerDescription),
                          trailing:
                              option.cityCode ==
                                  _selectedStandardizedLocation?.cityCode
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
      _showLocationSelectionNotice('请先选择项目所在地区，再决定是否补充区/县。');
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
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: '选择日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    _updateFieldState(
      fieldId,
      () => controller.text = _displayDate(pickedDate),
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

  void _applyValidationFeedback(_ProjectCreateValidationResult validation) {
    setState(() {
      _fieldErrors = validation.errors;
      _formErrorMessage = validation.formMessage;
      _lastResult = null;
    });

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
            actionLabel: '项目工作台',
            actionRouteName: ExhibitionRoutes.workbench,
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

    final workbenchResult = await ExhibitionConsumerLayer.instance
        .loadWorkbench(forceRefresh: true);
    if (!mounted) {
      return;
    }

    if (workbenchResult.state == AppPageState.content) {
      final canCreateProject = _canCreateProjectFromWorkbench(
        workbenchResult.payload,
      );
      if (canCreateProject == true) {
        setState(() {
          _guardLoading = false;
          _accessGuard = const _ProjectCreateAccessGuard.allowed();
        });
        return;
      }

      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.blocked(
          title: '当前暂不可创建项目',
          message: '项目工作台显示当前账号暂不具备创建项目条件，请先回到项目工作台查看可执行入口。',
          actionLabel: '回到项目工作台',
          actionRouteName: ExhibitionRoutes.workbench,
        );
      });
      return;
    }

    if (workbenchResult.state == AppPageState.unauthorized) {
      setState(() {
        _guardLoading = false;
        _accessGuard = const _ProjectCreateAccessGuard.blocked(
          title: '登录状态已失效',
          message: '项目工作台校验未通过，请先恢复登录后再创建项目。',
          actionLabel: '去登录',
          actionRouteName: ProfileIdentityRoutes.login,
        );
      });
      return;
    }

    setState(() {
      _guardLoading = false;
      _accessGuard = _ProjectCreateAccessGuard.blocked(
        title: _projectCreateGuardFailureTitle(workbenchResult),
        message:
            _projectCreateGuardFailureMessage(workbenchResult) ??
            '当前无法确认是否可创建项目，请稍后再试。',
        actionLabel: '回到项目工作台',
        actionRouteName: ExhibitionRoutes.workbench,
      );
    });
  }

  static bool? _canCreateProjectFromWorkbench(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final projectChain = payload['project_chain'];
    if (projectChain is! Map) {
      return null;
    }

    final value = projectChain['canCreateProject'];
    return value is bool ? value : null;
  }

  static _ProjectCreateValidationResult _validateForm({
    required String title,
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

    if (title.isEmpty) {
      errors[_ProjectCreateFieldId.title] = '请输入项目名称';
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
    if (provinceCode == null || provinceName.isEmpty) {
      errors[_ProjectCreateFieldId.provinceName] = '请选择省';
    }
    if (cityCode == null || cityName.isEmpty) {
      errors[_ProjectCreateFieldId.cityName] = '请选择市';
    }
    final hasDistrictCode = _normalizeOptionalText(districtCode ?? '') != null;
    final hasDistrictName = _normalizeOptionalText(districtName) != null;
    if (hasDistrictCode != hasDistrictName) {
      errors[_ProjectCreateFieldId.districtName] = '请选择完整的区/县';
    }
    if (detailAddress.isEmpty) {
      errors[_ProjectCreateFieldId.detailAddress] = '请输入详细地址';
    }
    if (scopeSummary.isEmpty) {
      errors[_ProjectCreateFieldId.scopeSummary] = '请输入范围说明';
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

  static String _projectCreateGuardFailureTitle(ExhibitionLoadResult result) {
    if (_isTransportTechnicalMessage(result.message)) {
      return '网络暂时不可用';
    }

    return switch (result.state) {
      AppPageState.errorRetryable => '当前暂时无法确认创建条件',
      AppPageState.errorNonRetryable => '当前暂时无法打开创建项目',
      AppPageState.notFound => '当前暂未开放创建项目',
      _ => '当前暂时无法打开创建项目',
    };
  }

  static String? _projectCreateGuardFailureMessage(
    ExhibitionLoadResult result,
  ) {
    if (_isTransportTechnicalMessage(result.message)) {
      return '当前无法从项目工作台确认是否可创建项目，请检查网络后再试。';
    }

    if (result.message != null && result.message!.trim().isNotEmpty) {
      return result.message;
    }

    return switch (result.state) {
      AppPageState.errorRetryable => '当前无法从项目工作台确认是否可创建项目，请稍后重试。',
      AppPageState.errorNonRetryable => '当前无法从项目工作台确认是否可创建项目，请稍后再试。',
      AppPageState.notFound => '当前入口还没有承接到创建项目能力。',
      _ => null,
    };
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
