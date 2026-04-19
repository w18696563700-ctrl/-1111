import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyOcrService } from '../content_safety/content-safety-ocr.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { personalCertificationOcrInvalid } from './profile.errors';
import { ProfilePresenter } from './profile.presenter';

type PersonalCertificationOcrCommand = {
  organizationId: string;
  idCardFrontFileId: string;
};

export type PersonalCertificationIdCardOcrView = {
  status: 'recognized' | 'manual_required';
  message: string;
  realName: string | null;
  idNumberMasked: string | null;
  providerRequestId: string | null;
};

@Injectable()
export class ProfilePersonalCertificationOcrService {
  constructor(
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly uploadPublicUrlService: UploadPublicUrlService,
    private readonly ocrService: ContentSafetyOcrService,
    private readonly presenter: ProfilePresenter
  ) {}

  async recognizeIdCardFront(
    payload: Record<string, unknown>,
    context: RequestContext
  ) {
    const command = this.toCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireCurrentOrganizationScope(
      currentSession,
      command.organizationId
    );
    const view = await this.recognizeIdCardFrontForOrganization(
      scope.organization.id,
      command.idCardFrontFileId
    );
    return this.presenter.toPersonalCertificationIdCardOcr(view);
  }

  async recognizeIdCardFrontForOrganization(
    organizationId: string,
    idCardFrontFileId: string
  ): Promise<PersonalCertificationIdCardOcrView> {
    const fileAsset = await this.fileAssetRepository.findOneBy({
      id: idCardFrontFileId
    });
    if (!fileAsset) {
      throw personalCertificationOcrInvalid(
        'Personal certification OCR requires a confirmed id-card front file truth.'
      );
    }
    if (
      fileAsset.businessType !== 'profile' ||
      fileAsset.fileKind !== 'id_card_front' ||
      fileAsset.businessId !== organizationId ||
      fileAsset.organizationId !== organizationId
    ) {
      throw personalCertificationOcrInvalid(
        'Personal certification OCR id-card file does not belong to the current organization.'
      );
    }
    if (!fileAsset.mimeType.toLowerCase().startsWith('image/')) {
      throw personalCertificationOcrInvalid(
        'Personal certification OCR only supports image id-card files.'
      );
    }

    const accessUrl = await this.uploadPublicUrlService.buildObjectAccessUrl(
      fileAsset.objectKey
    );
    if (!accessUrl) {
      return this.manualRequired(
        '当前身份证正面 OCR 访问地址不可用，请重新上传清晰的身份证正面。',
        null
      );
    }

    const ocrResult = await this.ocrService.recognizeIdCardFront(accessUrl);
    if (ocrResult.status === 'disabled') {
      return this.manualRequired(
        '当前身份证 OCR 未开启，请稍后再试。',
        ocrResult.providerRequestId
      );
    }
    if (ocrResult.status === 'failed') {
      return this.manualRequired(
        '当前身份证 OCR 识别未完成，请重新上传清晰的身份证正面后再试。',
        ocrResult.providerRequestId
      );
    }
    if (!ocrResult.isFrontSide) {
      return this.manualRequired(
        '当前只支持身份证正面。请重新上传姓名和身份证号所在的正面照片。',
        ocrResult.providerRequestId
      );
    }
    if (!ocrResult.realName || !ocrResult.idNumber || !ocrResult.maskedIdNumber) {
      return this.manualRequired(
        '当前身份证 OCR 未能稳定提取姓名和身份证号，请重新上传清晰的身份证正面。',
        ocrResult.providerRequestId
      );
    }

    return {
      status: 'recognized',
      message: '当前已完成身份证正面 OCR，姓名与身份证号摘要已回填。',
      realName: ocrResult.realName,
      idNumberMasked: ocrResult.maskedIdNumber,
      providerRequestId: ocrResult.providerRequestId
    };
  }

  private toCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      organizationId: this.readRequiredString(source.organizationId, 'organizationId'),
      idCardFrontFileId: this.readRequiredString(
        source.idCardFrontFileId,
        'idCardFrontFileId'
      )
    } satisfies PersonalCertificationOcrCommand;
  }

  private asRecord(value: unknown) {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
      throw personalCertificationOcrInvalid(
        'Personal certification OCR body must be an object.'
      );
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw personalCertificationOcrInvalid(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private manualRequired(
    message: string,
    providerRequestId: string | null
  ): PersonalCertificationIdCardOcrView {
    return {
      status: 'manual_required',
      message,
      realName: null,
      idNumberMasked: null,
      providerRequestId
    };
  }
}
