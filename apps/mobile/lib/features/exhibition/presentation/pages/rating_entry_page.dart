part of '../exhibition_trade_pages.dart';

class RatingEntryPage extends StatefulWidget {
  const RatingEntryPage({
    super.key,
    this.orderId,
    this.projectId,
    this.rateeOrganizationId,
  });

  final String? orderId;
  final String? projectId;
  final String? rateeOrganizationId;

  @override
  State<RatingEntryPage> createState() => _RatingEntryPageState();
}

class _RatingEntryPageState extends State<RatingEntryPage> {
  final TextEditingController _remarkController = TextEditingController();
  final Set<String> _tags = <String>{'响应及时'};
  ExhibitionLoadResult? _entryResult;
  ExhibitionActionResult? _submitResult;
  bool _loading = false;
  bool _submitting = false;
  int _score = 5;

  @override
  void initState() {
    super.initState();
    if (!_hasRequiredAnchors) {
      _entryResult = ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: ExhibitionCanonicalPaths.projectCounterpartyRatingEntry,
        message:
            'orderId, projectId and rateeOrganizationId are required before counterparty rating entry',
      );
      return;
    }

    _load();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  bool get _hasRequiredAnchors =>
      _routeOrderId != null &&
      _routeProjectId != null &&
      _routeRateeOrganizationId != null;

  String? get _routeOrderId => _normalizeId(widget.orderId);

  String? get _routeProjectId => _normalizeId(widget.projectId);

  String? get _routeRateeOrganizationId =>
      _normalizeId(widget.rateeOrganizationId);

  Future<void> _load({bool forceRefresh = false}) async {
    if (!_hasRequiredAnchors) {
      return;
    }
    setState(() {
      _loading = true;
    });

    final result = await ExhibitionConsumerLayer.instance
        .loadProjectCounterpartyRatingEntry(
          orderId: _routeOrderId,
          projectId: _routeProjectId,
          rateeOrganizationId: _routeRateeOrganizationId,
          forceRefresh: forceRefresh,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _entryResult = result;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final orderId = _routeOrderId;
    final projectId = _routeProjectId;
    final rateeOrganizationId = _routeRateeOrganizationId;
    if (_submitting ||
        orderId == null ||
        projectId == null ||
        rateeOrganizationId == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _submitResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance
        .submitProjectCounterpartyRating(
          ProjectCounterpartyRatingSubmitCommand(
            orderId: orderId,
            projectId: projectId,
            rateeOrganizationId: rateeOrganizationId,
            scoreLabel: _scoreLabel(_score),
            commentText: _ratingCommentText(),
          ),
        );

    ExhibitionLoadResult? refreshedEntry;
    if (result.isSuccess) {
      refreshedEntry = await ExhibitionConsumerLayer.instance
          .loadProjectCounterpartyRatingEntry(
            orderId: orderId,
            projectId: projectId,
            rateeOrganizationId: rateeOrganizationId,
            forceRefresh: true,
          );
      await ExhibitionConsumerLayer.instance.loadOrderDetail(
        orderId: orderId,
        projectId: projectId,
        forceRefresh: true,
      );
      await ExhibitionConsumerLayer.instance.loadMyProjectList(
        forceRefresh: true,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _submitResult = result;
      if (refreshedEntry != null) {
        _entryResult = refreshedEntry;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _routeOrderId;
    final routeProjectId = _routeProjectId;
    final routeRateeOrganizationId = _routeRateeOrganizationId;
    final result = _entryResult;

    return _LoadPageFrame(
      title: '双方互评入口',
      summary:
          '这里只承接 ProjectCounterpartyRating 三锚点 entry + submit 闭环。页面不再调用旧 rating/submit，也不在 Flutter 推断被评主体。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      controls: _routeOnlyControls(
        routeId: routeOrderId,
        label: 'orderId',
        onReload: () => _load(forceRefresh: true),
        reloadLabel: '重新读取双方互评入口',
      ),
      recoveryRouteOverride: routeOrderId == null
          ? null
          : ExhibitionRoutes.orderDetailWithOrderId(
              routeOrderId,
              projectId: routeProjectId,
            ),
      recoveryButtonLabelOverride: routeOrderId == null ? null : '回到订单详情',
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        if (result.state != AppPageState.content ||
            routeOrderId == null ||
            routeProjectId == null ||
            routeRateeOrganizationId == null) {
          return const <Widget>[];
        }

        final payload = _payloadMap(result.payload);
        final actionPayload = _payloadMap(_submitResult?.payload);
        final ratingId =
            _normalizeId(actionPayload?['ratingId'] as String?) ??
            _normalizeId(payload?['ratingId'] as String?);
        final displayState =
            _counterpartyRatingState(actionPayload) ??
            _counterpartyRatingState(payload) ??
            (payload?['canRate'] == true ? 'eligible' : null);
        final canRate =
            payload?['canRate'] == true && !(_submitResult?.isSuccess == true);
        final reason = _normalizeId(payload?['reason'] as String?);

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(
            title: '当前互评锚点',
            summary:
                '三锚点由 BFF/Server 返回或路由带入；提交动作继续以后端 ProjectCounterpartyRating 真值为准。',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
              const SizedBox(height: 12),
              _InstanceSummaryLine(title: '当前项目 ID', value: routeProjectId),
              const SizedBox(height: 12),
              _InstanceSummaryLine(
                title: '被评主体 ID',
                value: routeRateeOrganizationId,
              ),
              if (ratingId != null) ...<Widget>[
                const SizedBox(height: 12),
                _InstanceSummaryLine(title: '当前评价 ID', value: ratingId),
              ],
              if (displayState != null) ...<Widget>[
                const SizedBox(height: 12),
                _DetailLine(
                  label: '当前状态',
                  value: _counterpartyRatingStateLabel(displayState),
                  highlight: true,
                ),
              ],
              const SizedBox(height: 12),
              _StateMessage(
                title: canRate ? '当前可评价' : '当前不可评价',
                body: canRate
                    ? '当前可以继续提交双方互评；提交后会刷新互评入口、订单详情与我的项目。'
                    : reason ?? '当前评价已提交、订单未完成，或后端未开放互评入口。',
              ),
            ],
          ),
          if (canRate) ...<Widget>[
            const SizedBox(height: 16),
            _ActionCard(
              title: '提交评价',
              summary: '评分、标签和备注只作为本次 ProjectCounterpartyRating 的提交内容。',
              children: <Widget>[
                _RatingScorePicker(
                  score: _score,
                  onChanged: (int value) => setState(() => _score = value),
                ),
                const SizedBox(height: 12),
                _RatingTagPicker(selectedTags: _tags, onToggle: _toggleTag),
                const SizedBox(height: 12),
                TextField(
                  controller: _remarkController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '文字备注',
                    hintText: '补充本次合作体验，仅支持文字。',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey<String>('rating_submit_button'),
                  onPressed: _submitting ? null : _submit,
                  child: const Text('提交双方互评'),
                ),
              ],
            ),
          ],
          if (_submitting) ...<Widget>[
            const SizedBox(height: 16),
            const _SubmittingPanel(),
          ] else if (_submitResult != null) ...<Widget>[
            const SizedBox(height: 16),
            _SubmissionResultPanel(result: _submitResult!),
            if (_submitResult!.isSuccess) ...<Widget>[
              const SizedBox(height: 16),
              _ActionCard(
                title: '双方互评已提交',
                summary: '当前页承接提交后的最小结果，并已刷新互评入口、订单详情与我的项目缓存。',
                tone: _ActionCardTone.emphasis,
                children: <Widget>[
                  _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
                  if (ratingId != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _InstanceSummaryLine(title: '当前评价 ID', value: ratingId),
                  ],
                  if (displayState != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _DetailLine(
                      label: '当前状态',
                      value: _counterpartyRatingStateLabel(displayState),
                      highlight: true,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ];
      },
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
  }

  String _scoreLabel(int score) {
    if (score >= 5) {
      return 'very_satisfied';
    }
    if (score == 4) {
      return 'satisfied';
    }
    if (score == 3) {
      return 'passable';
    }
    return 'negative';
  }

  String? _ratingCommentText() {
    final parts = <String>[
      if (_tags.isNotEmpty) '标签：${_tags.join('、')}',
      if (_remarkController.text.trim().isNotEmpty)
        _remarkController.text.trim(),
    ];
    return parts.isEmpty ? null : parts.join('\n');
  }
}

String? _counterpartyRatingState(Map<String, Object?>? payload) {
  if (payload == null) {
    return null;
  }
  return _normalizeId(payload['ratingState'] as String?) ??
      _normalizeId(payload['state'] as String?);
}

String _counterpartyRatingStateLabel(String state) {
  return switch (state) {
    'eligible' || 'draft' => '待评价',
    'submitted' => '已评价',
    _ => _frontStageStateLabel(state),
  };
}
