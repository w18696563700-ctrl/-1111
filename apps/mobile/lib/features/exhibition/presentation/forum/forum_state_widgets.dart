import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';

import 'forum_scaffold_widgets.dart';

class ForumReadStateCard extends StatelessWidget {
  const ForumReadStateCard({
    super.key,
    required this.loading,
    required this.state,
    required this.emptyMessage,
    required this.onRetry,
    this.message,
    this.errorCode,
  });

  final bool loading;
  final AppPageState? state;
  final String emptyMessage;
  final VoidCallback onRetry;
  final String? message;
  final String? errorCode;

  @override
  Widget build(BuildContext context) {
    final resolved = loading
        ? AppPageState.loading
        : state ?? AppPageState.loading;
    final headline = switch (resolved) {
      AppPageState.loading => '正在加载',
      AppPageState.content => '内容已准备好',
      AppPageState.empty => emptyMessage,
      AppPageState.errorRetryable => message ?? '当前内容暂时没有加载出来',
      AppPageState.errorNonRetryable => message ?? '论坛接口返回异常，请重新加载',
      AppPageState.unauthorized => message ?? '请先登录后查看',
      AppPageState.forbidden => message ?? '当前账号暂不能查看',
      AppPageState.notFound => message ?? '没有找到这条论坛内容',
    };
    final body = _forumReadStateBody(state: resolved, message: message);

    return ForumSectionCard(
      eyebrow: '页面提示',
      title: headline,
      summary: body,
      children: <Widget>[
        if (resolved == AppPageState.loading) ...<Widget>[
          const SizedBox(height: 2),
          const LinearProgressIndicator(minHeight: 6),
        ],
        if (resolved == AppPageState.errorRetryable ||
            resolved == AppPageState.errorNonRetryable ||
            resolved == AppPageState.unauthorized ||
            resolved == AppPageState.forbidden ||
            resolved == AppPageState.notFound) ...<Widget>[
          const SizedBox(height: 4),
          FilledButton.tonal(onPressed: onRetry, child: const Text('重新加载')),
        ],
      ],
    );
  }
}

String _forumReadStateBody({required AppPageState state, String? message}) {
  if (_forumRouteMissingSummary(message) case final String summary) {
    return summary;
  }

  return switch (state) {
    AppPageState.loading => '请稍候片刻。',
    AppPageState.content => '现在可以继续查看了。',
    AppPageState.empty => '这里暂时还没有新的内容。',
    AppPageState.errorRetryable => '你可以稍后重试。',
    AppPageState.errorNonRetryable => '当前暂时还不能查看，请稍后再试。',
    AppPageState.unauthorized => '登录后可以继续查看。',
    AppPageState.forbidden => '当前账号暂时没有查看权限。',
    AppPageState.notFound => '这个内容现在还不能查看。',
  };
}

String? _forumRouteMissingSummary(String? message) {
  if (message == null) {
    return null;
  }
  if (!message.contains('尚未部署') || !message.contains('路由')) {
    return null;
  }
  return '这表示当前云端运行时还没有挂出对应论坛读侧接口，请先同步云端后再试。';
}

class ForumSlimStatePanel extends StatelessWidget {
  const ForumSlimStatePanel({
    super.key,
    required this.loading,
    required this.state,
    required this.emptyMessage,
    required this.onRetry,
    this.message,
  });

  final bool loading;
  final AppPageState? state;
  final String emptyMessage;
  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = loading
        ? AppPageState.loading
        : state ?? AppPageState.loading;
    final title = switch (resolved) {
      AppPageState.loading => '加载中',
      AppPageState.content => '内容已准备好',
      AppPageState.empty => emptyMessage,
      AppPageState.errorRetryable => message ?? '当前内容暂时没有加载出来',
      AppPageState.errorNonRetryable => message ?? '论坛接口返回异常',
      AppPageState.unauthorized => message ?? '请先登录后查看',
      AppPageState.forbidden => message ?? '当前账号暂不能查看',
      AppPageState.notFound => message ?? '没有找到这条论坛内容',
    };
    final showRetry = switch (resolved) {
      AppPageState.errorRetryable ||
      AppPageState.errorNonRetryable ||
      AppPageState.unauthorized ||
      AppPageState.forbidden ||
      AppPageState.notFound => true,
      _ => false,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (resolved == AppPageState.loading) ...<Widget>[
              const SizedBox(height: 10),
              const LinearProgressIndicator(minHeight: 4),
            ],
            if (showRetry) ...<Widget>[
              const SizedBox(height: 10),
              TextButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }
}

class ForumActionStateCard extends StatelessWidget {
  const ForumActionStateCard({
    super.key,
    required this.submitting,
    required this.result,
    this.successActions = const <Widget>[],
    this.failureActions = const <Widget>[],
  });

  final bool submitting;
  final AppPageState? result;
  final List<Widget> successActions;
  final List<Widget> failureActions;

  @override
  Widget build(BuildContext context) {
    final isSuccess = !submitting && result == null;
    final headline = submitting
        ? '正在提交'
        : isSuccess
        ? '可以继续操作'
        : '当前操作还没有完成';
    final summary = submitting
        ? '请稍候片刻。'
        : isSuccess
        ? '可以继续保存草稿或发布。'
        : '请先处理当前提示，再继续下一步。';

    return ForumSectionCard(
      eyebrow: '操作提示',
      title: headline,
      summary: summary,
      children: <Widget>[
        if (submitting) ...<Widget>[
          const SizedBox(height: 2),
          const LinearProgressIndicator(minHeight: 6),
        ],
        if (isSuccess && successActions.isNotEmpty)
          Wrap(spacing: 12, runSpacing: 12, children: successActions),
        if (!isSuccess && !submitting && failureActions.isNotEmpty)
          Wrap(spacing: 12, runSpacing: 12, children: failureActions),
      ],
    );
  }
}

class ForumMetricTile extends StatelessWidget {
  const ForumMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.58)
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
