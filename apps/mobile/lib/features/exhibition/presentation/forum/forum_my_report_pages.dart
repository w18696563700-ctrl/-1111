part of 'forum_pages.dart';

class ForumMyReportListPage extends StatefulWidget {
  const ForumMyReportListPage({super.key});

  @override
  State<ForumMyReportListPage> createState() => _ForumMyReportListPageState();
}

class _ForumMyReportListPageState extends State<ForumMyReportListPage> {
  ForumReadResult<ForumPagedCollectionView<ForumMyReportTicketItemView>>?
  _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ForumConsumerLayer.instance.loadMyReports();
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reports =
        _result?.data?.items ?? const <ForumMyReportTicketItemView>[];

    return ForumPageFrame(
      eyebrow: '我的论坛',
      title: '我的举报记录',
      summary: '只展示当前账号提交过的论坛举报记录与 BFF 回读状态，不提供后续治理操作。',
      scopeLabel: 'reports/mine',
      routeLabel: ExhibitionRoutes.forumMeReports,
      showRouteMeta: false,
      heroActions: <Widget>[
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(context).pushNamed(ExhibitionRoutes.forum),
          child: const Text('回论坛容器'),
        ),
      ],
      children: <Widget>[
        ForumReadStateCard(
          loading: _loading,
          state: _result?.state,
          emptyMessage: '当前还没有举报记录。',
          onRetry: _load,
          message: _result?.message,
          errorCode: _result?.errorCode,
        ),
        if (_result?.state == AppPageState.content)
          ForumSectionCard(
            eyebrow: '只读记录',
            title: '最近提交',
            summary: '这里按 BFF 返回结果展示本人举报记录，不在本地判断处理结论。',
            children: _reportCards(context, reports),
          ),
      ],
    );
  }

  List<Widget> _reportCards(
    BuildContext context,
    List<ForumMyReportTicketItemView> reports,
  ) {
    if (reports.isEmpty) {
      return const <Widget>[
        ForumPostPreviewCard(
          title: '当前没有举报记录',
          summary: '这里暂时还没有可查看的记录。',
          meta: '列表：0',
        ),
      ];
    }

    return reports
        .map(
          (ForumMyReportTicketItemView item) => _ForumActionableCard(
            title: _reportTicketTitle(item),
            summary: _reportTicketSummary(item),
            meta:
                '状态：${_reportStatusLabel(item.status)} | 提交：${_compactPublishedAt(item.submittedAt)}',
            footer: '编号：${item.reportTicketId}',
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  ExhibitionRoutes.forumMeReportDetailWithTicketId(
                    item.reportTicketId,
                  ),
                ),
                child: const Text('查看详情'),
              ),
            ],
          ),
        )
        .toList();
  }
}

class ForumMyReportDetailPage extends StatefulWidget {
  const ForumMyReportDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<ForumMyReportDetailPage> createState() =>
      _ForumMyReportDetailPageState();
}

class _ForumMyReportDetailPageState extends State<ForumMyReportDetailPage> {
  ForumReadResult<ForumMyReportTicketDetailView>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ForumConsumerLayer.instance.loadMyReportDetail(
      ticketId: widget.ticketId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = _result?.data;

    return ForumPageFrame(
      eyebrow: '我的论坛',
      title: '举报详情',
      summary: '只展示该举报记录的 BFF 回读内容，不提供处理动作。',
      scopeLabel: 'reports/mine/detail',
      routeLabel: ExhibitionRoutes.forumMeReportDetailWithTicketId(
        widget.ticketId,
      ),
      showRouteMeta: false,
      heroActions: <Widget>[
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(context).pushNamed(ExhibitionRoutes.forumMeReports),
          child: const Text('回举报记录'),
        ),
      ],
      children: <Widget>[
        ForumReadStateCard(
          loading: _loading,
          state: _result?.state,
          emptyMessage: '当前举报记录不存在或暂不可见。',
          onRetry: _load,
          message: _result?.message,
          errorCode: _result?.errorCode,
        ),
        if (_result?.state == AppPageState.content && detail != null)
          ForumSectionCard(
            eyebrow: '记录详情',
            title: _reportDetailTitle(detail),
            summary: _reportDetailSummary(detail),
            children: <Widget>[
              ForumPostPreviewCard(
                title: '目标快照',
                summary: _snapshotSummary(detail.targetSnapshot),
                meta:
                    '对象：${_reportTargetLabel(detail.targetType)} | 目标ID：${detail.targetId}',
                footer: '最近更新：${_compactPublishedAt(detail.updatedAt)}',
              ),
              ForumPostPreviewCard(
                title: '提交原因',
                summary: detail.reasonDetail ?? '未填写补充说明',
                meta: '原因：${_reportReasonLabel(detail.reasonCode)}',
                footer: '提交时间：${_compactPublishedAt(detail.submittedAt)}',
              ),
            ],
          ),
      ],
    );
  }
}

String _reportTicketTitle(ForumMyReportTicketItemView item) {
  final snapshotTitle = item.targetSnapshot.title;
  if (snapshotTitle != null && snapshotTitle.trim().isNotEmpty) {
    return snapshotTitle;
  }
  return '${_reportTargetLabel(item.targetType)}举报记录';
}

String _reportTicketSummary(ForumMyReportTicketItemView item) {
  final snapshot = item.targetSnapshot;
  final excerpt = snapshot.excerpt ?? snapshot.body;
  if (excerpt != null && excerpt.trim().isNotEmpty) {
    return excerpt;
  }
  return '原因：${_reportReasonLabel(item.reasonCode)}';
}

String _reportDetailTitle(ForumMyReportTicketDetailView detail) {
  final snapshotTitle = detail.targetSnapshot.title;
  if (snapshotTitle != null && snapshotTitle.trim().isNotEmpty) {
    return snapshotTitle;
  }
  return '${_reportTargetLabel(detail.targetType)}举报记录';
}

String _reportDetailSummary(ForumMyReportTicketDetailView detail) {
  return '状态：${_reportStatusLabel(detail.status)} | 编号：${detail.reportTicketId}';
}

String _snapshotSummary(ForumMyReportTargetSnapshotView snapshot) {
  final excerpt = snapshot.excerpt ?? snapshot.body;
  if (excerpt != null && excerpt.trim().isNotEmpty) {
    return excerpt;
  }
  final title = snapshot.title;
  if (title != null && title.trim().isNotEmpty) {
    return title;
  }
  return '当前快照未返回可展示摘要。';
}

String _reportTargetLabel(String targetType) {
  return switch (targetType.trim()) {
    'post' => '帖子',
    'comment' => '评论',
    _ => '对象回读：$targetType',
  };
}

String _reportReasonLabel(String reasonCode) {
  for (final option in _forumReportReasonOptions) {
    if (option.code == reasonCode.trim()) {
      return option.label;
    }
  }
  return '原因回读：$reasonCode';
}

String _reportStatusLabel(String status) {
  final value = status.trim();
  return switch (value) {
    'submitted' => '已提交',
    _ => '状态回读：$value',
  };
}
