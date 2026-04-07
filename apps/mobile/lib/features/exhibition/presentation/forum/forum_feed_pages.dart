part of 'forum_pages.dart';

class ForumHubPage extends StatefulWidget {
  const ForumHubPage({super.key, this.initialTopicId});

  final String? initialTopicId;

  @override
  State<ForumHubPage> createState() => _ForumHubPageState();
}

class _ForumHubPageState extends State<ForumHubPage> {
  ForumReadResult<ForumFeedView>? _feedResult;
  ForumReadResult<List<ForumTopicMetadataItemView>>? _topicResult;
  String _selectedFilterKey = _allTopicFilterKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedFilterKey = _initialForumFilterKey(widget.initialTopicId);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ForumConsumerLayer.instance.loadFeed(
        scope: _feedScopeKey(ForumFeedScope.square),
        topicId: _queryTopicIdForFilter(_selectedFilterKey),
      ),
      ForumConsumerLayer.instance.loadTopicMetadata(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _feedResult = results[0] as ForumReadResult<ForumFeedView>;
      _topicResult =
          results[1] as ForumReadResult<List<ForumTopicMetadataItemView>>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ForumBrowsePane(
      scope: ForumFeedScope.square,
      loading: _loading,
      feedResult: _feedResult,
      topicResult: _topicResult,
      selectedFilterKey: _selectedFilterKey,
      onRetry: _load,
      onOpenScope: (ForumFeedScope scope) {
        if (scope == ForumFeedScope.square) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(_routeForScope(scope));
      },
      onSelectTopic: (String filterKey) {
        setState(() => _selectedFilterKey = filterKey);
        _load();
      },
    );
  }
}

class ForumFeedPage extends StatefulWidget {
  const ForumFeedPage({super.key, required this.scope, this.initialTopicId});

  final ForumFeedScope scope;
  final String? initialTopicId;

  @override
  State<ForumFeedPage> createState() => _ForumFeedPageState();
}

class _ForumFeedPageState extends State<ForumFeedPage> {
  ForumReadResult<ForumFeedView>? _feedResult;
  ForumReadResult<List<ForumTopicMetadataItemView>>? _topicResult;
  String _selectedFilterKey = _allTopicFilterKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedFilterKey = _initialForumFilterKey(widget.initialTopicId);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ForumConsumerLayer.instance.loadFeed(
        scope: _feedScopeKey(widget.scope),
        topicId: _queryTopicIdForFilter(_selectedFilterKey),
      ),
      ForumConsumerLayer.instance.loadTopicMetadata(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _feedResult = results[0] as ForumReadResult<ForumFeedView>;
      _topicResult =
          results[1] as ForumReadResult<List<ForumTopicMetadataItemView>>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ForumBrowsePane(
      scope: widget.scope,
      loading: _loading,
      feedResult: _feedResult,
      topicResult: _topicResult,
      selectedFilterKey: _selectedFilterKey,
      onRetry: _load,
      onOpenScope: (ForumFeedScope scope) {
        if (scope == widget.scope) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(_routeForScope(scope));
      },
      onSelectTopic: (String filterKey) {
        setState(() => _selectedFilterKey = filterKey);
        _load();
      },
    );
  }
}

String _initialForumFilterKey(String? topicId) {
  final resolvedTopicId = topicId?.trim();
  if (resolvedTopicId == null || resolvedTopicId.isEmpty) {
    return _allTopicFilterKey;
  }
  return _topicFilterKey(resolvedTopicId);
}
