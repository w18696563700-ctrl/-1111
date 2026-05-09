import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/shared/ui/app_visual_components.dart';
import 'package:mobile/shared/ui/app_visual_tokens.dart';

enum AppPageStateViewScope { fullPage, list, card }

class AppPageStateView extends StatelessWidget {
  const AppPageStateView({
    super.key,
    required this.state,
    required this.content,
    this.title,
    this.message,
    this.retryLabel = '重试',
    this.onRetry,
    this.scope = AppPageStateViewScope.fullPage,
  });

  final AppPageState state;
  final Widget content;
  final String? title;
  final String? message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final AppPageStateViewScope scope;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AppPageState.loading => _wrap(
        context,
        _StateBody(
          title: title ?? '正在加载',
          message: message ?? '当前内容正在读取，请稍候。',
          progress: true,
        ),
      ),
      AppPageState.empty => _wrap(
        context,
        _StateBody(
          title: title ?? '暂无内容',
          message: message ?? '当前还没有可展示的内容。',
          action: onRetry == null
              ? null
              : OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
        ),
      ),
      AppPageState.errorRetryable => _wrap(
        context,
        _StateBody(
          title: title ?? '当前内容暂不可用',
          message: message ?? '请稍后重试。',
          action: onRetry == null
              ? null
              : OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
        ),
      ),
      AppPageState.errorNonRetryable ||
      AppPageState.unauthorized ||
      AppPageState.forbidden ||
      AppPageState.notFound => _wrap(
        context,
        _StateBody(
          title: title ?? _fallbackTitle(state),
          message: message ?? _fallbackMessage(state),
          action: onRetry == null
              ? null
              : OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
        ),
      ),
      AppPageState.content => content,
    };
  }

  Widget _wrap(BuildContext context, Widget child) {
    return switch (scope) {
      AppPageStateViewScope.fullPage => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
      AppPageStateViewScope.list => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: child,
      ),
      AppPageStateViewScope.card => child,
    };
  }

  static String _fallbackTitle(AppPageState state) {
    return switch (state) {
      AppPageState.errorNonRetryable => '当前内容暂不可用',
      AppPageState.unauthorized => '需要登录',
      AppPageState.forbidden => '暂无权限',
      AppPageState.notFound => '内容不存在',
      _ => '当前内容暂不可用',
    };
  }

  static String _fallbackMessage(AppPageState state) {
    return switch (state) {
      AppPageState.errorNonRetryable => '当前能力暂不可继续，请稍后再试。',
      AppPageState.unauthorized => '请登录后继续查看。',
      AppPageState.forbidden => '当前账号暂不能查看此内容。',
      AppPageState.notFound => '当前内容暂未开放或已经不存在。',
      _ => '请稍后重试。',
    };
  }
}

class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.title,
    required this.message,
    this.progress = false,
    this.action,
  });

  final String title;
  final String message;
  final bool progress;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (progress) ...<Widget>[
            const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(height: 12),
          ],
          Text(title, style: AppTextTokens.cardTitle),
          const SizedBox(height: 8),
          Text(message, style: AppTextTokens.body),
          if (action != null) ...<Widget>[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}
