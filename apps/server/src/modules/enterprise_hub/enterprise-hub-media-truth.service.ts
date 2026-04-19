import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { invalidMediaOwnership } from './enterprise-hub.errors';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseMediaAssetRefEntity } from './entities/enterprise-media-asset-ref.entity';

const ENTERPRISE_DISPLAY_IMAGE_FILE_KINDS = new Set([
  'enterprise_logo',
  'enterprise_album',
  'enterprise_factory_showcase',
  'enterprise_case_media',
  'enterprise_company_case_media',
  'enterprise_factory_case_media',
  'enterprise_supplier_case_media',
]);

const ENTERPRISE_DISPLAY_CASE_FILE_KINDS_BY_BOARD: Record<string, Set<string>> = {
  company: new Set(['enterprise_case_media', 'enterprise_company_case_media']),
  factory: new Set(['enterprise_case_media', 'enterprise_factory_case_media']),
  supplier: new Set(['enterprise_case_media', 'enterprise_supplier_case_media']),
};

type ListingBasicMediaInput = {
  logoFileAssetId: string | null;
  albumImageFileAssetIds: string[];
};

type CaseMediaInput = {
  caseCoverFileAssetId: string | null;
  caseMediaFileAssetIds: string[];
};

@Injectable()
export class EnterpriseHubMediaTruthService {
  constructor(
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    @InjectRepository(EnterpriseMediaAssetRefEntity)
    private readonly mediaAssetRefRepository: Repository<EnterpriseMediaAssetRefEntity>,
  ) {}

  async validateListingBasicMedia(
    listing: EnterpriseListingEntity,
    input: ListingBasicMediaInput,
  ) {
    await this.validateRoleAssets(listing, [input.logoFileAssetId], ['enterprise_logo'], 'listing logo');
    await this.validateRoleAssets(
      listing,
      input.albumImageFileAssetIds,
      ['enterprise_album'],
      'listing album',
    );
  }

  async validateFactoryShowcaseMedia(
    listing: EnterpriseListingEntity,
    showcaseImageFileAssetIds: string[],
  ) {
    await this.validateRoleAssets(
      listing,
      showcaseImageFileAssetIds,
      ['enterprise_factory_showcase'],
      'factory showcase',
    );
  }

  async validateCaseMedia(
    listing: EnterpriseListingEntity,
    input: CaseMediaInput,
  ) {
    const allowedFileKinds =
      ENTERPRISE_DISPLAY_CASE_FILE_KINDS_BY_BOARD[listing.primaryBoardType] ??
      ENTERPRISE_DISPLAY_CASE_FILE_KINDS_BY_BOARD.company;
    await this.validateRoleAssets(
      listing,
      [input.caseCoverFileAssetId, ...input.caseMediaFileAssetIds],
      [...allowedFileKinds],
      'enterprise case media',
    );
  }

  async syncListingBasicRefs(
    listing: EnterpriseListingEntity,
    input: ListingBasicMediaInput,
  ) {
    await this.replaceOwnerRefs(listing.id, 'enterprise_listing_basic', listing.id, [
      ...this.buildRefs('logo', input.logoFileAssetId ? [input.logoFileAssetId] : []),
      ...this.buildRefs('album', input.albumImageFileAssetIds),
    ]);
  }

  async syncFactoryShowcaseRefs(
    listing: EnterpriseListingEntity,
    showcaseImageFileAssetIds: string[],
  ) {
    await this.replaceOwnerRefs(
      listing.id,
      'enterprise_factory_profile',
      listing.id,
      this.buildRefs('showcase', showcaseImageFileAssetIds),
    );
  }

  async syncCaseRefs(
    listing: EnterpriseListingEntity,
    ownerType: string,
    ownerId: string,
    input: CaseMediaInput,
  ) {
    await this.replaceOwnerRefs(listing.id, ownerType, ownerId, [
      ...this.buildRefs('case_cover', input.caseCoverFileAssetId ? [input.caseCoverFileAssetId] : []),
      ...this.buildRefs('case_media', input.caseMediaFileAssetIds),
    ]);
  }

  async clearCaseRefs(enterpriseId: string, ownerType: string, ownerId: string) {
    await this.mediaAssetRefRepository.delete({
      enterpriseId,
      ownerType,
      ownerId,
    });
  }

  async clearEnterpriseRefs(enterpriseId: string) {
    await this.mediaAssetRefRepository.delete({ enterpriseId });
  }

  isEnterpriseDisplayImageFileAsset(fileAsset: FileAssetEntity | null) {
    if (!fileAsset?.objectKey) {
      return false;
    }
    const mimeType = fileAsset.mimeType?.toLowerCase() ?? '';
    if (!mimeType.startsWith('image/')) {
      return false;
    }
    if (
      fileAsset.businessType &&
      fileAsset.businessType !== 'enterprise_display'
    ) {
      return false;
    }
    if (
      fileAsset.fileKind &&
      !ENTERPRISE_DISPLAY_IMAGE_FILE_KINDS.has(fileAsset.fileKind)
    ) {
      return false;
    }
    return true;
  }

  private async validateRoleAssets(
    listing: EnterpriseListingEntity,
    fileAssetIds: Array<string | null | undefined>,
    allowedFileKinds: string[],
    label: string,
  ) {
    const normalizedIds = [
      ...new Set(
        fileAssetIds.flatMap((item) => {
          const fileAssetId = this.normalizeFileAssetId(item);
          return fileAssetId ? [fileAssetId] : [];
        }),
      ),
    ];
    if (!normalizedIds.length) {
      return;
    }
    const fileAssets = await this.fileAssetRepository.findBy({
      id: In(normalizedIds),
    });
    const fileAssetMap = new Map(fileAssets.map((item) => [item.id, item]));

    for (const fileAssetId of normalizedIds) {
      const fileAsset = fileAssetMap.get(fileAssetId);
      if (!fileAsset) {
        throw invalidMediaOwnership(`Current ${label} FileAsset is missing from enterprise display truth.`);
      }
      const mimeType = fileAsset.mimeType?.toLowerCase() ?? '';
      if (
        fileAsset.businessType !== 'enterprise_display' ||
        fileAsset.businessId !== listing.id ||
        fileAsset.organizationId !== listing.organizationId ||
        !allowedFileKinds.includes(fileAsset.fileKind) ||
        !mimeType.startsWith('image/')
      ) {
        throw invalidMediaOwnership(
          `Current ${label} FileAsset does not belong to the current enterprise display scope.`,
        );
      }
    }
  }

  private async replaceOwnerRefs(
    enterpriseId: string,
    ownerType: string,
    ownerId: string,
    entries: Array<{ mediaRole: string; fileAssetId: string; sortOrder: number | null }>,
  ) {
    await this.mediaAssetRefRepository.delete({
      enterpriseId,
      ownerType,
      ownerId,
    });
    for (const entry of entries) {
      await this.mediaAssetRefRepository.save(
        this.mediaAssetRefRepository.create({
          id: randomUUID(),
          enterpriseId,
          ownerType,
          ownerId,
          mediaRole: entry.mediaRole,
          fileAssetId: entry.fileAssetId,
          sortOrder: entry.sortOrder,
        }),
      );
    }
  }

  private buildRefs(mediaRole: string, fileAssetIds: string[]) {
    return fileAssetIds
      .flatMap((item, index) => {
        const fileAssetId = this.normalizeFileAssetId(item);
        if (!fileAssetId) {
          return [];
        }
        return [
          {
            mediaRole,
            fileAssetId,
            sortOrder: mediaRole === 'case_cover' || mediaRole === 'logo' ? null : index,
          },
        ];
      });
  }

  private normalizeFileAssetId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}
