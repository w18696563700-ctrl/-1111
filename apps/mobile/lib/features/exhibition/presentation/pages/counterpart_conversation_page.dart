part of '../exhibition_trade_pages.dart';

class CounterpartConversationPage extends StatefulWidget {
  const CounterpartConversationPage({
    super.key,
    this.conversationId,
    this.projectId,
    this.threadId,
    this.projectListSearchToggleSignal,
    this.onChatWindowActiveChanged,
  });

  final String? conversationId;
  final String? projectId;
  final String? threadId;
  final ValueListenable<int>? projectListSearchToggleSignal;
  final ValueChanged<bool>? onChatWindowActiveChanged;

  @override
  State<CounterpartConversationPage> createState() =>
      _CounterpartConversationPageState();
}

class _CounterpartConversationPageState
    extends State<CounterpartConversationPage>
    with WidgetsBindingObserver {
  static const String _missingProjectContextMessage =
      '无法进入项目沟通，缺少项目上下文，请返回项目列表重新进入。';

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
  bool _chatWindowActiveNotified = false;
  String? _lastMarkedReadMessageId;
  final Map<String, ProjectCommunicationFilePreviewAccessView>
  _attachmentPreviewCache =
      <String, ProjectCommunicationFilePreviewAccessView>{};
  final Set<String> _loadingAttachmentPreviewKeys = <String>{};
  final Set<String> _failedAttachmentPreviewKeys = <String>{};
  CounterpartConversationResult<ProjectCommunicationWorkbenchView>?
  _workbenchResult;
  bool _loadingWorkbench = false;

  @override
  void initState() {
    super.initState();
    final initialProjectId = widget.projectId?.trim();
    final initialThreadId = widget.threadId?.trim();
    if (initialProjectId != null &&
        initialProjectId.isNotEmpty &&
        initialThreadId != null &&
        initialThreadId.isNotEmpty) {
      _selectedProjectId = initialProjectId;
    }
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    _notifyChatWindowActive(false);
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stopRealtime(waitForClose: false));
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
        unawaited(_stopRealtime(waitForClose: false));
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
        _notifyChatWindowActive(false);
        _workbenchResult = null;
        _loadingWorkbench = false;
        _drafts.clear();
      }
    });
    await _stopRealtime();
    final selectedProjectId = _selectedProjectId;
    if (result.state == AppPageState.content &&
        result.data != null &&
        selectedProjectId != null) {
      _notifyChatWindowActive(true);
      final selectedGroup = _selectedProjectGroup(result.data!);
      if (selectedGroup != null) {
        setState(() {
          _workbenchResult = null;
          _loadingWorkbench = true;
        });
      }
      await _loadThreadAndMessages(result.data!, projectId: selectedProjectId);
    }
  }

  void _notifyChatWindowActive(bool active) {
    if (_chatWindowActiveNotified == active) {
      return;
    }
    _chatWindowActiveNotified = active;
    widget.onChatWindowActiveChanged?.call(active);
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
      final selectedGroup = _selectedProjectGroup(data);
      if (selectedGroup != null) {
        unawaited(_loadProjectWorkbench(selectedGroup, threadResult.data!));
      }
      await _loadMessages(threadResult.data!);
      await _connectRealtime(threadResult.data!, data.counterpart);
    } else if (mounted) {
      setState(() => _loadingMessages = false);
    }
  }

  Future<void> _loadProjectWorkbench(
    CounterpartConversationProjectGroupView group,
    ProjectCommunicationThreadView thread,
  ) async {
    setState(() => _loadingWorkbench = true);
    final result = await CounterpartConversationConsumerLayer.instance
        .loadProjectCommunicationWorkbench(
          projectId: group.projectId,
          threadId: thread.threadId,
          counterpartOrganizationId: _result?.data?.counterpart.organizationId,
          bidId: _firstBidId(group),
        );
    if (!mounted || _selectedProjectId != group.projectId) {
      return;
    }
    setState(() {
      _workbenchResult = result;
      _loadingWorkbench = false;
    });
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
    _preloadImageAttachmentPreviews(result.data?.items);
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
    _preloadImageAttachmentPreviews(result.data?.items);
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

  Future<void> _stopRealtime({bool waitForClose = true}) async {
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
    if (closeFuture != null && waitForClose) {
      await closeFuture.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {},
      );
    } else if (closeFuture != null) {
      unawaited(closeFuture.catchError((_) {}));
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
    _preloadImageAttachmentPreviews(nextMessages);
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
  ) async {
    if (_lastMarkedReadMessageId == lastReadMessageId) {
      return;
    }
    final result = await CounterpartConversationConsumerLayer.instance
        .markProjectCommunicationReadCursor(
          threadId: thread.threadId,
          projectId: thread.projectId,
          lastReadMessageId: lastReadMessageId,
        );
    if (result.state != AppPageState.content) {
      return;
    }
    _lastMarkedReadMessageId = lastReadMessageId;
    await _reloadShellContextAfterRead();
    await _refreshConversationDetailAfterRead();
  }

  Future<void> _reloadShellContextAfterRead() async {
    try {
      await AppShellScope.read(context).reloadShellContext();
    } catch (_) {
      // Tests may mount this page without the full shell scope.
    }
  }

  Future<void> _refreshConversationDetailAfterRead() async {
    final result = await CounterpartConversationConsumerLayer.instance
        .loadDetail(
          conversationId: widget.conversationId,
          projectId: widget.projectId,
        );
    if (!mounted || result.state != AppPageState.content) {
      return;
    }
    setState(() {
      _result = result;
      final selectedProjectId = _selectedProjectId;
      if (selectedProjectId != null &&
          !_hasProjectGroup(result.data!, selectedProjectId)) {
        _selectedProjectId = null;
        _workbenchResult = null;
        _loadingWorkbench = false;
        _threadResult = null;
        _messageResult = null;
        _drafts.clear();
      }
    });
  }

  bool _canSendProjectCommunication() {
    return _threadResult?.data?.chatAvailability.canSendMessage == true;
  }

  String _chatLockMessage([ProjectCommunicationThreadView? thread]) {
    final availability =
        thread?.chatAvailability ?? _threadResult?.data?.chatAvailability;
    final text = availability?.lockReasonText?.trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
    return '当前项目沟通暂不可发送消息，请先完成业务待办。';
  }

  void _openChatRequiredAction() {
    final action = _threadResult?.data?.chatAvailability.requiredNextAction;
    final data = _result?.data;
    final group = data == null ? null : _selectedProjectGroup(data);
    if (action == null || action == 'none') {
      _showSnack('当前没有需要处理的业务待办。');
      return;
    }
    if (group == null) {
      _showSnack('无法进入项目沟通，缺少项目上下文，请返回项目列表重新进入。');
      return;
    }
    switch (action) {
      case 'review_bid_participation':
        final card = _firstBusinessCard(group, 'bid_participation_request');
        if (card == null) {
          _showSnack('当前没有可处理的参与竞标申请。');
          return;
        }
        _openBusinessCard(card);
        return;
      case 'confirm_publisher_materials':
        _openWorkbenchEntryList(<String>{
          'publisher_materials',
        }, title: '发布方资料确认');
        return;
      case 'submit_bid_materials':
        unawaited(_openBidSubmitAndRefresh(group.projectId));
        return;
      case 'confirm_bid_materials':
        _openWorkbenchEntryList(<String>{'bid_materials'}, title: '竞标资料确认');
        return;
      case 'complete_service_fee_authorization':
        final card = _firstServiceFeeAuthorizationCard(group);
        if (card == null) {
          _showSnack('预授权入口暂不可用，请刷新后重试。');
          return;
        }
        _openBusinessCard(card);
        return;
      case 'open_deal_confirmation':
        _openFirstPendingWorkbenchEntry(<String>{'deal_confirmation'});
        return;
      default:
        _showSnack(_chatLockMessage());
    }
  }

  void _openFirstPendingWorkbenchEntry(Set<String> groups) {
    final entries = _workbenchResult?.data?.entries;
    final wantsDealConfirmation = groups.contains('deal_confirmation');
    if (entries == null) {
      _showSnack(
        wantsDealConfirmation ? '后续承接状态暂不可读，请稍后重试。' : '资料确认单状态暂不可读，请稍后重试。',
      );
      return;
    }
    ProjectCommunicationWorkbenchEntryView? entry;
    for (final item in entries) {
      if (!groups.contains(item.group)) {
        continue;
      }
      if (item.badgeCount > 0 ||
          item.reviewState == 'pending_review' ||
          item.actionState == 'enabled') {
        entry = item;
        break;
      }
    }
    if (entry == null) {
      _showSnack(wantsDealConfirmation ? '当前没有可处理的成交确认项。' : '当前没有可处理的资料确认项。');
      return;
    }
    _openWorkbenchEntry(entry);
  }

  void _openWorkbenchEntryList(Set<String> groups, {required String title}) {
    _showProjectCommunicationWorkbenchEntryListSheet(
      context: context,
      result: _workbenchResult,
      groups: groups,
      title: title,
      onUnavailable: _showSnack,
      onOpenEntry: (entry) {
        if (mounted) {
          _openWorkbenchEntry(entry);
        }
      },
    );
  }

  Future<void> _openBidSubmitAndRefresh(String projectId) async {
    await Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.bidSubmitWithProjectId(projectId));
    if (!mounted) {
      return;
    }
    await _load();
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
    if (!thread.chatAvailability.canSendMessage) {
      _showSnack(_chatLockMessage(thread));
      return;
    }
    if (_shouldShowContactSoftPrompt(body)) {
      final shouldContinue = await _showContactSoftPrompt();
      if (!shouldContinue) {
        return;
      }
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

  Future<void> _sendAttachmentMessage({required bool imageOnly}) async {
    final thread = _threadResult?.data;
    if (thread == null || _sending) {
      return;
    }
    if (!thread.chatAvailability.canSendMessage) {
      _showSnack(_chatLockMessage(thread));
      return;
    }
    final outcome = await _pickAndUploadProjectCommunicationAttachment(
      projectId: thread.projectId,
      imageOnly: imageOnly,
    );
    if (!mounted || outcome == null) {
      return;
    }
    if (!outcome.isSuccess) {
      _showSnack(outcome.message);
      return;
    }
    final caption = _messageController.text.trim();
    final attachment = outcome.attachment!;
    final draft = _DraftProjectCommunicationMessage(
      clientMessageId: _newClientMessageId(),
      body: caption,
      createdAt: DateTime.now(),
      state: _DraftProjectCommunicationState.sending,
      messageKind: attachment.category == 'image' ? 'image' : 'file',
      attachment: attachment,
    );
    setState(() {
      _messageController.clear();
      _drafts.add(draft);
    });
    _scheduleScrollToBottom();
    await _sendDraft(draft);
  }

  Future<void> _retryDraft(_DraftProjectCommunicationMessage draft) {
    if (!_canSendProjectCommunication()) {
      _showSnack(_chatLockMessage());
      return Future<void>.value();
    }
    return _sendDraft(
      draft.copyWith(state: _DraftProjectCommunicationState.sending),
    );
  }

  Future<void> _sendDraft(_DraftProjectCommunicationMessage draft) async {
    final thread = _threadResult?.data;
    if (thread == null || _sending) {
      return;
    }
    if (!thread.chatAvailability.canSendMessage) {
      _showSnack(_chatLockMessage(thread));
      _replaceDraft(
        draft.copyWith(
          state: _DraftProjectCommunicationState.failed,
          errorMessage: _chatLockMessage(thread),
        ),
      );
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
          messageKind: draft.messageKind,
          payload: _draftPayload(draft),
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

  Map<String, Object?>? _draftPayload(_DraftProjectCommunicationMessage draft) {
    final attachment = draft.attachment;
    if (attachment != null) {
      return <String, Object?>{
        'attachment': <String, Object?>{
          'fileAssetId': attachment.fileAssetId,
          'fileName': attachment.fileName,
          'mimeType': attachment.mimeType,
          'size': attachment.size,
          'category': attachment.category,
        },
      };
    }
    final confirmation = draft.confirmation;
    if (confirmation != null) {
      return <String, Object?>{
        'confirmation': <String, Object?>{
          'confirmationType': confirmation.confirmationType,
          'title': confirmation.title,
          'summary': confirmation.summary,
          'status': confirmation.status,
        },
      };
    }
    return null;
  }

  Future<_ProjectCommunicationUploadOutcome?>
  _pickAndUploadProjectCommunicationAttachment({
    required String projectId,
    required bool imageOnly,
  }) async {
    _showSnack(imageOnly ? '请选择要发送的图片。' : '请选择要发送的附件。');
    late final ProjectAttachmentDraft? draft;
    try {
      draft = await _pickProjectAttachmentDraft(imageOnly: imageOnly);
    } catch (_) {
      return _ProjectCommunicationUploadOutcome(
        message: imageOnly
            ? '当前设备暂时打不开相册，请检查相册权限后再试。'
            : '当前设备暂时打不开文件选择器，请稍后再试。',
      );
    }
    if (draft == null) {
      return _ProjectCommunicationUploadOutcome(
        message: imageOnly ? '当前没有选择图片。' : '当前没有选择文件。',
      );
    }
    final resolved = _resolveProjectAttachmentDraft(draft);
    if (resolved == null) {
      return const _ProjectCommunicationUploadOutcome(message: '当前文件格式暂不支持。');
    }
    final isImage = resolved.mimeType.toLowerCase().startsWith('image/');
    if (imageOnly && !isImage) {
      return const _ProjectCommunicationUploadOutcome(message: '图片入口仅支持图片文件。');
    }
    if (imageOnly) {
      final confirmed = await _confirmProjectCommunicationImageSend(resolved);
      if (!mounted || !confirmed) {
        return null;
      }
    }
    _showSnack('正在申请上传策略。');
    final init = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: 'project',
        businessId: projectId,
        fileKind: 'project_communication_attachment',
        mimeType: resolved.mimeType,
        size: resolved.sizeInBytes,
        checksum: resolved.checksum,
      ),
    );
    final directive = init.directive;
    if (init.state != AppUploadState.signedReady || directive == null) {
      return _ProjectCommunicationUploadOutcome(
        message: init.message ?? '当前上传初始化未完成，请稍后重试。',
      );
    }
    _showSnack('正在上传 ${resolved.fileName}。');
    final direct = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: resolved.bytes,
    );
    final confirmDirective = direct.directive;
    if (direct.state != AppUploadState.uploadConfirming ||
        confirmDirective == null) {
      return _ProjectCommunicationUploadOutcome(
        message: direct.message ?? '当前文件直传未完成，请重新上传。',
      );
    }
    _showSnack('正在确认文件。');
    final confirm = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: confirmDirective,
    );
    final fileAssetId = confirm.fileAssetId?.trim();
    if (confirm.state != AppUploadState.uploadBound ||
        fileAssetId == null ||
        fileAssetId.isEmpty) {
      return _ProjectCommunicationUploadOutcome(
        message: confirm.message ?? '当前文件确认失败，请稍后重试。',
      );
    }
    return _ProjectCommunicationUploadOutcome(
      message: '${resolved.fileName} 已上传。',
      attachment: ProjectCommunicationAttachmentView(
        fileAssetId: fileAssetId,
        fileName: resolved.fileName,
        mimeType: resolved.mimeType,
        size: resolved.sizeInBytes,
        category: isImage ? 'image' : 'file',
      ),
    );
  }

  Future<bool> _confirmProjectCommunicationImageSend(
    _ResolvedProjectAttachmentDraft draft,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(18, 8, 18, 18 + bottomInset),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '发送这张图片？',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    Uint8List.fromList(draft.bytes),
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => SizedBox(
                      height: 160,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '图片 · ${_formatBytes(draft.sizeInBytes)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('发送图片'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result == true;
  }

  bool _shouldShowContactSoftPrompt(String body) {
    final normalized = body.toLowerCase();
    if (RegExp(r'1[3-9]\d{9}').hasMatch(normalized)) {
      return true;
    }
    return normalized.contains('微信') ||
        normalized.contains('qq') ||
        normalized.contains('联系我') ||
        normalized.contains('加我') ||
        normalized.contains('电话多少');
  }

  Future<bool> _showContactSoftPrompt() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('建议优先在平台内继续沟通'),
        content: const Text('平台内沟通更便于留存关键记录，报价、材质、排期等事项建议优先保留在项目沟通中。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('返回修改'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('继续发送'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openProjectCommunication(
    CounterpartConversationProjectGroupView group,
  ) async {
    final data = _result?.data;
    if (group.projectId.trim().isEmpty ||
        data == null ||
        data.counterpart.organizationId.trim().isEmpty) {
      _showSnack(_missingProjectContextMessage);
      return;
    }
    await _stopRealtime();
    if (!mounted) {
      return;
    }
    _messageController.clear();
    setState(() {
      _selectedProjectId = group.projectId;
      _workbenchResult = null;
      _loadingWorkbench = true;
      _threadResult = null;
      _messageResult = null;
      _lastMarkedReadMessageId = null;
      _drafts.clear();
      _loadingThread = true;
      _loadingMessages = true;
    });
    _notifyChatWindowActive(true);
    _scheduleScrollToTop();
    await _loadThreadAndMessages(data, projectId: group.projectId);
    if (!mounted) {
      return;
    }
    if (_selectedProjectId == group.projectId &&
        _threadResult?.state != AppPageState.content) {
      final message = _threadResult?.message ?? _missingProjectContextMessage;
      await _backToProjectList();
      if (mounted) {
        _showSnack(
          message.contains('threadId')
              ? _missingProjectContextMessage
              : message,
        );
      }
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
      _workbenchResult = null;
      _loadingWorkbench = false;
      _threadResult = null;
      _messageResult = null;
      _lastMarkedReadMessageId = null;
      _drafts.clear();
      _loadingThread = false;
      _loadingMessages = false;
    });
    _notifyChatWindowActive(false);
    _scheduleScrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    final thread = _threadResult?.data;
    final selectedGroup = data == null ? null : _selectedProjectGroup(data);
    final selectedOrderId = selectedGroup == null
        ? null
        : _orderIdFromConversationGroup(selectedGroup);
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
              if (_selectedProjectId != null &&
                  thread != null &&
                  selectedGroup != null) ...<Widget>[
                _SelectedProjectBusinessEntrypoints(
                  group: selectedGroup,
                  participationCard: _firstBusinessCard(
                    selectedGroup,
                    'bid_participation_request',
                  ),
                  orderId: selectedOrderId,
                  loadingWorkbench: _loadingWorkbench,
                  workbenchResult: _workbenchResult,
                  onOpenNameAccess: _openBusinessCard,
                  onOpenContinuation: () =>
                      _openContinuationPanel(selectedGroup),
                  onOpenProjectAlbum: () => _openProjectAlbum(selectedGroup),
                  onOpenMaterialConfirmation: () => _openWorkbenchEntryList(
                    <String>{'publisher_materials', 'bid_materials'},
                    title: '资料确认单',
                  ),
                ),
                _ProjectCommunicationComposer(
                  controller: _messageController,
                  enabled: !_loadingThread,
                  canSendMessage: _canSendProjectCommunication(),
                  sending: _sending,
                  lockReasonText: _chatLockMessage(),
                  requiredNextAction:
                      _threadResult?.data?.chatAvailability.requiredNextAction,
                  onOpenRequiredAction: _openChatRequiredAction,
                  onSend: _sendCurrentMessage,
                  onAttachFile: () => _sendAttachmentMessage(imageOnly: false),
                  onAttachImage: () => _sendAttachmentMessage(imageOnly: true),
                ),
              ],
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
        _CounterpartProjectEntryList(
          data: data,
          groups: groups,
          searchToggleSignal: widget.projectListSearchToggleSignal,
          onOpenSubjectCard: () => _openSubjectCard(data),
          canOpenSubjectCard: _canOpenSubjectCard(data),
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
      _ProjectConversationHeaderCard(
        data: data,
        group: selectedGroup,
        thread: thread,
        currentOrganizationId: _currentOrganizationId(context),
        currentDisplayName: _currentDisplayName(context),
        currentAvatarUrl: _currentAvatarUrl(context),
        onBackToProjectList: _backToProjectList,
        onOpenSubjectCard: () => _openSubjectCard(data),
        canOpenSubjectCard: _canOpenSubjectCard(data),
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
          currentDisplayName: _currentDisplayName(context),
          currentAvatarUrl: _currentAvatarUrl(context),
          counterpart: data.counterpart,
          attachmentPreviewForMessage: _previewForMessage,
          attachmentPreviewLoadingForMessage: _previewLoadingForMessage,
          onRetryDraft: _retryDraft,
          onRefreshMessages: thread == null
              ? null
              : () => _loadMessages(thread),
          onPreviewAttachment: _openAttachmentPreview,
          onOpenConfirmationSoftLink: _openConfirmationSoftLink,
          onOpenBusinessAction: _openMessageBusinessAction,
        ),
      ),
    ];
  }

  Widget _buildFailureCard(
    CounterpartConversationResult<CounterpartConversationDetailView>? result,
  ) {
    if (_isStaleCounterpartContainerFailure(result)) {
      return _ActionCard(
        title: '项目沟通入口已失效',
        children: <Widget>[
          const _StateMessage(title: '受控提示', body: '入口已失效，可从主体项目列表重新进入。'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.tonal(
                onPressed: _returnToPreviousEntry,
                child: const Text('返回消息列表'),
              ),
              OutlinedButton(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ],
      );
    }
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

  bool _isStaleCounterpartContainerFailure(
    CounterpartConversationResult<CounterpartConversationDetailView>? result,
  ) {
    final errorCode = result?.errorCode ?? '';
    final message = result?.message ?? '';
    return errorCode.contains('COUNTERPART_CONVERSATION_UNAVAILABLE') ||
        message.contains('COUNTERPART_CONVERSATION_UNAVAILABLE') ||
        message.contains('当前对方沟通容器暂不可用');
  }

  void _returnToPreviousEntry() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('请从消息页主体项目列表重新进入。')));
  }

  void _openBusinessCard(CounterpartConversationBusinessCardView card) {
    final target = card.detailRouteTarget ?? _fallbackRouteTarget(card);
    if (target == null) {
      _showSnack('当前业务卡暂时没有可打开的详情。');
      return;
    }
    Navigator.of(context).pushNamed(target.routeLocation);
  }

  void _openMessageBusinessAction(ProjectCommunicationMessageView message) {
    final target = message.routeTarget;
    if (target != null) {
      Navigator.of(context).pushNamed(target.routeLocation);
      return;
    }
    if (message.requiredNextAction == 'complete_service_fee_authorization') {
      _openChatRequiredAction();
      return;
    }
    _showSnack('当前系统提醒暂时没有可打开的业务入口。');
  }

  void _openOrderDetail(CounterpartConversationProjectGroupView group) {
    final orderCard = _firstBusinessCard(group, 'project_order');
    final orderTarget =
        orderCard?.detailRouteTarget ?? _fallbackOrderTarget(group);
    if (orderTarget == null) {
      _showSnack('当前项目暂时没有可打开的后续承接状态。');
      return;
    }
    Navigator.of(context).pushNamed(orderTarget.routeLocation);
  }

  void _openContinuationPanel(CounterpartConversationProjectGroupView group) {
    final entries =
        _workbenchResult?.data?.entries
            .where(_isDealWorkbenchEntry)
            .toList(growable: false) ??
        const <ProjectCommunicationWorkbenchEntryView>[];
    final amountEntry = entries
        .where(
          (entry) => entry.entryKey == 'final_confirmed_amount_confirmation',
        )
        .firstOrNull;
    final contractEntry = entries
        .where((entry) => entry.entryKey == 'contract_confirmation')
        .firstOrNull;
    final orderCard = _firstBusinessCard(group, 'project_order');
    final orderTarget =
        orderCard?.detailRouteTarget ?? _fallbackOrderTarget(group);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '后续承接',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '订单种子、合同文件、最终成交金额分层承接；最终金额只以双方确认后的 Server finalConfirmedAmount 为准。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ContinuationActionTile(
                    icon: Icons.price_check_outlined,
                    title: '最终成交金额确认',
                    summary: amountEntry == null
                        ? '当前暂无可处理的最终成交确认入口。'
                        : '双方确认完成后才形成正式合同金额。',
                    badgeCount:
                        amountEntry?.badgeCount ??
                        group.businessTodoSummary.dealConfirmationPendingCount,
                    enabled: amountEntry != null,
                    disabledReason: amountEntry?.disabledReason,
                    onTap: amountEntry == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            unawaited(_openDealConfirmationEntry(amountEntry));
                          },
                  ),
                  const SizedBox(height: 10),
                  _ContinuationActionTile(
                    icon: Icons.description_outlined,
                    title: '合同文件',
                    summary: contractEntry == null
                        ? '合同文件入口暂未开放，不能替代最终金额确认。'
                        : '合同文件是成交确认依据之一。',
                    badgeCount: contractEntry?.badgeCount ?? 0,
                    enabled: contractEntry != null,
                    disabledReason: contractEntry?.disabledReason,
                    onTap: contractEntry == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            unawaited(
                              _openDealConfirmationEntry(contractEntry),
                            );
                          },
                  ),
                  const SizedBox(height: 10),
                  _ContinuationActionTile(
                    icon: Icons.receipt_long_outlined,
                    title: '订单种子',
                    summary: orderTarget == null
                        ? '当前暂无订单种子，不能当作正式成交。'
                        : '订单种子金额只是中标报价参考，不是最终合同金额。',
                    enabled: orderTarget != null,
                    onTap: orderTarget == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            Navigator.of(
                              context,
                            ).pushNamed(orderTarget.routeLocation);
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openProjectAlbum(CounterpartConversationProjectGroupView group) {
    final threadId = _threadResult?.data?.threadId.trim();
    if (threadId == null || threadId.isEmpty) {
      _showSnack('无法进入项目相册，缺少项目沟通上下文，请返回项目列表重新进入。');
      return;
    }
    final base = Uri.parse(
      ExhibitionRoutes.projectAlbumWithProjectId(group.projectId),
    );
    final location = base
        .replace(
          queryParameters: <String, String>{
            ...base.queryParameters,
            'threadId': threadId,
          },
        )
        .toString();
    Navigator.of(context).pushNamed(location);
  }

  void _preloadImageAttachmentPreviews(
    List<ProjectCommunicationMessageView>? messages,
  ) {
    if (messages == null || messages.isEmpty) {
      return;
    }
    for (final message in messages) {
      final attachment = message.attachment;
      if (attachment == null || !_isProjectCommunicationImage(attachment)) {
        continue;
      }
      final key = _attachmentPreviewKey(message);
      if (_attachmentPreviewCache.containsKey(key) ||
          _loadingAttachmentPreviewKeys.contains(key) ||
          _failedAttachmentPreviewKeys.contains(key)) {
        continue;
      }
      _loadingAttachmentPreviewKeys.add(key);
      unawaited(_loadAttachmentPreviewForThumbnail(message, key));
    }
  }

  Future<void> _loadAttachmentPreviewForThumbnail(
    ProjectCommunicationMessageView message,
    String key,
  ) async {
    final result = await CounterpartConversationConsumerLayer.instance
        .loadProjectCommunicationFilePreviewAccess(
          projectId: message.projectId,
          threadId: message.threadId,
          fileAssetId: message.attachment?.fileAssetId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _loadingAttachmentPreviewKeys.remove(key);
      final data = result.data;
      if (result.state == AppPageState.content && data != null) {
        _attachmentPreviewCache[key] = data;
        return;
      }
      _failedAttachmentPreviewKeys.add(key);
    });
  }

  ProjectCommunicationFilePreviewAccessView? _previewForMessage(
    ProjectCommunicationMessageView message,
  ) {
    return _attachmentPreviewCache[_attachmentPreviewKey(message)];
  }

  bool _previewLoadingForMessage(ProjectCommunicationMessageView message) {
    return _loadingAttachmentPreviewKeys.contains(
      _attachmentPreviewKey(message),
    );
  }

  String _attachmentPreviewKey(ProjectCommunicationMessageView message) {
    return '${message.projectId}::${message.threadId}::${message.attachment?.fileAssetId ?? ''}';
  }

  bool _isProjectCommunicationImage(ProjectCommunicationAttachmentView item) {
    return item.category == 'image' ||
        item.mimeType.toLowerCase().startsWith('image/');
  }

  Future<void> _openAttachmentPreview(
    ProjectCommunicationMessageView message,
  ) async {
    final attachment = message.attachment;
    if (attachment == null) {
      return;
    }
    final key = _attachmentPreviewKey(message);
    var data = _attachmentPreviewCache[key];
    if (data == null) {
      final result = await CounterpartConversationConsumerLayer.instance
          .loadProjectCommunicationFilePreviewAccess(
            projectId: message.projectId,
            threadId: message.threadId,
            fileAssetId: attachment.fileAssetId,
          );
      if (!mounted) {
        return;
      }
      data = result.data;
      if (result.state != AppPageState.content || data == null) {
        _showSnack(result.message ?? '当前附件暂不可预览。');
        return;
      }
      _attachmentPreviewCache[key] = data;
    }

    final accessUrl = data.accessUrl?.trim();
    if (_isProjectCommunicationImage(attachment) &&
        data.canPreview &&
        data.previewType == 'image' &&
        accessUrl != null &&
        accessUrl.isNotEmpty) {
      await _showProjectAttachmentNetworkImagePreviewDialog(
        context,
        fileName: data.fileName ?? attachment.fileName,
        imageUrl: accessUrl,
      );
      return;
    }
    await _showAttachmentPreviewDialog(data);
  }

  Future<void> _showAttachmentPreviewDialog(
    ProjectCommunicationFilePreviewAccessView preview,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final canPreview = preview.canPreview && preview.accessUrl != null;
        return AlertDialog(
          title: const Text('附件预览'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                preview.fileName ?? preview.fileAssetId,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canPreview
                    ? '${_previewTypeLabel(preview.previewType)}预览链接已就绪。'
                    : '当前文件暂不支持在线预览，可保留下载入口。',
              ),
              if (preview.mimeType != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  preview.mimeType!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            if (canPreview)
              FilledButton(
                onPressed: () {
                  final url = preview.accessUrl;
                  if (url != null) {
                    unawaited(launchUrlString(url));
                  }
                },
                child: const Text('打开预览'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openConfirmationSoftLink(
    ProjectCommunicationMessageView message,
  ) async {
    final result = await CounterpartConversationConsumerLayer.instance
        .loadProjectCommunicationConfirmationSoftLink(
          projectId: message.projectId,
          threadId: message.threadId,
          messageId: message.messageId,
        );
    if (!mounted) {
      return;
    }
    final data = result.data;
    if (result.state != AppPageState.content || data == null) {
      _showSnack(result.message ?? '当前确认卡入口暂不可用。');
      return;
    }
    final routeLocation = data.routeTarget?.routeLocation;
    if (routeLocation == null || routeLocation.isEmpty) {
      _showSnack(
        '${_confirmationSoftLinkLabel(data.confirmationType)}暂未开放独立页面。',
      );
      return;
    }
    Navigator.of(context).pushNamed(routeLocation);
  }

  void _openWorkbenchEntry(ProjectCommunicationWorkbenchEntryView entry) {
    if (!_hasWorkbenchEntryContext(entry)) {
      _showSnack('无法进入资料确认单，缺少项目沟通上下文，请返回项目列表重新进入。');
      return;
    }
    if (entry.group == 'deal_confirmation') {
      _openDealConfirmationEntry(entry);
      return;
    }
    if (!_hasMaterialReviewRouteTarget(entry)) {
      _showSnack('资料确认入口暂不可用，请刷新后重试。');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ProjectCommunicationMaterialReviewDetailPage(
          entry: entry,
          onConfirm: _submitWorkbenchConfirm,
          onFeedback: _submitWorkbenchFeedback,
          onOpenPublisherSupplement: _openPublisherSupplementPage,
          onOpenBidMaterialSupplement: _openBidMaterialSupplementPage,
        ),
      ),
    );
  }

  void _openPublisherSupplementPage(
    ProjectCommunicationWorkbenchEntryView entry,
  ) {
    final projectId = entry.projectId.trim();
    if (projectId.isEmpty) {
      _showSnack('无法进入补充资料页，缺少项目上下文。');
      return;
    }
    Navigator.of(context).pushNamed(
      ExhibitionRoutes.myProjectDetailWithProjectId(
        projectId,
        stage: 'published',
        focus: 'attachments',
      ),
    );
  }

  Future<void> _openBidMaterialSupplementPage(
    ProjectCommunicationWorkbenchEntryView entry,
  ) async {
    final projectId = entry.projectId.trim();
    if (projectId.isEmpty) {
      _showSnack('无法进入补充竞标资料页，缺少项目上下文。');
      return;
    }
    await _openBidSubmitAndRefresh(projectId);
  }

  bool _hasWorkbenchEntryContext(ProjectCommunicationWorkbenchEntryView entry) {
    return entry.projectId.trim().isNotEmpty &&
        entry.threadId.trim().isNotEmpty &&
        entry.truthAnchor.projectId.trim().isNotEmpty &&
        entry.truthAnchor.threadId.trim().isNotEmpty;
  }

  bool _hasMaterialReviewRouteTarget(
    ProjectCommunicationWorkbenchEntryView entry,
  ) {
    final routeTarget = entry.routeTarget;
    if (routeTarget == null ||
        routeTarget.actionKey != 'project_communication_material_review.open' ||
        routeTarget.canonicalPath.trim().isEmpty) {
      return false;
    }
    final projectId = routeTarget.params['projectId']?.trim();
    final threadId = routeTarget.params['threadId']?.trim();
    final entryKey = routeTarget.params['entryKey']?.trim();
    final bidId = routeTarget.params['bidId']?.trim();
    if (projectId == null ||
        projectId.isEmpty ||
        threadId == null ||
        threadId.isEmpty ||
        entryKey == null ||
        entryKey.isEmpty) {
      return false;
    }
    if (entry.group == 'bid_materials' &&
        entry.bidId?.trim().isNotEmpty == true &&
        (bidId == null || bidId.isEmpty)) {
      return false;
    }
    return true;
  }

  Future<void> _openDealConfirmationEntry(
    ProjectCommunicationWorkbenchEntryView entry,
  ) {
    final canonicalPath =
        entry.routeTarget?.canonicalPath ??
        ExhibitionCanonicalPaths.projectDealConfirmations(entry.projectId);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '请上传合同文件并填写最终成交价；双方确认完成后，Server 才会持久化 finalConfirmedAmount。',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前入口只承接 deal-confirmations，不触发支付、服务费扣费或 /contract/confirm。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoBand(
                    icon: Icons.verified_outlined,
                    text: '唯一路径：$canonicalPath',
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('知道了'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _submitWorkbenchConfirm(
    ProjectCommunicationWorkbenchEntryView entry,
  ) async {
    return _submitWorkbenchReview(entry, reviewAction: 'confirm');
  }

  Future<bool> _submitWorkbenchFeedback(
    ProjectCommunicationWorkbenchEntryView entry,
    String feedbackText,
  ) async {
    return _submitWorkbenchReview(
      entry,
      reviewAction: 'request_supplement',
      feedbackText: feedbackText,
    );
  }

  Future<bool> _submitWorkbenchReview(
    ProjectCommunicationWorkbenchEntryView entry, {
    required String reviewAction,
    String? feedbackText,
  }) async {
    final result = await CounterpartConversationConsumerLayer.instance
        .submitProjectCommunicationMaterialReview(
          projectId: entry.projectId,
          threadId: entry.threadId,
          bidId: entry.bidId,
          entryKey: entry.entryKey,
          reviewAction: reviewAction,
          feedbackText: feedbackText,
          sourceVersionToken: entry.truthAnchor.sourceVersionToken,
          idempotencyKey:
              '${entry.entryKey}-$reviewAction-${DateTime.now().microsecondsSinceEpoch}',
        );
    if (result.state != AppPageState.content || result.data == null) {
      _showSnack(result.message ?? '资料确认提交失败。');
      return false;
    }
    final response = result.data!;
    final previousWorkbench = _workbenchResult?.data;
    if (previousWorkbench == null) {
      _showSnack('当前资料确认状态暂不可读，请刷新后重试。');
      return false;
    }
    setState(() {
      _workbenchResult =
          CounterpartConversationResult<ProjectCommunicationWorkbenchView>(
            state: AppPageState.content,
            method: result.method,
            path: result.path,
            data: ProjectCommunicationWorkbenchView(
              projectId: response.projectId,
              threadId: response.threadId,
              viewerRole: response.viewerRole,
              businessTodoSummary: previousWorkbench.businessTodoSummary,
              chatAvailability: previousWorkbench.chatAvailability,
              entries:
                  response.entries ?? _replaceWorkbenchEntry(response.entry),
              generatedAt: response.updatedAt,
            ),
          );
    });
    final currentDetail = _result?.data;
    final currentThread = _threadResult?.data;
    final selectedGroup = currentDetail == null
        ? null
        : _selectedProjectGroup(currentDetail);
    if (currentDetail != null && selectedGroup != null) {
      await _loadThreadAndMessages(
        currentDetail,
        projectId: selectedGroup.projectId,
      );
    } else if (currentThread != null && selectedGroup != null) {
      await _loadProjectWorkbench(selectedGroup, currentThread);
    }
    _showSnack(reviewAction == 'confirm' ? '已确认。' : '反馈已提交。');
    return true;
  }

  List<ProjectCommunicationWorkbenchEntryView> _replaceWorkbenchEntry(
    ProjectCommunicationWorkbenchEntryView entry,
  ) {
    final current = _workbenchResult?.data?.entries;
    if (current == null) {
      return <ProjectCommunicationWorkbenchEntryView>[entry];
    }
    return current
        .map((item) => item.entryKey == entry.entryKey ? entry : item)
        .toList(growable: false);
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
            projectPublishedAt: group.projectPublishedAt,
            projectUpdatedAt: group.projectUpdatedAt,
            latestActivityAt: group.latestActivityAt,
            latestUnreadMessageAt: group.latestUnreadMessageAt,
            projectUnreadCount: group.projectUnreadCount,
            hasProjectUnread: group.hasProjectUnread,
            businessTodoSummary: group.businessTodoSummary,
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

  CounterpartConversationBusinessCardView? _firstServiceFeeAuthorizationCard(
    CounterpartConversationProjectGroupView group,
  ) {
    for (final card in group.cards) {
      final routeAction = card.detailRouteTarget?.actionKey;
      if (routeAction == 'bid_service_fee_authorization.open' ||
          card.cardType == 'bid_service_fee_authorization' ||
          card.truthAnchor.truthType == 'bid_service_fee_authorization') {
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

  String? _currentDisplayName(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<AppShellScope>();
    final scope = element?.widget as AppShellScope?;
    return scope?.notifier?.snapshot.shellContext.displayName;
  }

  String? _currentAvatarUrl(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<AppShellScope>();
    final scope = element?.widget as AppShellScope?;
    return scope?.notifier?.snapshot.shellContext.avatarUrl;
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

class _ProjectCommunicationUploadOutcome {
  const _ProjectCommunicationUploadOutcome({
    required this.message,
    this.attachment,
  });

  final String message;
  final ProjectCommunicationAttachmentView? attachment;

  bool get isSuccess => attachment != null;
}
