import { Injectable } from '@nestjs/common';
import { ContentSafetyDecision, ContentSafetyProfileField } from '../content_safety/content-safety.constants';
import { ContentSafetyOcrService } from '../content_safety/content-safety-ocr.service';
import {
  ContentSafetyRuleEngine,
  ContentSafetyRuleResult
} from '../content_safety/content-safety-rule.engine';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';

type ProfileSafetyMatchedRule = ContentSafetyRuleResult['matchedRules'][number];

export type ProfileSafetyAutoDecision = {
  status: 'approved' | 'rejected' | 'pending_review';
  engineType: 'rule' | 'ocr';
  decision: ContentSafetyDecision;
  matchedRules: ProfileSafetyMatchedRule[];
  reasonCode: string | null;
  reasonText: string | null;
  metadata: Record<string, unknown>;
};

export type ProfileSafetyAutoDecisionInput = {
  fieldKey: ContentSafetyProfileField;
  proposedValue: string;
  fileAsset?: {
    id: string;
    objectKey: string | null;
  } | null;
};

@Injectable()
export class ProfileSafetyAutoDecisionService {
  constructor(
    private readonly ocrService: ContentSafetyOcrService,
    private readonly ruleEngine: ContentSafetyRuleEngine,
    private readonly uploadPublicUrlService: UploadPublicUrlService
  ) {}

  async decide(input: ProfileSafetyAutoDecisionInput): Promise<ProfileSafetyAutoDecision> {
    if (input.fieldKey === 'nickname') {
      return this.decideNickname(input.proposedValue);
    }
    if (input.fieldKey === 'avatar') {
      return this.decideAvatar(input);
    }
    return this.decideIntro(input.proposedValue);
  }

  private async decideNickname(content: string): Promise<ProfileSafetyAutoDecision> {
    const result = await this.ruleEngine.evaluateProfileText({ fieldKey: 'nickname', content });
    if (result.decision === 'block') {
      return this.toBlockedDecision('rule', result, {});
    }
    return {
      status: 'approved',
      engineType: 'rule',
      decision: 'allow',
      matchedRules: [],
      reasonCode: null,
      reasonText: null,
      metadata: { autoApprovalPath: 'nickname_rule_allow' }
    };
  }

  private async decideIntro(content: string): Promise<ProfileSafetyAutoDecision> {
    const result = await this.ruleEngine.evaluateProfileText({ fieldKey: 'intro', content });
    if (result.decision === 'block') {
      return this.toBlockedDecision('rule', result, {});
    }
    return {
      status: 'pending_review',
      engineType: 'rule',
      decision: 'allow',
      matchedRules: [],
      reasonCode: null,
      reasonText: null,
      metadata: { autoApprovalPath: 'intro_manual_review_fallback' }
    };
  }

  private async decideAvatar(input: ProfileSafetyAutoDecisionInput): Promise<ProfileSafetyAutoDecision> {
    const objectKey = input.fileAsset?.objectKey?.trim() ?? '';
    if (!objectKey) {
      return this.toManualReviewDecision('ocr_access_url_unavailable', 'Avatar object key is unavailable.');
    }
    const accessUrl = await this.uploadPublicUrlService.buildObjectAccessUrl(objectKey);
    if (!accessUrl) {
      return this.toManualReviewDecision(
        'ocr_access_url_unavailable',
        'Signed avatar access URL is unavailable for OCR moderation.'
      );
    }
    const ocrResult = await this.ocrService.recognizeGeneralText(accessUrl);
    if (ocrResult.status === 'disabled') {
      return this.toManualReviewDecision(ocrResult.errorCode, ocrResult.errorMessage, null, ocrResult.status);
    }
    if (ocrResult.status === 'failed') {
      return this.toManualReviewDecision(
        ocrResult.errorCode,
        ocrResult.errorMessage,
        ocrResult.providerRequestId,
        ocrResult.status
      );
    }

    const extractedText = ocrResult.extractedText;
    if (!extractedText) {
      return {
        status: 'approved',
        engineType: 'ocr',
        decision: 'allow',
        matchedRules: [],
        reasonCode: null,
        reasonText: null,
        metadata: {
          autoApprovalPath: 'avatar_ocr_allow_empty_text',
          ocrStatus: ocrResult.status,
          ocrProviderRequestId: ocrResult.providerRequestId,
          ocrTextLength: 0,
          ocrTextExcerpt: null
        }
      };
    }

    const ruleResult = await this.ruleEngine.evaluateProfileText({
      fieldKey: 'avatar',
      content: extractedText
    });
    if (ruleResult.decision === 'block') {
      return this.toBlockedDecision('ocr', ruleResult, {
        autoApprovalPath: 'avatar_ocr_rule_block',
        ocrStatus: ocrResult.status,
        ocrProviderRequestId: ocrResult.providerRequestId,
        ocrTextLength: extractedText.length,
        ocrTextExcerpt: extractedText.slice(0, 120)
      });
    }

    return {
      status: 'approved',
      engineType: 'ocr',
      decision: 'allow',
      matchedRules: [],
      reasonCode: null,
      reasonText: null,
      metadata: {
        autoApprovalPath: 'avatar_ocr_allow',
        ocrStatus: ocrResult.status,
        ocrProviderRequestId: ocrResult.providerRequestId,
        ocrTextLength: extractedText.length,
        ocrTextExcerpt: extractedText.slice(0, 120)
      }
    };
  }

  private toBlockedDecision(
    engineType: 'rule' | 'ocr',
    result: ContentSafetyRuleResult,
    metadata: Record<string, unknown>
  ): ProfileSafetyAutoDecision {
    return {
      status: 'rejected',
      engineType,
      decision: 'block',
      matchedRules: result.matchedRules,
      reasonCode: result.reasonCode,
      reasonText: result.reasonText,
      metadata
    };
  }

  private toManualReviewDecision(
    errorCode: string,
    errorMessage: string,
    providerRequestId?: string | null,
    ocrStatus: 'disabled' | 'failed' = 'failed'
  ): ProfileSafetyAutoDecision {
    return {
      status: 'pending_review',
      engineType: 'ocr',
      decision: 'manual_review',
      matchedRules: [],
      reasonCode: errorCode,
      reasonText: errorMessage,
      metadata: {
        autoApprovalPath: 'avatar_manual_review_fallback',
        ocrStatus,
        ocrProviderRequestId: providerRequestId ?? null
      }
    };
  }
}
