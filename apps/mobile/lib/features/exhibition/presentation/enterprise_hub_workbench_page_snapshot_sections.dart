part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageSnapshotSections
    on _EnterpriseApplicationPageState {
  Widget _buildPublishedChangeSnapshotSection(
    EnterpriseHubPublishedChangeWorkbenchData? data,
  ) {
    final result = _publishedChangeWorkbenchResult;
    if (data == null) {
      return EnterpriseSectionCard(
        key: const ValueKey<String>(
          'enterprise-published-change-snapshot-section',
        ),
        title: '已发布展示变更',
        subtitle: '当前页只消费 app-facing published-change surface。',
        child: Text(
          enterprisePublishedChangeVisibleMessage(
            state: result?.state,
            errorCode: result?.errorCode,
            fallbackMessage: result?.message ?? '当前无法读取已发布展示变更快照。',
          ),
        ),
      );
    }
    final changeRequest = data.currentChangeRequest;
    final rejectionReason = _normalizedText(changeRequest?.rejectionReason);
    final expanded = _publishedChangeSnapshotExpanded;
    return EnterpriseSectionCard(
      key: const ValueKey<String>(
        'enterprise-published-change-snapshot-section',
      ),
      title: '已发布展示变更',
      subtitle: '当前页维护待发布的变更稿；线上公开展示仍以当前线上版本为准。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '当前状态：${enterprisePublishedChangeStatusLabel(changeRequest?.changeStatus)}',
          ),
          const SizedBox(height: 6),
          Text(
            '线上展示仍以 liveSnapshot 为准；保存修改不会立即改线上。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey<String>(
                'enterprise-published-change-snapshot-toggle',
              ),
              onPressed: () => _updateWorkbenchState(() {
                _publishedChangeSnapshotExpanded =
                    !_publishedChangeSnapshotExpanded;
              }),
              icon: Icon(
                expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
              label: Text(expanded ? '收起详情' : '展开详情'),
            ),
          ),
          if (expanded) ...<Widget>[
            _SectionNotice(
              key: const ValueKey<String>(
                'enterprise-published-change-current-snapshot',
              ),
              tone: _publishedChangeSnapshotTone(changeRequest?.changeStatus),
              title: '当前变更稿',
              lines: <String>[
                '当前状态：${enterprisePublishedChangeStatusLabel(changeRequest?.changeStatus)}',
                if (changeRequest?.submittedAt != null)
                  '提交时间：${_displayDateLabel(changeRequest?.submittedAt)}',
                if (changeRequest?.reviewedAt != null)
                  '审核时间：${_displayDateLabel(changeRequest?.reviewedAt)}',
                if (rejectionReason != null) '退回/驳回原因：$rejectionReason',
                enterprisePublishedChangeStatusExplanation(
                  changeRequest?.changeStatus,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionNotice(
              key: const ValueKey<String>(
                'enterprise-published-change-live-snapshot',
              ),
              tone: _SectionNoticeTone.neutral,
              title: '当前线上版本',
              lines: <String>[
                '企业状态：${enterprisePublishedEnterpriseStatusLabel(data.liveSnapshot.enterpriseStatus)}',
                '展示状态：${enterprisePublishedDisplayStatusLabel(data.liveSnapshot.displayStatus)}',
                '发布时间：${_displayDateLabel(data.liveSnapshot.publishedAt)}',
                '当前线上展示仍以 liveSnapshot 为准，保存修改不会立即改线上。',
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPublishedChangeSubmitSection(
    EnterpriseHubPublishedChangeWorkbenchData? data,
    EnterpriseHubPublishedChangeStatusData? status,
  ) {
    final result = _publishedChangeWorkbenchResult;
    final statusResult = _publishedChangeStatusResult;
    final readiness = data?.changeReadiness;
    final disposition = enterprisePublishedChangeDisposition(
      currentChangeRequest: data?.currentChangeRequest,
      status: status,
      readiness: readiness,
    );
    final enterpriseId = _currentEnterpriseId;
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-workbench-submit-section'),
      title: '提交变更',
      subtitle: disposition.subtitle,
      actions: <Widget>[
        if (enterpriseId != null && disposition.showViewStatusAction)
          (disposition.viewStatusPrimary
              ? FilledButton(
                  key: const ValueKey<String>(
                    'enterprise-workbench-view-change-status',
                  ),
                  onPressed: _submittingAction
                      ? null
                      : () => Navigator.of(context).pushNamed(
                          ExhibitionRoutes.enterprisePublishedChangeStatusWithEnterpriseId(
                            enterpriseId,
                            boardType: _boardType.contractName,
                          ),
                        ),
                  child: const Text('查看变更状态'),
                )
              : FilledButton.tonal(
                  key: const ValueKey<String>(
                    'enterprise-workbench-view-change-status',
                  ),
                  onPressed: _submittingAction
                      ? null
                      : () => Navigator.of(context).pushNamed(
                          ExhibitionRoutes.enterprisePublishedChangeStatusWithEnterpriseId(
                            enterpriseId,
                            boardType: _boardType.contractName,
                          ),
                        ),
                  child: const Text('查看变更状态'),
                )),
        if (disposition.showSubmitAction)
          FilledButton(
            key: const ValueKey<String>('enterprise-workbench-submit-change'),
            onPressed:
                disposition.showSubmitAction &&
                    (readiness?.submitReady ?? false) &&
                    !_submittingAction
                ? _submitPrimaryAction
                : null,
            child: const Text('提交变更'),
          ),
      ],
      child: result == null || _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          : result.state == AppPageState.content
          ? _buildSubmitStatusPanel(
              highlighted: disposition.panelHighlighted,
              title: disposition.panelTitle,
              body: disposition.panelBody,
              blockers: disposition.showBlockers
                  ? readiness?.blockers ?? const <String>[]
                  : const <String>[],
            )
          : Text(
              enterprisePublishedChangeVisibleMessage(
                state: statusResult?.state ?? result.state,
                errorCode: statusResult?.errorCode ?? result.errorCode,
                fallbackMessage:
                    statusResult?.message ??
                    result.message ??
                    '当前无法读取已发布展示变更状态。',
              ),
            ),
    );
  }

  Widget _buildPublishedLivePreviewSection(
    EnterpriseHubLoadResult<EnterpriseHubDetailData>? liveResult,
    AppShellContextData shellContext,
  ) {
    final liveData = liveResult?.data;
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-published-live-preview-section'),
      title: '线上公开展示',
      subtitle: '当前首屏只展示线上公开版本；图片与案例应与展览楼公开详情保持一致。',
      child: liveResult == null
          ? const Text('当前正在读取线上公开展示。')
          : liveData != null && liveResult.state == AppPageState.content
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                EnterpriseDetailRelayoutSurface(
                  data: liveData,
                  boardType: liveData.header.primaryBoardType,
                  shellContext: shellContext,
                  onOpenTargetEnterpriseInfo: () {},
                ),
                const SizedBox(height: 12),
                Text(
                  '当前线上公开展示只消费 live / approved 真值；待发布修改请到下面的“当前变更稿预览”里单独核对。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          : Text(
              enterprisePublishedChangeVisibleMessage(
                state: liveResult.state,
                errorCode: liveResult.errorCode,
                fallbackMessage:
                    liveResult.message ?? '当前无法读取线上公开展示。',
              ),
            ),
    );
  }

  Widget _buildPublishedChangePreviewSection(
    EnterpriseHubPublishedChangeWorkbenchData? data,
    AppShellContextData shellContext,
  ) {
    final previewData = data == null
        ? null
        : enterpriseHubBuildPublishedChangePreviewDetailData(
            data: data,
            certification: _currentCertification,
          );
    final expanded = _publishedChangePreviewExpanded;
    return EnterpriseSectionCard(
      key: const ValueKey<String>(
        'enterprise-published-change-preview-section',
      ),
      title: '当前变更稿预览',
      subtitle: '当前变更稿只用于核对待发布内容，不代表线上公开展示。',
      child: previewData == null
          ? const Text(
              '当前变更稿还不足以拼出最小预览，请先补齐基础信息。',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '默认收起当前变更稿预览，避免占据过多工作台空间；只有需要核对待发布效果时再展开。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const ValueKey<String>(
                      'enterprise-published-change-preview-toggle',
                    ),
                    onPressed: () => _updateWorkbenchState(() {
                      _publishedChangePreviewExpanded =
                          !_publishedChangePreviewExpanded;
                    }),
                    icon: Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                    label: Text(expanded ? '收起变更稿' : '展开变更稿'),
                  ),
                ),
                if (expanded) ...<Widget>[
                  EnterpriseDetailRelayoutSurface(
                    data: previewData,
                    boardType: previewData.header.primaryBoardType,
                    shellContext: shellContext,
                    onOpenTargetEnterpriseInfo: () {},
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '当前变更稿预览优先使用已解析到的 Logo、画册与案例封面图片；只有提交并完成审核/应用后才会替换线上公开展示。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
    );
  }
}
