part of 'enterprise_hub_published_change_consumer_layer.dart';

final class EnterpriseHubPublishedChangeCanonicalPaths {
  const EnterpriseHubPublishedChangeCanonicalPaths._();

  static String workbench(EnterpriseBoardType boardType) =>
      '${EnterpriseHubBoardCanonicalFamily.forBoard(boardType).basePath}/enterprises/{enterpriseId}/changes/current';

  static String workbenchWithEnterpriseId(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) => EnterpriseHubBoardCanonicalFamily.forBoard(
    boardType,
  ).publishedChangeWorkbench(enterpriseId);

  static String basic(EnterpriseBoardType boardType, String enterpriseId) =>
      EnterpriseHubBoardCanonicalFamily.forBoard(
        boardType,
      ).publishedChangeBasic(enterpriseId);

  static String profile(EnterpriseBoardType boardType, String enterpriseId) =>
      EnterpriseHubBoardCanonicalFamily.forBoard(
        boardType,
      ).publishedChangeProfile(enterpriseId);

  static String createCase(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) => EnterpriseHubBoardCanonicalFamily.forBoard(
    boardType,
  ).publishedChangeCreateCase(enterpriseId);

  static String caseDetail(
    EnterpriseBoardType boardType,
    String enterpriseId,
    String caseId,
  ) => EnterpriseHubBoardCanonicalFamily.forBoard(
    boardType,
  ).publishedChangeCaseDetail(enterpriseId, caseId);

  static String submit(EnterpriseBoardType boardType, String enterpriseId) =>
      EnterpriseHubBoardCanonicalFamily.forBoard(
        boardType,
      ).publishedChangeSubmit(enterpriseId);

  static String status(EnterpriseBoardType boardType) =>
      '${EnterpriseHubBoardCanonicalFamily.forBoard(boardType).basePath}/enterprises/{enterpriseId}/changes/current/status';

  static String statusWithEnterpriseId(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) => EnterpriseHubBoardCanonicalFamily.forBoard(
    boardType,
  ).publishedChangeStatus(enterpriseId);
}
