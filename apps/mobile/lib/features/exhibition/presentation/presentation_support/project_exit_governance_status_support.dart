part of '../exhibition_trade_pages.dart';

enum _ProjectExitGovernancePlacement { conversation, orderDetail }

final class _ProjectExitGovernanceSnapshot {
  const _ProjectExitGovernanceSnapshot({
    required this.exitCaseId,
    required this.exitType,
    required this.caseStatus,
    required this.breachParty,
    required this.counterpartyAction,
    required this.updatedAt,
  });

  final String? exitCaseId;
  final String? exitType;
  final String? caseStatus;
  final String? breachParty;
  final String? counterpartyAction;
  final String? updatedAt;
}

_ProjectExitGovernanceSnapshot? _projectExitGovernanceSnapshotFromMap(
  Map<String, Object?>? map,
) {
  final source = _payloadMap(map?['exitGovernance']);
  if (source == null) {
    return null;
  }
  return _ProjectExitGovernanceSnapshot(
    exitCaseId: _normalizeDynamicText(source['exitCaseId']),
    exitType: _normalizeDynamicText(source['exitType']),
    caseStatus: _normalizeDynamicText(source['caseStatus']),
    breachParty: _normalizeDynamicText(source['breachParty']),
    counterpartyAction:
        _normalizeDynamicText(source['counterpartyAction']) ??
        _normalizeDynamicText(source['actionHint']),
    updatedAt: _normalizeDynamicText(source['updatedAt']),
  );
}

_ProjectExitGovernanceSnapshot? _projectExitGovernanceSnapshotFromConversation(
  CounterpartConversationExitGovernanceView? view,
) {
  if (view == null) {
    return null;
  }
  return _ProjectExitGovernanceSnapshot(
    exitCaseId: view.exitCaseId,
    exitType: view.exitType,
    caseStatus: view.caseStatus,
    breachParty: view.breachParty,
    counterpartyAction: view.counterpartyAction,
    updatedAt: view.updatedAt,
  );
}

class _ProjectExitGovernanceStatusCard extends StatelessWidget {
  const _ProjectExitGovernanceStatusCard({
    required this.snapshot,
    required this.placement,
    this.projectId,
    this.orderId,
    this.onOpenOrder,
  });

  final _ProjectExitGovernanceSnapshot snapshot;
  final _ProjectExitGovernancePlacement placement;
  final String? projectId;
  final String? orderId;
  final VoidCallback? onOpenOrder;

  @override
  Widget build(BuildContext context) {
    final readOnlyText =
        placement == _ProjectExitGovernancePlacement.conversation
        ? '消息楼仅展示状态，不在这里裁决取消或违约；需要处理时回到项目或订单详情。'
        : '订单详情只承接当前状态和入口，不自动扣钱、不删除订单合同。';
    return _ActionCard(
      title: '退出/违约状态',
      summary: readOnlyText,
      tone: _ActionCardTone.muted,
      children: <Widget>[
        _DetailLine(
          label: '当前状态',
          value: _projectExitCaseStatusLabel(snapshot.caseStatus),
          highlight: true,
        ),
        _DetailLine(
          label: '当前事项',
          value: _projectExitTypeLabel(snapshot.exitType, snapshot.breachParty),
        ),
        _DetailLine(
          label: '对方动作',
          value:
              snapshot.counterpartyAction ??
              _projectExitCounterpartyActionLabel(snapshot.caseStatus),
        ),
        if (snapshot.updatedAt != null)
          _DetailLine(label: '更新时间', value: snapshot.updatedAt!),
        if (placement == _ProjectExitGovernancePlacement.conversation &&
            onOpenOrder != null) ...<Widget>[
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onOpenOrder,
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('查看订单详情'),
          ),
        ],
        if (placement == _ProjectExitGovernancePlacement.orderDetail &&
            projectId != null) ...<Widget>[
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pushNamed(
              ExhibitionRoutes.myProjectDetailWithProjectId(projectId!),
            ),
            icon: const Icon(Icons.work_outline_rounded),
            label: const Text('回到我的项目处理'),
          ),
        ],
      ],
    );
  }
}

String _projectExitCaseStatusLabel(String? value) {
  return switch (value) {
    'requested' => '等待对方确认',
    'accepted' => '双方已同意',
    'rejected' => '对方已拒绝',
    'recorded' => '已留痕',
    'closed' => '已关闭',
    _ => '已记录',
  };
}

String _projectExitTypeLabel(String? exitType, String? breachParty) {
  return switch (exitType) {
    'mutual_cancellation' => '双方取消申请',
    'publisher_breach' => '发布方违约留痕',
    'factory_breach' => '工厂违约留痕',
    'submitted_discard' => '预发布作废',
    'published_withdrawal' => '竞标中撤回',
    _ => switch (breachParty) {
      'publisher' => '发布方违约留痕',
      'factory' => '工厂违约留痕',
      _ => '退出治理事项',
    },
  };
}

String _projectExitCounterpartyActionLabel(String? caseStatus) {
  return switch (caseStatus) {
    'requested' => '等待对方同意或拒绝',
    'accepted' => '对方已同意',
    'rejected' => '对方已拒绝',
    'recorded' => '本期只做信用候选留痕',
    _ => '以项目/订单详情为准',
  };
}
