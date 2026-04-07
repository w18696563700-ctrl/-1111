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
      case 'contract.confirm':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'orderId',
          builder: ExhibitionRoutes.contractConfirmWithOrderId,
        );
      case 'contract.amend':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'orderId',
          builder: ExhibitionRoutes.contractAmendWithOrderId,
        );
      case 'inspection.submit':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'milestoneId',
          builder: ExhibitionRoutes.inspectionSubmitWithMilestoneId,
        );
      case 'rating.submit':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'orderId',
          builder: ExhibitionRoutes.ratingSubmitWithOrderId,
        );
      case 'dispute.open':
        return _singleParamRouteLocation(
          routeParams: routeParams,
          requiredParam: 'orderId',
          builder: ExhibitionRoutes.disputeOpenWithOrderId,
        );
      case 'dispute.withdraw':
        final disputeId = routeParams['disputeId'];
        final orderId = routeParams['orderId'];
        if (disputeId == null || disputeId.trim().isEmpty) {
          return 'routeTarget.routeParams for "$actionKey" must include non-empty "disputeId"';
        }
        if (!_sameKeySet(routeParams.keys.toSet(), requiredParams.toSet())) {
          return 'routeTarget.routeParams for "$actionKey" must match the frozen minimum parameter shape';
        }
        return ExhibitionRoutes.disputeWithdrawWithDisputeId(
          disputeId,
          orderId: orderId,
        );
    }

    return 'routeTarget actionKey "$actionKey" is unsupported';
  }
}

const Set<String> messagesAllowedObjectTypes = <String>{
  'contract',
  'inspection',
  'rating',
  'dispute',
};

const Set<String> messagesAllowedActionKeys = <String>{
  'contract.confirm',
  'contract.amend',
  'inspection.submit',
  'rating.submit',
  'dispute.open',
  'dispute.withdraw',
};

const Map<String, String> messagesActionKeyToObjectType = <String, String>{
  'contract.confirm': 'contract',
  'contract.amend': 'contract',
  'inspection.submit': 'inspection',
  'rating.submit': 'rating',
  'dispute.open': 'dispute',
  'dispute.withdraw': 'dispute',
};

const Map<String, MessagesRegisteredEntryDefinition>
messagesRegisteredEntryByActionKey = <String, MessagesRegisteredEntryDefinition>{
  'contract.confirm': MessagesRegisteredEntryDefinition(
    objectType: 'contract',
    actionKey: 'contract.confirm',
    canonicalPath: '/api/app/contract/detail',
    localEntryKey: 'registered.contract.confirm',
    requiredParams: <String>['orderId'],
  ),
  'contract.amend': MessagesRegisteredEntryDefinition(
    objectType: 'contract',
    actionKey: 'contract.amend',
    canonicalPath: '/api/app/contract/detail',
    localEntryKey: 'registered.contract.amend',
    requiredParams: <String>['orderId'],
  ),
  'inspection.submit': MessagesRegisteredEntryDefinition(
    objectType: 'inspection',
    actionKey: 'inspection.submit',
    canonicalPath: '/api/app/inspection/detail',
    localEntryKey: 'registered.inspection.submit',
    requiredParams: <String>['milestoneId'],
  ),
  'rating.submit': MessagesRegisteredEntryDefinition(
    objectType: 'rating',
    actionKey: 'rating.submit',
    canonicalPath: '/api/app/rating/entry',
    localEntryKey: 'registered.rating.submit',
    requiredParams: <String>['orderId'],
  ),
  'dispute.open': MessagesRegisteredEntryDefinition(
    objectType: 'dispute',
    actionKey: 'dispute.open',
    canonicalPath: '/api/app/order/detail',
    localEntryKey: 'registered.dispute.open',
    requiredParams: <String>['orderId'],
  ),
  'dispute.withdraw': MessagesRegisteredEntryDefinition(
    objectType: 'dispute',
    actionKey: 'dispute.withdraw',
    canonicalPath: '/api/app/order/detail',
    localEntryKey: 'registered.dispute.withdraw',
    requiredParams: <String>['disputeId', 'orderId'],
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

bool _sameKeySet(Set<String> left, Set<String> right) {
  if (left.length != right.length) {
    return false;
  }

  for (final value in left) {
    if (!right.contains(value)) {
      return false;
    }
  }

  return true;
}
