import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';

class EnterpriseDetailMetricItem {
  const EnterpriseDetailMetricItem({required this.label, required this.value});

  final String label;
  final String value;
}

class EnterpriseDetailMetricTile extends StatelessWidget {
  const EnterpriseDetailMetricTile({super.key, required this.item});

  final EnterpriseDetailMetricItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(item.label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class EnterpriseDetailInfoRow extends StatelessWidget {
  const EnterpriseDetailInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}

class EnterpriseDetailBadgePill extends StatelessWidget {
  const EnterpriseDetailBadgePill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.94),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class EnterpriseDetailLogoAvatar extends StatelessWidget {
  const EnterpriseDetailLogoAvatar({
    super.key,
    required this.label,
    this.size = 68,
  });

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: size * 0.36,
            ),
          ),
        ),
      ),
    );
  }
}

class EnterpriseDetailImageFrame extends StatelessWidget {
  const EnterpriseDetailImageFrame({
    super.key,
    required this.imageUrl,
    required this.fallback,
  });

  final String? imageUrl;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) =>
                _placeholder(context),
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) =>
                progress == null ? child : _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerLowest,
            colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.photo_library_outlined,
          size: 44,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

List<EnterpriseDetailMetricItem> enterpriseDetailBuildSummaryItems(
  EnterpriseHubDetailData data,
) {
  final commonItems = <EnterpriseDetailMetricItem>[
    if (enterpriseDetailLocationSummaryValue(data) case final String location)
      EnterpriseDetailMetricItem(label: '地区', value: location),
    EnterpriseDetailMetricItem(
      label: '认证',
      value: enterpriseDetailVerificationLabel(data.header.verificationStatus),
    ),
  ];
  final boardSpecific = switch (data.header.primaryBoardType) {
    EnterpriseBoardType.company => <EnterpriseDetailMetricItem>[
      EnterpriseDetailMetricItem(
        label: '服务项目',
        value: enterpriseDetailPreviewList(data.boardProfile['serviceItems']),
      ),
      EnterpriseDetailMetricItem(
        label: '项目规模',
        value:
            enterpriseDetailString(data.boardProfile['maxProjectScale']) ??
            '暂未补充',
      ),
    ],
    EnterpriseBoardType.factory => <EnterpriseDetailMetricItem>[
      if (enterpriseDetailNullableArea(data.boardProfile['plantAreaSqm'])
          case final String plantArea)
        EnterpriseDetailMetricItem(label: '厂房面积', value: plantArea),
    ],
    EnterpriseBoardType.supplier => <EnterpriseDetailMetricItem>[
      EnterpriseDetailMetricItem(
        label: '供应品类',
        value: enterpriseDetailPreviewList(
          data.boardProfile['supplyCategories'],
        ),
      ),
      EnterpriseDetailMetricItem(
        label: '响应时效',
        value:
            enterpriseDetailString(data.boardProfile['responseSlaDesc']) ??
            '暂未补充',
      ),
    ],
  };
  return <EnterpriseDetailMetricItem>[
    ...commonItems,
    ...boardSpecific,
    if (data.basicInfo.teamSizeRange case final String teamSize
        when teamSize.trim().isNotEmpty)
      EnterpriseDetailMetricItem(label: '团队规模', value: teamSize.trim()),
  ];
}

List<String> enterpriseDetailServiceAreaLabels(EnterpriseHubDetailData data) {
  final values = data.serviceAreas
      .map((EnterpriseHubServiceArea item) {
        final city = item.cityName?.trim();
        return city == null || city.isEmpty
            ? item.provinceName.trim()
            : '${item.provinceName.trim()} $city';
      })
      .where((String item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);
  if (values.isNotEmpty) {
    return values;
  }
  return <String>['${data.header.provinceName} ${data.header.cityName}'];
}

String enterpriseDetailDisplayName(EnterpriseHubDetailData data) {
  if (data.header.primaryBoardType == EnterpriseBoardType.factory) {
    final factoryName = enterpriseDetailString(
      data.boardProfile['factoryName'],
    );
    if (factoryName != null && factoryName.isNotEmpty) {
      return factoryName;
    }
  }
  return data.header.name;
}

String? enterpriseDetailMetaLine(EnterpriseHubDetailData data) {
  final items = <String>[
    if (data.basicInfo.legalName case final String legalName
        when legalName.trim().isNotEmpty)
      legalName.trim(),
    if (data.basicInfo.foundedAt case final String foundedAt
        when foundedAt.trim().isNotEmpty)
      '成立于 $foundedAt',
  ];
  return items.isEmpty ? null : items.join(' · ');
}

String enterpriseDetailVerificationLabel(String? status) {
  return switch (status?.trim().toLowerCase()) {
    'approved' || 'verified' => '认证已通过',
    'pending' => '认证中',
    'failed' => '认证未通过',
    _ => '认证待完善',
  };
}

String enterpriseDetailPreviewList(Object? raw) {
  final values = enterpriseDetailStringList(raw);
  if (values.isEmpty) {
    return '暂未补充';
  }
  return values.take(3).join(' / ');
}

List<String> enterpriseDetailStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw
      .whereType<String>()
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

String? enterpriseDetailString(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

String enterpriseDetailFormatArea(Object? raw) {
  return enterpriseDetailNullableArea(raw) ?? '暂未补充';
}

String? enterpriseDetailNullableArea(Object? raw) {
  if (raw is num) {
    return '${raw.toInt()}㎡';
  }
  return enterpriseDetailString(raw);
}

String? enterpriseDetailLocationSummaryValue(EnterpriseHubDetailData data) {
  final province = data.header.provinceName.trim();
  final city = data.header.cityName.trim();
  if (province.isEmpty && city.isEmpty) {
    return null;
  }
  if (province.isEmpty) {
    return city;
  }
  if (city.isEmpty || city == province) {
    return province;
  }
  return '$province / $city';
}

bool enterpriseDetailShouldShowCapabilitySection(EnterpriseHubDetailData data) {
  return data.header.primaryBoardType != EnterpriseBoardType.company;
}

List<EnterpriseDetailMetricItem> enterpriseDetailHeroSummaryItems(
  EnterpriseHubDetailData data,
) {
  final items = enterpriseDetailBuildSummaryItems(data);
  return switch (data.header.primaryBoardType) {
    EnterpriseBoardType.company =>
      items
          .where(
            (EnterpriseDetailMetricItem item) =>
                item.label == '地区' ||
                item.label == '认证' ||
                item.label == '服务项目',
          )
          .toList(growable: false),
    EnterpriseBoardType.factory =>
      items
          .where(
            (EnterpriseDetailMetricItem item) =>
                item.label == '地区' ||
                item.label == '认证' ||
                item.label == '厂房面积' ||
                item.label == '团队规模',
          )
          .toList(growable: false),
    EnterpriseBoardType.supplier => items,
  };
}

bool enterpriseDetailShouldShowVisualGallerySection(
  EnterpriseHubDetailData data,
) {
  return data.header.primaryBoardType == EnterpriseBoardType.supplier;
}
