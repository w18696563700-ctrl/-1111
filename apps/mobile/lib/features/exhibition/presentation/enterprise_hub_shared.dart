import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_board_surface.dart';

class EnterpriseSectionCard extends StatelessWidget {
  const EnterpriseSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ],
            const SizedBox(height: 14),
            child,
            if (actions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Wrap(spacing: 12, runSpacing: 12, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class CapabilityTagGroup extends StatelessWidget {
  const CapabilityTagGroup({
    super.key,
    required this.tags,
    this.emptyLabel = '暂未补充标签',
  });

  final List<String> tags;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Text(emptyLabel);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map((String tag) => _EnterpriseMetaPill(label: tag))
          .toList(growable: false),
    );
  }
}

class EnterpriseCard extends StatelessWidget {
  const EnterpriseCard({
    super.key,
    required this.item,
    required this.onPressed,
    this.clean = false,
  });

  final EnterpriseHubListItem item;
  final VoidCallback onPressed;
  final bool clean;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summaryText = enterpriseBoardCardSummaryText(item);
    final chips = enterpriseBoardCardSummaryChips(item);
    final title = enterpriseBoardDisplayTitle(item);
    final companyLine = enterpriseBoardCompanyLine(item);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _EnterpriseCardLogo(
                label: title.characters.first,
                logoUrl: item.logoUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (companyLine != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        companyLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${item.provinceName} / ${item.cityName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (summaryText != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        summaryText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ],
                    if (!clean && chips.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: chips
                            .map(
                              (String chip) => _EnterpriseMetaPill(label: chip),
                            )
                            .toList(growable: false),
                      ),
                    ],
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
      ),
    );
  }
}

class _EnterpriseCardLogo extends StatelessWidget {
  const _EnterpriseCardLogo({required this.label, this.logoUrl});

  final String label;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SizedBox(
        width: 68,
        height: 68,
        child: _buildEnterpriseCardLogoImage(
          logoUrl,
          fallback: label,
          backgroundColor: colorScheme.surfaceContainerLowest,
        ),
      ),
    );
  }
}

Widget _buildEnterpriseCardLogoImage(
  String? imageUrl, {
  required String fallback,
  required Color backgroundColor,
}) {
  final url = imageUrl?.trim();
  if (url != null && url.isNotEmpty) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) {
              return child;
            }
            return _enterpriseCardLogoPlaceholder(
              fallback: fallback,
              backgroundColor: backgroundColor,
            );
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return _enterpriseCardLogoPlaceholder(
              fallback: fallback,
              backgroundColor: backgroundColor,
            );
          },
    );
  }
  return _enterpriseCardLogoPlaceholder(
    fallback: fallback,
    backgroundColor: backgroundColor,
  );
}

Widget _enterpriseCardLogoPlaceholder({
  required String fallback,
  required Color backgroundColor,
}) {
  return ColoredBox(
    color: backgroundColor,
    child: Center(
      child: Builder(
        builder: (BuildContext context) {
          return Text(
            fallback,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          );
        },
      ),
    ),
  );
}

class _EnterpriseMetaPill extends StatelessWidget {
  const _EnterpriseMetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
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

class BoardFilterBar extends StatelessWidget {
  const BoardFilterBar({
    super.key,
    required this.boardType,
    required this.certifiedOnly,
    required this.onCertifiedOnlyChanged,
    required this.boardSpecificFilters,
  });

  final EnterpriseBoardType boardType;
  final bool certifiedOnly;
  final ValueChanged<bool> onCertifiedOnlyChanged;
  final List<Widget> boardSpecificFilters;

  @override
  Widget build(BuildContext context) {
    return EnterpriseSectionCard(
      title: '筛选区',
      subtitle: '${boardType.title} 按合同 query 参数收口，不扩写第二套筛选语义。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilterChip(
                label: const Text('仅看已认证'),
                selected: certifiedOnly,
                onSelected: onCertifiedOnlyChanged,
              ),
            ],
          ),
          if (boardSpecificFilters.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: boardSpecificFilters),
          ],
        ],
      ),
    );
  }
}

class BoardSortBar extends StatelessWidget {
  const BoardSortBar({
    super.key,
    required this.currentSortBy,
    required this.onChanged,
  });

  final String currentSortBy;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <MapEntry<String, String>>[
      MapEntry<String, String>('default', '默认'),
      MapEntry<String, String>('latest', '最新'),
      MapEntry<String, String>('cases_desc', '案例优先'),
    ];

    return EnterpriseSectionCard(
      title: '排序区',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (MapEntry<String, String> option) => ChoiceChip(
                label: Text(option.value),
                selected: currentSortBy == option.key,
                onSelected: (_) => onChanged(option.key),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class RecommendationSlotBanner extends StatelessWidget {
  const RecommendationSlotBanner({
    super.key,
    required this.boardType,
    required this.result,
  });

  final EnterpriseBoardType boardType;
  final EnterpriseHubLoadResult<EnterpriseHubRecommendationData>? result;

  @override
  Widget build(BuildContext context) {
    final currentResult = result;
    final items = currentResult?.data?.items ?? const <EnterpriseHubListItem>[];

    if (currentResult == null) {
      return const EnterpriseSectionCard(
        title: '推荐位区',
        subtitle: '推荐位正在准备读取。',
        child: CircularProgressIndicator(),
      );
    }

    if (currentResult.state == AppPageState.forbidden) {
      return EnterpriseSectionCard(
        title: '推荐位区',
        subtitle: '当前 actor 范围未开放推荐位。',
        child: Text(currentResult.message ?? '推荐位当前未开放。'),
      );
    }

    if (currentResult.state == AppPageState.notFound) {
      return EnterpriseSectionCard(
        title: '推荐位区',
        subtitle: '推荐位当前未返回内容。',
        child: Text(currentResult.message ?? '推荐位当前暂未承接。'),
      );
    }

    if (currentResult.state == AppPageState.errorRetryable ||
        currentResult.state == AppPageState.errorNonRetryable ||
        currentResult.state == AppPageState.unauthorized) {
      return EnterpriseSectionCard(
        title: '推荐位区',
        subtitle: '推荐位当前未能正常读取。',
        child: Text(currentResult.message ?? '推荐位读取失败。'),
      );
    }

    if (items.isEmpty) {
      return EnterpriseSectionCard(
        title: '推荐位区',
        subtitle: '${boardType.title} 推荐位当前为空，列表仍按合同继续承接。',
        child: const Text('当前未返回推荐位内容。'),
      );
    }

    return EnterpriseSectionCard(
      title: '推荐位区',
      subtitle: '推荐位单独消费 `/recommendations`，不与首页六容器混写。',
      child: Column(
        children: items
            .take(3)
            .map(
              (EnterpriseHubListItem item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text(
                  item.shortIntro,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(item.primaryBoardLabel),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class EnterpriseHeaderSection extends StatelessWidget {
  const EnterpriseHeaderSection({
    super.key,
    required this.header,
    this.boardProfile,
    this.onApplyPressed,
  });

  final EnterpriseHubHeader header;
  final Map<String, Object?>? boardProfile;
  final VoidCallback? onApplyPressed;

  @override
  Widget build(BuildContext context) {
    final title = enterpriseBoardHeaderTitle(
      boardType: header.primaryBoardType,
      fallbackName: header.name,
      boardProfile: boardProfile,
    );
    final companyLine = enterpriseBoardHeaderCompanyLine(
      boardType: header.primaryBoardType,
      companyName: header.name,
      boardProfile: boardProfile,
    );
    return EnterpriseSectionCard(
      title: 'header',
      subtitle: '${header.provinceName} · ${header.cityName}',
      actions: onApplyPressed == null
          ? const <Widget>[]
          : <Widget>[
              FilledButton(
                onPressed: onApplyPressed,
                child: Text(header.primaryBoardType.applyTitle),
              ),
            ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(radius: 28, child: Text(title.characters.first)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (companyLine != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        companyLine,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    CapabilityTagGroup(
                      tags: <String>[
                        header.primaryBoardType.title,
                        ...header.secondaryCapabilities.map(
                          (EnterpriseBoardType item) => item.title,
                        ),
                        if (header.verificationStatus != null)
                          '认证 ${header.verificationStatus}',
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            header.shortIntro,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class EnterpriseCaseGallery extends StatelessWidget {
  const EnterpriseCaseGallery({super.key, required this.items});

  final List<EnterpriseHubCaseCard> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EnterpriseSectionCard(
        title: 'cases',
        child: Text('当前还没有公开案例。'),
      );
    }

    return EnterpriseSectionCard(
      title: 'cases',
      child: Column(
        children: items
            .map(
              (EnterpriseHubCaseCard item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(item.summary),
                trailing: Text(item.caseStatus),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class EnterpriseCertificationSection extends StatelessWidget {
  const EnterpriseCertificationSection({super.key, required this.items});

  final List<EnterpriseHubCertificationCard> items;

  @override
  Widget build(BuildContext context) {
    return EnterpriseSectionCard(
      title: 'certifications',
      child: items.isEmpty
          ? const Text('当前未返回资质信息。')
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (EnterpriseHubCertificationCard item) =>
                        _EnterpriseMetaPill(
                          label: '${item.name} · ${item.status}',
                        ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class EnterpriseContactSection extends StatelessWidget {
  const EnterpriseContactSection({super.key, required this.items});

  final List<EnterpriseHubContactCard> items;

  @override
  Widget build(BuildContext context) {
    return EnterpriseSectionCard(
      title: 'contacts',
      child: items.isEmpty
          ? const Text('当前未返回联系方式。')
          : Column(
              children: items
                  .map(
                    (EnterpriseHubContactCard item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.contactName),
                      subtitle: Text(
                        <String>[
                          if (item.position != null) item.position!,
                          if (item.mobile != null) '手机 ${item.mobile}',
                          if (item.phone != null) '电话 ${item.phone}',
                          if (item.wechat != null) '微信 ${item.wechat}',
                          if (item.email != null) item.email!,
                        ].join(' · '),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

String enterpriseDetailRouteForItem(EnterpriseHubListItem item) {
  return switch (item.boardType) {
    EnterpriseBoardType.company =>
      ExhibitionRoutes.companyDetailWithEnterpriseId(item.enterpriseId),
    EnterpriseBoardType.factory =>
      ExhibitionRoutes.factoryDetailWithEnterpriseId(item.enterpriseId),
    EnterpriseBoardType.supplier =>
      ExhibitionRoutes.supplierDetailWithEnterpriseId(item.enterpriseId),
  };
}
