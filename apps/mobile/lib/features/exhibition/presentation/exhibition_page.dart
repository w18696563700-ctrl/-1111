import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_workbench_source.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_workbench_view_model.dart';

part 'exhibition_page_sections.dart';
part 'exhibition_page_support.dart';

class ExhibitionPage extends StatefulWidget {
  const ExhibitionPage({super.key});

  @override
  State<ExhibitionPage> createState() => _ExhibitionPageState();
}

class _ExhibitionPageState extends State<ExhibitionPage> {
  late final ExhibitionWorkbenchSource _source = ExhibitionWorkbenchAutoSource(
    consumerLayer: ExhibitionConsumerLayer.instance,
  );

  ExhibitionWorkbenchPageViewModel? _viewModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });

    final result = await _source.load(forceRefresh: forceRefresh);
    if (!mounted) {
      return;
    }

    setState(() {
      _viewModel = ExhibitionWorkbenchViewModelAdapter.fromSourceResult(result);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: const <Widget>[
          _LoadingHeroCard(title: '项目工作台加载中'),
          SizedBox(height: 16),
          _LoadingSectionCard(),
          SizedBox(height: 16),
          _LoadingSectionCard(),
          SizedBox(height: 16),
          _LoadingSectionCard(),
          SizedBox(height: 16),
          _LoadingSectionCard(),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        _WorkbenchHeroCard(
          viewModel: viewModel,
          loading: _loading,
          onRefresh: () => _load(forceRefresh: true),
        ),
        if (viewModel.bannerTitle != null &&
            viewModel.bannerMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          _StatusBanner(
            title: viewModel.bannerTitle!,
            message: viewModel.bannerMessage!,
          ),
        ],
        const SizedBox(height: 16),
        _WorkbenchContainerDeck(
          viewModel: viewModel,
          onRefresh: () => _load(forceRefresh: true),
        ),
        const SizedBox(height: 16),
        const _BoundaryFootnoteCard(),
      ],
    );
  }
}

class _WorkbenchHeroCard extends StatelessWidget {
  const _WorkbenchHeroCard({
    required this.viewModel,
    required this.loading,
    required this.onRefresh,
  });

  final ExhibitionWorkbenchPageViewModel viewModel;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _HeroPill(label: '私域入口', highlighted: true),
            const SizedBox(height: 10),
            const _HeroPill(label: '/exhibition/workbench'),
            Text(
              viewModel.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _HeroPill(label: viewModel.sourceLabel, highlighted: true),
                if (loading) const _HeroPill(label: '工作台正在整理'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: loading ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新工作台'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '当前工作台边界',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. 当前只消费四容器摘要：project_chain / order_chain / fulfillment_chain / extension_boundary。',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2. 只受控 handoff 到已冻结入口，不扩展治理台、第二 dashboard 或未冻结动作。',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '3. 当前状态说明：${viewModel.sourceMessage}',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
