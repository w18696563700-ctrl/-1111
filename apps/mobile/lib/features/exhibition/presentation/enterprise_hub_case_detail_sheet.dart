import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

Future<void> showEnterpriseCaseDetailSheet(
  BuildContext context, {
  required EnterpriseHubCaseCard item,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _EnterpriseCaseDetailSheet(item: item),
          ),
        ),
      );
    },
  );
}

class _EnterpriseCaseDetailSheet extends StatefulWidget {
  const _EnterpriseCaseDetailSheet({required this.item});

  final EnterpriseHubCaseCard item;

  @override
  State<_EnterpriseCaseDetailSheet> createState() =>
      _EnterpriseCaseDetailSheetState();
}

class _EnterpriseCaseDetailSheetState
    extends State<_EnterpriseCaseDetailSheet> {
  EnterpriseHubLoadResult<EnterpriseHubCaseDetailData>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final inlineDetail = _buildInlineCaseDetail(widget.item);
    if (inlineDetail != null) {
      setState(() {
        _result = EnterpriseHubLoadResult<EnterpriseHubCaseDetailData>(
          state: AppPageState.content,
          method: 'INLINE',
          path: 'enterprise-case-detail-inline-preview',
          data: inlineDetail,
        );
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
    });

    final result = await EnterpriseHubConsumerLayer.instance.getPublicCaseDetail(
      caseId: widget.item.id,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final body = switch ((result, _loading)) {
      (null, true) => const _EnterpriseCaseDetailLoadingState(),
      (
        final EnterpriseHubLoadResult<EnterpriseHubCaseDetailData> current,
        false,
      )
          when current.state == AppPageState.content && current.data != null =>
        _EnterpriseCaseDetailSuccessState(
          previewItem: widget.item,
          detail: current.data!,
          onRetry: _load,
        ),
      (
        final EnterpriseHubLoadResult<EnterpriseHubCaseDetailData> current,
        false,
      ) =>
        _EnterpriseCaseDetailFailureState(
          previewItem: widget.item,
          result: current,
          onRetry: _load,
        ),
      _ => const _EnterpriseCaseDetailLoadingState(),
    };

    return Column(
      key: const ValueKey<String>('enterprise-detail-case-detail-sheet'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '案例详情',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          widget.item.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: body),
      ],
    );
  }
}

EnterpriseHubCaseDetailData? _buildInlineCaseDetail(EnterpriseHubCaseCard item) {
  final enterpriseId = _trimmed(item.enterpriseId);
  final boardType = item.boardType;
  final caseCoverFileAssetId = _trimmed(item.caseCoverFileAssetId);
  if (enterpriseId == null ||
      boardType == null ||
      caseCoverFileAssetId == null ||
      item.caseImageUrlMap.isEmpty) {
    return null;
  }
  return EnterpriseHubCaseDetailData(
    caseId: item.id,
    enterpriseId: enterpriseId,
    boardType: boardType,
    title: item.title,
    exhibitionType: item.exhibitionType,
    city: item.city,
    eventTime: item.eventTime,
    summary: item.summary,
    caseCoverFileAssetId: caseCoverFileAssetId,
    caseMediaFileAssetIds: item.caseMediaFileAssetIds,
    caseImageUrlMap: item.caseImageUrlMap,
    isFeatured: item.isFeatured,
    caseStatus: item.caseStatus,
  );
}

class _EnterpriseCaseDetailLoadingState extends StatelessWidget {
  const _EnterpriseCaseDetailLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        key: ValueKey<String>('enterprise-detail-case-detail-loading'),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在读取案例详情'),
        ],
      ),
    );
  }
}

class _EnterpriseCaseDetailFailureState extends StatelessWidget {
  const _EnterpriseCaseDetailFailureState({
    required this.previewItem,
    required this.result,
    required this.onRetry,
  });

  final EnterpriseHubCaseCard previewItem;
  final EnterpriseHubLoadResult<EnterpriseHubCaseDetailData> result;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = switch (result.state) {
      AppPageState.unauthorized => '当前会话已失效，请重新登录后再查看案例详情。',
      AppPageState.forbidden => '当前账号暂不能读取该案例详情。',
      AppPageState.notFound => '当前案例暂不可用，可能已下线或被移除。',
      AppPageState.errorRetryable => result.message ?? '当前案例详情读取失败，请稍后重试。',
      AppPageState.errorNonRetryable => result.message ?? '当前案例详情不可用。',
      AppPageState.empty => '当前案例详情为空。',
      AppPageState.content => result.message ?? '当前案例详情无法读取。',
      AppPageState.loading => '正在读取案例详情。',
    };

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              size: 52,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              previewItem.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (result.errorCode != null) ...<Widget>[
              const SizedBox(height: 6),
              Text('错误码：${result.errorCode}', style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class _EnterpriseCaseDetailSuccessState extends StatelessWidget {
  const _EnterpriseCaseDetailSuccessState({
    required this.previewItem,
    required this.detail,
    required this.onRetry,
  });

  final EnterpriseHubCaseCard previewItem;
  final EnterpriseHubCaseDetailData detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final coverImageUrl = _caseCoverImageUrl(detail, previewItem);
    final galleryImageUrls = _caseGalleryImageUrls(detail, previewItem);
    final theme = Theme.of(context);

    return ListView(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: EnterpriseDetailImageFrame(
              imageUrl: coverImageUrl,
              fallback: '案',
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            Chip(label: Text(detail.caseStatus)),
            if (detail.isFeatured) const Chip(label: Text('精选案例')),
            if (_trimmed(detail.exhibitionType)
                case final String exhibitionType)
              Chip(label: Text(exhibitionType)),
            if (_trimmed(detail.city) case final String city)
              Chip(label: Text(city)),
            if (_trimmed(detail.eventTime) case final String eventTime)
              Chip(label: Text(eventTime)),
          ],
        ),
        const SizedBox(height: 14),
        EnterpriseSectionCard(
          title: '案例信息',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              EnterpriseDetailInfoRow(label: '案例标题', value: detail.title),
              if (_trimmed(detail.exhibitionType)
                  case final String exhibitionType) ...<Widget>[
                const SizedBox(height: 12),
                EnterpriseDetailInfoRow(label: '展会类型', value: exhibitionType),
              ],
              if (_trimmed(detail.city) case final String city) ...<Widget>[
                const SizedBox(height: 12),
                EnterpriseDetailInfoRow(label: '所在城市', value: city),
              ],
              if (_trimmed(detail.eventTime)
                  case final String eventTime) ...<Widget>[
                const SizedBox(height: 12),
                EnterpriseDetailInfoRow(label: '案例时间', value: eventTime),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        EnterpriseSectionCard(
          title: '案例摘要',
          child: Text(
            detail.summary,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ),
        if (galleryImageUrls.length > 1) ...<Widget>[
          const SizedBox(height: 14),
          EnterpriseSectionCard(
            title: '案例图片',
            child: SizedBox(
              height: 132,
              child: ListView.separated(
                key: const ValueKey<String>(
                  'enterprise-detail-case-detail-gallery',
                ),
                scrollDirection: Axis.horizontal,
                itemCount: galleryImageUrls.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 10),
                itemBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 176,
                      child: EnterpriseDetailImageFrame(
                        imageUrl: galleryImageUrls[index],
                        fallback: '案',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新读取'),
          ),
        ),
      ],
    );
  }
}

String? _caseCoverImageUrl(
  EnterpriseHubCaseDetailData detail,
  EnterpriseHubCaseCard previewItem,
) {
  return _firstNonEmpty(<String?>[
    _caseImageUrl(detail.caseImageUrlMap, detail.caseCoverFileAssetId),
    previewItem.coverImageUrl,
  ]);
}

List<String> _caseGalleryImageUrls(
  EnterpriseHubCaseDetailData detail,
  EnterpriseHubCaseCard previewItem,
) {
  final values = <String>[];

  void add(String? value) {
    final normalized = _trimmed(value);
    if (normalized == null || values.contains(normalized)) {
      return;
    }
    values.add(normalized);
  }

  add(_caseCoverImageUrl(detail, previewItem));
  for (final assetId in detail.caseMediaFileAssetIds) {
    add(_caseImageUrl(detail.caseImageUrlMap, assetId));
  }

  return values;
}

String? _caseImageUrl(Map<String, String> imageUrlMap, String? fileAssetId) {
  final assetId = _trimmed(fileAssetId);
  if (assetId == null) {
    return null;
  }
  return _trimmed(imageUrlMap[assetId]);
}

String? _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final normalized = _trimmed(value);
    if (normalized != null) {
      return normalized;
    }
  }
  return null;
}

String? _trimmed(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}
