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
  MessagesIndexResult? _remindersResult;
  ValueListenable<int>? _refreshSignal;
  int _lastRefreshTick = 0;
  int _latestLoadToken = 0;
  int _latestReminderLoadToken = 0;
  bool _loading = false;
  bool _remindersLoading = false;

  @override
  void initState() {
    super.initState();
    _bindRefreshSignal(widget.refreshSignal);
    _load();
    _loadRoundAReminders();
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
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await Future.wait<void>(<Future<void>>[_load(), _loadRoundAReminders()]);
  }

  Future<void> _load() async {
    final requestedTab = _selectedTab;
    final loadToken = ++_latestLoadToken;
    setState(() => _loading = true);
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

  Future<void> _loadRoundAReminders() async {
    final loadToken = ++_latestReminderLoadToken;
    setState(() => _remindersLoading = true);
    final result = await MessagesConsumerLayer.instance.loadIndex();
    if (!mounted) {
      return;
    }
    setState(() {
      if (loadToken == _latestReminderLoadToken) {
        _remindersResult = result;
        _remindersLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _results[_selectedTab];
    final state = _loading ? AppPageState.loading : result?.state;
    final items =
        result?.data?.items ?? const <ForumInteractionInboxItemView>[];
    final roundAReminders = _roundAReminders(_remindersResult);

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: <Widget>[
          Text(
            '互动中心',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            '这里集中查看别人对你的回复、点赞、关注，以及项目沟通提醒。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
          if (_remindersLoading || roundAReminders.isNotEmpty) ...<Widget>[
            _MessagesRoundAReminderSection(
              loading: _remindersLoading,
              items: roundAReminders,
              onOpen: (MessagesTodoItem item) => _openReminder(context, item),
            ),
            const SizedBox(height: 16),
          ],
          _MessagesInboxTabBar(
            selectedTab: _selectedTab,
            onSelectTab: (_MessagesInteractionTab tab) {
              if (tab == _selectedTab) {
                return;
              }
              setState(() => _selectedTab = tab);
              _load();
            },
          ),
          const SizedBox(height: 12),
          _MessagesTabHintCard(currentTab: _selectedTab),
          const SizedBox(height: 16),
          if (_loading || (state != null && state != AppPageState.content))
            _MessagesInteractionStateCard(
              loading: _loading,
              state: state,
              onRetry: _load,
              currentTab: _selectedTab,
              message: result?.message,
            )
          else if (items.isEmpty)
            _MessagesStaticCard(title: '当前没有新互动', body: _tabHint(_selectedTab))
          else
            ...items.map(
              (ForumInteractionInboxItemView item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _MessagesInteractionCard(
                  item: item,
                  sourceActionLabel: _sourceActionLabel(item.targetType),
                  showQuickReply:
                      item.canQuickReply == true &&
                      item.targetType != 'forum_comment',
                  onOpenSource: () => _openSource(context, item),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<MessagesTodoItem> _roundAReminders(MessagesIndexResult? result) {
    if (result?.state != AppPageState.content) {
      return const <MessagesTodoItem>[];
    }
    return result!.items
        .where((MessagesTodoItem item) => item.isProjectCommunicationReminder)
        .toList(growable: false);
  }

  void _openReminder(BuildContext context, MessagesTodoItem item) {
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
