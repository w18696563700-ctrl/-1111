import 'package:flutter/material.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_case_detail_sheet.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

class EnterpriseDetailHeroBanner extends StatelessWidget {
  const EnterpriseDetailHeroBanner({
    super.key,
    required this.header,
    required this.boardProfile,
    required this.visualGallery,
  });

  final EnterpriseHubHeader header;
  final Map<String, Object?> boardProfile;
  final EnterpriseHubVisualGallery visualGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = _detailTitle(header, boardProfile);
    final companyLine = _detailCompanyLine(header, boardProfile);
    final previewUrl = visualGallery.imageUrls.firstOrNull ?? header.logoUrl;
    final heroHighlight = _heroHighlightText(
      header.primaryBoardType,
      boardProfile,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.surfaceContainerLowest,
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _EnterpriseDetailHeroLogo(
                  title: title,
                  logoUrl: header.logoUrl,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _DetailPill(label: header.primaryBoardType.title),
                          if (header.verificationStatus != null)
                            _DetailPill(
                              label: '认证 ${header.verificationStatus}',
                            ),
                          ...header.secondaryCapabilities.map(
                            (EnterpriseBoardType item) =>
                                _DetailPill(label: item.title),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (companyLine != null) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          companyLine,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        header.shortIntro,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                      if (heroHighlight != null) ...<Widget>[
                        const SizedBox(height: 12),
                        _DetailHeroHighlight(text: heroHighlight),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                _EnterpriseDetailHeroPreview(imageUrl: previewUrl),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _DetailStatPill(
                  label: '地区',
                  value: '${header.provinceName} · ${header.cityName}',
                ),
                if (boardProfile['factoryName'] case final String factoryName
                    when factoryName.trim().isNotEmpty)
                  _DetailStatPill(label: '工厂名', value: factoryName.trim()),
                if (header.shortIntro.trim().isNotEmpty)
                  _DetailStatPill(label: '概述', value: header.shortIntro.trim()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EnterpriseDetailVisualGallerySection extends StatefulWidget {
  const EnterpriseDetailVisualGallerySection({
    super.key,
    required this.visualGallery,
    this.footer,
  });

  final EnterpriseHubVisualGallery visualGallery;
  final Widget? footer;

  @override
  State<EnterpriseDetailVisualGallerySection> createState() =>
      _EnterpriseDetailVisualGallerySectionState();
}

class _EnterpriseDetailVisualGallerySectionState
    extends State<EnterpriseDetailVisualGallerySection> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _galleryImages(widget.visualGallery);
    final gallerySourceLabel = _gallerySourceLabel(widget.visualGallery);
    if (images.isEmpty) {
      return const EnterpriseSectionCard(
        title: '企业画册',
        subtitle: '当前还没有可展示的企业画册图片。',
        child: _EnterpriseGalleryEmptyState(),
      );
    }

    return EnterpriseSectionCard(
      title: '企业画册',
      subtitle: '$gallerySourceLabel · 最多展示 6 张',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _controller,
                itemCount: images.length,
                onPageChanged: (int index) => setState(() => _page = index),
                itemBuilder: (BuildContext context, int index) {
                  return _EnterpriseNetworkImageFrame(imageUrl: images[index]);
                },
              ),
            ),
          ),
          if (images.length > 1) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                images.length,
                (int index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '企业画册只消费 `visualGallery.albumImageUrls`，最多展示 6 张，并按当前顺序左右滑动。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (widget.footer != null) ...<Widget>[
            const SizedBox(height: 14),
            widget.footer!,
          ],
        ],
      ),
    );
  }
}

class EnterpriseTargetEnterpriseInfoEntryCard extends StatelessWidget {
  const EnterpriseTargetEnterpriseInfoEntryCard({
    super.key,
    required this.shellContext,
    required this.onPressed,
  });

  final AppShellContextData shellContext;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accessible = _hasTargetEnterpriseInfoPreviewAccess(shellContext);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      key: const ValueKey<String>(
        'enterprise-target-enterprise-info-entry-card',
      ),
      borderRadius: BorderRadius.circular(18),
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: accessible
              ? colorScheme.primaryContainer.withValues(alpha: 0.55)
              : colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              accessible
                  ? Icons.verified_user_outlined
                  : Icons.lock_outline_rounded,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '查看企业信息',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accessible
                        ? '点击后查看当前权限允许访问的企业认证信息。'
                        : '当前仅展示锁定态，可见信息仍由云端权限返回决定。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class EnterpriseDetailCapabilitySection extends StatelessWidget {
  const EnterpriseDetailCapabilitySection({
    super.key,
    required this.boardType,
    required this.boardProfile,
  });

  final EnterpriseBoardType boardType;
  final Map<String, Object?> boardProfile;

  @override
  Widget build(BuildContext context) {
    final children = switch (boardType) {
      EnterpriseBoardType.company => _buildCompanyBlocks(context),
      EnterpriseBoardType.factory => _buildFactoryBlocks(context),
      EnterpriseBoardType.supplier => _buildSupplierBlocks(context),
    };

    return EnterpriseSectionCard(
      title: '核心能力',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  List<Widget> _buildCompanyBlocks(BuildContext context) {
    return <Widget>[
      _DetailCapabilityBlock(
        title: '展会类型',
        values: _stringList(boardProfile['exhibitionTypes']),
      ),
      const SizedBox(height: 12),
      _DetailCapabilityBlock(
        title: '服务项目',
        values: _stringList(boardProfile['serviceItems']),
      ),
      const SizedBox(height: 12),
      _DetailCapabilityBlock(
        title: '服务城市',
        values: _stringList(boardProfile['serviceCities']),
      ),
      const SizedBox(height: 12),
      _DetailTextBlock(
        title: '最大项目规模',
        value: _string(boardProfile['maxProjectScale']) ?? '暂未补充',
      ),
      const SizedBox(height: 12),
      _DetailTextBlock(
        title: '资质说明',
        value: _string(boardProfile['qualificationDesc']) ?? '暂未补充',
      ),
    ];
  }

  List<Widget> _buildFactoryBlocks(BuildContext context) {
    final equipmentValues = _stringList(boardProfile['equipmentList']);
    return <Widget>[
      Row(
        key: const ValueKey<String>(
          'enterprise-detail-factory-capability-layout',
        ),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              key: const ValueKey<String>(
                'enterprise-detail-factory-capability-left-column',
              ),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DetailCapabilityBlock(
                  key: const ValueKey<String>(
                    'enterprise-detail-factory-process-types',
                  ),
                  title: '工艺类型',
                  values: _stringList(boardProfile['processTypes']),
                ),
                const SizedBox(height: 12),
                _DetailCapabilityBlock(
                  key: const ValueKey<String>(
                    'enterprise-detail-factory-core-products',
                  ),
                  title: '核心产品',
                  values: _stringList(boardProfile['coreProducts']),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _FactoryEquipmentColumns(values: equipmentValues)),
        ],
      ),
    ];
  }

  List<Widget> _buildSupplierBlocks(BuildContext context) {
    return <Widget>[
      _DetailCapabilityBlock(
        title: '供应品类',
        values: _stringList(boardProfile['supplyCategories']),
      ),
      const SizedBox(height: 12),
      _DetailTextBlock(
        title: '核心产品或服务',
        value: _string(boardProfile['coreProductsOrServices']) ?? '暂未补充',
      ),
      const SizedBox(height: 12),
      _DetailTextBlock(
        title: '响应时效',
        value: _string(boardProfile['responseSlaDesc']) ?? '暂未补充',
      ),
      const SizedBox(height: 12),
      _DetailTextBlock(
        title: '配送范围',
        value: _string(boardProfile['deliveryRange']) ?? '暂未补充',
      ),
    ];
  }
}

class EnterpriseDetailIntroSection extends StatelessWidget {
  const EnterpriseDetailIntroSection({
    super.key,
    required this.fullIntro,
    required this.shortIntro,
  });

  final String? fullIntro;
  final String shortIntro;

  @override
  Widget build(BuildContext context) {
    final text = _string(fullIntro) ?? shortIntro.trim();
    return EnterpriseSectionCard(
      title: '详细介绍',
      child: Text(
        text.isEmpty ? '当前还没有补充详细介绍。' : text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
      ),
    );
  }
}

class EnterpriseDetailReviewSummarySection extends StatelessWidget {
  const EnterpriseDetailReviewSummarySection({
    super.key,
    required this.reviewSummary,
  });

  final EnterpriseHubReviewSummary reviewSummary;

  @override
  Widget build(BuildContext context) {
    final hasScores =
        reviewSummary.avgScore != null ||
        reviewSummary.reviewCount != null ||
        reviewSummary.deliveryScore != null ||
        reviewSummary.qualityScore != null ||
        reviewSummary.communicationScore != null;
    if (reviewSummary.keywordTags.isEmpty && !hasScores) {
      return const SizedBox.shrink();
    }

    return EnterpriseSectionCard(
      title: '企业口碑',
      subtitle: '展示当前公开详情已返回的评价摘要，不派生第二套评价真值。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasScores)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (reviewSummary.avgScore != null)
                  _DetailStatPill(
                    label: '综合评分',
                    value: reviewSummary.avgScore!.toStringAsFixed(1),
                  ),
                if (reviewSummary.reviewCount != null)
                  _DetailStatPill(
                    label: '评价数',
                    value: '${reviewSummary.reviewCount}',
                  ),
                if (reviewSummary.deliveryScore != null)
                  _DetailStatPill(
                    label: '交付',
                    value: reviewSummary.deliveryScore!.toStringAsFixed(1),
                  ),
                if (reviewSummary.qualityScore != null)
                  _DetailStatPill(
                    label: '质量',
                    value: reviewSummary.qualityScore!.toStringAsFixed(1),
                  ),
                if (reviewSummary.communicationScore != null)
                  _DetailStatPill(
                    label: '沟通',
                    value: reviewSummary.communicationScore!.toStringAsFixed(1),
                  ),
              ],
            ),
          if (reviewSummary.keywordTags.isNotEmpty) ...<Widget>[
            if (hasScores) const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reviewSummary.keywordTags
                  .map((String tag) => Chip(label: Text(tag)))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class EnterpriseDetailCaseSection extends StatelessWidget {
  const EnterpriseDetailCaseSection({super.key, required this.items});

  final List<EnterpriseHubCaseCard> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EnterpriseSectionCard(
        title: '案例展示',
        subtitle: '当前还没有公开案例。',
        child: _EnterpriseGalleryEmptyState(message: '暂无公开案例'),
      );
    }

    return EnterpriseSectionCard(
      title: '案例展示',
      subtitle: '案例会继续保留为独立内容，不混入企业画册。',
      child: Column(
        children: items
            .map(
              (EnterpriseHubCaseCard item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EnterpriseCasePreviewCard(item: item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class EnterpriseDetailContactSection extends StatelessWidget {
  const EnterpriseDetailContactSection({super.key, required this.items});

  final List<EnterpriseHubContactCard> items;

  @override
  Widget build(BuildContext context) {
    return EnterpriseSectionCard(
      title: '联系方式',
      child: items.isEmpty
          ? const Text('当前未返回联系方式。')
          : Column(
              children: items
                  .map(
                    (EnterpriseHubContactCard item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EnterpriseContactCard(item: item),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _EnterpriseDetailHeroLogo extends StatelessWidget {
  const _EnterpriseDetailHeroLogo({required this.title, required this.logoUrl});

  final String title;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 72,
        height: 72,
        color: colorScheme.surfaceContainerHighest,
        child: _buildImageOrPlaceholder(
          logoUrl,
          fallback: _firstCharacterOrFallback(title, '企'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _EnterpriseDetailHeroPreview extends StatelessWidget {
  const _EnterpriseDetailHeroPreview({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 108,
        height: 108,
        child: _buildImageOrPlaceholder(
          imageUrl,
          fallback: '画',
          fit: BoxFit.cover,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DetailHeroHighlight extends StatelessWidget {
  const _DetailHeroHighlight({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

class _DetailStatPill extends StatelessWidget {
  const _DetailStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text('$label · $value'),
      ),
    );
  }
}

class _DetailCapabilityBlock extends StatelessWidget {
  const _DetailCapabilityBlock({
    super.key,
    required this.title,
    required this.values,
  });

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        values.isEmpty
            ? const Text('暂未补充')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: values
                    .map((String value) => Chip(label: Text(value)))
                    .toList(growable: false),
              ),
      ],
    );
  }
}

class _DetailTextBlock extends StatelessWidget {
  const _DetailTextBlock({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(value),
      ],
    );
  }
}

class _FactoryEquipmentColumns extends StatelessWidget {
  const _FactoryEquipmentColumns({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final columns = <List<String>>[];
    for (var index = 0; index < values.length; index += 3) {
      final end = index + 3 > values.length ? values.length : index + 3;
      columns.add(values.sublist(index, end));
    }
    return Column(
      key: const ValueKey<String>(
        'enterprise-detail-factory-equipment-columns',
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '设备清单',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (columns.isEmpty)
          const Text('暂未补充')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (
                  var index = 0;
                  index < columns.length;
                  index += 1
                ) ...<Widget>[
                  _FactoryEquipmentColumn(
                    key: ValueKey<String>(
                      'enterprise-detail-factory-equipment-column-$index',
                    ),
                    values: columns[index],
                  ),
                  if (index != columns.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _FactoryEquipmentColumn extends StatelessWidget {
  const _FactoryEquipmentColumn({super.key, required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 96, maxWidth: 132),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: values
            .map(
              (String value) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(label: Text(value)),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _EnterpriseGalleryEmptyState extends StatelessWidget {
  const _EnterpriseGalleryEmptyState({this.message = '当前还没有可展示的企业画册图片。'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(message),
    );
  }
}

class _EnterpriseCasePreviewCard extends StatelessWidget {
  const _EnterpriseCasePreviewCard({required this.item});

  final EnterpriseHubCaseCard item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey<String>('enterprise-detail-case-card-${item.id}'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => showEnterpriseCaseDetailSheet(context, item: item),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
            color: colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: _buildImageOrPlaceholder(
                    item.coverImageUrl,
                    fallback: '案',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DetailPill(label: item.caseStatus),
                      ],
                    ),
                    if (item.eventTime != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        item.eventTime!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnterpriseContactCard extends StatelessWidget {
  const _EnterpriseContactCard({required this.item});

  final EnterpriseHubContactCard item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              child: Text(_firstCharacterOrFallback(item.contactName, '联')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.contactName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    <String>[
                      if (item.position != null) item.position!,
                      if (item.mobile != null) '手机 ${item.mobile}',
                      if (item.phone != null) '电话 ${item.phone}',
                      if (item.wechat != null) '微信 ${item.wechat}',
                      if (item.email != null) item.email!,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildImageOrPlaceholder(
  String? imageUrl, {
  required String fallback,
  BoxFit fit = BoxFit.cover,
  Color? backgroundColor,
}) {
  final url = imageUrl?.trim();
  if (url != null && url.isNotEmpty) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) {
              return child;
            }
            return _imagePlaceholder(
              fallback: fallback,
              backgroundColor: backgroundColor,
            );
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return _imagePlaceholder(
              fallback: fallback,
              backgroundColor: backgroundColor,
            );
          },
    );
  }
  return _imagePlaceholder(
    fallback: fallback,
    backgroundColor: backgroundColor,
  );
}

class _EnterpriseNetworkImageFrame extends StatelessWidget {
  const _EnterpriseNetworkImageFrame({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return _buildImageOrPlaceholder(
      imageUrl,
      fallback: '画',
      fit: BoxFit.cover,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

Widget _imagePlaceholder({required String fallback, Color? backgroundColor}) {
  return Container(
    color: backgroundColor ?? Colors.transparent,
    alignment: Alignment.center,
    child: Text(
      fallback,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
    ),
  );
}

List<String> _galleryImages(EnterpriseHubVisualGallery visualGallery) {
  return visualGallery.galleryImageUrls.take(6).toList(growable: false);
}

String _gallerySourceLabel(EnterpriseHubVisualGallery visualGallery) {
  return visualGallery.source;
}

String _detailTitle(
  EnterpriseHubHeader header,
  Map<String, Object?> boardProfile,
) {
  if (header.primaryBoardType == EnterpriseBoardType.factory) {
    final value = _string(boardProfile['factoryName']);
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return header.name;
}

String? _detailCompanyLine(
  EnterpriseHubHeader header,
  Map<String, Object?> boardProfile,
) {
  if (header.primaryBoardType != EnterpriseBoardType.factory) {
    return null;
  }
  final factoryName = _string(boardProfile['factoryName']);
  if (factoryName == null || factoryName == header.name) {
    return null;
  }
  return '所属公司：${header.name}';
}

String? _heroHighlightText(
  EnterpriseBoardType boardType,
  Map<String, Object?> boardProfile,
) {
  return switch (boardType) {
    EnterpriseBoardType.company =>
      _string(boardProfile['qualificationDesc']) ??
          _string(boardProfile['maxProjectScale']),
    EnterpriseBoardType.factory =>
      _string(boardProfile['monthlyCapacityDesc']) ??
          _stringListPreview(boardProfile['coreProducts']) ??
          _stringListPreview(boardProfile['processTypes']),
    EnterpriseBoardType.supplier =>
      _string(boardProfile['responseSlaDesc']) ??
          _string(boardProfile['deliveryRange']) ??
          _string(boardProfile['coreProductsOrServices']),
  };
}

List<String> _stringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw
      .whereType<String>()
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

String? _stringListPreview(Object? raw) {
  final items = _stringList(raw);
  if (items.isEmpty) {
    return null;
  }
  return items.take(3).join(' / ');
}

String? _string(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

bool _hasTargetEnterpriseInfoPreviewAccess(AppShellContextData shellContext) {
  final certificationApproved = _isApprovedStatus(
    shellContext.certificationStatus,
  );
  final personalApproved =
      _isApprovedStatus(shellContext.personalCertificationStatus) &&
      shellContext.personalCertificationQualified != false &&
      shellContext.personalCertificationLockedToOtherActor != true;
  return certificationApproved && personalApproved;
}

bool _isApprovedStatus(String? value) {
  final normalized = value?.trim().toLowerCase();
  return normalized == 'approved' || normalized == 'verified';
}

String _firstCharacterOrFallback(String value, String fallback) {
  final characters = value.characters;
  return characters.isEmpty ? fallback : characters.first;
}
