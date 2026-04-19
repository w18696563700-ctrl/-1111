part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageSubmitSections
    on _EnterpriseApplicationPageState {
  Widget _buildLoadState(
    EnterpriseHubLoadResult<EnterpriseHubWorkbenchData> result,
    EnterpriseHubWorkbenchReadiness readiness,
  ) {
    if (result.state == AppPageState.content) {
      final data = result.data;
      if (data?.latestApplication == null) {
        return _buildSubmitStatusPanel(
          highlighted: false,
          title: readiness.submitReady ? '当前资料已满足提交条件' : '当前暂不能提交',
          body: readiness.submitReady
              ? '当前还没有申请记录，继续提交时会自动沿当前资料进入申请链。'
              : '当前还没有申请记录；请先补齐工作台资料。未完成项会在下方明确显示。',
          blockers: readiness.blockers,
        );
      }
      final latestApplication = data!.latestApplication!;
      final disposition = enterpriseWorkbenchSubmitDisposition(
        latestApplication: latestApplication,
        readiness: readiness,
      );
      if (disposition.isPostSubmit) {
        return _buildSubmitStatusPanel(
          highlighted: disposition.panelHighlighted,
          title: disposition.panelTitle!,
          body: disposition.panelBody!,
          blockers: disposition.showBlockers
              ? readiness.blockers
              : const <String>[],
        );
      }
      final statusLabel = enterpriseWorkbenchApplicationStatusLabel(
        latestApplication.applicationStatus,
      );
      final reviewNote = latestApplication.reviewNote?.trim();
      final rejectionReason = latestApplication.rejectionReason?.trim();
      final body = reviewNote != null && reviewNote.isNotEmpty
          ? '审核说明：$reviewNote'
          : rejectionReason != null && rejectionReason.isNotEmpty
          ? '驳回原因：$rejectionReason'
          : '当前申请状态：$statusLabel';
      return _buildSubmitStatusPanel(
        highlighted: readiness.submitReady,
        title: readiness.submitReady ? '当前资料已满足提交条件' : '当前暂不能提交',
        body: body,
        blockers: readiness.blockers,
      );
    }
    return _buildSubmitStatusPanel(
      highlighted: false,
      title: '当前暂不能提交',
      body: _localizedWorkbenchMessage(result.message ?? '当前无法读取企业展示工作台。'),
      blockers: readiness.blockers,
    );
  }

  Widget _buildSubmitStatusPanel({
    required bool highlighted,
    required String title,
    required String body,
    required List<String> blockers,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final panelColor = highlighted
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = highlighted
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                highlighted
                    ? Icons.verified_rounded
                    : Icons.pending_actions_rounded,
                color: textColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (blockers.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            '还差这些：',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...blockers.map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $item'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRequiredHint(List<String> missingFields) {
    if (missingFields.isEmpty) {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '当前页可编辑字段还差：${missingFields.join('、')}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
        ),
      );
  }
}
