import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { bidResourceUnavailable, bidSubmitInvalid } from './bid.errors';
import { bidSubmissionAttachmentSlots } from './bid-submission-attachment.support';

type SubmitBidAttachmentCommand = {
  projectUnderstandingFileAssetId: string;
  quoteSheetFileAssetId: string;
  schedulePlanFileAssetId: string;
};

@Injectable()
export class BidSubmissionAttachmentTruthService {
  constructor(
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
  ) {}

  async validateAndNormalize(
    command: SubmitBidAttachmentCommand,
    projectId: string,
    organizationId: string,
  ) {
    const requestedIds = bidSubmissionAttachmentSlots.map((slot) => command[slot.commandField]);
    if (new Set(requestedIds).size !== requestedIds.length) {
      throw bidSubmitInvalid('Bid submit attachments must use three distinct confirmed FileAsset ids.');
    }

    const fileAssets = await this.fileAssetRepository.findBy({ id: In(requestedIds) });
    const fileAssetMap = new Map(fileAssets.map((item) => [item.id, item]));

    for (const slot of bidSubmissionAttachmentSlots) {
      const fileAssetId = command[slot.commandField];
      const fileAsset = fileAssetMap.get(fileAssetId);
      if (!fileAsset) {
        throw bidResourceUnavailable(`Current ${slot.slotLabel} attachment is unavailable for bid submit.`);
      }
      if (fileAsset.organizationId !== organizationId) {
        throw bidSubmitInvalid(`Current ${slot.slotLabel} attachment does not belong to the active bidder organization.`);
      }
      if (fileAsset.businessType !== 'project' || fileAsset.businessId !== projectId) {
        throw bidSubmitInvalid(`Current ${slot.slotLabel} attachment is not bound to the current project.`);
      }
      if (fileAsset.fileKind !== slot.fileKind) {
        throw bidSubmitInvalid(`Current ${slot.slotLabel} attachment is bound with an unexpected file kind.`);
      }
    }

    return command;
  }
}
