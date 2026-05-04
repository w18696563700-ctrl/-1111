part of '../exhibition_trade_pages.dart';

extension _MyBidWorkspaceSupport on _MyProjectListPageState {
  Future<void> _loadMyBidList({bool forceRefresh = false}) async {
    if (_myBidLoading && !forceRefresh) {
      return;
    }

    _setMyBidLoading(true);
    final result = await ExhibitionConsumerLayer.instance.loadMyBidList(
      forceRefresh: forceRefresh,
    );
    if (!mounted) {
      return;
    }

    _finishMyBidLoad(result);
  }

  Widget _buildMyBidWorkspaceSection(BuildContext context) {
    final result = _myBidResult;
    final items = _myBidItemsFromPayload(result?.payload);

    return _ActionCard(
      title: '我的竞标',
      summary: '这里承接当前主体参与过的竞标，并直接给出下一步入口。',
      children: <Widget>[
        if (_myBidLoading)
          const LinearProgressIndicator(minHeight: 6)
        else if (result == null) ...<Widget>[
          const _StateMessage(
            title: '准备读取我的竞标',
            body: '切换到这里后，会读取当前主体参与过的竞标记录。',
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _loadMyBidList,
            child: const Text('读取我的竞标'),
          ),
        ] else if (result.state == AppPageState.empty)
          const _EmptyNotice(
            title: '当前还没有竞标记录',
            message: '你提交过竞标后，这里会自然沉淀成我的竞标记录。',
          )
        else if (result.state != AppPageState.content) ...<Widget>[
          _StateMessage(
            title: '当前竞标列表暂不可用',
            body: result.message ?? '当前还没有成功读取我的竞标列表。',
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => _loadMyBidList(forceRefresh: true),
            child: const Text('重新读取'),
          ),
        ] else
          ...items.map(
            (Map<String, Object?> item) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _EntityCard(
                title: _normalizeId(item['projectTitle'] as String?) ?? '未命名竞标',
                description:
                    _normalizeId(item['proposalSummaryPreview'] as String?) ??
                    '当前竞标已经提交，可继续查看后续进展。',
                statusLabel: _myBidOutcomeLabel(
                  item['outcomeState'] as String?,
                ),
                detailLines: <Widget>[
                  _DetailLine(
                    label: '项目编号',
                    value: _normalizeId(item['projectNo'] as String?) ?? '未提供',
                  ),
                  _DetailLine(
                    label: '当前状态',
                    value: _myBidOutcomeLabel(item['outcomeState'] as String?),
                    highlight: true,
                  ),
                  _DetailLine(
                    label: '报价金额',
                    value: _currencyText(item['quoteAmount']),
                    highlight: true,
                  ),
                  _DetailLine(
                    label: '提交时间',
                    value:
                        _normalizeId(item['submittedAt'] as String?) ?? '未提供',
                  ),
                ],
                actionLabel: _myBidPrimaryActionLabel(item),
                actionSummary: _myBidActionSummary(item),
                onPressed: () => _openRoute(_myBidPrimaryRoute(item)),
                secondaryActionLabel: _myBidSecondaryActionLabel(item),
                onSecondaryPressed: _myBidSecondaryRoute(item) == null
                    ? null
                    : () => _openRoute(_myBidSecondaryRoute(item)!),
              ),
            ),
          ),
      ],
    );
  }
}

List<Map<String, Object?>> _myBidItemsFromPayload(Object? payload) {
  if (payload is! Map) {
    return const <Map<String, Object?>>[];
  }

  final items = payload['items'];
  if (items is! List) {
    return const <Map<String, Object?>>[];
  }

  return items.whereType<Map<String, Object?>>().toList(growable: false);
}

String _myBidOutcomeLabel(String? outcomeState) {
  final normalized = _normalizeId(outcomeState);
  if (normalized == null) {
    return '已提交';
  }
  return _frontStageStateLabel(normalized);
}

String _myBidPrimaryActionLabel(Map<String, Object?> item) {
  final canOpenBidThread = item['canOpenBidThread'] == true;
  final canOpenBidResult = item['canOpenBidResult'] == true;
  if (canOpenBidThread) {
    return '沟通与投标';
  }
  if (canOpenBidResult) {
    return '查看竞标结果';
  }
  return '查看项目详情';
}

String? _myBidSecondaryActionLabel(Map<String, Object?> item) {
  final canOpenBidThread = item['canOpenBidThread'] == true;
  final canOpenBidResult = item['canOpenBidResult'] == true;
  if (canOpenBidThread && canOpenBidResult) {
    return '查看竞标结果';
  }
  return null;
}

String _myBidActionSummary(Map<String, Object?> item) {
  final canOpenBidThread = item['canOpenBidThread'] == true;
  final canOpenBidResult = item['canOpenBidResult'] == true;
  if (canOpenBidThread && canOpenBidResult) {
    return '沟通与投标 / 查看竞标结果';
  }
  if (canOpenBidThread) {
    return '沟通与投标';
  }
  if (canOpenBidResult) {
    return '查看竞标结果';
  }
  return '查看项目详情';
}

String _myBidPrimaryRoute(Map<String, Object?> item) {
  final bidId = _normalizeId(item['bidId'] as String?);
  final projectId = _normalizeId(item['projectId'] as String?);
  if (item['canOpenBidThread'] == true && projectId != null && bidId != null) {
    return ExhibitionRoutes.bidThreadWithIds(
      projectId: projectId,
      bidId: bidId,
    );
  }
  if (item['canOpenBidResult'] == true && projectId != null) {
    return ExhibitionRoutes.bidResultWithProjectId(projectId);
  }
  if (projectId != null) {
    return ExhibitionRoutes.projectDetailWithProjectId(projectId);
  }
  return ExhibitionRoutes.showcase;
}

String? _myBidSecondaryRoute(Map<String, Object?> item) {
  final projectId = _normalizeId(item['projectId'] as String?);
  if (item['canOpenBidThread'] == true &&
      item['canOpenBidResult'] == true &&
      projectId != null) {
    return ExhibitionRoutes.bidResultWithProjectId(projectId);
  }
  return null;
}
