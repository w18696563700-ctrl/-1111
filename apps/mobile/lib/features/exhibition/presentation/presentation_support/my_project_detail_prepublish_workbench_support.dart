part of '../exhibition_trade_pages.dart';

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
    return _ActionCard(
      title: '发布前待办',
      summary: '诚意金、报价依据资料和发布确认合并在这里处理。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _PrepublishTodoRow(
          icon: Icons.verified_user_outlined,
          title: '项目真实性诚意金',
          body: sincerity == null
              ? '当前状态以云端费用回读为准。'
              : '${sincerity!.amountLabel} · ${sincerity!.statusLabel}',
          statusLabel: pricingLoading
              ? '读取中'
              : sincerity?.satisfied == true
              ? '已满足'
              : '待处理',
          emphasized: sincerity?.satisfied == true,
          action: sincerity?.satisfied == true
              ? OutlinedButton(
                  onPressed: pricingLoading ? null : onRefreshSincerity,
                  child: const Text('刷新状态'),
                )
              : FilledButton(
                  onPressed: continuingSincerity || pricingLoading
                      ? null
                      : onContinueSincerity,
                  child: Text(continuingSincerity ? '处理中...' : '继续处理诚意金'),
                ),
        ),
        const SizedBox(height: 10),
        _PrepublishTodoRow(
          icon: Icons.attach_file_rounded,
          title: '报价依据资料',
          body: quoteBasis.unavailable
              ? '当前资料列表暂不可用，请刷新后再试。'
              : '效果图为当前发布确认前置项，五类资料建议继续补齐。',
          statusLabel: quoteBasis.summaryLabel,
          emphasized: quoteBasis.hasRequiredEffectImage,
          action: OutlinedButton(
            onPressed: quoteBasis.loading ? null : onAddAttachments,
            child: Text(quoteBasis.hasRequiredEffectImage ? '继续补充' : '添加资料'),
          ),
        ),
        const SizedBox(height: 10),
        _PrepublishTodoRow(
          icon: Icons.fact_check_outlined,
          title: '发布确认',
          body: bottomPlan.helper,
          statusLabel: canSubmit ? '可提交' : '未满足',
          emphasized: canSubmit,
          action: FilledButton(
            onPressed: bottomPlan.enabled && canSubmit ? onPublish : null,
            child: Text(
              submittingLifecycleAction == _MyProjectLifecycleActionKind.publish
                  ? '提交中...'
                  : '提交发布',
            ),
          ),
        ),
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
              submittingFeedbackChoice: submittingFeedbackChoice,
              onFeedbackChoice: onFeedbackChoice,
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
        if (current?.freezeFeedback != null) ...<Widget>[
          const SizedBox(height: 10),
          _SincerityFreezeFeedbackStrip(
            summary: current!.freezeFeedback!,
            submittingChoice: submittingFeedbackChoice,
            onChoice: onFeedbackChoice,
          ),
        ],
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

class _PrepublishTodoRow extends StatelessWidget {
  const _PrepublishTodoRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.statusLabel,
    required this.action,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String statusLabel;
  final Widget action;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              color: emphasized ? colorScheme.primary : colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _StatusPill(
                        label: statusLabel,
                        tone: emphasized
                            ? _ActionCardTone.emphasis
                            : _ActionCardTone.muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.42,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              ),
            ),
          ],
        ),
      ),
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
