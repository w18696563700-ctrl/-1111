import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_case_detail_sheet.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';

class EnterpriseDetailCompanyAdvantageItem {
  const EnterpriseDetailCompanyAdvantageItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class EnterpriseDetailCompanyAdvantageCard extends StatelessWidget {
  const EnterpriseDetailCompanyAdvantageCard({super.key, required this.item});

  final EnterpriseDetailCompanyAdvantageItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 154,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.primaryContainer.withValues(alpha: 0.24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.icon, color: colorScheme.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class EnterpriseDetailCompanyPublicCaseCard extends StatelessWidget {
  const EnterpriseDetailCompanyPublicCaseCard({super.key, required this.item});

  final EnterpriseHubCaseCard item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: 186,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showEnterpriseCaseDetailSheet(context, item: item),
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: EnterpriseDetailImageFrame(
                      imageUrl: item.coverImageUrl,
                      fallback: '案',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnterpriseDetailCompanyInfoRowData {
  const EnterpriseDetailCompanyInfoRowData(this.label, this.value);

  final String label;
  final String value;
}
