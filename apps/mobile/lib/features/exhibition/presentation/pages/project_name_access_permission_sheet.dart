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
    final theme = Theme.of(context);
    final status = _projectNameAccessStatus(projectMap);
    final canRequest = _projectCanRequestNameAccess(projectMap);
    final requestId = _projectNameAccessRequestId(projectMap);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '项目名称查看权限',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _StatusPill(
                  label: _projectNameAccessStatusLabel(status),
                  tone: _ActionCardTone.muted,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StateMessage(
              title: '当前说明',
              body: _projectNameAccessStatusBody(projectMap),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton(
                  onPressed: canRequest && !requesting ? onRequest : null,
                  child: Text(
                    requesting
                        ? '提交中...'
                        : _projectNameAccessActionLabel(projectMap),
                  ),
                ),
                if (requestId != null)
                  OutlinedButton(
                    onPressed: onOpenStatus,
                    child: const Text('查看申请状态'),
                  ),
                OutlinedButton(onPressed: onRefresh, child: const Text('刷新状态')),
              ],
            ),
          ],
        ),
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
