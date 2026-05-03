const assert = require('node:assert/strict');
const test = require('node:test');

function createContext(requestId = 'shell-unread-visible-projection') {
  return {
    requestId,
    traceId: `${requestId}-trace`,
    actorId: 'actor-shell-unread',
    userId: 'user-shell-unread',
  };
}

function createShellService({ visibleUnreadCount, rawUnreadCount }) {
  const { ShellQueryService } = require('../dist/modules/shell/shell-query.service.js');
  const { ShellPresenter } = require('../dist/modules/shell/shell.presenter.js');

  return new ShellQueryService(
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell-unread',
            actorId: context.actorId,
            userId: context.userId,
            organizationId: 'org-visible',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return {
          id: 'user-shell-unread',
          mobile: '18800000000',
          nickname: 'shell unread user',
          avatarUrl: null,
          profileIntro: null,
        };
      },
      async getCurrentOrganizationScope() {
        return {
          organization: {
            id: 'org-visible',
            organizationType: 'supplier',
          },
          membership: {
            memberStatus: 'active',
          },
          certification: {
            certificationStatus: 'approved',
          },
          roleKeys: ['supplier_admin'],
        };
      },
      canPublishProjectInScope() {
        return true;
      },
    },
    {
      async getShellSummaryProjection() {
        return {
          paidMembershipTier: null,
          paidMembershipEntitlementsSummary: [],
          paidMembershipQuotaSummary: [],
          paidMembershipNextRefreshAt: null,
        };
      },
    },
    {
      getShellContextProjection() {
        const updatedAt = new Date('2026-05-04T00:00:00.000Z');
        return {
          profileCorridorKey: 'profile_v1',
          profileEntryOrderBucket: 'default',
          visibleFamilyKeys: [],
          orderingReferenceVersion: 'test',
          updatedAt,
          regrouping: {
            regroupingKey: 'messages_regrouping',
            regroupingVisibilityStatus: 'visible',
            regroupingExplanationKey: 'test_regrouping',
            updatedAt,
          },
          entryOrder: {
            entryOrderKey: 'messages_entry_order',
            entryVisibilityStatus: 'visible',
            entryPriorityBucket: 'primary',
            orderingExplanationKey: 'test_entry_order',
            updatedAt,
          },
          corridor: {
            corridorKey: 'profile_v1',
            corridorVisibilityStatus: 'visible',
            corridorExplanationKey: 'test_corridor',
            corridorTargetFamily: 'messages',
            updatedAt,
          },
          familyPresence: [],
          navigationExplanation: {
            navigationExplanationKey: 'test_navigation',
            regroupingExplanationKey: 'test_regrouping',
            orderingExplanationKey: 'test_entry_order',
            corridorExplanationKey: 'test_corridor',
            dependencyExplanationKey: 'test_dependency',
          },
          dependencyReference: {
            dependencyRequired: false,
            dependencyFamilyKey: 'messages',
            dependencyExplanationKey: 'test_dependency',
            dependencyHandoffKey: 'test_handoff',
          },
        };
      },
    },
    {
      async buildAccessUrlFromObjectUrl() {
        return null;
      },
    },
    new ShellPresenter(),
    {
      async countUnreadForShell() {
        return rawUnreadCount;
      },
    },
    {
      async listConversations() {
        return [
          {
            interactionId: 'visible-1',
            interactionType: 'counterpart_conversation',
            conversationUnreadCount: visibleUnreadCount,
          },
        ];
      },
    },
  );
}

test('shell unread summary follows visible message interactions projection', async () => {
  const service = createShellService({
    visibleUnreadCount: 0,
    rawUnreadCount: 2,
  });

  const result = await service.getContext(createContext());

  assert.equal(result.unreadSummary.messages, 0);
});

test('shell unread summary falls back to raw project communication count when visible projection is absent', async () => {
  const { ShellQueryService } = require('../dist/modules/shell/shell-query.service.js');
  const { ShellPresenter } = require('../dist/modules/shell/shell.presenter.js');
  const service = createShellService({
    visibleUnreadCount: 0,
    rawUnreadCount: 2,
  });

  const fallbackService = new ShellQueryService(
    service.currentSessionVerificationService,
    service.eligibilityService,
    service.membershipQueryService,
    service.privateOperatingSystemService,
    service.avatarUrlService,
    new ShellPresenter(),
    {
      async countUnreadForShell() {
        return 2;
      },
    },
    undefined,
  );

  const result = await fallbackService.getContext(createContext('shell-unread-fallback'));

  assert.equal(result.unreadSummary.messages, 2);
});
