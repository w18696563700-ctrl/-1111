part of '../exhibition_trade_pages.dart';

List<Widget> _buildBidSubmitResultSections({
  required BuildContext context,
  required ExhibitionActionResult result,
  required String? projectId,
  required ExhibitionStageDataOrigin? lastResultOrigin,
}) {
  final bidId = _bidIdFromPayload(result.payload);
  if (!result.isSuccess || bidId == null) {
    return const <Widget>[];
  }

  return <Widget>[
    const SizedBox(height: 16),
    _ActionCard(
      title: '竞标已提交',
      summary: lastResultOrigin == ExhibitionStageDataOrigin.demo
          ? '当前竞标结果来自演示内容，仅用于继续讲解当前页面，不代表真实链路已成功提交。'
          : '当前竞标已经完成最小提交。此轮成功走廊到 bidId 为止，不继续扩展订单或后续链路。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '竞标 ID', value: bidId),
        if (lastResultOrigin == ExhibitionStageDataOrigin.demo) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前展示：演示内容',
            message: '当前提交结果来自演示内容，真实竞标链路恢复后会自动切回已接通内容。',
          ),
        ],
        const SizedBox(height: 12),
        const _StateMessage(
          title: '当前结果',
          body: '竞标最小提交已经完成。当前页面只保留 bid 提交结果反馈。',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (projectId != null)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.projectDetailWithProjectId(projectId),
                  );
                },
                child: const Text('回到项目详情'),
              ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).pushNamed(ExhibitionRoutes.showcase);
              },
              child: const Text('回到项目展示'),
            ),
          ],
        ),
      ],
    ),
  ];
}

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
  required String? bidId,
  required ExhibitionLoadResult? seatResult,
  required ExhibitionLoadResult? completenessResult,
  required bool showSeatActions,
  required VoidCallback? onLockSeat,
  required VoidCallback? onReleaseSeat,
  required TextEditingController quoteAmountController,
  required TextEditingController proposalSummaryController,
  required bool submitting,
  required VoidCallback onApplyDemoBidResult,
  required GlobalKey quoteAmountFieldKey,
  required GlobalKey proposalSummaryFieldKey,
  required VoidCallback onFocusQuoteAmount,
  required VoidCallback onFocusProposalSummary,
  required VoidCallback onRetryBidProjection,
}) {
  return <Widget>[
    if (guardLoading)
      const _ActionCard(
        title: '正在核对竞标守卫',
        summary: '正在检查当前登录、组织类型、双重认证和项目状态，请稍候。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _DetailLine(label: '当前状态', value: '守卫状态读取中，当前先不开放竞标提交。'),
        ],
      ),
    if (!guardLoading && accessGuard != null)
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
    if (guardLoading || accessGuard != null) const SizedBox(height: 16),
    _ActionCard(
      title: '第一步 承接当前项目',
      summary: '最小竞标继续面会直接挂在当前项目下继续推进，所以这一步必须先承接到真实项目。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (routeProjectId != null)
          _InstanceSummaryLine(title: '当前项目 ID', value: routeProjectId),
        if (routeProjectId != null) const SizedBox(height: 12),
        const _StateMessage(title: '当前目标', body: '完成本次最小竞标提交并确认 bidId 结果。'),
        if (routeProjectId == null) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前不可继续',
            message: '当前没有承接到真实项目时，暂时不能继续真实竞标；如需演示，可直接使用演示结果继续讲解。',
          ),
        ],
      ],
    ),
    const SizedBox(height: 16),
    ..._buildBidSeatAndCompletenessSections(
      context: context,
      projectId: routeProjectId,
      bidId: bidId,
      seatResult: seatResult,
      completenessResult: completenessResult,
      showSeatActions: showSeatActions,
      onLockSeat: onLockSeat,
      onReleaseSeat: onReleaseSeat,
      onRetrySeat: onRetryBidProjection,
      showCompletenessActions: true,
      onFocusQuoteAmount: onFocusQuoteAmount,
      onFocusProposalSummary: onFocusProposalSummary,
      onRetryCompleteness: onRetryBidProjection,
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '第二步 补齐最小竞标信息',
      summary: '把本次报价和方案说明补充完整，当前最小竞标提交仅消费这两项输入。',
      children: <Widget>[
        _InputField(
          controller: quoteAmountController,
          label: '竞标报价',
          fieldKey: quoteAmountFieldKey,
          keyboardType: TextInputType.number,
          hintText: '例如：1200',
          helperText: '填写当前竞标报价。',
        ),
        _InputField(
          controller: proposalSummaryController,
          label: '方案说明',
          fieldKey: proposalSummaryFieldKey,
          maxLines: 3,
          hintText: '例如：先完成展台结构、照明和基础安装',
          helperText: '简要说明当前竞标方案的重点。',
        ),
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '第三步 提交继续',
      summary: '当前页只保留现有提交动作和受控结果反馈，不扩成独立竞标工作台，也不提前放开后续链路。',
      children: <Widget>[
        const _DetailLine(label: '提交后承接', value: '成功后仅返回最小 bidId 结果。'),
        const _DetailLine(
          label: '当前边界',
          value: '本轮不扩比较台、结果披露、我的竞标、订单承接与后续履约链路。',
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: (submitting || guardLoading || accessGuard != null)
              ? null
              : onApplyDemoBidResult,
          child: const Text('使用演示竞标继续讲解'),
        ),
      ],
    ),
  ];
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
