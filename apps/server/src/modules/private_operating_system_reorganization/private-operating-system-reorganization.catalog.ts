const PRIVATE_OPERATING_SYSTEM_UPDATED_AT = new Date('2026-04-06T00:00:00.000Z');
const ORDERING_REFERENCE_VERSION = 'v23.private-operating-system.package1';

const REGROUPING_REFERENCE = {
  regroupingKey: 'my_building_compact_current_user_hub',
  regroupingVisibilityStatus: 'visible',
  regroupingExplanationKey: 'my_building_bounded_private_regrouping'
} as const;

const ENTRY_ORDER_REFERENCE = {
  entryOrderKey: 'my_building_compact_hub_first_level',
  entryVisibilityStatus: 'visible',
  entryPriorityBucket: 'profile_my_building_first_level',
  orderingExplanationKey: 'my_building_compact_hub_order_preserved'
} as const;

const CORRIDOR_REFERENCE = {
  corridorKey: 'my_building_compact_hub_corridor',
  corridorVisibilityStatus: 'visible',
  corridorExplanationKey: 'my_building_compact_hub_corridor_visible',
  corridorTargetFamily: 'profile_my_building'
} as const;

const DEPENDENCY_REFERENCE = {
  dependencyRequired: true,
  dependencyFamilyKey: 'future_cross_building_shell_rewrite',
  dependencyExplanationKey: 'future_cross_building_shell_rewrite_strategic_hold',
  dependencyHandoffKey: 'strategic_hold_current_private_operating_system_boundary'
} as const;

const NAVIGATION_EXPLANATION_REFERENCE = {
  navigationExplanationKey: 'my_building_navigation_reference',
  regroupingExplanationKey: REGROUPING_REFERENCE.regroupingExplanationKey,
  orderingExplanationKey: ENTRY_ORDER_REFERENCE.orderingExplanationKey,
  corridorExplanationKey: CORRIDOR_REFERENCE.corridorExplanationKey,
  dependencyExplanationKey: DEPENDENCY_REFERENCE.dependencyExplanationKey
} as const;

const FAMILY_PRESENCE_REFERENCE = [
  {
    familyKey: 'my_company',
    familyPresenceStatus: 'visible',
    familyOrderReference: 100,
    familyVisibilityReasonKey: 'current_organization_identity_available'
  },
  {
    familyKey: 'certification_membership_status',
    familyPresenceStatus: 'visible',
    familyOrderReference: 200,
    familyVisibilityReasonKey: 'current_status_reference_available'
  },
  {
    familyKey: 'my_projects',
    familyPresenceStatus: 'visible',
    familyOrderReference: 300,
    familyVisibilityReasonKey: 'bounded_private_project_entry_preserved'
  },
  {
    familyKey: 'my_forum',
    familyPresenceStatus: 'visible',
    familyOrderReference: 400,
    familyVisibilityReasonKey: 'bounded_forum_asset_entry_preserved'
  },
  {
    familyKey: 'settings',
    familyPresenceStatus: 'visible',
    familyOrderReference: 500,
    familyVisibilityReasonKey: 'bottom_most_first_level_entry_preserved'
  }
] as const;

function cloneUpdatedAt() {
  return new Date(PRIVATE_OPERATING_SYSTEM_UPDATED_AT);
}

export function buildProfileIndexProjection() {
  return {
    regroupingKey: REGROUPING_REFERENCE.regroupingKey,
    entryOrderKey: ENTRY_ORDER_REFERENCE.entryOrderKey,
    corridorVisibilityStatus: CORRIDOR_REFERENCE.corridorVisibilityStatus,
    groupingExplanationKey: REGROUPING_REFERENCE.regroupingExplanationKey,
    updatedAt: cloneUpdatedAt()
  };
}

export function buildShellContextProjection() {
  return {
    profileCorridorKey: CORRIDOR_REFERENCE.corridorKey,
    profileEntryOrderBucket: ENTRY_ORDER_REFERENCE.entryPriorityBucket,
    visibleFamilyKeys: FAMILY_PRESENCE_REFERENCE.map((item) => item.familyKey),
    orderingReferenceVersion: ORDERING_REFERENCE_VERSION,
    updatedAt: cloneUpdatedAt(),
    regrouping: {
      ...REGROUPING_REFERENCE,
      updatedAt: cloneUpdatedAt()
    },
    entryOrder: {
      ...ENTRY_ORDER_REFERENCE,
      updatedAt: cloneUpdatedAt()
    },
    corridor: {
      ...CORRIDOR_REFERENCE,
      updatedAt: cloneUpdatedAt()
    },
    familyPresence: FAMILY_PRESENCE_REFERENCE.map((item) => ({
      ...item,
      updatedAt: cloneUpdatedAt()
    })),
    navigationExplanation: {
      ...NAVIGATION_EXPLANATION_REFERENCE
    },
    dependencyReference: {
      ...DEPENDENCY_REFERENCE
    }
  };
}

