part of '../exhibition_trade_pages.dart';

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _MethodPathPanel extends StatelessWidget {
  const _MethodPathPanel({required this.method, required this.path});

  final String method;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Chip(label: Text(method)),
        SelectableText(path, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _InstanceSummaryLine extends StatelessWidget {
  const _InstanceSummaryLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      '$title：$value',
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _ContractToken extends StatelessWidget {
  const _ContractToken({required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    return Text(
      '页面承接：${_pageStateLabel(token)}',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

String _pageStateLabel(String token) {
  return switch (token) {
    'loading' => '读取中',
    'content' => '已承接内容',
    'empty' => '当前为空',
    'error_retryable' => '可重试',
    'error_non_retryable' => '受控失败',
    'unauthorized' => '未授权',
    'forbidden' => '当前不可进入',
    'not_found' => '未找到',
    _ => token,
  };
}

class _ContractLoadingCard extends StatelessWidget {
  const _ContractLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('正在读取当前内容', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _PayloadPreview extends StatelessWidget {
  const _PayloadPreview({required this.payload, this.label = '技术详情'});

  final Object? payload;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = payload == null
        ? 'null'
        : payload is String
        ? payload as String
        : const JsonEncoder.withIndent('  ').convert(payload);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SelectableText(text),
      ],
    );
  }
}

class _TechnicalDisclosure extends StatelessWidget {
  const _TechnicalDisclosure({
    this.title = '开发辅助（默认收起）',
    this.method,
    this.path,
    this.payload,
    this.payloadLabel,
  });

  final String title;
  final String? method;
  final String? path;
  final Object? payload;
  final String? payloadLabel;

  @override
  Widget build(BuildContext context) {
    if (method == null && path == null && payload == null) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 8),
      title: Text(title),
      children: <Widget>[
        if (method != null && path != null) ...<Widget>[
          _MethodPathPanel(method: method!, path: path!),
          if (payload != null) const SizedBox(height: 12),
        ],
        if (payload != null)
          _PayloadPreview(payload: payload, label: payloadLabel ?? '技术详情'),
      ],
    );
  }
}
