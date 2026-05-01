import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_visible_copy.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

part 'messages_page_support.dart';

enum _MessagesInteractionTab { replies, likes, follows }

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

  @override
  void initState() {
    super.initState();
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
      _loading = false;
    });
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
    final result = await MessagesConsumerLayer.instance.loadNotifications();
    if (!mounted) {
      return;
    }
    setState(() {
      _notificationResult = result;
      _notificationLoading = false;
    });
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

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: <Widget>[
          if (_notificationLoading || _notificationResult != null) ...<Widget>[
            _MessagesNotificationCenterSection(
              loading: _notificationLoading,
              expanded: _notificationCenterExpanded,
              result: _notificationResult,
              onToggleExpanded: () {
                setState(
                  () => _notificationCenterExpanded =
                      !_notificationCenterExpanded,
                );
              },
              onOpen: _openNotification,
              onRetry: () => _loadNotifications(),
            ),
            const SizedBox(height: 14),
          ],
          if (_projectCommunicationLoading ||
              _projectCommunicationResult != null) ...<Widget>[
            _MessagesProjectCommunicationSection(
              loading: _projectCommunicationLoading,
              result: _projectCommunicationResult,
              items: projectCommunicationItems,
              onOpen: (MessageInteractionItemView item) =>
                  _openProjectCommunication(context, item),
            ),
            const SizedBox(height: 14),
          ],
          _MessagesForumInteractionSection(
            selectedTab: selectedTab,
            onSelectTab: (_MessagesInteractionTab tab) {
              if (tab == selectedTab) {
                setState(() {
                  _selectedTab = null;
                  _loading = false;
                });
                return;
              }
              setState(() => _selectedTab = tab);
              _load(tab: tab);
            },
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
    );
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

  void _openProjectCommunication(
    BuildContext context,
    MessageInteractionItemView item,
  ) {
    Navigator.of(context).pushNamed(item.routeTarget.routeLocation);
  }

  Future<void> _openNotification(AppNotificationItemView item) async {
    if (item.unread) {
      await MessagesConsumerLayer.instance.markNotificationsRead(<String>[
        item.notificationId,
      ]);
      await _loadNotifications(showLoading: false);
      _reloadShellContextAfterNotificationRead();
    }
    if (!mounted) {
      return;
    }
    final routeLocation = item.routeTarget?.routeLocation;
    if (routeLocation == null || routeLocation.isEmpty) {
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(const SnackBar(content: Text('当前通知暂时没有可打开的页面。')));
      return;
    }
    Navigator.of(context).pushNamed(routeLocation);
  }

  void _reloadShellContextAfterNotificationRead() {
    try {
      unawaited(AppShellScope.read(context).reloadShellContext());
    } catch (_) {
      // Tests may mount this page without the full shell scope.
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
