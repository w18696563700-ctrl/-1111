const { Client } = require('pg');
const crypto = require('crypto');

const publisherOrgId = process.env.P0_PAY_UAT_PUBLISHER_ORG_ID || 'e6bf4567-016e-45f9-9420-9c950237690e';
const factoryOrgId = process.env.P0_PAY_UAT_FACTORY_ORG_ID || 'bdfb4523-aeb7-4b56-89a1-992170fb5d98';
const bffBase = process.env.P0_PAY_E2E_BFF_BASE || 'http://127.0.0.1/api/app';
const serverBase = process.env.P0_PAY_E2E_SERVER_BASE || 'http://127.0.0.1:3001';
const runId = `uat-day20-${Date.now()}-${crypto.randomBytes(3).toString('hex')}`;

const evidence = {
  runId,
  plannedGateDate: '2026-05-20',
  actualExecutionAt: new Date().toISOString(),
  ingress: 'nginx_localhost_80_to_bff; direct_server_callback_3001',
  runtime: {
    callbackSecretInProcess: process.env.P0_PAY_CALLBACK_SECRET ? 'SET' : 'MISSING',
  },
  actors: {
    publisherOrgId,
    factoryOrgId,
  },
  steps: [],
  checks: {},
  blockers: [],
};

const client = new Client({
  host: process.env.POSTGRES_HOST,
  port: Number(process.env.POSTGRES_PORT || 5432),
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});

function money(value) {
  return Number(value).toFixed(2);
}

function fee(value) {
  return money(Number(value) * 0.03);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== 'object') return value;
  return Object.fromEntries(
    Object.entries(value)
      .filter(([key]) => key !== 'signature')
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([key, item]) => [key, sortValue(item)]),
  );
}

function callbackSignature(payload) {
  const stableJson = JSON.stringify(sortValue(payload));
  return `sha256=${crypto
    .createHmac('sha256', process.env.P0_PAY_CALLBACK_SECRET || '')
    .update(stableJson, 'utf8')
    .digest('hex')}`;
}

function tokenFor(sessionId, organizationId, expiresAt) {
  const payload = {
    sessionId,
    organizationId,
    expiresAt: expiresAt.toISOString(),
    nonce: crypto.randomBytes(18).toString('base64url'),
  };
  const payloadEncoded = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const key = crypto
    .createHash('sha256')
    .update([
      process.env.AUTH_ACCESS_TOKEN_SECRET || '',
      process.env.SESSION_SIGNING_SECRET || '',
      process.env.SESSION_OPAQUE_VERIFIER_SECRET || '',
    ].join(':'))
    .digest();
  const sig = crypto.createHmac('sha256', key).update(payloadEncoded).digest('base64url');
  return `p1a.${payloadEncoded}.${sig}`;
}

async function q(sql, params = []) {
  return client.query(sql, params);
}

async function loadActor(label, organizationId) {
  const result = await q(
    `
      select
        session.id as "sessionId",
        session.user_id as "userId",
        session.organization_id as "organizationId",
        session.expires_at as "expiresAt",
        member.role_key as "roleKey"
      from sessions session
      left join organization_members member
        on member.organization_id = session.organization_id
       and member.user_id = session.user_id
       and member.member_status = 'active'
      where session.organization_id = $1
        and session.status = 'valid'
        and session.expires_at > now()
      order by session.created_at desc, session.id desc
      limit 1
    `,
    [organizationId],
  );
  const row = result.rows[0];
  if (!row) {
    throw new Error(`${label} has no valid cloud session`);
  }
  return {
    label,
    sessionId: row.sessionId,
    userId: row.userId,
    orgId: row.organizationId,
    roleKey: row.roleKey,
    token: tokenFor(row.sessionId, row.organizationId, new Date(row.expiresAt)),
  };
}

function publicActor(actor) {
  return {
    userId: actor.userId,
    orgId: actor.orgId,
    roleKey: actor.roleKey,
    sessionId: actor.sessionId,
  };
}

function authHeaders(actor, suffix) {
  return {
    'content-type': 'application/json',
    authorization: `Bearer ${actor.token}`,
    'x-request-id': `${runId}-${suffix}`,
    'x-trace-id': `${runId}-${suffix}`,
    'user-agent': 'p0-pay-day20-real-account-uat',
  };
}

async function http(method, path, actor, body, suffix, expectOk = true) {
  const res = await fetch(`${bffBase}${path}`, {
    method,
    headers: authHeaders(actor, suffix),
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  let parsed;
  try {
    parsed = text ? JSON.parse(text) : null;
  } catch {
    parsed = text;
  }
  const out = { status: res.status, body: parsed };
  if (expectOk && (res.status < 200 || res.status >= 300)) {
    const err = new Error(`${method} ${path} -> ${res.status}`);
    err.response = out;
    throw err;
  }
  return out;
}

function taskPayload() {
  return {
    taskType: 'fixed_price_bid',
    projectName: `UAT-20260425 Day20 消息楼承接 ${runId}`,
    cityCode: '510100',
    projectType: 'exhibition_booth',
    exhibitionName: `UAT-Day20 P0Pay 展会 ${runId}`,
    area: 128,
    buildStartAt: '2026-06-20',
    dismantleAt: '2026-06-26',
    requirementDescription: `Day20 repair UAT: message building carry and P0-Pay read-only summary, no real payment. ${runId}`,
    budgetAmount: '100000.00',
    budgetRange: '80000-120000',
    quoteDeadlineAt: '2026-05-30T10:00:00.000Z',
    contactId: `contact-${runId}`,
    authenticityMaterialFileAssetIds: [],
    authenticityDeclarations: {
      demandExistsConfirmed: true,
      authorizationConfirmed: true,
      noQuoteHarvestingConfirmed: true,
      resultProcessingConfirmed: true,
      creditImpactAcknowledged: true,
    },
    idempotencyKey: `${runId}-create-task`,
  };
}

function fixedBidPayload(amount) {
  return {
    quoteAmount: money(amount),
    quoteValidUntil: '2026-06-30T00:00:00.000Z',
    taxIncluded: true,
    transportIncluded: true,
    installationIncluded: true,
    constructionPlan: `Day20 施工方案 ${runId}`,
    materialDescription: `Day20 材料说明 ${runId}`,
    craftDescription: `Day20 工艺说明 ${runId}`,
    buildProcess: `Day20 搭建流程 ${runId}`,
    deliveryMilestones: [
      { name: '进场', date: '2026-06-20' },
      { name: '验收', date: '2026-06-25' },
    ],
    riskNotes: `Day20 风险说明 ${runId}`,
    attachmentFileAssetIds: [],
    platformServiceFeeRuleAgreement: {
      ruleVersion: 'V1.3-P0-Pay',
      ruleSnapshotHash: `hash-${runId}`,
      agreedAtClient: new Date().toISOString(),
      readConfirmed: true,
      authorizationAwarenessConfirmed: true,
      publisherBreachReleaseAwarenessConfirmed: true,
    },
    idempotencyKey: `${runId}-fixed-bid`,
  };
}

async function paymentCallback(merchantOrderNo, amount, label) {
  const payload = {
    merchantOrderNo,
    channelOrderId: `CH-${label}-${crypto.randomBytes(4).toString('hex')}`,
    providerEventId: `EVT-${label}-${crypto.randomBytes(4).toString('hex')}`,
    channelEventId: `CHEVT-${label}-${crypto.randomBytes(4).toString('hex')}`,
    eventType: 'payment_succeeded',
    eventStatus: 'succeeded',
    amount: String(amount),
  };
  const res = await fetch(`${serverBase}/server/exhibition/p0-pay/payment-callbacks/other`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-p0-pay-signature': callbackSignature(payload),
      'x-request-id': `${runId}-${label}-callback`,
      'x-trace-id': `${runId}-${label}-callback`,
      'user-agent': 'p0-pay-day20-real-account-uat',
    },
    body: JSON.stringify(payload),
  });
  const text = await res.text();
  const parsed = text ? JSON.parse(text) : null;
  if (res.status < 200 || res.status >= 300) {
    const err = new Error(`callback ${label} -> ${res.status}`);
    err.response = { status: res.status, body: parsed };
    throw err;
  }
  return { status: res.status, body: parsed };
}

async function authorizeBid(taskId, bidId, amount, actor) {
  const create = await http(
    'POST',
    `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bidId}/service-fee-authorizations`,
    actor,
    {
      expectedQuotedAmount: money(amount),
      expectedFeeRate: '0.030000',
      expectedAuthorizationAmount: fee(amount),
      currency: 'CNY',
      idempotencyKey: `${runId}-auth-create`,
    },
    'auth-create',
  );
  const authorizationId = create.body.authorizationId;
  const init = await http(
    'POST',
    `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bidId}/service-fee-authorizations/${authorizationId}/authorize-init`,
    actor,
    {
      payChannel: 'other_candidate',
      clientPlatform: 'cloud-day20-uat',
      idempotencyKey: `${runId}-auth-init`,
    },
    'auth-init',
  );
  const merchantOrderNo = init.body.channelPayload?.merchantOrderNo || init.body.paymentReferenceId;
  const callback = await paymentCallback(merchantOrderNo, fee(amount), 'auth');
  const status = await http(
    'GET',
    `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bidId}/service-fee-authorizations/${authorizationId}`,
    actor,
    undefined,
    'auth-status',
  );
  return { create, init, callback, status, authorizationId };
}

function containsTask(body, taskId) {
  return JSON.stringify(body).includes(taskId);
}

function findTaskItem(body, taskId) {
  const items = Array.isArray(body?.items) ? body.items : [];
  return items.find((item) => item?.projectId === taskId || JSON.stringify(item).includes(taskId)) ?? null;
}

async function dbCounts(taskId) {
  const threads = await q('select count(*)::int as count from bid_private_threads where project_id=$1', [taskId]);
  const messages = await q('select count(*)::int as count from bid_thread_messages where project_id=$1', [taskId]);
  const communicationThreads = await q(
    'select count(*)::int as count from project_communication_threads where project_id=$1',
    [taskId],
  );
  return {
    bidPrivateThreads: threads.rows[0].count,
    bidThreadMessages: messages.rows[0].count,
    projectCommunicationThreads: communicationThreads.rows[0].count,
  };
}

async function main() {
  await client.connect();
  const publisher = await loadActor('publisher', publisherOrgId);
  const factory = await loadActor('factory', factoryOrgId);
  evidence.actors.publisher = publicActor(publisher);
  evidence.actors.factory = publicActor(factory);

  const task = await http('POST', '/exhibition/trade-tasks', publisher, taskPayload(), 'create-task');
  const taskId = task.body.taskId;
  evidence.taskId = taskId;
  evidence.steps.push({
    step: 'create_fixed_price_task',
    status: task.status,
    taskStatus: task.body.taskStatus,
    publishGateStatus: task.body.publishGateStatus,
  });

  const bidAmount = 88000;
  const bid = await http(
    'POST',
    `/exhibition/trade-tasks/${taskId}/fixed-price-bids`,
    factory,
    fixedBidPayload(bidAmount),
    'fixed-bid',
  );
  const bidId = bid.body.bidId;
  evidence.bidId = bidId;
  evidence.steps.push({
    step: 'submit_fixed_bid',
    status: bid.status,
    bidStatus: bid.body.bidStatus,
    threadId: bid.body.threadId || null,
    seedMessageId: bid.body.seedMessageId || null,
  });

  const authorization = await authorizeBid(taskId, bidId, bidAmount, factory);
  evidence.authorizationId = authorization.authorizationId;
  evidence.steps.push({
    step: 'authorize_platform_service_fee',
    createStatus: authorization.create.status,
    initStatus: authorization.init.status,
    callbackStatus: authorization.callback.body.applyStatus,
    authorizationStatus: authorization.status.body.authorizationStatus,
  });

  const award = await http(
    'POST',
    '/bid/award',
    publisher,
    {
      projectId: taskId,
      winningBidId: bidId,
      reasonCode: 'p0_pay_day20_uat_award',
      reasonText: 'Day20 UAT 定标并验证消息楼承接',
    },
    'award',
  );
  evidence.steps.push({
    step: 'award_bid',
    status: award.status,
    awardState: award.body.state,
    orderId: award.body.orderId,
    contractId: award.body.contractId,
  });

  const publisherConfirm = await http(
    'POST',
    `/exhibition/trade-tasks/${taskId}/contract-confirmations`,
    publisher,
    {
      selectedBidId: bidId,
      selectedQuotationId: null,
      finalConfirmedAmount: '90000.00',
      currency: 'CNY',
      contractFileAssetIds: [],
      confirmationRole: 'publisher',
      platformServiceFeeRecalculationAwarenessConfirmed: true,
      idempotencyKey: `${runId}-contract-publisher`,
    },
    'contract-publisher',
  );
  const factoryConfirm = await http(
    'POST',
    `/exhibition/trade-tasks/${taskId}/contract-confirmations`,
    factory,
    {
      selectedBidId: bidId,
      selectedQuotationId: null,
      finalConfirmedAmount: '90000.00',
      currency: 'CNY',
      contractFileAssetIds: [],
      confirmationRole: 'factory',
      platformServiceFeeRecalculationAwarenessConfirmed: true,
      idempotencyKey: `${runId}-contract-factory`,
    },
    'contract-factory',
  );
  evidence.steps.push({
    step: 'dual_contract_confirmation',
    publisherContract: publisherConfirm.body.contractStatus,
    factoryContract: factoryConfirm.body.contractStatus,
    feeStatus: factoryConfirm.body.platformServiceFeeStatus,
    finalFee: factoryConfirm.body.platformServiceFeeFinalAmount,
  });

  const summary = await http(
    'GET',
    `/exhibition/trade-tasks/${taskId}/p0-pay-summary`,
    publisher,
    undefined,
    'p0-summary',
  );
  const publisherMessages = await http(
    'GET',
    '/message/interactions?lane=project_communication',
    publisher,
    undefined,
    'publisher-messages',
  );
  const factoryMessages = await http(
    'GET',
    '/message/interactions?lane=project_communication',
    factory,
    undefined,
    'factory-messages',
  );
  const counts = await dbCounts(taskId);
  const publisherItem = findTaskItem(publisherMessages.body, taskId);
  const factoryItem = findTaskItem(factoryMessages.body, taskId);

  evidence.checks = {
    p0PaySummary: {
      platformServiceFeeStatus: summary.body.platformServiceFee?.status,
      finalFeeAmount: summary.body.platformServiceFee?.finalFeeAmount,
      contractConfirmationStatus: summary.body.contractConfirmation?.status,
      messageDisplayReadOnly: summary.body.messageDisplaySummary?.readOnly,
      messageDisplayStatusTextKey: summary.body.messageDisplaySummary?.statusTextKey,
    },
    messageCarrierDb: counts,
    publisherMessageIndex: {
      itemCount: publisherMessages.body.items?.length ?? null,
      containsTask: containsTask(publisherMessages.body, taskId),
      itemP0PayStatus: publisherItem?.p0PaySummary?.platformServiceFee?.status ?? null,
      itemReadOnly: publisherItem?.p0PaySummary?.messageDisplaySummary?.readOnly ?? null,
    },
    factoryMessageIndex: {
      itemCount: factoryMessages.body.items?.length ?? null,
      containsTask: containsTask(factoryMessages.body, taskId),
      itemP0PayStatus: factoryItem?.p0PaySummary?.platformServiceFee?.status ?? null,
      itemReadOnly: factoryItem?.p0PaySummary?.messageDisplaySummary?.readOnly ?? null,
    },
  };

  evidence.status =
    factoryConfirm.body.contractStatus === 'confirmed' &&
    factoryConfirm.body.platformServiceFeeStatus === 'charged' &&
    summary.body.platformServiceFee?.status === 'charged' &&
    summary.body.platformServiceFee?.finalFeeAmount === '2700.00' &&
    summary.body.contractConfirmation?.status === 'confirmed' &&
    summary.body.messageDisplaySummary?.readOnly === true &&
    counts.bidPrivateThreads >= 1 &&
    counts.bidThreadMessages >= 1 &&
    containsTask(publisherMessages.body, taskId) &&
    containsTask(factoryMessages.body, taskId) &&
    publisherItem?.p0PaySummary?.messageDisplaySummary?.readOnly === true &&
    factoryItem?.p0PaySummary?.messageDisplaySummary?.readOnly === true
      ? 'passed'
      : 'failed';
}

main()
  .catch((error) => {
    evidence.status = 'failed';
    evidence.error = { message: error.message, response: error.response };
    evidence.blockers.push(error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    evidence.finishedAt = new Date().toISOString();
    console.log(JSON.stringify(evidence, null, 2));
    try {
      await client.end();
    } catch {
      // ignore close errors for receipt generation.
    }
  });
