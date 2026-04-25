// ignore_for_file: invalid_use_of_protected_member

part of '../exhibition_trade_pages.dart';

extension _P0PayBidAuthorizationSupport on _BidSubmitPageState {
  Widget _buildP0PayFixedPriceBidAuthorizationSection() {
    final blocker = _p0PayFixedPriceBidBlockerMessage();
    final canSubmit = !_p0PaySubmitting && blocker == null;
    final taskId = _p0PayTaskIdForFixedPriceBid;

    return _ActionCard(
      title: 'P0-Pay 平台服务费预授权',
      summary: '明价竞标单报名时只做平台服务费预授权；预授权不是实际扣费，未中标自动释放，中标并合同确认后才按最终成交确认金额正式扣费。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (taskId != null) ...<Widget>[
          _InstanceSummaryLine(title: '当前交易任务 ID', value: taskId),
          const SizedBox(height: 8),
        ],
        const _DetailLine(label: '平台服务费率', value: '3%（P0-Pay 冻结规则提示）'),
        const _DetailLine(label: '预计服务费', value: '提交报价后读取 BFF/Server 返回值'),
        const _StateMessage(
          title: '资金边界',
          body:
              'Flutter 只提交报价、展示 BFF 回读的预计服务费，并拉起支付通道 channel payload；资金状态真相只读 Server/BFF 回读，不在本地生成或裁定。',
        ),
        const SizedBox(height: 12),
        _InputField(
          controller: _p0PayQuoteValidUntilController,
          inputKey: const ValueKey<String>('p0-pay-bid-quote-valid-until'),
          label: '报价有效期',
          hintText: '例如：2026-05-20T18:00:00+08:00',
          helperText: '用于提交明价竞标单报价，不作为平台服务费最终收费真值。',
          onChanged: (_) => setState(() {}),
        ),
        _buildP0PayInclusionSwitches(),
        _InputField(
          controller: _p0PayMaterialDescriptionController,
          inputKey: const ValueKey<String>('p0-pay-bid-material-description'),
          label: '材料说明',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        _InputField(
          controller: _p0PayCraftDescriptionController,
          inputKey: const ValueKey<String>('p0-pay-bid-craft-description'),
          label: '工艺说明',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        _InputField(
          controller: _p0PayBuildProcessController,
          inputKey: const ValueKey<String>('p0-pay-bid-build-process'),
          label: '搭建流程',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        _InputField(
          controller: _p0PayDeliveryMilestonesController,
          inputKey: const ValueKey<String>('p0-pay-bid-delivery-milestones'),
          label: '交付节点',
          hintText: '例如：结构搭建, 灯光安装, 撤展交付',
          helperText: '可用逗号、分号或换行分隔多个节点。',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        _InputField(
          controller: _p0PayRiskNotesController,
          inputKey: const ValueKey<String>('p0-pay-bid-risk-notes'),
          label: '风险说明',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        _InputField(
          controller: _p0PayAttachmentFileAssetIdsController,
          inputKey: const ValueKey<String>('p0-pay-bid-attachment-ids'),
          label: '补充报价附件 FileAsset ID',
          hintText: '例如：file-a,file-b',
          helperText: '已在当前页上传并确认的三类竞标附件会自动带入；这里仅补充额外附件 ID。',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        _buildP0PayChannelSelector(),
        const SizedBox(height: 8),
        _buildP0PayAuthorizationCheckbox(
          value: _p0PayReadRuleConfirmed,
          title: '我已阅读并同意平台成交服务费规则',
          onChanged: (bool value) =>
              setState(() => _p0PayReadRuleConfirmed = value),
        ),
        _buildP0PayAuthorizationCheckbox(
          value: _p0PayAuthorizationAwarenessConfirmed,
          title: '我知晓未中标自动释放，中标并合同确认后正式扣款',
          onChanged: (bool value) =>
              setState(() => _p0PayAuthorizationAwarenessConfirmed = value),
        ),
        _buildP0PayAuthorizationCheckbox(
          value: _p0PayPublisherBreachReleaseConfirmed,
          title: '我知晓发布方毁约或项目条件重大变化时，预授权应按规则释放',
          onChanged: (bool value) =>
              setState(() => _p0PayPublisherBreachReleaseConfirmed = value),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const ValueKey<String>('p0-pay-submit-fixed-bid-authorize'),
          onPressed: canSubmit ? _submitP0PayFixedPriceBidAndAuthorize : null,
          icon: _p0PaySubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.verified_user_outlined),
          label: const Text('提交报价并确认平台服务费预授权'),
        ),
        if (!canSubmit && !_p0PaySubmitting) ...<Widget>[
          const SizedBox(height: 8),
          _StateMessage(
            title: '预授权条件未完成',
            body: blocker ?? '请先补齐报价字段、附件和预授权确认项。',
          ),
        ],
        ..._buildP0PayAuthorizationResultLines(),
      ],
    );
  }

  Widget _buildP0PayInclusionSwitches() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilterChip(
          label: const Text('含税'),
          selected: _p0PayTaxIncluded,
          onSelected: (bool value) => setState(() => _p0PayTaxIncluded = value),
        ),
        FilterChip(
          label: const Text('含运输'),
          selected: _p0PayTransportIncluded,
          onSelected: (bool value) =>
              setState(() => _p0PayTransportIncluded = value),
        ),
        FilterChip(
          label: const Text('含安装'),
          selected: _p0PayInstallationIncluded,
          onSelected: (bool value) =>
              setState(() => _p0PayInstallationIncluded = value),
        ),
      ],
    );
  }

  Widget _buildP0PayChannelSelector() {
    return SegmentedButton<String>(
      segments: const <ButtonSegment<String>>[
        ButtonSegment<String>(
          value: 'alipay_candidate',
          label: Text('支付宝'),
          icon: Icon(Icons.payments_outlined),
        ),
        ButtonSegment<String>(
          value: 'wechat_candidate',
          label: Text('微信'),
          icon: Icon(Icons.chat_bubble_outline),
        ),
        ButtonSegment<String>(
          value: 'other_candidate',
          label: Text('其他'),
          icon: Icon(Icons.more_horiz),
        ),
      ],
      selected: <String>{_p0PayAuthorizationChannel},
      onSelectionChanged: (Set<String> value) {
        setState(() {
          _p0PayAuthorizationChannel = value.first;
        });
      },
    );
  }

  Widget _buildP0PayAuthorizationCheckbox({
    required bool value,
    required String title,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      title: Text(title),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool? next) => onChanged(next ?? false),
    );
  }
}

Map<String, Object?>? _p0PayServiceFeeRequirement(Object? payload) {
  final payloadMap = _payloadMap(payload);
  return _payloadMap(payloadMap?['platformServiceFeeRequirement']);
}

String _p0PayServiceFeeRequirementSummary(Object? payload) {
  final requirement = _p0PayServiceFeeRequirement(payload);
  if (requirement == null) {
    return 'BFF 未返回 platformServiceFeeRequirement';
  }
  final feeRate = _p0PayRequirementText(requirement, 'feeRate') ?? '未提供';
  final quotedAmount =
      _p0PayRequirementText(requirement, 'quotedAmount') ?? '未提供';
  final estimatedFeeAmount =
      _p0PayRequirementText(requirement, 'estimatedFeeAmount') ?? '未提供';
  final currency = _p0PayRequirementText(requirement, 'currency') ?? 'CNY';
  final authorizationStatus =
      _p0PayRequirementText(requirement, 'authorizationStatus') ?? '待预授权';
  return '报价 $quotedAmount $currency；费率 $feeRate；预计服务费 $estimatedFeeAmount $currency；状态 $authorizationStatus';
}

String _p0PayAuthorizationStatusText(ExhibitionLoadResult? result) {
  if (result == null) {
    return '未查询';
  }
  if (result.state != AppPageState.content) {
    return result.message ?? result.errorCode ?? '暂不可用';
  }
  final payload = _payloadMap(result.payload);
  final status =
      _normalizeDynamicText(payload?['authorizationStatus']) ??
      _normalizeDynamicText(payload?['status']) ??
      '已回读';
  final feeRate = _normalizeDynamicText(payload?['feeRate']);
  final estimatedFeeAmount = _normalizeDynamicText(
    payload?['estimatedFeeAmount'],
  );
  final currency = _normalizeDynamicText(payload?['currency']) ?? 'CNY';
  final suffix = status == 'authorized' ? '；已预授权，不是已扣款' : '';
  return <String>[
    '状态：$status$suffix',
    if (feeRate != null) '费率：$feeRate',
    if (estimatedFeeAmount != null) '预计服务费：$estimatedFeeAmount $currency',
  ].join('；');
}

String? _authorizationIdFromPayload(Object? payload) {
  return _stringFromPayload(payload, 'authorizationId');
}

String? _p0PayRequirementText(Map<String, Object?> requirement, String key) {
  return _normalizeDynamicText(requirement[key]);
}

double? _p0PayRequirementNumber(Map<String, Object?> requirement, String key) {
  final value = requirement[key];
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(_normalizeDynamicText(value) ?? '');
}
