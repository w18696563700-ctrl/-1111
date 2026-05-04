import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/profile/presentation/profile_certification_truth_support.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

Future<void> showEnterpriseTargetEnterpriseInfoSheet(
  BuildContext context, {
  required String enterpriseId,
  required String enterpriseName,
}) async {
  final shellContext = AppShellScope.read(context).snapshot.shellContext;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.88,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _EnterpriseTargetEnterpriseInfoSheet(
              enterpriseId: enterpriseId,
              enterpriseName: enterpriseName,
              shellContext: shellContext,
            ),
          ),
        ),
      );
    },
  );
}

class _EnterpriseTargetEnterpriseInfoSheet extends StatefulWidget {
  const _EnterpriseTargetEnterpriseInfoSheet({
    required this.enterpriseId,
    required this.enterpriseName,
    required this.shellContext,
  });

  final String enterpriseId;
  final String enterpriseName;
  final AppShellContextData shellContext;

  @override
  State<_EnterpriseTargetEnterpriseInfoSheet> createState() =>
      _EnterpriseTargetEnterpriseInfoSheetState();
}

class _EnterpriseTargetEnterpriseInfoSheetState
    extends State<_EnterpriseTargetEnterpriseInfoSheet> {
  EnterpriseHubLoadResult<EnterpriseHubTargetEnterpriseFormalInfoData>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _result = null;
    });

    final result = await EnterpriseHubConsumerLayer.instance
        .loadTargetEnterpriseFormalInfo(enterpriseId: widget.enterpriseId);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final previewAccessible = _hasTargetEnterpriseInfoPreviewAccess(
      widget.shellContext,
    );

    final body = switch ((result, _loading)) {
      (null, true) => const _TargetEnterpriseInfoLoadingState(),
      (
        final EnterpriseHubLoadResult<
          EnterpriseHubTargetEnterpriseFormalInfoData
        >
        current,
        false,
      )
          when current.state == AppPageState.content && current.data != null =>
        _TargetEnterpriseInfoSuccessState(
          enterpriseName: widget.enterpriseName,
          data: current.data!,
          onRetry: _load,
        ),
      (
        final EnterpriseHubLoadResult<
          EnterpriseHubTargetEnterpriseFormalInfoData
        >
        current,
        false,
      ) =>
        _TargetEnterpriseInfoFailureState(
          enterpriseName: widget.enterpriseName,
          result: current,
          onRetry: _load,
        ),
      _ => const _TargetEnterpriseInfoLoadingState(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '企业信息',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.enterpriseName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (!previewAccessible)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '当前账号还未满足双重认证预判，云端若拒绝访问会显示受控失败态。',
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (!previewAccessible) const SizedBox(height: 12),
        Expanded(child: body),
      ],
    );
  }
}

class _TargetEnterpriseInfoLoadingState extends StatelessWidget {
  const _TargetEnterpriseInfoLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在读取企业正式信息'),
        ],
      ),
    );
  }
}

class _TargetEnterpriseInfoFailureState extends StatelessWidget {
  const _TargetEnterpriseInfoFailureState({
    required this.enterpriseName,
    required this.result,
    required this.onRetry,
  });

  final String enterpriseName;
  final EnterpriseHubLoadResult<EnterpriseHubTargetEnterpriseFormalInfoData>
  result;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = switch (result.state) {
      AppPageState.unauthorized => '当前会话已失效，请重新登录后再查看企业正式信息。',
      AppPageState.forbidden => '当前账号未满足双重认证或云端权限要求，暂不能查看目标企业信息。',
      AppPageState.notFound => '当前企业暂未接通正式信息，或者该企业已下线。',
      AppPageState.errorRetryable => result.message ?? '当前云端暂不可用，请稍后重试。',
      AppPageState.errorNonRetryable => result.message ?? '当前企业正式信息读取失败。',
      AppPageState.empty => '当前企业正式信息为空。',
      AppPageState.content => result.message ?? '当前企业正式信息无法读取。',
      AppPageState.loading => '正在读取企业正式信息。',
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
              enterpriseName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
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

class _TargetEnterpriseInfoSuccessState extends StatelessWidget {
  const _TargetEnterpriseInfoSuccessState({
    required this.enterpriseName,
    required this.data,
    required this.onRetry,
  });

  final String enterpriseName;
  final EnterpriseHubTargetEnterpriseFormalInfoData data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final fields = buildEnterpriseTargetEnterpriseInfoFields(data);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SuccessHeader(
          enterpriseName: enterpriseName,
          statusLabel: _enterpriseFormalInfoStatusLabel(
            data.certificationStatus,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: fields.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final item = fields[index];
              return _FormalInfoFieldRow(field: item);
            },
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新读取'),
          ),
        ),
        Text(
          '当前显示为 OCR 识别后沉淀的正式认证文字信息，不展示证照图片。',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({
    required this.enterpriseName,
    required this.statusLabel,
  });

  final String enterpriseName;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            enterpriseName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            '当前认证状态',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(statusLabel),
        ],
      ),
    );
  }
}

class _FormalInfoFieldRow extends StatelessWidget {
  const _FormalInfoFieldRow({required this.field});

  final ProfileCertificationTruthField field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 108,
            child: Text(
              field.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              field.value,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

List<ProfileCertificationTruthField> buildEnterpriseTargetEnterpriseInfoFields(
  EnterpriseHubTargetEnterpriseFormalInfoData data,
) {
  final items = <ProfileCertificationTruthField>[
    if (data.legalName?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '认证主体',
        value: data.legalName!.trim(),
      ),
    if (data.uscc?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '统一社会信用代码',
        value: data.uscc!.trim(),
      ),
    if (data.legalPerson?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '法定代表人',
        value: data.legalPerson!.trim(),
      ),
    if (_normalizedBusinessType(data.businessType) case final String value)
      ProfileCertificationTruthField(label: '企业类型', value: value),
    if (data.address?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(label: '住所', value: data.address!.trim()),
    if (data.registeredCapital?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '注册资本',
        value: data.registeredCapital!.trim(),
      ),
    if (data.establishedAt?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '成立日期',
        value: data.establishedAt!.trim(),
      ),
    if (data.businessTerm?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '营业期限',
        value: data.businessTerm!.trim(),
      ),
    if (data.businessScope?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '经营范围',
        value: data.businessScope!.trim(),
      ),
    ProfileCertificationTruthField(
      label: '当前认证状态',
      value: _enterpriseFormalInfoStatusLabel(data.certificationStatus),
    ),
  ];
  return List<ProfileCertificationTruthField>.unmodifiable(items);
}

String _enterpriseFormalInfoStatusLabel(String? status) {
  final normalized = status?.trim().toLowerCase();
  return switch (normalized) {
    'approved' || 'verified' => '已通过',
    'submitted' => '已提交',
    'under_review' => '审核中',
    'rejected' => '未通过',
    'pending' => '待补齐',
    _ => status?.trim().isNotEmpty == true ? status!.trim() : '待补充',
  };
}

String? _normalizedBusinessType(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  final normalized = value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  if (normalized == 'qrcode' ||
      normalized == 'qr码' ||
      value == 'QRCode' ||
      value == '二维码') {
    return null;
  }
  return value;
}

bool _hasTargetEnterpriseInfoPreviewAccess(AppShellContextData shellContext) {
  final certificationApproved = _isApprovedStatus(
    shellContext.certificationStatus,
  );
  final personalApproved =
      _isApprovedStatus(shellContext.personalCertificationStatus) &&
      shellContext.personalCertificationQualified != false &&
      shellContext.personalCertificationLockedToOtherActor != true;
  return certificationApproved && personalApproved;
}

bool _isApprovedStatus(String? value) {
  final normalized = value?.trim().toLowerCase();
  return normalized == 'approved' || normalized == 'verified';
}
