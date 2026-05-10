import 'package:mobile/core/rc/rc_release_flags.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/shell/navigation/app_building.dart';

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
      case 'counterpart_conversation.open':
        return _counterpartConversationRouteLocation(routeParams);
      case 'project_name_access_thread.open':
        return _projectNameAccessThreadRouteLocation(routeParams);
      case 'bid_participation_request.open':
        return _bidParticipationThreadRouteLocation(routeParams);
      case 'bid_service_fee_authorization.open':
        if (!RcReleaseFlags.bidServiceFeeAuthorizationEnabled) {
          return ProfileRoutes.rcFeatureUnavailableFor(
            'bid_service_fee_authorization',
          );
        }
        return _bidServiceFeeAuthorizationRouteLocation(routeParams);
      case 'bid_submit.open':
        return _bidSubmitRouteLocation(routeParams);
      case 'bid_thread.open':
        if (!RcReleaseFlags.bidThreadEnabled) {
          return ProfileRoutes.rcFeatureUnavailableFor('bid_thread');
        }
        return _bidThreadRouteLocation(routeParams);
      case 'order_detail.open':
        return _orderDetailRouteLocation(routeParams);
      case 'forum_interaction.open':
        return _forumInteractionRouteLocation(routeParams);
    }

    return 'routeTarget actionKey "$actionKey" is unsupported';
  }
}

const Set<String> messagesAllowedObjectTypes = <String>{
  'inspection',
  'dispute',
  'project_clarification',
  'counterpart_conversation',
  'project_name_access_thread',
  'bid_participation_request',
  'bid_service_fee_authorization',
  'bid_thread',
  'bid_submit',
  'order',
  'forum_interaction',
};

const Set<String> messagesAllowedActionKeys = <String>{
  'inspection.submit',
  'dispute.open',
  'project_clarification.open',
  'counterpart_conversation.open',
  'project_name_access_thread.open',
  'bid_participation_request.open',
  'bid_service_fee_authorization.open',
  'bid_submit.open',
  'bid_thread.open',
  'order_detail.open',
  'forum_interaction.open',
};

const Set<String> messagesProjectCommunicationActionKeys = <String>{
  'counterpart_conversation.open',
  'project_clarification.open',
  'project_name_access_thread.open',
  'bid_participation_request.open',
  'bid_service_fee_authorization.open',
  'bid_submit.open',
  'bid_thread.open',
  'order_detail.open',
};

const Map<String, String> messagesActionKeyToObjectType = <String, String>{
  'inspection.submit': 'inspection',
  'dispute.open': 'dispute',
  'project_clarification.open': 'project_clarification',
  'counterpart_conversation.open': 'counterpart_conversation',
  'project_name_access_thread.open': 'project_name_access_thread',
  'bid_participation_request.open': 'bid_participation_request',
  'bid_service_fee_authorization.open': 'bid_service_fee_authorization',
  'bid_submit.open': 'bid_submit',
  'bid_thread.open': 'bid_thread',
  'order_detail.open': 'order',
  'forum_interaction.open': 'forum_interaction',
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
      'counterpart_conversation.open': MessagesRegisteredEntryDefinition(
        objectType: 'counterpart_conversation',
        actionKey: 'counterpart_conversation.open',
        canonicalPath: '/api/app/message/counterpart-conversation/detail',
        localEntryKey: 'registered.counterpart_conversation.open',
        requiredParams: <String>['conversationId', 'projectId', 'threadId'],
      ),
      'project_name_access_thread.open': MessagesRegisteredEntryDefinition(
        objectType: 'project_name_access_thread',
        actionKey: 'project_name_access_thread.open',
        canonicalPath: '/api/app/project/name-access/thread/detail',
        localEntryKey: 'registered.project_name_access_thread.open',
        requiredParams: <String>['threadId', 'projectId', 'requestId'],
      ),
      'bid_participation_request.open': MessagesRegisteredEntryDefinition(
        objectType: 'bid_participation_request',
        actionKey: 'bid_participation_request.open',
        canonicalPath: '/api/app/project/bid-participation/thread/detail',
        localEntryKey: 'registered.bid_participation_request.open',
        requiredParams: <String>['threadId', 'projectId', 'requestId'],
      ),
      'bid_submit.open': MessagesRegisteredEntryDefinition(
        objectType: 'bid_submit',
        actionKey: 'bid_submit.open',
        canonicalPath: '/api/app/bid/submit',
        localEntryKey: 'registered.bid_submit.open',
        requiredParams: <String>['projectId'],
      ),
      'bid_service_fee_authorization.open': MessagesRegisteredEntryDefinition(
        objectType: 'bid_service_fee_authorization',
        actionKey: 'bid_service_fee_authorization.open',
        canonicalPath:
            '/api/app/project/{projectId}/bid-service-fee-authorizations',
        localEntryKey: 'registered.bid_service_fee_authorization.open',
        requiredParams: <String>['projectId', 'bidParticipationRequestId'],
      ),
      'bid_thread.open': MessagesRegisteredEntryDefinition(
        objectType: 'bid_thread',
        actionKey: 'bid_thread.open',
        canonicalPath: '/api/app/bid/thread/detail',
        localEntryKey: 'registered.bid_thread.open',
        requiredParams: <String>['projectId', 'bidId'],
      ),
      'order_detail.open': MessagesRegisteredEntryDefinition(
        objectType: 'order',
        actionKey: 'order_detail.open',
        canonicalPath: '/api/app/order/detail',
        localEntryKey: 'registered.order_detail.open',
        requiredParams: <String>['projectId', 'orderId'],
      ),
      'forum_interaction.open': MessagesRegisteredEntryDefinition(
        objectType: 'forum_interaction',
        actionKey: 'forum_interaction.open',
        canonicalPath: '/api/app/forum/interaction/inbox',
        localEntryKey: 'forum_interaction.open',
        requiredParams: <String>['tab'],
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

String? _counterpartConversationRouteLocation(Map<String, String> routeParams) {
  if (!routeParams.containsKey('conversationId') ||
      !routeParams.containsKey('projectId') ||
      !routeParams.containsKey('threadId')) {
    return 'routeTarget.routeParams must include "conversationId", "projectId", and "threadId"';
  }
  final conversationId = routeParams['conversationId'];
  final projectId = routeParams['projectId'];
  final threadId = routeParams['threadId'];
  if (conversationId == null ||
      conversationId.trim().isEmpty ||
      projectId == null ||
      projectId.trim().isEmpty ||
      threadId == null ||
      threadId.trim().isEmpty) {
    return 'routeTarget.routeParams conversationId, projectId, and threadId must be non-empty';
  }
  return ExhibitionRoutes.counterpartConversationWithIds(
    conversationId: conversationId,
    projectId: projectId,
    threadId: threadId,
  );
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

String? _orderDetailRouteLocation(Map<String, String> routeParams) {
  if (routeParams.length != 2 ||
      !routeParams.containsKey('projectId') ||
      !routeParams.containsKey('orderId')) {
    return 'routeTarget.routeParams must include only "projectId" and "orderId"';
  }
  final projectId = routeParams['projectId'];
  final orderId = routeParams['orderId'];
  if (projectId == null ||
      projectId.trim().isEmpty ||
      orderId == null ||
      orderId.trim().isEmpty) {
    return 'routeTarget.routeParams projectId and orderId must be non-empty';
  }
  return ExhibitionRoutes.orderDetailWithOrderId(orderId, projectId: projectId);
}

String? _projectNameAccessThreadRouteLocation(Map<String, String> routeParams) {
  if (routeParams.length != 3 ||
      !routeParams.containsKey('threadId') ||
      !routeParams.containsKey('projectId') ||
      !routeParams.containsKey('requestId')) {
    return 'routeTarget.routeParams must include only "threadId", "projectId", and "requestId"';
  }
  final threadId = routeParams['threadId'];
  final projectId = routeParams['projectId'];
  final requestId = routeParams['requestId'];
  if (threadId == null ||
      threadId.trim().isEmpty ||
      projectId == null ||
      projectId.trim().isEmpty ||
      requestId == null ||
      requestId.trim().isEmpty) {
    return 'routeTarget.routeParams threadId, projectId, and requestId must be non-empty';
  }
  return ExhibitionRoutes.projectNameAccessThreadWithIds(
    threadId: threadId,
    projectId: projectId,
    requestId: requestId,
  );
}

String? _bidParticipationThreadRouteLocation(Map<String, String> routeParams) {
  if (routeParams.length != 3 ||
      !routeParams.containsKey('threadId') ||
      !routeParams.containsKey('projectId') ||
      !routeParams.containsKey('requestId')) {
    return 'routeTarget.routeParams must include only "threadId", "projectId", and "requestId"';
  }
  final threadId = routeParams['threadId'];
  final projectId = routeParams['projectId'];
  final requestId = routeParams['requestId'];
  if (threadId == null ||
      threadId.trim().isEmpty ||
      projectId == null ||
      projectId.trim().isEmpty ||
      requestId == null ||
      requestId.trim().isEmpty) {
    return 'routeTarget.routeParams threadId, projectId, and requestId must be non-empty';
  }
  return ExhibitionRoutes.bidParticipationThreadWithIds(
    threadId: threadId,
    projectId: projectId,
    requestId: requestId,
  );
}

String? _bidSubmitRouteLocation(Map<String, String> routeParams) {
  if (routeParams.length != 1 || !routeParams.containsKey('projectId')) {
    return 'routeTarget.routeParams must include only "projectId"';
  }
  final projectId = routeParams['projectId'];
  if (projectId == null || projectId.trim().isEmpty) {
    return 'routeTarget.routeParams projectId must be non-empty';
  }
  return ExhibitionRoutes.bidSubmitWithProjectId(projectId);
}

String? _bidServiceFeeAuthorizationRouteLocation(
  Map<String, String> routeParams,
) {
  if (!routeParams.containsKey('projectId') ||
      !routeParams.containsKey('bidParticipationRequestId')) {
    return 'routeTarget.routeParams must include projectId and bidParticipationRequestId';
  }
  final projectId = routeParams['projectId'];
  final requestId = routeParams['bidParticipationRequestId'];
  if (projectId == null ||
      projectId.trim().isEmpty ||
      requestId == null ||
      requestId.trim().isEmpty) {
    return 'routeTarget.routeParams projectId and bidParticipationRequestId must be non-empty';
  }
  return ProfileRoutes.bidServiceFeeAuthorizationWithIds(
    projectId: projectId,
    bidParticipationRequestId: requestId,
    bidId: routeParams['bidId'],
  );
}

String? _forumInteractionRouteLocation(Map<String, String> routeParams) {
  if (!routeParams.containsKey('tab')) {
    return 'routeTarget.routeParams must include "tab"';
  }
  final tab = routeParams['tab'];
  if (tab == null || tab.trim().isEmpty) {
    return 'routeTarget.routeParams tab must be non-empty';
  }
  final normalizedTab = tab.trim();
  if (!const <String>{'replies', 'likes', 'follows'}.contains(normalizedTab)) {
    return 'routeTarget.routeParams tab is outside the frozen forum interaction tabs';
  }
  final targetId = routeParams['targetId']?.trim();
  return Uri(
    path: AppBuilding.messages.routePath,
    queryParameters: <String, String>{
      'tab': 'forum_interaction',
      'interactionTab': normalizedTab,
      if (targetId != null && targetId.isNotEmpty) 'targetId': targetId,
    },
  ).toString();
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
