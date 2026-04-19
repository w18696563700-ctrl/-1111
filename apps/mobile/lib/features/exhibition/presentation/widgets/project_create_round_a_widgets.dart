part of '../exhibition_trade_pages.dart';

List<Widget> _buildProjectCreateRoundABody({
  required BuildContext context,
  required bool guardLoading,
  required _ProjectCreateAccessGuard accessGuard,
  required String? formErrorMessage,
  required String? selectedProjectTypeLabel,
  required String? selectedStandardizedLocationLabel,
  required bool hasStandardizedLocationSelection,
  required bool districtSelectionEnabled,
  required TextEditingController exhibitionNameController,
  required TextEditingController brandNameController,
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
  required Future<void> Function() onScopeSummaryPressed,
  required VoidCallback onPlannedStartDatePressed,
  required VoidCallback onPlannedEndDatePressed,
  required VoidCallback onPlannedStartDateCleared,
  required VoidCallback onPlannedEndDateCleared,
}) {
  final projectTypeHelperText = switch (selectedProjectTypeLabel) {
    final String value when value.isNotEmpty => '已选择$value，当前会统一按会展归类发布。',
    _ => '请选择一个更贴近当前项目的场景，当前会统一按会展归类发布。',
  };
  final standardizedLocationHelperText =
      switch (selectedStandardizedLocationLabel) {
        final String value when value.isNotEmpty => '已选择$value，可继续补充区/县。',
        _ => '请选择项目所在省 / 市，系统会自动带入对应地区信息。',
      };
  final cityHelperText = hasStandardizedLocationSelection
      ? '市会随左侧地区自动带入；如需调整，请重新选择省 / 市。'
      : '请先在左侧选择省 / 市，市会自动带入。';
  final districtHintText = !hasStandardizedLocationSelection
      ? '先选择省 / 市'
      : districtSelectionEnabled
      ? '可选填'
      : '当前无需补充';
  final districtHelperText = !hasStandardizedLocationSelection
      ? '请先选择省 / 市，再决定是否补充区/县。'
      : districtSelectionEnabled
      ? '如需补充区/县，可继续选择更准确的位置。'
      : '当前所选城市暂无区/县选项，可直接填写详细地址。';

  return <Widget>[
    if (guardLoading)
      const _ActionCard(
        title: '正在确认创建条件',
        summary: '正在检查登录、组织主体、认证状态和当前创建资格。',
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
      summary: '先补齐展会、品牌、类型、预算和面积，让公开展示身份和沟通对象都更清楚。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (formErrorMessage case final String message) ...<Widget>[
          _StateMessage(title: '请先完善当前信息', body: message),
          const SizedBox(height: 12),
        ],
        _ResponsiveFieldGroup(
          columnsWhenWide: 2,
          minItemWidth: 180,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _InputField(
              controller: exhibitionNameController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.title],
              inputKey: const ValueKey<String>('project-create-title'),
              label: '展会',
              hintText: '例如：春季医疗器械展',
              helperText: '第一格填写展会名称；公域展示与详情会优先消费这个字段。',
              required: true,
              errorText: fieldErrors[_ProjectCreateFieldId.title],
              onChanged: (_) => onFieldInteracted(_ProjectCreateFieldId.title),
            ),
            _InputField(
              controller: brandNameController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.brandName],
              inputKey: const ValueKey<String>('project-create-brand-name'),
              label: '品牌',
              hintText: '例如：迈德瑞',
              helperText: '第二格填写品牌名称；前端会同时保留 legacy title compatibility。',
              required: true,
              errorText: fieldErrors[_ProjectCreateFieldId.brandName],
              onChanged: (_) =>
                  onFieldInteracted(_ProjectCreateFieldId.brandName),
            ),
          ],
        ),
        _ResponsiveFieldGroup(
          columnsWhenWide: 3,
          minItemWidth: 120,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
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
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '项目地点与范围',
      summary: '先确认项目所在地区，再补充详细地址；范围说明需要先补齐后才能保存项目。',
      children: <Widget>[
        const _StateMessage(
          title: '地区选择说明',
          body: '请先选择项目所在省 / 市，系统会自动带入对应层级；如需补充区/县，也可以继续选择更准确的位置。',
        ),
        const SizedBox(height: 12),
        _ResponsiveFieldGroup(
          wrapKey: const ValueKey<String>('project-create-location-fields'),
          columnsWhenWide: 3,
          minItemWidth: 120,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _InputField(
              controller: provinceNameController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.provinceName],
              inputKey: const ValueKey<String>('project-create-province'),
              label: '省',
              hintText: '点击选择省 / 市',
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
              helperText: cityHelperText,
              readOnly: true,
              enabled: false,
              errorText: fieldErrors[_ProjectCreateFieldId.cityName],
              suffixIcon: const Icon(Icons.lock_outline_rounded),
            ),
            _InputField(
              controller: districtNameController,
              fieldKey: fieldKeys[_ProjectCreateFieldId.districtName],
              inputKey: const ValueKey<String>('project-create-district'),
              label: '区/县',
              hintText: districtHintText,
              helperText: districtHelperText,
              readOnly: true,
              enabled: districtSelectionEnabled,
              errorText: fieldErrors[_ProjectCreateFieldId.districtName],
              onTap: districtSelectionEnabled ? onDistrictPressed : null,
              suffixIcon: Icon(
                districtSelectionEnabled
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.lock_outline_rounded,
              ),
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
        _ProjectScopeSummaryButton(
          fieldKey: fieldKeys[_ProjectCreateFieldId.scopeSummary],
          buttonKey: const ValueKey<String>('project-create-scope-summary'),
          value: scopeSummaryController.text.trim(),
          errorText: fieldErrors[_ProjectCreateFieldId.scopeSummary],
          onPressed: onScopeSummaryPressed,
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
          minItemWidth: 180,
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
      summary: '先补充项目背景说明；保存基本信息后会跳转到我的项目继续处理，进入预发布列表后即可补充正式附件。',
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
        const _StateMessage(
          title: '资料补充',
          body:
              '保存基本信息后，会先跳转到我的项目；你可以从草稿或预发布列表继续确认回显。效果图、施工图和其他资料会在进入预发布列表后开放为正式附件。',
        ),
      ],
    ),
  ];
}

class _ProjectScopeSummaryButton extends StatelessWidget {
  const _ProjectScopeSummaryButton({
    required this.value,
    required this.onPressed,
    this.fieldKey,
    this.buttonKey,
    this.errorText,
  });

  final String value;
  final Key? fieldKey;
  final Key? buttonKey;
  final String? errorText;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasValue = value.trim().isNotEmpty;

    return Padding(
      key: fieldKey,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          OutlinedButton.icon(
            key: buttonKey,
            onPressed: () {
              onPressed();
            },
            icon: Icon(
              hasValue ? Icons.edit_outlined : Icons.add_rounded,
              size: 18,
            ),
            label: Text(hasValue ? '编辑范围说明' : '添加范围说明'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              side: BorderSide(
                color: errorText == null
                    ? colorScheme.outlineVariant
                    : colorScheme.error,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasValue ? value.trim() : '一句话概括本次发布范围，当前为必填。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: errorText == null
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.error,
            ),
          ),
          if (errorText case final String value) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
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
