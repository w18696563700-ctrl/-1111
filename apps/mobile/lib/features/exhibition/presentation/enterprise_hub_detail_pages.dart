import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

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

    setState(() {
      _loading = true;
    });

    final result = await EnterpriseHubConsumerLayer.instance.loadEnterpriseDetail(
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
            subtitle: '详情页统一骨架未拆散，当前先展示受控失败信息。',
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        EnterpriseHeaderSection(
          header: data.header,
          onApplyPressed: () {
            Navigator.of(context).pushNamed(
              ExhibitionRoutes.enterpriseApplyWithBoardType(
                widget.boardType.contractName,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: 'basicInfo',
          child: _DetailInfoList(
            entries: <MapEntry<String, String>>[
              MapEntry<String, String>('主体名称', data.basicInfo.legalName ?? '暂未补充'),
              MapEntry<String, String>('成立时间', data.basicInfo.foundedAt ?? '暂未补充'),
              MapEntry<String, String>('团队规模', data.basicInfo.teamSizeRange ?? '暂未补充'),
              MapEntry<String, String>('地址', data.basicInfo.address ?? '暂未补充'),
              MapEntry<String, String>('完整介绍', data.basicInfo.fullIntro ?? '暂未补充'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: 'boardProfile',
          child: _DetailInfoList(entries: _boardProfileEntries(data.boardProfile)),
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: 'serviceAreas',
          child: data.serviceAreas.isEmpty
              ? const Text('当前未返回服务区域。')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.serviceAreas
                      .map(
                        (EnterpriseHubServiceArea item) => Chip(
                          label: Text(
                            <String>[
                              if (item.areaType != null) item.areaType!,
                              item.provinceName,
                              if (item.cityName != null) item.cityName!,
                            ].join(' · '),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        const SizedBox(height: 16),
        EnterpriseCaseGallery(items: data.cases),
        const SizedBox(height: 16),
        EnterpriseCertificationSection(items: data.certifications),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: 'reviewSummary',
          child: _DetailInfoList(
            entries: <MapEntry<String, String>>[
              MapEntry<String, String>(
                '综合评分',
                data.reviewSummary.avgScore?.toStringAsFixed(1) ?? '暂未补充',
              ),
              MapEntry<String, String>(
                '评价数',
                data.reviewSummary.reviewCount?.toString() ?? '暂未补充',
              ),
              MapEntry<String, String>(
                '交付评分',
                data.reviewSummary.deliveryScore?.toStringAsFixed(1) ?? '暂未补充',
              ),
              MapEntry<String, String>(
                '质量评分',
                data.reviewSummary.qualityScore?.toStringAsFixed(1) ?? '暂未补充',
              ),
              MapEntry<String, String>(
                '沟通评分',
                data.reviewSummary.communicationScore?.toStringAsFixed(1) ?? '暂未补充',
              ),
              MapEntry<String, String>(
                '关键词',
                data.reviewSummary.keywordTags.isEmpty
                    ? '暂未补充'
                    : data.reviewSummary.keywordTags.join(' / '),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnterpriseContactSection(items: data.contacts),
      ],
    );
  }
}

class _DetailInfoList extends StatelessWidget {
  const _DetailInfoList({required this.entries});

  final List<MapEntry<String, String>> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map(
            (MapEntry<String, String> entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 96,
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

List<MapEntry<String, String>> _boardProfileEntries(Map<String, Object?> profile) {
  final entries = <MapEntry<String, String>>[];
  profile.forEach((String key, Object? value) {
    if (value == null) {
      return;
    }

    if (value is List) {
      final normalized = value
          .map((Object? item) => '$item'.trim())
          .where((String item) => item.isNotEmpty)
          .join(' / ');
      if (normalized.isEmpty) {
        return;
      }
      entries.add(MapEntry<String, String>(_profileLabel(key), normalized));
      return;
    }

    entries.add(MapEntry<String, String>(_profileLabel(key), '$value'));
  });

  if (entries.isEmpty) {
    entries.add(const MapEntry<String, String>('当前板块画像', '暂未补充'));
  }
  return entries;
}

String _profileLabel(String key) {
  return switch (key) {
    'exhibitionTypes' => '展会类型',
    'serviceItems' => '服务项目',
    'serviceCities' => '服务城市',
    'teamSize' => '团队人数',
    'maxProjectScale' => '最大项目规模',
    'averageDeliveryCycleDays' => '平均交付天数',
    'knownClients' => '已知客户',
    'qualificationDesc' => '资质说明',
    'projectManagementCapability' => '项目管理能力',
    'onsiteExecutionCapability' => '现场执行能力',
    'processTypes' => '工艺类型',
    'coreProducts' => '核心产品',
    'equipmentList' => '设备清单',
    'plantAreaSqm' => '厂房面积',
    'monthlyCapacityDesc' => '月产能',
    'urgentOrderCapability' => '加急能力',
    'urgentCycleDesc' => '加急周期',
    'warehouseCapability' => '仓储能力',
    'transportCapability' => '运输能力',
    'maxOrderCapacityDesc' => '最大订单承接能力',
    'productionQualificationDesc' => '生产资质',
    'deliveryRadiusDesc' => '配送半径',
    'supplyCategories' => '供应品类',
    'supplyMode' => '供应模式',
    'coreProductsOrServices' => '核心产品或服务',
    'responseSlaDesc' => '响应时效',
    'stockStatusDesc' => '库存状态',
    'deliveryRange' => '配送范围',
    'aftersalesPolicy' => '售后政策',
    'partnerCasesDesc' => '合作案例说明',
    'supplyQualificationDesc' => '供给资质',
    _ => key,
  };
}
