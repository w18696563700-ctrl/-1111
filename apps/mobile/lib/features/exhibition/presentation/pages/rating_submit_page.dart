part of '../exhibition_trade_pages.dart';

class RatingSubmitPage extends StatefulWidget {
  const RatingSubmitPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<RatingSubmitPage> createState() => _RatingSubmitPageState();
}

class _RatingSubmitPageState extends State<RatingSubmitPage> {
  late final TextEditingController _orderIdController = TextEditingController(
    text: widget.orderId ?? '',
  );
  ExhibitionLoadResult? _entryResult;
  ExhibitionActionResult? _actionResult;
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (_orderIdController.text.trim().isEmpty) {
      _entryResult = ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: ExhibitionCanonicalPaths.ratingEntry,
        message: 'orderId is required from route context before rating submit',
      );
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });

    final result = await ExhibitionConsumerLayer.instance.loadRatingEntry(
      orderId: _orderIdController.text,
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
    if (orderId == null) {
      setState(() {
        _actionResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.ratingSubmit,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          message:
              'orderId is required from route context before rating submit',
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _actionResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.submitRating(
      RatingSubmitCommand(orderId: orderId),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _actionResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _normalizeId(widget.orderId);
    final ratingState = _stateFromPayload(_entryResult?.payload);
    final entrySummary = _payloadMap(_entryResult?.payload)?['summary'];
    final canSubmit =
        _entryResult?.state == AppPageState.content &&
        routeOrderId != null &&
        ratingState == 'draft';

    final currentStateMessage = switch (ratingState) {
      'draft' => '当前状态：评价仍处于待提交，可以继续完成本次提交。',
      'submitted' => '当前状态：评价已经提交，这一页保持只读承接。',
      _ when _entryResult?.state == AppPageState.content =>
        '当前状态：评价入口已经承接完成，是否允许提交以后端结果为准。',
      _ => '当前状态：需要先拿到评价入口，才能判断这一步是否继续。',
    };
    final actionMessage = switch (ratingState) {
      'draft'
          when _entryResult?.state == AppPageState.content &&
              routeOrderId != null =>
        '当前动作：可以继续提交评价；页面不会本地补做资格或范围判断。',
      'submitted' => '当前动作：评价已经提交，当前页保持只读承接，不再继续放开提交。',
      _ when _entryResult?.state == AppPageState.content =>
        '当前动作：当前保持只读承接，请以后端返回结果为准。',
      _ => '当前动作：当前不可提交，请先恢复评价入口承接。',
    };
    final continueMessage = _actionResult?.isSuccess == true
        ? '提交后如何继续：页面只停留在后端返回的已提交结果承接面。'
        : switch (ratingState) {
            'draft' => '提交后如何继续：如果提交成功，页面只保留 ratingId、orderId、state 与最小摘要承接。',
            'submitted' => '提交后如何继续：当前页保持只读承接，不再展开更多评价工作流。',
            _ => '提交后如何继续：当前页保持受控承接，不扩成额外工作流面板。',
          };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: _buildPageChildren(
        routeOrderId: routeOrderId,
        ratingState: ratingState,
        entrySummary: entrySummary,
        canSubmit: canSubmit,
        currentStateMessage: currentStateMessage,
        actionMessage: actionMessage,
        continueMessage: continueMessage,
      ),
    );
  }

  List<Widget> _buildPageChildren({
    required String? routeOrderId,
    required String? ratingState,
    required Object? entrySummary,
    required bool canSubmit,
    required String currentStateMessage,
    required String actionMessage,
    required String continueMessage,
  }) {
    return <Widget>[
      const _SummaryCard(
        title: '评价提交',
        summary:
            '页面先读取评价入口，再做最小评价提交；这里只消费 orderId、ratingId、state、summary，并只承接最小 submitted 结果。',
      ),
      const SizedBox(height: 16),
      if (_loading)
        const _ContractLoadingCard()
      else if (_entryResult != null)
        _LoadStateCard(
          result: _entryResult!,
          onRetry: () => _load(forceRefresh: true),
        ),
      const SizedBox(height: 16),
      _buildActionCard(
        routeOrderId: routeOrderId,
        ratingState: ratingState,
        entrySummary: entrySummary,
        canSubmit: canSubmit,
        currentStateMessage: currentStateMessage,
        actionMessage: actionMessage,
        continueMessage: continueMessage,
      ),
    ];
  }

  Widget _buildActionCard({
    required String? routeOrderId,
    required String? ratingState,
    required Object? entrySummary,
    required bool canSubmit,
    required String currentStateMessage,
    required String actionMessage,
    required String continueMessage,
  }) {
    return _ActionCard(
      title: '现在提交什么',
      children: <Widget>[
        _StateMessage(title: '当前状态', body: currentStateMessage),
        const SizedBox(height: 12),
        _StateMessage(title: '当前动作', body: actionMessage),
        const SizedBox(height: 12),
        _StateMessage(title: '后续如何继续', body: continueMessage),
        const SizedBox(height: 12),
        if (routeOrderId != null)
          _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
        if (ratingState != null) ...<Widget>[
          const SizedBox(height: 12),
          Text('当前业务状态：${_frontStageStateLabel(ratingState)}'),
        ],
        if (entrySummary is Map) ...<Widget>[
          const SizedBox(height: 12),
          const Text('摘要承接：已承接最小 summary'),
        ],
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey<String>('rating_submit_button'),
          onPressed: _submitting || !canSubmit ? null : _submit,
          child: const Text('提交'),
        ),
        const SizedBox(height: 16),
        if (_submitting)
          const _SubmittingPanel()
        else if (_actionResult != null) ...<Widget>[
          _SubmissionResultPanel(result: _actionResult!),
          if (_actionResult!.isSuccess) ...<Widget>[
            const SizedBox(height: 16),
            ..._buildSuccessSections(routeOrderId),
          ],
        ],
      ],
    );
  }

  List<Widget> _buildSuccessSections(String? routeOrderId) {
    final actionPayload = _payloadMap(_actionResult!.payload);
    final ratingId = _ratingIdFromPayload(_actionResult!.payload);
    final orderId = _orderIdFromPayload(_actionResult!.payload) ?? routeOrderId;
    final actionState = _stateFromPayload(_actionResult!.payload);
    final actionSummary = actionPayload?['summary'];

    if (ratingId == null || orderId == null) {
      return const <Widget>[];
    }

    return <Widget>[
      _ActionCard(
        title: '已提交结果',
        children: <Widget>[
          const Text('当前页面只承接后端返回的最小已提交结果。'),
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前订单 ID', value: orderId),
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前评价 ID', value: ratingId),
          if (actionState != null) ...<Widget>[
            const SizedBox(height: 12),
            Text('当前业务状态：${_frontStageStateLabel(actionState)}'),
          ],
          if (actionSummary is Map) ...<Widget>[
            const SizedBox(height: 12),
            const Text('摘要承接：已承接最小 summary'),
          ],
        ],
      ),
      const SizedBox(height: 16),
      const _ActionCard(
        title: '提交后如何继续',
        children: <Widget>[Text('评价提交已完成，页面停留在当前结果承接，不扩成争议入口、资格台、评审矩阵或历史报表。')],
      ),
    ];
  }
}
