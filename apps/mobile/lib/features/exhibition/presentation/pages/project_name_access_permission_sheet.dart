part of '../exhibition_trade_pages.dart';

class ProjectNameAccessPermissionSheet extends StatelessWidget {
  const ProjectNameAccessPermissionSheet({
    super.key,
    required this.projectMap,
    required this.requesting,
    required this.onRequest,
    required this.onOpenStatus,
    required this.onRefresh,
  });

  final Map<String, Object?> projectMap;
  final bool requesting;
  final Future<void> Function() onRequest;
  final VoidCallback onOpenStatus;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final status = _projectNameAccessStatus(projectMap);
    final canRequest = _projectCanRequestNameAccess(projectMap);
    final requestId = _projectNameAccessRequestId(projectMap);
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppVisualTokens.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: AppVisualTokens.shadowFloating(opacity: 0.1),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            14,
            24,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppVisualTokens.textTertiary.withValues(alpha: 0.55),
                    borderRadius: AppVisualTokens.radiusPillBorder,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '参与竞标申请',
                style: AppTextTokens.pageTitle.copyWith(
                  fontSize: 25,
                  height: 1.16,
                ),
              ),
              const SizedBox(height: 14),
              AppStatusBadge(
                label: _projectNameAccessStatusLabel(status),
                tone: AppStatusTone.warning,
              ),
              const SizedBox(height: 26),
              Text('当前说明', style: AppTextTokens.sectionTitle),
              const SizedBox(height: 10),
              Text(
                _projectNameAccessStatusBody(projectMap),
                style: AppTextTokens.bodyStrong.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final compact = constraints.maxWidth < 390;
                  final primaryButton = FilledButton.icon(
                    onPressed: canRequest && !requesting ? onRequest : null,
                    icon: Icon(
                      canRequest
                          ? Icons.hourglass_bottom_rounded
                          : Icons.check_circle_outline_rounded,
                    ),
                    label: Text(
                      requesting
                          ? '提交中...'
                          : _projectNameAccessActionLabel(projectMap),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        AppVisualTokens.primaryButtonHeight,
                      ),
                      backgroundColor: AppVisualTokens.brandGoldLight,
                      foregroundColor: AppVisualTokens.brandGoldDark,
                      disabledBackgroundColor: const Color(0xFFF4F0EC),
                      disabledForegroundColor: AppVisualTokens.textSecondary,
                      textStyle: AppTextTokens.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppVisualTokens.radiusPillBorder,
                      ),
                    ),
                  );
                  final primary = compact
                      ? SizedBox(width: double.infinity, child: primaryButton)
                      : primaryButton;
                  final actions = <Widget>[
                    primary,
                    if (requestId != null)
                      OutlinedButton.icon(
                        onPressed: onOpenStatus,
                        icon: const Icon(Icons.rule_rounded),
                        label: const Text('查看申请状态'),
                        style: _sheetSecondaryButtonStyle(),
                      ),
                    OutlinedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('刷新状态'),
                      style: _sheetSecondaryButtonStyle(),
                    ),
                  ];
                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: actions
                          .map(
                            (Widget action) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: action,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return Wrap(spacing: 12, runSpacing: 12, children: actions);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _sheetSecondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(0, AppVisualTokens.primaryButtonHeight),
      foregroundColor: AppVisualTokens.textPrimary,
      side: const BorderSide(color: AppVisualTokens.borderSoft),
      textStyle: AppTextTokens.buttonText,
      shape: RoundedRectangleBorder(
        borderRadius: AppVisualTokens.radiusPillBorder,
      ),
    );
  }
}

class _ProjectDetailHeadline extends StatelessWidget {
  const _ProjectDetailHeadline({
    required this.headline,
    required this.accessControlled,
    required this.onTap,
  });

  final String headline;
  final bool accessControlled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );
    if (!accessControlled) {
      return Text(headline, style: textStyle);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(child: Text(headline, style: textStyle)),
              const SizedBox(width: 6),
              Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
