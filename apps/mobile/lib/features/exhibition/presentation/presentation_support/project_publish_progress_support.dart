part of '../exhibition_trade_pages.dart';

enum _ProjectPublishProgressStep {
  basic,
  quoteBasis,
  sincerity,
  confirmation,
  published,
}

final class _ProjectAuthenticitySinceritySnapshot {
  const _ProjectAuthenticitySinceritySnapshot({
    required this.required,
    required this.status,
    required this.amount,
    required this.currency,
    required this.orderId,
    required this.channelCandidates,
    required this.updatedAt,
    required this.policyNotice,
    required this.freezeFeedback,
  });

  final bool required;
  final String? status;
  final String? amount;
  final String? currency;
  final String? orderId;
  final List<String> channelCandidates;
  final String? updatedAt;
  final String? policyNotice;
  final _ProjectAuthenticitySincerityFreezeFeedbackSummary? freezeFeedback;

  bool get satisfied {
    return switch (status) {
      'paid' ||
      'frozen' ||
      'succeeded' ||
      'satisfied' ||
      'internal_test_no_freeze_required' ||
      'internal_test_no_freeze_allowed' ||
      'not_required' => true,
      _ => false,
    };
  }

  bool get pendingPayment {
    return switch (status) {
      'pending_payment' ||
      'pending' ||
      'pending_user_confirm' ||
      'processing' => true,
      _ => false,
    };
  }

  bool get canContinuePayment => orderId != null && !satisfied;

  String get amountLabel {
    final raw = amount;
    if (raw == null) {
      return '200 元';
    }
    final parsed = num.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final normalized = parsed
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$normalized 元';
  }

  String get statusLabel {
    return switch (status) {
      'not_required' => '无需处理',
      'pending_payment' => '待支付',
      'pending' => '待处理',
      'pending_user_confirm' => '等待确认',
      'internal_test_no_freeze_required' ||
      'internal_test_no_freeze_allowed' => '内测暂不冻结',
      'processing' => '处理中',
      'paid' || 'frozen' || 'succeeded' || 'satisfied' => '已完成',
      'refund_pending' => '退款中',
      'refunded' => '已退回',
      'failed' => '失败',
      'cancelled' => '已取消',
      'expired' => '已过期',
      null => '待创建',
      _ => status!,
    };
  }

  String get summary {
    if (status == 'refunded') {
      return '当前项目真实性诚意金已退回；如需再次正式发布，需要重新完成当前项目诚意金。';
    }
    if (status == 'refund_pending') {
      return '当前项目真实性诚意金正在退款中；退款进度以平台记录为准。';
    }
    if (satisfied) {
      if (status == 'internal_test_no_freeze_required' ||
          status == 'internal_test_no_freeze_allowed') {
        return '内测期间暂不冻结真实资金，平台已保留当前流程记录，可继续提交发布。';
      }
      return '当前项目的项目真实性诚意金已完成，可以继续确认发布。';
    }
    if (canContinuePayment) {
      return '当前项目已有一笔进行中的 $amountLabel 项目真实性诚意金订单，可继续支付或刷新状态。';
    }
    if (pendingPayment) {
      return '当前项目真实性诚意金处于$statusLabel，但暂未取得可继续支付的订单编号。';
    }
    return '当前项目还需要完成 $amountLabel 项目真实性诚意金后，才能正式发布。';
  }
}

final class _ProjectAuthenticitySincerityFreezeFeedbackSummary {
  const _ProjectAuthenticitySincerityFreezeFeedbackSummary({
    required this.supportFreezeCount,
    required this.opposeFreezeCount,
    required this.myChoice,
    required this.updatedAt,
  });

  final int supportFreezeCount;
  final int opposeFreezeCount;
  final String? myChoice;
  final String? updatedAt;
}

final class _ProjectPublishProgressNode {
  const _ProjectPublishProgressNode({
    required this.step,
    required this.label,
    required this.caption,
  });

  final _ProjectPublishProgressStep step;
  final String label;
  final String caption;
}

const List<_ProjectPublishProgressNode> _projectPublishProgressNodes =
    <_ProjectPublishProgressNode>[
      _ProjectPublishProgressNode(
        step: _ProjectPublishProgressStep.basic,
        label: '基础信息',
        caption: '填写项目基本资料',
      ),
      _ProjectPublishProgressNode(
        step: _ProjectPublishProgressStep.quoteBasis,
        label: '报价依据资料',
        caption: '补齐五类资料',
      ),
      _ProjectPublishProgressNode(
        step: _ProjectPublishProgressStep.sincerity,
        label: '诚意金',
        caption: '当前项目 200 元',
      ),
      _ProjectPublishProgressNode(
        step: _ProjectPublishProgressStep.confirmation,
        label: '确认发布',
        caption: '检查无误后发布',
      ),
      _ProjectPublishProgressNode(
        step: _ProjectPublishProgressStep.published,
        label: '已发布',
        caption: '进入竞标中',
      ),
    ];

List<_ProjectPublishProgressNode> _projectPublishProgressNodesFor({
  required bool useDraftLandingCopy,
}) {
  if (useDraftLandingCopy) {
    return _projectPublishProgressNodes;
  }
  return _projectPublishProgressNodes;
}

class _ProjectPublishProgressCard extends StatelessWidget {
  const _ProjectPublishProgressCard({
    required this.currentStep,
    this.sincerity,
    this.basicInfoOnlyNote = false,
    this.useDraftLandingCopy = false,
    this.compact = false,
    this.showStepNotice = true,
  });

  final _ProjectPublishProgressStep currentStep;
  final _ProjectAuthenticitySinceritySnapshot? sincerity;
  final bool basicInfoOnlyNote;
  final bool useDraftLandingCopy;
  final bool compact;
  final bool showStepNotice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nodes = _projectPublishProgressNodesFor(
      useDraftLandingCopy: useDraftLandingCopy,
    );
    final currentIndex = nodes.indexWhere(
      (_ProjectPublishProgressNode item) => item.step == currentStep,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: compact ? 0.03 : 0.04),
            blurRadius: compact ? 12 : 18,
            offset: Offset(0, compact ? 5 : 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '发布进度',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (basicInfoOnlyNote)
                  _StatusPill(label: '基础信息', tone: _ActionCardTone.emphasis),
              ],
            ),
            SizedBox(height: compact ? 10 : 16),
            _ProjectPublishStepper(
              nodes: nodes,
              currentIndex: math.max(currentIndex, 0),
              compact: compact,
            ),
            if (showStepNotice) ...<Widget>[
              SizedBox(height: compact ? 10 : 16),
              _ProjectPublishStepNotice(
                title: _projectPublishProgressTitle(currentStep),
                message: _projectPublishProgressSummary(
                  currentStep,
                  useDraftLandingCopy: useDraftLandingCopy,
                ),
              ),
            ],
            if (sincerity != null) ...<Widget>[
              const SizedBox(height: 12),
              _DetailLine(
                label: '项目真实性诚意金',
                value: '${sincerity!.amountLabel} · ${sincerity!.statusLabel}',
                highlight: sincerity!.satisfied,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectPublishStepper extends StatelessWidget {
  const _ProjectPublishStepper({
    required this.nodes,
    required this.currentIndex,
    this.compact = false,
  });

  final List<_ProjectPublishProgressNode> nodes;
  final int currentIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final nodeWidth = compact ? 44.0 : 50.0;
        final totalNodeWidth = nodeWidth * nodes.length;
        final lineWidth = nodes.length <= 1
            ? 0.0
            : math.max(
                8.0,
                (constraints.maxWidth - totalNodeWidth) / (nodes.length - 1),
              );
        return Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (var index = 0; index < nodes.length; index++) ...<Widget>[
                  SizedBox(
                    width: nodeWidth,
                    child: _ProjectPublishStepperNode(
                      node: nodes[index],
                      index: index,
                      active: index == currentIndex,
                      completed: index < currentIndex,
                      compact: compact,
                    ),
                  ),
                  if (index < nodes.length - 1)
                    Padding(
                      padding: EdgeInsets.only(top: compact ? 12 : 14),
                      child: SizedBox(
                        width: lineWidth,
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: index < currentIndex
                              ? colorScheme.primary.withValues(alpha: 0.55)
                              : colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProjectPublishStepperNode extends StatelessWidget {
  const _ProjectPublishStepperNode({
    required this.node,
    required this.index,
    required this.active,
    required this.completed,
    this.compact = false,
  });

  final _ProjectPublishProgressNode node;
  final int index;
  final bool active;
  final bool completed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = active
        ? colorScheme.onPrimary
        : completed
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final background = active
        ? colorScheme.primary
        : completed
        ? colorScheme.primaryContainer.withValues(alpha: 0.7)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: compact ? 24 : 28,
          height: compact ? 24 : 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(
              color: active || completed
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: completed
              ? Icon(
                  Icons.check_rounded,
                  size: compact ? 14 : 16,
                  color: foreground,
                )
              : Text(
                  '${index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          node.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: active ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProjectPublishStepNotice extends StatelessWidget {
  const _ProjectPublishStepNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.assignment_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _projectPublishProgressTitle(_ProjectPublishProgressStep step) {
  return switch (step) {
    _ProjectPublishProgressStep.basic => '正在填写项目基础信息',
    _ProjectPublishProgressStep.quoteBasis => '正在补齐报价依据资料',
    _ProjectPublishProgressStep.sincerity => '正在处理项目真实性诚意金',
    _ProjectPublishProgressStep.confirmation => '正在确认正式发布',
    _ProjectPublishProgressStep.published => '项目已发布',
  };
}

// Retained for non-workbench sincerity surfaces; the current prepublish
// workbench uses a denser folded rule panel.
// ignore: unused_element
class _ProjectSincerityStatusCard extends StatelessWidget {
  const _ProjectSincerityStatusCard({
    required this.snapshot,
    required this.loading,
    required this.continuing,
    required this.onRefresh,
    required this.onContinuePayment,
    required this.submittingFeedbackChoice,
    required this.onFeedbackChoice,
  });

  final _ProjectAuthenticitySinceritySnapshot? snapshot;
  final bool loading;
  final bool continuing;
  final VoidCallback? onRefresh;
  final VoidCallback? onContinuePayment;
  final String? submittingFeedbackChoice;
  final ValueChanged<String>? onFeedbackChoice;

  @override
  Widget build(BuildContext context) {
    final current = snapshot;
    return _ActionCard(
      title: '项目真实性诚意金',
      summary: '这笔 200 元只属于当前项目；支付是否完成以平台记录为准。',
      children: <Widget>[
        if (loading)
          const _DetailLine(label: '当前状态', value: '正在读取云端费用状态...')
        else if (current == null)
          const _DetailLine(label: '当前状态', value: '暂未读取到诚意金状态。')
        else ...<Widget>[
          _DetailLine(
            label: '当前状态',
            value: current.statusLabel,
            highlight: current.satisfied,
          ),
          _DetailLine(label: '金额归属', value: '当前项目 · ${current.amountLabel}'),
          if (current.orderId != null)
            _DetailLine(label: '订单状态', value: current.summary),
          if (current.orderId == null && !current.satisfied)
            _DetailLine(label: '下一步', value: current.summary),
        ],
        const SizedBox(height: 10),
        _StateMessage(
          title: '内测说明',
          body:
              current?.policyNotice ??
              '内测期间暂不需要真实支付；页面仍按平台返回状态走完整流程，不在本地改写支付结果。',
        ),
        if (current?.freezeFeedback != null) ...<Widget>[
          const SizedBox(height: 10),
          _SincerityFreezeFeedbackStrip(
            summary: current!.freezeFeedback!,
            submittingChoice: submittingFeedbackChoice,
            onChoice: onFeedbackChoice,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (current?.canContinuePayment == true)
              FilledButton.icon(
                onPressed: continuing ? null : onContinuePayment,
                icon: continuing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payments_outlined),
                label: Text(continuing ? '正在拉起...' : '继续支付诚意金'),
              ),
            OutlinedButton.icon(
              onPressed: loading ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('刷新状态'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 4),
          title: Text(
            '查看诚意金规则说明',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          children: <Widget>[
            Text(
              '这 200 元为当前项目的项目真实性诚意金，不是押金、罚款或平台服务费。项目成交成立或合规正式撤回后，将按云端退款状态进入原路退回流程；退款中和已退回状态均以平台记录为准，不承诺即时到账。若存在虚假发布、恶意发布或长期不处理结果，平台可按规则处理。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SincerityFreezeFeedbackStrip extends StatelessWidget {
  const _SincerityFreezeFeedbackStrip({
    required this.summary,
    required this.submittingChoice,
    required this.onChoice,
  });

  final _ProjectAuthenticitySincerityFreezeFeedbackSummary summary;
  final String? submittingChoice;
  final ValueChanged<String>? onChoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '绿色通道表态',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '上线初期暂不强制真实支付或冻结；请选择是否支持项目真实性诚意金机制。当前反馈只做统计，选择暂不支持仍可继续发布。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _SincerityFreezeFeedbackButton(
                  label: '支持项目真实性诚意金机制 ${summary.supportFreezeCount}',
                  choice: 'support_freeze',
                  selected: summary.myChoice == 'support_freeze',
                  submittingChoice: submittingChoice,
                  onChoice: onChoice,
                ),
                _SincerityFreezeFeedbackButton(
                  label: '暂不支持项目真实性诚意金机制 ${summary.opposeFreezeCount}',
                  choice: 'oppose_freeze',
                  selected: summary.myChoice == 'oppose_freeze',
                  submittingChoice: submittingChoice,
                  onChoice: onChoice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SincerityFreezeFeedbackButton extends StatelessWidget {
  const _SincerityFreezeFeedbackButton({
    required this.label,
    required this.choice,
    required this.selected,
    required this.submittingChoice,
    required this.onChoice,
  });

  final String label;
  final String choice;
  final bool selected;
  final String? submittingChoice;
  final ValueChanged<String>? onChoice;

  @override
  Widget build(BuildContext context) {
    final loading = submittingChoice == choice;
    final disabled = submittingChoice != null || onChoice == null;
    if (selected) {
      return FilledButton.tonalIcon(
        onPressed: disabled ? null : () => onChoice?.call(choice),
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_rounded),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: disabled ? null : () => onChoice?.call(choice),
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.how_to_vote_outlined),
      label: Text(label),
    );
  }
}

_ProjectPublishProgressStep _projectPublishProgressStepForState({
  required String? state,
  _ProjectAuthenticitySinceritySnapshot? sincerity,
}) {
  final normalized = _normalizeDynamicText(state);
  if (normalized == 'draft') {
    return _ProjectPublishProgressStep.basic;
  }
  if (normalized == 'submitted') {
    if (sincerity?.satisfied == true) {
      return _ProjectPublishProgressStep.confirmation;
    }
    if (sincerity?.status != null || sincerity?.orderId != null) {
      return _ProjectPublishProgressStep.sincerity;
    }
    return _ProjectPublishProgressStep.quoteBasis;
  }
  if (normalized == 'published' ||
      normalized == 'awarded' ||
      normalized == 'converted_to_order' ||
      normalized == 'active') {
    return _ProjectPublishProgressStep.published;
  }
  return _ProjectPublishProgressStep.basic;
}

String _projectPublishProgressSummary(
  _ProjectPublishProgressStep step, {
  bool useDraftLandingCopy = false,
}) {
  if (useDraftLandingCopy && step == _ProjectPublishProgressStep.basic) {
    return '保存后进入我的项目草稿箱，后续可继续补充报价依据资料并进入预发布核对。';
  }
  return switch (step) {
    _ProjectPublishProgressStep.basic => '当前正在整理项目基础信息，保存后进入预发布核对。',
    _ProjectPublishProgressStep.quoteBasis => '当前应补齐报价依据资料，再处理项目真实性诚意金。',
    _ProjectPublishProgressStep.sincerity => '当前需要完成项目真实性诚意金绿色通道表态。',
    _ProjectPublishProgressStep.confirmation => '当前可检查无误后正式发布。',
    _ProjectPublishProgressStep.published => '当前项目已经进入公域竞标展示。',
  };
}

_ProjectAuthenticitySinceritySnapshot?
_projectAuthenticitySinceritySnapshotFromPayload(Object? payload) {
  final payloadMap = _payloadMap(payload);
  if (payloadMap == null) {
    return null;
  }
  final publisherPricing = _payloadMap(payloadMap['publisherPricing']);
  final sincerity =
      _payloadMap(payloadMap['projectAuthenticitySincerity']) ??
      _payloadMap(payloadMap['inquiryDeposit']);
  final source = publisherPricing ?? sincerity ?? payloadMap;
  final status = _normalizeDynamicText(
    publisherPricing?['authenticitySincerityStatus'] ??
        publisherPricing?['publishGateStatus'] ??
        sincerity?['orderStatus'] ??
        sincerity?['depositStatus'] ??
        sincerity?['status'] ??
        payloadMap['orderStatus'] ??
        payloadMap['depositStatus'] ??
        payloadMap['status'],
  );
  final required = publisherPricing?['authenticitySincerityRequired'] is bool
      ? publisherPricing!['authenticitySincerityRequired'] as bool
      : status != 'not_required';
  final amount = _normalizeDynamicText(
    publisherPricing?['authenticitySincerityAmount'] ??
        sincerity?['amount'] ??
        source['amount'],
  );
  final orderId = _normalizeDynamicText(
    publisherPricing?['authenticitySincerityOrderId'] ??
        sincerity?['orderId'] ??
        sincerity?['depositOrderId'] ??
        payloadMap['orderId'] ??
        payloadMap['depositOrderId'],
  );
  final currency = _normalizeDynamicText(
    publisherPricing?['authenticitySincerityCurrency'] ??
        sincerity?['currency'] ??
        source['currency'],
  );
  final updatedAt = _normalizeDynamicText(
    sincerity?['updatedAt'] ?? source['updatedAt'] ?? payloadMap['updatedAt'],
  );
  final channels = _stringListFromPayload(
    publisherPricing?['authenticitySincerityChannelCandidates'] ??
        sincerity?['channelCandidates'] ??
        source['channelCandidates'],
  );
  final feedbackSummary =
      _projectAuthenticitySincerityFreezeFeedbackFromPayload(
        publisherPricing?['freezeFeedbackSummary'],
      );
  if (!required && status == null && orderId == null && amount == null) {
    return null;
  }
  return _ProjectAuthenticitySinceritySnapshot(
    required: required,
    status: status,
    amount: amount,
    currency: currency,
    orderId: orderId,
    channelCandidates: channels,
    updatedAt: updatedAt,
    policyNotice: _normalizeDynamicText(
      publisherPricing?['sincerityFreezePolicyNotice'],
    ),
    freezeFeedback: feedbackSummary,
  );
}

_ProjectAuthenticitySincerityFreezeFeedbackSummary?
_projectAuthenticitySincerityFreezeFeedbackFromPayload(Object? value) {
  final record = _payloadMap(value);
  if (record == null) {
    return null;
  }
  return _ProjectAuthenticitySincerityFreezeFeedbackSummary(
    supportFreezeCount: _normalizeDynamicInt(record['supportFreezeCount']) ?? 0,
    opposeFreezeCount: _normalizeDynamicInt(record['opposeFreezeCount']) ?? 0,
    myChoice: _normalizeDynamicText(record['myChoice']),
    updatedAt: _normalizeDynamicText(record['updatedAt']),
  );
}

int? _normalizeDynamicInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

List<String> _stringListFromPayload(Object? value) {
  if (value is! Iterable) {
    return const <String>[];
  }
  return value
      .map(_normalizeDynamicText)
      .whereType<String>()
      .toList(growable: false);
}
