import { P0PayPaymentChannel } from './p0-pay.types';

export type CreateAuthorizationCommand = {
  taskId: string;
  bidId: string;
  expectedQuotedAmount: string;
  expectedFeeRate: string;
  expectedAuthorizationAmount: string;
  currency: string;
  idempotencyKey: string;
};

export type AuthorizeInitCommand = {
  taskId: string;
  bidId: string;
  authorizationId: string;
  payChannel: P0PayPaymentChannel;
  clientPlatform: string;
  idempotencyKey: string;
};

export type CreateInquiryDepositOrderCommand = {
  taskId: string;
  expectedAmount: string;
  expectedCurrency: string;
  ruleVersion: string;
  ruleSnapshotHash: string;
  idempotencyKey: string;
};

export type InquiryDepositPayInitCommand = {
  taskId: string;
  depositOrderId: string;
  payChannel: P0PayPaymentChannel;
  clientPlatform: string;
  idempotencyKey: string;
};

export type ContractConfirmationCommand = {
  taskId: string;
  selectedBidId: string | null;
  selectedQuotationId: string | null;
  finalConfirmedAmount: string;
  currency: string;
  contractFileAssetIds: string[];
  confirmationRole: 'publisher' | 'factory';
  platformServiceFeeRecalculationAwarenessConfirmed: boolean;
  idempotencyKey: string;
};
