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
  static const String projectDetail = '/api/app/project/detail';
  static const String projectBidMaterials = '/api/app/project/bid-materials';
  static const String bidSubmit = '/api/app/bid/submit';
  static const String bidAward = '/api/app/bid/award';
  static const String bidResult = '/api/app/bid/result';
  static const String orderDetail = '/api/app/order/detail';
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
  static const String disputeOpen = '/api/app/dispute/open';
  static const String disputeWithdraw = '/api/app/dispute/withdraw';
  static const String fileAccess = '/api/app/file/access';
  static const String uploadInit = '/api/app/file/upload/init';
  static const String uploadConfirm = '/api/app/file/upload/confirm';

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
}
