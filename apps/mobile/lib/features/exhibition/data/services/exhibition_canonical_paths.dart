part of '../exhibition_consumer_layer.dart';

final class ExhibitionCanonicalPaths {
  const ExhibitionCanonicalPaths._();

  static const String exhibitionHome = '/api/app/exhibition/home';
  static const String exhibitionHomeRefresh =
      '/api/app/exhibition/home/refresh';
  static const String exhibitionHomeLocationSelect =
      '/api/app/exhibition/home/location/select';
  static const String projectList = '/api/app/project/list';
  static const String myProjectList = '/api/app/my/projects';
  static const String myBidList = '/api/app/my/bids';
  static const String myProjectDetailPattern =
      '/api/app/my/projects/{projectId}';
  static const String myProjectAttachmentsPattern =
      '/api/app/my/projects/{projectId}/attachments';
  static const String projectPublicResources =
      '/api/app/project/public-resources';
  static const String projectCreate = '/api/app/project/create';
  static const String projectEditDetail = '/api/app/project/edit/detail';
  static const String projectSave = '/api/app/project/save';
  static const String projectSubmit = '/api/app/project/submit';
  static const String projectPublish = '/api/app/project/publish';
  static const String projectWithdraw = '/api/app/project/withdraw';
  static const String projectArchive = '/api/app/project/archive';
  static const String projectClose = '/api/app/project/close';
  static const String projectWithdrawPublished =
      '/api/app/project/withdraw-published';
  static const String projectDiscardSubmitted =
      '/api/app/project/discard-submitted';
  static const String projectCancellationRequest =
      '/api/app/project/cancellation/request';
  static const String projectCancellationRespond =
      '/api/app/project/cancellation/respond';
  static const String projectPublisherBreachRecord =
      '/api/app/project/breach/record-publisher';
  static const String projectFactoryBreachRecord =
      '/api/app/project/breach/record-factory';
  static const String projectDetail = '/api/app/project/detail';
  static const String projectBidMaterials = '/api/app/project/bid-materials';
  static const String exhibitionReportSubmit =
      '/api/app/exhibition/report/submit';
  static const String bidSubmit = '/api/app/bid/submit';
  static const String bidSubmissionSupplement =
      '/api/app/bid/submission/supplement';
  static const String bidAward = '/api/app/bid/award';
  static const String bidSelectAndCreateOrder =
      '/api/app/bid/select-bid-and-create-order';
  static const String bidResult = '/api/app/bid/result';
  static const String orderDetail = '/api/app/order/detail';
  static const String orderCompleteRequest = '/api/app/order/complete/request';
  static const String orderCompleteConfirm = '/api/app/order/complete/confirm';
  static const String orderCompleteReject = '/api/app/order/complete/reject';
  static const String contractDetail = '/api/app/contract/detail';
  static const String contractConfirm = '/api/app/contract/confirm';
  static const String contractAmend = '/api/app/contract/amend';
  static const String milestoneList = '/api/app/milestone/list';
  static const String milestoneSubmit = '/api/app/milestone/submit';
  static const String inspectionDetail = '/api/app/inspection/detail';
  static const String inspectionSubmit = '/api/app/inspection/submit';
  static const String inspectionRecheck = '/api/app/inspection/recheck';
  static const String ratingEntry = '/api/app/rating/entry';
  static const String ratingSubmit = '/api/app/rating/submit';
  static const String projectCounterpartyRatingEntry =
      '/api/app/project-counterparty-rating/entry';
  static const String projectCounterpartyRatingSubmit =
      '/api/app/project-counterparty-rating/submit';
  static const String disputeOpen = '/api/app/dispute/open';
  static const String disputeWithdraw = '/api/app/dispute/withdraw';
  static const String fileAccess = '/api/app/file/access';
  static const String uploadInit = '/api/app/file/upload/init';
  static const String uploadConfirm = '/api/app/file/upload/confirm';
  static const String p0PayTradeTaskCreate = '/api/app/exhibition/trade-tasks';

  static String projectPricingSummary(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/pricing-summary';
  }

  static String projectDealConfirmations(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/deal-confirmations';
  }

  static String projectDealConfirmationDetail(
    String projectId,
    String dealConfirmationId,
  ) {
    return '${projectDealConfirmations(projectId)}/${Uri.encodeComponent(dealConfirmationId)}';
  }

  static String projectAuthenticitySincerityOrders(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/authenticity-sincerity/orders';
  }

  static String projectAuthenticitySincerityPayInit(
    String projectId,
    String orderId,
  ) {
    return '${projectAuthenticitySincerityOrders(projectId)}/${Uri.encodeComponent(orderId)}/pay-init';
  }

  static String projectAuthenticitySincerityOrderStatus(
    String projectId,
    String orderId,
  ) {
    return '${projectAuthenticitySincerityOrders(projectId)}/${Uri.encodeComponent(orderId)}';
  }

  static String projectAuthenticitySincerityFreezeFeedback(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/authenticity-sincerity/freeze-feedback';
  }

  static String projectAuthenticitySincerityRefundInit(
    String projectId,
    String orderId,
  ) {
    return '${projectAuthenticitySincerityOrderStatus(projectId, orderId)}/refund-init';
  }

  static String projectAuthenticitySincerityRefundStatus(
    String projectId,
    String orderId,
  ) {
    return '${projectAuthenticitySincerityOrderStatus(projectId, orderId)}/refund';
  }

  static String projectSettlementSummary(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/settlement/summary';
  }

  static String projectSettlementBatchDraft(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/settlement/batch-draft';
  }

  static String projectSettlementReconciliation(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/settlement/reconciliation';
  }

  static String projectBidServiceFeeAuthorizations(String projectId) {
    return '/api/app/project/${Uri.encodeComponent(projectId)}/bid-service-fee-authorizations';
  }

  static String projectBidServiceFeeAuthorizationFreezeInit(
    String projectId,
    String authorizationId,
  ) {
    return '${projectBidServiceFeeAuthorizations(projectId)}/${Uri.encodeComponent(authorizationId)}/freeze-init';
  }

  static String projectBidServiceFeeAuthorizationStatus(
    String projectId,
    String authorizationId,
  ) {
    return '${projectBidServiceFeeAuthorizations(projectId)}/${Uri.encodeComponent(authorizationId)}';
  }

  static String myProjectDetail(String projectId) {
    return '$myProjectList/${Uri.encodeComponent(projectId)}';
  }

  static bool isMyProjectDelete(String canonicalPath) {
    return isMyProjectDetail(canonicalPath);
  }

  static String myProjectAttachments(String projectId) {
    return '${myProjectDetail(projectId)}/attachments';
  }

  static String myProjectAttachmentDelete(
    String projectId,
    String attachmentId,
  ) {
    return '${myProjectAttachments(projectId)}/${Uri.encodeComponent(attachmentId)}';
  }

  static bool isMyProjectDetail(String canonicalPath) {
    if (canonicalPath == myProjectDetailPattern) {
      return true;
    }

    final prefix = '$myProjectList/';
    if (!canonicalPath.startsWith(prefix)) {
      return false;
    }

    final segments = canonicalPath.substring(prefix.length).split('/');
    return segments.length == 1 && segments.first.trim().isNotEmpty;
  }

  static bool isMyProjectAttachments(String canonicalPath) {
    if (canonicalPath == myProjectAttachmentsPattern) {
      return true;
    }

    final prefix = '$myProjectList/';
    if (!canonicalPath.startsWith(prefix)) {
      return false;
    }

    final segments = canonicalPath.substring(prefix.length).split('/');
    return segments.length == 2 && segments[1] == 'attachments';
  }

  static bool isMyProjectAttachmentDelete(String canonicalPath) {
    final prefix = '$myProjectList/';
    if (!canonicalPath.startsWith(prefix)) {
      return false;
    }

    final segments = canonicalPath.substring(prefix.length).split('/');
    return segments.length == 3 &&
        segments[1] == 'attachments' &&
        segments[2].trim().isNotEmpty;
  }

  static String p0PayTradeTaskDetail(String taskId) {
    return '$p0PayTradeTaskCreate/${Uri.encodeComponent(taskId)}';
  }

  static String p0PayAuthenticityMaterials(String taskId) {
    return '${p0PayTradeTaskDetail(taskId)}/authenticity-materials';
  }

  static String p0PayFixedPriceBids(String taskId) {
    return '${p0PayTradeTaskDetail(taskId)}/fixed-price-bids';
  }

  static String p0PayServiceFeeAuthorizations(String taskId, String bidId) {
    return '${p0PayFixedPriceBids(taskId)}/${Uri.encodeComponent(bidId)}/service-fee-authorizations';
  }

  static String p0PayServiceFeeAuthorizeInit(
    String taskId,
    String bidId,
    String authorizationId,
  ) {
    return '${p0PayServiceFeeAuthorizations(taskId, bidId)}/${Uri.encodeComponent(authorizationId)}/authorize-init';
  }

  static String p0PayServiceFeeAuthorizationStatus(
    String taskId,
    String bidId,
    String authorizationId,
  ) {
    return '${p0PayServiceFeeAuthorizations(taskId, bidId)}/${Uri.encodeComponent(authorizationId)}';
  }

  static String p0PayInquiryDepositOrders(String taskId) {
    return '${p0PayTradeTaskDetail(taskId)}/inquiry-deposit/orders';
  }

  static String p0PayInquiryDepositPayInit(
    String taskId,
    String depositOrderId,
  ) {
    return '${p0PayInquiryDepositOrders(taskId)}/${Uri.encodeComponent(depositOrderId)}/pay-init';
  }

  static String p0PayInquiryDepositStatus(
    String taskId,
    String depositOrderId,
  ) {
    return '${p0PayInquiryDepositOrders(taskId)}/${Uri.encodeComponent(depositOrderId)}';
  }

  static String p0PaySummary(String taskId) {
    return '${p0PayTradeTaskDetail(taskId)}/p0-pay-summary';
  }
}
