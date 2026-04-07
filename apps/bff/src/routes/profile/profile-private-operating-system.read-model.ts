export type PrivateOperatingSystemReferenceCode =
  | 'REGROUPING_REFERENCE_UNAVAILABLE'
  | 'ENTRY_ORDER_REFERENCE_UNAVAILABLE'
  | 'CORRIDOR_REFERENCE_UNAVAILABLE';

export class PrivateOperatingSystemReferenceError extends Error {
  constructor(
    readonly code: PrivateOperatingSystemReferenceCode,
    message: string,
  ) {
    super(message);
  }
}

export type ProfileIndexMyBuildingProjectionViewModel = {
  regroupingKey: string;
  entryOrderKey: string;
  corridorVisibilityStatus: string;
  groupingExplanationKey: string;
  updatedAt: string;
};

export type ShellMyBuildingProjectionViewModel = {
  profileCorridorKey: string;
  profileEntryOrderBucket: string;
  visibleFamilyKeys: string[];
  orderingReferenceVersion: string;
  updatedAt: string;
  regrouping: {
    regroupingKey: string;
    regroupingVisibilityStatus: string;
    regroupingExplanationKey: string;
    updatedAt: string;
  };
  entryOrder: {
    entryOrderKey: string;
    entryVisibilityStatus: string;
    entryPriorityBucket: string;
    orderingExplanationKey: string;
    updatedAt: string;
  };
  corridor: {
    corridorKey: string;
    corridorVisibilityStatus: string;
    corridorExplanationKey: string;
    corridorTargetFamily: string;
    updatedAt: string;
  };
  familyPresence: Array<{
    familyKey: string;
    familyPresenceStatus: string;
    familyOrderReference: number;
    familyVisibilityReasonKey: string;
    updatedAt: string;
  }>;
  navigationExplanation: {
    navigationExplanationKey: string;
    regroupingExplanationKey: string;
    orderingExplanationKey: string;
    corridorExplanationKey: string;
    dependencyExplanationKey: string;
  };
  dependencyReference: {
    dependencyRequired: boolean;
    dependencyFamilyKey: string;
    dependencyExplanationKey: string;
    dependencyHandoffKey: string;
  };
};

export function readProfileIndexMyBuildingProjection(
  value: unknown,
): ProfileIndexMyBuildingProjectionViewModel {
  const projection = requireRecord(
    value,
    'REGROUPING_REFERENCE_UNAVAILABLE',
    'Profile index response is missing myBuildingProjection.',
  );

  return {
    regroupingKey: readRequiredString(
      projection.regroupingKey,
      'REGROUPING_REFERENCE_UNAVAILABLE',
      'Profile index response is missing myBuildingProjection.regroupingKey.',
    ),
    entryOrderKey: readRequiredString(
      projection.entryOrderKey,
      'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
      'Profile index response is missing myBuildingProjection.entryOrderKey.',
    ),
    corridorVisibilityStatus: readRequiredString(
      projection.corridorVisibilityStatus,
      'CORRIDOR_REFERENCE_UNAVAILABLE',
      'Profile index response is missing myBuildingProjection.corridorVisibilityStatus.',
    ),
    groupingExplanationKey: readRequiredString(
      projection.groupingExplanationKey,
      'REGROUPING_REFERENCE_UNAVAILABLE',
      'Profile index response is missing myBuildingProjection.groupingExplanationKey.',
    ),
    updatedAt: readRequiredString(
      projection.updatedAt,
      'REGROUPING_REFERENCE_UNAVAILABLE',
      'Profile index response is missing myBuildingProjection.updatedAt.',
    ),
  };
}

export function readShellMyBuildingProjection(
  value: unknown,
): ShellMyBuildingProjectionViewModel {
  const projection = requireRecord(
    value,
    'REGROUPING_REFERENCE_UNAVAILABLE',
    'Shell context response is missing myBuildingProjection.',
  );

  const regrouping = requireRecord(
    projection.regrouping,
    'REGROUPING_REFERENCE_UNAVAILABLE',
    'Shell context response is missing myBuildingProjection.regrouping.',
  );
  const entryOrder = requireRecord(
    projection.entryOrder,
    'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
    'Shell context response is missing myBuildingProjection.entryOrder.',
  );
  const corridor = requireRecord(
    projection.corridor,
    'CORRIDOR_REFERENCE_UNAVAILABLE',
    'Shell context response is missing myBuildingProjection.corridor.',
  );
  const navigationExplanation = requireRecord(
    projection.navigationExplanation,
    'REGROUPING_REFERENCE_UNAVAILABLE',
    'Shell context response is missing myBuildingProjection.navigationExplanation.',
  );
  const dependencyReference = requireRecord(
    projection.dependencyReference,
    'REGROUPING_REFERENCE_UNAVAILABLE',
    'Shell context response is missing myBuildingProjection.dependencyReference.',
  );

  return {
    profileCorridorKey: readRequiredString(
      projection.profileCorridorKey,
      'CORRIDOR_REFERENCE_UNAVAILABLE',
      'Shell context response is missing myBuildingProjection.profileCorridorKey.',
    ),
    profileEntryOrderBucket: readRequiredString(
      projection.profileEntryOrderBucket,
      'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
      'Shell context response is missing myBuildingProjection.profileEntryOrderBucket.',
    ),
    visibleFamilyKeys: readStringArray(
      projection.visibleFamilyKeys,
      'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
      'Shell context response is missing myBuildingProjection.visibleFamilyKeys.',
    ),
    orderingReferenceVersion: readRequiredString(
      projection.orderingReferenceVersion,
      'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
      'Shell context response is missing myBuildingProjection.orderingReferenceVersion.',
    ),
    updatedAt: readRequiredString(
      projection.updatedAt,
      'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
      'Shell context response is missing myBuildingProjection.updatedAt.',
    ),
    regrouping: {
      regroupingKey: readRequiredString(
        regrouping.regroupingKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.regrouping.regroupingKey.',
      ),
      regroupingVisibilityStatus: readRequiredString(
        regrouping.regroupingVisibilityStatus,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.regrouping.regroupingVisibilityStatus.',
      ),
      regroupingExplanationKey: readRequiredString(
        regrouping.regroupingExplanationKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.regrouping.regroupingExplanationKey.',
      ),
      updatedAt: readRequiredString(
        regrouping.updatedAt,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.regrouping.updatedAt.',
      ),
    },
    entryOrder: {
      entryOrderKey: readRequiredString(
        entryOrder.entryOrderKey,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.entryOrder.entryOrderKey.',
      ),
      entryVisibilityStatus: readRequiredString(
        entryOrder.entryVisibilityStatus,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.entryOrder.entryVisibilityStatus.',
      ),
      entryPriorityBucket: readRequiredString(
        entryOrder.entryPriorityBucket,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.entryOrder.entryPriorityBucket.',
      ),
      orderingExplanationKey: readRequiredString(
        entryOrder.orderingExplanationKey,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.entryOrder.orderingExplanationKey.',
      ),
      updatedAt: readRequiredString(
        entryOrder.updatedAt,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.entryOrder.updatedAt.',
      ),
    },
    corridor: {
      corridorKey: readRequiredString(
        corridor.corridorKey,
        'CORRIDOR_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.corridor.corridorKey.',
      ),
      corridorVisibilityStatus: readRequiredString(
        corridor.corridorVisibilityStatus,
        'CORRIDOR_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.corridor.corridorVisibilityStatus.',
      ),
      corridorExplanationKey: readRequiredString(
        corridor.corridorExplanationKey,
        'CORRIDOR_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.corridor.corridorExplanationKey.',
      ),
      corridorTargetFamily: readRequiredString(
        corridor.corridorTargetFamily,
        'CORRIDOR_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.corridor.corridorTargetFamily.',
      ),
      updatedAt: readRequiredString(
        corridor.updatedAt,
        'CORRIDOR_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.corridor.updatedAt.',
      ),
    },
    familyPresence: readFamilyPresence(projection.familyPresence),
    navigationExplanation: {
      navigationExplanationKey: readRequiredString(
        navigationExplanation.navigationExplanationKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.navigationExplanation.navigationExplanationKey.',
      ),
      regroupingExplanationKey: readRequiredString(
        navigationExplanation.regroupingExplanationKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.navigationExplanation.regroupingExplanationKey.',
      ),
      orderingExplanationKey: readRequiredString(
        navigationExplanation.orderingExplanationKey,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.navigationExplanation.orderingExplanationKey.',
      ),
      corridorExplanationKey: readRequiredString(
        navigationExplanation.corridorExplanationKey,
        'CORRIDOR_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.navigationExplanation.corridorExplanationKey.',
      ),
      dependencyExplanationKey: readRequiredString(
        navigationExplanation.dependencyExplanationKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.navigationExplanation.dependencyExplanationKey.',
      ),
    },
    dependencyReference: {
      dependencyRequired: readRequiredBoolean(
        dependencyReference.dependencyRequired,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.dependencyReference.dependencyRequired.',
      ),
      dependencyFamilyKey: readRequiredString(
        dependencyReference.dependencyFamilyKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.dependencyReference.dependencyFamilyKey.',
      ),
      dependencyExplanationKey: readRequiredString(
        dependencyReference.dependencyExplanationKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.dependencyReference.dependencyExplanationKey.',
      ),
      dependencyHandoffKey: readRequiredString(
        dependencyReference.dependencyHandoffKey,
        'REGROUPING_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.dependencyReference.dependencyHandoffKey.',
      ),
    },
  };
}

function readFamilyPresence(value: unknown) {
  if (!Array.isArray(value)) {
    throw unavailable(
      'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
      'Shell context response is missing myBuildingProjection.familyPresence.',
    );
  }

  return value.map((item) => {
    const record = requireRecord(
      item,
      'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
      'Shell context response contains an invalid myBuildingProjection.familyPresence item.',
    );
    return {
      familyKey: readRequiredString(
        record.familyKey,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.familyPresence.familyKey.',
      ),
      familyPresenceStatus: readRequiredString(
        record.familyPresenceStatus,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.familyPresence.familyPresenceStatus.',
      ),
      familyOrderReference: readRequiredNumber(
        record.familyOrderReference,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.familyPresence.familyOrderReference.',
      ),
      familyVisibilityReasonKey: readRequiredString(
        record.familyVisibilityReasonKey,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.familyPresence.familyVisibilityReasonKey.',
      ),
      updatedAt: readRequiredString(
        record.updatedAt,
        'ENTRY_ORDER_REFERENCE_UNAVAILABLE',
        'Shell context response is missing myBuildingProjection.familyPresence.updatedAt.',
      ),
    };
  });
}

function requireRecord(
  value: unknown,
  code: PrivateOperatingSystemReferenceCode,
  message: string,
) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw unavailable(code, message);
}

function readRequiredString(
  value: unknown,
  code: PrivateOperatingSystemReferenceCode,
  message: string,
) {
  if (typeof value === 'string' && value.trim().length > 0) {
    return value.trim();
  }
  throw unavailable(code, message);
}

function readRequiredBoolean(
  value: unknown,
  code: PrivateOperatingSystemReferenceCode,
  message: string,
) {
  if (typeof value === 'boolean') {
    return value;
  }
  throw unavailable(code, message);
}

function readRequiredNumber(
  value: unknown,
  code: PrivateOperatingSystemReferenceCode,
  message: string,
) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  throw unavailable(code, message);
}

function readStringArray(
  value: unknown,
  code: PrivateOperatingSystemReferenceCode,
  message: string,
) {
  if (!Array.isArray(value)) {
    throw unavailable(code, message);
  }
  return [...new Set(value.filter((item): item is string => typeof item === 'string' && item.trim().length > 0))];
}

function unavailable(code: PrivateOperatingSystemReferenceCode, message: string) {
  return new PrivateOperatingSystemReferenceError(code, message);
}
