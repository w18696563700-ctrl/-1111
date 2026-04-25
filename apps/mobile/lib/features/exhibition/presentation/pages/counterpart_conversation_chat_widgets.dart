part of '../exhibition_trade_pages.dart';

enum _DraftProjectCommunicationState { sending, failed }

class _DraftProjectCommunicationMessage {
  const _DraftProjectCommunicationMessage({
    required this.clientMessageId,
    required this.body,
    required this.createdAt,
    required this.state,
    this.errorMessage,
  });

  final String clientMessageId;
  final String body;
  final DateTime createdAt;
  final _DraftProjectCommunicationState state;
  final String? errorMessage;

  _DraftProjectCommunicationMessage copyWith({
    _DraftProjectCommunicationState? state,
    String? errorMessage,
  }) {
    return _DraftProjectCommunicationMessage(
      clientMessageId: clientMessageId,
      body: body,
      createdAt: createdAt,
      state: state ?? this.state,
      errorMessage: errorMessage,
    );
  }
}

class _ProjectCommunicationTimeline extends StatelessWidget {
  const _ProjectCommunicationTimeline({
    required this.loadingThread,
    required this.loadingMessages,
    required this.threadResult,
    required this.messageResult,
    required this.drafts,
    required this.currentOrganizationId,
    required this.onRetryDraft,
    required this.onRefreshMessages,
  });

  final bool loadingThread;
  final bool loadingMessages;
  final CounterpartConversationResult<ProjectCommunicationThreadView>?
  threadResult;
  final CounterpartConversationResult<ProjectCommunicationMessageListView>?
  messageResult;
  final List<_DraftProjectCommunicationMessage> drafts;
  final String? currentOrganizationId;
  final ValueChanged<_DraftProjectCommunicationMessage> onRetryDraft;
  final VoidCallback? onRefreshMessages;

  @override
  Widget build(BuildContext context) {
    final messages =
        messageResult?.data?.items ?? const <ProjectCommunicationMessageView>[];
    return _ActionCard(
      title: '聊天',
      summary: '当前仅支持文字沟通，所有消息继续锚定当前项目。',
      children: <Widget>[
        if (loadingThread || loadingMessages)
          const _StateMessage(title: '正在同步聊天', body: '正在读取项目沟通消息。')
        else if (threadResult != null &&
            threadResult!.state != AppPageState.content)
          _StateMessage(
            title: '聊天暂不可用',
            body: threadResult!.message ?? threadResult!.state.contractName,
          )
        else if (messageResult != null &&
            messageResult!.state != AppPageState.content)
          _StateMessage(
            title: '消息读取失败',
            body: messageResult!.message ?? messageResult!.state.contractName,
          )
        else if (messages.isEmpty && drafts.isEmpty)
          const _StateMessage(title: '还没有文字消息', body: '可以从底部输入框发送第一条消息。')
        else ...<Widget>[
          for (final message in messages)
            _ProjectCommunicationMessageBubble(
              message: message,
              isMine: _isMine(message.senderOrganizationId),
            ),
          for (final draft in drafts)
            _DraftProjectCommunicationMessageBubble(
              draft: draft,
              onRetry: () => onRetryDraft(draft),
            ),
        ],
        if (onRefreshMessages != null) ...<Widget>[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: onRefreshMessages,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              icon: const Icon(Icons.sync_rounded, size: 16),
              label: const Text('手动同步'),
            ),
          ),
        ],
      ],
    );
  }

  bool _isMine(String senderOrganizationId) {
    final current = currentOrganizationId?.trim();
    return current != null &&
        current.isNotEmpty &&
        senderOrganizationId.trim() == current;
  }
}

class _ProjectCommunicationMessageBubble extends StatelessWidget {
  const _ProjectCommunicationMessageBubble({
    required this.message,
    required this.isMine,
  });

  final ProjectCommunicationMessageView message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return _ChatBubble(
      body: message.body,
      meta: _formatChatTime(message.createdAt),
      isMine: isMine,
    );
  }
}

class _DraftProjectCommunicationMessageBubble extends StatelessWidget {
  const _DraftProjectCommunicationMessageBubble({
    required this.draft,
    required this.onRetry,
  });

  final _DraftProjectCommunicationMessage draft;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failed = draft.state == _DraftProjectCommunicationState.failed;
    final meta = failed
        ? '发送失败${draft.errorMessage == null ? '' : ' · ${draft.errorMessage}'}'
        : '发送中...';
    return _ChatBubble(
      body: draft.body,
      meta: meta,
      isMine: true,
      trailing: failed
          ? TextButton(onPressed: onRetry, child: const Text('重试'))
          : null,
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.body,
    required this.meta,
    required this.isMine,
    this.trailing,
  });

  final String body;
  final String meta;
  final bool isMine;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth = math.max(220.0, math.min(420.0, screenWidth * 0.72));
    final bubbleColor = isMine
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerLowest;
    final textColor = isMine
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      meta,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor.withValues(alpha: 0.68),
                      ),
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    const SizedBox(width: 6),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCommunicationComposer extends StatelessWidget {
  const _ProjectCommunicationComposer({
    required this.controller,
    required this.enabled,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled && !sending,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => enabled && !sending ? onSend() : null,
                    decoration: InputDecoration(
                      hintText: enabled ? '想跟TA说点什么...' : '聊天暂不可用',
                      filled: true,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: enabled && !sending ? onSend : null,
                  icon: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatChatTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  final local = parsed.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
