part of '../exhibition_consumer_layer.dart';

_SuccessContractValidation _validateMyProjectListPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeMyProjectListPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final ongoingMessage = _requireListField(
    raw,
    'ongoingProjects',
    canonicalPath,
  );
  if (ongoingMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      ongoingMessage,
      payload: sanitized,
    );
  }
  final historicalMessage = _requireListField(
    raw,
    'historicalProjects',
    canonicalPath,
  );
  if (historicalMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      historicalMessage,
      payload: sanitized,
    );
  }

  final ongoingProjects = raw['ongoingProjects']! as List;
  for (var index = 0; index < ongoingProjects.length; index += 1) {
    final item = ongoingProjects[index];
    if (item is! Map) {
      return _invalidSuccessPayload(
        canonicalPath,
        'ongoingProjects[$index] must be an object',
        payload: sanitized,
      );
    }
    final message = _validateMyProjectListItem(
      item.map((Object? key, Object? value) => MapEntry('$key', value)),
      '$canonicalPath ongoingProjects[$index]',
    );
    if (message != null) {
      return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
    }
  }

  final historicalProjects = raw['historicalProjects']! as List;
  for (var index = 0; index < historicalProjects.length; index += 1) {
    final item = historicalProjects[index];
    if (item is! Map) {
      return _invalidSuccessPayload(
        canonicalPath,
        'historicalProjects[$index] must be an object',
        payload: sanitized,
      );
    }
    final message = _validateMyProjectListItem(
      item.map((Object? key, Object? value) => MapEntry('$key', value)),
      '$canonicalPath historicalProjects[$index]',
    );
    if (message != null) {
      return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
    }
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateMyProjectDetailPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeMyProjectDetailPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final publicMessage = _requireMapField(raw, 'publicProject', canonicalPath);
  if (publicMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      publicMessage,
      payload: sanitized,
    );
  }
  final privateMessage = _requireMapField(
    raw,
    'privateProgress',
    canonicalPath,
  );
  if (privateMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      privateMessage,
      payload: sanitized,
    );
  }

  final publicProject = _asMap(raw['publicProject']);
  if (publicProject == null) {
    return _invalidSuccessPayload(
      canonicalPath,
      'publicProject must be an object',
      payload: sanitized,
    );
  }
  final publicProjectMessage = _validateProjectEntity(
    publicProject,
    '$canonicalPath publicProject',
  );
  if (publicProjectMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      publicProjectMessage,
      payload: sanitized,
    );
  }

  final privateProgress = _asMap(raw['privateProgress']);
  if (privateProgress == null) {
    return _invalidSuccessPayload(
      canonicalPath,
      'privateProgress must be an object',
      payload: sanitized,
    );
  }
  final privateProgressMessage = _validateMyProjectPrivateProgress(
    privateProgress,
    '$canonicalPath privateProgress',
  );
  if (privateProgressMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      privateProgressMessage,
      payload: sanitized,
    );
  }

  return _SuccessContractValidation(payload: sanitized);
}

String? _validateMyProjectListItem(Map<String, Object?> raw, String context) {
  final publicMessage = _requireMapField(raw, 'publicProject', context);
  if (publicMessage != null) {
    return publicMessage;
  }
  final privateMessage = _requireMapField(raw, 'privateSummary', context);
  if (privateMessage != null) {
    return privateMessage;
  }

  final publicProject = _asMap(raw['publicProject']);
  if (publicProject == null) {
    return 'contract drift at $context: publicProject must be an object';
  }
  final validatedPublic = _validateProjectEntity(
    publicProject,
    '$context publicProject',
  );
  if (validatedPublic != null) {
    return validatedPublic;
  }

  final privateSummary = _asMap(raw['privateSummary']);
  if (privateSummary == null) {
    return 'contract drift at $context: privateSummary must be an object';
  }
  return _validateMyProjectPrivateProgress(
    privateSummary,
    '$context privateSummary',
  );
}

String? _validateMyProjectPrivateProgress(
  Map<String, Object?> raw,
  String context,
) {
  return _firstValidationError(<String?>[
    _requireBooleanField(raw, 'hasAcceptedOrder', context),
    _requireNullableStringField(raw, 'orderStatus', context),
    _requireNullableStringField(raw, 'contractStatus', context),
    _requireNullableStringField(raw, 'fulfillmentStatus', context),
    _requireNullableStringField(raw, 'acceptanceStatus', context),
    _requireNullableStringField(raw, 'afterSalesOrDisputeStatus', context),
    _requireStateField(
      raw,
      'formalCompletionStatus',
      _myProjectFormalCompletionStatuses,
      context,
    ),
    _requireStateField(
      raw,
      'evaluationStatus',
      _myProjectEvaluationStatuses,
      context,
    ),
  ]);
}
