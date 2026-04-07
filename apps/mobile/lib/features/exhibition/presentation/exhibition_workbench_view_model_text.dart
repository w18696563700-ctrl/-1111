part of 'exhibition_workbench_view_model.dart';

String _workbenchPageSubtitle(bool isDemo) {
  return isDemo
      ? '当前先用演示内容承接四容器结构，真实摘要恢复后会自动切回云端结果。'
      : '当前仅消费 workbench 四容器私域摘要，并受控导流到既有下游入口。';
}

bool _usesConnectedCopy(AppPageState state, bool isDemo) {
  return !isDemo &&
      (state == AppPageState.content ||
          state == AppPageState.empty ||
          state == AppPageState.unauthorized ||
          state == AppPageState.forbidden);
}

String _sourceLabel(AppPageState state, bool isDemo) {
  if (isDemo) {
    return '工作台数据：演示承接';
  }

  return switch (state) {
    AppPageState.content ||
    AppPageState.empty ||
    AppPageState.unauthorized ||
    AppPageState.forbidden => '工作台数据：已接通',
    AppPageState.notFound => '工作台数据：待承接',
    AppPageState.errorRetryable ||
    AppPageState.errorNonRetryable => '工作台数据：待重试',
    AppPageState.loading => '工作台数据：加载中',
  };
}

String? _bannerTitle(ExhibitionWorkbenchSourceResult result, bool isDemo) {
  if (isDemo) {
    return '工作台当前先按演示内容承接';
  }
  return switch (result.state) {
    AppPageState.unauthorized => '项目工作台当前暂不能查看',
    AppPageState.forbidden => '项目工作台当前暂未开放',
    AppPageState.notFound => '项目工作台暂未承接完成',
    AppPageState.errorRetryable ||
    AppPageState.errorNonRetryable => '项目工作台暂时没有刷新成功',
    _ => null,
  };
}

String? _bannerMessage(ExhibitionWorkbenchSourceResult result, bool isDemo) {
  if (isDemo) {
    return '当前工作台先用演示内容保持链路讲解连续；真实摘要恢复后会自动替换。';
  }
  return switch (result.state) {
    AppPageState.unauthorized => '当前账号还不能查看项目工作台，先恢复登录状态再继续私域动作。',
    AppPageState.forbidden => '当前身份暂未开放项目工作台，先回到已开放路径继续。',
    AppPageState.notFound => '项目工作台暂时还没有承接到当前环境需要的私域摘要，请稍后重试。',
    AppPageState.errorRetryable ||
    AppPageState.errorNonRetryable => '项目工作台暂时没有刷新成功。你可以手动刷新后重试。',
    _ => null,
  };
}

String _containerStateLabel(ExhibitionWorkbenchContainerState state) {
  return switch (state) {
    ExhibitionWorkbenchContainerState.loading => 'loading',
    ExhibitionWorkbenchContainerState.empty => 'empty',
    ExhibitionWorkbenchContainerState.content => 'content',
    ExhibitionWorkbenchContainerState.controlledFailure => 'controlled_failure',
  };
}

String _containerFailureSummary(AppPageState state) {
  return switch (state) {
    AppPageState.unauthorized => '当前登录态未通过，容器进入受控失败态。',
    AppPageState.forbidden => '当前权限不足，容器进入受控失败态。',
    AppPageState.notFound => '当前摘要未承接完成，容器进入受控失败态。',
    AppPageState.errorRetryable => '当前请求失败可重试，容器进入受控失败态。',
    AppPageState.errorNonRetryable => '当前请求失败需处理后重试，容器进入受控失败态。',
    _ => '当前容器进入受控失败态。',
  };
}

String _containerFailureGuidance(AppPageState state) {
  return switch (state) {
    AppPageState.unauthorized => '请先登录后重试。',
    AppPageState.forbidden => '请确认当前账号是否有工作台访问权限。',
    AppPageState.notFound => '请稍后刷新，等待云端摘要承接。',
    AppPageState.errorRetryable => '请检查网络后刷新重试。',
    AppPageState.errorNonRetryable => '请检查返回数据并与联调方确认后重试。',
    _ => '请稍后刷新重试。',
  };
}

String _ratingBoundaryDescription(String state) {
  return switch (state) {
    'extension_only' =>
      'ratingEntryState=extension_only，仅做边界提示，不放开 rating/submit。',
    _ => 'ratingEntryState=controlled_unavailable，当前不放开 rating/submit。',
  };
}

String _ratingBoundaryLabel(String state) {
  return switch (state) {
    'extension_only' => 'extension_only',
    _ => 'controlled_unavailable',
  };
}

String _disputeWithdrawDescription(String state) {
  return state == 'frozen'
      ? 'disputeWithdrawState=frozen，当前不放开 dispute/withdraw。'
      : '争议撤回当前仍是冻结边界。';
}

String _disputeWithdrawLabel(String state) {
  return state == 'frozen' ? 'frozen' : 'boundary';
}
