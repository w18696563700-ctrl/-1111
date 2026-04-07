part of '../exhibition_trade_pages.dart';

List<Widget> _buildProjectCreateRoundABody({
  required BuildContext context,
  required bool guardLoading,
  required _ProjectCreateAccessGuard accessGuard,
  required String? formErrorMessage,
  required String? selectedProjectTypeLabel,
  required String? selectedStandardizedLocationLabel,
  required TextEditingController titleController,
  required TextEditingController buildingTypeController,
  required TextEditingController buildingTypeRemarkController,
  required TextEditingController budgetAmountController,
  required TextEditingController areaSqmController,
  required TextEditingController provinceNameController,
  required TextEditingController cityNameController,
  required TextEditingController districtNameController,
  required TextEditingController detailAddressController,
  required TextEditingController scopeSummaryController,
  required TextEditingController plannedStartAtController,
  required TextEditingController plannedEndAtController,
  required TextEditingController scheduleDetailController,
  required TextEditingController descriptionController,
  required Map<_ProjectCreateFieldId, GlobalKey> fieldKeys,
  required Map<_ProjectCreateFieldId, String> fieldErrors,
  required ValueChanged<_ProjectCreateFieldId> onFieldInteracted,
  required Future<void> Function() onProjectTypePressed,
  required Future<void> Function() onStandardizedLocationPressed,
  required Future<void> Function() onDistrictPressed,
  required VoidCallback onPlannedStartDatePressed,
  required VoidCallback onPlannedEndDatePressed,
  required VoidCallback onPlannedStartDateCleared,
  required VoidCallback onPlannedEndDateCleared,
}) {
  final projectTypeHelperText = switch (selectedProjectTypeLabel) {
    final String value when value.isNotEmpty => '已选择$value，当前会统一按展览项目归类发布。',
    _ => '请选择一个更贴近当前项目的场景，当前会统一按展览项目归类发布。',
  };
  final standardizedLocationHelperText =
      switch (selectedStandardizedLocationLabel) {
        final String value when value.isNotEmpty => '已选择$value，提交时会自动带入省市信息。',
        _ => '请选择项目所在地区，系统会自动带入省市信息。',
      };

  return <Widget>[
    if (guardLoading)
      const _ActionCard(
        title: '正在确认创建条件',
        summary: '正在检查登录、组织和当前项目工作台状态。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[_DetailLine(label: '当前状态', value: '请稍候后再继续。')],
      ),
    if (!guardLoading && accessGuard.blocked)
      _ActionCard(
        title: accessGuard.title ?? '当前发布入口受控',
        summary: accessGuard.message ?? '当前发布入口暂不可继续。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          if (accessGuard.actionLabel != null)
            _DetailLine(label: '下一步', value: accessGuard.actionLabel!),
          if (accessGuard.actionRouteName != null &&
              accessGuard.actionLabel != null) ...<Widget>[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(accessGuard.actionRouteName!),
              child: Text(accessGuard.actionLabel!),
            ),
          ],
        ],
      ),
    if (guardLoading || accessGuard.blocked) const SizedBox(height: 16),
    _ActionCard(
      title: '基础信息',
      summary: '先补齐项目名称、类型、预算和面积，让后续沟通更聚焦。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (formErrorMessage case final String message) ...<Widget>[
          _StateMessage(title: '请先完善当前信息', body: message),
          const SizedBox(height: 12),
        ],
        _InputField(
          controller: titleController,
          fieldKey: fieldKeys[_ProjectCreateFieldId.title],
          inputKey: const ValueKey<String>('project-create-title'),
          label: '项目名称',
          hintText: '例如：春季医疗器械展主展区搭建',
          helperText: '建议填写一个便于内部识别和对外沟通的项目名称。',
          required: true,
          errorText: fieldErrors[_ProjectCreateFieldId.title],
          onChanged: (_) => onFieldInteracted(_ProjectCreateFieldId.title),
        ),
        _InputField(
          controller: buildingTypeController,
          fieldKey: fieldKeys[_ProjectCreateFieldId.buildingType],
          inputKey: const ValueKey<String>('project-create-building-type'),
          label: '项目类型',
          hintText: '请选择项目类型',
          helperText: projectTypeHelperText,
          required: true,
          readOnly: true,
          errorText: fieldErrors[_ProjectCreateFieldId.buildingType],
          onTap: onProjectTypePressed,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        _InputField(
          controller: buildingTypeRemarkController,
          fieldKey: fieldKeys[_ProjectCreateFieldId.buildingTypeRemark],
          inputKey: const ValueKey<String>(
            'project-create-building-type-remark',
          ),
          label: '类型备注（选填）',
          hintText: '例如：医疗器械展区特装搭建',
          helperText: '只补充当前项目类型的细节，不替代正式项目类型。',
          maxLines: 2,
          errorText: fieldErrors[_ProjectCreateFieldId.buildingTypeRemark],
          onChanged: (_) =>
              onFieldInteracted(_ProjectCreateFieldId.buildingTypeRemark),
        ),
        _ResponsiveFieldGroup(
          columnsWhenWide: 2,
          minItemWidth: 240,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _InputField(
              controller: budgetAmountController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.budgetAmount],
              inputKey: const ValueKey<String>('project-create-budget-amount'),
              label: '预算金额',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: '例如：180000',
              helperText: '填写本次项目的预计预算金额，便于后续快速判断承接范围。',
              required: true,
              errorText: fieldErrors[_ProjectCreateFieldId.budgetAmount],
              onChanged: (_) =>
                  onFieldInteracted(_ProjectCreateFieldId.budgetAmount),
            ),
            _InputField(
              controller: areaSqmController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.areaSqm],
              inputKey: const ValueKey<String>('project-create-area-sqm'),
              label: '项目面积',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: '例如：350.50',
              helperText: '当前为选填，只填写数值真值，单位固定为㎡。',
              suffixText: '㎡',
              errorText: fieldErrors[_ProjectCreateFieldId.areaSqm],
              onChanged: (_) =>
                  onFieldInteracted(_ProjectCreateFieldId.areaSqm),
            ),
          ],
        ),
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '项目地点与范围',
      summary: '先确认项目所在地区，再补充详细地址和范围说明。',
      children: <Widget>[
        const _StateMessage(
          title: '地区选择说明',
          body: '请先选择项目所在地区，系统会自动带入省、市信息；如需补充区/县，也可以继续选择更准确的位置。',
        ),
        const SizedBox(height: 12),
        _ResponsiveFieldGroup(
          wrapKey: const ValueKey<String>('project-create-location-fields'),
          columnsWhenWide: 3,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _InputField(
              controller: provinceNameController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.provinceName],
              inputKey: const ValueKey<String>('project-create-province'),
              label: '省',
              hintText: '请选择项目所在地区',
              helperText: standardizedLocationHelperText,
              required: true,
              readOnly: true,
              errorText: fieldErrors[_ProjectCreateFieldId.provinceName],
              onTap: onStandardizedLocationPressed,
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            _InputField(
              controller: cityNameController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.cityName],
              inputKey: const ValueKey<String>('project-create-city'),
              label: '市',
              hintText: '将随地区自动带入',
              helperText: '市会随地区选择自动带入，无需单独填写。',
              required: true,
              readOnly: true,
              errorText: fieldErrors[_ProjectCreateFieldId.cityName],
              onTap: onStandardizedLocationPressed,
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            _InputField(
              controller: districtNameController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.districtName],
              inputKey: const ValueKey<String>('project-create-district'),
              label: '区/县',
              hintText: '可选填',
              helperText: '如需补充区/县，可继续选择更准确的位置。',
              readOnly: true,
              errorText: fieldErrors[_ProjectCreateFieldId.districtName],
              onTap: onDistrictPressed,
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ],
        ),
        _InputField(
          controller: detailAddressController,
          fieldKey: fieldKeys[_ProjectCreateFieldId.detailAddress],
          inputKey: const ValueKey<String>('project-create-detail-address'),
          label: '详细地址',
          hintText: '例如：世纪城新国际会展中心 6 号馆西门',
          helperText: '填写进场、施工或对接的具体地点，方便后续安排。',
          maxLines: 2,
          required: true,
          errorText: fieldErrors[_ProjectCreateFieldId.detailAddress],
          onChanged: (_) =>
              onFieldInteracted(_ProjectCreateFieldId.detailAddress),
        ),
        _InputField(
          controller: scopeSummaryController,
          fieldKey: fieldKeys[_ProjectCreateFieldId.scopeSummary],
          inputKey: const ValueKey<String>('project-create-scope-summary'),
          label: '范围说明',
          hintText: '例如：主舞台、医疗器械展区与灯光联动区进场搭建',
          helperText: '一句话概括本次发布范围，方便快速理解需求。',
          maxLines: 3,
          required: true,
          errorText: fieldErrors[_ProjectCreateFieldId.scopeSummary],
          onChanged: (_) =>
              onFieldInteracted(_ProjectCreateFieldId.scopeSummary),
        ),
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '计划时间',
      summary: '计划日期支持直接点选，页面会自动显示为中文日期；如需补充更细的时间说明，也可以直接填写。',
      children: <Widget>[
        _ResponsiveFieldGroup(
          wrapKey: const ValueKey<String>('project-create-date-fields'),
          columnsWhenWide: 2,
          minItemWidth: 240,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _InputField(
              controller: plannedStartAtController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.plannedStartAt],
              inputKey: const ValueKey<String>(
                'project-create-planned-start-at',
              ),
              label: '计划开始日期',
              keyboardType: TextInputType.datetime,
              hintText: '请选择开始日期',
              helperText: '开始日期可选填，选择后会自动显示为中文日期。',
              errorText: fieldErrors[_ProjectCreateFieldId.plannedStartAt],
              suffixIcon: _DateFieldActions(
                hasValue: plannedStartAtController.text.trim().isNotEmpty,
                pickTooltip: '选择计划开始日期',
                clearTooltip: '清空计划开始日期',
                onPick: onPlannedStartDatePressed,
                onClear: onPlannedStartDateCleared,
              ),
            ),
            _InputField(
              controller: plannedEndAtController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.plannedEndAt],
              inputKey: const ValueKey<String>('project-create-planned-end-at'),
              label: '计划结束日期',
              keyboardType: TextInputType.datetime,
              hintText: '请选择结束日期',
              helperText: '结束日期可选填，选择后会自动显示为中文日期。',
              errorText: fieldErrors[_ProjectCreateFieldId.plannedEndAt],
              suffixIcon: _DateFieldActions(
                hasValue: plannedEndAtController.text.trim().isNotEmpty,
                pickTooltip: '选择计划结束日期',
                clearTooltip: '清空计划结束日期',
                onPick: onPlannedEndDatePressed,
                onClear: onPlannedEndDateCleared,
              ),
            ),
          ],
        ),
        _InputField(
          controller: scheduleDetailController,
          fieldKey: fieldKeys[_ProjectCreateFieldId.scheduleDetail],
          inputKey: const ValueKey<String>('project-create-schedule-detail'),
          label: '详细时间（选填）',
          hintText: '例如：4 月 10 日晚进场，4 月 18 日 20:00 前撤场',
          helperText: '只补充当前排期说明，不替代计划开始/结束日期。',
          maxLines: 3,
          errorText: fieldErrors[_ProjectCreateFieldId.scheduleDetail],
          onChanged: (_) =>
              onFieldInteracted(_ProjectCreateFieldId.scheduleDetail),
        ),
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '补充说明与附件',
      summary: '补充项目背景说明；资料可在发布成功后继续补齐。',
      children: <Widget>[
        _InputField(
          controller: descriptionController,
          fieldKey: fieldKeys[_ProjectCreateFieldId.description],
          inputKey: const ValueKey<String>('project-create-description'),
          label: '补充说明',
          hintText: '例如：本期先完成基础施工与设备进场，重点关注医疗器械展区和灯光联动。',
          helperText: '可补充项目背景、协作提醒或现场重点，当前为选填。',
          maxLines: 4,
          onChanged: (_) =>
              onFieldInteracted(_ProjectCreateFieldId.description),
        ),
        const SizedBox(height: 4),
        const _StateMessage(title: '资料补充', body: '项目发布成功后，可以继续补充效果图、施工图和其他资料。'),
      ],
    ),
  ];
}

class _ResponsiveFieldGroup extends StatelessWidget {
  const _ResponsiveFieldGroup({
    required this.children,
    this.wrapKey,
    this.columnsWhenWide = 3,
    this.minItemWidth = 180,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  final List<Widget> children;
  final Key? wrapKey;
  final int columnsWhenWide;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final columns = _resolveColumns(constraints.maxWidth);
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          key: wrapKey,
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map((Widget child) => SizedBox(width: itemWidth, child: child))
              .toList(growable: false),
        );
      },
    );
  }

  int _resolveColumns(double maxWidth) {
    final wideThreshold =
        minItemWidth * columnsWhenWide + spacing * (columnsWhenWide - 1);
    if (maxWidth >= wideThreshold) {
      return columnsWhenWide;
    }
    if (maxWidth >= minItemWidth * 2 + spacing) {
      return 2;
    }
    return 1;
  }
}

class _DateFieldActions extends StatelessWidget {
  const _DateFieldActions({
    required this.hasValue,
    required this.pickTooltip,
    required this.clearTooltip,
    required this.onPick,
    required this.onClear,
  });

  final bool hasValue;
  final String pickTooltip;
  final String clearTooltip;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (hasValue)
          IconButton(
            tooltip: clearTooltip,
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded),
          ),
        IconButton(
          tooltip: pickTooltip,
          onPressed: onPick,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ],
    );
  }
}
