part of '../exhibition_trade_pages.dart';

String _frontStageStateLabel(String state) {
  return switch (state) {
    'published' => '竞标中',
    'bidding_closed' => '竞标已结束',
    'awarded' => '已授标',
    'converted_to_order' => '已被承接',
    'available' => '可锁定',
    'locked' => '已锁定',
    'released' => '已释放',
    'timed_out' => '已超时',
    'submitted' => '预发布列表',
    'archived' => '已归档',
    'won' => '已中标',
    'active' => '进行中',
    'completed' => '已完成',
    'cancelled' => '已取消',
    'none' => '未申请完工',
    'requested' => '待发布方确认完工',
    'rejected' => '已拒绝完工',
    'dispute_reserved' => '已预留争议',
    'confirmed' => '已确认完工',
    'pending_submission' => '待提交',
    'pending_confirm' => '待确认',
    'draft' => '草稿',
    'accepted' => '已受理',
    'opened' => '已开启',
    'withdrawn' => '已撤回',
    'amended' => '已改单',
    'rechecked' => '已复检',
    'eligible' => '待评价',
    'complete' => '资料完整',
    'incomplete' => '资料不完整',
    'lost' => '未中标',
    _ => state,
  };
}

String _frontStageLoadMessage({required String path}) {
  if (path == ExhibitionCanonicalPaths.myProjectList) {
    return '我的项目已经加载，可以先看当前组织有哪些项目仍在继续处理，再进入单项目页。';
  }
  if (ExhibitionCanonicalPaths.isMyProjectDetail(path)) {
    return '单项目继续处理信息已经到位，可以先确认公域信息，再看私域进度。';
  }

  return switch (path) {
    ExhibitionCanonicalPaths.projectList => '项目池已经加载，可以先判断是继续跟进现有项目，还是发布新项目。',
    ExhibitionCanonicalPaths.projectEditDetail =>
      '项目编辑资料已经到位，可以继续核对当前内容，并决定是仅保存草稿还是进入预发布列表。',
    ExhibitionCanonicalPaths.projectDetail => '项目详情已经到位，可以先确认当前项目状态，再继续后续承接。',
    ExhibitionCanonicalPaths.bidResult =>
      '竞标结果已经到位，可以先确认当前项目下的最小结果回读，再决定是否回到项目详情继续。',
    ExhibitionCanonicalPaths.orderDetail =>
      '后续承接状态已经到位，可以先判断当前要推进里程碑还是进入后半链路入口。',
    ExhibitionCanonicalPaths.milestoneList => '里程碑清单已经到位，现在可以选择当前要推进的里程碑。',
    ExhibitionCanonicalPaths.ratingEntry =>
      '评价入口已经到位，可以先确认当前订单是否已承接评价锚点，再决定是否提交。',
    ExhibitionCanonicalPaths.projectCounterpartyRatingEntry =>
      '双方互评入口已经到位，可以先确认当前订单、项目与被评主体三锚点，再决定是否提交。',
    _ => '当前链路已经进入可继续状态，可以按下方动作继续推进。',
  };
}

String _frontStageSuccessMessage({required String path}) {
  return switch (path) {
    ExhibitionCanonicalPaths.projectCreate =>
      '项目已创建，基本信息已保存；下一步先进入我的项目详情，确认信息后再决定继续编辑或保存到预发布列表。',
    ExhibitionCanonicalPaths.projectSave => '已仅保存草稿，可继续编辑当前项目。',
    ExhibitionCanonicalPaths.projectSubmit => '已保存到预发布列表，请先检查无误后再正式发布。',
    ExhibitionCanonicalPaths.projectPublish => '已正式发布，可继续查看公域详情或补充资料。',
    ExhibitionCanonicalPaths.projectWithdraw => '项目已经撤回到草稿，下一步可以继续编辑。',
    ExhibitionCanonicalPaths.projectArchive => '项目已经作废归档，后续只保留归档查看入口。',
    ExhibitionCanonicalPaths.projectClose => '项目已经下架关闭，后续只保留归档查看入口。',
    ExhibitionCanonicalPaths.projectWithdrawPublished =>
      '项目已经撤回到预发布列表，并退出公域展示。',
    ExhibitionCanonicalPaths.projectDiscardSubmitted =>
      '项目已经作废并归档，后续只保留归档查看入口。',
    ExhibitionCanonicalPaths.projectCancellationRequest => '取消申请已受理，等待对方确认。',
    ExhibitionCanonicalPaths.projectCancellationRespond => '取消响应已受理。',
    ExhibitionCanonicalPaths.projectPublisherBreachRecord ||
    ExhibitionCanonicalPaths.projectFactoryBreachRecord =>
      '违约记录已受理，本期只做留痕，不自动扣钱。',
    ExhibitionCanonicalPaths.bidAward =>
      '当前定标桥接已受理，页面会同步刷新项目详情与我的项目，并继续保留最小结果承接。',
    ExhibitionCanonicalPaths.bidSelectAndCreateOrder =>
      '合作方选择已受理，页面会同步刷新项目详情与我的项目，并继续以后续承接状态承接。',
    ExhibitionCanonicalPaths.contractConfirm =>
      '合同承接状态确认已受理，最终合同金额仍以最终金额确认入口为准。',
    ExhibitionCanonicalPaths.contractAmend =>
      '合同改单已受理，页面会继续回显最新合同状态，并同步刷新我的项目与项目工作台。',
    ExhibitionCanonicalPaths.orderCompleteRequest =>
      '完工申请已受理，页面会继续回显订单状态，并等待发布方确认。',
    ExhibitionCanonicalPaths.orderCompleteConfirm =>
      '完工确认已受理，订单会进入完成链路；后续双方互评仍以后端评价入口为准。',
    ExhibitionCanonicalPaths.orderCompleteReject =>
      '完工拒绝已受理，订单会继续停留在受控沟通状态；是否进入争议以后端结果为准。',
    ExhibitionCanonicalPaths.bidSubmit => '竞标已经提交完成，下一步可以回看项目详情。',
    ExhibitionCanonicalPaths.milestoneSubmit =>
      '当前里程碑提交入口已受理，后续可以继续查看验收详情；这不代表里程碑 truth 已在本页推进。',
    ExhibitionCanonicalPaths.inspectionSubmit =>
      '当前验收提交入口已受理，后续仍以验收详情真值为准；这不代表验收状态已在本页推进。',
    ExhibitionCanonicalPaths.inspectionRecheck =>
      '当前验收复检入口已受理，页面会继续回显最新验收状态，并同步刷新项目工作台。',
    ExhibitionCanonicalPaths.ratingSubmit =>
      '当前评价提交入口已受理，页面会同步刷新我的项目与项目工作台，并继续保留最小结果承接。',
    ExhibitionCanonicalPaths.projectCounterpartyRatingSubmit =>
      '当前双方互评已提交，页面会刷新评价入口、订单与我的项目缓存；信用联动以后端为准。',
    ExhibitionCanonicalPaths.disputeOpen =>
      '当前争议开启入口已受理，后续仍停留在边界续接；这不代表争议 truth 已创建。',
    ExhibitionCanonicalPaths.disputeWithdraw =>
      '当前争议撤回入口已受理，页面会同步刷新我的项目与项目工作台，并继续保留最小结果承接。',
    _ => '当前动作已经完成，可以按下方入口继续当前链路。',
  };
}

String _loadStateLabel(AppPageState state) {
  return switch (state) {
    AppPageState.content => '内容已准备好',
    AppPageState.empty => '当前无内容',
    AppPageState.errorRetryable => '可重试',
    AppPageState.errorNonRetryable => '当前受控',
    AppPageState.unauthorized => '待恢复登录',
    AppPageState.forbidden => '当前未开放',
    AppPageState.notFound => '暂未承接',
    AppPageState.loading => '准备中',
  };
}

String _loadStateActionHint(ExhibitionLoadResult result) {
  if (result.path == ExhibitionCanonicalPaths.projectDetail &&
      result.errorCode == 'AUTH_RESOURCE_UNAVAILABLE') {
    return '当前页只读承接公域展示退出；这不代表项目不存在，也不代表 owner 私域不可见。你可以回到项目展示继续查看其他公开项目。';
  }

  return switch (result.state) {
    AppPageState.content => '当前页已经准备好，可以直接看下方内容与动作区，按当前链路继续往下走。',
    AppPageState.empty => '当前页先停留在空态说明，方便客户理解这里为什么暂时没有内容，以及现在该回到哪一步。',
    AppPageState.errorRetryable => '当前内容这次没有稳定返回，你可以先重试；如果仍未恢复，再按下方回退入口回到上一步。',
    AppPageState.errorNonRetryable => '当前页保持受控反馈，不会本地编造内容。先看清提示，再决定是否回到上一步继续。',
    AppPageState.unauthorized => '当前页需要先恢复登录或授权状态，页面不会继续假装可进入。',
    AppPageState.forbidden => '当前页先明确告诉你“现在不能做什么”，避免把未开放内容伪装成没做完。',
    AppPageState.notFound => '当前实例还没有承接到这一页，所以页面会先停在受控提示里，避免误导进入下一步。',
    AppPageState.loading => '当前内容仍在准备中，请稍候。',
  };
}

String _actionFollowUpMessage(ExhibitionActionResult result) {
  if (result.isSuccess) {
    if (result.path == ExhibitionCanonicalPaths.projectCreate) {
      return '当前页会继续给出草稿回显和下一步入口，不需要回到上一页重新找项目详情或编辑入口。';
    }
    return '当前结果已经承接到页面里，你可以继续看下方结果区和下一步入口，不需要回到上一页重新找上下文。';
  }

  return '当前页会直接告诉你现在能做什么：重试、回到上一步，或停留在这一页继续讲解当前状态。';
}

String _userFacingUploadTitle(AppUploadState state) {
  return switch (state) {
    AppUploadState.localValidating => '正在校验上传信息',
    AppUploadState.signedReady => '上传信息已准备好',
    AppUploadState.uploading => '正在上传凭证',
    AppUploadState.uploadFailedRetryable => '上传暂未完成',
    AppUploadState.uploadConfirming => '正在确认上传结果',
    AppUploadState.uploadConfirmFailed => '上传确认暂未完成',
    AppUploadState.uploadBound => '上传已完成',
  };
}

String _userFacingUploadMessage({
  required AppUploadState state,
  required String? message,
  required String? path,
}) {
  final normalized = message?.toLowerCase() ?? '';
  if (normalized.contains('network error') ||
      normalized.contains('http error') ||
      normalized.contains('response decoding failed')) {
    return '当前上传暂时没有成功完成。你可以先重新执行上传；如果仍未恢复，请回到当前里程碑提交页重新开始。';
  }

  return switch (state) {
    AppUploadState.localValidating => '正在检查这次补充凭证是否满足当前页面的最小上传条件。',
    AppUploadState.signedReady => '上传指令已经准备好，可以继续把当前凭证发到后端承接的上传链路。',
    AppUploadState.uploading => '当前凭证正在上传，请稍候。',
    AppUploadState.uploadFailedRetryable => '这次上传暂时没有完成，你可以继续执行上传重试。',
    AppUploadState.uploadConfirming => '文件已经传出，正在确认是否完成当前绑定。',
    AppUploadState.uploadConfirmFailed => '上传确认暂时没有完成，你可以继续执行上传或稍后重试。',
    AppUploadState.uploadBound => '当前凭证已经完成上传并承接到当前链路。',
  };
}

String _userFacingUploadNextStep(AppUploadState state) {
  return switch (state) {
    AppUploadState.localValidating => '现在可以做什么：等待本次校验完成。',
    AppUploadState.signedReady => '现在可以做什么：继续执行上传，把凭证补充到当前链路。',
    AppUploadState.uploading => '现在可以做什么：等待上传完成，不需要额外操作。',
    AppUploadState.uploadFailedRetryable =>
      '现在可以做什么：继续执行上传重试；如仍失败，再回到当前里程碑提交页重新开始。',
    AppUploadState.uploadConfirming => '现在可以做什么：等待确认完成；如长时间未恢复，可重新执行上传。',
    AppUploadState.uploadConfirmFailed =>
      '现在可以做什么：继续执行上传重试；如仍未恢复，请回到当前里程碑提交页重新开始。',
    AppUploadState.uploadBound => '现在可以做什么：回到当前里程碑链路，继续后续工作。',
  };
}

String _userFacingLoadFailureMessage(ExhibitionLoadResult result) {
  final rawMessage = result.message;

  if (result.path == ExhibitionCanonicalPaths.projectDetail &&
      result.errorCode == 'AUTH_RESOURCE_UNAVAILABLE') {
    return '当前项目已退出公域展示，公开详情先停在不可用承接；这不等于项目不存在，也不等于 owner 私域不可见。';
  }

  if (_isMissingInstanceMessage(rawMessage)) {
    return _missingInstanceMessageForPath(result.path);
  }

  if (_isTransportTechnicalMessage(rawMessage)) {
    return _transportFailureMessageForPath(result.path, isAction: false);
  }

  if (_isNormalizedChineseBusinessMessage(rawMessage)) {
    return rawMessage!;
  }

  final controlledMessage = _controlledBusinessFailureMessage(
    errorCode: result.errorCode,
    path: result.path,
  );
  if (controlledMessage != null) {
    return controlledMessage;
  }

  return rawMessage ??
      switch (result.state) {
        AppPageState.notFound => _missingInstanceMessageForPath(result.path),
        AppPageState.errorRetryable => _transportFailureMessageForPath(
          result.path,
          isAction: false,
        ),
        AppPageState.errorNonRetryable =>
          '当前页面暂时不能继续。你现在可以先${_recoveryHintForPath(result.path)}。',
        _ => '当前页面暂时不能继续。你现在可以先${_recoveryHintForPath(result.path)}。',
      };
}

String _userFacingActionFailureMessage(ExhibitionActionResult result) {
  final rawMessage = result.message;

  if (_isMissingInstanceMessage(rawMessage)) {
    return _missingInstanceMessageForPath(result.path);
  }

  if (_isTransportTechnicalMessage(rawMessage)) {
    return _transportFailureMessageForPath(result.path, isAction: true);
  }

  if (_isNormalizedChineseBusinessMessage(rawMessage)) {
    return rawMessage!;
  }

  final controlledMessage = _controlledBusinessFailureMessage(
    errorCode: result.errorCode,
    path: result.path,
  );
  if (controlledMessage != null) {
    return controlledMessage;
  }

  return rawMessage ??
      '当前动作暂时不能继续。你现在可以先重试；如果仍未恢复，请${_recoveryHintForPath(result.path)}。';
}

String? _controlledBusinessFailureMessage({
  required String? errorCode,
  String? path,
}) {
  if (errorCode == 'P0_PAY_STATE_CONFLICT' &&
      path != null &&
      path.contains('/authenticity-sincerity/orders')) {
    return '当前项目已经有一笔进行中的 200 元项目真实性诚意金订单，请刷新项目状态后继续支付或等待结果，不要重复创建。';
  }

  return switch (errorCode) {
    'AUTH_SESSION_INVALID' => '当前登录状态已失效，请重新登录后再继续当前动作。',
    'AUTH_PERMISSION_INSUFFICIENT' => '当前账号没有权限执行这一步。请确认是否使用项目或订单所属组织账号进入。',
    'AUTH_RESOURCE_UNAVAILABLE' => '当前资源暂时不可见。请确认入口是否来自当前项目、订单或组织上下文。',
    'IDEMPOTENCY_KEY_CONFLICT' => '当前动作已被相同幂等键处理或正在处理，请刷新状态后再判断是否需要继续。',
    'PROJECT_WITHDRAW_INVALID' => '当前项目尚未提交，暂不支持撤回到草稿。',
    'PROJECT_ARCHIVE_INVALID' => '当前项目尚未提交，暂不支持作废归档。',
    'PROJECT_CLOSE_INVALID' => '当前项目状态暂不支持下架关闭。',
    'PROJECT_EXIT_INVALID_STATE' => '当前项目状态暂不支持这个退出动作。',
    'PROJECT_WITHDRAW_PUBLISHED_INVALID' => '竞标中撤回参数无效，请检查后再试。',
    'PROJECT_SUBMITTED_DISCARD_INVALID' => '预发布作废归档参数无效，请检查后再试。',
    'PROJECT_CANCELLATION_REQUEST_INVALID' => '取消申请参数无效，请检查后再试。',
    'PROJECT_CANCELLATION_RESPONSE_INVALID' => '取消响应参数无效，请检查后再试。',
    'PROJECT_BREACH_RECORD_INVALID' => '违约记录参数无效，请检查后再试。',
    'PROJECT_AUTHENTICITY_SINCERITY_REQUIRED' =>
      '发布项目需先补齐必传报价依据资料，并完成项目真实性诚意金绿色通道表态；选择支持或暂不支持均可继续发布。',
    'PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_POLICY_UNAVAILABLE' =>
      '发布项目需先补齐必传报价依据资料，并完成项目真实性诚意金绿色通道表态；选择支持或暂不支持均可继续发布。',
    'PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_INVALID' =>
      '绿色通道表态参数无效，请重新选择支持或暂不支持后再发布。',
    'PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_REJECTED' =>
      '绿色通道表态暂未提交成功，请重新选择后再发布。',
    'PROJECT_AUTHENTICITY_SINCERITY_ORDER_CREATE_REJECTED' =>
      '当前暂不能创建项目真实性诚意金订单，请刷新项目状态后再试。',
    'PROJECT_AUTHENTICITY_SINCERITY_ORDER_NOT_FOUND' =>
      '当前项目真实性诚意金订单暂不可用，请重新拉起后再试。',
    'PROJECT_AUTHENTICITY_SINCERITY_PAY_INIT_REJECTED' =>
      '当前暂不能拉起项目真实性诚意金支付，请刷新后再试。',
    'PROJECT_AUTHENTICITY_SINCERITY_INVALID_STATE' =>
      '当前项目真实性诚意金状态暂不允许继续发布，请完成冻结后再试。',
    'PROJECT_AUTHENTICITY_SINCERITY_RESULT_UNAVAILABLE' =>
      '项目真实性诚意金结果暂不可用，请稍后刷新。',
    'P0_PAY_INVALID' => '当前平台收费规则请求参数未通过校验，请刷新页面后再继续。',
    'P0_PAY_RESOURCE_UNAVAILABLE' => '当前平台收费规则资源暂不可用，请刷新页面后再继续。',
    'P0_PAY_PERMISSION_DENIED' => '当前账号没有权限操作这笔平台收费规则资源，请确认是否使用所属组织账号进入。',
    'P0_PAY_STATE_CONFLICT' => '当前平台收费规则状态暂不允许继续，请刷新页面确认最新状态后再试。',
    'P0_PAY_IDEMPOTENCY_CONFLICT' => '当前平台收费规则请求已被处理或正在处理，请刷新状态后再判断是否需要继续。',
    'PRICING_RULE_VERSION_MISMATCH' => '当前收费规则版本已更新，请刷新页面后再继续。',
    'BID_DUPLICATE_SUBMISSION' => '当前项目已提交过竞标，本页不再重复提交。请回到项目详情查看最新竞标状态。',
    'BID_SERVICE_FEE_AUTHORIZATION_REQUIRED' =>
      '资料确认通过后需先完成 4000 元竞标服务费预授权额度，完成后才能开启项目级自由发送。',
    'BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED' =>
      '当前暂不能创建竞标服务费预授权额度，请刷新项目状态后再试。',
    'BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND' => '当前竞标服务费预授权记录暂不可用，请重新拉起后再试。',
    'BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED' =>
      '当前暂不能拉起竞标服务费预授权冻结，请稍后再试。',
    'BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE' =>
      '当前竞标服务费预授权状态暂不允许开启项目级自由发送，请完成预授权后再试。',
    'BID_AWARD_INVALID' => '当前定标参数未通过校验。请回到我的项目详情确认中标投标 ID 与定标原因后再试。',
    'BID_AWARD_INVALID_STATE' => '当前项目状态暂时不能继续定标。请先回到我的项目详情确认项目是否已进入后续链路。',
    'BID_AWARD_DUPLICATE' => '当前项目已经处理过定标，本页不再重复提交。你可以先查看项目详情或我的项目中的最新状态。',
    'BID_AWARD_CONCURRENT_CONFLICT' => '当前项目的定标正在被其他操作处理。请稍后重新读取项目状态，再决定是否继续。',
    'ORDER_CONVERSION_FAILED' => '当前定标已受理，但订单承接暂未完成。请稍后重新读取项目详情或我的项目。',
    'PROJECT_ORDER_COMPLETE_INVALID' => '当前完工动作参数未通过校验。请重新读取订单后再试。',
    'PROJECT_ORDER_COMPLETE_UNAVAILABLE' => '当前订单暂不可执行完工动作。请确认订单是否仍属于当前账号。',
    'PROJECT_ORDER_COMPLETE_INVALID_STATE' =>
      '当前订单状态暂不支持这个完工动作。请先刷新订单状态，确认是否已有待确认完工申请。',
    'ORDER_INVALID_STATE' => '当前订单状态暂不支持这一步。请刷新订单详情后再继续。',
    'CONTRACT_SEED_FAILED' => '当前定标已受理，但合同承接暂未完成。请稍后重新读取项目详情或我的项目。',
    'BID_RESULT_INVALID' => '当前项目暂时不能读取竞标结果。请先确认是否从有效项目继续进入。',
    'BID_RESULT_UNAVAILABLE' => '当前竞标结果暂未开放读取。请稍后再试，或先回到项目详情确认当前状态。',
    'PROJECT_COUNTERPARTY_RATING_INVALID' =>
      '当前互评参数未通过校验。请从已完成订单或项目沟通头像入口重新进入。',
    'PROJECT_COUNTERPARTY_RATING_FORBIDDEN' =>
      '当前账号不能评价该订单对方主体。请确认订单、项目和被评主体是否都属于当前账号可操作范围。',
    'PROJECT_COUNTERPARTY_RATING_UNAVAILABLE' => '当前订单暂未开放双方互评。只有订单完成后才可以评价对方。',
    'PROJECT_COUNTERPARTY_RATING_DUPLICATE' =>
      '当前双方互评已经提交过，本页不再重复提交。请刷新状态查看最新评价结果。',
    'RATING_INVALID_STATE' => '当前评价状态暂不支持提交。请刷新订单或评价入口后再继续。',
    _ => null,
  };
}

bool _isMissingInstanceMessage(String? message) {
  if (message == null) {
    return false;
  }

  return message.contains('required from route context') ||
      message.contains('required from route context or page context') ||
      message.contains('required from contract detail') ||
      message.contains('required from inspection detail') ||
      message.contains('before calling BFF');
}

bool _isTransportTechnicalMessage(String? message) {
  if (message == null) {
    return false;
  }

  final normalized = message.toLowerCase();
  return normalized.contains('network error') ||
      normalized.contains('http error') ||
      normalized.contains('response decoding failed');
}

bool _isNormalizedChineseBusinessMessage(String? message) {
  if (message == null) {
    return false;
  }

  if (_isMissingInstanceMessage(message) ||
      _isTransportTechnicalMessage(message)) {
    return false;
  }

  return RegExp(r'[\u4e00-\u9fff]').hasMatch(message);
}

String _missingInstanceMessageForPath(String path) {
  if (ExhibitionCanonicalPaths.isMyProjectDetail(path)) {
    return '当前入口还没有承接到所需项目，这一页暂时不能继续。你现在可以先回到我的项目，再从当前组织项目资产重新进入。';
  }

  return switch (path) {
    ExhibitionCanonicalPaths.projectDetail ||
    ExhibitionCanonicalPaths.bidSubmit =>
      '当前入口还没有承接到所需项目，这一页暂时不能继续。你现在可以先回到项目展示，再从已承接项目重新进入。',
    ExhibitionCanonicalPaths.projectCreate ||
    ExhibitionCanonicalPaths.projectEditDetail ||
    ExhibitionCanonicalPaths.projectSave ||
    ExhibitionCanonicalPaths.projectSubmit ||
    ExhibitionCanonicalPaths.projectPublish ||
    ExhibitionCanonicalPaths.projectWithdraw ||
    ExhibitionCanonicalPaths.projectArchive ||
    ExhibitionCanonicalPaths.projectClose ||
    ExhibitionCanonicalPaths.projectWithdrawPublished ||
    ExhibitionCanonicalPaths.projectDiscardSubmitted ||
    ExhibitionCanonicalPaths.projectCancellationRequest ||
    ExhibitionCanonicalPaths.projectCancellationRespond ||
    ExhibitionCanonicalPaths.projectPublisherBreachRecord ||
    ExhibitionCanonicalPaths.projectFactoryBreachRecord =>
      '当前入口还没有承接到所需项目，这一页暂时不能继续。你现在可以先回到项目池，再从已承接项目重新进入。',
    ExhibitionCanonicalPaths.contractConfirm =>
      '当前入口还没有承接到所需订单与合同，这一页暂时不能继续。你现在可以先回到订单或合同详情，再从已承接订单重新进入。',
    ExhibitionCanonicalPaths.contractAmend =>
      '当前入口还没有承接到所需订单与合同，这一页暂时不能继续。你现在可以先回到订单或合同详情，再从已承接订单重新进入。',
    ExhibitionCanonicalPaths.inspectionRecheck =>
      '当前入口还没有承接到所需里程碑或验收实例，这一页暂时不能继续。你现在可以先回到里程碑或验收详情，再从已承接里程碑重新进入。',
    ExhibitionCanonicalPaths.ratingEntry ||
    ExhibitionCanonicalPaths.ratingSubmit ||
    ExhibitionCanonicalPaths.projectCounterpartyRatingEntry ||
    ExhibitionCanonicalPaths.projectCounterpartyRatingSubmit =>
      '当前入口还没有承接到所需订单、项目或被评主体锚点，这一页暂时不能继续。你现在可以先回到项目沟通头像入口，再从已完成订单重新进入。',
    ExhibitionCanonicalPaths.bidAward =>
      '当前入口还没有承接到所需项目或定标参数，这一页暂时不能继续。你现在可以先回到我的项目详情，再从当前项目重新进入。',
    ExhibitionCanonicalPaths.bidResult =>
      '当前入口还没有承接到所需项目，这一页暂时不能继续。你现在可以先回到项目详情，再从当前项目重新进入。',
    ExhibitionCanonicalPaths.disputeWithdraw =>
      '当前入口还没有承接到所需订单或争议锚点，这一页暂时不能继续。你现在可以先回到争议开启入口，再从已承接订单重新进入。',
    ExhibitionCanonicalPaths.inspectionDetail ||
    ExhibitionCanonicalPaths.inspectionSubmit =>
      '当前入口还没有承接到所需里程碑或验收实例，这一页暂时不能继续。你现在可以先回到展览，再从里程碑链路重新进入。',
    _ => '当前入口还没有承接到所需实例，这一页暂时不能继续。你现在可以先回到展览，再从已承接主链重新进入。',
  };
}

String _transportFailureMessageForPath(String path, {required bool isAction}) {
  final opening = isAction ? '当前动作暂时没有提交成功。' : '当前内容暂时没有成功返回。';
  return '$opening 你现在可以先重试；如果仍未恢复，请${_recoveryHintForPath(path)}。';
}

bool _shouldExposeRawFailureMessage(String path, String message) {
  return message.contains('before contract entry');
}

String _recoveryHintForPath(String path) {
  if (path == ExhibitionCanonicalPaths.myProjectList) {
    return '回到我的楼，稍后再从我的项目重新进入';
  }
  if (ExhibitionCanonicalPaths.isMyProjectDetail(path)) {
    return '回到我的项目，再从当前组织项目资产重新进入';
  }

  return switch (path) {
    ExhibitionCanonicalPaths.projectDetail ||
    ExhibitionCanonicalPaths.bidResult ||
    ExhibitionCanonicalPaths.bidSubmit => '回到项目展示，再从已承接项目重新进入',
    ExhibitionCanonicalPaths.projectCreate => '回到项目池，再从已承接项目重新进入',
    ExhibitionCanonicalPaths.projectWithdraw ||
    ExhibitionCanonicalPaths.projectArchive ||
    ExhibitionCanonicalPaths.projectClose ||
    ExhibitionCanonicalPaths.projectWithdrawPublished ||
    ExhibitionCanonicalPaths.projectDiscardSubmitted ||
    ExhibitionCanonicalPaths.projectCancellationRequest ||
    ExhibitionCanonicalPaths.projectCancellationRespond ||
    ExhibitionCanonicalPaths.projectPublisherBreachRecord ||
    ExhibitionCanonicalPaths.projectFactoryBreachRecord =>
      '回到我的项目，再从当前组织项目资产重新进入',
    ExhibitionCanonicalPaths.bidAward => '回到我的项目详情，再从当前项目重新进入',
    ExhibitionCanonicalPaths.projectEditDetail ||
    ExhibitionCanonicalPaths.projectSave ||
    ExhibitionCanonicalPaths.projectSubmit ||
    ExhibitionCanonicalPaths.projectPublish => '回到我的项目，再从当前项目重新进入',
    ExhibitionCanonicalPaths.contractConfirm => '回到订单详情或合同详情，再从当前订单重新进入',
    ExhibitionCanonicalPaths.contractAmend => '回到订单详情或合同详情，再从当前订单重新进入',
    ExhibitionCanonicalPaths.inspectionRecheck => '回到里程碑或验收详情，再从当前里程碑重新进入',
    ExhibitionCanonicalPaths.disputeWithdraw => '回到争议开启入口，再从当前订单重新进入',
    _ => '回到展览，再从已承接主链重新进入',
  };
}

String _recoveryButtonLabelForPath(String path) {
  if (path == ExhibitionCanonicalPaths.myProjectList) {
    return '回到我的楼';
  }
  if (ExhibitionCanonicalPaths.isMyProjectDetail(path)) {
    return '回到我的项目';
  }

  return switch (path) {
    ExhibitionCanonicalPaths.projectDetail ||
    ExhibitionCanonicalPaths.bidResult ||
    ExhibitionCanonicalPaths.bidSubmit => '回到项目展示',
    ExhibitionCanonicalPaths.projectCreate => '回到项目池',
    ExhibitionCanonicalPaths.bidAward => '回到我的项目',
    ExhibitionCanonicalPaths.projectEditDetail ||
    ExhibitionCanonicalPaths.projectSave ||
    ExhibitionCanonicalPaths.projectSubmit ||
    ExhibitionCanonicalPaths.projectPublish => '回到我的项目',
    ExhibitionCanonicalPaths.disputeWithdraw => '回到争议开启',
    _ => '回到展览',
  };
}

String _recoveryRouteForPath(String path) {
  if (path == ExhibitionCanonicalPaths.myProjectList) {
    return AppBuilding.profile.routePath;
  }
  if (ExhibitionCanonicalPaths.isMyProjectDetail(path)) {
    return ExhibitionRoutes.myProjectList;
  }

  return switch (path) {
    ExhibitionCanonicalPaths.projectDetail ||
    ExhibitionCanonicalPaths.bidResult ||
    ExhibitionCanonicalPaths.bidSubmit ||
    ExhibitionCanonicalPaths.projectCreate => ExhibitionRoutes.projectList,
    ExhibitionCanonicalPaths.bidAward => ExhibitionRoutes.myProjectList,
    ExhibitionCanonicalPaths.projectEditDetail ||
    ExhibitionCanonicalPaths.projectSave ||
    ExhibitionCanonicalPaths.projectSubmit ||
    ExhibitionCanonicalPaths.projectPublish ||
    ExhibitionCanonicalPaths.projectWithdrawPublished ||
    ExhibitionCanonicalPaths.projectDiscardSubmitted ||
    ExhibitionCanonicalPaths.projectCancellationRequest ||
    ExhibitionCanonicalPaths.projectCancellationRespond ||
    ExhibitionCanonicalPaths.projectPublisherBreachRecord ||
    ExhibitionCanonicalPaths.projectFactoryBreachRecord =>
      ExhibitionRoutes.myProjectList,
    ExhibitionCanonicalPaths.disputeWithdraw => ExhibitionRoutes.disputeOpen,
    _ => AppBuilding.exhibition.routePath,
  };
}
