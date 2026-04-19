const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const { ShellService } = require('../dist/apps/bff/src/routes/shell/shell.service.js');

function createService(overrides = {}) {
  return new ShellService(
    {
      async get() {
        throw new Error('get mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildReadOnlyForwardHeaders() {
        return { authorization: 'Bearer shell-smoke' };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('shell context forwards projectCreateEligibility from server shell projection', async () => {
  const service = createService({
    serverClient: {
      async get(path) {
        assert.equal(path, '/server/shell/context');
        return {
          userId: 'user-1',
          displayName: '张三',
          avatarUrl: null,
          organizationId: 'org-1',
          organizationType: 'both',
          roleKeys: ['buyer_admin'],
          certificationStatus: 'approved',
          personalCertificationStatus: 'approved',
          membershipStatus: 'active',
          projectCreateEligibility: {
            canCreateProject: true,
          },
          visibleBuildings: ['exhibition', 'messages', 'profile'],
          featureFlagsVersion: 'ffv-20260414',
          unreadSummary: {},
          myBuildingProjection: {
            profileCorridorKey: 'my_building_compact_current_user_hub',
            profileEntryOrderBucket: 'my_building_compact_hub_first_level',
            visibleFamilyKeys: ['exhibition', 'messages', 'profile'],
            orderingReferenceVersion: '1',
            updatedAt: '2026-04-01T00:00:00.000Z',
            regrouping: {
              regroupingKey: 'my_building_compact_current_user_hub',
              regroupingVisibilityStatus: 'visible',
              regroupingExplanationKey: 'my_building_bounded_private_regrouping',
              updatedAt: '2026-04-01T00:00:00.000Z',
            },
            entryOrder: {
              entryOrderKey: 'my_building_compact_hub_first_level',
              entryVisibilityStatus: 'visible',
              entryPriorityBucket: 'primary',
              orderingExplanationKey: 'my_building_bounded_private_regrouping',
              updatedAt: '2026-04-01T00:00:00.000Z',
            },
            corridor: {
              corridorKey: 'profile',
              corridorVisibilityStatus: 'visible',
              corridorExplanationKey: 'my_building_bounded_private_regrouping',
              corridorTargetFamily: 'profile',
              updatedAt: '2026-04-01T00:00:00.000Z',
            },
            familyPresence: [],
            navigationExplanation: {
              navigationExplanationKey: 'nav',
              regroupingExplanationKey: 'regroup',
              orderingExplanationKey: 'order',
              corridorExplanationKey: 'corridor',
              dependencyExplanationKey: 'dependency',
            },
            dependencyReference: {
              dependencyRequired: false,
              dependencyFamilyKey: 'profile',
              dependencyExplanationKey: 'dependency',
              dependencyHandoffKey: 'profile',
            },
          },
        };
      },
    },
  });

  const result = await service.getContext({});

  assert.equal(result.projectCreateEligibility.canCreateProject, true);
  assert.equal(result.organizationId, 'org-1');
  assert.equal(result.organizationType, 'both');
});
