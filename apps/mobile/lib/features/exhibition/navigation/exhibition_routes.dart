final class ExhibitionRoutes {
  const ExhibitionRoutes._();

  static const String showcaseSurface = 'showcase';
  static const String showcase = '/exhibition/showcase';
  static const String projectList = '/exhibition/projects';
  static const String myProjectList = '/exhibition/my/projects';
  static const String projectCreate = '/exhibition/projects/create';
  static const String projectEdit = '/exhibition/projects/edit';
  static const String projectDetail = '/exhibition/projects/detail';
  static const String myProjectDetail = '/exhibition/my/projects/detail';
  static const String projectClarification =
      '/exhibition/projects/clarification';
  static const String projectAlbum = '/exhibition/projects/album';
  static const String projectNameAccessThread =
      '/exhibition/projects/name-access-thread';
  static const String bidParticipationThread =
      '/exhibition/projects/bid-participation-thread';
  static const String counterpartConversation =
      '/exhibition/messages/counterpart-conversation';
  static const String bidThread = '/exhibition/bids/thread';
  static const String forum = '/exhibition/forum';
  static const String forumSquare = '/exhibition/forum/square';
  static const String forumLocal = '/exhibition/forum/local';
  static const String forumFollowing = '/exhibition/forum/following';
  static const String forumTopics = '/exhibition/forum/topics';
  static const String forumPosts = '/exhibition/forum/posts';
  static const String forumAuthors = '/exhibition/forum/authors';
  static const String forumComments = '/exhibition/forum/comments';
  static const String forumPublish = '/exhibition/forum/publish';
  static const String forumDrafts = '/exhibition/forum/drafts';
  static const String forumSearch = '/exhibition/forum/search';
  static const String forumMePosts = '/exhibition/forum/me/posts';
  static const String forumMeComments = '/exhibition/forum/me/comments';
  static const String forumMeBookmarks = '/exhibition/forum/me/bookmarks';
  static const String forumMeLikes = '/exhibition/forum/me/likes';
  static const String forumMeFollows = '/exhibition/forum/me/follows';
  static const String forumMeReports = '/exhibition/forum/me/reports';
  static const String companies = '/exhibition/companies';
  static const String factories = '/exhibition/factories';
  static const String suppliers = '/exhibition/suppliers';
  static const String companyDetail = '/exhibition/companies/detail';
  static const String factoryDetail = '/exhibition/factories/detail';
  static const String supplierDetail = '/exhibition/suppliers/detail';
  static const String enterpriseApply = '/exhibition/enterprise/apply';
  static const String enterpriseCaseEditor =
      '/exhibition/enterprise/cases/editor';
  static const String enterpriseApplicationStatus =
      '/exhibition/enterprise/application-status';
  static const String companyDisplayWorkbench =
      '/exhibition/company-display/workbench';
  static const String factoryDisplayWorkbench =
      '/exhibition/factory-display/workbench';
  static const String supplierDisplayWorkbench =
      '/exhibition/supplier-display/workbench';
  static const String companyDisplayCaseEditor =
      '/exhibition/company-display/cases/editor';
  static const String factoryDisplayCaseEditor =
      '/exhibition/factory-display/cases/editor';
  static const String supplierDisplayCaseEditor =
      '/exhibition/supplier-display/cases/editor';
  static const String companyDisplayStatus =
      '/exhibition/company-display/status';
  static const String factoryDisplayStatus =
      '/exhibition/factory-display/status';
  static const String supplierDisplayStatus =
      '/exhibition/supplier-display/status';
  static const String bidSubmit = '/exhibition/bids/submit';
  static const String orderDetail = '/exhibition/orders/detail';
  static const String contractDetail = '/exhibition/contracts/detail';
  static const String milestoneList = '/exhibition/milestones';
  static const String milestoneSubmit = '/exhibition/milestones/submit';
  static const String inspectionDetail = '/exhibition/inspections/detail';
  static const String inspectionSubmit = '/exhibition/inspections/submit';
  static const String ratingEntry = '/exhibition/ratings/entry';
  static const String disputeOpen = '/exhibition/disputes/open';
  static const String disputeWithdraw = '/exhibition/disputes/withdraw';

  static String myProjectListWithWorkspace(String workspace) {
    return _withQuery(myProjectList, <String, String>{'workspace': workspace});
  }

  static String myProjectListWithStage({
    required String workspace,
    required String stage,
    String? projectId,
  }) {
    return _withQuery(myProjectList, <String, String>{
      'workspace': workspace,
      'stage': stage,
      if (projectId != null && projectId.trim().isNotEmpty)
        'projectId': projectId.trim(),
    });
  }

  static String myProjectDraftboxWithProjectId(String projectId) {
    return myProjectListWithStage(
      workspace: 'published',
      stage: 'draft',
      projectId: projectId,
    );
  }

  static String projectDetailWithProjectId(
    String projectId, {
    String? surface,
  }) {
    // Public project detail no longer branches by query-carried surface.
    return _withQuery(projectDetail, <String, String>{'projectId': projectId});
  }

  static String projectEditWithProjectId(String projectId) {
    return _withQuery(projectEdit, <String, String>{'projectId': projectId});
  }

  static String myProjectDetailWithProjectId(String projectId) {
    return _withQuery(myProjectDetail, <String, String>{
      'projectId': projectId,
    });
  }

  static String projectClarificationWithProjectId(String projectId) {
    return _withQuery(projectClarification, <String, String>{
      'projectId': projectId,
    });
  }

  static String projectAlbumWithProjectId(String projectId) {
    return _withQuery(projectAlbum, <String, String>{'projectId': projectId});
  }

  static String projectNameAccessThreadWithIds({
    required String threadId,
    required String projectId,
    required String requestId,
  }) {
    return _withQuery(projectNameAccessThread, <String, String>{
      'threadId': threadId,
      'projectId': projectId,
      'requestId': requestId,
    });
  }

  static String bidParticipationThreadWithIds({
    required String threadId,
    required String projectId,
    required String requestId,
  }) {
    return _withQuery(bidParticipationThread, <String, String>{
      'threadId': threadId,
      'projectId': projectId,
      'requestId': requestId,
    });
  }

  static String counterpartConversationWithIds({
    required String conversationId,
    required String projectId,
  }) {
    return _withQuery(counterpartConversation, <String, String>{
      'conversationId': conversationId,
      'projectId': projectId,
    });
  }

  static String bidThreadWithIds({
    required String projectId,
    required String bidId,
  }) {
    return _withQuery(bidThread, <String, String>{
      'projectId': projectId,
      'bidId': bidId,
    });
  }

  static String forumTopicWithTopicId(String topicId) {
    return '$forumTopics/${Uri.encodeComponent(topicId)}';
  }

  static String forumSquareWithTopicId(String topicId) {
    return _withQuery(forumSquare, <String, String>{'topicId': topicId});
  }

  static String forumPostWithPostId(String postId) {
    return '$forumPosts/${Uri.encodeComponent(postId)}';
  }

  static String forumAuthorWithAuthorId(String authorId) {
    return '$forumAuthors/${Uri.encodeComponent(authorId)}';
  }

  static String forumMeReportDetailWithTicketId(String ticketId) {
    return '$forumMeReports/${Uri.encodeComponent(ticketId)}';
  }

  static String forumCommentsWithPostId(String postId) {
    return _withQuery(forumComments, <String, String>{'postId': postId});
  }

  static String forumSearchWithQuery(String query) {
    return _withQuery(forumSearch, <String, String>{'q': query});
  }

  static String forumPublishWithDraftId(String draftId) {
    return _withQuery(forumPublish, <String, String>{'draftId': draftId});
  }

  static String companyDetailWithEnterpriseId(String enterpriseId) {
    return _withQuery(companyDetail, <String, String>{
      'enterpriseId': enterpriseId,
    });
  }

  static String factoryDetailWithEnterpriseId(String enterpriseId) {
    return _withQuery(factoryDetail, <String, String>{
      'enterpriseId': enterpriseId,
    });
  }

  static String supplierDetailWithEnterpriseId(String enterpriseId) {
    return _withQuery(supplierDetail, <String, String>{
      'enterpriseId': enterpriseId,
    });
  }

  static String enterpriseApplyWithBoardType(String boardType) {
    return _withQuery(enterpriseApply, <String, String>{
      'boardType': boardType,
    });
  }

  static String enterpriseWorkbenchForBoard(String boardType) {
    return switch (boardType.trim().toLowerCase()) {
      'company' => companyDisplayWorkbench,
      'factory' => factoryDisplayWorkbench,
      'supplier' => supplierDisplayWorkbench,
      _ => enterpriseApplyWithBoardType(boardType),
    };
  }

  static String enterprisePublishedChangeWorkbenchWithEnterpriseId(
    String enterpriseId, {
    required String boardType,
  }) {
    return _withQuery(enterpriseWorkbenchForBoard(boardType), <String, String>{
      'enterpriseId': enterpriseId,
      'mode': 'published_change',
    });
  }

  static String enterpriseCaseEditorWithBoardType(
    String boardType, {
    String? enterpriseId,
    String? caseId,
    bool publishedChange = false,
  }) {
    return _withQuery(enterpriseCaseEditorForBoard(boardType), <String, String>{
      if (enterpriseId != null && enterpriseId.trim().isNotEmpty)
        'enterpriseId': enterpriseId,
      if (caseId != null && caseId.trim().isNotEmpty) 'caseId': caseId,
      if (publishedChange) 'mode': 'published_change',
    });
  }

  static String enterpriseCaseEditorForBoard(String boardType) {
    return switch (boardType.trim().toLowerCase()) {
      'company' => companyDisplayCaseEditor,
      'factory' => factoryDisplayCaseEditor,
      'supplier' => supplierDisplayCaseEditor,
      _ => enterpriseCaseEditor,
    };
  }

  static String enterpriseApplicationStatusWithId(
    String applicationId, {
    String? boardType,
  }) {
    final targetPath = boardType == null || boardType.trim().isEmpty
        ? enterpriseApplicationStatus
        : enterpriseStatusForBoard(boardType);
    return _withQuery(targetPath, <String, String>{
      'applicationId': applicationId,
      if (boardType != null && boardType.trim().isNotEmpty)
        'boardType': boardType,
    });
  }

  static String enterpriseStatusForBoard(String boardType) {
    return switch (boardType.trim().toLowerCase()) {
      'company' => companyDisplayStatus,
      'factory' => factoryDisplayStatus,
      'supplier' => supplierDisplayStatus,
      _ => enterpriseApplicationStatus,
    };
  }

  static String enterprisePublishedChangeStatusWithEnterpriseId(
    String enterpriseId, {
    required String boardType,
  }) {
    return _withQuery(enterpriseStatusForBoard(boardType), <String, String>{
      'enterpriseId': enterpriseId,
      'mode': 'published_change',
    });
  }

  static String? enterpriseBoardTypeFromPrivatePath(String path) {
    return switch (path) {
      companyDisplayWorkbench ||
      companyDisplayCaseEditor ||
      companyDisplayStatus => 'company',
      factoryDisplayWorkbench ||
      factoryDisplayCaseEditor ||
      factoryDisplayStatus => 'factory',
      supplierDisplayWorkbench ||
      supplierDisplayCaseEditor ||
      supplierDisplayStatus => 'supplier',
      _ => null,
    };
  }

  static bool isEnterpriseWorkbenchPath(String path) {
    return path == enterpriseApply ||
        path == companyDisplayWorkbench ||
        path == factoryDisplayWorkbench ||
        path == supplierDisplayWorkbench;
  }

  static bool isEnterpriseCaseEditorPath(String path) {
    return path == enterpriseCaseEditor ||
        path == companyDisplayCaseEditor ||
        path == factoryDisplayCaseEditor ||
        path == supplierDisplayCaseEditor;
  }

  static bool isEnterpriseStatusPath(String path) {
    return path == enterpriseApplicationStatus ||
        path == companyDisplayStatus ||
        path == factoryDisplayStatus ||
        path == supplierDisplayStatus;
  }

  static String bidSubmitWithProjectId(
    String projectId, {
    String? mode,
    String? bidParticipationRequestId,
  }) {
    return _withQuery(bidSubmit, <String, String>{
      'projectId': projectId,
      if (mode != null && mode.trim().isNotEmpty) 'mode': mode,
      if (bidParticipationRequestId != null &&
          bidParticipationRequestId.trim().isNotEmpty)
        'bidParticipationRequestId': bidParticipationRequestId,
    });
  }

  static String bidResultWithProjectId(String projectId) {
    return bidSubmitWithProjectId(projectId, mode: 'result');
  }

  static String orderDetailWithOrderId(String orderId, {String? projectId}) {
    return _withQuery(orderDetail, <String, String>{
      'orderId': orderId,
      if (projectId != null && projectId.trim().isNotEmpty)
        'projectId': projectId.trim(),
    });
  }

  static String contractDetailWithOrderId(String orderId) {
    return _withQuery(contractDetail, <String, String>{'orderId': orderId});
  }

  static String milestoneListWithOrderId(String orderId) {
    return _withQuery(milestoneList, <String, String>{'orderId': orderId});
  }

  static String milestoneSubmitWithMilestoneId(String milestoneId) {
    return _withQuery(milestoneSubmit, <String, String>{
      'milestoneId': milestoneId,
    });
  }

  static String inspectionDetailWithMilestoneId(String milestoneId) {
    return _withQuery(inspectionDetail, <String, String>{
      'milestoneId': milestoneId,
    });
  }

  static String inspectionSubmitWithMilestoneId(String milestoneId) {
    return _withQuery(inspectionSubmit, <String, String>{
      'milestoneId': milestoneId,
    });
  }

  static String disputeOpenWithOrderId(String orderId) {
    return _withQuery(disputeOpen, <String, String>{'orderId': orderId});
  }

  static String ratingEntryWithOrderId(String orderId) {
    return _withQuery(ratingEntry, <String, String>{'orderId': orderId});
  }

  static String projectCounterpartyRatingEntry({
    required String orderId,
    required String projectId,
    required String rateeOrganizationId,
  }) {
    return _withQuery(ratingEntry, <String, String>{
      'orderId': orderId,
      'projectId': projectId,
      'rateeOrganizationId': rateeOrganizationId,
    });
  }

  static String disputeWithdrawWithOrderId(String orderId) {
    return _withQuery(disputeWithdraw, <String, String>{'orderId': orderId});
  }

  static String _withQuery(String path, Map<String, String> queryParameters) {
    return Uri(path: path, queryParameters: queryParameters).toString();
  }
}
