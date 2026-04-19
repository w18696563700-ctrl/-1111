import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { EnterpriseListingEntity } from '../enterprise_hub/entities/enterprise-listing.entity';
import { FileAssetEntity } from './entities/file-asset.entity';
import { UploadSessionEntity } from './entities/upload-session.entity';
import { uploadInitInvalid, uploadSessionMissingFileAssetTruth } from './upload.errors';

@Injectable()
export class UploadEnterpriseDisplayBindingService {
  constructor(
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
  ) {}

  async loadOwnedListingForInit(
    businessId: string | null,
    context: RequestContext,
    manager?: EntityManager,
  ) {
    const organizationId = this.requireOrganizationScope(context);
    const enterpriseId = this.requireBusinessIdForInit(businessId);
    const repository =
      manager?.getRepository(EnterpriseListingEntity) ?? this.listingRepository;
    const listing = await repository.findOneBy({ id: enterpriseId });
    if (!listing || listing.organizationId !== organizationId) {
      throw uploadInitInvalid(
        'Current enterprise display upload must bind to a listing owned by the current organization.',
      );
    }
    return listing;
  }

  async loadOwnedListingForConfirm(
    session: UploadSessionEntity,
    context: RequestContext,
    manager?: EntityManager,
  ) {
    const organizationId = this.requireOrganizationScope(context);
    const enterpriseId = this.requireBusinessIdForConfirm(session.businessId);
    const repository =
      manager?.getRepository(EnterpriseListingEntity) ?? this.listingRepository;
    const listing = await repository.findOneBy({ id: enterpriseId });
    if (!listing || listing.organizationId !== organizationId) {
      throw uploadSessionMissingFileAssetTruth(
        'Current enterprise display upload session does not belong to the current organization.',
      );
    }
    return listing;
  }

  ensureFileAsset(
    fileAsset: FileAssetEntity,
    session: UploadSessionEntity,
    listing: EnterpriseListingEntity | null,
  ) {
    if (session.businessType !== 'enterprise_display' || listing == null) {
      return;
    }
    if (
      fileAsset.businessType !== 'enterprise_display' ||
      fileAsset.businessId !== listing.id ||
      fileAsset.organizationId !== listing.organizationId ||
      !fileAsset.mimeType.toLowerCase().startsWith('image/')
    ) {
      throw uploadSessionMissingFileAssetTruth(
        'Current enterprise display FileAsset truth is not aligned with the upload session.',
      );
    }
  }

  private requireOrganizationScope(context: RequestContext) {
    const organizationId = context.organizationId?.trim() ?? '';
    if (!organizationId) {
      throw uploadInitInvalid(
        'Current enterprise display upload requires an active organization scope.',
      );
    }
    return organizationId;
  }

  private requireBusinessIdForInit(businessId: string | null) {
    const enterpriseId = businessId?.trim() ?? '';
    if (!enterpriseId) {
      throw uploadInitInvalid(
        'Current enterprise display upload requires an enterprise listing id.',
      );
    }
    return enterpriseId;
  }

  private requireBusinessIdForConfirm(businessId: string | null) {
    const enterpriseId = businessId?.trim() ?? '';
    if (!enterpriseId) {
      throw uploadSessionMissingFileAssetTruth(
        'Current enterprise display upload session is missing enterprise listing truth.',
      );
    }
    return enterpriseId;
  }
}
