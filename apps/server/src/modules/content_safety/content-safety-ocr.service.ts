import { Injectable, Logger } from "@nestjs/common";
import OcrClient, {
  RecognizeBusinessLicenseRequest,
  RecognizeGeneralRequest,
  RecognizeIdcardRequest,
} from "@alicloud/ocr-api20210707";
import { $OpenApiUtil } from "@alicloud/openapi-core";
import { RuntimeConfigService } from "../../core/runtime-config.service";

export type ContentSafetyOcrResult =
  | {
      status: "disabled";
      extractedText: "";
      providerRequestId: null;
      errorCode: "ocr_disabled";
      errorMessage: string;
    }
  | {
      status: "failed";
      extractedText: "";
      providerRequestId: string | null;
      errorCode: string;
      errorMessage: string;
    }
  | {
      status: "succeeded";
      extractedText: string;
      providerRequestId: string | null;
      errorCode: null;
      errorMessage: null;
    };

export type BusinessLicenseOcrResult =
  | {
      status: "disabled";
      legalName: null;
      uscc: null;
      legalPerson: null;
      businessType: null;
      address: null;
      registeredCapital: null;
      establishedAt: null;
      businessTerm: null;
      businessScope: null;
      extractedText: "";
      providerRequestId: null;
      errorCode: "ocr_disabled";
      errorMessage: string;
    }
  | {
      status: "failed";
      legalName: null;
      uscc: null;
      legalPerson: null;
      businessType: null;
      address: null;
      registeredCapital: null;
      establishedAt: null;
      businessTerm: null;
      businessScope: null;
      extractedText: "";
      providerRequestId: string | null;
      errorCode: string;
      errorMessage: string;
    }
  | {
      status: "succeeded";
      legalName: string | null;
      uscc: string | null;
      legalPerson: string | null;
      businessType: string | null;
      address: string | null;
      registeredCapital: string | null;
      establishedAt: string | null;
      businessTerm: string | null;
      businessScope: string | null;
      extractedText: string;
      providerRequestId: string | null;
      errorCode: null;
      errorMessage: null;
    };

export type IdCardOcrResult =
  | {
      status: "disabled";
      realName: null;
      idNumber: null;
      maskedIdNumber: null;
      isFrontSide: null;
      extractedText: "";
      providerRequestId: null;
      errorCode: "ocr_disabled";
      errorMessage: string;
    }
  | {
      status: "failed";
      realName: null;
      idNumber: null;
      maskedIdNumber: null;
      isFrontSide: null;
      extractedText: "";
      providerRequestId: string | null;
      errorCode: string;
      errorMessage: string;
    }
  | {
      status: "succeeded";
      realName: string | null;
      idNumber: string | null;
      maskedIdNumber: string | null;
      isFrontSide: boolean;
      extractedText: string;
      providerRequestId: string | null;
      errorCode: null;
      errorMessage: null;
    };

@Injectable()
export class ContentSafetyOcrService {
  private readonly logger = new Logger(ContentSafetyOcrService.name);
  private client: OcrClient | null = null;

  constructor(private readonly config: RuntimeConfigService) {}

  async recognizeGeneralText(
    imageUrl: string,
  ): Promise<ContentSafetyOcrResult> {
    if (!this.isEnabled()) {
      return {
        status: "disabled",
        extractedText: "",
        providerRequestId: null,
        errorCode: "ocr_disabled",
        errorMessage: "Alibaba Cloud OCR stopgap is disabled or incomplete.",
      };
    }
    try {
      const request = new RecognizeGeneralRequest({ url: imageUrl });
      const response = await this.getClient().recognizeGeneral(request);
      const responseCode = response.body?.code?.trim() ?? "";
      const responseMessage = response.body?.message?.trim() ?? "";
      if (responseCode && responseCode !== "200") {
        return {
          status: "failed",
          extractedText: "",
          providerRequestId: response.body?.requestId ?? null,
          errorCode: responseCode,
          errorMessage:
            responseMessage ||
            "Alibaba Cloud OCR returned a non-success business code.",
        };
      }
      return {
        status: "succeeded",
        extractedText: this.extractText(response.body?.data),
        providerRequestId: response.body?.requestId ?? null,
        errorCode: null,
        errorMessage: null,
      };
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : "Alibaba Cloud OCR request failed.";
      this.logger.warn(`recognizeGeneralText failed: ${message}`);
      return {
        status: "failed",
        extractedText: "",
        providerRequestId: null,
        errorCode: "ocr_request_failed",
        errorMessage: message,
      };
    }
  }

  async recognizeBusinessLicense(
    imageUrl: string,
  ): Promise<BusinessLicenseOcrResult> {
    if (!this.isEnabled()) {
      return {
        status: "disabled",
        legalName: null,
        uscc: null,
        legalPerson: null,
        businessType: null,
        address: null,
        registeredCapital: null,
        establishedAt: null,
        businessTerm: null,
        businessScope: null,
        extractedText: "",
        providerRequestId: null,
        errorCode: "ocr_disabled",
        errorMessage: "Alibaba Cloud OCR stopgap is disabled or incomplete.",
      };
    }
    try {
      const request = new RecognizeBusinessLicenseRequest({ url: imageUrl });
      const response = await this.getClient().recognizeBusinessLicense(request);
      const responseCode = response.body?.code?.trim() ?? "";
      const responseMessage = response.body?.message?.trim() ?? "";
      if (responseCode && responseCode !== "200") {
        return {
          status: "failed",
          legalName: null,
          uscc: null,
          legalPerson: null,
          businessType: null,
          address: null,
          registeredCapital: null,
          establishedAt: null,
          businessTerm: null,
          businessScope: null,
          extractedText: "",
          providerRequestId: response.body?.requestId ?? null,
          errorCode: responseCode,
          errorMessage:
            responseMessage ||
            "Alibaba Cloud business license OCR returned a non-success business code.",
        };
      }
      const parsed = this.parseBusinessLicenseData(response.body?.data);
      return {
        status: "succeeded",
        legalName: parsed.legalName,
        uscc: parsed.uscc,
        legalPerson: parsed.legalPerson,
        businessType: parsed.businessType,
        address: parsed.address,
        registeredCapital: parsed.registeredCapital,
        establishedAt: parsed.establishedAt,
        businessTerm: parsed.businessTerm,
        businessScope: parsed.businessScope,
        extractedText: parsed.extractedText,
        providerRequestId: response.body?.requestId ?? null,
        errorCode: null,
        errorMessage: null,
      };
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : "Alibaba Cloud business license OCR request failed.";
      this.logger.warn(`recognizeBusinessLicense failed: ${message}`);
      return {
        status: "failed",
        legalName: null,
        uscc: null,
        legalPerson: null,
        businessType: null,
        address: null,
        registeredCapital: null,
        establishedAt: null,
        businessTerm: null,
        businessScope: null,
        extractedText: "",
        providerRequestId: null,
        errorCode: "ocr_request_failed",
        errorMessage: message,
      };
    }
  }

  async recognizeIdCardFront(imageUrl: string): Promise<IdCardOcrResult> {
    if (!this.isEnabled()) {
      return {
        status: "disabled",
        realName: null,
        idNumber: null,
        maskedIdNumber: null,
        isFrontSide: null,
        extractedText: "",
        providerRequestId: null,
        errorCode: "ocr_disabled",
        errorMessage: "Alibaba Cloud OCR stopgap is disabled or incomplete.",
      };
    }
    try {
      const request = new RecognizeIdcardRequest({
        url: imageUrl,
        outputFigure: false,
        outputQualityInfo: false,
      });
      const response = await this.getClient().recognizeIdcard(request);
      const responseCode = response.body?.code?.trim() ?? "";
      const responseMessage = response.body?.message?.trim() ?? "";
      if (responseCode && responseCode !== "200") {
        return {
          status: "failed",
          realName: null,
          idNumber: null,
          maskedIdNumber: null,
          isFrontSide: null,
          extractedText: "",
          providerRequestId: response.body?.requestId ?? null,
          errorCode: responseCode,
          errorMessage:
            responseMessage ||
            "Alibaba Cloud id-card OCR returned a non-success business code.",
        };
      }
      const parsed = this.parseIdCardData(response.body?.data);
      return {
        status: "succeeded",
        realName: parsed.realName,
        idNumber: parsed.idNumber,
        maskedIdNumber: parsed.maskedIdNumber,
        isFrontSide: parsed.isFrontSide,
        extractedText: parsed.extractedText,
        providerRequestId: response.body?.requestId ?? null,
        errorCode: null,
        errorMessage: null,
      };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Alibaba Cloud id-card OCR request failed.";
      this.logger.warn(`recognizeIdCardFront failed: ${message}`);
      return {
        status: "failed",
        realName: null,
        idNumber: null,
        maskedIdNumber: null,
        isFrontSide: null,
        extractedText: "",
        providerRequestId: null,
        errorCode: "ocr_request_failed",
        errorMessage: message,
      };
    }
  }

  private isEnabled() {
    return (
      this.config.aliyunOcrEnabled &&
      Boolean(this.config.aliyunOcrAccessKeyId.trim()) &&
      Boolean(this.config.aliyunOcrAccessKeySecret.trim()) &&
      Boolean(this.config.aliyunOcrEndpoint.trim())
    );
  }

  private getClient() {
    if (this.client) {
      return this.client;
    }
    this.client = new OcrClient(
      new $OpenApiUtil.Config({
        accessKeyId: this.config.aliyunOcrAccessKeyId,
        accessKeySecret: this.config.aliyunOcrAccessKeySecret,
        regionId: this.config.aliyunOcrRegionId,
        endpoint: this.config.aliyunOcrEndpoint,
        connectTimeout: this.config.aliyunOcrConnectTimeoutMs,
        readTimeout: this.config.aliyunOcrReadTimeoutMs,
      }),
    );
    return this.client;
  }

  private extractText(data: string | undefined) {
    const normalized = data?.trim() ?? "";
    if (!normalized) {
      return "";
    }
    try {
      const parsed = JSON.parse(normalized) as Record<string, unknown>;
      return this.normalizeExtractedText(this.readContentFromPayload(parsed));
    } catch {
      return this.normalizeExtractedText(normalized);
    }
  }

  private parseBusinessLicenseData(data: string | undefined) {
    const normalized = data?.trim() ?? "";
    if (!normalized) {
      return {
        legalName: null,
        uscc: null,
        legalPerson: null,
        businessType: null,
        address: null,
        registeredCapital: null,
        establishedAt: null,
        businessTerm: null,
        businessScope: null,
        extractedText: "",
      };
    }
    try {
      const parsed = JSON.parse(normalized) as Record<string, unknown>;
      const flattened = this.collectNamedValues(parsed);
      const extractedText = this.normalizeExtractedText(
        [...flattened.values()].join(" "),
      );
      return {
        legalName: this.pickBusinessLicenseValue(flattened, [
          "companyname",
          "enterprisename",
          "unitname",
          "name",
          "企业名称",
          "公司名称",
          "名称",
          "单位名称",
        ]),
        uscc:
          this.pickUscc(
            this.pickBusinessLicenseValue(flattened, [
              "creditcode",
              "socialcreditcode",
              "uniformsocialcreditcode",
              "统一社会信用代码",
              "社会信用代码",
              "注册号",
            ]),
          ) ?? this.pickUscc(extractedText),
        legalPerson: this.pickBusinessLicenseValue(flattened, [
          "legalperson",
          "法人",
          "法人代表",
          "法定代表人",
        ]),
        businessType: this.pickBusinessLicenseBusinessType(flattened),
        address: this.pickBusinessLicenseValue(flattened, [
          "businessaddress",
          "registeredaddress",
          "address",
          "addr",
          "住所",
          "营业场所",
          "经营场所",
          "企业住所",
          "注册地址",
        ]),
        registeredCapital: this.pickBusinessLicenseValue(flattened, [
          "capital",
          "registeredcaptial",
          "registeredcapital",
          "注册资本",
        ]),
        establishedAt: this.pickBusinessLicenseValue(flattened, [
          "registrationdate",
          "dateofregistration",
          "dateofestablishment",
          "establishdate",
          "registerdate",
          "成立日期",
          "成立时间",
          "注册日期",
        ]),
        businessTerm: this.pickBusinessLicenseValue(flattened, [
          "validperiod",
          "businessterm",
          "operatingperiod",
          "营业期限",
          "经营期限",
          "期限",
        ]),
        businessScope: this.pickBusinessLicenseValue(flattened, [
          "business",
          "businessscope",
          "scope",
          "经营范围",
          "业务范围",
        ]),
        extractedText,
      };
    } catch {
      return {
        legalName: null,
        uscc: this.pickUscc(normalized),
        legalPerson: null,
        businessType: null,
        address: null,
        registeredCapital: null,
        establishedAt: null,
        businessTerm: null,
        businessScope: null,
        extractedText: this.normalizeExtractedText(normalized),
      };
    }
  }

  private parseIdCardData(data: string | undefined) {
    const normalized = data?.trim() ?? "";
    if (!normalized) {
      return {
        realName: null,
        idNumber: null,
        maskedIdNumber: null,
        isFrontSide: false,
        extractedText: "",
      };
    }
    try {
      const parsed = JSON.parse(normalized) as Record<string, unknown>;
      const flattened = this.collectNamedValues(parsed);
      const extractedText = this.normalizeExtractedText(
        [...flattened.values()].join(" "),
      );
      const realName = this.pickIdCardValue(flattened, [
        "name",
        "姓名",
        "持证人",
      ]);
      const idNumber =
        this.normalizeIdNumber(
          this.pickIdCardValue(flattened, [
            "num",
            "idnumber",
            "身份证号",
            "身份证号码",
            "公民身份号码",
          ]),
        ) ?? this.pickIdNumber(extractedText);
      const backOnlyField =
        this.pickIdCardValue(flattened, [
          "issueauthority",
          "签发机关",
          "validdate",
          "有效期限",
          "startdate",
          "enddate",
        ]) !=
        null;
      return {
        realName,
        idNumber,
        maskedIdNumber: this.maskIdNumber(idNumber),
        isFrontSide: Boolean(realName && idNumber) && !backOnlyField,
        extractedText,
      };
    } catch {
      const idNumber = this.pickIdNumber(normalized);
      return {
        realName: null,
        idNumber,
        maskedIdNumber: this.maskIdNumber(idNumber),
        isFrontSide: false,
        extractedText: this.normalizeExtractedText(normalized),
      };
    }
  }

  private collectNamedValues(
    value: unknown,
    target: Map<string, string> = new Map<string, string>(),
  ) {
    if (typeof value === "string") {
      return target;
    }
    if (Array.isArray(value)) {
      for (const item of value) {
        if (item && typeof item === "object") {
          const record = item as Record<string, unknown>;
          const key = record.key;
          const fieldValue = record.value;
          if (typeof key === "string" && typeof fieldValue === "string") {
            this.writeNamedValue(target, key, fieldValue);
          }
        }
        this.collectNamedValues(item, target);
      }
      return target;
    }
    if (!value || typeof value !== "object") {
      return target;
    }

    for (const [key, nested] of Object.entries(
      value as Record<string, unknown>,
    )) {
      if (typeof nested === "string") {
        this.writeNamedValue(target, key, nested);
      }
      this.collectNamedValues(nested, target);
    }
    return target;
  }

  private writeNamedValue(
    target: Map<string, string>,
    key: string,
    value: string,
  ) {
    const normalizedKey = this.normalizeBusinessLicenseKey(key);
    const normalizedValue = this.normalizeExtractedText(value);
    if (!normalizedKey || !normalizedValue || target.has(normalizedKey)) {
      return;
    }
    target.set(normalizedKey, normalizedValue);
  }

  private pickBusinessLicenseValue(
    target: Map<string, string>,
    keys: string[],
  ) {
    for (const key of keys) {
      const direct = target.get(this.normalizeBusinessLicenseKey(key));
      if (direct) {
        return direct;
      }
    }
    return null;
  }

  private pickIdCardValue(target: Map<string, string>, keys: string[]) {
    for (const key of keys) {
      const direct = target.get(this.normalizeBusinessLicenseKey(key));
      if (direct) {
        return direct;
      }
    }
    return null;
  }

  private pickBusinessLicenseBusinessType(target: Map<string, string>) {
    const candidate = this.pickBusinessLicenseValue(target, [
      "type",
      "companytype",
      "enterprisetype",
      "主体类型",
      "企业类型",
      "公司类型",
    ]);
    return this.normalizeBusinessTypePreview(candidate);
  }

  private normalizeBusinessTypePreview(value: string | null) {
    const normalized = this.normalizeExtractedText(value ?? "");
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

  private pickUscc(source: string | null) {
    const normalized = source?.toUpperCase().replace(/[^0-9A-Z]/gu, "") ?? "";
    if (!/^[0-9A-Z]{18}$/u.test(normalized)) {
      return null;
    }
    return normalized;
  }

  private pickIdNumber(source: string | null) {
    const normalized = source?.toUpperCase().replace(/[^0-9X]/gu, "") ?? "";
    const match = normalized.match(/\d{17}[0-9X]/u);
    return match ? match[0] : null;
  }

  private normalizeIdNumber(value: string | null) {
    const normalized = value?.toUpperCase().replace(/[^0-9X]/gu, "") ?? "";
    if (/^\d{17}[0-9X]$/u.test(normalized)) {
      return normalized;
    }
    return null;
  }

  private maskIdNumber(value: string | null) {
    const normalized = this.normalizeIdNumber(value);
    if (!normalized) {
      return null;
    }
    return `${normalized.slice(0, 6)}********${normalized.slice(-4)}`;
  }

  private normalizeBusinessLicenseKey(value: string) {
    return value
      .trim()
      .replace(/[\s_\-:：]/gu, "")
      .toLowerCase();
  }

  private readContentFromPayload(payload: Record<string, unknown>) {
    const content = payload.content;
    if (typeof content === "string") {
      return content;
    }
    const prismWords = payload.prism_wordsInfo;
    if (Array.isArray(prismWords)) {
      return prismWords
        .map((item) => {
          if (!item || typeof item !== "object") {
            return "";
          }
          const word = (item as Record<string, unknown>).word;
          return typeof word === "string" ? word : "";
        })
        .filter(Boolean)
        .join(" ");
    }
    return "";
  }

  private normalizeExtractedText(value: string) {
    return value.replace(/\s+/gu, " ").trim();
  }
}
