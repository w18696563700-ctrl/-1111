part of '../exhibition_trade_pages.dart';

class MinimalVisualSpecPage extends StatelessWidget {
  const MinimalVisualSpecPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        const _SummaryCard(
          title: '最小视觉规范',
          summary: '冻结页面底色、信息卡、按钮、chip 和状态 badge 的最小规则；后续页面只允许在这套基线上做轻量扩展。',
          eyebrow: '基线',
          highlights: <String>['纯白底', '单层卡片', '主次分明'],
          footnote: '目标不是更花，而是更清楚、更一致、更稳。',
        ),
        const SizedBox(height: 16),
        const _ActionCard(
          title: '按钮、Chip 与状态 Badge',
          summary: '品牌色只留给主路径；次级动作、筛选和状态提示全部回到中性体系。',
          tone: _ActionCardTone.emphasis,
          children: <Widget>[_SpecControlShowcase()],
        ),
        const SizedBox(height: 16),
        _ActionCard(
          title: '页面底色与信息卡',
          summary: '页面只保留纯白底和一层信息卡，减少卡片套卡片的装修感。',
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final isWide = constraints.maxWidth >= 520;
                final sampleWidth = isWide
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    SizedBox(
                      width: sampleWidth,
                      child: _SpecTile(
                        title: '页面底色',
                        note: '#FFFFFF，避免全页暖底抢戏。',
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: const SizedBox(height: 56),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: sampleWidth,
                      child: _SpecTile(
                        title: '信息卡',
                        note: '白底 + 细描边 + 轻阴影，只保留一层承载。',
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.04,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '卡片标题',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(height: 8),
                                Text('次级说明留在中性灰，不再叠多层色块。'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _ActionCard(
          title: '冻结规则',
          summary: '后续列表页、详情页、表单页都按这 6 条执行，不再局部另起一套配色。',
          children: <Widget>[
            _SpecRuleItem(title: '页面底色', body: '统一纯白，次级背景只允许极浅中性色。'),
            SizedBox(height: 10),
            _SpecRuleItem(title: '信息卡', body: '一层卡片承载信息，不叠多个彩色容器。'),
            SizedBox(height: 10),
            _SpecRuleItem(title: '主按钮', body: '只保留一个主按钮，承担当前页面的主路径。'),
            SizedBox(height: 10),
            _SpecRuleItem(title: '次按钮', body: '统一描边，不再用 tonal 形成第二主角。'),
            SizedBox(height: 10),
            _SpecRuleItem(title: 'Chip', body: '仅做筛选与摘要，默认中性，不承担品牌展示。'),
            SizedBox(height: 10),
            _SpecRuleItem(title: '状态 Badge', body: '默认中性，只有当前选中或关键状态才使用暖棕强调。'),
          ],
        ),
      ],
    );
  }
}

class _SpecControlShowcase extends StatelessWidget {
  const _SpecControlShowcase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(onPressed: () {}, child: const Text('主按钮')),
            OutlinedButton(onPressed: () {}, child: const Text('次按钮')),
            TextButton(onPressed: () {}, child: const Text('文字动作')),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            Chip(
              label: const Text('筛选 Chip'),
              side: BorderSide(color: colorScheme.outlineVariant),
              backgroundColor: colorScheme.surface,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Chip(
              label: const Text('摘要 Chip'),
              side: BorderSide(color: colorScheme.outlineVariant),
              backgroundColor: colorScheme.surfaceContainerLowest,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const _StatusPill(label: '默认状态'),
            const _StatusPill(label: '当前状态', tone: _ActionCardTone.emphasis),
            const _StatusPill(label: '次级状态', tone: _ActionCardTone.muted),
          ],
        ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              '当前页只允许一个有色主按钮。其余动作、筛选和状态反馈全部退回中性层级。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({
    required this.title,
    required this.note,
    required this.child,
  });

  final String title;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _SpecRuleItem extends StatelessWidget {
  const _SpecRuleItem({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text.rich(
      TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.45,
        ),
        children: <InlineSpan>[
          TextSpan(
            text: '$title：',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: body),
        ],
      ),
    );
  }
}
