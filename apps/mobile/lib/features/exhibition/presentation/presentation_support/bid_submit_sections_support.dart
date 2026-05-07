part of '../exhibition_trade_pages.dart';

// Strategic reserve: current submit page retired seat/completeness from the
// main surface, but the frozen Package A truth remains available for a bounded
// future reactivation after SSOT approval.
// ignore: unused_element
List<Widget> _buildBidSeatAndCompletenessSections({
  required BuildContext context,
  required String? projectId,
  required String? bidId,
  required ExhibitionLoadResult? seatResult,
  required ExhibitionLoadResult? completenessResult,
  required bool showSeatActions,
  required VoidCallback? onLockSeat,
  required VoidCallback? onReleaseSeat,
  required VoidCallback? onRetrySeat,
  required bool showCompletenessActions,
  required VoidCallback? onFocusQuoteAmount,
  required VoidCallback? onFocusProposalSummary,
  required VoidCallback? onRetryCompleteness,
}) {
  return <Widget>[
    _buildBidSeatSection(
      context: context,
      projectId: projectId,
      bidId: bidId,
      seatResult: seatResult,
      showSeatActions: showSeatActions,
      onLockSeat: onLockSeat,
      onReleaseSeat: onReleaseSeat,
      onRetrySeat: onRetrySeat,
    ),
    const SizedBox(height: 16),
    _buildBidCompletenessSection(
      context: context,
      projectId: projectId,
      bidId: bidId,
      completenessResult: completenessResult,
      showCompletenessActions: showCompletenessActions,
      onFocusQuoteAmount: onFocusQuoteAmount,
      onFocusProposalSummary: onFocusProposalSummary,
      onRetryCompleteness: onRetryCompleteness,
    ),
  ];
}

List<Widget> _buildBidSubmitBody({
  required BuildContext context,
  required String? routeProjectId,
  required bool guardLoading,
  required _BidAccessGuard? accessGuard,
  required bool flowExpanded,
  required bool projectReviewExpanded,
  required bool showContinueBidFlowAction,
  required bool canContinueBidFlow,
  required Future<void> Function() onContinueBidFlow,
  required VoidCallback onToggleProjectReview,
  required ExhibitionLoadResult? projectDetailResult,
  required ExhibitionLoadResult? bidMaterialResult,
  required String? bidMaterialProjectId,
  required Set<String> openingBidMaterialIds,
  required Set<String> openingMaterialReviewEntryKeys,
  required TextEditingController quoteAmountController,
  required TextEditingController proposalSummaryController,
  required bool submitting,
  required List<_BidSubmitAttachmentSlotState> attachmentSlots,
  required GlobalKey quoteAmountFieldKey,
  required GlobalKey proposalSummaryFieldKey,
  required List<Widget> platformServiceFeeChildren,
  required VoidCallback onQuoteAmountChanged,
  required VoidCallback onProposalSummaryChanged,
  required VoidCallback onRetryBidMaterials,
  required Future<void> Function(ProjectBidMaterialReadModel attachment)
  onOpenBidMaterial,
  required Future<void> Function(ProjectCommunicationWorkbenchEntryView entry)
  onOpenMaterialReview,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onUploadAttachment,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onPreviewAttachment,
}) {
  final sections = <Widget>[
    _buildBidSubmitProjectOverviewSection(
      context: context,
      routeProjectId: routeProjectId,
      projectDetailResult: projectDetailResult,
      flowExpanded: flowExpanded,
      projectReviewExpanded: projectReviewExpanded,
      showContinueBidFlowAction: showContinueBidFlowAction,
      canContinueBidFlow: canContinueBidFlow,
      onContinueBidFlow: onContinueBidFlow,
      onToggleProjectReview: onToggleProjectReview,
    ),
  ];

  if (guardLoading) {
    sections.add(const SizedBox(height: 16));
    sections.add(
      const _ActionCard(
        title: '正在核对竞标守卫',
        summary: '正在检查当前登录、组织类型、双重认证和项目状态，请稍候。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _DetailLine(label: '当前状态', value: '守卫状态读取中，当前先不开放竞标提交。'),
        ],
      ),
    );
  }

  if (!guardLoading && accessGuard != null) {
    sections.add(const SizedBox(height: 16));
    sections.add(
      _ActionCard(
        title: accessGuard.title,
        summary: accessGuard.message,
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          const _DetailLine(
            label: '守卫说明',
            value: '当前以前端登录态、组织类型、双重认证和项目只读状态作为导流守卫依据；最终业务权限仍以后端判定为准。',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(
              _resolveBidGuardRouteName(accessGuard, projectId: routeProjectId),
            ),
            child: Text(accessGuard.actionLabel),
          ),
        ],
      ),
    );
  }

  if (!flowExpanded) {
    return sections;
  }

  sections.addAll(<Widget>[
    const SizedBox(height: 16),
    _buildBidSubmitMaterialSection(
      bidMaterialResult: bidMaterialResult,
      projectId: bidMaterialProjectId,
      openingAttachmentIds: openingBidMaterialIds,
      openingReviewEntryKeys: openingMaterialReviewEntryKeys,
      onRetry: onRetryBidMaterials,
      onOpenAttachment: onOpenBidMaterial,
      onOpenMaterialReview: onOpenMaterialReview,
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '填写报价',
      summary: '先填写本次竞标报价；服务费预授权将在发布方资料确认通过后再处理。',
      children: <Widget>[
        _InputField(
          controller: quoteAmountController,
          label: '竞标报价',
          fieldKey: quoteAmountFieldKey,
          keyboardType: TextInputType.number,
          hintText: '例如：1200',
          helperText: '填写当前竞标报价。',
          onChanged: (_) => onQuoteAmountChanged(),
        ),
        const SizedBox(height: 12),
        ...platformServiceFeeChildren,
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '上传方案',
      summary: '方案说明是接单方给发布方的总体概述；项目理解、报价表和进度安排均为必传附件。',
      children: <Widget>[
        _InputField(
          controller: proposalSummaryController,
          label: '方案说明',
          fieldKey: proposalSummaryFieldKey,
          maxLines: 3,
          hintText: '例如：先完成展台结构、照明和基础安装',
          helperText: '接单方给发布方的总体方案概述。',
          onChanged: (_) => onProposalSummaryChanged(),
        ),
        const SizedBox(height: 16),
        const _BidSubmitTemplateDownloadSection(),
        const SizedBox(height: 16),
        _buildBidSubmitAttachmentGrid(
          context: context,
          attachmentSlots: attachmentSlots,
          submitting: submitting,
          onUploadAttachment: onUploadAttachment,
          onPreviewAttachment: onPreviewAttachment,
        ),
      ],
    ),
  ]);

  return sections;
}

Widget _buildBidSubmitProjectOverviewSection({
  required BuildContext context,
  required String? routeProjectId,
  required ExhibitionLoadResult? projectDetailResult,
  required bool flowExpanded,
  required bool projectReviewExpanded,
  required bool showContinueBidFlowAction,
  required bool canContinueBidFlow,
  required Future<void> Function() onContinueBidFlow,
  required VoidCallback onToggleProjectReview,
}) {
  final result = projectDetailResult;
  if (routeProjectId == null) {
    return const _ActionCard(
      title: '已承接项目',
      summary: '提交竞标前先承接当前要处理的项目。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _EmptyNotice(title: '当前还没有承接到项目', message: '请先从项目详情选择立即参与竞标，再进入本页。'),
      ],
    );
  }

  if (result == null || result.state == AppPageState.loading) {
    return _ActionCard(
      title: '已承接项目',
      summary: '正在承接当前要处理的项目。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '当前项目 ID', value: routeProjectId),
        const SizedBox(height: 12),
        const _StateMessage(title: '正在读取项目详情', body: '正在同步当前项目的核心信息与地点安排。'),
      ],
    );
  }

  if (result.state != AppPageState.content) {
    return _ActionCard(
      title: '已承接项目',
      summary: '当前项目承接信息暂不可读。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '当前项目 ID', value: routeProjectId),
        const SizedBox(height: 12),
        _StateMessage(
          title: '项目详情暂不可读',
          body: result.message ?? '当前项目详情暂不可读，请稍后重试。',
        ),
      ],
    );
  }

  final payload = _payloadMap(result.payload) ?? const <String, Object?>{};
  final projectNo = _normalizeId(payload['projectNo'] as String?);
  final exhibitionName = _projectExhibitionName(payload);
  final brandName = _projectBrandName(payload);
  final title = _projectDisplayTitle(payload);
  final state = _stateFromPayload(result.payload);
  final buildingType = _normalizeId(payload['buildingType'] as String?);
  final budgetAmount = payload['budgetAmount'];
  final areaSqm = payload['areaSqm'] as num?;
  final buildingTypeRemark = _normalizeId(
    payload['buildingTypeRemark'] as String?,
  );
  final summaryMap = _payloadMap(payload['summary']);
  final summaryHeading = _normalizeId(summaryMap?['heading'] as String?);
  final description = _normalizeId(payload['description'] as String?);
  final provinceName = _normalizeId(payload['provinceName'] as String?);
  final cityName = _normalizeId(payload['cityName'] as String?);
  final districtName = _normalizeId(payload['districtName'] as String?);
  final detailAddress = _normalizeId(payload['detailAddress'] as String?);
  final scopeSummary = _normalizeId(payload['scopeSummary'] as String?);
  final plannedStartAt = _normalizeId(payload['plannedStartAt'] as String?);
  final plannedEndAt = _normalizeId(payload['plannedEndAt'] as String?);
  final scheduleDetail = _normalizeId(payload['scheduleDetail'] as String?);
  final headline = exhibitionName ?? title;
  final secondaryHeadline = exhibitionName != null
      ? brandName ?? _compatibilityTitle(headline: exhibitionName, title: title)
      : brandName;
  final locationSummary = _locationSummary(
    provinceName: provinceName,
    cityName: cityName,
    districtName: districtName,
    detailAddress: detailAddress,
  );
  final scheduleRange = _scheduleRangeSummary(
    plannedStartAt: plannedStartAt,
    plannedEndAt: plannedEndAt,
  );
  final arrangementMissing =
      _bidSubmitAddressRangeFullyMissing(
        provinceName: provinceName,
        cityName: cityName,
        districtName: districtName,
        detailAddress: detailAddress,
        scopeSummary: scopeSummary,
        plannedStartAt: plannedStartAt,
        plannedEndAt: plannedEndAt,
        scheduleDetail: scheduleDetail,
      ) &&
      description == null;

  if (flowExpanded && !projectReviewExpanded) {
    return _ActionCard(
      title: '已承接项目',
      summary: '项目信息已承接，下面查看报价依据资料、填写报价、上传方案并提交竞标；需要时可复核。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        const _DetailLine(label: '承接状态', value: '已承接当前项目', highlight: true),
        _DetailLine(label: '项目名称', value: headline),
        if (projectNo != null) _DetailLine(label: '项目编号', value: projectNo),
        if (state != null)
          _DetailLine(
            label: '当前状态',
            value: _frontStageStateLabel(state),
            highlight: true,
          ),
        if (locationSummary != null)
          _DetailLine(label: '项目地点', value: locationSummary),
        if (scheduleRange != null)
          _DetailLine(label: '计划时间', value: scheduleRange),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onToggleProjectReview,
          icon: const Icon(Icons.unfold_more),
          label: const Text('复核项目信息'),
        ),
      ],
    );
  }

  return _ActionCard(
    title: '已承接项目',
    summary: flowExpanded
        ? '当前参与竞标的项目已承接，可继续查看材料、填写报价和上传方案。'
        : '当前参与竞标的项目已承接；点击“查看报价依据资料”后再查看材料、填写报价和上传方案。',
    tone: _ActionCardTone.emphasis,
    children: <Widget>[
      _ActionCard(
        title: '核心信息',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      headline,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (secondaryHeadline != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        secondaryHeadline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state != null)
                _StatusPill(
                  label: _frontStageStateLabel(state),
                  tone: _ActionCardTone.muted,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ProjectDetailCompactMetaGrid(
            items: <_ProjectDetailCompactMetaItemData>[
              _ProjectDetailCompactMetaItemData(
                label: '项目编号',
                value: projectNo ?? '未提供',
                fullWidth: true,
              ),
              _ProjectDetailCompactMetaItemData(
                label: '项目类型',
                value: _buildingTypeLabel(buildingType),
              ),
              _ProjectDetailCompactMetaItemData(
                label: '预算金额',
                value: _currencyText(budgetAmount),
                highlight: true,
              ),
              _ProjectDetailCompactMetaItemData(
                label: '项目面积',
                value: _areaSqmOrUnavailable(areaSqm),
              ),
            ],
          ),
          if (buildingTypeRemark != null) ...<Widget>[
            const SizedBox(height: 12),
            _DetailLine(label: '类型备注', value: buildingTypeRemark),
          ],
          if (summaryHeading != null) ...<Widget>[
            const SizedBox(height: 4),
            _DetailLine(label: '项目摘要', value: summaryHeading),
          ],
        ],
      ),
      const SizedBox(height: 16),
      _ActionCard(
        title: '地点与安排',
        children: <Widget>[
          if (arrangementMissing)
            const _EmptyNotice(
              title: '当前暂无地点与安排信息',
              message: '当前项目暂未提供地点、范围、说明或时间安排。',
            ),
          if (locationSummary != null)
            _DetailLine(label: '项目地点', value: locationSummary),
          if (scopeSummary != null)
            _DetailLine(label: '范围说明', value: scopeSummary),
          if (scheduleRange != null)
            _DetailLine(label: '计划时间', value: scheduleRange),
          if (scheduleDetail != null)
            _DetailLine(label: '时间说明', value: scheduleDetail),
          if (description != null)
            _DetailLine(label: '补充说明', value: description),
        ],
      ),
      if (showContinueBidFlowAction) ...<Widget>[
        const SizedBox(height: 16),
        FilledButton(
          onPressed: canContinueBidFlow ? onContinueBidFlow : null,
          child: const Text('查看报价依据资料'),
        ),
        if (!canContinueBidFlow) ...<Widget>[
          const SizedBox(height: 8),
          const Text('项目信息承接完成后，当前按钮才会开放。'),
        ],
      ],
      if (flowExpanded && projectReviewExpanded) ...<Widget>[
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onToggleProjectReview,
          icon: const Icon(Icons.unfold_less),
          label: const Text('收起项目信息'),
        ),
      ],
    ],
  );
}

String _bidSubmitFieldOrUnavailable(String? value) {
  return value ?? '当前项目暂未提供';
}

bool _bidSubmitAddressRangeFullyMissing({
  required String? provinceName,
  required String? cityName,
  required String? districtName,
  required String? detailAddress,
  required String? scopeSummary,
  required String? plannedStartAt,
  required String? plannedEndAt,
  required String? scheduleDetail,
}) {
  return provinceName == null &&
      cityName == null &&
      districtName == null &&
      detailAddress == null &&
      scopeSummary == null &&
      plannedStartAt == null &&
      plannedEndAt == null &&
      scheduleDetail == null;
}

String _areaSqmOrUnavailable(num? value) {
  if (value == null) {
    return '当前项目暂未提供';
  }

  final normalized = value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '');
  return '$normalized ㎡';
}

String? _compatibilityTitle({required String headline, required String title}) {
  return headline == title ? null : title;
}

String? _locationSummary({
  required String? provinceName,
  required String? cityName,
  required String? districtName,
  required String? detailAddress,
}) {
  final regionParts = <String?>[
    provinceName,
    cityName,
    districtName,
  ].nonNulls.toList(growable: false);
  final regionLabel = regionParts.isEmpty ? null : regionParts.join(' / ');
  if (regionLabel == null && detailAddress == null) {
    return null;
  }
  if (regionLabel != null && detailAddress != null) {
    return '$regionLabel · $detailAddress';
  }
  return regionLabel ?? detailAddress;
}

String? _scheduleRangeSummary({
  required String? plannedStartAt,
  required String? plannedEndAt,
}) {
  if (plannedStartAt == null && plannedEndAt == null) {
    return null;
  }
  return '${_bidSubmitFieldOrUnavailable(plannedStartAt)} 至 ${_bidSubmitFieldOrUnavailable(plannedEndAt)}';
}

Widget _buildBidSeatSection({
  required BuildContext context,
  required String? projectId,
  required String? bidId,
  required ExhibitionLoadResult? seatResult,
  required bool showSeatActions,
  required VoidCallback? onLockSeat,
  required VoidCallback? onReleaseSeat,
  required VoidCallback? onRetrySeat,
}) {
  if (bidId == null) {
    return _ActionCard(
      title: '席位状态',
      summary: '当前页面尚未拿到明确 bidId，暂不消费最小席位投影。',
      children: <Widget>[
        _EmptyNotice(
          title: '当前席位不可见',
          message: projectId == null
              ? '当前没有项目上下文，暂时不能展示席位信息。'
              : '当前页面尚未明确 bidId，暂不展示席位信息。',
        ),
      ],
    );
  }

  if (seatResult == null) {
    return _ActionCard(
      title: '席位状态',
      summary: '当前页面只消费最小 seat 状态，不扩成支付、保证金或竞标控制台。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _StateMessage(title: '席位状态读取中', body: '席位信息尚未返回，请稍候重试或重新读取当前竞标上下文。'),
        if (onRetrySeat != null) ...<Widget>[
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetrySeat,
            child: const Text('重新读取席位状态'),
          ),
        ],
      ],
    );
  }

  if (seatResult.state == AppPageState.loading) {
    return const _ActionCard(
      title: '席位状态',
      summary: '当前正在读取最小 seat 投影。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[_StateMessage(title: '当前状态', body: '席位信息读取中，请稍候。')],
    );
  }

  if (seatResult.state != AppPageState.content) {
    if (seatResult.state == AppPageState.empty) {
      return _ActionCard(
        title: '席位状态',
        summary: '当前页面暂未展示该竞标的最小席位信息。',
        children: <Widget>[
          _EmptyNotice(
            title: '当前席位不可见',
            message: projectId == null
                ? '当前没有项目上下文，暂时不能展示席位信息。'
                : '当前页面尚未明确 bidId，暂不展示席位信息。',
          ),
        ],
      );
    }

    final title = seatResult.state == AppPageState.unauthorized
        ? '席位状态需要恢复登录'
        : seatResult.state == AppPageState.forbidden
        ? '席位状态当前未开放'
        : seatResult.state == AppPageState.notFound
        ? '席位状态暂未承接'
        : seatResult.state == AppPageState.errorRetryable
        ? '席位状态暂时不可用'
        : seatResult.state == AppPageState.errorNonRetryable
        ? '席位状态受控失败'
        : '席位状态暂不可读';
    final body = seatResult.message ?? '当前席位信息暂不可读，请稍后再试或回到上一步重新进入。';
    return _ActionCard(
      title: '席位状态',
      summary: '当前页面只消费最小 seat 状态，不扩成支付、保证金或竞标控制台。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _StateMessage(title: title, body: body),
        if (onRetrySeat != null) ...<Widget>[
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetrySeat,
            child: const Text('重新读取席位状态'),
          ),
        ],
      ],
    );
  }

  final seatState = _stateFromPayload(seatResult.payload) ?? 'available';
  final seatId = _normalizeId(
    _payloadMap(seatResult.payload)?['seatId'] as String?,
  );
  final expiresAt = _normalizeId(
    _payloadMap(seatResult.payload)?['expiresAt'] as String?,
  );
  final releasedAt = _normalizeId(
    _payloadMap(seatResult.payload)?['releasedAt'] as String?,
  );
  final seatSummary = switch (seatState) {
    'available' => '当前席位可锁定，页面不会伪装成已占用。',
    'locked' => '当前席位已锁定，页面会保留最小占位信息。',
    'released' => '当前席位已释放，不保留伪 locked 态。',
    'timed_out' => '当前席位已超时，不保留伪 locked 态。',
    _ => '当前席位处于 ${_frontStageStateLabel(seatState)}。',
  };

  final buttons = <Widget>[];
  if (showSeatActions) {
    if (seatState == 'locked') {
      if (onReleaseSeat != null) {
        buttons.add(
          FilledButton.tonal(
            onPressed: onReleaseSeat,
            child: const Text('释放候选席位'),
          ),
        );
      }
    } else if (seatState == 'available' || seatState == 'released') {
      if (onLockSeat != null) {
        buttons.add(
          FilledButton(
            onPressed: onLockSeat,
            child: Text(seatState == 'available' ? '锁定候选席位' : '重新锁定候选席位'),
          ),
        );
      }
    }
  }

  return _ActionCard(
    title: '席位状态',
    summary: '当前页面只消费最小 seat 状态，不扩成支付、保证金或竞标控制台。',
    tone: _ActionCardTone.emphasis,
    children: <Widget>[
      if (projectId != null)
        _InstanceSummaryLine(title: '当前项目 ID', value: projectId),
      if (projectId != null) const SizedBox(height: 12),
      _InstanceSummaryLine(title: '当前竞标 ID', value: bidId),
      const SizedBox(height: 12),
      if (seatId != null) ...<Widget>[
        _InstanceSummaryLine(title: '席位 ID', value: seatId),
        const SizedBox(height: 12),
      ],
      _DetailLine(
        label: '当前状态',
        value: _frontStageStateLabel(seatState),
        highlight: true,
      ),
      const SizedBox(height: 10),
      _StateMessage(title: '席位说明', body: seatSummary),
      if (expiresAt != null) ...<Widget>[
        const SizedBox(height: 12),
        _DetailLine(label: '有效期至', value: expiresAt),
      ],
      if (releasedAt != null) ...<Widget>[
        const SizedBox(height: 8),
        _DetailLine(label: '释放时间', value: releasedAt),
      ],
      if (buttons.isNotEmpty) ...<Widget>[
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: buttons),
      ],
      if (onRetrySeat != null && seatState == 'timed_out') ...<Widget>[
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: onRetrySeat,
          child: const Text('重新读取席位状态'),
        ),
      ],
    ],
  );
}

Widget _buildBidCompletenessSection({
  required BuildContext context,
  required String? projectId,
  required String? bidId,
  required ExhibitionLoadResult? completenessResult,
  required bool showCompletenessActions,
  required VoidCallback? onFocusQuoteAmount,
  required VoidCallback? onFocusProposalSummary,
  required VoidCallback? onRetryCompleteness,
}) {
  if (bidId == null) {
    return _ActionCard(
      title: '资料完整度',
      summary: '当前页面尚未拿到明确 bidId，暂不消费最小完整度投影。',
      children: <Widget>[
        _EmptyNotice(
          title: '当前完整度不可见',
          message: projectId == null
              ? '当前没有项目上下文，暂时不能展示完整度信息。'
              : '当前页面尚未明确 bidId，暂不展示完整度信息。',
        ),
      ],
    );
  }

  if (completenessResult == null) {
    return _ActionCard(
      title: '资料完整度',
      summary: '当前页面只消费最小 completeness 投影，不扩成完整方案工作台。',
      children: <Widget>[
        _StateMessage(title: '完整度信息读取中', body: '完整度信息尚未返回，请稍候重试或重新读取当前竞标上下文。'),
        if (onRetryCompleteness != null) ...<Widget>[
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetryCompleteness,
            child: const Text('重新读取完整度'),
          ),
        ],
      ],
    );
  }

  if (completenessResult.state == AppPageState.loading) {
    return const _ActionCard(
      title: '资料完整度',
      summary: '当前正在读取最小 completeness 投影。',
      children: <Widget>[_StateMessage(title: '当前状态', body: '完整度信息读取中，请稍候。')],
    );
  }

  if (completenessResult.state != AppPageState.content) {
    if (completenessResult.state == AppPageState.empty) {
      return _ActionCard(
        title: '资料完整度',
        summary: '当前页面暂未展示该竞标的最小完整度信息。',
        children: <Widget>[
          _EmptyNotice(
            title: '当前完整度不可见',
            message: projectId == null
                ? '当前没有项目上下文，暂时不能展示完整度信息。'
                : '当前页面尚未明确 bidId，暂不展示完整度信息。',
          ),
        ],
      );
    }

    final title = completenessResult.state == AppPageState.unauthorized
        ? '完整度信息需要恢复登录'
        : completenessResult.state == AppPageState.forbidden
        ? '完整度信息当前未开放'
        : completenessResult.state == AppPageState.notFound
        ? '完整度信息暂未承接'
        : completenessResult.state == AppPageState.errorRetryable
        ? '完整度信息暂时不可用'
        : completenessResult.state == AppPageState.errorNonRetryable
        ? '完整度信息受控失败'
        : '完整度信息暂不可读';
    final body = completenessResult.message ?? '当前完整度信息暂不可读，请稍后再试或回到上一步重新进入。';
    return _ActionCard(
      title: '资料完整度',
      summary: '当前页面只消费最小 completeness 投影，不扩成完整方案工作台。',
      children: <Widget>[
        _StateMessage(title: title, body: body),
        if (onRetryCompleteness != null) ...<Widget>[
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetryCompleteness,
            child: const Text('重新读取完整度'),
          ),
        ],
      ],
    );
  }

  final completenessState =
      _stateFromPayload(completenessResult.payload) ?? 'incomplete';
  final missingItems = _missingItemsFromPayload(completenessResult.payload);
  final quoteAmountReady = _boolFromPayload(
    completenessResult.payload,
    'quoteAmountReady',
  );
  final proposalSummaryReady = _boolFromPayload(
    completenessResult.payload,
    'proposalSummaryReady',
  );
  final completenessSummary = switch (completenessState) {
    'complete' => '当前 bid 的最小资料已经齐全。',
    'incomplete' => '当前 bid 的最小资料仍需补齐。',
    _ => '当前完整度处于 ${_frontStageStateLabel(completenessState)}。',
  };

  final actionButtons = <Widget>[];
  if (showCompletenessActions && completenessState == 'incomplete') {
    if (missingItems.any(_isQuoteAmountItem) && onFocusQuoteAmount != null) {
      actionButtons.add(
        FilledButton(onPressed: onFocusQuoteAmount, child: const Text('补齐报价')),
      );
    }
    if (missingItems.any(_isProposalSummaryItem) &&
        onFocusProposalSummary != null) {
      actionButtons.add(
        FilledButton.tonal(
          onPressed: onFocusProposalSummary,
          child: const Text('补齐方案摘要'),
        ),
      );
    }
  }

  return _ActionCard(
    title: '资料完整度',
    summary: '当前页面只消费最小 completeness 投影，不扩成完整方案工作台。',
    children: <Widget>[
      if (projectId != null)
        _InstanceSummaryLine(title: '当前项目 ID', value: projectId),
      if (projectId != null) const SizedBox(height: 12),
      _InstanceSummaryLine(title: '当前竞标 ID', value: bidId),
      const SizedBox(height: 12),
      _DetailLine(
        label: '当前状态',
        value: _frontStageStateLabel(completenessState),
        highlight: true,
      ),
      const SizedBox(height: 10),
      _StateMessage(title: '完整度说明', body: completenessSummary),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          _StatusPill(
            label: '报价：${quoteAmountReady ? '已准备' : '未准备'}',
            tone: quoteAmountReady
                ? _ActionCardTone.emphasis
                : _ActionCardTone.muted,
          ),
          _StatusPill(
            label: '方案摘要：${proposalSummaryReady ? '已准备' : '未准备'}',
            tone: proposalSummaryReady
                ? _ActionCardTone.emphasis
                : _ActionCardTone.muted,
          ),
        ],
      ),
      if (missingItems.isNotEmpty) ...<Widget>[
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: missingItems
              .map(
                (String item) => _StatusPill(
                  label: '缺失：${_missingItemLabel(item)}',
                  tone: _ActionCardTone.standard,
                ),
              )
              .toList(),
        ),
      ],
      if (actionButtons.isNotEmpty) ...<Widget>[
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: actionButtons),
      ],
      if (onRetryCompleteness != null &&
          completenessState != 'complete' &&
          actionButtons.isEmpty) ...<Widget>[
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: onRetryCompleteness,
          child: const Text('重新读取完整度'),
        ),
      ],
    ],
  );
}

List<String> _missingItemsFromPayload(Object? payload) {
  final rawItems = _payloadMap(payload)?['missingItems'];
  if (rawItems is! List) {
    return const <String>[];
  }

  return rawItems
      .whereType<String>()
      .map(_normalizeId)
      .whereType<String>()
      .toList();
}

bool _boolFromPayload(Object? payload, String field) {
  final value = _payloadMap(payload)?[field];
  return value is bool && value;
}

bool _isQuoteAmountItem(String item) {
  final normalized = item.toLowerCase();
  return normalized.contains('quote') ||
      normalized.contains('报价') ||
      normalized.contains('amount');
}

bool _isProposalSummaryItem(String item) {
  final normalized = item.toLowerCase();
  return normalized.contains('proposal') ||
      normalized.contains('summary') ||
      normalized.contains('方案');
}

String _missingItemLabel(String item) {
  final normalized = item.toLowerCase();
  if (_isQuoteAmountItem(normalized)) {
    return '报价';
  }
  if (_isProposalSummaryItem(normalized)) {
    return '方案摘要';
  }
  return item;
}
