part of '../exhibition_trade_pages.dart';

class _LoadStateCard extends StatelessWidget {
  const _LoadStateCard({
    required this.result,
    required this.onRetry,
    this.showTechnicalDisclosure = false,
    this.recoveryRouteOverride,
    this.recoveryButtonLabelOverride,
  });

  final ExhibitionLoadResult result;
  final VoidCallback onRetry;
  final bool showTechnicalDisclosure;
  final String? recoveryRouteOverride;
  final String? recoveryButtonLabelOverride;

  @override
  Widget build(BuildContext context) {
    final entityState = _stateFromPayload(result.payload);
    final rawMessage = result.message;
    final stateMessage = switch (result.state) {
      AppPageState.loading => '当前内容仍在准备中，请稍候。',
      AppPageState.content => _frontStageLoadMessage(path: result.path),
      AppPageState.empty => '当前链路暂时没有可继续的内容，页面先停留在空态承接面。',
      AppPageState.errorRetryable => _userFacingLoadFailureMessage(result),
      AppPageState.errorNonRetryable => _userFacingLoadFailureMessage(result),
      AppPageState.unauthorized => _userFacingLoadFailureMessage(result),
      AppPageState.forbidden => _userFacingLoadFailureMessage(result),
      AppPageState.notFound => _userFacingLoadFailureMessage(result),
    };
    final showRawFailureMessage =
        rawMessage != null &&
        rawMessage != stateMessage &&
        !_isTransportTechnicalMessage(rawMessage) &&
        _shouldExposeRawFailureMessage(result.path, rawMessage);
    final showRecoveryActions = switch (result.state) {
      AppPageState.content => false,
      AppPageState.empty => false,
      _ => true,
    };

    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _StatusPill(
                  label: _loadStateLabel(result.state),
                  tone: result.state == AppPageState.content
                      ? _ActionCardTone.emphasis
                      : _ActionCardTone.muted,
                ),
                if (entityState != null)
                  _StatusPill(
                    label: '业务状态：${_frontStageStateLabel(entityState)}',
                    tone: _ActionCardTone.standard,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _StateMessage(title: '当前状态', body: stateMessage),
            if (showRawFailureMessage) ...<Widget>[
              const SizedBox(height: 12),
              Text(rawMessage),
            ],
            const SizedBox(height: 12),
            Text(
              _loadStateActionHint(result),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (showRecoveryActions) ...<Widget>[
              const SizedBox(height: 12),
              _RecoveryActions(
                path: result.path,
                onRetry: result.state == AppPageState.errorRetryable
                    ? onRetry
                    : null,
                routeOverride: recoveryRouteOverride,
                buttonLabelOverride: recoveryButtonLabelOverride,
              ),
            ],
            if (showTechnicalDisclosure) ...<Widget>[
              const SizedBox(height: 12),
              _ContractToken(token: result.state.contractName),
            ],
            if (showTechnicalDisclosure) ...<Widget>[
              const SizedBox(height: 16),
              _TechnicalDisclosure(
                method: result.method,
                path: result.path,
                payload: result.state == AppPageState.content
                    ? result.payload
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmissionResultPanel extends StatelessWidget {
  const _SubmissionResultPanel({
    required this.result,
    this.showTechnicalDisclosure = false,
  });

  final ExhibitionActionResult result;
  final bool showTechnicalDisclosure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = result.isSuccess
        ? colorScheme.primary.withValues(alpha: 0.18)
        : colorScheme.outlineVariant;
    final entityStateLabel = _submissionResultStateLabel(result);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _StatusPill(
                  label: result.isSuccess ? '结果已返回' : '需要处理反馈',
                  tone: result.isSuccess
                      ? _ActionCardTone.emphasis
                      : _ActionCardTone.muted,
                ),
                if (entityStateLabel != null)
                  _StatusPill(
                    label: '业务状态：$entityStateLabel',
                    tone: _ActionCardTone.muted,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              result.isSuccess ? '当前动作已完成' : '当前动作未完成',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.isSuccess
                  ? _frontStageSuccessMessage(path: result.path)
                  : _userFacingActionFailureMessage(result),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _actionFollowUpMessage(result),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (!result.isSuccess) ...<Widget>[
              const SizedBox(height: 12),
              _RecoveryActions(path: result.path),
            ],
            if (showTechnicalDisclosure) ...<Widget>[
              const SizedBox(height: 12),
              Theme(
                data: theme.copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: _TechnicalDisclosure(
                  method: result.method,
                  path: result.path,
                  payload: <String, Object?>{
                    if (result.controlledState != null)
                      'controlledState': result.controlledState!.contractName,
                    if (result.errorCode != null) 'errorCode': result.errorCode,
                    if (result.payload != null) 'payload': result.payload,
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String? _submissionResultStateLabel(ExhibitionActionResult result) {
  if (result.path == ExhibitionCanonicalPaths.projectCounterpartyRatingSubmit) {
    final payload = _payloadMap(result.payload);
    final state = _counterpartyRatingState(payload);
    return state == null ? null : _counterpartyRatingStateLabel(state);
  }
  final state = _stateFromPayload(result.payload);
  return state == null ? null : _frontStageStateLabel(state);
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(body),
      ],
    );
  }
}

class _RecoveryActions extends StatelessWidget {
  const _RecoveryActions({
    required this.path,
    this.onRetry,
    this.routeOverride,
    this.buttonLabelOverride,
  });

  final String path;
  final VoidCallback? onRetry;
  final String? routeOverride;
  final String? buttonLabelOverride;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        if (onRetry != null)
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        if (onRetry != null)
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                routeOverride ?? _recoveryRouteForPath(path),
              );
            },
            child: Text(
              buttonLabelOverride ?? _recoveryButtonLabelForPath(path),
            ),
          )
        else
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                routeOverride ?? _recoveryRouteForPath(path),
              );
            },
            child: Text(
              buttonLabelOverride ?? _recoveryButtonLabelForPath(path),
            ),
          ),
      ],
    );
  }
}

class _SubmittingPanel extends StatelessWidget {
  const _SubmittingPanel();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('提交中', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '页面正在整理本次动作结果，稍后会自动给出结果反馈和后续承接。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UploadStatePanel extends StatelessWidget {
  const _UploadStatePanel({
    required this.state,
    required this.path,
    required this.message,
    required this.errorCode,
    required this.uploadDirective,
  });

  final AppUploadState? state;
  final String? path;
  final String? message;
  final String? errorCode;
  final UploadDirective? uploadDirective;

  @override
  Widget build(BuildContext context) {
    if (state == null) {
      return const Text('如需补充凭证，可在这里继续执行当前页面里的上传步骤。');
    }

    final uploadTitle = _userFacingUploadTitle(state!);
    final uploadMessage = _userFacingUploadMessage(
      state: state!,
      message: message,
      path: path,
    );
    final nextStep = _userFacingUploadNextStep(state!);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              uploadTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(uploadMessage),
            const SizedBox(height: 12),
            Text(
              nextStep,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _TechnicalDisclosure(
              title: '开发辅助（默认收起）',
              payload: <String, Object?>{
                if (path != null) 'path': path,
                if (errorCode != null) 'errorCode': errorCode,
                if (uploadDirective != null)
                  'uploadSessionId': uploadDirective!.uploadSessionId,
                if (uploadDirective != null)
                  'directMethod': uploadDirective!.directUploadMethod,
                if (uploadDirective != null)
                  'confirmEndpoint': uploadDirective!.confirmEndpoint,
              },
            ),
          ],
        ),
      ),
    );
  }
}
