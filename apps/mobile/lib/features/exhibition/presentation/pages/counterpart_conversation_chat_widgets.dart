part of '../exhibition_trade_pages.dart';

enum _DraftProjectCommunicationState { sending, failed }

typedef _ProjectCommunicationAttachmentPreviewResolver =
    ProjectCommunicationFilePreviewAccessView? Function(
      ProjectCommunicationMessageView message,
    );

typedef _ProjectCommunicationAttachmentPreviewLoadingResolver =
    bool Function(ProjectCommunicationMessageView message);

class _DraftProjectCommunicationMessage {
  const _DraftProjectCommunicationMessage({
    required this.clientMessageId,
    required this.body,
    required this.createdAt,
    required this.state,
    this.messageKind = 'text',
    this.attachment,
    this.confirmation,
    this.errorMessage,
  });

  final String clientMessageId;
  final String body;
  final DateTime createdAt;
  final _DraftProjectCommunicationState state;
  final String messageKind;
  final ProjectCommunicationAttachmentView? attachment;
  final ProjectCommunicationConfirmationView? confirmation;
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
      messageKind: messageKind,
      attachment: attachment,
      confirmation: confirmation,
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
    required this.currentDisplayName,
    required this.currentAvatarUrl,
    required this.counterpart,
    required this.attachmentPreviewForMessage,
    required this.attachmentPreviewLoadingForMessage,
    required this.onRetryDraft,
    required this.onRefreshMessages,
    required this.onPreviewAttachment,
    required this.onOpenConfirmationSoftLink,
  });

  final bool loadingThread;
  final bool loadingMessages;
  final CounterpartConversationResult<ProjectCommunicationThreadView>?
  threadResult;
  final CounterpartConversationResult<ProjectCommunicationMessageListView>?
  messageResult;
  final List<_DraftProjectCommunicationMessage> drafts;
  final String? currentOrganizationId;
  final String? currentDisplayName;
  final String? currentAvatarUrl;
  final MessageInteractionCounterpartView counterpart;
  final _ProjectCommunicationAttachmentPreviewResolver
  attachmentPreviewForMessage;
  final _ProjectCommunicationAttachmentPreviewLoadingResolver
  attachmentPreviewLoadingForMessage;
  final ValueChanged<_DraftProjectCommunicationMessage> onRetryDraft;
  final VoidCallback? onRefreshMessages;
  final ValueChanged<ProjectCommunicationMessageView> onPreviewAttachment;
  final ValueChanged<ProjectCommunicationMessageView>
  onOpenConfirmationSoftLink;

  @override
  Widget build(BuildContext context) {
    final thread = threadResult?.data;
    final rawMessages =
        messageResult?.data?.items ?? const <ProjectCommunicationMessageView>[];
    final messages = thread == null
        ? rawMessages
        : rawMessages
              .where(
                (message) =>
                    message.threadId == thread.threadId &&
                    message.projectId == thread.projectId,
              )
              .toList(growable: false);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 280),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '项目沟通',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (onRefreshMessages != null)
                    IconButton(
                      onPressed: onRefreshMessages,
                      tooltip: '手动同步',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.sync_rounded, size: 18),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (loadingThread || loadingMessages)
                const _StateMessage(title: '正在同步沟通记录', body: '正在读取项目沟通消息。')
              else if (threadResult != null &&
                  threadResult!.state != AppPageState.content)
                _StateMessage(
                  title: '聊天暂不可用',
                  body:
                      threadResult!.message ?? threadResult!.state.contractName,
                )
              else if (messageResult != null &&
                  messageResult!.state != AppPageState.content)
                _StateMessage(
                  title: '消息读取失败',
                  body:
                      messageResult!.message ??
                      messageResult!.state.contractName,
                )
              else if (messages.isEmpty && drafts.isEmpty)
                const SizedBox(
                  height: 190,
                  child: Center(
                    child: _StateMessage(
                      title: '还没有项目沟通记录',
                      body: '可以从底部输入框发送第一条项目沟通消息。',
                    ),
                  ),
                )
              else ...<Widget>[
                for (final message in messages)
                  _ProjectCommunicationMessageBubble(
                    message: message,
                    isMine: _isMine(message.senderOrganizationId),
                    senderName: _senderName(message.senderOrganizationId),
                    roleLabel: _roleLabel(message.senderOrganizationId),
                    avatarUrl: _avatarUrl(message.senderOrganizationId),
                    attachmentPreview: attachmentPreviewForMessage(message),
                    attachmentPreviewLoading:
                        attachmentPreviewLoadingForMessage(message),
                    onPreviewAttachment: () => onPreviewAttachment(message),
                    onOpenConfirmationSoftLink: () =>
                        onOpenConfirmationSoftLink(message),
                  ),
                for (final draft in drafts)
                  _DraftProjectCommunicationMessageBubble(
                    draft: draft,
                    senderName: _fallbackCurrentName,
                    roleLabel: '我方',
                    avatarUrl: currentAvatarUrl,
                    onRetry: () => onRetryDraft(draft),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isMine(String senderOrganizationId) {
    final current = currentOrganizationId?.trim();
    return current != null &&
        current.isNotEmpty &&
        senderOrganizationId.trim() == current;
  }

  String get _fallbackCurrentName {
    final normalized = currentDisplayName?.trim();
    return normalized == null || normalized.isEmpty ? '我' : normalized;
  }

  String _senderName(String senderOrganizationId) {
    if (_isMine(senderOrganizationId)) {
      return _fallbackCurrentName;
    }
    final nickname = counterpart.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }
    final companyName = counterpart.companyName.trim();
    if (companyName.isNotEmpty) {
      return companyName;
    }
    return counterpart.displayName.trim().isEmpty
        ? '对方'
        : counterpart.displayName.trim();
  }

  String _roleLabel(String senderOrganizationId) {
    final thread = threadResult?.data;
    if (thread == null) {
      return _isMine(senderOrganizationId) ? '我方' : '对方';
    }
    if (senderOrganizationId == thread.ownerOrganizationId) {
      return '发布方';
    }
    if (senderOrganizationId == thread.counterpartOrganizationId) {
      return '竞标方';
    }
    return _isMine(senderOrganizationId) ? '我方' : '对方';
  }

  String? _avatarUrl(String senderOrganizationId) {
    if (_isMine(senderOrganizationId)) {
      return currentAvatarUrl;
    }
    return counterpart.avatarUrl;
  }
}

class _ProjectCommunicationMessageBubble extends StatelessWidget {
  const _ProjectCommunicationMessageBubble({
    required this.message,
    required this.isMine,
    required this.senderName,
    required this.roleLabel,
    required this.avatarUrl,
    required this.attachmentPreview,
    required this.attachmentPreviewLoading,
    required this.onPreviewAttachment,
    required this.onOpenConfirmationSoftLink,
  });

  final ProjectCommunicationMessageView message;
  final bool isMine;
  final String senderName;
  final String roleLabel;
  final String? avatarUrl;
  final ProjectCommunicationFilePreviewAccessView? attachmentPreview;
  final bool attachmentPreviewLoading;
  final VoidCallback onPreviewAttachment;
  final VoidCallback onOpenConfirmationSoftLink;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _messageStatusLabel(message, isMine);
    final sentAtLabel = _formatChatTime(message.createdAt);
    return _ChatBubble(
      body: message.body,
      attachment: message.attachment,
      confirmation: message.confirmation,
      meta: statusLabel == null ? sentAtLabel : '$sentAtLabel · $statusLabel',
      isMine: isMine,
      senderName: senderName,
      roleLabel: roleLabel,
      avatarUrl: avatarUrl,
      attachmentPreview: attachmentPreview,
      attachmentPreviewLoading: attachmentPreviewLoading,
      onPreviewAttachment: message.attachment == null
          ? null
          : onPreviewAttachment,
      onOpenConfirmationSoftLink: message.confirmation == null
          ? null
          : onOpenConfirmationSoftLink,
    );
  }

  String? _messageStatusLabel(
    ProjectCommunicationMessageView message,
    bool isMine,
  ) {
    if (!isMine) {
      return null;
    }
    if (message.readState == 'read_by_counterpart') {
      return '已读';
    }
    if (message.deliveryState == 'persisted') {
      return '已发送';
    }
    return null;
  }
}

class _DraftProjectCommunicationMessageBubble extends StatelessWidget {
  const _DraftProjectCommunicationMessageBubble({
    required this.draft,
    required this.senderName,
    required this.roleLabel,
    required this.avatarUrl,
    required this.onRetry,
  });

  final _DraftProjectCommunicationMessage draft;
  final String senderName;
  final String roleLabel;
  final String? avatarUrl;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failed = draft.state == _DraftProjectCommunicationState.failed;
    final sentAtLabel = _formatDraftChatTime(draft.createdAt);
    final meta = failed
        ? '$sentAtLabel · 发送失败${draft.errorMessage == null ? '' : ' · ${draft.errorMessage}'}'
        : '$sentAtLabel · 发送中';
    return _ChatBubble(
      body: draft.body,
      attachment: draft.attachment,
      confirmation: draft.confirmation,
      meta: meta,
      isMine: true,
      senderName: senderName,
      roleLabel: roleLabel,
      avatarUrl: avatarUrl,
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
    required this.senderName,
    required this.roleLabel,
    required this.avatarUrl,
    this.attachment,
    this.confirmation,
    this.attachmentPreview,
    this.attachmentPreviewLoading = false,
    this.trailing,
    this.onPreviewAttachment,
    this.onOpenConfirmationSoftLink,
  });

  final String body;
  final String meta;
  final bool isMine;
  final String senderName;
  final String roleLabel;
  final String? avatarUrl;
  final ProjectCommunicationAttachmentView? attachment;
  final ProjectCommunicationConfirmationView? confirmation;
  final ProjectCommunicationFilePreviewAccessView? attachmentPreview;
  final bool attachmentPreviewLoading;
  final Widget? trailing;
  final VoidCallback? onPreviewAttachment;
  final VoidCallback? onOpenConfirmationSoftLink;

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
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxBubbleWidth),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    senderName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _ConversationPill(
                  label: roleLabel,
                  foregroundColor: isMine
                      ? const Color(0xFF2E6F43)
                      : const Color(0xFF245BA7),
                  backgroundColor: isMine
                      ? const Color(0xFFE7F5EA)
                      : const Color(0xFFE8F0FF),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (confirmation != null)
              _ConversationConfirmationCard(
                confirmation: confirmation!,
                onOpenSoftLink: onOpenConfirmationSoftLink,
              )
            else if (attachment != null)
              _ConversationAttachmentCard(
                attachment: attachment!,
                preview: attachmentPreview,
                previewLoading: attachmentPreviewLoading,
                onPreview: onPreviewAttachment,
              )
            else
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (body.trim().isNotEmpty &&
                (confirmation != null || attachment != null)) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.74),
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    meta,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.62),
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
    );
    final rowChildren = <Widget>[
      if (!isMine) _ConversationAvatar(avatarUrl: avatarUrl, label: senderName),
      if (!isMine) const SizedBox(width: 8),
      Flexible(child: bubble),
      if (isMine) const SizedBox(width: 8),
      if (isMine) _ConversationAvatar(avatarUrl: avatarUrl, label: senderName),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: rowChildren,
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.avatarUrl, required this.label});

  final String? avatarUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    final normalized = avatarUrl?.trim();
    return CircleAvatar(
      radius: 18,
      backgroundImage: normalized == null || normalized.isEmpty
          ? null
          : NetworkImage(normalized),
      child: normalized == null || normalized.isEmpty
          ? Text(label.trim().isEmpty ? '?' : label.characters.first)
          : null,
    );
  }
}

class _ConversationAttachmentCard extends StatelessWidget {
  const _ConversationAttachmentCard({
    required this.attachment,
    this.preview,
    this.previewLoading = false,
    this.onPreview,
  });

  final ProjectCommunicationAttachmentView attachment;
  final ProjectCommunicationFilePreviewAccessView? preview;
  final bool previewLoading;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImage =
        attachment.category == 'image' ||
        attachment.mimeType.toLowerCase().startsWith('image/');
    final accessUrl = preview?.accessUrl?.trim();
    final canShowImage =
        isImage &&
        preview?.canPreview == true &&
        preview?.previewType == 'image' &&
        accessUrl != null &&
        accessUrl.isNotEmpty;
    if (canShowImage) {
      return _ConversationImageAttachmentCard(
        attachment: attachment,
        imageUrl: accessUrl,
        onPreview: onPreview,
      );
    }
    if (isImage && previewLoading) {
      return const _ConversationImageAttachmentLoadingCard();
    }
    if (isImage) {
      return _ConversationImageAttachmentUnavailableCard(onPreview: onPreview);
    }
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isImage ? Icons.image_outlined : Icons.attach_file_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    attachment.fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isImage ? '图片' : '附件'} · ${_formatBytes(attachment.size)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onPreview != null) ...<Widget>[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onPreview,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('预览'),
              ),
            ],
          ],
        ),
      ),
    );
    if (onPreview == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPreview,
      child: content,
    );
  }
}

class _ConversationImageAttachmentLoadingCard extends StatelessWidget {
  const _ConversationImageAttachmentLoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SizedBox(
        width: 220,
        height: 132,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 10),
            Text(
              '正在加载图片',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationImageAttachmentUnavailableCard extends StatelessWidget {
  const _ConversationImageAttachmentUnavailableCard({this.onPreview});

  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SizedBox(
        width: 220,
        height: 132,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.image_not_supported_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              '图片暂不可预览',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
    if (onPreview == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPreview,
      child: content,
    );
  }
}

class _ConversationImageAttachmentCard extends StatelessWidget {
  const _ConversationImageAttachmentCard({
    required this.attachment,
    required this.imageUrl,
    this.onPreview,
  });

  final ProjectCommunicationAttachmentView attachment;
  final String imageUrl;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 220,
        height: 150,
        fit: BoxFit.cover,
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return const SizedBox(
                width: 220,
                height: 150,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
        errorBuilder: (_, _, _) => SizedBox(
          width: 220,
          height: 150,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Icon(Icons.broken_image_outlined)),
          ),
        ),
      ),
    );
    final content = SizedBox(
      key: ValueKey<String>(
        'project-communication-image-attachment-${attachment.fileAssetId}',
      ),
      width: 220,
      height: 150,
      child: image,
    );
    if (onPreview == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPreview,
      child: content,
    );
  }
}

class _ConversationConfirmationCard extends StatelessWidget {
  const _ConversationConfirmationCard({
    required this.confirmation,
    this.onOpenSoftLink,
  });

  final ProjectCommunicationConfirmationView confirmation;
  final VoidCallback? onOpenSoftLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8C48E)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.verified_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _confirmationTypeLabel(confirmation.confirmationType),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _ConversationPill(
                  label: _confirmationStatusLabel(confirmation.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              confirmation.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              confirmation.summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (onOpenSoftLink != null) ...<Widget>[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpenSoftLink,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('查看入口'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
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
    required this.lockReasonText,
    required this.requiredNextAction,
    required this.onOpenRequiredAction,
    required this.onSend,
    required this.onAttachFile,
    required this.onAttachImage,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final String? lockReasonText;
  final String? requiredNextAction;
  final VoidCallback? onOpenRequiredAction;
  final VoidCallback onSend;
  final VoidCallback onAttachFile;
  final VoidCallback onAttachImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final actionLabel = _requiredActionLabel;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!enabled && lockReasonText != null) ...<Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lockReasonText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (actionLabel != null &&
                      onOpenRequiredAction != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onOpenRequiredAction,
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(actionLabel),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
                Row(
                  children: <Widget>[
                    _ComposerActionButton(
                      icon: Icons.attach_file_rounded,
                      label: '附件',
                      enabled: enabled && !sending,
                      onPressed: onAttachFile,
                    ),
                    _ComposerActionButton(
                      icon: Icons.image_outlined,
                      label: '图片',
                      enabled: enabled && !sending,
                      onPressed: onAttachImage,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: enabled && !sending,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) =>
                            enabled && !sending ? onSend() : null,
                        decoration: InputDecoration(
                          hintText: enabled ? '围绕当前项目说点什么...' : '业务节点完成后可继续沟通',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _requiredActionLabel {
    return switch (requiredNextAction) {
      'review_bid_participation' => '去处理申请',
      'confirm_publisher_materials' => '打开资料确认单',
      'submit_bid_materials' => '去提交竞标资料',
      'confirm_bid_materials' => '打开资料确认单',
      'open_deal_confirmation' => '打开成交确认',
      _ => null,
    };
  }
}

class _ComposerActionButton extends StatelessWidget {
  const _ComposerActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
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

String _formatDraftChatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatBytes(int value) {
  if (value >= 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (value >= 1024) {
    return '${(value / 1024).toStringAsFixed(1)} KB';
  }
  return '$value B';
}

String _confirmationStatusLabel(String status) {
  return switch (status) {
    'proposed' => '待确认',
    'pending' => '待确认',
    'recorded' => '已记录',
    _ => status,
  };
}

String _previewTypeLabel(String type) {
  return switch (type) {
    'image' => '图片',
    'pdf' => 'PDF',
    'text' => '文本',
    _ => '附件',
  };
}

String _confirmationSoftLinkLabel(String type) {
  return switch (type) {
    'quote' => '报价确认',
    'material' || 'material_process' => '工艺/材质确认',
    'schedule' => '排期确认',
    _ => '确认卡入口',
  };
}
