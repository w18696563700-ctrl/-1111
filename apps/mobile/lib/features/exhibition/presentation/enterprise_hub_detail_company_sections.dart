import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_company_support_widgets.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

bool enterpriseDetailCompanyShouldShowCoreAdvantages(
  EnterpriseHubDetailData data,
) {
  return enterpriseDetailStringList(
        data.boardProfile['exhibitionTypes'],
      ).isNotEmpty ||
      enterpriseDetailStringList(
        data.boardProfile['serviceItems'],
      ).isNotEmpty ||
      enterpriseDetailString(data.boardProfile['maxProjectScale']) != null ||
      enterpriseDetailString(data.boardProfile['qualificationDesc']) != null;
}

bool enterpriseDetailCompanyShouldShowBasicInfo(EnterpriseHubDetailData data) {
  return data.basicInfo.foundedAt?.trim().isNotEmpty == true ||
      data.basicInfo.teamSizeRange?.trim().isNotEmpty == true ||
      data.basicInfo.legalName?.trim().isNotEmpty == true ||
      enterpriseDetailStringList(
        data.boardProfile['serviceItems'],
      ).isNotEmpty ||
      enterpriseDetailStringList(
        data.boardProfile['exhibitionTypes'],
      ).isNotEmpty ||
      enterpriseDetailString(data.boardProfile['maxProjectScale']) != null;
}

class EnterpriseDetailCompanyTrustSummarySection extends StatelessWidget {
  const EnterpriseDetailCompanyTrustSummarySection({
    super.key,
    required this.data,
  });

  final EnterpriseHubDetailData data;

  @override
  Widget build(BuildContext context) {
    final summaryItems = <EnterpriseDetailCompanyTrustMetricItem>[
      if (enterpriseDetailLocationSummaryValue(data) case final String location)
        EnterpriseDetailCompanyTrustMetricItem(
          icon: Icons.location_on_outlined,
          label: '服务区域',
          value: location,
        ),
      EnterpriseDetailCompanyTrustMetricItem(
        icon: Icons.verified_user_outlined,
        label: '平台认证',
        value: enterpriseDetailVerificationLabel(
          data.header.verificationStatus,
        ),
      ),
      if (data.basicInfo.teamSizeRange case final String teamSize
          when teamSize.trim().isNotEmpty)
        EnterpriseDetailCompanyTrustMetricItem(
          icon: Icons.groups_2_outlined,
          label: '团队规模',
          value: teamSize.trim(),
        )
      else if (data.basicInfo.foundedAt case final String foundedAt
          when foundedAt.trim().isNotEmpty)
        EnterpriseDetailCompanyTrustMetricItem(
          icon: Icons.event_available_outlined,
          label: '成立时间',
          value: foundedAt.trim(),
        ),
      if (data.reviewSummary.avgScore != null)
        EnterpriseDetailCompanyTrustMetricItem(
          icon: Icons.star_rate_rounded,
          label: '综合评分',
          value: data.reviewSummary.avgScore!.toStringAsFixed(1),
        )
      else if (data.reviewSummary.reviewCount != null)
        EnterpriseDetailCompanyTrustMetricItem(
          icon: Icons.rate_review_outlined,
          label: '客户评价',
          value: '${data.reviewSummary.reviewCount}',
        ),
    ].take(4).toList(growable: false);

    return EnterpriseSectionCard(
      title: '信任背书',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: summaryItems
            .map((item) => EnterpriseDetailCompanyTrustMetricCard(item: item))
            .toList(growable: false),
      ),
    );
  }
}

class EnterpriseDetailCompanyIntroSection extends StatefulWidget {
  const EnterpriseDetailCompanyIntroSection({
    super.key,
    required this.fullIntro,
    required this.shortIntro,
  });

  final String? fullIntro;
  final String shortIntro;

  @override
  State<EnterpriseDetailCompanyIntroSection> createState() =>
      _EnterpriseDetailCompanyIntroSectionState();
}

class _EnterpriseDetailCompanyIntroSectionState
    extends State<EnterpriseDetailCompanyIntroSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text =
        enterpriseDetailString(widget.fullIntro) ?? widget.shortIntro.trim();
    final hasContent = text.isNotEmpty;
    final canExpand = text.length > 96;
    return EnterpriseSectionCard(
      title: '公司介绍',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            hasContent ? text : '当前还没有补充公司介绍。',
            maxLines: !_expanded && canExpand ? 4 : null,
            overflow: !_expanded && canExpand ? TextOverflow.ellipsis : null,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.58),
          ),
          if (canExpand) ...<Widget>[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(
                _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              label: Text(_expanded ? '收起介绍' : '展开全部'),
            ),
          ],
        ],
      ),
    );
  }
}

class EnterpriseDetailCompanyCoreAdvantagesSection extends StatelessWidget {
  const EnterpriseDetailCompanyCoreAdvantagesSection({
    super.key,
    required this.data,
  });

  final EnterpriseHubDetailData data;

  @override
  Widget build(BuildContext context) {
    final items = <EnterpriseDetailCompanyAdvantageItem>[
      if (enterpriseDetailStringList(data.boardProfile['serviceItems'])
          case final List<String> values when values.isNotEmpty)
        EnterpriseDetailCompanyAdvantageItem(
          icon: Icons.storefront_outlined,
          title: '服务项目',
          value: values.take(4).join(' / '),
        ),
      if (enterpriseDetailStringList(data.boardProfile['exhibitionTypes'])
          case final List<String> values when values.isNotEmpty)
        EnterpriseDetailCompanyAdvantageItem(
          icon: Icons.category_outlined,
          title: '展会类型',
          value: values.take(4).join(' / '),
        ),
      if (enterpriseDetailString(data.boardProfile['maxProjectScale'])
          case final String value)
        EnterpriseDetailCompanyAdvantageItem(
          icon: Icons.speed_outlined,
          title: '项目规模',
          value: value,
        ),
      if (enterpriseDetailString(data.boardProfile['qualificationDesc'])
          case final String value)
        EnterpriseDetailCompanyAdvantageItem(
          icon: Icons.verified_outlined,
          title: '资质说明',
          value: value,
        ),
    ];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return EnterpriseSectionCard(
      title: '核心优势',
      subtitle: '只基于公开详情返回的主营业务与服务能力展示。',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items
            .map((item) => EnterpriseDetailCompanyAdvantageCard(item: item))
            .toList(growable: false),
      ),
    );
  }
}

class EnterpriseDetailCompanyCaseSection extends StatelessWidget {
  const EnterpriseDetailCompanyCaseSection({super.key, required this.items});

  final List<EnterpriseHubCaseCard> items;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(6).toList(growable: false);
    if (visibleItems.isEmpty) {
      return const EnterpriseSectionCard(
        title: '案例展示',
        subtitle: '当前还没有公开案例。',
        child: Text('暂无公开案例'),
      );
    }

    return EnterpriseSectionCard(
      title: '案例展示',
      subtitle: '只展示公开详情返回的案例，最多展示 6 个。',
      child: SizedBox(
        height: 158,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: visibleItems.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (BuildContext context, int index) {
            final item = visibleItems[index];
            return EnterpriseDetailCompanyPublicCaseCard(item: item);
          },
        ),
      ),
    );
  }
}

class EnterpriseDetailCompanyBasicInfoSection extends StatelessWidget {
  const EnterpriseDetailCompanyBasicInfoSection({
    super.key,
    required this.data,
  });

  final EnterpriseHubDetailData data;

  @override
  Widget build(BuildContext context) {
    final rows = <EnterpriseDetailCompanyInfoRowData>[
      if (data.basicInfo.legalName case final String value
          when value.trim().isNotEmpty)
        EnterpriseDetailCompanyInfoRowData('主体名称', value.trim()),
      if (data.basicInfo.foundedAt case final String value
          when value.trim().isNotEmpty)
        EnterpriseDetailCompanyInfoRowData('成立时间', value.trim()),
      if (data.basicInfo.teamSizeRange case final String value
          when value.trim().isNotEmpty)
        EnterpriseDetailCompanyInfoRowData('团队规模', value.trim()),
      if (enterpriseDetailPreviewList(data.boardProfile['serviceItems'])
          case final String value when value != '暂未补充')
        EnterpriseDetailCompanyInfoRowData('主营业务', value),
      if (enterpriseDetailPreviewList(data.boardProfile['exhibitionTypes'])
          case final String value when value != '暂未补充')
        EnterpriseDetailCompanyInfoRowData('展会类型', value),
      if (enterpriseDetailString(data.boardProfile['maxProjectScale'])
          case final String value)
        EnterpriseDetailCompanyInfoRowData('项目规模', value),
    ];

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return EnterpriseSectionCard(
      title: '基本信息',
      subtitle: '公开详情中的关键企业信息，便于快速判断匹配度。',
      child: Column(
        children: <Widget>[
          for (var index = 0; index < rows.length; index += 1) ...<Widget>[
            EnterpriseDetailCompanyInfoTile(row: rows[index]),
            if (index != rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
