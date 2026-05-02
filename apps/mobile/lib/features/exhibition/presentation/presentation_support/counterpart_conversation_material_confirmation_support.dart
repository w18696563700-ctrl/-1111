part of '../exhibition_trade_pages.dart';

const String _projectMaterialConfirmationEffectImage = 'effect_image';
const String _projectMaterialConfirmationConstructionDoc = 'construction_doc';
const String _projectMaterialConfirmationMaterialSample = 'material_sample';
const String _projectMaterialConfirmationEquipmentMaterialList =
    'equipment_material_list';
const String _projectMaterialConfirmationServiceList = 'service_list';

const String _publisherConfirmationQuote = 'quote';
const String _publisherConfirmationSchedule = 'schedule';
const String _publisherConfirmationMaterialProcess = 'material_process';

enum _PublisherConfirmationStatus { pending, confirmed, unavailable }

enum _ProjectMaterialConfirmationStatus {
  unsubmitted,
  pending,
  confirmed,
  unavailable,
}

final class _PublisherConfirmationDefinition {
  const _PublisherConfirmationDefinition({
    required this.confirmationKey,
    required this.label,
  });

  final String confirmationKey;
  final String label;
}

const List<_PublisherConfirmationDefinition> _publisherConfirmationDefinitions =
    <_PublisherConfirmationDefinition>[
      _PublisherConfirmationDefinition(
        confirmationKey: _publisherConfirmationQuote,
        label: '报价确认',
      ),
      _PublisherConfirmationDefinition(
        confirmationKey: _publisherConfirmationSchedule,
        label: '排期确认',
      ),
      _PublisherConfirmationDefinition(
        confirmationKey: _publisherConfirmationMaterialProcess,
        label: '工艺材质确认',
      ),
    ];

final class _PublisherConfirmationItem {
  const _PublisherConfirmationItem({
    required this.confirmationKey,
    required this.label,
    required this.status,
  });

  final String confirmationKey;
  final String label;
  final _PublisherConfirmationStatus status;
}

final class _PublisherConfirmationSnapshot {
  const _PublisherConfirmationSnapshot({
    required this.items,
    this.unavailableMessage,
  });

  factory _PublisherConfirmationSnapshot.fromConfirmedKeys(
    Set<String> confirmedKeys,
  ) {
    return _PublisherConfirmationSnapshot(
      items: _publisherConfirmationDefinitions
          .map(
            (definition) => _PublisherConfirmationItem(
              confirmationKey: definition.confirmationKey,
              label: definition.label,
              status: confirmedKeys.contains(definition.confirmationKey)
                  ? _PublisherConfirmationStatus.confirmed
                  : _PublisherConfirmationStatus.pending,
            ),
          )
          .toList(growable: false),
    );
  }

  factory _PublisherConfirmationSnapshot.unavailable(String message) {
    return _PublisherConfirmationSnapshot(
      unavailableMessage: message,
      items: _publisherConfirmationDefinitions
          .map(
            (definition) => _PublisherConfirmationItem(
              confirmationKey: definition.confirmationKey,
              label: definition.label,
              status: _PublisherConfirmationStatus.unavailable,
            ),
          )
          .toList(growable: false),
    );
  }

  final List<_PublisherConfirmationItem> items;
  final String? unavailableMessage;
}

final class _ProjectMaterialConfirmationDefinition {
  const _ProjectMaterialConfirmationDefinition({
    required this.attachmentKind,
    required this.label,
  });

  final String attachmentKind;
  final String label;
}

const List<_ProjectMaterialConfirmationDefinition>
_projectMaterialConfirmationDefinitions =
    <_ProjectMaterialConfirmationDefinition>[
      _ProjectMaterialConfirmationDefinition(
        attachmentKind: _projectMaterialConfirmationEffectImage,
        label: '效果图',
      ),
      _ProjectMaterialConfirmationDefinition(
        attachmentKind: _projectMaterialConfirmationMaterialSample,
        label: '材质图',
      ),
      _ProjectMaterialConfirmationDefinition(
        attachmentKind: _projectMaterialConfirmationConstructionDoc,
        label: '尺寸图',
      ),
      _ProjectMaterialConfirmationDefinition(
        attachmentKind: _projectMaterialConfirmationEquipmentMaterialList,
        label: '设备物料清单',
      ),
      _ProjectMaterialConfirmationDefinition(
        attachmentKind: _projectMaterialConfirmationServiceList,
        label: '服务清单',
      ),
    ];

final class _ProjectMaterialConfirmationItem {
  const _ProjectMaterialConfirmationItem({
    required this.attachmentKind,
    required this.label,
    required this.status,
    required this.attachmentCount,
  });

  final String attachmentKind;
  final String label;
  final _ProjectMaterialConfirmationStatus status;
  final int attachmentCount;

  bool get canOpen =>
      status == _ProjectMaterialConfirmationStatus.pending ||
      status == _ProjectMaterialConfirmationStatus.confirmed;
}

final class _ProjectMaterialConfirmationSnapshot {
  const _ProjectMaterialConfirmationSnapshot({
    required this.loading,
    required this.items,
    this.unavailableMessage,
  });

  factory _ProjectMaterialConfirmationSnapshot.loading() {
    return _ProjectMaterialConfirmationSnapshot(
      loading: true,
      items: _projectMaterialConfirmationDefinitions
          .map(
            (definition) => _ProjectMaterialConfirmationItem(
              attachmentKind: definition.attachmentKind,
              label: definition.label,
              status: _ProjectMaterialConfirmationStatus.unavailable,
              attachmentCount: 0,
            ),
          )
          .toList(growable: false),
    );
  }

  factory _ProjectMaterialConfirmationSnapshot.unavailable(String message) {
    return _ProjectMaterialConfirmationSnapshot(
      loading: false,
      unavailableMessage: message,
      items: _projectMaterialConfirmationDefinitions
          .map(
            (definition) => _ProjectMaterialConfirmationItem(
              attachmentKind: definition.attachmentKind,
              label: definition.label,
              status: _ProjectMaterialConfirmationStatus.unavailable,
              attachmentCount: 0,
            ),
          )
          .toList(growable: false),
    );
  }

  factory _ProjectMaterialConfirmationSnapshot.fromAttachmentKinds(
    Iterable<String> attachmentKinds,
  ) {
    final counts = <String, int>{};
    for (final rawKind in attachmentKinds) {
      final kind = rawKind.trim();
      if (!_projectMaterialConfirmationKindSet.contains(kind)) {
        continue;
      }
      counts[kind] = (counts[kind] ?? 0) + 1;
    }
    return _ProjectMaterialConfirmationSnapshot(
      loading: false,
      items: _projectMaterialConfirmationDefinitions
          .map(
            (definition) => _ProjectMaterialConfirmationItem(
              attachmentKind: definition.attachmentKind,
              label: definition.label,
              status: (counts[definition.attachmentKind] ?? 0) > 0
                  ? _ProjectMaterialConfirmationStatus.pending
                  : _ProjectMaterialConfirmationStatus.unsubmitted,
              attachmentCount: counts[definition.attachmentKind] ?? 0,
            ),
          )
          .toList(growable: false),
    );
  }

  final bool loading;
  final List<_ProjectMaterialConfirmationItem> items;
  final String? unavailableMessage;

  bool get unavailable => unavailableMessage != null;
}

const Set<String> _projectMaterialConfirmationKindSet = <String>{
  _projectMaterialConfirmationEffectImage,
  _projectMaterialConfirmationConstructionDoc,
  _projectMaterialConfirmationMaterialSample,
  _projectMaterialConfirmationEquipmentMaterialList,
  _projectMaterialConfirmationServiceList,
};

_ProjectMaterialConfirmationSnapshot
_projectMaterialConfirmationSnapshotFromBidMaterials(
  ExhibitionLoadResult result,
) {
  if (result.state != AppPageState.content) {
    return _ProjectMaterialConfirmationSnapshot.unavailable('资料状态暂不可读');
  }
  try {
    final materials = ProjectBidMaterialListReadModel.fromPayload(
      result.payload,
    );
    return _ProjectMaterialConfirmationSnapshot.fromAttachmentKinds(
      materials.attachments.map((attachment) => attachment.attachmentKind),
    );
  } on FormatException {
    return _ProjectMaterialConfirmationSnapshot.unavailable('资料状态暂不可读');
  }
}
