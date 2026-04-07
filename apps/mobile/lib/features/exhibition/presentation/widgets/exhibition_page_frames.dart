part of '../exhibition_trade_pages.dart';

class _LoadPageFrame extends StatelessWidget {
  const _LoadPageFrame({
    required this.title,
    required this.summary,
    required this.loading,
    required this.result,
    required this.onRetry,
    this.controls = const <Widget>[],
    this.showConnectionInfo = false,
    this.showTechnicalDisclosure = false,
    this.showPageSummaryCard = true,
    this.showContentStateCard = true,
    this.showSourceNotice = true,
    this.showFallbackNotice = true,
    this.sourceLabel,
    this.sourceMessage,
    this.fallbackTitle,
    this.fallbackMessage,
    this.recoveryRouteOverride,
    this.recoveryButtonLabelOverride,
    this.resultSectionsBuilder,
  });

  final String title;
  final String summary;
  final bool loading;
  final ExhibitionLoadResult? result;
  final VoidCallback onRetry;
  final List<Widget> controls;
  final bool showConnectionInfo;
  final bool showTechnicalDisclosure;
  final bool showPageSummaryCard;
  final bool showContentStateCard;
  final bool showSourceNotice;
  final bool showFallbackNotice;
  final String? sourceLabel;
  final String? sourceMessage;
  final String? fallbackTitle;
  final String? fallbackMessage;
  final String? recoveryRouteOverride;
  final String? recoveryButtonLabelOverride;
  final List<Widget> Function(ExhibitionLoadResult result)?
  resultSectionsBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        if (showPageSummaryCard)
          _SummaryCard(
            title: title,
            summary: summary,
            eyebrow: '页面',
            showConnectionInfo: showConnectionInfo,
            highlights: <String>[loading ? '准备中' : '已更新'],
            footnote: '受控状态、重试和回退入口会保留在这一页。',
          ),
        if (showSourceNotice &&
            sourceLabel != null &&
            sourceMessage != null) ...<Widget>[
          if (showPageSummaryCard) const SizedBox(height: 16),
          _StageNoticeCard(
            title: sourceLabel!,
            message: sourceMessage!,
            tone: _ActionCardTone.muted,
          ),
        ],
        if (showFallbackNotice &&
            fallbackTitle != null &&
            fallbackMessage != null) ...<Widget>[
          if (showPageSummaryCard || showSourceNotice)
            const SizedBox(height: 16),
          _StageNoticeCard(
            title: fallbackTitle!,
            message: fallbackMessage!,
            tone: _ActionCardTone.emphasis,
          ),
        ],
        if (controls.isNotEmpty) ...<Widget>[
          if (showPageSummaryCard || showSourceNotice || showFallbackNotice)
            const SizedBox(height: 16),
          _ActionCard(
            title: '页面操作',
            summary: '需要时可刷新当前内容或返回上一层入口。',
            tone: _ActionCardTone.muted,
            children: controls,
          ),
        ],
        if (showPageSummaryCard ||
            showSourceNotice ||
            showFallbackNotice ||
            controls.isNotEmpty)
          const SizedBox(height: 16),
        if (loading)
          const _ContractLoadingCard()
        else if (result != null) ...<Widget>[
          if (result!.state != AppPageState.content || showContentStateCard)
            _LoadStateCard(
              result: result!,
              onRetry: onRetry,
              showTechnicalDisclosure: showTechnicalDisclosure,
              recoveryRouteOverride: recoveryRouteOverride,
              recoveryButtonLabelOverride: recoveryButtonLabelOverride,
            ),
          if (resultSectionsBuilder != null) ...resultSectionsBuilder!(result!),
        ],
      ],
    );
  }
}

class _SubmissionPageFrame extends StatelessWidget {
  const _SubmissionPageFrame({
    required this.title,
    required this.summary,
    required this.canonicalPath,
    required this.submitting,
    required this.lastResult,
    required this.onSubmitPressed,
    required this.body,
    this.submitButtonLabel = '提交',
    this.submitButtonKey,
    this.showSubmitButton = true,
    this.showConnectionInfo = false,
    this.showTechnicalDisclosure = false,
    this.showPageSummaryCard = true,
    this.showSourceNotice = true,
    this.showActionContainer = true,
    this.hideResultPanelOnSuccess = false,
    this.sourceLabel,
    this.sourceMessage,
    this.resultSectionsBuilder,
  });

  final String title;
  final String summary;
  final String canonicalPath;
  final bool submitting;
  final ExhibitionActionResult? lastResult;
  final VoidCallback onSubmitPressed;
  final List<Widget> body;
  final String submitButtonLabel;
  final Key? submitButtonKey;
  final bool showSubmitButton;
  final bool showConnectionInfo;
  final bool showTechnicalDisclosure;
  final bool showPageSummaryCard;
  final bool showSourceNotice;
  final bool showActionContainer;
  final bool hideResultPanelOnSuccess;
  final String? sourceLabel;
  final String? sourceMessage;
  final List<Widget> Function(ExhibitionActionResult result)?
  resultSectionsBuilder;

  @override
  Widget build(BuildContext context) {
    final actionContent = <Widget>[
      ...body,
      if (showSubmitButton) ...<Widget>[
        const SizedBox(height: 18),
        FilledButton(
          key: submitButtonKey,
          onPressed: submitting ? null : onSubmitPressed,
          child: Text(submitButtonLabel),
        ),
        const SizedBox(height: 16),
      ],
      if (submitting)
        const _SubmittingPanel()
      else if (lastResult != null) ...<Widget>[
        if (!(hideResultPanelOnSuccess && lastResult!.isSuccess)) ...<Widget>[
          const _SectionEyebrow(label: '当前结果'),
          const SizedBox(height: 12),
          _SubmissionResultPanel(
            result: lastResult!,
            showTechnicalDisclosure: showTechnicalDisclosure,
          ),
        ],
        if (resultSectionsBuilder != null)
          ...resultSectionsBuilder!(lastResult!),
      ] else if (showTechnicalDisclosure)
        _TechnicalDisclosure(method: 'POST', path: canonicalPath),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        if (showPageSummaryCard)
          _SummaryCard(
            title: title,
            summary: summary,
            eyebrow: '操作',
            showConnectionInfo: showConnectionInfo,
            highlights: <String>[submitting ? '提交中' : '可继续'],
            footnote: '提交结果与后续入口会留在当前页面。',
          ),
        if (showSourceNotice &&
            sourceLabel != null &&
            sourceMessage != null) ...<Widget>[
          if (showPageSummaryCard) const SizedBox(height: 16),
          _StageNoticeCard(
            title: sourceLabel!,
            message: sourceMessage!,
            tone: _ActionCardTone.muted,
          ),
        ],
        if (showActionContainer) ...<Widget>[
          if (showPageSummaryCard || showSourceNotice)
            const SizedBox(height: 16),
          _ActionCard(
            title: '填写内容',
            summary: '确认信息后即可提交。',
            children: <Widget>[
              Text(
                '完成当前信息后即可继续。',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              ...actionContent,
            ],
          ),
        ] else
          ...actionContent,
      ],
    );
  }
}

class _StageNoticeCard extends StatelessWidget {
  const _StageNoticeCard({
    required this.title,
    required this.message,
    this.tone = _ActionCardTone.standard,
  });

  final String title;
  final String message;
  final _ActionCardTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = switch (tone) {
      _ActionCardTone.standard => colorScheme.surface,
      _ActionCardTone.emphasis => colorScheme.surfaceContainerHigh,
      _ActionCardTone.muted => colorScheme.surfaceContainerLow,
    };
    final borderColor = switch (tone) {
      _ActionCardTone.standard => colorScheme.outlineVariant,
      _ActionCardTone.emphasis => colorScheme.primary.withValues(alpha: 0.18),
      _ActionCardTone.muted => colorScheme.outlineVariant,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
