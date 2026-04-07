part of '../exhibition_consumer_layer.dart';

final class ExhibitionCanonicalPaths {
  const ExhibitionCanonicalPaths._();

  static const String exhibitionHome = '/api/app/exhibition/home';
  static const String exhibitionHomeRefresh =
      '/api/app/exhibition/home/refresh';
  static const String exhibitionHomeLocationSelect =
      '/api/app/exhibition/home/location/select';
  static const String exhibitionWorkbench = '/api/app/exhibition/workbench';
  static const String projectList = '/api/app/project/list';
  static const String myProjectList = '/api/app/my/projects';
  static const String myProjectDetailPattern =
      '/api/app/my/projects/{projectId}';
  static const String projectCreate = '/api/app/project/create';
  static const String projectDetail = '/api/app/project/detail';
  static const String bidSubmit = '/api/app/bid/submit';
  static const String orderCreate = '/api/app/order/create';
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
  static const String uploadInit = '/api/app/file/upload/init';
  static const String uploadConfirm = '/api/app/file/upload/confirm';

  static String myProjectDetail(String projectId) {
    return '$myProjectList/${Uri.encodeComponent(projectId)}';
  }

  static bool isMyProjectDetail(String canonicalPath) {
    return canonicalPath == myProjectDetailPattern ||
        canonicalPath.startsWith('$myProjectList/');
  }
}
