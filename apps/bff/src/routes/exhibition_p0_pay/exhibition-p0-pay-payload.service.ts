import { BadRequestException, Injectable } from '@nestjs/common';

type Payload = Record<string, unknown>;

const TASK_TYPES = new Set(['fixed_price_bid', 'inquiry_quote']);
const MATERIAL_TYPES = new Set([
  'rendering',
  'construction_drawing',
  'floor_plan',
  'booth_plan',
  'customer_requirement_screenshot',
  'customer_authorization_note',
  'tender_document',
  'venue_information',
  'organizer_information',
  'historical_project_photo',
  'other',
]);
const PAY_CHANNELS = new Set(['alipay_candidate', 'wechat_candidate', 'other_candidate']);
const RESULT_ACTIONS = new Set(['select_factory', 'close_without_deal', 'cancel_project']);
const CONFIRMATION_ROLES = new Set(['publisher', 'factory']);

@Injectable()
export class ExhibitionP0PayPayloadService {
  toCreateTradeTaskPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    const declarations = this.requireRecord(source.authenticityDeclarations);
    return {
      taskType: this.readEnum(source.taskType, TASK_TYPES, 'taskType'),
      projectName: this.readString(source.projectName, 'projectName'),
      cityCode: this.readString(source.cityCode, 'cityCode'),
      projectType: this.readString(source.projectType, 'projectType'),
      exhibitionName: this.readString(source.exhibitionName, 'exhibitionName'),
      area: this.readPositiveNumber(source.area, 'area'),
      buildStartAt: this.readString(source.buildStartAt, 'buildStartAt'),
      dismantleAt: this.readString(source.dismantleAt, 'dismantleAt'),
      requirementDescription: this.readString(source.requirementDescription, 'requirementDescription'),
      budgetAmount: this.readMoney(source.budgetAmount, 'budgetAmount'),
      budgetRange: this.readString(source.budgetRange, 'budgetRange'),
      quoteDeadlineAt: this.readString(source.quoteDeadlineAt, 'quoteDeadlineAt'),
      contactId: this.readString(source.contactId, 'contactId'),
      authenticityMaterialFileAssetIds: this.readStringArray(
        source.authenticityMaterialFileAssetIds,
        'authenticityMaterialFileAssetIds',
      ),
      authenticityDeclarations: {
        demandExistsConfirmed: this.readConfirmed(declarations.demandExistsConfirmed, 'demandExistsConfirmed'),
        authorizationConfirmed: this.readConfirmed(declarations.authorizationConfirmed, 'authorizationConfirmed'),
        noQuoteHarvestingConfirmed: this.readConfirmed(
          declarations.noQuoteHarvestingConfirmed,
          'noQuoteHarvestingConfirmed',
        ),
        resultProcessingConfirmed: this.readConfirmed(
          declarations.resultProcessingConfirmed,
          'resultProcessingConfirmed',
        ),
        creditImpactAcknowledged: this.readConfirmed(
          declarations.creditImpactAcknowledged,
          'creditImpactAcknowledged',
        ),
      },
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toAuthenticityMaterialsPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      fileAssetIds: this.readStringArray(source.fileAssetIds, 'fileAssetIds'),
      materialType: this.readEnum(source.materialType, MATERIAL_TYPES, 'materialType'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toFixedPriceBidPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      quoteAmount: this.readMoney(source.quoteAmount, 'quoteAmount'),
      quoteValidUntil: this.readString(source.quoteValidUntil, 'quoteValidUntil'),
      taxIncluded: this.readBoolean(source.taxIncluded, 'taxIncluded'),
      transportIncluded: this.readBoolean(source.transportIncluded, 'transportIncluded'),
      installationIncluded: this.readBoolean(source.installationIncluded, 'installationIncluded'),
      constructionPlan: this.readString(source.constructionPlan, 'constructionPlan'),
      materialDescription: this.readString(source.materialDescription, 'materialDescription'),
      craftDescription: this.readString(source.craftDescription, 'craftDescription'),
      buildProcess: this.readString(source.buildProcess, 'buildProcess'),
      deliveryMilestones: this.readUnknownArray(source.deliveryMilestones, 'deliveryMilestones'),
      riskNotes: this.readString(source.riskNotes, 'riskNotes'),
      attachmentFileAssetIds: this.readStringArray(source.attachmentFileAssetIds, 'attachmentFileAssetIds'),
      platformServiceFeeRuleAgreement: this.readRuleAgreement(source.platformServiceFeeRuleAgreement),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toServiceFeeAuthorizationPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      expectedQuotedAmount: this.readMoney(source.expectedQuotedAmount, 'expectedQuotedAmount'),
      expectedFeeRate: this.readMoney(source.expectedFeeRate, 'expectedFeeRate'),
      expectedAuthorizationAmount: this.readMoney(source.expectedAuthorizationAmount, 'expectedAuthorizationAmount'),
      currency: this.readCurrency(source.currency),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toBidServiceFeeAuthorizationPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    const expectedAmount = this.readMoney(source.expectedAmount, 'expectedAmount');
    if (Number(expectedAmount) !== 4000) {
      throw this.badRequest('Bid service fee authorization quota must be 4000.00 CNY.');
    }
    return {
      bidParticipationRequestId: this.readString(source.bidParticipationRequestId, 'bidParticipationRequestId'),
      expectedAmount,
      expectedCurrency: this.readCurrency(source.expectedCurrency),
      ruleVersion: this.readString(source.ruleVersion, 'ruleVersion'),
      ruleSnapshotHash: this.readString(source.ruleSnapshotHash, 'ruleSnapshotHash'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toPayInitPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      payChannel: this.readEnum(source.payChannel, PAY_CHANNELS, 'payChannel'),
      clientPlatform: this.readString(source.clientPlatform, 'clientPlatform').slice(0, 64),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toInquiryDepositOrderPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      expectedAmount: this.readMoney(source.expectedAmount, 'expectedAmount'),
      expectedCurrency: this.readCurrency(source.expectedCurrency),
      ruleVersion: this.readString(source.ruleVersion, 'ruleVersion'),
      ruleSnapshotHash: this.readString(source.ruleSnapshotHash, 'ruleSnapshotHash'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toInquiryQuotationPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      quotedAmount: this.readMoney(source.quotedAmount, 'quotedAmount'),
      quoteValidUntil: this.readString(source.quoteValidUntil, 'quoteValidUntil'),
      taxIncluded: this.readBoolean(source.taxIncluded, 'taxIncluded'),
      transportIncluded: this.readBoolean(source.transportIncluded, 'transportIncluded'),
      installationIncluded: this.readBoolean(source.installationIncluded, 'installationIncluded'),
      proposalSummary: this.readString(source.proposalSummary, 'proposalSummary'),
      constructionPlan: this.readString(source.constructionPlan, 'constructionPlan'),
      riskNotes: this.readString(source.riskNotes, 'riskNotes'),
      attachmentFileAssetIds: this.readStringArray(source.attachmentFileAssetIds, 'attachmentFileAssetIds'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toInquiryResultPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      processingAction: this.readEnum(source.processingAction, RESULT_ACTIONS, 'processingAction'),
      selectedQuotationId: this.readOptionalString(source.selectedQuotationId),
      reasonCode: this.readString(source.reasonCode, 'reasonCode'),
      reasonText: this.readString(source.reasonText, 'reasonText'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toContractConfirmationPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      selectedBidId: this.readOptionalString(source.selectedBidId),
      selectedQuotationId: this.readOptionalString(source.selectedQuotationId),
      finalConfirmedAmount: this.readMoney(source.finalConfirmedAmount, 'finalConfirmedAmount'),
      currency: this.readCurrency(source.currency),
      contractFileAssetIds: this.readStringArray(source.contractFileAssetIds, 'contractFileAssetIds'),
      confirmationRole: this.readEnum(source.confirmationRole, CONFIRMATION_ROLES, 'confirmationRole'),
      platformServiceFeeRecalculationAwarenessConfirmed: this.readConfirmed(
        source.platformServiceFeeRecalculationAwarenessConfirmed,
        'platformServiceFeeRecalculationAwarenessConfirmed',
      ),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toReleaseNonWinningPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      winningBidId: this.readString(source.winningBidId, 'winningBidId'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toPublisherBreachReleasePayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      bidId: this.readOptionalString(source.bidId),
      reasonCode: this.readString(source.reasonCode, 'reasonCode'),
      reasonText: this.readString(source.reasonText, 'reasonText'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toFactoryRefusalBreachHoldPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      bidId: this.readString(source.bidId, 'bidId'),
      reasonCode: this.readString(source.reasonCode, 'reasonCode'),
      reasonText: this.readString(source.reasonText, 'reasonText'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toBidServiceFeeAuthorizationReleasePayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      releaseReasonCode: this.readString(source.releaseReasonCode, 'releaseReasonCode'),
      releaseReasonText: this.readString(source.releaseReasonText, 'releaseReasonText'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toProjectAuthenticitySincerityRefundPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      refundReasonCode: this.readOptionalString(source.refundReasonCode) ?? 'project_publish_cancelled',
      refundReasonText: this.readOptionalString(source.refundReasonText) ?? '',
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  toDealConfirmationPayload(value: unknown, idempotencyKey?: string) {
    const source = this.requireRecord(value);
    return {
      selectedBidId: this.readString(source.selectedBidId, 'selectedBidId'),
      finalConfirmedAmount: this.readMoney(source.finalConfirmedAmount, 'finalConfirmedAmount'),
      currency: this.readCurrency(source.currency),
      contractFileAssetIds: this.readStringArray(source.contractFileAssetIds, 'contractFileAssetIds'),
      confirmationRole: this.readEnum(source.confirmationRole, CONFIRMATION_ROLES, 'confirmationRole'),
      idempotencyKey: this.readIdempotencyKey(source.idempotencyKey, idempotencyKey),
    };
  }

  readPathId(value: string | undefined, field: string) {
    return this.readString(value, field);
  }

  private readRuleAgreement(value: unknown) {
    const source = this.requireRecord(value);
    return {
      ruleVersion: this.readString(source.ruleVersion, 'ruleVersion'),
      ruleSnapshotHash: this.readString(source.ruleSnapshotHash, 'ruleSnapshotHash'),
      agreedAtClient: this.readString(source.agreedAtClient, 'agreedAtClient'),
      readConfirmed: this.readConfirmed(source.readConfirmed, 'readConfirmed'),
      authorizationAwarenessConfirmed: this.readConfirmed(
        source.authorizationAwarenessConfirmed,
        'authorizationAwarenessConfirmed',
      ),
      publisherBreachReleaseAwarenessConfirmed: this.readConfirmed(
        source.publisherBreachReleaseAwarenessConfirmed,
        'publisherBreachReleaseAwarenessConfirmed',
      ),
    };
  }

  private requireRecord(value: unknown) {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      return value as Payload;
    }
    throw this.badRequest('P0-Pay request body must be an object.');
  }

  private readString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw this.badRequest(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readOptionalString(value: unknown) {
    if (value === null || value === undefined || value === '') {
      return null;
    }
    if (typeof value !== 'string') {
      throw this.badRequest('Optional id fields must be strings.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readEnum(value: unknown, allowed: Set<string>, field: string) {
    const normalized = this.readString(value, field);
    if (!allowed.has(normalized)) {
      throw this.badRequest(`Field \`${field}\` is not supported.`);
    }
    return normalized;
  }

  private readCurrency(value: unknown) {
    if (value !== 'CNY') {
      throw this.badRequest('Currency must be CNY.');
    }
    return 'CNY';
  }

  private readMoney(value: unknown, field: string) {
    if (typeof value !== 'number' && typeof value !== 'string') {
      throw this.badRequest(`Field \`${field}\` must be a money value.`);
    }
    const normalized = String(value).trim();
    const parsed = Number(normalized);
    if (!normalized || !Number.isFinite(parsed) || parsed < 0) {
      throw this.badRequest(`Field \`${field}\` must be non-negative.`);
    }
    return normalized;
  }

  private readPositiveNumber(value: unknown, field: string) {
    if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0) {
      throw this.badRequest(`Field \`${field}\` must be a positive number.`);
    }
    return value;
  }

  private readBoolean(value: unknown, field: string) {
    if (typeof value !== 'boolean') {
      throw this.badRequest(`Field \`${field}\` must be boolean.`);
    }
    return value;
  }

  private readConfirmed(value: unknown, field: string) {
    if (value !== true) {
      throw this.badRequest(`Field \`${field}\` must be confirmed.`);
    }
    return true;
  }

  private readStringArray(value: unknown, field: string) {
    if (!Array.isArray(value) || value.some((item) => typeof item !== 'string' || !item.trim())) {
      throw this.badRequest(`Field \`${field}\` must be a string array.`);
    }
    return [...new Set(value.map((item) => item.trim()))];
  }

  private readUnknownArray(value: unknown, field: string) {
    if (!Array.isArray(value)) {
      throw this.badRequest(`Field \`${field}\` must be an array.`);
    }
    return value;
  }

  private readIdempotencyKey(bodyValue: unknown, headerValue?: string) {
    const value = typeof bodyValue === 'string' && bodyValue.trim() ? bodyValue : headerValue;
    return this.readString(value, 'idempotencyKey');
  }

  private badRequest(message: string) {
    return new BadRequestException({
      statusCode: 400,
      code: 'P0_PAY_REQUEST_INVALID',
      message,
      source: 'bff',
    });
  }
}
