import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

class EnterpriseDetailCompanyOverviewSupplement extends StatelessWidget {
  const EnterpriseDetailCompanyOverviewSupplement({
    super.key,
    required this.boardProfile,
  });

  final Map<String, Object?> boardProfile;

  @override
  Widget build(BuildContext context) {
    final exhibitionTypes = enterpriseDetailStringList(
      boardProfile['exhibitionTypes'],
    );
    final qualificationDesc = enterpriseDetailString(
      boardProfile['qualificationDesc'],
    );
    if (exhibitionTypes.isEmpty && qualificationDesc == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (exhibitionTypes.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            '展会类型',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          CapabilityTagGroup(tags: exhibitionTypes),
        ],
        if (qualificationDesc != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            '资质说明',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            qualificationDesc,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ],
    );
  }
}
