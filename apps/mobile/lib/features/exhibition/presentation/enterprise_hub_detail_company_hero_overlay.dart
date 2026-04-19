import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';

class EnterpriseDetailCompanyHeroOverlay extends StatelessWidget {
  const EnterpriseDetailCompanyHeroOverlay({super.key, required this.data});

  final EnterpriseHubDetailData data;

  @override
  Widget build(BuildContext context) {
    final title = enterpriseDetailDisplayName(data);
    final items = enterpriseDetailHeroSummaryItems(data);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final compact = constraints.maxWidth < 380;
        return Padding(
          key: const ValueKey<String>('enterprise-detail-hero-overlay'),
          padding: EdgeInsets.fromLTRB(18, 18, 18, compact ? 4 : 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  shadows: const <Shadow>[
                    Shadow(
                      blurRadius: 12,
                      color: Color(0x66000000),
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (items.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (
                      var index = 0;
                      index < items.length;
                      index += 1
                    ) ...<Widget>[
                      Expanded(
                        child: _EnterpriseDetailHeroMetricPill(
                          item: items[index],
                          compact: compact,
                        ),
                      ),
                      if (index != items.length - 1)
                        SizedBox(width: compact ? 6 : 8),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EnterpriseDetailHeroMetricPill extends StatelessWidget {
  const _EnterpriseDetailHeroMetricPill({
    required this.item,
    required this.compact,
  });

  final EnterpriseDetailMetricItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('enterprise-detail-hero-metric-${item.label}'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 10 : 11,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        item.value,
        maxLines: compact ? 3 : 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: compact ? 12 : 13,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
      ),
    );
  }
}
