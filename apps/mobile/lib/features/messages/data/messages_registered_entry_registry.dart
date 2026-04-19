import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

class MessagesRegisteredEntryDefinition {
  const MessagesRegisteredEntryDefinition({
    required this.objectType,
    required this.actionKey,
    required this.canonicalPath,
    required this.localEntryKey,
    required this.requiredParams,
    this.state = 'enabled',
  });

  final String objectType;
  final String actionKey;
  final String canonicalPath;
  final String localEntryKey;
  final List<String> requiredParams;
  final String state;

  String? validateSkeleton({
    required String canonicalPath,
    required String localEntryKey,
    required List<String> requiredParams,
    required String state,
  }) {
    if (canonicalPath != this.canonicalPath) {
      return 'routeTarget.canonicalPath "$canonicalPath" is not the frozen canonical entry for "$actionKey"';
    }
    if (localEntryKey != this.localEntryKey) {
      return 'routeTarget.localEntryKey "$localEntryKey" is not the frozen local entry key for "$actionKey"';
    }
    if (!_sameOrderedList(requiredParams, this.requiredParams)) {
      return 'routeTarget.requiredParams for "$actionKey" must match the frozen minimum parameter shape';
    }
    if (state != this.state) {
      return 'routeTarget.state "$state" is outside the frozen registration state';
    }
    return null;
  }

  String? buildRouteLocation(Map<String, String> routeParams) {
    switch (actionKey) {
      case 'inspection.submit':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'milestoneId',
          builder: ExhibitionRoutes.inspectionSubmitWithMilestoneId,
        );
      case 'dispute.open':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'orderId',
          builder: ExhibitionRoutes.disputeOpenWithOrderId,
        );
      case 'project_clarification.open':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'projectId',
          builder: ExhibitionRoutes.projectClarificationWithProjectId,
        );
      case 'bid_thread.open':
        return _bidThreadRouteLocation(routeParams);
    }

    return 'routeTarget actionKey "$actionKey" is unsupported';
  }
}

const Set<String> messagesAllowedObjectTypes = <String>{
  'inspection',
  'dispute',
  'project_clarification',
  'bid_thread',
};

const Set<String> messagesAllowedActionKeys = <String>{
  'inspection.submit',
  'dispute.open',
  'project_clarification.open',
  'bid_thread.open',
};

const Map<String, String> messagesActionKeyToObjectType = <String, String>{
  'inspection.submit': 'inspection',
  'dispute.open': 'dispute',
  'project_clarification.open': 'project_clarification',
  'bid_thread.open': 'bid_thread',
};

const Map<String, MessagesRegisteredEntryDefinition>
messagesRegisteredEntryByActionKey =
    <String, MessagesRegisteredEntryDefinition>{
      'inspection.submit': MessagesRegisteredEntryDefinition(
        objectType: 'inspection',
        actionKey: 'inspection.submit',
        canonicalPath: '/api/app/inspection/detail',
        localEntryKey: 'registered.inspection.submit',
        requiredParams: <String>['milestoneId'],
      ),
      'dispute.open': MessagesRegisteredEntryDefinition(
        objectType: 'dispute',
        actionKey: 'dispute.open',
        canonicalPath: '/api/app/order/detail',
        localEntryKey: 'registered.dispute.open',
        requiredParams: <String>['orderId'],
      ),
      'project_clarification.open': MessagesRegisteredEntryDefinition(
        objectType: 'project_clarification',
        actionKey: 'project_clarification.open',
        canonicalPath: '/api/app/project/clarification/list',
        localEntryKey: 'registered.project_clarification.open',
        requiredParams: <String>['projectId'],
      ),
      'bid_thread.open': MessagesRegisteredEntryDefinition(
        objectType: 'bid_thread',
        actionKey: 'bid_thread.open',
        canonicalPath: '/api/app/bid/thread/detail',
        localEntryKey: 'registered.bid_thread.open',
        requiredParams: <String>['projectId', 'bidId'],
      ),
    };

String? _singleParamRouteLocation({
  required Map<String, String> routeParams,
  required String requiredParam,
  required String Function(String value) builder,
}) {
  if (routeParams.length != 1 || !routeParams.containsKey(requiredParam)) {
    return 'routeTarget.routeParams must include only "$requiredParam"';
  }
  final value = routeParams[requiredParam];
  if (value == null || value.trim().isEmpty) {
    return 'routeTarget.routeParams parameter "$requiredParam" must be non-empty';
  }
  return builder(value);
}

String? _bidThreadRouteLocation(Map<String, String> routeParams) {
  if (routeParams.length != 2 ||
      !routeParams.containsKey('projectId') ||
      !routeParams.containsKey('bidId')) {
    return 'routeTarget.routeParams must include only "projectId" and "bidId"';
  }
  final projectId = routeParams['projectId'];
  final bidId = routeParams['bidId'];
  if (projectId == null ||
      projectId.trim().isEmpty ||
      bidId == null ||
      bidId.trim().isEmpty) {
    return 'routeTarget.routeParams projectId and bidId must be non-empty';
  }
  return ExhibitionRoutes.bidThreadWithIds(projectId: projectId, bidId: bidId);
}

bool _sameOrderedList(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
