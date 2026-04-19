part of 'enterprise_hub_published_change_consumer_layer.dart';

class EnterpriseHubPublishedLiveSnapshot {
  const EnterpriseHubPublishedLiveSnapshot({
    required this.enterpriseStatus,
    required this.displayStatus,
    required this.publishedAt,
  });

  final String enterpriseStatus;
  final String displayStatus;
  final String publishedAt;
}

class EnterpriseHubCurrentChangeRequestSnapshot {
  const EnterpriseHubCurrentChangeRequestSnapshot({
    required this.changeRequestId,
    required this.changeStatus,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String changeRequestId;
  final String changeStatus;
  final String? submittedAt;
  final String? reviewedAt;
  final String? rejectionReason;
}

class EnterpriseHubPublishedChangeReadiness {
  const EnterpriseHubPublishedChangeReadiness({
    required this.draftEditable,
    required this.submitReady,
    required this.blockers,
  });

  final bool draftEditable;
  final bool submitReady;
  final List<String> blockers;
}

class EnterpriseHubPublishedChangeWorkbenchData {
  const EnterpriseHubPublishedChangeWorkbenchData({
    required this.enterpriseId,
    required this.boardType,
    required this.liveSnapshot,
    required this.currentChangeRequest,
    required this.basic,
    required this.boardProfile,
    required this.primaryContact,
    required this.cases,
    required this.changeReadiness,
  });

  final String enterpriseId;
  final EnterpriseBoardType boardType;
  final EnterpriseHubPublishedLiveSnapshot liveSnapshot;
  final EnterpriseHubCurrentChangeRequestSnapshot? currentChangeRequest;
  final EnterpriseHubWorkbenchBasic? basic;
  final Map<String, Object?>? boardProfile;
  final EnterpriseHubWorkbenchContact? primaryContact;
  final List<EnterpriseHubWorkbenchCaseItem> cases;
  final EnterpriseHubPublishedChangeReadiness changeReadiness;
}

class EnterpriseHubPublishedChangeStatusData {
  const EnterpriseHubPublishedChangeStatusData({
    required this.enterpriseId,
    required this.changeRequestId,
    required this.changeStatus,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String enterpriseId;
  final String changeRequestId;
  final String changeStatus;
  final String? submittedAt;
  final String? reviewedAt;
  final String? rejectionReason;
}
