part of '../exhibition_trade_pages.dart';

class RatingEntryPage extends StatefulWidget {
  const RatingEntryPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<RatingEntryPage> createState() => _RatingEntryPageState();
}

class _RatingEntryPageState extends State<RatingEntryPage> {
  late final TextEditingController _orderIdController = TextEditingController(
    text: widget.orderId ?? '',
  );
  ExhibitionLoadResult? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (_orderIdController.text.trim().isEmpty) {
      _result = ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: ExhibitionCanonicalPaths.ratingEntry,
        message: 'orderId is required from route context before rating entry',
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
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _normalizeId(widget.orderId);
    final showRouteControls =
        routeOrderId != null && _result?.state == AppPageState.content;

    return _LoadPageFrame(
      title: '评价入口',
      summary: '先确认当前评价是待提交还是已提交；待提交时继续提交，已提交时保持只读承接，不扩成争议入口、资格台、评审矩阵或历史报表。',
      loading: _loading,
      result: _result,
      onRetry: () => _load(forceRefresh: true),
      controls: showRouteControls
          ? _routeOnlyControls(
              routeId: routeOrderId,
              label: 'orderId',
              onReload: () => _load(forceRefresh: true),
              reloadLabel: '重新读取当前评价入口',
            )
          : const <Widget>[],
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        final ratingState = _stateFromPayload(result.payload);
        final ratingSummary = _payloadMap(result.payload)?['summary'];
        if (result.state != AppPageState.content || routeOrderId == null) {
          return const <Widget>[];
        }

        final actionStatus = switch (ratingState) {
          'draft' => '当前动作：可以继续提交评价',
          _ => '当前动作：当前保持只读',
        };
        final nextStep = switch (ratingState) {
          'draft' => '提交完成后，页面会继续承接已提交评价状态，不再展开更多流程。',
          'submitted' => '当前评价已经提交，后续仍以现有入口回看为主。',
          _ => '当前评价停留在受控承接面，后续不会在这里展开 review 或 moderation。',
        };

        final children = <Widget>[
          Text(switch (ratingState) {
            'draft' => '当前评价还未提交，现在可以继续完成评价提交。',
            'submitted' => '当前评价已经提交，页面保持在只读承接面。',
            _ => '当前评价停留在受控承接面，下一步仍以已有入口为准。',
          }),
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
          if (ratingState != null) ...<Widget>[
            const SizedBox(height: 12),
            Text('当前业务状态：${_frontStageStateLabel(ratingState)}'),
          ],
          if (ratingSummary is Map) ...<Widget>[
            const SizedBox(height: 12),
            const Text('摘要承接：已承接最小 summary'),
          ],
          const SizedBox(height: 12),
          Chip(label: Text(actionStatus)),
          const SizedBox(height: 12),
          Text('后续如何继续：$nextStep'),
        ];

        if (ratingState == 'draft') {
          children.addAll(<Widget>[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  ExhibitionRoutes.ratingSubmitWithOrderId(routeOrderId),
                );
              },
              child: const Text('继续提交评价'),
            ),
          ]);
        }

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(title: '现在先处理什么', children: children),
        ];
      },
    );
  }
}
