import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_visible_copy.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';

part 'messages_page_support.dart';

enum _MessagesInteractionTab { replies, likes, follows }

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key, this.refreshSignal});

  final ValueListenable<int>? refreshSignal;

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
  _MessagesInteractionTab _selectedTab = _MessagesInteractionTab.replies;
  MessageInteractionListResult? _projectCommunicationResult;
  ValueListenable<int>? _refreshSignal;
  int _lastRefreshTick = 0;
  int _latestLoadToken = 0;
  int _latestReminderLoadToken = 0;
  bool _loading = false;
  bool _projectCommunicationLoading = false;

  @override
  void initState() {
    super.initState();
    _bindRefreshSignal(widget.refreshSignal);
    _load();
    _loadProjectCommunication();
  }

  @override
  void didUpdateWidget(covariant MessagesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _bindRefreshSignal(widget.refreshSignal);
    }
  }

  @override
  void dispose() {
    _refreshSignal?.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  void _bindRefreshSignal(ValueListenable<int>? signal) {
    _refreshSignal?.removeListener(_handleRefreshSignal);
    _refreshSignal = signal;
    _lastRefreshTick = signal?.value ?? 0;
    _refreshSignal?.addListener(_handleRefreshSignal);
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

  Future<void> _refreshAll({bool showLoading = true}) async {
    await Future.wait<void>(<Future<void>>[
      _load(showLoading: showLoading),
      _loadProjectCommunication(showLoading: showLoading),
    ]);
  }

  Future<void> _load({bool showLoading = true}) async {
    final requestedTab = _selectedTab;
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

  @override
  Widget build(BuildContext context) {
    final result = _results[_selectedTab];
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
            selectedTab: _selectedTab,
            onSelectTab: (_MessagesInteractionTab tab) {
              if (tab == _selectedTab) {
                return;
              }
              setState(() => _selectedTab = tab);
              _load();
            },
            loading: _loading,
            state: state,
            message: result?.message,
            items: items,
            onRetry: _load,
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
