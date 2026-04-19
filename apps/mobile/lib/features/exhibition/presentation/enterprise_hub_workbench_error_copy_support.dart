part of 'enterprise_hub_workbench_pages.dart';

String _localizedWorkbenchMessage(String message) {
  if (message.contains(
    'Current enterprise primary board type is not factory.',
  )) {
    return '当前企业主板块不是优秀工厂，请先确认板块类型后再继续。';
  }
  if (message.contains(
    'Current enterprise primary board type is not company.',
  )) {
    return '当前企业主板块不是优秀公司，请先确认板块类型后再继续。';
  }
  if (message.contains(
    'Current enterprise primary board type is not supplier.',
  )) {
    return '当前企业主板块不是优秀供应商，请先确认板块类型后再继续。';
  }
  if (message.contains(
    'Cannot GET /server/exhibition/enterprise-hub/workbench',
  )) {
    return '当前工作台读取链路还未就绪，请刷新后重试。';
  }
  if (message.contains('Case title is required.')) {
    return '请填写案例标题。';
  }
  if (message.contains('Case summary is required.')) {
    return '请填写案例摘要。';
  }
  if (message.contains('caseCoverFileAssetId') &&
      message.contains('caseMediaFileAssetIds')) {
    return '当前案例至少需要 1 张已确认上传的图片，请重新上传案例图片后再保存。';
  }
  if (message.contains('processTypes is required.')) {
    return '请填写工艺类型。';
  }
  if (message.contains('coreProducts is required.')) {
    return '请填写核心产品。';
  }
  if (message.contains('Current actor must carry organization context')) {
    return '当前缺少组织上下文，请重新进入我的楼后再试。';
  }
  if (message.contains(
    'Current actor must carry organization scope for enterprise display workbench.',
  )) {
    return '当前企业展示工作台缺少组织上下文，请重新进入我的楼后再试。';
  }
  if (message.contains(
    'Current organization already owns a different enterprise display board.',
  )) {
    return '当前组织已在其他展示板块建档，请切换到对应板块继续维护。';
  }
  if (message.contains('Unable to load asset') &&
      message.contains('china_province_city.json')) {
    return '当前城市字典暂不可用，请稍后重试；本页涉及城市选择与省市回填的能力会暂时降级。';
  }
  if (message.contains('ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE') ||
      message.contains('provider 暂不可用')) {
    return '当前企业位置解析服务暂不可用，请稍后重试。';
  }
  if (message.contains('ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING') ||
      message.contains('缺少高德运行态配置')) {
    return '当前企业位置解析缺少高德运行态配置，暂时无法解析文字地址。';
  }
  if (message.contains('ENTERPRISE_LOCATION_RESOLVE_INVALID') ||
      message.contains('解析请求不完整')) {
    return '当前企业位置解析请求不完整，请先补齐位置说明后再试。';
  }
  return message;
}

String enterpriseLocationResolveVisibleMessage({
  String? errorCode,
  String? fallbackMessage,
}) {
  switch (errorCode?.trim()) {
    case 'ENTERPRISE_LOCATION_RESOLVE_INVALID':
      return '当前位置说明还不完整，请先补齐后再解析文字地址。';
    case 'ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE':
      return '当前企业位置解析服务暂不可用，请稍后重试。';
    case 'ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING':
      return '当前企业位置解析缺少高德运行态配置，暂时无法解析文字地址。';
    case 'ENTERPRISE_LOCATION_RESOLVE_FAILED':
      return '当前文字地址解析失败，请稍后重试。';
  }
  final normalizedFallback = _normalizedText(fallbackMessage);
  if (normalizedFallback != null) {
    return _localizedWorkbenchMessage(normalizedFallback);
  }
  return '当前文字地址解析暂不可用，请稍后重试。';
}

String enterprisePublishedChangeVisibleMessage({
  AppPageState? state,
  String? errorCode,
  String? fallbackMessage,
}) {
  switch (errorCode?.trim()) {
    case 'AUTH_SESSION_INVALID':
      return '登录状态已失效，请重新登录后再继续已发布展示变更。';
    case 'ENTERPRISE_HUB_PERMISSION_DENIED':
      return '当前账号暂不允许进入这条已发布展示变更。';
    case 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND':
      return '当前展示不存在或已不可访问。';
    case 'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE':
      return '当前展示暂未进入已发布变更通道，请回到原工作台继续维护。';
    case 'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED':
      return '当前案例已进入正式展示变更流程，当前页不继续假装可直接编辑线上内容。';
  }

  final normalizedFallback = _normalizedText(fallbackMessage);
  if (normalizedFallback != null) {
    return _localizedWorkbenchMessage(normalizedFallback);
  }

  return switch (state) {
    AppPageState.unauthorized => '登录状态已失效，请重新登录后再继续已发布展示变更。',
    AppPageState.forbidden => '当前账号暂不允许进入这条已发布展示变更。',
    AppPageState.notFound => '当前展示不存在或已不可访问。',
    AppPageState.errorRetryable => '当前已发布展示变更服务暂时不可用，请稍后重试。',
    _ => '当前已发布展示变更暂不可用。',
  };
}

String enterpriseApplicationVisibleErrorMessage({
  AppPageState? state,
  String? errorCode,
  String? fallbackMessage,
}) {
  const confirmRequiredMessage = '当前提交确认未完成，请返回工作台确认提交入驻申请后再继续。';
  switch (errorCode?.trim()) {
    case 'AUTH_SESSION_INVALID':
      return '登录状态已失效，请重新登录后再继续企业展示申请。';
    case 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS':
      return confirmRequiredMessage;
    case 'ENTERPRISE_HUB_PERMISSION_DENIED':
      return '当前账号暂不允许执行企业展示申请操作。';
    case 'ENTERPRISE_HUB_APPLICATION_NOT_FOUND':
      return '当前申请单不存在或已不可访问。';
    case 'ENTERPRISE_HUB_PROFILE_NOT_COMPLETED':
      return '当前板块画像尚未完善，请先回到工作台补齐后再提交。';
    case 'ENTERPRISE_HUB_CONTACT_REQUIRED':
      return '当前还缺少联系人，请先回到工作台补齐后再提交。';
    case 'ENTERPRISE_HUB_CASE_REQUIRED':
      return '当前还缺少已保存案例，请先回到工作台保存案例后再提交。';
    case 'ENTERPRISE_HUB_CERTIFICATION_REQUIRED':
      return '当前企业认证尚未通过，请先完成认证后再提交。';
    case 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION':
      return '当前申请状态不允许继续此操作，请先刷新状态后再试。';
  }

  final normalizedFallback = _normalizedText(fallbackMessage);
  if (normalizedFallback != null) {
    final lowered = normalizedFallback.toLowerCase();
    if (lowered.contains('confirm') && lowered.contains('required')) {
      return confirmRequiredMessage;
    }
  }
  if (normalizedFallback != null) {
    return _localizedWorkbenchMessage(normalizedFallback);
  }

  return switch (state) {
    AppPageState.unauthorized => '登录状态已失效，请重新登录后再继续企业展示申请。',
    AppPageState.forbidden => '当前账号暂不允许访问这条企业展示申请。',
    AppPageState.notFound => '当前申请单不存在或已不可访问。',
    AppPageState.errorRetryable => '当前企业展示申请服务暂时不可用，请稍后重试。',
    _ => '当前企业展示申请暂不可用。',
  };
}

String enterpriseWorkbenchCaseContinuationVisibleMessage({
  AppPageState? state,
  String? errorCode,
  String? fallbackMessage,
}) {
  switch (errorCode?.trim()) {
    case 'AUTH_SESSION_INVALID':
      return '登录状态已失效，请重新登录后再继续编辑企业展示案例。';
    case 'ENTERPRISE_HUB_PERMISSION_DENIED':
      return '当前账号暂不允许继续编辑这条企业展示案例。';
    case 'ENTERPRISE_HUB_CASE_NOT_FOUND':
      return '当前案例不存在或已不可访问。';
    case 'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED':
      return '当前案例已进入正式展示变更流程，当前页不再继续直接编辑，请改走正式变更入口。';
  }

  final normalizedFallback = _normalizedText(fallbackMessage);
  if (normalizedFallback != null) {
    return _localizedWorkbenchMessage(normalizedFallback);
  }

  return switch (state) {
    AppPageState.unauthorized => '登录状态已失效，请重新登录后再继续编辑企业展示案例。',
    AppPageState.forbidden => '当前账号暂不允许继续编辑这条企业展示案例。',
    AppPageState.notFound => '当前案例不存在或已不可访问。',
    AppPageState.errorRetryable => '当前企业展示案例服务暂时不可用，请稍后重试。',
    _ => '当前企业展示案例暂不可用。',
  };
}

bool enterpriseWorkbenchShouldExitDirectCaseEditing(String? errorCode) {
  return errorCode?.trim() == 'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED';
}
