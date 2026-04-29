part of '../exhibition_consumer_layer.dart';

extension _ExhibitionProjectExitActionService on _ExhibitionActionService {
  Future<ExhibitionActionResult> withdrawPublishedProject(
    ProjectLifecycleActionCommand command,
  ) => _submitProjectExitAction(
    ExhibitionCanonicalPaths.projectWithdrawPublished,
    command,
    action: 'withdraw_published',
    reasonCode: 'content_needs_revision',
    extra: const <String, Object?>{
      'publicDelistConfirmed': true,
      'bidHistoryRetainedConfirmed': true,
      'authorizationReleaseAwarenessConfirmed': true,
    },
  );

  Future<ExhibitionActionResult> discardSubmittedProject(
    ProjectLifecycleActionCommand command,
  ) => _submitProjectExitAction(
    ExhibitionCanonicalPaths.projectDiscardSubmitted,
    command,
    action: 'discard_submitted',
    reasonCode: 'no_longer_needed',
    extra: const <String, Object?>{'archiveInsteadOfHardDeleteConfirmed': true},
  );

  Future<ExhibitionActionResult> requestProjectCancellation(
    ProjectLifecycleActionCommand command,
  ) => _submitProjectExitAction(
    ExhibitionCanonicalPaths.projectCancellationRequest,
    command,
    action: 'request_cancellation',
    reasonCode: 'mutual_change',
    noAutomaticPenaltyConfirmed: true,
  );

  Future<ExhibitionActionResult> recordPublisherBreach(
    ProjectLifecycleActionCommand command,
  ) => _submitProjectExitAction(
    ExhibitionCanonicalPaths.projectPublisherBreachRecord,
    command,
    action: 'record_publisher_breach',
    reasonCode: 'publisher_cancelled',
    noAutomaticPenaltyConfirmed: true,
  );

  Future<ExhibitionActionResult> recordFactoryBreach(
    ProjectLifecycleActionCommand command,
  ) => _submitProjectExitAction(
    ExhibitionCanonicalPaths.projectFactoryBreachRecord,
    command,
    action: 'record_factory_breach',
    reasonCode: 'factory_refused_fulfillment',
    noAutomaticPenaltyConfirmed: true,
  );

  Future<ExhibitionActionResult> _submitProjectExitAction(
    String canonicalPath,
    ProjectLifecycleActionCommand command, {
    required String action,
    required String reasonCode,
    bool noAutomaticPenaltyConfirmed = false,
    Map<String, Object?> extra = const <String, Object?>{},
  }) {
    return _submitProtected(
      canonicalPath,
      body: <String, Object?>{
        ...command.toJson(),
        ...extra,
        'reasonCode': reasonCode,
        if (noAutomaticPenaltyConfirmed) 'noAutomaticPenaltyConfirmed': true,
        'idempotencyKey': _idempotencyKey(action),
      },
    );
  }
}
