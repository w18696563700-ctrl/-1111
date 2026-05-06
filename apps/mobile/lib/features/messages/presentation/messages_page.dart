import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_visible_copy.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shared/ui/safe_remote_image.dart';

part 'messages_page_support.dart';

enum _MessagesInteractionTab { replies, likes, follows }

enum _MessagesPrimaryTab { projectCommunication, forumInteraction }

enum _MessagesNotificationFilter {
  all,
  projectCommunication,
  forumInteraction,
  businessTodo,
  system,
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key, this.refreshSignal, this.entrySignal});

  final ValueListenable<int>? refreshSignal;
  final ValueListenable<int>? entrySignal;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final Map<
    _MessagesInteractionTab,
    ForumReadResult<ForumPagedCollectionView<ForumInteractionInboxItemView>>
  >
  _results =
      <
        _MessagesInteractionTab,
        ForumReadResult<ForumPagedCollectionView<ForumInteractionInboxItemView>>
      >{};
  _MessagesInteractionTab? _selectedTab;
  _MessagesPrimaryTab _selectedPrimaryTab =
      _MessagesPrimaryTab.projectCommunication;
  late final PageController _primaryPageController;
  MessageInteractionListResult? _projectCommunicationResult;
  AppNotificationListResult? _notificationResult;
  ValueListenable<int>? _refreshSignal;
  ValueListenable<int>? _entrySignal;
  int _lastRefreshTick = 0;
  int _lastEntryTick = 0;
  int _latestLoadToken = 0;
  int _latestReminderLoadToken = 0;
  bool _loading = false;
  bool _projectCommunicationLoading = false;
  bool _notificationLoading = false;
  bool _notificationCenterExpanded = false;
  _MessagesNotificationFilter _selectedNotificationFilter =
      _MessagesNotificationFilter.all;

  @override
  void initState() {
    super.initState();
    _primaryPageController = PageController();
    _bindRefreshSignal(widget.refreshSignal);
    _bindEntrySignal(widget.entrySignal);
    _loadNotifications();
    _loadProjectCommunication();
  }

  @override
  void didUpdateWidget(covariant MessagesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _bindRefreshSignal(widget.refreshSignal);
    }
    if (oldWidget.entrySignal != widget.entrySignal) {
      _bindEntrySignal(widget.entrySignal);
    }
  }

  @override
  void dispose() {
    _refreshSignal?.removeListener(_handleRefreshSignal);
    _entrySignal?.removeListener(_handleEntrySignal);
    _primaryPageController.dispose();
    super.dispose();
  }

  void _bindRefreshSignal(ValueListenable<int>? signal) {
    _refreshSignal?.removeListener(_handleRefreshSignal);
    _refreshSignal = signal;
    _lastRefreshTick = signal?.value ?? 0;
    _refreshSignal?.addListener(_handleRefreshSignal);
  }

  void _bindEntrySignal(ValueListenable<int>? signal) {
    _entrySignal?.removeListener(_handleEntrySignal);
    _entrySignal = signal;
    _lastEntryTick = signal?.value ?? 0;
    _entrySignal?.addListener(_handleEntrySignal);
  }

  void _handleRefreshSignal() {
    final signal = _refreshSignal;
    if (signal == null) {
      return;
    }
    final tick = signal.value;
    if (tick == _lastRefreshTick) {
      return;
    }
    _lastRefreshTick = tick;
    _refreshAll(showLoading: false);
  }

  void _handleEntrySignal() {
    final signal = _entrySignal;
    if (signal == null) {
      return;
    }
    final tick = signal.value;
    if (tick == _lastEntryTick) {
      return;
    }
    _lastEntryTick = tick;
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedTab = null;
      _selectedPrimaryTab = _MessagesPrimaryTab.projectCommunication;
      _loading = false;
    });
    if (_primaryPageController.hasClients) {
      _primaryPageController.jumpToPage(0);
    }
  }

  Future<void> _refreshAll({bool showLoading = true}) async {
    final tasks = <Future<void>>[
      _loadNotifications(showLoading: showLoading),
      _loadProjectCommunication(showLoading: showLoading),
    ];
    final selectedTab = _selectedTab;
    if (selectedTab != null) {
      tasks.add(_load(tab: selectedTab, showLoading: showLoading));
    }
    await Future.wait<void>(tasks);
  }

  Future<void> _load({
    required _MessagesInteractionTab tab,
    bool showLoading = true,
  }) async {
    final requestedTab = tab;
    final loadToken = ++_latestLoadToken;
    final shouldShowLoading =
        showLoading || !_results.containsKey(requestedTab);
    if (shouldShowLoading) {
      setState(() => _loading = true);
    }
    final result = await ForumConsumerLayer.instance.loadInteractionInbox(
      tab: _tabKey(requestedTab),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _results[requestedTab] = result;
      if (loadToken == _latestLoadToken) {
        _loading = false;
      }
    });
  }

  Future<void> _loadProjectCommunication({bool showLoading = true}) async {
    final loadToken = ++_latestReminderLoadToken;
    final shouldShowLoading =
        showLoading || _projectCommunicationResult == null;
    if (shouldShowLoading) {
      setState(() => _projectCommunicationLoading = true);
    }
    final result = await MessagesConsumerLayer.instance.loadInteractions();
    if (!mounted) {
      return;
    }
    setState(() {
      if (loadToken == _latestReminderLoadToken) {
        _projectCommunicationResult = result;
        _projectCommunicationLoading = false;
      }
    });
  }

  Future<void> _loadNotifications({bool showLoading = true}) async {
    final shouldShowLoading = showLoading || _notificationResult == null;
    if (shouldShowLoading) {
      setState(() => _notificationLoading = true);
    }
    final result = await MessagesConsumerLayer.instance.loadNotifications(
      source: _notificationFilterQuery(_selectedNotificationFilter),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _notificationResult = result;
      _notificationLoading = false;
    });
    _syncShellMessagesUnreadBadge(result);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = _selectedTab;
    final result = selectedTab == null ? null : _results[selectedTab];
    final state = _loading ? AppPageState.loading : result?.state;
    final items =
        result?.data?.items ?? const <ForumInteractionInboxItemView>[];
    final projectCommunicationItems = _projectCommunicationItems(
      _projectCommunicationResult,
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: _MessagesTopBar(
            unreadCount: _notificationUnreadCount(_notificationResult),
            loading: _notificationLoading,
            notificationExpanded: _notificationCenterExpanded,
            onToggleNotifications: () {
              setState(
                () =>
                    _notificationCenterExpanded = !_notificationCenterExpanded,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: _MessagesPrimaryNavigation(
            selectedTab: _selectedPrimaryTab,
            onSelectTab: _selectPrimaryTab,
          ),
        ),
        if (_notificationCenterExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: _MessagesNotificationPanel(
              loading: _notificationLoading,
              result: _notificationResult,
              selectedFilter: _selectedNotificationFilter,
              onSelectFilter: _selectNotificationFilter,
              onOpen: _openNotification,
              onDismiss: _dismissUnavailableNotification,
              onDismissMany: _dismissUnavailableNotifications,
              onRetry: () => _loadNotifications(),
              onLoadMore: _loadMoreNotifications,
            ),
          ),
        Expanded(
          child: PageView(
            controller: _primaryPageController,
            onPageChanged: (index) {
              final tab = _primaryTabFromIndex(index);
              setState(() => _selectedPrimaryTab = tab);
              if (tab == _MessagesPrimaryTab.forumInteraction) {
                _ensureForumTabLoaded();
              }
            },
            children: <Widget>[
              RefreshIndicator(
                onRefresh: _refreshAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  children: <Widget>[
                    if (_projectCommunicationLoading ||
                        _projectCommunicationResult != null)
                      _MessagesProjectCommunicationSection(
                        loading: _projectCommunicationLoading,
                        result: _projectCommunicationResult,
                        items: projectCommunicationItems,
                        onOpen: (MessageInteractionItemView item) =>
                            _openProjectCommunication(context, item),
                      )
                    else
                      const _MessagesInlinePanel(
                        title: '项目沟通正在加载',
                        body: '正在读取主体会话列表。',
                      ),
                  ],
                ),
              ),
              RefreshIndicator(
                onRefresh: _refreshAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  children: <Widget>[
                    _MessagesForumInteractionSection(
                      selectedTab: selectedTab,
                      onSelectTab: _selectForumInteractionTab,
                      loading: _loading,
                      state: state,
                      message: result?.message,
                      items: items,
                      onRetry: () {
                        final currentTab = _selectedTab;
                        if (currentTab == null) {
                          return;
                        }
                        _load(tab: currentTab);
                      },
                      onOpenSource: (ForumInteractionInboxItemView item) =>
                          _openSource(context, item),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _notificationUnreadCount(AppNotificationListResult? result) {
    final data = result?.data;
    if ((result?.state == AppPageState.content ||
            result?.state == AppPageState.empty) &&
        data != null) {
      return data.unread.total;
    }
    return 0;
  }

  void _syncShellMessagesUnreadBadge(AppNotificationListResult result) {
    final data = result.data;
    if (data == null) {
      return;
    }
    _syncShellMessagesUnreadCount(data.unread.total);
  }

  void _syncShellMessagesUnreadCount(int unreadCount) {
    try {
      AppShellScope.read(context).applyMessagesUnreadProjection(unreadCount);
    } catch (_) {
      // Some focused widget tests mount MessagesPage outside the full shell.
    }
  }

  void _selectPrimaryTab(_MessagesPrimaryTab tab) {
    if (tab == _selectedPrimaryTab) {
      return;
    }
    setState(() => _selectedPrimaryTab = tab);
    _primaryPageController.animateToPage(
      _primaryTabIndex(tab),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    if (tab == _MessagesPrimaryTab.forumInteraction) {
      _ensureForumTabLoaded();
    }
  }

  int _primaryTabIndex(_MessagesPrimaryTab tab) {
    return switch (tab) {
      _MessagesPrimaryTab.projectCommunication => 0,
      _MessagesPrimaryTab.forumInteraction => 1,
    };
  }

  _MessagesPrimaryTab _primaryTabFromIndex(int index) {
    return index == 1
        ? _MessagesPrimaryTab.forumInteraction
        : _MessagesPrimaryTab.projectCommunication;
  }

  void _ensureForumTabLoaded() {
    final selectedTab = _selectedTab ?? _MessagesInteractionTab.replies;
    if (_selectedTab == null) {
      setState(() => _selectedTab = selectedTab);
    }
    if (!_results.containsKey(selectedTab)) {
      _load(tab: selectedTab);
    }
  }

  void _selectForumInteractionTab(_MessagesInteractionTab tab) {
    if (tab == _selectedTab && _results.containsKey(tab)) {
      return;
    }
    setState(() => _selectedTab = tab);
    _load(tab: tab);
  }

  void _selectNotificationFilter(_MessagesNotificationFilter filter) {
    if (filter == _selectedNotificationFilter) {
      return;
    }
    setState(() {
      _selectedNotificationFilter = filter;
    });
    _loadNotifications(showLoading: false);
  }

  Future<void> _loadMoreNotifications() async {
    final current = _notificationResult?.data;
    if (current == null || current.nextCursor == null || _notificationLoading) {
      return;
    }
    setState(() => _notificationLoading = true);
    final result = await MessagesConsumerLayer.instance.loadNotifications(
      cursor: current.nextCursor,
      source: _notificationFilterQuery(_selectedNotificationFilter),
    );
    if (!mounted) {
      return;
    }
    final next = result.data;
    setState(() {
      _notificationLoading = false;
      if (result.state == AppPageState.content && next != null) {
        _notificationResult = AppNotificationListResult(
          state: result.state,
          method: result.method,
          path: result.path,
          data: AppNotificationListView(
            items: <AppNotificationItemView>[...current.items, ...next.items],
            nextCursor: next.nextCursor,
            hasMore: next.hasMore,
            unread: next.unread,
          ),
          message: result.message,
          errorCode: result.errorCode,
        );
      } else {
        _notificationResult = result;
      }
    });
    _syncShellMessagesUnreadBadge(result);
  }

  List<MessageInteractionItemView> _projectCommunicationItems(
    MessageInteractionListResult? result,
  ) {
    if (result?.state != AppPageState.content) {
      return const <MessageInteractionItemView>[];
    }
    final itemsByConversationId = <String, MessageInteractionItemView>{};
    for (final item in result!.items) {
      if (item.interactionType != 'counterpart_conversation') {
        continue;
      }
      itemsByConversationId.putIfAbsent(item.conversationId, () => item);
    }
    return itemsByConversationId.values.toList(growable: false);
  }

  Future<void> _openProjectCommunication(
    BuildContext context,
    MessageInteractionItemView item,
  ) async {
    if (!_canOpenProjectCommunication(item)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(_projectCommunicationMissingContextMessage),
        ),
      );
      return;
    }
    await Navigator.of(context).pushNamed(item.routeTarget.routeLocation);
    if (!mounted) {
      return;
    }
    await _refreshAll(showLoading: false);
    await _reloadShellContextPreservingNotificationUnread();
  }

  bool _canOpenProjectCommunication(MessageInteractionItemView item) {
    final params = item.routeTarget.params;
    return _nonEmpty(item.conversationId) &&
        _nonEmpty(item.projectId) &&
        _nonEmpty(params['conversationId']) &&
        _nonEmpty(params['projectId']) &&
        _nonEmpty(item.routeTarget.routeLocation);
  }

  bool _nonEmpty(String? value) => value != null && value.trim().isNotEmpty;

  String _notificationAvailabilityMessage(String? message) {
    final normalized = message?.trim();
    if (normalized == null || normalized.isEmpty) {
      return '当前通知暂时无法定位，请稍后重试或从对应入口进入。';
    }
    if (normalized.contains('COUNTERPART_CONVERSATION_UNAVAILABLE') ||
        normalized.contains('routeTarget') ||
        normalized.contains('routeParams') ||
        normalized.contains('non-empty strings')) {
      return '当前通知暂时无法定位，请稍后重试或从对应入口进入。';
    }
    return normalized;
  }

  Future<void> _openNotification(AppNotificationItemView item) async {
    final availability = item.routeTargetAvailability;
    if (!availability.isAvailable) {
      if (availability.canOpenFallback) {
        setState(() {
          _selectedPrimaryTab = _MessagesPrimaryTab.projectCommunication;
          _notificationCenterExpanded = false;
        });
        if (_primaryPageController.hasClients) {
          unawaited(
            _primaryPageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
            ),
          );
        }
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              _notificationAvailabilityMessage(availability.reasonText),
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            _notificationAvailabilityMessage(availability.reasonText),
          ),
        ),
      );
      return;
    }
    final routeLocation = item.routeTarget?.routeLocation;
    if (_isProjectCommunicationNotification(item) &&
        !_hasCompleteProjectCommunicationRoute(item)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(_projectCommunicationMissingContextMessage),
        ),
      );
      return;
    }
    if (routeLocation == null || routeLocation.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('当前通知暂时无法定位，请稍后重试或从对应入口进入。')),
      );
      return;
    }
    try {
      final routeFuture = Navigator.of(context).pushNamed(routeLocation);
      unawaited(routeFuture);
    } catch (_) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('当前通知暂时无法定位，请稍后重试或从对应入口进入。')),
      );
      return;
    }
    if (item.unread && !_isProjectCommunicationNotification(item)) {
      final result = await MessagesConsumerLayer.instance.markNotificationsRead(
        <String>[item.notificationId],
      );
      if (result.state != AppPageState.content) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(result.message ?? '当前通知已读操作暂不可用，请稍后再试。')),
        );
        return;
      }
      await _loadNotifications(showLoading: false);
      await _reloadShellContextPreservingNotificationUnread();
      final unread = result.unread;
      if (unread != null) {
        _syncShellMessagesUnreadCount(unread.total);
      }
    }
  }

  Future<void> _dismissUnavailableNotification(
    AppNotificationItemView item,
  ) async {
    await _dismissUnavailableNotifications(<AppNotificationItemView>[item]);
  }

  Future<void> _dismissUnavailableNotifications(
    List<AppNotificationItemView> items,
  ) async {
    final notificationIds = items
        .where((item) => !item.routeTargetAvailability.isAvailable)
        .where((item) => item.unread)
        .map((item) => item.notificationId)
        .where((notificationId) => notificationId.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (notificationIds.isEmpty) {
      return;
    }
    final result = await MessagesConsumerLayer.instance.markNotificationsRead(
      notificationIds,
    );
    if (!mounted) {
      return;
    }
    if (result.state != AppPageState.content) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(result.message ?? '当前通知处理暂不可用，请稍后再试。')),
      );
      return;
    }
    final unread = result.unread;
    if (unread != null) {
      _syncShellMessagesUnreadCount(unread.total);
    }
    await _loadNotifications(showLoading: false);
    if (!mounted) {
      return;
    }
    await _reloadShellContextPreservingNotificationUnread();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('已清理失效提醒。')));
  }

  bool _isProjectCommunicationNotification(AppNotificationItemView item) {
    return item.source == 'project_communication' ||
        item.type == 'project_communication_message' ||
        item.routeTarget?.canonicalPath ==
            '/api/app/message/counterpart-conversation/detail';
  }

  bool _hasCompleteProjectCommunicationRoute(AppNotificationItemView item) {
    final routeTarget = item.routeTarget;
    if (routeTarget == null || !_nonEmpty(routeTarget.routeLocation)) {
      return false;
    }
    final params = routeTarget.params;
    return _nonEmpty(params['conversationId']) &&
        _nonEmpty(params['projectId']) &&
        _nonEmpty(params['threadId']);
  }

  Future<void> _reloadShellContext() async {
    try {
      await AppShellScope.read(context).reloadShellContext();
    } catch (_) {
      // Tests may mount this page without the full shell scope.
    }
  }

  Future<void> _reloadShellContextPreservingNotificationUnread() async {
    await _reloadShellContext();
    final notificationResult = _notificationResult;
    if (notificationResult != null) {
      _syncShellMessagesUnreadBadge(notificationResult);
    }
  }

  void _openSource(BuildContext context, ForumInteractionInboxItemView item) {
    switch (item.targetType) {
      case 'forum_post':
        Navigator.of(
          context,
        ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.targetId));
        return;
      case 'forum_topic':
        Navigator.of(
          context,
        ).pushNamed(ExhibitionRoutes.forumTopicWithTopicId(item.targetId));
        return;
      case 'forum_comment':
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('这条提醒暂时还不能直接打开原评论，请稍后再试。')),
        );
        return;
      default:
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(const SnackBar(content: Text('当前提醒入口暂未开放，请稍后再试。')));
        return;
    }
  }
}
