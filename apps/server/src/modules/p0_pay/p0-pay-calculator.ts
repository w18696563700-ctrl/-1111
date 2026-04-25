import { P0_PAY_DEFAULT_SERVICE_FEE_RATE } from './p0-pay.state';

export function normalizePositiveMoney(value: string | number, field = 'amount') {
  const amount = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error(`${field} must be a positive number.`);
  }
  return amount.toFixed(2);
}

export function normalizeFeeRate(value: string | number = P0_PAY_DEFAULT_SERVICE_FEE_RATE) {
  const rate = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(rate) || rate <= 0 || rate > 1) {
    throw new Error('feeRate must be greater than 0 and not greater than 1.');
  }
  return rate.toFixed(6);
}

export function calculatePlatformServiceFeeAmount(
  quotedAmount: string | number,
  feeRate: string | number = P0_PAY_DEFAULT_SERVICE_FEE_RATE
) {
  const amount = Number(normalizePositiveMoney(quotedAmount, 'quotedAmount'));
  const rate = Number(normalizeFeeRate(feeRate));
  const amountCents = Math.round(amount * 100);
  const feeCents = Math.round(amountCents * rate);
  return (feeCents / 100).toFixed(2);
}
