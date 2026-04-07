final class ExhibitionRoutes {
  const ExhibitionRoutes._();

  static const String showcaseSurface = 'showcase';
  static const String showcase = '/exhibition/showcase';
  static const String workbench = '/exhibition/workbench';
  static const String projectList = '/exhibition/projects';
  static const String myProjectList = '/exhibition/my/projects';
  static const String projectCreate = '/exhibition/projects/create';
  static const String projectDetail = '/exhibition/projects/detail';
  static const String myProjectDetail = '/exhibition/my/projects/detail';
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
  static const String forumMeFollows = '/exhibition/forum/me/follows';
  static const String companies = '/exhibition/companies';
  static const String factories = '/exhibition/factories';
  static const String suppliers = '/exhibition/suppliers';
  static const String companyDetail = '/exhibition/companies/detail';
  static const String factoryDetail = '/exhibition/factories/detail';
  static const String supplierDetail = '/exhibition/suppliers/detail';
  static const String enterpriseApply = '/exhibition/enterprise/apply';
  static const String enterpriseApplicationStatus =
      '/exhibition/enterprise/application-status';
  static const String bidSubmit = '/exhibition/bids/submit';
  static const String orderDetail = '/exhibition/orders/detail';
  static const String contractDetail = '/exhibition/contracts/detail';
  static const String contractConfirm = '/exhibition/contracts/confirm';
  static const String contractAmend = '/exhibition/contracts/amend';
  static const String milestoneList = '/exhibition/milestones';
  static const String milestoneSubmit = '/exhibition/milestones/submit';
  static const String inspectionDetail = '/exhibition/inspections/detail';
  static const String inspectionSubmit = '/exhibition/inspections/submit';
  static const String inspectionRecheck = '/exhibition/inspections/recheck';
  static const String ratingEntry = '/exhibition/ratings/entry';
  static const String ratingSubmit = '/exhibition/ratings/submit';
  static const String disputeOpen = '/exhibition/disputes/open';
  static const String disputeWithdraw = '/exhibition/disputes/withdraw';

  static String projectDetailWithProjectId(
    String projectId, {
    String? surface,
  }) {
    return _withQuery(projectDetail, <String, String>{
      'projectId': projectId,
      if (surface != null && surface.trim().isNotEmpty) 'surface': surface,
    });
  }

  static String myProjectDetailWithProjectId(String projectId) {
    return _withQuery(myProjectDetail, <String, String>{
      'projectId': projectId,
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

  static String enterpriseApplicationStatusWithId(
    String applicationId, {
    String? boardType,
  }) {
    return _withQuery(enterpriseApplicationStatus, <String, String>{
      'applicationId': applicationId,
      if (boardType != null && boardType.trim().isNotEmpty)
        'boardType': boardType,
    });
  }

  static String bidSubmitWithProjectId(String projectId) {
    return _withQuery(bidSubmit, <String, String>{'projectId': projectId});
  }

  static String orderDetailWithOrderId(String orderId) {
    return _withQuery(orderDetail, <String, String>{'orderId': orderId});
  }

  static String contractDetailWithOrderId(String orderId) {
    return _withQuery(contractDetail, <String, String>{'orderId': orderId});
  }

  static String contractConfirmWithOrderId(String orderId) {
    return _withQuery(contractConfirm, <String, String>{'orderId': orderId});
  }

  static String contractAmendWithOrderId(String orderId) {
    return _withQuery(contractAmend, <String, String>{'orderId': orderId});
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

  static String inspectionRecheckWithMilestoneId(String milestoneId) {
    return _withQuery(inspectionRecheck, <String, String>{
      'milestoneId': milestoneId,
    });
  }

  static String ratingEntryWithOrderId(String orderId) {
    return _withQuery(ratingEntry, <String, String>{'orderId': orderId});
  }

  static String ratingSubmitWithOrderId(String orderId) {
    return _withQuery(ratingSubmit, <String, String>{'orderId': orderId});
  }

  static String disputeOpenWithOrderId(String orderId) {
    return _withQuery(disputeOpen, <String, String>{'orderId': orderId});
  }

  static String disputeWithdrawWithDisputeId(
    String disputeId, {
    String? orderId,
  }) {
    return _withQuery(disputeWithdraw, <String, String>{
      'disputeId': disputeId,
      if (orderId != null && orderId.trim().isNotEmpty) 'orderId': orderId,
    });
  }

  static String _withQuery(String path, Map<String, String> queryParameters) {
    return Uri(path: path, queryParameters: queryParameters).toString();
  }
}
