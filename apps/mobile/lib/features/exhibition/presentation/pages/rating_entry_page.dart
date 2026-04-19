part of '../exhibition_trade_pages.dart';

class RatingEntryPage extends StatefulWidget {
  const RatingEntryPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<RatingEntryPage> createState() => _RatingEntryPageState();
}

class _RatingEntryPageState extends State<RatingEntryPage> {
  ExhibitionLoadResult? _entryResult;
  bool _loading = false;
  bool _submitting = false;
  ExhibitionActionResult? _submitResult;

  @override
  void initState() {
    super.initState();
    if (_normalizeId(widget.orderId) == null) {
      _entryResult = ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: ExhibitionCanonicalPaths.ratingEntry,
        message: 'orderId is required from route context before rating entry',
      );
      return;
    }

    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });

    final result = await ExhibitionConsumerLayer.instance.loadRatingEntry(
      orderId: widget.orderId,
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
    final orderId = _normalizeId(widget.orderId);
    if (_submitting || orderId == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _submitResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.submitRating(
      RatingSubmitCommand(orderId: orderId),
    );

    if (result.isSuccess) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _normalizeId(widget.orderId);
    final result = _entryResult;
    final entryState = _stateFromPayload(result?.payload);

    return _LoadPageFrame(
      title: '评价入口',
      summary:
          '这里只承接当前订单的最小评价 entry + submit 闭环。页面只消费既有评价锚点，不扩成评价工作台、历史列表或详情面。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      controls: _routeOnlyControls(
        routeId: routeOrderId,
        label: 'orderId',
        onReload: () => _load(forceRefresh: true),
        reloadLabel: '重新读取评价入口',
      ),
      recoveryRouteOverride:
          routeOrderId == null
              ? null
              : ExhibitionRoutes.orderDetailWithOrderId(routeOrderId),
      recoveryButtonLabelOverride:
          routeOrderId == null ? null : '回到订单详情',
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        if (result.state != AppPageState.content || routeOrderId == null) {
          return const <Widget>[];
        }

        final payload = _payloadMap(result.payload);
        final actionPayload = _payloadMap(_submitResult?.payload);
        final ratingId =
            _normalizeId(actionPayload?['ratingId'] as String?) ??
            _normalizeId(payload?['ratingId'] as String?);
        final summary = payload?['summary'];
        final displayState =
            (_submitResult?.isSuccess == true
                ? _stateFromPayload(_submitResult?.payload)
                : null) ??
            entryState;
        final showSubmitButton =
            displayState == 'eligible' && !(_submitResult?.isSuccess == true);

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(
            title: '当前评价锚点',
            summary: '先确认当前订单是否已经承接到可评价锚点；是否真的允许提交，仍以后端当前返回为准。',
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
                  value: _frontStageStateLabel(displayState),
                  highlight: true,
                ),
              ],
              if (summary is Map)
                const _DetailLine(
                  label: '当前说明',
                  value: '当前评价入口已经读取到最小评价锚点；页面不会扩成评价工作台。',
                ),
              const SizedBox(height: 12),
              _StateMessage(
                title: '当前动作',
                body: showSubmitButton
                    ? '当前可以继续提交最小评价；提交后会刷新我的项目。'
                    : '当前页继续保留最小评价结果承接，不展开第二套评价流程。',
              ),
              if (showSubmitButton) ...<Widget>[
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey<String>('rating_submit_button'),
                  onPressed: _submitting ? null : _submit,
                  child: const Text('继续评价提交'),
                ),
              ],
            ],
          ),
          if (_submitting) ...<Widget>[
            const SizedBox(height: 16),
            const _SubmittingPanel(),
          ] else if (_submitResult != null) ...<Widget>[
            const SizedBox(height: 16),
            _SubmissionResultPanel(result: _submitResult!),
            if (_submitResult!.isSuccess) ...<Widget>[
              const SizedBox(height: 16),
              _ActionCard(
                title: '评价提交已受理',
                summary: '当前页承接提交后的最小结果，并同步刷新我的项目。',
                tone: _ActionCardTone.emphasis,
                children: <Widget>[
                  _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
                  if (_normalizeId(
                        _payloadMap(_submitResult?.payload)?['ratingId']
                            as String?,
                      )
                      case final String submittedRatingId) ...<Widget>[
                    const SizedBox(height: 12),
                    _InstanceSummaryLine(
                      title: '当前评价 ID',
                      value: submittedRatingId,
                    ),
                  ],
                  if (_stateFromPayload(_submitResult?.payload)
                      case final String actionState) ...<Widget>[
                    const SizedBox(height: 12),
                    _DetailLine(
                      label: '当前状态',
                      value: _frontStageStateLabel(actionState),
                      highlight: true,
                    ),
                  ],
                  if (_payloadMap(_submitResult?.payload)?['summary'] is Map)
                    const _DetailLine(
                      label: '当前说明',
                      value: '评价提交已受理；页面已经刷新我的项目缓存。',
                    ),
                ],
              ),
            ],
          ],
        ];
      },
    );
  }
}
