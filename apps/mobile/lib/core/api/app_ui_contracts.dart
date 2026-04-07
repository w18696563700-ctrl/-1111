enum AppPageState {
  loading,
  empty,
  content,
  errorRetryable,
  errorNonRetryable,
  unauthorized,
  forbidden,
  notFound,
}

extension AppPageStateX on AppPageState {
  String get contractName => switch (this) {
    AppPageState.loading => 'loading',
    AppPageState.empty => 'empty',
    AppPageState.content => 'content',
    AppPageState.errorRetryable => 'error_retryable',
    AppPageState.errorNonRetryable => 'error_non_retryable',
    AppPageState.unauthorized => 'unauthorized',
    AppPageState.forbidden => 'forbidden',
    AppPageState.notFound => 'not_found',
  };
}

enum AppUploadState {
  localValidating,
  signedReady,
  uploading,
  uploadFailedRetryable,
  uploadConfirming,
  uploadConfirmFailed,
  uploadBound,
}

extension AppUploadStateX on AppUploadState {
  String get contractName => switch (this) {
    AppUploadState.localValidating => 'local_validating',
    AppUploadState.signedReady => 'signed_ready',
    AppUploadState.uploading => 'uploading',
    AppUploadState.uploadFailedRetryable => 'upload_failed_retryable',
    AppUploadState.uploadConfirming => 'upload_confirming',
    AppUploadState.uploadConfirmFailed => 'upload_confirm_failed',
    AppUploadState.uploadBound => 'upload_bound',
  };
}
