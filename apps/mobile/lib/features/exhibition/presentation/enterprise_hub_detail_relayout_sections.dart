import 'package:flutter/material.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_company_hero_overlay.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';
import 'package:mobile/features/exhibition/presentation/presentation_support/external_map_launcher.dart';

class EnterpriseDetailOverviewCard extends StatefulWidget {
  const EnterpriseDetailOverviewCard({super.key, required this.data});

  final EnterpriseHubDetailData data;

  @override
  State<EnterpriseDetailOverviewCard> createState() =>
      _EnterpriseDetailOverviewCardState();
}

class _EnterpriseDetailOverviewCardState
    extends State<EnterpriseDetailOverviewCard> {
  late final PageController _heroPageController;
  int _heroPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController();
  }

  @override
  void dispose() {
    _heroPageController.dispose();
    super.dispose();
  }

  Future<void> _showNextHeroImage(int imageCount) async {
    if (imageCount <= 1 || !_heroPageController.hasClients) {
      return;
    }
    final nextIndex = (_heroPageIndex + 1) % imageCount;
    await _heroPageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompany =
        widget.data.header.primaryBoardType == EnterpriseBoardType.company;
    final heroImages = widget.data.visualGallery.imageUrls;
    final fallbackHeroImageUrl = widget.data.header.logoUrl;
    final heroSection = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (heroImages.isEmpty)
              EnterpriseDetailImageFrame(
                imageUrl: fallbackHeroImageUrl,
                fallback:
                    enterpriseDetailDisplayName(
                      widget.data,
                    ).characters.firstOrNull ??
                    '企',
              )
            else
              PageView.builder(
                controller: _heroPageController,
                itemCount: heroImages.length,
                onPageChanged: (int index) {
                  if (_heroPageIndex == index) {
                    return;
                  }
                  setState(() => _heroPageIndex = index);
                },
                itemBuilder: (BuildContext context, int index) {
                  return EnterpriseDetailImageFrame(
                    imageUrl: heroImages[index],
                    fallback:
                        enterpriseDetailDisplayName(
                          widget.data,
                        ).characters.firstOrNull ??
                        '企',
                  );
                },
              ),
            // Keep the visual overlay transparent to pointer events so the
            // hero carousel remains swipeable through the title and pills.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: isCompany ? 0.16 : 0.06),
                      Colors.black.withValues(alpha: isCompany ? 0.44 : 0.34),
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: EnterpriseDetailCompanyHeroOverlay(data: widget.data),
            ),
            // Desktop simulators still need an explicit click path for album
            // switching, so this next-button is part of the frozen behavior.
            if (heroImages.length > 1)
              Positioned(
                top: 0,
                right: 12,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _EnterpriseDetailHeroNextButton(
                    onPressed: () => _showNextHeroImage(heroImages.length),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: heroSection,
    );
  }
}

class _EnterpriseDetailHeroNextButton extends StatelessWidget {
  const _EnterpriseDetailHeroNextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: const ValueKey<String>('enterprise-detail-hero-next-button'),
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SizedBox(
          width: 34,
          height: 78,
          child: Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.92),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class EnterpriseDetailLocationSection extends StatelessWidget {
  const EnterpriseDetailLocationSection({super.key, required this.data});

  final EnterpriseHubDetailData data;

  @override
  Widget build(BuildContext context) {
    final areas = enterpriseDetailServiceAreaLabels(data);
    final location = data.location;
    final address = location.displayAddress ?? data.basicInfo.address?.trim();
    final isResolved = location.isResolved;
    return EnterpriseSectionCard(
      title: '地址与服务区域',
      subtitle: isResolved
          ? '当前公开详情已返回可展示坐标，优先用地图模式呈现企业位置。'
          : '当前公开详情先展示地址与服务范围；坐标未返回前不伪造地图能力。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          EnterpriseDetailInfoRow(
            label: '所在地区',
            value:
                '${location.provinceName ?? data.header.provinceName} · ${location.cityName ?? data.header.cityName}',
          ),
          const SizedBox(height: 12),
          EnterpriseDetailInfoRow(
            label: '详细地址',
            value: address == null || address.isEmpty ? '当前未返回详细地址。' : address,
          ),
          const SizedBox(height: 12),
          Text(
            '服务区域',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          CapabilityTagGroup(tags: areas, emptyLabel: '当前未返回服务区域，先以企业所在城市为准。'),
          const SizedBox(height: 14),
          _EnterpriseDetailLocationMapCard(location: location),
        ],
      ),
    );
  }
}

class _EnterpriseDetailLocationMapCard extends StatelessWidget {
  const _EnterpriseDetailLocationMapCard({required this.location});

  final EnterpriseHubLocationData location;

  Future<void> _openMap(BuildContext context) async {
    final mapLinkUrl = location.mapLinkUrl?.trim();
    if (!location.hasCoordinates &&
        (mapLinkUrl == null || mapLinkUrl.isEmpty)) {
      return;
    }
    try {
      final opened = await launchExternalMapWithFallback(
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.displayAddress,
        mapLinkUrl: mapLinkUrl,
      );
      if (opened) {
        return;
      }
    } catch (_) {
      // The user-facing fallback is shown below.
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('当前设备暂时无法直接打开地图，请稍后再试。')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayAddress = location.displayAddress ?? '当前企业位置已解析。';
    final mapLinkUrl = location.mapLinkUrl?.trim();
    final canOpenMap =
        location.hasCoordinates ||
        (mapLinkUrl != null && mapLinkUrl.isNotEmpty);
    if (location.hasMapPreview) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 25 / 12,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    location.mapPreviewUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) => DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.55,
                                ),
                                colorScheme.surfaceContainerHighest,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.map_rounded, size: 40),
                          ),
                        ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: FilledButton.tonalIcon(
                      onPressed: canOpenMap ? () => _openMap(context) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('查看地图'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    displayAddress,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.place_outlined, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mapLinkUrl == null || mapLinkUrl.isEmpty
                              ? '当前已解析出可展示坐标，地图预览已接通。'
                              : '当前地址与地图落点已对齐，可直接打开地图查看。',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final message = switch (location.geoStatus) {
      'text_only' => '当前只同步了文字地址，还没有解析出地图坐标。',
      'failed' => '当前企业位置解析失败，请在工作台校正地址后重新解析。',
      'resolved' => '当前已返回坐标，但缺少可展示的地图预览或打开链接。',
      _ => '当前公开详情还没有返回可用坐标，先按文字地址展示企业位置。',
    };
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 152,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.primaryContainer.withValues(alpha: 0.7),
                  colorScheme.surfaceContainerHighest,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.map_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '地图模式',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (canOpenMap)
                      FilledButton.tonalIcon(
                        onPressed: () => _openMap(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('查看地图'),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  displayAddress,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.info_outline),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EnterpriseDetailTrustSection extends StatelessWidget {
  const EnterpriseDetailTrustSection({
    super.key,
    required this.certifications,
    required this.reviewSummary,
    required this.shellContext,
    required this.onOpenTargetEnterpriseInfo,
  });

  final List<EnterpriseHubCertificationCard> certifications;
  final EnterpriseHubReviewSummary reviewSummary;
  final AppShellContextData shellContext;
  final VoidCallback onOpenTargetEnterpriseInfo;

  @override
  Widget build(BuildContext context) {
    final statItems = <EnterpriseDetailMetricItem>[
      if (reviewSummary.avgScore != null)
        EnterpriseDetailMetricItem(
          label: '综合评分',
          value: reviewSummary.avgScore!.toStringAsFixed(1),
        ),
      if (reviewSummary.reviewCount != null)
        EnterpriseDetailMetricItem(
          label: '评价数',
          value: '${reviewSummary.reviewCount}',
        ),
      if (reviewSummary.deliveryScore != null)
        EnterpriseDetailMetricItem(
          label: '交付',
          value: reviewSummary.deliveryScore!.toStringAsFixed(1),
        ),
      if (reviewSummary.qualityScore != null)
        EnterpriseDetailMetricItem(
          label: '质量',
          value: reviewSummary.qualityScore!.toStringAsFixed(1),
        ),
      if (reviewSummary.communicationScore != null)
        EnterpriseDetailMetricItem(
          label: '沟通',
          value: reviewSummary.communicationScore!.toStringAsFixed(1),
        ),
    ];
    return EnterpriseSectionCard(
      title: '资质与口碑',
      subtitle: '只承接当前公开详情已返回的资质和评价摘要，不派生第二套企业真值。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '资质摘要',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          certifications.isEmpty
              ? const Text('当前未返回公开资质摘要。')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: certifications
                      .map(
                        (EnterpriseHubCertificationCard item) =>
                            Chip(label: Text(item.name)),
                      )
                      .toList(growable: false),
                ),
          const SizedBox(height: 14),
          Text(
            '口碑摘要',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (statItems.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: statItems
                  .map(
                    (EnterpriseDetailMetricItem item) =>
                        EnterpriseDetailMetricTile(item: item),
                  )
                  .toList(growable: false),
            )
          else
            const Text('当前未返回评分摘要。'),
          if (reviewSummary.keywordTags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            CapabilityTagGroup(
              tags: reviewSummary.keywordTags,
              emptyLabel: '当前未返回口碑标签。',
            ),
          ],
          const SizedBox(height: 14),
          EnterpriseTargetEnterpriseInfoEntryCard(
            shellContext: shellContext,
            onPressed: onOpenTargetEnterpriseInfo,
          ),
        ],
      ),
    );
  }
}
