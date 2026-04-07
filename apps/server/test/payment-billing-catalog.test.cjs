const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildSummaryStatus,
  findBillingExplanation,
  findDependency,
  findHandoff,
  findPaymentExplanation,
  getPaymentBillingDisclaimer
} = require('../dist/modules/payment_billing/payment-billing.catalog.js');

test('buildSummaryStatus keeps dependency-required state fail-closed', () => {
  const status = buildSummaryStatus({
    paymentStatus: 'handoff_required',
    paymentAvailabilityStatus: 'unavailable',
    billingReferenceStatus: 'available',
    billingReferenceVisibilityStatus: 'visible',
    handoffStatus: 'handoff_required',
    dependencyRequired: true
  });

  assert.equal(status, 'handoff_required');
});

test('catalog lookup exposes the future finance dependency boundary', () => {
  const paymentExplanation = findPaymentExplanation('payment_handoff_required');
  const billingExplanation = findBillingExplanation('billing_reference_visible');
  const dependency = findDependency('future_finance_dependency_required');
  const handoff = findHandoff('open_future_finance_dependency');

  assert.equal(paymentExplanation?.explanationKey, 'payment_handoff_required');
  assert.equal(billingExplanation?.explanationKey, 'billing_reference_visible');
  assert.equal(
    dependency?.dependencyFamilyKey,
    'future_settlement_clearing_tax_finance_admin'
  );
  assert.equal(handoff?.handoffKey, 'open_future_finance_dependency');
  assert.match(getPaymentBillingDisclaimer(), /payment execution/i);
});
