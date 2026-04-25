import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_supplier_category_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

const List<MapEntry<String, String>> enterpriseWorkbenchTeamSizeOptions =
    <MapEntry<String, String>>[
      MapEntry<String, String>('1_10', '1-10 人'),
      MapEntry<String, String>('11_30', '11-30 人'),
      MapEntry<String, String>('31_100', '31-100 人'),
      MapEntry<String, String>('101_300', '101-300 人'),
      MapEntry<String, String>('300_plus', '300 人以上'),
    ];

const List<MapEntry<String, String>> enterpriseWorkbenchUrgentOptions =
    <MapEntry<String, String>>[
      MapEntry<String, String>('none', '无加急'),
      MapEntry<String, String>('24h', '24 小时'),
      MapEntry<String, String>('48h', '48 小时'),
      MapEntry<String, String>('72h', '72 小时'),
      MapEntry<String, String>('custom', '自定义'),
    ];

const List<MapEntry<String, String>> enterpriseWorkbenchTransportOptions =
    <MapEntry<String, String>>[
      MapEntry<String, String>('none', '无运输'),
      MapEntry<String, String>('partner_only', '合作物流'),
      MapEntry<String, String>('self_owned', '自有车队'),
      MapEntry<String, String>('self_and_partner', '自有+合作'),
    ];

const List<MapEntry<String, String>> enterpriseWorkbenchCooperationModeOptions =
    <MapEntry<String, String>>[
      MapEntry<String, String>('host_service', '主场服务'),
      MapEntry<String, String>('remote_execution', '异地执行'),
      MapEntry<String, String>('package_labor_material', '包工包料'),
      MapEntry<String, String>('labor_only', '清工执行'),
      MapEntry<String, String>('subcontract_collaboration', '分包协作'),
      MapEntry<String, String>('long_term_cooperation', '长期合作'),
    ];

const List<MapEntry<String, String>>
enterpriseWorkbenchCompanyExhibitionOptions = <MapEntry<String, String>>[
  MapEntry<String, String>('特装展台', '特装展台'),
  MapEntry<String, String>('标准展位', '标准展位'),
  MapEntry<String, String>('会议活动', '会议活动'),
];

const List<MapEntry<String, String>>
enterpriseWorkbenchCompanyServiceItemOptions = <MapEntry<String, String>>[
  MapEntry<String, String>('策划设计', '策划设计'),
  MapEntry<String, String>('主场承建', '主场承建'),
  MapEntry<String, String>('落地执行', '落地执行'),
  MapEntry<String, String>('活动搭建', '活动搭建'),
];

const List<MapEntry<String, String>> enterpriseWorkbenchFactoryProcessOptions =
    <MapEntry<String, String>>[
      MapEntry<String, String>('木作', '木作制作'),
      MapEntry<String, String>('喷绘', '喷绘美工'),
      MapEntry<String, String>('桁架', '桁架结构'),
      MapEntry<String, String>('烤漆', '烤漆铁艺'),
    ];

const List<MapEntry<String, String>>
enterpriseWorkbenchSupplierCategoryOptions =
    enterpriseHubSupplierCategoryOptions;

class EnterpriseWorkbenchProgressCard extends StatelessWidget {
  const EnterpriseWorkbenchProgressCard({
    super.key,
    required this.boardType,
    required this.readiness,
  });

  final EnterpriseBoardType boardType;
  final EnterpriseHubWorkbenchReadiness readiness;

  @override
  Widget build(BuildContext context) {
    return EnterpriseSectionCard(
      title: '${boardType.title}工作台',
      subtitle: '当前页只维护当前组织的企业展示资料与申请状态，不承担公开展示入口。',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _ReadinessPill(label: '可编辑', done: readiness.draftEditable),
          _ReadinessPill(label: '基础资料', done: readiness.basicCompleted),
          _ReadinessPill(label: '板块画像', done: readiness.profileCompleted),
          _ReadinessPill(label: '案例', done: readiness.hasCase),
          _ReadinessPill(label: '联系人', done: readiness.hasContact),
          _ReadinessPill(label: '企业认证', done: readiness.certificationApproved),
          _ReadinessPill(label: '可提交', done: readiness.submitReady),
        ],
      ),
    );
  }
}

class EnterpriseWorkbenchReadinessCard extends StatelessWidget {
  const EnterpriseWorkbenchReadinessCard({
    super.key,
    required this.readiness,
    required this.statusLabel,
  });

  final EnterpriseHubWorkbenchReadiness readiness;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return EnterpriseSectionCard(
      title: '当前申请状态',
      subtitle: statusLabel,
      child: readiness.blockers.isEmpty
          ? const Text('当前没有阻塞项，可以继续提交或查看状态。')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: readiness.blockers
                  .map(
                    (String item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(Icons.error_outline_rounded, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class EnterpriseWorkbenchCaseListCard extends StatelessWidget {
  const EnterpriseWorkbenchCaseListCard({
    super.key,
    required this.items,
    this.onContinueEdit,
    this.onDelete,
    this.onCreateCase,
    this.createActionLabel = '新增案例',
  });

  final List<EnterpriseHubWorkbenchCaseItem> items;
  final ValueChanged<String>? onContinueEdit;
  final ValueChanged<String>? onDelete;
  final VoidCallback? onCreateCase;
  final String createActionLabel;

  @override
  Widget build(BuildContext context) {
    return EnterpriseSectionCard(
      title: '案例库',
      subtitle: items.isEmpty
          ? '当前展示档下还没有已保存案例。提交门槛认的是这里。'
          : '这里回读当前展示档下已保存的案例；提交门槛认的是这里。',
      actions: onCreateCase == null
          ? const <Widget>[]
          : <Widget>[
              FilledButton.tonal(
                onPressed: onCreateCase,
                child: Text(createActionLabel),
              ),
            ],
      child: items.isEmpty
          ? const Text('当前案例库为空。')
          : Column(
              children: items
                  .map(
                    (EnterpriseHubWorkbenchCaseItem item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${enterpriseWorkbenchCaseStatusLabel(item.caseStatus)}${item.eventTime == null ? '' : ' · ${enterpriseWorkbenchDisplayDateLabel(item.eventTime)}'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (onContinueEdit != null ||
                              onDelete != null) ...<Widget>[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                spacing: 4,
                                children: <Widget>[
                                  if (onContinueEdit != null)
                                    TextButton(
                                      key: ValueKey<String>(
                                        'enterprise-workbench-case-continue-edit-${item.caseId}',
                                      ),
                                      onPressed: () =>
                                          onContinueEdit!(item.caseId),
                                      child: const Text('继续编辑'),
                                    ),
                                  if (onDelete != null)
                                    TextButton(
                                      onPressed: () => onDelete!(item.caseId),
                                      child: const Text('删除案例'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class EnterpriseWorkbenchDropdownField extends StatelessWidget {
  const EnterpriseWorkbenchDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
  });

  final String label;
  final String? value;
  final List<MapEntry<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: items.any((item) => item.key == value) ? value : null,
      decoration: InputDecoration(
        label: _WorkbenchFieldLabel(label: label, required: required),
        border: const OutlineInputBorder(),
      ),
      items: <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(value: '', child: Text('暂不填写')),
        ...items.map(
          (MapEntry<String, String> item) => DropdownMenuItem<String>(
            value: item.key,
            child: Text(item.value),
          ),
        ),
      ],
      onChanged: (String? next) {
        if (next == null || next.isEmpty) {
          onChanged(null);
          return;
        }
        onChanged(next);
      },
    );
  }
}

class EnterpriseWorkbenchBoardProfileHeader extends StatelessWidget {
  const EnterpriseWorkbenchBoardProfileHeader({
    super.key,
    required this.boardType,
  });

  final EnterpriseBoardType boardType;

  @override
  Widget build(BuildContext context) {
    return Text(switch (boardType) {
      EnterpriseBoardType.company => '当前主板块为公司，重点维护业务方向、服务项目和案例履历。',
      EnterpriseBoardType.factory => '当前主板块为工厂，重点维护工艺、产能与交付能力。',
      EnterpriseBoardType.supplier => '当前主板块为供应商，重点维护主营品类与响应能力。',
    }, style: Theme.of(context).textTheme.bodySmall);
  }
}

class EnterpriseWorkbenchMultiSelectField extends StatelessWidget {
  const EnterpriseWorkbenchMultiSelectField({
    super.key,
    required this.label,
    required this.helperText,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.required = false,
    this.singleSelect = false,
  });

  final String label;
  final String helperText;
  final List<MapEntry<String, String>> options;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onChanged;
  final bool required;
  final bool singleSelect;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        label: _WorkbenchFieldLabel(label: label, required: required),
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (option) => FilterChip(
                label: Text(option.value),
                selected: selectedValues.contains(option.key),
                onSelected: (selected) {
                  final next = singleSelect
                      ? <String>{}
                      : Set<String>.of(selectedValues);
                  if (selected) {
                    next.add(option.key);
                  } else {
                    next.remove(option.key);
                  }
                  onChanged(next);
                },
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _WorkbenchFieldLabel extends StatelessWidget {
  const _WorkbenchFieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    if (!required) {
      return Text(label, style: style);
    }
    return RichText(
      text: TextSpan(
        style: style,
        children: <InlineSpan>[
          TextSpan(
            text: '* ',
            style: style?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          TextSpan(text: label),
        ],
      ),
    );
  }
}

class _ReadinessPill extends StatelessWidget {
  const _ReadinessPill({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: done
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label),
      ),
    );
  }
}

String enterpriseWorkbenchApplicationStatusLabel(String? status) {
  switch (status) {
    case 'draft':
      return '当前可继续编辑并提交。';
    case 'submitted':
      return '当前已提交，等待审核。';
    case 'under_review':
      return '当前审核中。';
    case 'revision_required':
      return '当前被要求补充资料，请补齐后重新提交。';
    case 'approved':
      return '当前申请已通过审核。';
    case 'rejected':
      return '当前申请未通过，可补齐资料后重新发起。';
    default:
      return '当前还没有申请记录。';
  }
}

String enterpriseWorkbenchCaseStatusLabel(String? status) {
  switch (status?.trim()) {
    case 'draft':
      return '已保存到案例库';
    case 'submitted':
      return '已进入审核';
    case 'approved':
      return '已进入公域';
    case 'rejected':
      return '审核未通过';
    default:
      return '状态待补充';
  }
}

String enterpriseWorkbenchDisplayDateLabel(String? rawValue) {
  final normalized = rawValue?.trim();
  if (normalized == null || normalized.isEmpty) {
    return '时间未提供';
  }
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(normalized);
  if (match == null) {
    return normalized;
  }
  return '${match.group(1)}年${match.group(2)}月${match.group(3)}日';
}
