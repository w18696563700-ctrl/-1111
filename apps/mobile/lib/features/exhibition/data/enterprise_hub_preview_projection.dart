import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';

EnterpriseHubDetailData? enterpriseHubBuildPublishedChangePreviewDetailData({
  required EnterpriseHubPublishedChangeWorkbenchData data,
  EnterpriseHubWorkbenchCertification? certification,
}) {
  final basic = data.basic;
  if (basic == null) {
    return null;
  }
  final provinceName =
      _firstNonEmpty(<String?>[
        basic.provinceName,
        basic.location?.provinceName,
      ]) ??
      '待完善地区';
  final cityName =
      _firstNonEmpty(<String?>[basic.cityName, basic.location?.cityName]) ??
      '待完善城市';
  final contacts = <EnterpriseHubContactCard>[
    if ((basic.contactVisible ||
            data.primaryContact?.visibleToPublic == true) &&
        data.primaryContact != null)
      EnterpriseHubContactCard(
        contactName: data.primaryContact!.contactName,
        mobile: data.primaryContact!.mobile,
        wechat: data.primaryContact!.wechat,
        phone: data.primaryContact!.phone,
        email: data.primaryContact!.email,
        position: data.primaryContact!.position,
      ),
  ];
  final certifications = <EnterpriseHubCertificationCard>[
    if (certification != null)
      EnterpriseHubCertificationCard(
        type: 'business',
        name: '营业执照',
        status: certification.certificationStatus,
      ),
  ];
  return EnterpriseHubDetailData(
    header: EnterpriseHubHeader(
      enterpriseId: data.enterpriseId,
      name: basic.name?.trim().isNotEmpty == true
          ? basic.name!.trim()
          : '当前变更未补企业名称',
      primaryBoardType: data.boardType,
      secondaryCapabilities: const <EnterpriseBoardType>[],
      shortIntro: basic.shortIntro?.trim() ?? '',
      provinceName: provinceName,
      cityName: cityName,
      verificationStatus: certification?.certificationStatus,
      logoUrl: basic.logoUrl,
    ),
    visualGallery: EnterpriseHubVisualGallery(
      showcaseImageUrls: _previewShowcaseImageUrls(data.boardProfile),
      albumImageUrls: basic.albumImageUrlMap.values
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false),
      source:
          _previewShowcaseImageUrls(data.boardProfile).isNotEmpty
          ? 'change_snapshot_preview_showcase'
          : 'change_snapshot_preview_album',
    ),
    basicInfo: EnterpriseHubBasicInfo(
      legalName: certification?.legalName,
      foundedAt: basic.foundedAt,
      fullIntro: basic.fullIntro,
      address: basic.address,
    ),
    location:
        basic.location ??
        EnterpriseHubLocationData(
          addressText: basic.address,
          publicDisplayAddress: basic.address,
          provinceCode: basic.provinceCode,
          provinceName: basic.provinceName,
          cityCode: basic.cityCode,
          cityName: basic.cityName,
        ),
    boardProfile: data.boardProfile ?? const <String, Object?>{},
    serviceAreas: _serviceAreasFromChangeSnapshot(
      basic: basic,
      boardProfile: data.boardProfile,
    ),
    cases: data.cases
        .map(
          (EnterpriseHubWorkbenchCaseItem item) => EnterpriseHubCaseCard(
            id: item.caseId,
            title: item.title,
            summary: item.summary,
            caseStatus: item.caseStatus,
            coverImageUrl: _publishedChangeCasePreviewImageUrl(item),
            eventTime: item.eventTime,
            enterpriseId: data.enterpriseId,
            boardType: data.boardType,
            exhibitionType: item.exhibitionType,
            city: item.city,
            caseCoverFileAssetId: item.caseCoverFileAssetId,
            caseMediaFileAssetIds: item.caseMediaFileAssetIds,
            caseImageUrlMap: item.caseImageUrlMap,
            isFeatured: item.isFeatured,
          ),
        )
        .toList(growable: false),
    certifications: certifications,
    reviewSummary: const EnterpriseHubReviewSummary(keywordTags: <String>[]),
    contacts: contacts,
  );
}

List<EnterpriseHubServiceArea> _serviceAreasFromChangeSnapshot({
  required EnterpriseHubWorkbenchBasic basic,
  required Map<String, Object?>? boardProfile,
}) {
  final serviceCities = boardProfile?['serviceCities'];
  if (serviceCities is List) {
    final provinceName = basic.provinceName?.trim();
    final items = serviceCities
        .whereType<String>()
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .map(
          (String city) => EnterpriseHubServiceArea(
            provinceName: provinceName ?? '服务区域',
            cityName: city,
          ),
        )
        .toList(growable: false);
    if (items.isNotEmpty) {
      return items;
    }
  }
  final provinceName = _firstNonEmpty(<String?>[
    basic.provinceName,
    basic.location?.provinceName,
  ]);
  final cityName = _firstNonEmpty(<String?>[
    basic.cityName,
    basic.location?.cityName,
  ]);
  if (provinceName == null) {
    return const <EnterpriseHubServiceArea>[];
  }
  return <EnterpriseHubServiceArea>[
    EnterpriseHubServiceArea(provinceName: provinceName, cityName: cityName),
  ];
}

List<String> _previewShowcaseImageUrls(Map<String, Object?>? boardProfile) {
  if (boardProfile == null) {
    return const <String>[];
  }
  final imageUrlMap = boardProfile['showcaseImageUrlMap'];
  if (imageUrlMap is! Map) {
    return const <String>[];
  }
  return imageUrlMap.values
      .whereType<String>()
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

String? _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
  }
  return null;
}

String? _publishedChangeCasePreviewImageUrl(
  EnterpriseHubWorkbenchCaseItem item,
) {
  final coverFileAssetId = item.caseCoverFileAssetId.trim();
  final coverImageUrl = _normalizedImageUrl(item.caseImageUrlMap[coverFileAssetId]);
  if (coverImageUrl != null) {
    return coverImageUrl;
  }
  for (final fileAssetId in item.caseMediaFileAssetIds) {
    final mediaImageUrl = _normalizedImageUrl(item.caseImageUrlMap[fileAssetId]);
    if (mediaImageUrl != null) {
      return mediaImageUrl;
    }
  }
  for (final imageUrl in item.caseImageUrlMap.values) {
    final normalizedImageUrl = _normalizedImageUrl(imageUrl);
    if (normalizedImageUrl != null) {
      return normalizedImageUrl;
    }
  }
  return null;
}

String? _normalizedImageUrl(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}
