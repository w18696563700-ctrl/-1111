import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { requireVerifiedCurrentSessionContext } from "../../shared/current-session-verification";
import { RequestContext } from "../../shared/request-context";
import { CurrentSessionVerificationService } from "../auth/current-session-verification.service";
import { ContentSafetyOcrService } from "../content_safety/content-safety-ocr.service";
import { CurrentActorEligibilityService } from "../organization/current-actor-eligibility.service";
import { OrganizationCertificationEntity } from "../organization/entities/organization-certification.entity";
import { FileAssetEntity } from "../upload/entities/file-asset.entity";
import { UploadPublicUrlService } from "../upload/upload-public-url.service";
import { certificationLicenseOcrInvalid } from "./profile.errors";
import { ProfilePresenter } from "./profile.presenter";

type CertificationLicenseOcrCommand = {
  organizationId: string;
  licenseFileId: string;
};

export type CertificationLicenseOcrView = {
  status: "recognized" | "partial" | "manual_required";
  message: string;
  legalName: string | null;
  uscc: string | null;
  legalPerson: string | null;
  businessType: string | null;
  address: string | null;
  registeredCapital: string | null;
  establishedAt: string | null;
  businessTerm: string | null;
  businessScope: string | null;
  providerRequestId: string | null;
};

@Injectable()
export class ProfileCertificationOcrService {
  constructor(
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly uploadPublicUrlService: UploadPublicUrlService,
    private readonly ocrService: ContentSafetyOcrService,
    private readonly presenter: ProfilePresenter,
  ) {}

  async recognizeLicense(
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    const command = this.toCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    const scope = await this.eligibilityService.requireOrganizationAdmin(
      currentSession,
      command.organizationId,
    );
    const result = await this.recognizeLicenseForOrganization(
      scope.organization.id,
      command.licenseFileId,
    );
    await this.persistCertificationSupplements(
      scope.organization.id,
      command.licenseFileId,
      result,
    );
    return this.presenter.toCertificationLicenseOcr(result);
  }

  async recognizeLicenseForOrganization(
    organizationId: string,
    licenseFileId: string,
  ): Promise<CertificationLicenseOcrView> {
    const fileAsset = await this.fileAssetRepository.findOneBy({
      id: licenseFileId,
    });
    if (!fileAsset) {
      throw certificationLicenseOcrInvalid(
        "Certification OCR requires a confirmed license file truth.",
      );
    }
    if (
      fileAsset.organizationId &&
      fileAsset.organizationId !== organizationId
    ) {
      throw certificationLicenseOcrInvalid(
        "Certification OCR license file does not belong to the current organization.",
      );
    }
    if (!fileAsset.mimeType.toLowerCase().startsWith("image/")) {
      throw certificationLicenseOcrInvalid(
        "Certification OCR only supports image license files.",
      );
    }

    const accessUrl = await this.uploadPublicUrlService.buildObjectAccessUrl(
      fileAsset.objectKey,
    );
    if (!accessUrl) {
      return this.manualRequired(
        "当前营业执照 OCR 访问地址不可用，请先手动填写认证信息。",
        null,
      );
    }

    const ocrResult = await this.ocrService.recognizeBusinessLicense(accessUrl);
    if (ocrResult.status === "disabled") {
      return this.manualRequired(
        "当前营业执照 OCR 未开启，请先手动填写认证信息。",
        ocrResult.providerRequestId,
      );
    }
    if (ocrResult.status === "failed") {
      return this.manualRequired(
        "当前营业执照 OCR 识别未完成，请先手动填写或稍后重试。",
        ocrResult.providerRequestId,
      );
    }

    const status =
      ocrResult.legalName && ocrResult.uscc
        ? "recognized"
        : ocrResult.legalName ||
            ocrResult.uscc ||
            ocrResult.legalPerson ||
            ocrResult.businessType ||
            ocrResult.address ||
            ocrResult.registeredCapital ||
            ocrResult.establishedAt ||
            ocrResult.businessTerm ||
            ocrResult.businessScope
          ? "partial"
          : "manual_required";
    const message =
      status == "recognized"
        ? "当前已完成营业执照 OCR 识别，认证主体和统一社会信用代码已自动回填。"
        : status == "partial"
          ? "当前已完成部分营业执照 OCR 识别，已回填可确认字段，其余字段请手动补充。"
          : "当前营业执照 OCR 未识别到可回填字段，请手动填写认证信息。";

    return {
      status,
      message,
      legalName: ocrResult.legalName,
      uscc: ocrResult.uscc,
      legalPerson: ocrResult.legalPerson,
      businessType: ocrResult.businessType,
      address: ocrResult.address,
      registeredCapital: ocrResult.registeredCapital,
      establishedAt: ocrResult.establishedAt,
      businessTerm: ocrResult.businessTerm,
      businessScope: ocrResult.businessScope,
      providerRequestId: ocrResult.providerRequestId,
    };
  }

  private toCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      organizationId: this.readRequiredString(
        source.organizationId,
        "organizationId",
      ),
      licenseFileId: this.readRequiredString(
        source.licenseFileId,
        "licenseFileId",
      ),
    } satisfies CertificationLicenseOcrCommand;
  }

  private asRecord(value: unknown) {
    if (!value || typeof value !== "object" || Array.isArray(value)) {
      throw certificationLicenseOcrInvalid(
        "Certification OCR body must be an object.",
      );
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== "string" || value.trim().length === 0) {
      throw certificationLicenseOcrInvalid(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private manualRequired(
    message: string,
    providerRequestId: string | null,
  ): CertificationLicenseOcrView {
    return {
      status: "manual_required",
      message,
      legalName: null,
      uscc: null,
      legalPerson: null,
      businessType: null,
      address: null,
      registeredCapital: null,
      establishedAt: null,
      businessTerm: null,
      businessScope: null,
      providerRequestId,
    };
  }

  private async persistCertificationSupplements(
    organizationId: string,
    licenseFileId: string,
    input: CertificationLicenseOcrView,
  ) {
    const address = this.readNullableText(input.address);
    const establishedAt = this.normalizeEstablishedAt(input.establishedAt);
    const legalPerson = this.readNullableText(input.legalPerson);
    const businessType = this.normalizeBusinessType(input.businessType);
    const registeredCapital = this.readNullableText(input.registeredCapital);
    const businessTerm = this.readNullableText(input.businessTerm);
    const businessScope = this.readNullableText(input.businessScope);
    if (
      !address &&
      !establishedAt &&
      !legalPerson &&
      !businessType &&
      !registeredCapital &&
      !businessTerm &&
      !businessScope
    ) {
      return;
    }

    const certification = await this.organizationCertificationRepository.findOne({
      where: { organizationId },
      order: { updatedAt: "DESC", createdAt: "DESC" },
    });
    if (!certification) {
      return;
    }
    if (
      certification.licenseFileId &&
      certification.licenseFileId !== licenseFileId
    ) {
      return;
    }
    if (
      certification.address === address &&
      certification.establishedAt === establishedAt &&
      certification.legalPerson === legalPerson &&
      certification.businessType === businessType &&
      certification.registeredCapital === registeredCapital &&
      certification.businessTerm === businessTerm &&
      certification.businessScope === businessScope
    ) {
      return;
    }
    certification.address = address;
    certification.establishedAt = establishedAt;
    certification.legalPerson = legalPerson;
    certification.businessType = businessType;
    certification.registeredCapital = registeredCapital;
    certification.businessTerm = businessTerm;
    certification.businessScope = businessScope;
    await this.organizationCertificationRepository.save(certification);
  }

  private readNullableText(value: string | null) {
    const normalized = value?.trim() ?? "";
    return normalized ? normalized : null;
  }

  private normalizeEstablishedAt(value: string | null) {
    const normalized = value?.trim() ?? "";
    if (!normalized) {
      return null;
    }
    const match =
      normalized.match(/^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$/u) ??
      normalized.match(/^(\d{4})年(\d{1,2})月(\d{1,2})日$/u);
    if (!match) {
      return null;
    }
    const [, year, month, day] = match;
    return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
  }

  private normalizeBusinessType(value: string | null) {
    const normalized = this.readNullableText(value);
    if (!normalized) {
      return null;
    }
    const compact = normalized.replace(/\s+/gu, "").toLowerCase();
    if (
      /^(qrcode|二维码|扫码|扫描码|条码|barcode|document|doctype|documenttype|scantype|scan|filetype|imagetype|picturetype)$/u.test(
        compact,
      ) ||
      /文档类型|扫描类型|版式标签|版面标签|识别类型/u.test(normalized)
    ) {
      return null;
    }
    return normalized;
  }
}
