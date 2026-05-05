import 'package:flutter/material.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_company_sections.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart';

class EnterpriseDetailRelayoutSurface extends StatelessWidget {
  const EnterpriseDetailRelayoutSurface({
    super.key,
    required this.data,
    required this.boardType,
    required this.shellContext,
    required this.onOpenTargetEnterpriseInfo,
  });

  final EnterpriseHubDetailData data;
  final EnterpriseBoardType boardType;
  final AppShellContextData shellContext;
  final VoidCallback onOpenTargetEnterpriseInfo;

  @override
  Widget build(BuildContext context) {
    final isCompany =
        data.header.primaryBoardType == EnterpriseBoardType.company;
    if (isCompany) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          EnterpriseDetailOverviewCard(data: data),
          const SizedBox(height: 16),
          EnterpriseDetailCompanyTrustSummarySection(data: data),
          const SizedBox(height: 16),
          EnterpriseDetailCompanyIntroSection(
            fullIntro: data.basicInfo.fullIntro,
            shortIntro: data.header.shortIntro,
          ),
          const SizedBox(height: 16),
          EnterpriseDetailLocationSection(data: data),
          if (enterpriseDetailCompanyShouldShowCoreAdvantages(
            data,
          )) ...<Widget>[
            const SizedBox(height: 16),
            EnterpriseDetailCompanyCoreAdvantagesSection(data: data),
          ],
          const SizedBox(height: 16),
          EnterpriseDetailCompanyCaseSection(items: data.cases),
          const SizedBox(height: 16),
          EnterpriseDetailTrustSection(
            certifications: data.certifications,
            reviewSummary: data.reviewSummary,
            shellContext: shellContext,
            onOpenTargetEnterpriseInfo: onOpenTargetEnterpriseInfo,
          ),
          if (enterpriseDetailCompanyShouldShowBasicInfo(data)) ...<Widget>[
            const SizedBox(height: 16),
            EnterpriseDetailCompanyBasicInfoSection(data: data),
          ],
          const SizedBox(height: 16),
          EnterpriseDetailContactSection(items: data.contacts),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EnterpriseDetailOverviewCard(data: data),
        const SizedBox(height: 16),
        EnterpriseDetailLocationSection(data: data),
        if (enterpriseDetailShouldShowCapabilitySection(data)) ...<Widget>[
          const SizedBox(height: 16),
          EnterpriseDetailCapabilitySection(
            boardType: boardType,
            boardProfile: data.boardProfile,
          ),
        ],
        if (enterpriseDetailShouldShowVisualGallerySection(data)) ...<Widget>[
          const SizedBox(height: 16),
          EnterpriseDetailVisualGallerySection(
            visualGallery: data.visualGallery,
          ),
        ],
        const SizedBox(height: 16),
        EnterpriseDetailTrustSection(
          certifications: data.certifications,
          reviewSummary: data.reviewSummary,
          shellContext: shellContext,
          onOpenTargetEnterpriseInfo: onOpenTargetEnterpriseInfo,
        ),
        const SizedBox(height: 16),
        EnterpriseDetailCaseSection(items: data.cases),
        const SizedBox(height: 16),
        EnterpriseDetailIntroSection(
          fullIntro: data.basicInfo.fullIntro,
          shortIntro: data.header.shortIntro,
        ),
        const SizedBox(height: 16),
        EnterpriseDetailContactSection(items: data.contacts),
      ],
    );
  }
}
