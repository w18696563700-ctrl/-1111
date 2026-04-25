const { Client } = require('pg');
const crypto = require('crypto');

const runId = `p0pay-${Date.now()}-${crypto.randomBytes(3).toString('hex')}`;
const bffBase = process.env.P0_PAY_E2E_BFF_BASE || 'http://127.0.0.1/api/app';
const serverBase = process.env.P0_PAY_E2E_SERVER_BASE || 'http://127.0.0.1:3001';
const requestedDays = new Set(
  (process.env.P0_PAY_E2E_DAYS || 'day16,day17,day18')
    .split(',')
    .map((day) => day.trim())
    .filter(Boolean),
);

const evidence = {
  runId,
  ingress: 'nginx_localhost_80_to_bff; direct_server_callback_3001',
  startedAt: new Date().toISOString(),
  runtime: {
    callbackSecretInProcess: process.env.P0_PAY_CALLBACK_SECRET ? 'SET' : 'MISSING',
  },
  actors: {},
  day16: { name: 'cloud inquiry/deposit/seats/refund', steps: [] },
  day17: { name: 'cloud fixed bid/preauth/non-winning release', steps: [] },
  day18: { name: 'cloud contract charge/publisher breach/factory refusal', steps: [] },
  blockers: [],
};

const client = new Client({
  host: process.env.POSTGRES_HOST,
  port: Number(process.env.POSTGRES_PORT || 5432),
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});

function uuid() {
  return crypto.randomUUID();
}

function money(value) {
  return Number(value).toFixed(2);
}

function fee(value) {
  return money(Number(value) * 0.03);
}

async function q(sql, params = []) {
  return client.query(sql, params);
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

async function seedActor(kind, index) {
  const userId = uuid();
  const orgId = uuid();
  const memberId = uuid();
  const certId = uuid();
  const personalCertId = uuid();
  const sessionId = uuid();
  const licenseFileId = uuid();
  const base = String(Date.now()).slice(-7).padStart(7, '0');
  const mobile = `199${base}${String(index).padStart(1, '0')}`.slice(0, 11);
  const isPublisher = kind === 'publisher';
  const orgType = isPublisher ? 'buyer' : 'supplier';
  const roleKey = isPublisher ? 'buyer_admin' : 'supplier_admin';
  const expiresAt = new Date(Date.now() + 2 * 60 * 60 * 1000);
  const uscc = `USCC${runId.replace(/[^a-zA-Z0-9]/g, '').slice(-20)}${index}`;

  await q(
    `insert into users (id,mobile,mobile_verified_at,nickname,avatar_url,avatar_file_asset_id,profile_intro,status,last_login_at,last_login_ip,created_at,updated_at)
     values ($1,$2,now(),$3,null,null,$4,'active',now(),'127.0.0.1',now(),now())`,
    [userId, mobile, `P0PAY-E2E ${kind} ${index}`, runId],
  );
  await q(
    `insert into organizations (id,name,organization_type,province_code,city_code,contact_name,contact_mobile,uscc,business_license_file_id,intro,status,created_by,created_at,updated_at)
     values ($1,$2,$3,'510000','510100',$4,$5,$6,null,$7,'active',$8,now(),now())`,
    [
      orgId,
      `P0PAY-E2E ${kind} ${index} ${runId}`,
      orgType,
      `E2E ${kind}`,
      mobile,
      uscc,
      runId,
      userId,
    ],
  );
  await q(
    `insert into organization_members (id,organization_id,user_id,role_key,member_status,invited_by,invited_at,joined_at,disabled_at)
     values ($1,$2,$3,$4,'active',null,null,now(),null)`,
    [memberId, orgId, userId, roleKey],
  );
  await q(
    `insert into organization_certifications (id,organization_id,certification_status,legal_name,uscc,license_file_id,address,established_at,legal_person,business_type,registered_capital,business_term,business_scope,submitted_at,reviewed_at,reviewed_by,reject_reason,expires_at,created_at,updated_at)
     values ($1,$2,'approved',$3,$4,$5,'成都','2020-01-01','E2E法人','有限责任公司','100万','长期','展览服务',now(),now(),null,null,now()+interval '1 year',now(),now())`,
    [
      certId,
      orgId,
      `P0PAY E2E ${kind} ${index}`,
      uscc,
      licenseFileId,
    ],
  );
  if (!isPublisher) {
    await q(
      `insert into personal_certifications (id,organization_id,user_id,certification_status,real_name,id_number_masked,id_card_front_file_id,provider_request_id,submitted_at,reviewed_at,reject_reason,locked_at,created_at,updated_at)
       values ($1,$2,$3,'approved',$4,'510***********0000',null,$5,now(),now(),null,null,now(),now())`,
      [personalCertId, orgId, userId, `E2E工厂${index}`, runId],
    );
  }
  await q(
    `insert into sessions (id,user_id,refresh_token_hash,organization_id,device_id,device_name,auth_mode,issue_reason,agreement_version,privacy_version,agreed_at,ip,user_agent,status,expires_at,revoked_at,created_at)
     values ($1,$2,$3,$4,$5,'p0pay-cloud-e2e','otp_login',$6,null,null,now(),'127.0.0.1','p0pay-cloud-e2e','valid',$7,null,now())`,
    [sessionId, userId, crypto.randomBytes(32).toString('hex'), orgId, `p0pay-${index}`, runId, expiresAt],
  );
  return { userId, orgId, roleKey, sessionId, token: tokenFor(sessionId, orgId, expiresAt) };
}

function publicActor(actor) {
  return { userId: actor.userId, orgId: actor.orgId, roleKey: actor.roleKey, sessionId: actor.sessionId };
}

function authHeaders(actor, suffix) {
  return {
    'content-type': 'application/json',
    authorization: `Bearer ${actor.token}`,
    'x-request-id': `${runId}-${suffix}`,
    'x-trace-id': `${runId}-${suffix}`,
    'user-agent': 'p0pay-cloud-e2e',
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

function taskPayload(taskType, suffix) {
  return {
    taskType,
    projectName: `P0PAY-E2E ${suffix} ${runId}`,
    cityCode: '510100',
    projectType: 'exhibition_booth',
    exhibitionName: `P0PAY-E2E 展会 ${suffix}`,
    area: 128,
    buildStartAt: '2026-06-01',
    dismantleAt: '2026-06-08',
    requirementDescription: `P0-Pay cloud integration ${suffix} ${runId}`,
    budgetAmount: '100000.00',
    budgetRange: '80000-120000',
    quoteDeadlineAt: '2026-05-30T10:00:00.000Z',
    contactId: `contact-${suffix}`,
    authenticityMaterialFileAssetIds: [],
    authenticityDeclarations: {
      demandExistsConfirmed: true,
      authorizationConfirmed: true,
      noQuoteHarvestingConfirmed: true,
      resultProcessingConfirmed: true,
      creditImpactAcknowledged: true,
    },
    idempotencyKey: `${runId}-${suffix}-create-task`,
  };
}

function fixedBidPayload(amount, suffix) {
  return {
    quoteAmount: money(amount),
    quoteValidUntil: '2026-06-15T00:00:00.000Z',
    taxIncluded: true,
    transportIncluded: true,
    installationIncluded: true,
    constructionPlan: `施工方案 ${suffix}`,
    materialDescription: `材料说明 ${suffix}`,
    craftDescription: `工艺说明 ${suffix}`,
    buildProcess: `搭建流程 ${suffix}`,
    deliveryMilestones: [{ name: '进场', date: '2026-06-01' }, { name: '验收', date: '2026-06-07' }],
    riskNotes: `风险说明 ${suffix}`,
    attachmentFileAssetIds: [],
    platformServiceFeeRuleAgreement: {
      ruleVersion: 'V1.3-P0-Pay',
      ruleSnapshotHash: `hash-${runId}`,
      agreedAtClient: new Date().toISOString(),
      readConfirmed: true,
      authorizationAwarenessConfirmed: true,
      publisherBreachReleaseAwarenessConfirmed: true,
    },
    idempotencyKey: `${runId}-${suffix}-fixed-bid`,
  };
}

function inquiryQuotePayload(amount, suffix) {
  return {
    quotedAmount: money(amount),
    quoteValidUntil: '2026-06-15T00:00:00.000Z',
    taxIncluded: true,
    transportIncluded: true,
    installationIncluded: true,
    proposalSummary: `询价报价摘要 ${suffix}`,
    constructionPlan: `询价施工方案 ${suffix}`,
    riskNotes: `询价风险说明 ${suffix}`,
    attachmentFileAssetIds: [],
    idempotencyKey: `${runId}-${suffix}-inquiry-quote`,
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
      'user-agent': 'p0pay-cloud-e2e',
    },
    body: JSON.stringify(payload),
  });
  const text = await res.text();
  const body = text ? JSON.parse(text) : null;
  if (res.status < 200 || res.status >= 300) {
    const err = new Error(`callback ${label} -> ${res.status}`);
    err.response = { status: res.status, body };
    throw err;
  }
  return { status: res.status, body };
}

async function authorizeBid(taskId, bidId, amount, actor, label) {
  const create = await http('POST', `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bidId}/service-fee-authorizations`, actor, {
    expectedQuotedAmount: money(amount),
    expectedFeeRate: '0.030000',
    expectedAuthorizationAmount: fee(amount),
    currency: 'CNY',
    idempotencyKey: `${runId}-${label}-auth-create`,
  }, `${label}-auth-create`);
  const authorizationId = create.body.authorizationId;
  const init = await http('POST', `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bidId}/service-fee-authorizations/${authorizationId}/authorize-init`, actor, {
    payChannel: 'other_candidate',
    clientPlatform: 'cloud-e2e',
    idempotencyKey: `${runId}-${label}-auth-init`,
  }, `${label}-auth-init`);
  const merchantOrderNo = init.body.channelPayload?.merchantOrderNo || init.body.paymentReferenceId;
  const cb = await paymentCallback(merchantOrderNo, fee(amount), `${label}-auth`);
  const status = await http('GET', `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bidId}/service-fee-authorizations/${authorizationId}`, actor, undefined, `${label}-auth-status`);
  return { authorizationId, create: create.body, init: init.body, callback: cb.body, status: status.body };
}

async function createFixedTaskWithAuthorizedBid(label, amount, factory, publisher) {
  const task = await http('POST', '/exhibition/trade-tasks', publisher, taskPayload('fixed_price_bid', label), `${label}-task`);
  const bid = await http('POST', `/exhibition/trade-tasks/${task.body.taskId}/fixed-price-bids`, factory, fixedBidPayload(amount, label), `${label}-bid`);
  const auth = await authorizeBid(task.body.taskId, bid.body.bidId, amount, factory, label);
  return { taskId: task.body.taskId, bidId: bid.body.bidId, task: task.body, bid: bid.body, auth };
}

async function runDay16(publisher, factories) {
  const t = await http('POST', '/exhibition/trade-tasks', publisher, taskPayload('inquiry_quote', 'day16-inquiry'), 'day16-task');
  const taskId = t.body.taskId;
  evidence.day16.steps.push({ step: 'create_inquiry_task', status: t.status, taskId, taskStatus: t.body.taskStatus, publishGateStatus: t.body.publishGateStatus });
  const dep = await http('POST', `/exhibition/trade-tasks/${taskId}/inquiry-deposit/orders`, publisher, {
    expectedAmount: '200.00',
    expectedCurrency: 'CNY',
    ruleVersion: 'V1.3-P0-Pay',
    ruleSnapshotHash: `hash-${runId}`,
    idempotencyKey: `${runId}-day16-deposit`,
  }, 'day16-deposit');
  const init = await http('POST', `/exhibition/trade-tasks/${taskId}/inquiry-deposit/orders/${dep.body.depositOrderId}/pay-init`, publisher, {
    payChannel: 'other_candidate',
    clientPlatform: 'cloud-e2e',
    idempotencyKey: `${runId}-day16-deposit-init`,
  }, 'day16-deposit-init');
  const cb = await paymentCallback(init.body.channelPayload?.merchantOrderNo || init.body.paymentReferenceId, '200.00', 'day16-deposit');
  const depStatus = await http('GET', `/exhibition/trade-tasks/${taskId}/inquiry-deposit/orders/${dep.body.depositOrderId}`, publisher, undefined, 'day16-deposit-status');
  evidence.day16.steps.push({ step: 'deposit_paid', createStatus: dep.status, initStatus: init.status, callbackStatus: cb.body.applyStatus, depositStatus: depStatus.body.depositStatus });

  const quotes = [];
  for (let i = 0; i < 5; i += 1) {
    const qr = await http('POST', `/exhibition/trade-tasks/${taskId}/inquiry-quotations`, factories[i], inquiryQuotePayload(82000 + i * 1000, `day16-q${i + 1}`), `day16-q${i + 1}`);
    quotes.push(qr.body);
  }
  const sixth = await http('POST', `/exhibition/trade-tasks/${taskId}/inquiry-quotations`, factories[5], inquiryQuotePayload(89000, 'day16-q6'), 'day16-q6', false);
  const result = await http('POST', `/exhibition/trade-tasks/${taskId}/inquiry-result`, publisher, {
    processingAction: 'select_factory',
    selectedQuotationId: quotes[0].quotationId,
    reasonCode: 'selected_best_value',
    reasonText: 'E2E选择第一家进入合同确认',
    idempotencyKey: `${runId}-day16-result`,
  }, 'day16-result');
  const depAfter = await http('GET', `/exhibition/trade-tasks/${taskId}/inquiry-deposit/orders/${dep.body.depositOrderId}`, publisher, undefined, 'day16-deposit-after-result');
  evidence.day16.steps.push({ step: 'quote_seats_and_refund', submitted: quotes.length, fifthSeat: quotes[4]?.quoteSeatSummary, sixthStatus: sixth.status, resultStatus: result.body.processingStatus, depositStatus: depAfter.body.depositStatus, refundStatus: depAfter.body.refundStatus });
  evidence.day16.taskId = taskId;
  evidence.day16.depositOrderId = dep.body.depositOrderId;
  evidence.day16.status = depStatus.body.depositStatus === 'paid' && quotes.length === 5 && sixth.status === 400 && depAfter.body.depositStatus === 'refund_pending' ? 'passed' : 'failed';
}

async function runDay17(publisher, factories) {
  const task = await http('POST', '/exhibition/trade-tasks', publisher, taskPayload('fixed_price_bid', 'day17-fixed'), 'day17-task');
  const taskId = task.body.taskId;
  const bid1 = await http('POST', `/exhibition/trade-tasks/${taskId}/fixed-price-bids`, factories[0], fixedBidPayload(80000, 'day17-bid1'), 'day17-bid1');
  const bid2 = await http('POST', `/exhibition/trade-tasks/${taskId}/fixed-price-bids`, factories[1], fixedBidPayload(86000, 'day17-bid2'), 'day17-bid2');
  const auth1 = await authorizeBid(taskId, bid1.body.bidId, 80000, factories[0], 'day17-bid1');
  const auth2 = await authorizeBid(taskId, bid2.body.bidId, 86000, factories[1], 'day17-bid2');
  const award = await http('POST', '/bid/award', publisher, { projectId: taskId, winningBidId: bid1.body.bidId, reasonCode: 'p0_pay_e2e_award', reasonText: 'E2E定标第一家' }, 'day17-award');
  const release = await http('POST', `/exhibition/trade-tasks/${taskId}/p0-pay-actions/release-non-winning`, publisher, { winningBidId: bid1.body.bidId, idempotencyKey: `${runId}-day17-release` }, 'day17-release');
  const winnerStatus = await http('GET', `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bid1.body.bidId}/service-fee-authorizations/${auth1.authorizationId}`, factories[0], undefined, 'day17-winner-status');
  const loserStatus = await http('GET', `/exhibition/trade-tasks/${taskId}/fixed-price-bids/${bid2.body.bidId}/service-fee-authorizations/${auth2.authorizationId}`, factories[1], undefined, 'day17-loser-status');
  evidence.day17.taskId = taskId;
  evidence.day17.steps.push({ step: 'preauth_award_release', authStatuses: [auth1.status.authorizationStatus, auth2.status.authorizationStatus], awardState: award.body.state, releaseChanged: release.body.changed, winner: winnerStatus.body.authorizationStatus, loser: loserStatus.body.authorizationStatus });
  evidence.day17.status = release.body.changed === 1 && winnerStatus.body.authorizationStatus === 'authorized' && loserStatus.body.authorizationStatus === 'authorization_released' ? 'passed' : 'failed';
}

async function runDay18(publisher, factories) {
  const chargeCase = await createFixedTaskWithAuthorizedBid('day18-charge', 92000, factories[2], publisher);
  const award = await http('POST', '/bid/award', publisher, { projectId: chargeCase.taskId, winningBidId: chargeCase.bidId, reasonCode: 'p0_pay_e2e_contract', reasonText: 'E2E合同确认扣费' }, 'day18-charge-award');
  const pubConfirm = await http('POST', `/exhibition/trade-tasks/${chargeCase.taskId}/contract-confirmations`, publisher, {
    selectedBidId: chargeCase.bidId,
    selectedQuotationId: null,
    finalConfirmedAmount: '94000.00',
    currency: 'CNY',
    contractFileAssetIds: [],
    confirmationRole: 'publisher',
    platformServiceFeeRecalculationAwarenessConfirmed: true,
    idempotencyKey: `${runId}-day18-contract-publisher`,
  }, 'day18-contract-publisher');
  const factoryConfirm = await http('POST', `/exhibition/trade-tasks/${chargeCase.taskId}/contract-confirmations`, factories[2], {
    selectedBidId: chargeCase.bidId,
    selectedQuotationId: null,
    finalConfirmedAmount: '94000.00',
    currency: 'CNY',
    contractFileAssetIds: [],
    confirmationRole: 'factory',
    platformServiceFeeRecalculationAwarenessConfirmed: true,
    idempotencyKey: `${runId}-day18-contract-factory`,
  }, 'day18-contract-factory');
  const chargedStatus = await http('GET', `/exhibition/trade-tasks/${chargeCase.taskId}/fixed-price-bids/${chargeCase.bidId}/service-fee-authorizations/${chargeCase.auth.authorizationId}`, factories[2], undefined, 'day18-charged-status');

  const breachCase = await createFixedTaskWithAuthorizedBid('day18-publisher-breach', 78000, factories[3], publisher);
  const breachRelease = await http('POST', `/exhibition/trade-tasks/${breachCase.taskId}/p0-pay-actions/publisher-breach-release`, publisher, { bidId: breachCase.bidId, reasonCode: 'publisher_cancelled', reasonText: 'E2E发布方毁约退回', idempotencyKey: `${runId}-day18-breach-release` }, 'day18-breach-release');
  const breachStatus = await http('GET', `/exhibition/trade-tasks/${breachCase.taskId}/fixed-price-bids/${breachCase.bidId}/service-fee-authorizations/${breachCase.auth.authorizationId}`, factories[3], undefined, 'day18-breach-status');

  const refusalCase = await createFixedTaskWithAuthorizedBid('day18-factory-refusal', 76000, factories[4], publisher);
  const hold = await http('POST', `/exhibition/trade-tasks/${refusalCase.taskId}/p0-pay-actions/factory-refusal-breach-hold`, publisher, { bidId: refusalCase.bidId, reasonCode: 'factory_refused_signing', reasonText: 'E2E工厂拒签挂起', idempotencyKey: `${runId}-day18-refusal-hold` }, 'day18-refusal-hold');
  const holdStatus = await http('GET', `/exhibition/trade-tasks/${refusalCase.taskId}/fixed-price-bids/${refusalCase.bidId}/service-fee-authorizations/${refusalCase.auth.authorizationId}`, factories[4], undefined, 'day18-hold-status');
  const bidReadback = await q('select state from bids where id=$1', [refusalCase.bidId]);

  evidence.day18.steps.push({ step: 'contract_charge', awardState: award.body.state, publisherContract: pubConfirm.body.contractStatus, factoryContract: factoryConfirm.body.contractStatus, feeStatus: factoryConfirm.body.platformServiceFeeStatus, finalFee: factoryConfirm.body.platformServiceFeeFinalAmount, authReadback: chargedStatus.body.authorizationStatus });
  evidence.day18.steps.push({ step: 'publisher_breach_release', changed: breachRelease.body.changed, authorizationReadback: breachStatus.body.authorizationStatus });
  evidence.day18.steps.push({ step: 'factory_refusal_hold', changed: hold.body.changed, authorizationReadback: holdStatus.body.authorizationStatus, bidState: bidReadback.rows[0]?.state });
  evidence.day18.status = factoryConfirm.body.contractStatus === 'confirmed' && factoryConfirm.body.platformServiceFeeStatus === 'charged' && chargedStatus.body.authorizationStatus === 'charged' && breachStatus.body.authorizationStatus === 'authorization_released' && holdStatus.body.authorizationStatus === 'breach_hold' && bidReadback.rows[0]?.state === 'breach_hold' ? 'passed' : 'failed';
}

async function guarded(name, run) {
  try {
    await run();
  } catch (err) {
    evidence[name].status = 'failed';
    evidence[name].error = { message: err.message, response: err.response };
    evidence.blockers.push(`${name} failed`);
  }
}

(async () => {
  await client.connect();
  const publisher = await seedActor('publisher', 0);
  const factories = [];
  for (let i = 1; i <= 7; i += 1) factories.push(await seedActor('factory', i));
  evidence.actors = { publisher: publicActor(publisher), factories: factories.map(publicActor) };

  for (const day of ['day16', 'day17', 'day18']) {
    if (!requestedDays.has(day)) {
      evidence[day].status = 'not_run';
    }
  }
  if (requestedDays.has('day16')) await guarded('day16', () => runDay16(publisher, factories));
  if (requestedDays.has('day17')) await guarded('day17', () => runDay17(publisher, factories));
  if (requestedDays.has('day18')) await guarded('day18', () => runDay18(publisher, factories));
  evidence.finishedAt = new Date().toISOString();
  console.log(JSON.stringify(evidence, null, 2));
})().catch((err) => {
  evidence.finishedAt = new Date().toISOString();
  evidence.fatal = { message: err.message, stack: err.stack, response: err.response };
  console.log(JSON.stringify(evidence, null, 2));
  process.exitCode = 1;
}).finally(async () => {
  try {
    await client.end();
  } catch {
    // ignore close errors for receipt generation.
  }
});
