// ignore_for_file: invalid_use_of_protected_member, unused_element

part of '../exhibition_trade_pages.dart';

extension _P0PayBidAuthorizationActions on _BidSubmitPageState {
  Future<void> _submitP0PayFixedPriceBidAndAuthorize() async {
    FocusScope.of(context).unfocus();
    final taskId = _p0PayTaskIdForFixedPriceBid;
    final blocker = _p0PayFixedPriceBidBlockerMessage();
    if (taskId == null || blocker != null) {
      setState(() {
        _p0PayFixedPriceBidResult = ExhibitionActionResult(
          method: 'POST',
          path: taskId == null
              ? ExhibitionCanonicalPaths.p0PayTradeTaskCreate
              : ExhibitionCanonicalPaths.p0PayFixedPriceBids(taskId),
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: blocker ?? '当前没有可用于明价竞标单的交易任务 ID。',
        );
      });
      return;
    }

    setState(() {
      _p0PaySubmitting = true;
      _p0PayFixedPriceBidResult = null;
      _p0PayAuthorizationResult = null;
      _p0PayAuthorizationInitResult = null;
      _p0PayAuthorizationStatusResult = null;
      _p0PayAuthorizationPollResult = null;
    });

    final quoteAmount = double.parse(_quoteAmountController.text.trim());
    final bidResult = await ExhibitionConsumerLayer.instance
        .submitP0PayFixedPriceBid(
          taskId: taskId,
          command: P0PayFixedPriceBidCommand(
            quoteAmount: quoteAmount,
            quoteValidUntil: _p0PayQuoteValidUntil(),
            taxIncluded: _p0PayTaxIncluded,
            transportIncluded: _p0PayTransportIncluded,
            installationIncluded: _p0PayInstallationIncluded,
            constructionPlan: _proposalSummaryController.text.trim(),
            materialDescription: _p0PayProfessionalPlanSummary(),
            craftDescription: _p0PayProfessionalPlanSummary(),
            buildProcess: '详见第四步上传的进度安排附件。',
            deliveryMilestones: _p0PayDeliveryMilestones(),
            riskNotes: '以第四步方案说明和必传文档为准。',
            attachmentFileAssetIds: _p0PayBidAttachmentFileAssetIds(),
            platformServiceFeeRuleAgreement:
                _p0PayPlatformServiceFeeAgreement(),
          ),
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _p0PayFixedPriceBidResult = bidResult;
    });

    final bidId = _bidIdFromPayload(bidResult.payload);
    final authorizationCommand = _p0PayAuthorizationCommandFromBidResult(
      bidResult,
    );
    if (!bidResult.isSuccess || bidId == null || authorizationCommand == null) {
      if (mounted) {
        setState(() {
          if (bidResult.isSuccess) {
            _p0PayAuthorizationResult = ExhibitionActionResult(
              method: 'POST',
              path: bidId == null
                  ? ExhibitionCanonicalPaths.p0PayFixedPriceBids(taskId)
                  : ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizations(
                      taskId,
                      bidId,
                    ),
              isSuccess: false,
              controlledState: AppPageState.errorNonRetryable,
              message: bidId == null
                  ? 'BFF 未返回 bidId，无法创建平台服务费预授权订单。'
                  : 'BFF 未返回完整 platformServiceFeeRequirement，Flutter 不本地计算预计服务费。',
            );
          }
          _p0PaySubmitting = false;
        });
      }
      return;
    }

    final authorizationResult = await ExhibitionConsumerLayer.instance
        .createP0PayServiceFeeAuthorization(
          taskId: taskId,
          bidId: bidId,
          command: authorizationCommand,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _p0PayAuthorizationResult = authorizationResult;
    });

    final authorizationId = _authorizationIdFromPayload(
      authorizationResult.payload,
    );
    if (!authorizationResult.isSuccess || authorizationId == null) {
      setState(() {
        _p0PaySubmitting = false;
      });
      return;
    }

    final initResult = await ExhibitionConsumerLayer.instance
        .initP0PayServiceFeeAuthorization(
          taskId: taskId,
          bidId: bidId,
          authorizationId: authorizationId,
          command: P0PayPayInitCommand(payChannel: _p0PayAuthorizationChannel),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _p0PayAuthorizationInitResult = initResult;
    });
    if (!initResult.isSuccess) {
      setState(() {
        _p0PaySubmitting = false;
      });
      return;
    }

    await _openP0PayAuthorizationChannelPayload(initResult.payload);
    await _pollP0PayServiceFeeAuthorizationStatus();
    if (mounted) {
      setState(() {
        _p0PaySubmitting = false;
      });
    }
  }

  List<Widget> _buildP0PayAuthorizationResultLines() {
    final bidResult = _p0PayFixedPriceBidResult;
    final authorizationResult = _p0PayAuthorizationResult;
    final initResult = _p0PayAuthorizationInitResult;
    final statusResult = _p0PayAuthorizationStatusResult;
    final pollResult = _p0PayAuthorizationPollResult;
    if (bidResult == null &&
        authorizationResult == null &&
        initResult == null &&
        statusResult == null &&
        pollResult == null) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 12),
      if (bidResult != null)
        _DetailLine(
          label: '明价竞标报价',
          value: bidResult.isSuccess
              ? '已提交：${_bidIdFromPayload(bidResult.payload) ?? '待回读'}'
              : bidResult.message ?? '提交失败',
          highlight: bidResult.isSuccess,
        ),
      if (bidResult?.isSuccess == true)
        _DetailLine(
          label: 'BFF 预计服务费',
          value: _p0PayServiceFeeRequirementSummary(bidResult!.payload),
          highlight: true,
        ),
      if (authorizationResult != null)
        _DetailLine(
          label: '平台服务费预授权订单',
          value: authorizationResult.isSuccess
              ? '已创建：${_authorizationIdFromPayload(authorizationResult.payload) ?? '待回读'}'
              : authorizationResult.message ?? '创建失败',
          highlight: authorizationResult.isSuccess,
        ),
      if (initResult != null)
        _DetailLine(
          label: '支付通道预授权',
          value: initResult.isSuccess
              ? '已拉起：${_paymentReferenceIdFromPayload(initResult.payload) ?? '等待通道确认'}'
              : _p0PayActionFailureText(initResult),
          highlight: initResult.isSuccess,
        ),
      if (statusResult != null)
        _DetailLine(
          label: '预授权状态',
          value: _p0PayAuthorizationStatusText(statusResult),
          highlight:
              pollResult?.isSuccess ??
              statusResult.state == AppPageState.content,
        ),
      if (pollResult != null)
        _StateMessage(
          title: '预授权结果',
          body: _p0PayPaymentPollResultText(pollResult),
        ),
      if (_p0PayAuthorizationIdsReady)
        TextButton.icon(
          onPressed: _p0PaySubmitting
              ? null
              : _pollP0PayServiceFeeAuthorizationStatus,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('重新轮询预授权状态'),
        ),
    ];
  }

  Future<void> _pollP0PayServiceFeeAuthorizationStatus() async {
    final taskId = _p0PayTaskIdForFixedPriceBid;
    final bidId = _bidIdFromPayload(_p0PayFixedPriceBidResult?.payload);
    final authorizationId = _authorizationIdFromPayload(
      _p0PayAuthorizationResult?.payload,
    );
    if (taskId == null || bidId == null || authorizationId == null) {
      return;
    }

    final result = await ExhibitionConsumerLayer.instance
        .pollP0PayServiceFeeAuthorizationStatus(
          taskId: taskId,
          bidId: bidId,
          authorizationId: authorizationId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _p0PayAuthorizationPollResult = result;
      _p0PayAuthorizationStatusResult = result.result;
    });
  }

  Future<void> _openP0PayAuthorizationChannelPayload(Object? payload) async {
    final url = _channelPayloadUrl(payload);
    if (url == null) {
      return;
    }
    await launchUrlString(url);
  }

  String? get _p0PayTaskIdForFixedPriceBid {
    final payload = _payloadMap(_projectDetailResult?.payload);
    return _normalizeDynamicText(payload?['taskId']) ??
        _normalizeDynamicText(payload?['tradeTaskId']) ??
        _normalizeDynamicText(_payloadMap(payload?['p0PaySummary'])?['taskId']);
  }

  bool get _p0PayAuthorizationIdsReady {
    return _p0PayTaskIdForFixedPriceBid != null &&
        _bidIdFromPayload(_p0PayFixedPriceBidResult?.payload) != null &&
        _authorizationIdFromPayload(_p0PayAuthorizationResult?.payload) != null;
  }

  String? _p0PayFixedPriceBidBlockerMessage() {
    if (_guardLoading) {
      return '当前正在核对竞标守卫，请稍候再试。';
    }
    if (_accessGuard != null) {
      return _accessGuard!.message;
    }
    if (_p0PayTaskIdForFixedPriceBid == null) {
      return '当前没有可用于明价竞标单的交易任务 ID。';
    }
    if (double.tryParse(_quoteAmountController.text.trim()) == null) {
      return '请先填写有效的竞标报价。';
    }
    if (_proposalSummaryController.text.trim().isEmpty) {
      return '请先填写方案说明。';
    }
    if (_p0PayBidAttachmentFileAssetIds().isEmpty) {
      return '请先完成当前页竞标附件上传确认。';
    }
    if (!_p0PayReadRuleConfirmed ||
        !_p0PayAuthorizationAwarenessConfirmed ||
        !_p0PayPublisherBreachReleaseConfirmed) {
      return '请先勾选全部平台服务费确认项。';
    }
    return null;
  }

  List<String> _p0PayBidAttachmentFileAssetIds() {
    final uploadedIds = _attachmentSlots
        .where((_BidSubmitAttachmentSlotState slot) => slot.isConfirmed)
        .map(
          (_BidSubmitAttachmentSlotState slot) =>
              _normalizeId(slot.fileAssetId),
        )
        .whereType<String>();
    return <String>{...uploadedIds}.toList(growable: false);
  }

  List<String> _p0PayDeliveryMilestones() => const <String>['详见第四步上传的进度安排附件'];

  String _p0PayProfessionalPlanSummary() {
    final proposalSummary = _proposalSummaryController.text.trim();
    return '详见第四步方案说明和必传文档：$proposalSummary';
  }

  String _p0PayQuoteValidUntil() {
    final expiresAt = DateTime.now().add(
      Duration(hours: _p0PayQuoteValidHours),
    );
    return _p0PayIso8601WithOffset(expiresAt);
  }

  String _p0PayIso8601WithOffset(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final offset = value.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final absoluteOffset = offset.abs();
    return '${value.year}-'
        '${twoDigits(value.month)}-'
        '${twoDigits(value.day)}T'
        '${twoDigits(value.hour)}:'
        '${twoDigits(value.minute)}:'
        '${twoDigits(value.second)}'
        '$sign'
        '${twoDigits(absoluteOffset.inHours)}:'
        '${twoDigits(absoluteOffset.inMinutes.remainder(60))}';
  }

  Map<String, Object?> _p0PayPlatformServiceFeeAgreement() {
    return <String, Object?>{
      'ruleVersion': 'platform_pricing_rules_master_v1',
      'ruleSnapshotHash': 'platform_pricing_rules_master_v1',
      'agreedAtClient': DateTime.now().toIso8601String(),
      'readConfirmed': _p0PayReadRuleConfirmed,
      'authorizationAwarenessConfirmed': _p0PayAuthorizationAwarenessConfirmed,
      'publisherBreachReleaseAwarenessConfirmed':
          _p0PayPublisherBreachReleaseConfirmed,
    };
  }

  P0PayServiceFeeAuthorizationCommand? _p0PayAuthorizationCommandFromBidResult(
    ExhibitionActionResult bidResult,
  ) {
    final requirement = _p0PayServiceFeeRequirement(bidResult.payload);
    if (requirement == null) {
      return null;
    }
    final quotedAmount = _p0PayRequirementNumber(requirement, 'quotedAmount');
    final feeRate = _p0PayRequirementText(requirement, 'feeRate');
    final estimatedFeeAmount = _p0PayRequirementText(
      requirement,
      'estimatedFeeAmount',
    );
    final currency = _p0PayRequirementText(requirement, 'currency') ?? 'CNY';
    if (quotedAmount == null || feeRate == null || estimatedFeeAmount == null) {
      return null;
    }
    return P0PayServiceFeeAuthorizationCommand(
      expectedQuotedAmount: quotedAmount,
      expectedFeeRate: feeRate,
      expectedAuthorizationAmount: estimatedFeeAmount,
      currency: currency,
    );
  }
}
