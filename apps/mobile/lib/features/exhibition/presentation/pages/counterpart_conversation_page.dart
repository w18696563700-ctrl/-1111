part of '../exhibition_trade_pages.dart';

class CounterpartConversationPage extends StatefulWidget {
  const CounterpartConversationPage({
    super.key,
    this.conversationId,
    this.projectId,
  });

  final String? conversationId;
  final String? projectId;

  @override
  State<CounterpartConversationPage> createState() =>
      _CounterpartConversationPageState();
}

class _CounterpartConversationPageState
    extends State<CounterpartConversationPage>
    with WidgetsBindingObserver {
  static const List<Duration> _reconnectDelays = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  CounterpartConversationResult<CounterpartConversationDetailView>? _result;
  CounterpartConversationResult<ProjectCommunicationThreadView>? _threadResult;
  CounterpartConversationResult<ProjectCommunicationMessageListView>?
  _messageResult;
  ProjectCommunicationRealtimeSubscription? _realtimeSubscription;
  StreamSubscription<ProjectCommunicationMessageCreatedEvent>?
  _realtimeEventSubscription;
  Timer? _reconnectTimer;
  Timer? _pollTimer;
  final List<_DraftProjectCommunicationMessage> _drafts =
      <_DraftProjectCommunicationMessage>[];
  String? _selectedProjectId;
  int _reconnectAttempt = 0;
  bool _loading = true;
  bool _loadingThread = false;
  bool _loadingMessages = false;
  bool _sending = false;
  bool _fallbackPolling = false;
  bool _pausedByLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRealtime();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_pausedByLifecycle) {
          _pausedByLifecycle = false;
          _resumeRealtimeAfterLifecyclePause();
        }
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pausedByLifecycle = true;
        _stopRealtime();
        return;
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await CounterpartConversationConsumerLayer.instance
        .loadDetail(
          conversationId: widget.conversationId,
          projectId: widget.projectId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
      _threadResult = null;
      _messageResult = null;
      if (_selectedProjectId != null &&
          (result.data == null ||
              !_hasProjectGroup(result.data!, _selectedProjectId!))) {
        _selectedProjectId = null;
        _drafts.clear();
      }
    });
    await _stopRealtime();
    final selectedProjectId = _selectedProjectId;
    if (result.state == AppPageState.content &&
        result.data != null &&
        selectedProjectId != null) {
      await _loadThreadAndMessages(result.data!, projectId: selectedProjectId);
    }
  }

  Future<void> _loadThreadAndMessages(
    CounterpartConversationDetailView data, {
    required String projectId,
  }) async {
    setState(() {
      _loadingThread = true;
      _loadingMessages = true;
    });
    final threadResult = await CounterpartConversationConsumerLayer.instance
        .loadProjectCommunicationThread(
          projectId: projectId,
          counterpartOrganizationId: data.counterpart.organizationId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _threadResult = threadResult;
      _loadingThread = false;
    });
    if (threadResult.state == AppPageState.content &&
        threadResult.data != null) {
      await _loadMessages(threadResult.data!);
      await _connectRealtime(threadResult.data!, data.counterpart);
    } else if (mounted) {
      setState(() => _loadingMessages = false);
    }
  }

  Future<void> _loadMessages(
    ProjectCommunicationThreadView thread, {
    bool scrollToBottom = false,
  }) async {
    setState(() => _loadingMessages = true);
    final result = await CounterpartConversationConsumerLayer.instance
        .loadProjectCommunicationMessages(
          threadId: thread.threadId,
          projectId: thread.projectId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _messageResult = result;
      _loadingMessages = false;
    });
    if (scrollToBottom && result.state == AppPageState.content) {
      _scheduleScrollToBottom();
    }
    if (result.state == AppPageState.content &&
        result.data?.items.isNotEmpty == true) {
      await _markLatestRead(thread, result.data!.items.last.messageId);
    }
  }

  Future<void> _loadMessagesQuiet(ProjectCommunicationThreadView thread) async {
    final result = await CounterpartConversationConsumerLayer.instance
        .loadProjectCommunicationMessages(
          threadId: thread.threadId,
          projectId: thread.projectId,
        );
    if (!mounted || result.state != AppPageState.content) {
      return;
    }
    setState(() => _messageResult = result);
    if (result.data?.items.isNotEmpty == true) {
      await _markLatestRead(thread, result.data!.items.last.messageId);
    }
  }

  Future<void> _connectRealtime(
    ProjectCommunicationThreadView thread,
    MessageInteractionCounterpartView counterpart,
  ) async {
    await _stopRealtime();
    try {
      final subscription = await CounterpartConversationConsumerLayer
          .instance
          .projectCommunicationRealtimeClient
          .subscribe(
            threadId: thread.threadId,
            projectId: thread.projectId,
            counterpartOrganizationId: counterpart.organizationId,
          );
      if (!mounted || _threadResult?.data?.threadId != thread.threadId) {
        await subscription.close();
        return;
      }
      _realtimeSubscription = subscription;
      _fallbackPolling = false;
      _reconnectAttempt = 0;
      _realtimeEventSubscription = subscription.events.listen(
        (ProjectCommunicationMessageCreatedEvent event) {
          _appendRealtimeEvent(thread, event);
        },
        onError: (_) => _handleRealtimeDisconnected(thread, counterpart),
        onDone: () => _handleRealtimeDisconnected(thread, counterpart),
      );
    } catch (_) {
      _handleRealtimeDisconnected(thread, counterpart);
    }
  }

  Future<void> _stopRealtime() async {
    _fallbackPolling = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    final eventSubscription = _realtimeEventSubscription;
    _realtimeEventSubscription = null;
    final cancelFuture = eventSubscription?.cancel();
    if (cancelFuture != null) {
      unawaited(cancelFuture.catchError((_) {}));
    }
    final subscription = _realtimeSubscription;
    _realtimeSubscription = null;
    final closeFuture = subscription?.close();
    if (closeFuture != null) {
      await closeFuture.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {},
      );
    }
  }

  void _handleRealtimeDisconnected(
    ProjectCommunicationThreadView thread,
    MessageInteractionCounterpartView counterpart,
  ) {
    if (!mounted || _pausedByLifecycle) {
      return;
    }
    _startQuietPolling(thread);
    _scheduleRealtimeReconnect(thread, counterpart);
  }

  void _scheduleRealtimeReconnect(
    ProjectCommunicationThreadView thread,
    MessageInteractionCounterpartView counterpart,
  ) {
    if (_reconnectTimer != null || !mounted) {
      return;
    }
    final delay =
        _reconnectDelays[math.min(
          _reconnectAttempt,
          _reconnectDelays.length - 1,
        )];
    _reconnectAttempt += 1;
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      if (!mounted ||
          _pausedByLifecycle ||
          _threadResult?.data?.threadId != thread.threadId) {
        return;
      }
      _connectRealtime(thread, counterpart);
    });
  }

  void _resumeRealtimeAfterLifecyclePause() {
    final thread = _threadResult?.data;
    final counterpart = _result?.data?.counterpart;
    if (thread == null || counterpart == null) {
      return;
    }
    _loadMessagesQuiet(thread);
    _connectRealtime(thread, counterpart);
  }

  void _startQuietPolling(ProjectCommunicationThreadView thread) {
    if (_fallbackPolling || !mounted) {
      return;
    }
    _fallbackPolling = true;
    _loadMessagesQuiet(thread);
    _scheduleQuietPoll(thread);
  }

  void _scheduleQuietPoll(ProjectCommunicationThreadView thread) {
    _pollTimer?.cancel();
    _pollTimer = Timer(const Duration(seconds: 10), () async {
      if (!mounted ||
          !_fallbackPolling ||
          _threadResult?.data?.threadId != thread.threadId) {
        return;
      }
      await _loadMessagesQuiet(thread);
      if (mounted &&
          _fallbackPolling &&
          _threadResult?.data?.threadId == thread.threadId) {
        _scheduleQuietPoll(thread);
      }
    });
  }

  void _appendRealtimeEvent(
    ProjectCommunicationThreadView thread,
    ProjectCommunicationMessageCreatedEvent event,
  ) {
    if (event.threadId != thread.threadId ||
        event.projectId != thread.projectId) {
      return;
    }
    final current = _messageResult?.data;
    final messages =
        current?.items ?? const <ProjectCommunicationMessageView>[];
    if (_containsMessage(messages, event)) {
      return;
    }
    final nextMessages = <ProjectCommunicationMessageView>[
      ...messages,
      event.toMessageView(),
    ];
    setState(() {
      _messageResult =
          CounterpartConversationResult<ProjectCommunicationMessageListView>(
            state: AppPageState.content,
            method: _messageResult?.method ?? 'WS',
            path:
                _messageResult?.path ??
                MessagesCanonicalPaths.projectCommunicationMessages,
            data: ProjectCommunicationMessageListView(
              items: nextMessages,
              nextCursor: current?.nextCursor,
            ),
          );
      final clientMessageId = event.clientMessageId;
      if (clientMessageId != null) {
        _drafts.removeWhere(
          (_DraftProjectCommunicationMessage item) =>
              item.clientMessageId == clientMessageId,
        );
      }
    });
    _scheduleScrollToBottom();
    _markLatestRead(thread, event.messageId);
  }

  bool _containsMessage(
    List<ProjectCommunicationMessageView> messages,
    ProjectCommunicationMessageCreatedEvent event,
  ) {
    return messages.any((ProjectCommunicationMessageView message) {
      if (message.messageId == event.messageId) {
        return true;
      }
      final eventClientMessageId = event.clientMessageId;
      return eventClientMessageId != null &&
          message.clientMessageId == eventClientMessageId;
    });
  }

  Future<void> _markLatestRead(
    ProjectCommunicationThreadView thread,
    String lastReadMessageId,
  ) {
    return CounterpartConversationConsumerLayer.instance
        .markProjectCommunicationReadCursor(
          threadId: thread.threadId,
          projectId: thread.projectId,
          lastReadMessageId: lastReadMessageId,
        );
  }

  Future<void> _sendCurrentMessage() async {
    final body = _messageController.text.trim();
    final thread = _threadResult?.data;
    if (body.isEmpty || thread == null || _sending) {
      if (body.isEmpty) {
        _showSnack('请输入要发送的文字。');
      }
      return;
    }
    final draft = _DraftProjectCommunicationMessage(
      clientMessageId: _newClientMessageId(),
      body: body,
      createdAt: DateTime.now(),
      state: _DraftProjectCommunicationState.sending,
    );
    setState(() {
      _messageController.clear();
      _drafts.add(draft);
    });
    _scheduleScrollToBottom();
    await _sendDraft(draft);
  }

  Future<void> _retryDraft(_DraftProjectCommunicationMessage draft) {
    return _sendDraft(
      draft.copyWith(state: _DraftProjectCommunicationState.sending),
    );
  }

  Future<void> _sendDraft(_DraftProjectCommunicationMessage draft) async {
    final thread = _threadResult?.data;
    if (thread == null || _sending) {
      return;
    }
    _replaceDraft(draft);
    setState(() => _sending = true);
    final result = await CounterpartConversationConsumerLayer.instance
        .sendProjectCommunicationMessage(
          threadId: thread.threadId,
          projectId: thread.projectId,
          body: draft.body,
          clientMessageId: draft.clientMessageId,
        );
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    if (result.state == AppPageState.content) {
      setState(
        () => _drafts.removeWhere(
          (_DraftProjectCommunicationMessage item) =>
              item.clientMessageId == draft.clientMessageId,
        ),
      );
      await _loadMessages(thread, scrollToBottom: true);
      return;
    }
    _replaceDraft(
      draft.copyWith(
        state: _DraftProjectCommunicationState.failed,
        errorMessage: result.message ?? result.state.contractName,
      ),
    );
  }

  void _replaceDraft(_DraftProjectCommunicationMessage draft) {
    final index = _drafts.indexWhere(
      (_DraftProjectCommunicationMessage item) =>
          item.clientMessageId == draft.clientMessageId,
    );
    setState(() {
      if (index == -1) {
        _drafts.add(draft);
      } else {
        _drafts[index] = draft;
      }
    });
  }

  Future<void> _openProjectCommunication(
    CounterpartConversationProjectGroupView group,
  ) async {
    await _stopRealtime();
    if (!mounted) {
      return;
    }
    _messageController.clear();
    setState(() {
      _selectedProjectId = group.projectId;
      _threadResult = null;
      _messageResult = null;
      _drafts.clear();
      _loadingThread = true;
      _loadingMessages = true;
    });
    _scheduleScrollToTop();
    final data = _result?.data;
    if (data != null) {
      await _loadThreadAndMessages(data, projectId: group.projectId);
    }
  }

  Future<void> _backToProjectList() async {
    await _stopRealtime();
    if (!mounted) {
      return;
    }
    _messageController.clear();
    setState(() {
      _selectedProjectId = null;
      _threadResult = null;
      _messageResult = null;
      _drafts.clear();
      _loadingThread = false;
      _loadingMessages = false;
    });
    _scheduleScrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    final thread = _threadResult?.data;
    return PopScope(
      canPop: _selectedProjectId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _selectedProjectId == null) {
          return;
        }
        unawaited(_backToProjectList());
      },
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: <Widget>[
                    if (_loading)
                      const _StateMessage(title: '正在加载', body: '请稍候片刻。')
                    else if (result == null ||
                        result.state != AppPageState.content)
                      _buildFailureCard(result)
                    else
                      ..._buildContent(data!, thread),
                  ],
                ),
              ),
            ),
            if (data != null && result?.state == AppPageState.content)
              if (_selectedProjectId != null && thread != null)
                _ProjectCommunicationComposer(
                  controller: _messageController,
                  enabled: !_loadingThread,
                  sending: _sending,
                  onSend: _sendCurrentMessage,
                ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    CounterpartConversationDetailView data,
    ProjectCommunicationThreadView? thread,
  ) {
    final groups = _sortedProjectGroups(data);
    final selectedGroup = _selectedProjectGroup(data);
    if (_selectedProjectId == null || selectedGroup == null) {
      return <Widget>[
        _CounterpartConversationHeader(
          data: data,
          onOpenSubjectCard: () => _openSubjectCard(data),
          canOpenSubjectCard: _canOpenSubjectCard(data),
          title: '项目沟通',
        ),
        const SizedBox(height: 16),
        _CounterpartProjectEntryList(
          groups: groups,
          onOpenProjectCommunication: _openProjectCommunication,
        ),
      ];
    }
    final exitGovernanceSnapshot =
        _projectExitGovernanceSnapshotFromConversation(
          selectedGroup.orderSummary?.exitGovernance,
        );
    final selectedOrderId = _orderIdFromConversationGroup(selectedGroup);
    return <Widget>[
      _CounterpartConversationHeader(
        data: data,
        onOpenSubjectCard: () => _openSubjectCard(data),
        canOpenSubjectCard: _canOpenSubjectCard(data),
        title: '竞标沟通',
      ),
      const SizedBox(height: 16),
      _SelectedProjectBusinessEntrypoints(
        group: selectedGroup,
        participationCard: _firstBusinessCard(
          selectedGroup,
          'bid_participation_request',
        ),
        orderId: selectedOrderId,
        onBackToProjectList: _backToProjectList,
        onOpenNameAccess: _openBusinessCard,
        onOpenOrder: () => _openOrderDetail(selectedGroup),
        onOpenProjectAlbum: () => _openProjectAlbum(selectedGroup),
      ),
      if (exitGovernanceSnapshot != null) ...<Widget>[
        const SizedBox(height: 16),
        _ProjectExitGovernanceStatusCard(
          snapshot: exitGovernanceSnapshot,
          placement: _ProjectExitGovernancePlacement.conversation,
          projectId: selectedGroup.projectId,
          orderId: selectedOrderId,
          onOpenOrder: selectedOrderId == null
              ? null
              : () => _openOrderDetail(selectedGroup),
        ),
      ],
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _ProjectCommunicationTimeline(
          loadingThread: _loadingThread,
          loadingMessages: _loadingMessages,
          threadResult: _threadResult,
          messageResult: _messageResult,
          drafts: _drafts,
          currentOrganizationId: _currentOrganizationId(context),
          onRetryDraft: _retryDraft,
          onRefreshMessages: thread == null
              ? null
              : () => _loadMessages(thread),
        ),
      ),
    ];
  }

  Widget _buildFailureCard(
    CounterpartConversationResult<CounterpartConversationDetailView>? result,
  ) {
    return _ActionCard(
      title: result?.message ?? '当前对方沟通容器暂不可用',
      children: <Widget>[
        _StateMessage(
          title: '受控状态',
          body: result?.errorCode ?? result?.state.contractName ?? 'unknown',
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: _load, child: const Text('重试')),
      ],
    );
  }

  void _openBusinessCard(CounterpartConversationBusinessCardView card) {
    final target = card.detailRouteTarget ?? _fallbackRouteTarget(card);
    if (target == null) {
      _showSnack('当前业务卡暂时没有可打开的详情。');
      return;
    }
    Navigator.of(context).pushNamed(target.routeLocation);
  }

  void _openOrderDetail(CounterpartConversationProjectGroupView group) {
    final orderCard = _firstBusinessCard(group, 'project_order');
    final orderTarget =
        orderCard?.detailRouteTarget ?? _fallbackOrderTarget(group);
    if (orderTarget == null) {
      _showSnack('当前项目暂时没有可打开的订单状态。');
      return;
    }
    Navigator.of(context).pushNamed(orderTarget.routeLocation);
  }

  void _openProjectAlbum(CounterpartConversationProjectGroupView group) {
    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.projectAlbumWithProjectId(group.projectId));
  }

  void _openSubjectCard(CounterpartConversationDetailView data) {
    final group = _subjectProjectGroup(data);
    if (group == null || data.counterpart.organizationId.trim().isEmpty) {
      _showSnack('当前缺少项目边界，暂不能打开对方主体卡。');
      return;
    }
    showCounterpartConversationSubjectSheet(
      context,
      data: data,
      projectGroup: group,
      bidId: _firstBidId(group),
      onRatingSubmitted: _load,
    );
  }

  bool _canOpenSubjectCard(CounterpartConversationDetailView data) {
    return _subjectProjectGroup(data) != null &&
        data.counterpart.organizationId.trim().isNotEmpty;
  }

  List<CounterpartConversationProjectGroupView> _sortedProjectGroups(
    CounterpartConversationDetailView data,
  ) {
    final groups = List<CounterpartConversationProjectGroupView>.of(
      data.projectGroups,
    );
    groups.sort((a, b) {
      if (a.projectId == data.focusProjectId &&
          b.projectId != data.focusProjectId) {
        return -1;
      }
      if (b.projectId == data.focusProjectId &&
          a.projectId != data.focusProjectId) {
        return 1;
      }
      return a.latestActivityAt.compareTo(b.latestActivityAt) * -1;
    });
    return groups
        .map(
          (group) => CounterpartConversationProjectGroupView(
            projectId: group.projectId,
            projectDisplayTitle: group.projectDisplayTitle,
            titleVisibility: group.titleVisibility,
            projectRelation: group.projectRelation,
            projectState: group.projectState,
            latestActivityAt: group.latestActivityAt,
            orderSummary: group.orderSummary,
            ratingEntry: group.ratingEntry,
            cards: _sortedBusinessCards(group.cards),
          ),
        )
        .toList(growable: false);
  }

  List<CounterpartConversationBusinessCardView> _sortedBusinessCards(
    List<CounterpartConversationBusinessCardView> cards,
  ) {
    final sorted = List<CounterpartConversationBusinessCardView>.of(cards);
    sorted.sort((a, b) {
      final priority = _businessCardPriority(
        a.cardType,
      ).compareTo(_businessCardPriority(b.cardType));
      if (priority != 0) {
        return priority;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return sorted;
  }

  int _businessCardPriority(String type) {
    return switch (type) {
      'bid_participation_request' => 0,
      'bid_thread' => 1,
      'project_order' => 2,
      'project_clarification' => 3,
      'system_notice' => 4,
      'project_name_access_request' => 8,
      _ => 9,
    };
  }

  CounterpartConversationProjectGroupView? _subjectProjectGroup(
    CounterpartConversationDetailView data,
  ) {
    final selectedProjectId = _selectedProjectId;
    if (selectedProjectId != null) {
      for (final group in data.projectGroups) {
        if (group.projectId == selectedProjectId) {
          return group;
        }
      }
    }
    for (final group in data.projectGroups) {
      if (group.projectId == data.focusProjectId) {
        return group;
      }
    }
    return data.projectGroups.isEmpty ? null : data.projectGroups.first;
  }

  CounterpartConversationProjectGroupView? _selectedProjectGroup(
    CounterpartConversationDetailView data,
  ) {
    final selectedProjectId = _selectedProjectId;
    if (selectedProjectId == null) {
      return null;
    }
    for (final group in _sortedProjectGroups(data)) {
      if (group.projectId == selectedProjectId) {
        return group;
      }
    }
    return null;
  }

  bool _hasProjectGroup(
    CounterpartConversationDetailView data,
    String projectId,
  ) {
    return data.projectGroups.any(
      (CounterpartConversationProjectGroupView group) =>
          group.projectId == projectId,
    );
  }

  CounterpartConversationBusinessCardView? _firstBusinessCard(
    CounterpartConversationProjectGroupView group,
    String cardType,
  ) {
    for (final card in group.cards) {
      if (card.cardType == cardType) {
        return card;
      }
    }
    return null;
  }

  String? _firstBidId(CounterpartConversationProjectGroupView? group) {
    if (group == null) {
      return null;
    }
    for (final card in group.cards) {
      final bidId = card.truthAnchor.bidId;
      if (bidId != null && bidId.trim().isNotEmpty) {
        return bidId.trim();
      }
    }
    return null;
  }

  MessageInteractionRouteTarget? _fallbackRouteTarget(
    CounterpartConversationBusinessCardView card,
  ) {
    final anchor = card.truthAnchor;
    switch (anchor.truthType) {
      case 'bid_participation_request':
        final requestId = anchor.requestId;
        final threadId = anchor.threadId ?? requestId;
        if (requestId == null || threadId == null) {
          return null;
        }
        return _routeTarget(
          objectType: 'bid_participation_request',
          actionKey: 'bid_participation_request.open',
          canonicalPath: '/api/app/project/bid-participation/thread/detail',
          params: <String, String>{
            'threadId': threadId,
            'projectId': anchor.projectId,
            'requestId': requestId,
          },
        );
      case 'project_name_access_request':
        final requestId = anchor.requestId;
        final threadId = anchor.threadId ?? requestId;
        if (requestId == null || threadId == null) {
          return null;
        }
        return _routeTarget(
          objectType: 'project_name_access_thread',
          actionKey: 'project_name_access_thread.open',
          canonicalPath: '/api/app/project/name-access/thread/detail',
          params: <String, String>{
            'threadId': threadId,
            'projectId': anchor.projectId,
            'requestId': requestId,
          },
        );
      case 'bid_thread':
        final bidId = anchor.bidId;
        if (bidId == null) {
          return null;
        }
        return _routeTarget(
          objectType: 'bid_thread',
          actionKey: 'bid_thread.open',
          canonicalPath: '/api/app/bid/thread/detail',
          params: <String, String>{
            'projectId': anchor.projectId,
            'bidId': bidId,
          },
        );
      case 'project_clarification':
        return _routeTarget(
          objectType: 'project_clarification',
          actionKey: 'project_clarification.open',
          canonicalPath: '/api/app/project/clarification/list',
          params: <String, String>{'projectId': anchor.projectId},
        );
      case 'project_order':
        final orderId = anchor.orderId;
        if (orderId == null) {
          return null;
        }
        return _routeTarget(
          objectType: 'order',
          actionKey: 'order_detail.open',
          canonicalPath: '/api/app/order/detail',
          params: <String, String>{
            'projectId': anchor.projectId,
            'orderId': orderId,
          },
        );
      default:
        return null;
    }
  }

  MessageInteractionRouteTarget? _fallbackOrderTarget(
    CounterpartConversationProjectGroupView group,
  ) {
    final orderId = _orderIdFromConversationGroup(group);
    if (orderId == null) {
      return null;
    }
    return _routeTarget(
      objectType: 'order',
      actionKey: 'order_detail.open',
      canonicalPath: '/api/app/order/detail',
      params: <String, String>{
        'projectId': group.projectId,
        'orderId': orderId,
      },
    );
  }

  MessageInteractionRouteTarget? _routeTarget({
    required String objectType,
    required String actionKey,
    required String canonicalPath,
    required Map<String, String> params,
  }) {
    final definition = messagesRegisteredEntryByActionKey[actionKey];
    final routeLocation = definition?.buildRouteLocation(params);
    if (definition == null ||
        definition.objectType != objectType ||
        definition.canonicalPath != canonicalPath ||
        routeLocation == null ||
        routeLocation.startsWith('routeTarget.')) {
      return null;
    }
    return MessageInteractionRouteTarget(
      objectType: objectType,
      actionKey: actionKey,
      canonicalPath: canonicalPath,
      params: params,
      routeLocation: routeLocation,
    );
  }

  String? _currentOrganizationId(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<AppShellScope>();
    final scope = element?.widget as AppShellScope?;
    return scope?.notifier?.snapshot.shellContext.organizationId;
  }

  String? _orderIdFromConversationGroup(
    CounterpartConversationProjectGroupView group,
  ) {
    final summaryOrderId =
        group.orderSummary?.orderId ?? group.ratingEntry?.orderId;
    if (summaryOrderId != null && summaryOrderId.trim().isNotEmpty) {
      return summaryOrderId;
    }
    for (final card in group.cards) {
      final orderId = card.truthAnchor.orderId;
      if ((card.cardType == 'project_order' ||
              card.truthAnchor.truthType == 'project_order') &&
          orderId != null &&
          orderId.trim().isNotEmpty) {
        return orderId;
      }
    }
    return null;
  }

  String _newClientMessageId() {
    return 'mobile-${DateTime.now().microsecondsSinceEpoch}';
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _scheduleScrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }
}
