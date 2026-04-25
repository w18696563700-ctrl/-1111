export const P0_PAY_RULE_VERSION = 'exhibition_trade_task_payment_mainline_p0_pay_v1_3';

export const P0_PAY_DEFAULT_SERVICE_FEE_RATE = 0.03;

export const P0_PAY_INQUIRY_DEPOSIT_AMOUNT = '200.00';

export const P0_PAY_SERVICE_FEE_AGREEMENT_TEXT =
  'P0-Pay 平台服务费预授权：未中标自动释放；中标后进入合同确认；合同确认生效后按最终成交确认金额计费。';

export const P0_PAY_ACCOUNT_BINDING_POLICY = {
  requiresPreBoundPaymentAccount: false,
  storesUserPaymentAccountIdentifiers: false,
  mode: 'order_level_payment_and_authorization'
} as const;

export const P0_PAY_SERVICE_FEE_AUTHORIZATION_MUTABLE_STATUSES = new Set([
  'pending_authorization',
  'authorized',
  'pending_contract_confirm'
]);

export const P0_PAY_CALLBACK_SECRET_ENV = 'P0_PAY_CALLBACK_SECRET';
