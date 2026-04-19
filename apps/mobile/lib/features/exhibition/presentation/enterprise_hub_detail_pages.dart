import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_target_enterprise_info_sheet.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class EnterpriseDetailPage extends StatefulWidget {
  const EnterpriseDetailPage({
    super.key,
    required this.boardType,
    required this.enterpriseId,
  });

  final EnterpriseBoardType boardType;
  final String? enterpriseId;

  @override
  State<EnterpriseDetailPage> createState() => _EnterpriseDetailPageState();
}

class _EnterpriseDetailPageState extends State<EnterpriseDetailPage> {
  EnterpriseHubLoadResult<EnterpriseHubDetailData>? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enterpriseId = widget.enterpriseId?.trim();
    if (enterpriseId == null || enterpriseId.isEmpty) {
      setState(() {
        _result = EnterpriseHubLoadResult<EnterpriseHubDetailData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}',
          message: '缺少 enterpriseId，当前无法进入详情页。',
        );
      });
      return;
    }

    setState(() => _loading = true);
    final result = await EnterpriseHubConsumerLayer.instance
        .loadEnterpriseDetail(
          enterpriseId: enterpriseId,
          boardType: widget.boardType,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _openTargetEnterpriseInfoSheet() async {
    final enterpriseId = widget.enterpriseId?.trim();
    if (enterpriseId == null || enterpriseId.isEmpty) {
      return;
    }
    final data = _result?.data;
    if (data == null) {
      return;
    }
    await showEnterpriseTargetEnterpriseInfoSheet(
      context,
      enterpriseId: enterpriseId,
      enterpriseName: data.header.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _result?.data;
    if (_loading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          EnterpriseSectionCard(
            title: widget.boardType.detailTitle,
            subtitle: '当前还没有读取到真实企业详情；页面保持受控阻断，不把空态或错误态伪装成实体已接通。',
            actions: <Widget>[
              FilledButton.tonal(
                onPressed: _loading ? null : _load,
                child: Text(_loading ? '读取中' : '重试'),
              ),
            ],
            child: Text(_result?.message ?? '当前详情暂不可用。'),
          ),
        ],
      );
    }

    final shellSnapshot = AppShellScope.of(context).snapshot;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        EnterpriseDetailRelayoutSurface(
          data: data,
          boardType: widget.boardType,
          shellContext: shellSnapshot.shellContext,
          onOpenTargetEnterpriseInfo: _openTargetEnterpriseInfoSheet,
        ),
      ],
    );
  }
}
