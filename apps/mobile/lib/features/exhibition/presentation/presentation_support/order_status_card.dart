part of '../exhibition_trade_pages.dart';

enum _OrderStatusPlacement { projectDetail, conversation, orderDetail }

enum _OrderActorSide { buyer, seller, unknown }

class _OrderStatusCard extends StatefulWidget {
  const _OrderStatusCard({
    required this.orderId,
    this.projectId,
    this.initialResult,
    this.placement = _OrderStatusPlacement.orderDetail,
    this.onChanged,
  });

  final String orderId;
  final String? projectId;
  final ExhibitionLoadResult? initialResult;
  final _OrderStatusPlacement placement;
  final Future<void> Function()? onChanged;

  @override
  State<_OrderStatusCard> createState() => _OrderStatusCardState();
}

class _OrderStatusCardState extends State<_OrderStatusCard> {
  ExhibitionLoadResult? _result;
  ExhibitionActionResult? _lastActionResult;
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    if (_result == null) {
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant _OrderStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _lastActionResult = null;
      _result = widget.initialResult;
      if (_result == null) {
        _load(forceRefresh: true);
      }
      return;
    }
    if (widget.initialResult != null &&
        widget.initialResult != oldWidget.initialResult) {
      _result = widget.initialResult;
    }
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    final result = await ExhibitionConsumerLayer.instance.loadOrderDetail(
      orderId: widget.orderId,
      projectId: widget.projectId,
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

  Future<void> _submit(_OrderCompletionAction action) async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _lastActionResult = null;
    });
    final result = await switch (action) {
      _OrderCompletionAction.request =>
        ExhibitionConsumerLayer.instance.requestOrderCompletion(
          OrderCompletionRequestCommand(
            orderId: widget.orderId,
            note: '承接方申请当前订单完工，请发布方确认。',
          ),
        ),
      _OrderCompletionAction.confirm =>
        ExhibitionConsumerLayer.instance.confirmOrderCompletion(
          OrderCompletionConfirmCommand(orderId: widget.orderId),
        ),
      _OrderCompletionAction.reject =>
        ExhibitionConsumerLayer.instance.rejectOrderCompletion(
          OrderCompletionRejectCommand(
            orderId: widget.orderId,
            reason: '发布方暂不确认完工，需要继续沟通。',
          ),
        ),
    };
    ExhibitionLoadResult? refreshed;
    if (result.isSuccess) {
      refreshed = await ExhibitionConsumerLayer.instance.loadOrderDetail(
        orderId: widget.orderId,
        projectId: widget.projectId,
        forceRefresh: true,
      );
      await ExhibitionConsumerLayer.instance.loadMyProjectList(
        forceRefresh: true,
      );
      await widget.onChanged?.call();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      _lastActionResult = result;
      if (refreshed != null) {
        _result = refreshed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final payload = _payloadMap(result?.payload) ?? const <String, Object?>{};
    final effectiveOrder = _EffectiveOrderStatus.from(
      payload: payload,
      actionPayload: _payloadMap(_lastActionResult?.payload),
      fallbackOrderId: widget.orderId,
      fallbackProjectId: widget.projectId,
    );
    final actorSide = _currentOrderActorSide(
      context,
      effectiveOrder,
      placement: widget.placement,
    );

    return _ActionCard(
      title: '完工处理',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (_loading && result == null)
          const _StateMessage(title: '正在读取订单', body: '正在读取最新订单状态。')
        else if (result != null && result.state != AppPageState.content)
          _buildLoadFailure(result)
        else
          ..._buildStatusContent(effectiveOrder, actorSide),
        if (_lastActionResult != null) ...<Widget>[
          const SizedBox(height: 12),
          _SubmissionResultPanel(result: _lastActionResult!),
        ],
      ],
    );
  }

  Widget _buildLoadFailure(ExhibitionLoadResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StateMessage(
          title: '订单状态暂不可读',
          body: _userFacingLoadFailureMessage(result),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _loading ? null : () => _load(forceRefresh: true),
          child: const Text('刷新订单状态'),
        ),
      ],
    );
  }

  List<Widget> _buildStatusContent(
    _EffectiveOrderStatus order,
    _OrderActorSide actorSide,
  ) {
    return <Widget>[
      _DetailLine(
        label: '订单状态',
        value: _frontStageStateLabel(order.state ?? 'active'),
        highlight: true,
      ),
      _DetailLine(
        label: '完工申请状态',
        value: _frontStageStateLabel(order.completionRequestState ?? 'none'),
      ),
      const SizedBox(height: 10),
      _StateMessage(
        title: '当前账号动作',
        body: _actorActionDescription(actorSide, order),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _buildActionButtons(actorSide, order),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _loading ? null : () => _load(forceRefresh: true),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('刷新状态'),
      ),
    ];
  }

  List<Widget> _buildActionButtons(
    _OrderActorSide actorSide,
    _EffectiveOrderStatus order,
  ) {
    if (order.isCompleted) {
      final ratingRoute = _projectCounterpartyRatingRouteForOrder(
        context,
        order,
      );
      return <Widget>[
        if (ratingRoute != null)
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pushNamed(ratingRoute);
            },
            child: const Text('查看双方互评入口'),
          )
        else
          const _StatusPill(label: '互评入口暂不可用', tone: _ActionCardTone.muted),
      ];
    }
    if (actorSide == _OrderActorSide.seller) {
      final requested = order.completionRequestState == 'requested';
      return <Widget>[
        FilledButton(
          onPressed: requested || _submitting
              ? null
              : () => _submit(_OrderCompletionAction.request),
          child: Text(requested ? '已申请完工' : '申请完工'),
        ),
      ];
    }
    if (actorSide == _OrderActorSide.buyer) {
      return <Widget>[
        FilledButton(
          onPressed: _submitting
              ? null
              : () => _submit(_OrderCompletionAction.confirm),
          child: const Text('确认完成'),
        ),
        OutlinedButton(
          onPressed: _submitting
              ? null
              : () => _submit(_OrderCompletionAction.reject),
          child: const Text('拒绝完工'),
        ),
      ];
    }
    return <Widget>[
      const _StatusPill(label: '当前账号仅可查看', tone: _ActionCardTone.muted),
    ];
  }
}

enum _OrderCompletionAction { request, confirm, reject }

class _EffectiveOrderStatus {
  const _EffectiveOrderStatus({
    required this.orderId,
    this.orderNo,
    this.projectId,
    this.buyerOrganizationId,
    this.sellerOrganizationId,
    this.state,
    this.completionRequestState,
  });

  final String orderId;
  final String? orderNo;
  final String? projectId;
  final String? buyerOrganizationId;
  final String? sellerOrganizationId;
  final String? state;
  final String? completionRequestState;

  bool get isCompleted =>
      state == 'completed' || completionRequestState == 'confirmed';

  static _EffectiveOrderStatus from({
    required Map<String, Object?> payload,
    required Map<String, Object?>? actionPayload,
    required String fallbackOrderId,
    required String? fallbackProjectId,
  }) {
    final action = actionPayload ?? const <String, Object?>{};
    return _EffectiveOrderStatus(
      orderId:
          _normalizeDynamicText(action['orderId']) ??
          _normalizeDynamicText(payload['orderId']) ??
          fallbackOrderId,
      orderNo: _normalizeDynamicText(payload['orderNo']),
      projectId:
          _normalizeDynamicText(action['projectId']) ??
          _normalizeDynamicText(payload['projectId']) ??
          fallbackProjectId,
      buyerOrganizationId: _normalizeDynamicText(
        payload['buyerOrganizationId'],
      ),
      sellerOrganizationId: _normalizeDynamicText(
        payload['sellerOrganizationId'],
      ),
      state:
          _normalizeDynamicText(action['state']) ??
          _normalizeDynamicText(payload['state']),
      completionRequestState:
          _normalizeDynamicText(action['completionRequestState']) ??
          _normalizeDynamicText(payload['completionRequestState']),
    );
  }
}

_OrderActorSide _currentOrderActorSide(
  BuildContext context,
  _EffectiveOrderStatus order, {
  required _OrderStatusPlacement placement,
}) {
  final scope = _shellScopeOf(context);
  final shellContext = scope?.notifier?.snapshot.shellContext;
  final organizationId = _currentOrganizationId(context);
  if (placement == _OrderStatusPlacement.conversation &&
      (organizationId == null ||
          order.buyerOrganizationId == null ||
          order.sellerOrganizationId == null)) {
    return _OrderActorSide.unknown;
  }
  if (organizationId != null) {
    if (organizationId == order.buyerOrganizationId) {
      return _OrderActorSide.buyer;
    }
    if (organizationId == order.sellerOrganizationId) {
      return _OrderActorSide.seller;
    }
  }
  final roleKeys = shellContext?.roleKeys ?? const <String>[];
  if (roleKeys.any((String role) => role.contains('supplier'))) {
    return _OrderActorSide.seller;
  }
  if (roleKeys.any(
    (String role) => role.contains('buyer') || role.contains('project_owner'),
  )) {
    return _OrderActorSide.buyer;
  }
  return _OrderActorSide.unknown;
}

AppShellScope? _shellScopeOf(BuildContext context) {
  return context
          .getElementForInheritedWidgetOfExactType<AppShellScope>()
          ?.widget
      as AppShellScope?;
}

String? _currentOrganizationId(BuildContext context) {
  final shellContext = _shellScopeOf(context)?.notifier?.snapshot.shellContext;
  return _normalizeDynamicText(shellContext?.organizationId);
}

String? _projectCounterpartyRatingRouteForOrder(
  BuildContext context,
  _EffectiveOrderStatus order,
) {
  if (!order.isCompleted) {
    return null;
  }
  final projectId = _normalizeDynamicText(order.projectId);
  final rateeOrganizationId = _rateeOrganizationIdForCurrentActor(
    context,
    order,
  );
  if (projectId == null || rateeOrganizationId == null) {
    return null;
  }
  return ExhibitionRoutes.projectCounterpartyRatingEntry(
    orderId: order.orderId,
    projectId: projectId,
    rateeOrganizationId: rateeOrganizationId,
  );
}

String? _rateeOrganizationIdForCurrentActor(
  BuildContext context,
  _EffectiveOrderStatus order,
) {
  final organizationId = _currentOrganizationId(context);
  final buyerId = _normalizeDynamicText(order.buyerOrganizationId);
  final sellerId = _normalizeDynamicText(order.sellerOrganizationId);
  if (organizationId == null || buyerId == null || sellerId == null) {
    return null;
  }
  if (organizationId == buyerId) {
    return sellerId;
  }
  if (organizationId == sellerId) {
    return buyerId;
  }
  return null;
}

String _actorActionDescription(
  _OrderActorSide actorSide,
  _EffectiveOrderStatus order,
) {
  if (order.isCompleted) {
    return '订单已完成，可继续查看双方互评入口。';
  }
  return switch (actorSide) {
    _OrderActorSide.seller =>
      order.completionRequestState == 'requested'
          ? '已申请完工，等待发布方确认。'
          : '当前账号可提交申请完工。',
    _OrderActorSide.buyer => '当前账号可确认完成或拒绝完工。',
    _OrderActorSide.unknown => '当前账号仅可查看订单状态。',
  };
}

String? _orderIdFromProjectMap(Map<String, Object?> projectMap) {
  final selection = _asStringObjectMap(projectMap['bidSelection']);
  final order = _asStringObjectMap(projectMap['order']);
  final orderSummary = _asStringObjectMap(projectMap['orderSummary']);
  return _normalizeDynamicText(selection?['orderId']) ??
      _normalizeDynamicText(order?['orderId']) ??
      _normalizeDynamicText(orderSummary?['orderId']) ??
      _normalizeDynamicText(projectMap['orderId']);
}

Map<String, Object?>? _asStringObjectMap(Object? value) {
  if (value is! Map) {
    return null;
  }
  return value.map((Object? key, Object? value) => MapEntry('$key', value));
}
