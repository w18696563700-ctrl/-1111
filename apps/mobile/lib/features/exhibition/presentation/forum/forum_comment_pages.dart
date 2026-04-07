part of 'forum_pages.dart';

class ForumCommentInteractionPage extends StatefulWidget {
  const ForumCommentInteractionPage({super.key, required this.postId});

  final String? postId;

  @override
  State<ForumCommentInteractionPage> createState() =>
      _ForumCommentInteractionPageState();
}

class _ForumCommentInteractionPageState
    extends State<ForumCommentInteractionPage> {
  final TextEditingController _controller = TextEditingController();
  ForumReadResult<ForumPostDetailView>? _detailResult;
  ForumReadResult<ForumPagedCollectionView<ForumCommentItemView>>?
  _commentResult;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ForumConsumerLayer.instance.loadPostDetail(postId: widget.postId),
      ForumConsumerLayer.instance.loadPostComments(postId: widget.postId),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _detailResult = results[0] as ForumReadResult<ForumPostDetailView>;
      _commentResult =
          results[1]
              as ForumReadResult<
                ForumPagedCollectionView<ForumCommentItemView>
              >;
      _loading = false;
    });
  }

  Future<void> _submitComment() async {
    if (_submitting) {
      return;
    }
    final body = _controller.text.trim();
    if (body.isEmpty) {
      _showMessage('请先输入回复内容');
      return;
    }

    setState(() => _submitting = true);
    final result = await ForumConsumerLayer.instance.submitComment(
      postId: widget.postId,
      body: body,
    );
    if (!mounted) {
      return;
    }
    if (!result.isSuccess) {
      setState(() => _submitting = false);
      _showMessage(result.message);
      return;
    }

    _controller.clear();
    await _load();
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    _showMessage('回复已发送');
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detailResult?.data;
    final comments =
        _commentResult?.data?.items ?? const <ForumCommentItemView>[];
    final topicTitle = detail == null
        ? null
        : forumDisplayTopicLabel(
            rawLabel: detail.topicTitle,
            topicId: detail.topicId,
          );
    final authorName = detail == null
        ? '论坛用户'
        : forumDisplayActorName(detail.author.displayName);
    final showStateCard =
        _loading ||
        (_detailResult?.state != null &&
            _detailResult?.state != AppPageState.content);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        if (showStateCard)
          ForumReadStateCard(
            loading: _loading,
            state: _detailResult?.state,
            emptyMessage: '当前还没有可继续互动的帖子内容。',
            onRetry: _load,
            message: _detailResult?.message,
            errorCode: _detailResult?.errorCode,
          )
        else if (detail != null) ...<Widget>[
          ForumSectionCard(
            eyebrow: '当前帖子',
            title: topicTitle!,
            summary: '评论互动区会继续围绕当前帖子展开。',
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ForumInfoPill(label: '# $topicTitle', highlighted: true),
                ],
              ),
              ForumPostPreviewCard(
                title: '帖子上下文',
                summary: detail.content,
                meta:
                    '$authorName · ${_compactPublishedAt(detail.publishedAt)}',
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: () =>
                        _returnToPostDetail(context, detail.postId),
                    child: const Text('回帖子详情'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(_routeForScope(ForumFeedScope.square)),
                    child: const Text('回论坛列表'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ForumSectionCard(
            eyebrow: '回复输入区',
            title: '继续发言',
            summary: '输入内容后可以继续回复当前讨论。',
            children: <Widget>[
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '继续补充你的排班经验、材料协同建议或进场提醒',
                  border: OutlineInputBorder(),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: _submitting ? null : _submitComment,
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_submitting ? '发送中' : '发送回复'),
                  ),
                  OutlinedButton(
                    onPressed: _submitting ? null : _controller.clear,
                    child: const Text('清空输入'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ForumSectionCard(
            eyebrow: '评论线程',
            title: '当前讨论现场',
            summary: '评论流清楚呈现谁、在回应什么、说了什么，并保留继续回复的位置。',
            children: <Widget>[
              if (_loading ||
                  (_commentResult?.state != null &&
                      _commentResult?.state != AppPageState.content))
                ForumReadStateCard(
                  loading: _loading,
                  state: _commentResult?.state,
                  emptyMessage: '当前帖子还没有评论。',
                  onRetry: _load,
                  message: _commentResult?.message,
                  errorCode: _commentResult?.errorCode,
                )
              else if (comments.isEmpty)
                const ForumPostPreviewCard(
                  title: '当前还没有评论',
                  summary: '现在还没有新的评论内容。',
                  meta: '评论数：0',
                )
              else
                ...comments.map(
                  (ForumCommentItemView item) => _ForumThreadCommentCard(
                    author: item.author,
                    target: item.parentCommentId == null ? '回复主帖' : '回复评论',
                    content: item.body,
                    meta:
                        '${_compactPublishedAt(item.publishedAt)} · ${item.replyCount} 条后续回复',
                    onOpenAuthor: () =>
                        _openForumAuthorProfile(context, item.author.authorId),
                    onReport: () => _showForumReportSheet(
                      context,
                      target: _ForumReportTarget(
                        targetType: 'comment',
                        targetId: item.commentId,
                        sheetTitle: '举报评论',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _returnToPostDetail(BuildContext context, String postId) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.forumPostWithPostId(postId));
  }

  void _showMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }
}
