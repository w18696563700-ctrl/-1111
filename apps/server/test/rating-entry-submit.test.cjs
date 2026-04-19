const test = require('node:test');
const assert = require('node:assert/strict');
const { PATH_METADATA, METHOD_METADATA, HTTP_CODE_METADATA } = require('@nestjs/common/constants');
const { RequestMethod } = require('@nestjs/common');

function createContext(requestId) {
  return {
    authorization: 'Bearer token',
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createVerifiedServices(roleKeys = ['buyer_admin']) {
  return {
    verifier: {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    eligibility: {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return {
          organization: { id: 'buyer-org' },
          membership: { roleKey: roleKeys[0] ?? 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys,
        };
      },
    },
  };
}

function createRatingRepository({ orderState = null, ratingState = null, trackUpdate = null } = {}) {
  return {
    async query(sql, params) {
      if (sql.includes('from public.orders "order"')) {
        return orderState
          ? [
              {
                orderId: 'order-1',
                buyerOrganizationId: 'buyer-org',
                supplierOrganizationId: 'supplier-org',
                state: orderState,
              },
            ]
          : [];
      }
      if (sql.includes('from public.ratings rating') && sql.includes('order by')) {
        return ratingState
          ? [
              {
                ratingId: 'rating-1',
                orderId: 'order-1',
                state: ratingState,
              },
            ]
          : [];
      }
      if (sql.includes('update public.ratings')) {
        if (typeof trackUpdate === 'function') {
          trackUpdate(params);
        }
        return [];
      }
      throw new Error(`Unexpected SQL branch: ${sql}`);
    },
  };
}

test('E5 rating entry returns eligible carrier only for buyer-scoped completed draft truth', async () => {
  const { RatingPresenter } = require('../dist/modules/rating/rating.presenter.js');
  const { RatingQueryService } = require('../dist/modules/rating/rating.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new RatingQueryService(
    createRatingRepository({ orderState: 'completed', ratingState: 'draft' }),
    verifier,
    eligibility,
    new RatingPresenter(),
  );

  const result = await service.getEntry('order-1', createContext('rating-entry-ok'));

  assert.deepEqual(result, {
    ratingId: 'rating-1',
    orderId: 'order-1',
    state: 'eligible',
    summary: {
      heading: '当前评价入口已就绪，可继续提交最小评价真值。',
    },
  });
});

test('E5 rating entry fail-closes with stable unavailable code when order is not eligible', async () => {
  const { RatingPresenter } = require('../dist/modules/rating/rating.presenter.js');
  const { RatingQueryService } = require('../dist/modules/rating/rating.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new RatingQueryService(
    createRatingRepository({ orderState: 'active', ratingState: 'draft' }),
    verifier,
    eligibility,
    new RatingPresenter(),
  );

  await assert.rejects(
    () => service.getEntry('order-1', createContext('rating-entry-unavailable')),
    (error) => error?.response?.code === 'RATING_ENTRY_UNAVAILABLE',
  );
});

test('E5 rating submit advances eligible draft truth into submitted and records submit actor', async () => {
  const { RatingPresenter } = require('../dist/modules/rating/rating.presenter.js');
  const { RatingWriteService } = require('../dist/modules/rating/rating.write.service.js');

  const updates = [];
  const { verifier, eligibility } = createVerifiedServices();
  const service = new RatingWriteService(
    createRatingRepository({
      orderState: 'completed',
      ratingState: 'draft',
      trackUpdate(params) {
        updates.push(params);
      },
    }),
    verifier,
    eligibility,
    new RatingPresenter(),
  );

  const result = await service.submit({ orderId: 'order-1' }, createContext('rating-submit-ok'));

  assert.deepEqual(result, {
    ratingId: 'rating-1',
    orderId: 'order-1',
    state: 'submitted',
    summary: {
      heading: '当前评价提交已受理，后续仍以项目私域真值为准。',
    },
  });
  assert.equal(updates.length, 1);
  assert.deepEqual(updates[0], ['rating-1', 'submitted', 'user-1']);
});

test('E5 rating submit triggers shadow recompute for supplier organization without changing current response', async () => {
  const { RatingPresenter } = require('../dist/modules/rating/rating.presenter.js');
  const { RatingWriteService } = require('../dist/modules/rating/rating.write.service.js');

  const shadowCalls = [];
  const { verifier, eligibility } = createVerifiedServices();
  const service = new RatingWriteService(
    createRatingRepository({
      orderState: 'completed',
      ratingState: 'draft',
    }),
    verifier,
    eligibility,
    new RatingPresenter(),
    {
      async recomputeAfterFormalRatingSubmit(input) {
        shadowCalls.push(input);
      },
    },
  );

  const result = await service.submit({ orderId: 'order-1' }, createContext('rating-submit-shadow'));

  assert.deepEqual(result, {
    ratingId: 'rating-1',
    orderId: 'order-1',
    state: 'submitted',
    summary: {
      heading: '当前评价提交已受理，后续仍以项目私域真值为准。',
    },
  });
  assert.equal(shadowCalls.length, 1);
  assert.equal(shadowCalls[0].organizationId, 'supplier-org');
  assert.equal(shadowCalls[0].sourceOrderId, 'order-1');
  assert.equal(shadowCalls[0].sourceRatingId, 'rating-1');
  assert.ok(shadowCalls[0].triggeredAt instanceof Date);
});

test('E5 rating submit rejects malformed body with stable invalid code', async () => {
  const { RatingPresenter } = require('../dist/modules/rating/rating.presenter.js');
  const { RatingWriteService } = require('../dist/modules/rating/rating.write.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new RatingWriteService(
    createRatingRepository(),
    verifier,
    eligibility,
    new RatingPresenter(),
  );

  await assert.rejects(
    () => service.submit({}, createContext('rating-submit-invalid')),
    (error) => error?.response?.code === 'RATING_SUBMIT_INVALID',
  );
});

test('E5 rating submit rejects non-draft truth with stable invalid-state code', async () => {
  const { RatingPresenter } = require('../dist/modules/rating/rating.presenter.js');
  const { RatingWriteService } = require('../dist/modules/rating/rating.write.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new RatingWriteService(
    createRatingRepository({ orderState: 'completed', ratingState: 'submitted' }),
    verifier,
    eligibility,
    new RatingPresenter(),
  );

  await assert.rejects(
    () => service.submit({ orderId: 'order-1' }, createContext('rating-submit-invalid-state')),
    (error) => error?.response?.code === 'RATING_INVALID_STATE',
  );
});

test('E5 rating controller exposes both server and canonical app-facing prefixes', async () => {
  const { RatingController } = require('../dist/modules/rating/rating.controller.js');

  assert.deepEqual(Reflect.getMetadata(PATH_METADATA, RatingController), [
    'server/rating',
    'api/app/rating',
  ]);

  const getEntry = RatingController.prototype.getEntry;
  const submit = RatingController.prototype.submit;

  assert.equal(Reflect.getMetadata(PATH_METADATA, getEntry), 'entry');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, getEntry), RequestMethod.GET);
  assert.equal(Reflect.getMetadata(PATH_METADATA, submit), 'submit');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, submit), RequestMethod.POST);
  assert.equal(Reflect.getMetadata(HTTP_CODE_METADATA, submit), 202);
});
