part of '../exhibition_trade_pages.dart';

const Color _prepublishReadyGreen = Color(0xFF2E7D32);

class _MyProjectPrepublishTodoCard extends StatelessWidget {
  const _MyProjectPrepublishTodoCard({
    required this.sincerity,
    required this.pricingLoading,
    required this.quoteBasis,
    required this.bottomPlan,
    required this.continuingSincerity,
    required this.onContinueSincerity,
    required this.onRefreshSincerity,
    required this.onAddAttachments,
    required this.onPublish,
    required this.onWithdraw,
    required this.onDiscard,
    required this.submittingLifecycleAction,
    required this.submittingFeedbackChoice,
    required this.onFeedbackChoice,
  });

  final _ProjectAuthenticitySinceritySnapshot? sincerity;
  final bool pricingLoading;
  final _QuoteBasisChecklistProgress quoteBasis;
  final _MyProjectBottomPublishCtaPlan bottomPlan;
  final bool continuingSincerity;
  final VoidCallback? onContinueSincerity;
  final VoidCallback? onRefreshSincerity;
  final VoidCallback? onAddAttachments;
  final VoidCallback? onPublish;
  final VoidCallback? onWithdraw;
  final VoidCallback? onDiscard;
  final _MyProjectLifecycleActionKind? submittingLifecycleAction;
  final String? submittingFeedbackChoice;
  final ValueChanged<String>? onFeedbackChoice;

  @override
  Widget build(BuildContext context) {
    final canSubmit = bottomPlan.kind == _MyProjectBottomPublishCtaKind.publish;
    final feedback = sincerity?.freezeFeedback;
    return _ActionCard(
      title: '发布前待办',
      summary: '先核对必传资料，再完成诚意金绿色通道表态并确认发布。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _PrepublishTodoList(
          children: <Widget>[
            _PrepublishTodoTile(
              icon: Icons.attach_file_rounded,
              title: '报价依据资料',
              body: quoteBasis.unavailable
                  ? '当前资料列表暂不可用，请刷新后再试。'
                  : '必传：效果图、尺寸图 / 施工图、材质图 / 材料样板；其余两类建议继续补齐。',
              statusLabel: quoteBasis.requiredSummaryLabel,
              emphasized: quoteBasis.allRequiredKindsPresent,
              accentColor: quoteBasis.allRequiredKindsPresent
                  ? _prepublishReadyGreen
                  : null,
              action: OutlinedButton(
                onPressed: quoteBasis.loading ? null : onAddAttachments,
                child: Text(
                  quoteBasis.allRequiredKindsPresent ? '继续补充' : '添加资料',
                ),
              ),
            ),
            _PrepublishTodoTile(
              icon: Icons.verified_user_outlined,
              title: '项目真实性绿色通道',
              body: _prepublishGreenChannelTodoBody(
                sincerity: sincerity,
                feedback: feedback,
              ),
              statusLabel: pricingLoading
                  ? '读取中'
                  : _sincerityGreenChannelChoiceCompleted(sincerity)
                  ? '已表态'
                  : '待表态',
              emphasized: _sincerityGreenChannelChoiceCompleted(sincerity),
              accentColor: _sincerityGreenChannelChoiceCompleted(sincerity)
                  ? _prepublishReadyGreen
                  : null,
              action: _PrepublishGreenChannelTodoActions(
                sincerity: sincerity,
                pricingLoading: pricingLoading,
                continuingSincerity: continuingSincerity,
                onContinueSincerity: onContinueSincerity,
                onRefreshSincerity: onRefreshSincerity,
                summary: feedback,
                submittingChoice: submittingFeedbackChoice,
                onChoice: onFeedbackChoice,
              ),
            ),
            _PrepublishTodoTile(
              icon: Icons.fact_check_outlined,
              title: '发布确认',
              body: bottomPlan.helper,
              statusLabel: canSubmit ? '可提交' : '未满足',
              emphasized: canSubmit,
              accentColor: canSubmit ? _prepublishReadyGreen : null,
              action: FilledButton(
                style: canSubmit
                    ? FilledButton.styleFrom(
                        backgroundColor: _prepublishReadyGreen,
                        foregroundColor: Colors.white,
                      )
                    : null,
                onPressed: bottomPlan.enabled && canSubmit ? onPublish : null,
                child: Text(
                  submittingLifecycleAction ==
                          _MyProjectLifecycleActionKind.publish
                      ? '提交中...'
                      : '确认并发布',
                ),
              ),
            ),
          ],
        ),
        if (feedback != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            '选择暂不支持仍可继续发布；当前反馈只做绿色通道统计。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 6),
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
            _SincerityRuleDetails(
              snapshot: sincerity,
              loading: pricingLoading,
              continuing: continuingSincerity,
              onRefresh: onRefreshSincerity,
              onContinuePayment: onContinueSincerity,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _PrepublishSecondaryActions(
          submittingLifecycleAction: submittingLifecycleAction,
          onWithdraw: onWithdraw,
          onDiscard: onDiscard,
        ),
      ],
    );
  }
}

class _SincerityRuleDetails extends StatelessWidget {
  const _SincerityRuleDetails({
    required this.snapshot,
    required this.loading,
    required this.continuing,
    required this.onRefresh,
    required this.onContinuePayment,
  });

  final _ProjectAuthenticitySinceritySnapshot? snapshot;
  final bool loading;
  final bool continuing;
  final VoidCallback? onRefresh;
  final VoidCallback? onContinuePayment;

  @override
  Widget build(BuildContext context) {
    final current = snapshot;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          _DetailLine(label: '当前说明', value: current.summary),
        ],
        const SizedBox(height: 8),
        Text(
          current?.policyNotice ?? '内测期间暂不需要真实支付；页面仍按平台返回状态走完整流程，不在本地改写支付结果。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
                label: Text(continuing ? '处理中...' : '继续处理诚意金'),
              ),
            OutlinedButton.icon(
              onPressed: loading ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('刷新状态'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '这 200 元为当前项目的项目真实性诚意金，不是押金、罚款或平台服务费。项目成交成立或合规正式撤回后，将按云端退款状态进入原路退回流程；退款中和已退回状态均以云端回读为准，不承诺即时到账。若存在虚假发布、恶意发布或长期不处理结果，平台可按规则处理。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _prepublishGreenChannelTodoBody({
  required _ProjectAuthenticitySinceritySnapshot? sincerity,
  required _ProjectAuthenticitySincerityFreezeFeedbackSummary? feedback,
}) {
  final statusLine = sincerity == null
      ? '当前状态以云端费用回读为准。'
      : '${sincerity.amountLabel} · ${sincerity.statusLabel}';
  if (feedback == null) {
    return statusLine;
  }
  final choiceLabel = switch (feedback.myChoice) {
    'support_freeze' => '已选择支持',
    'oppose_freeze' => '已选择暂不支持',
    _ => '待表态',
  };
  return '$statusLine\n$choiceLabel · 支持 ${feedback.supportFreezeCount} / 暂不支持 ${feedback.opposeFreezeCount}';
}

class _PrepublishTodoList extends StatelessWidget {
  const _PrepublishTodoList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 10),
          children[index],
        ],
      ],
    );
  }
}

class _PrepublishTodoTile extends StatelessWidget {
  const _PrepublishTodoTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.statusLabel,
    required this.action,
    this.emphasized = false,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final String statusLabel;
  final Widget action;
  final bool emphasized;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stateColor = emphasized
        ? (accentColor ?? _prepublishReadyGreen)
        : AppVisualTokens.brandGold;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 84),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: stateColor.withValues(alpha: emphasized ? 0.10 : 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: stateColor.withValues(alpha: emphasized ? 0.30 : 0.20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final compact = constraints.maxWidth < 360;
              final leading = DecoratedBox(
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, size: 18, color: stateColor),
                ),
              );
              final content = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TinyStatusPill(label: statusLabel, color: stateColor),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    maxLines: compact ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        leading,
                        const SizedBox(width: 10),
                        Expanded(child: content),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _PrepublishTodoActionWrap(child: action),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  leading,
                  const SizedBox(width: 12),
                  Expanded(child: content),
                  const SizedBox(width: 12),
                  _PrepublishTodoActionWrap(child: action),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PrepublishTodoActionWrap extends StatelessWidget {
  const _PrepublishTodoActionWrap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: child,
    );
  }
}

class _PrepublishGreenChannelTodoActions extends StatelessWidget {
  const _PrepublishGreenChannelTodoActions({
    required this.sincerity,
    required this.pricingLoading,
    required this.continuingSincerity,
    required this.onContinueSincerity,
    required this.onRefreshSincerity,
    required this.summary,
    required this.submittingChoice,
    required this.onChoice,
  });

  final _ProjectAuthenticitySinceritySnapshot? sincerity;
  final bool pricingLoading;
  final bool continuingSincerity;
  final VoidCallback? onContinueSincerity;
  final VoidCallback? onRefreshSincerity;
  final _ProjectAuthenticitySincerityFreezeFeedbackSummary? summary;
  final String? submittingChoice;
  final ValueChanged<String>? onChoice;

  @override
  Widget build(BuildContext context) {
    final feedback = summary;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: <Widget>[
        if (sincerity?.canContinuePayment == true)
          OutlinedButton(
            onPressed: continuingSincerity || pricingLoading
                ? null
                : onContinueSincerity,
            child: Text(continuingSincerity ? '处理中...' : '继续处理'),
          )
        else
          OutlinedButton(
            onPressed: pricingLoading ? null : onRefreshSincerity,
            child: const Text('刷新状态'),
          ),
        if (feedback != null)
          _PrepublishGreenChannelChoiceAction(
            summary: feedback,
            submittingChoice: submittingChoice,
            onChoice: onChoice,
          ),
      ],
    );
  }
}

class _PrepublishGreenChannelChoiceAction extends StatelessWidget {
  const _PrepublishGreenChannelChoiceAction({
    required this.summary,
    required this.submittingChoice,
    required this.onChoice,
  });

  final _ProjectAuthenticitySincerityFreezeFeedbackSummary summary;
  final String? submittingChoice;
  final ValueChanged<String>? onChoice;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onChoice == null
          ? null
          : () => _showPrepublishGreenChannelChoiceSheet(context),
      child: Text(
        summary.myChoice == null ? '去表态' : '改表态',
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _choiceButtons(BuildContext sheetContext) {
    void handleChoice(String choice) {
      Navigator.of(sheetContext).maybePop();
      onChoice?.call(choice);
    }

    return <Widget>[
      _SincerityFreezeFeedbackButton(
        label: '支持项目真实性诚意金机制 ${summary.supportFreezeCount}',
        choice: 'support_freeze',
        selected: summary.myChoice == 'support_freeze',
        submittingChoice: submittingChoice,
        onChoice: onChoice == null ? null : handleChoice,
      ),
      _SincerityFreezeFeedbackButton(
        label: '暂不支持项目真实性诚意金机制 ${summary.opposeFreezeCount}',
        choice: 'oppose_freeze',
        selected: summary.myChoice == 'oppose_freeze',
        submittingChoice: submittingChoice,
        onChoice: onChoice == null ? null : handleChoice,
      ),
    ];
  }

  void _showPrepublishGreenChannelChoiceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '绿色通道表态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ..._choiceButtons(context).map(
                  (Widget child) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrepublishSecondaryActions extends StatelessWidget {
  const _PrepublishSecondaryActions({
    required this.submittingLifecycleAction,
    required this.onWithdraw,
    required this.onDiscard,
  });

  final _MyProjectLifecycleActionKind? submittingLifecycleAction;
  final VoidCallback? onWithdraw;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        OutlinedButton(
          onPressed: submittingLifecycleAction == null ? onWithdraw : null,
          child: Text(
            submittingLifecycleAction == _MyProjectLifecycleActionKind.withdraw
                ? '处理中...'
                : '返回草稿继续编辑',
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error.withValues(alpha: 0.55)),
          ),
          onPressed: submittingLifecycleAction == null ? onDiscard : null,
          child: Text(
            submittingLifecycleAction ==
                    _MyProjectLifecycleActionKind.discardSubmitted
                ? '处理中...'
                : '作废并归档',
          ),
        ),
      ],
    );
  }
}
