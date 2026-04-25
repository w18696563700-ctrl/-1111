import { BidEntity } from './entities/bid.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';

export type BidSubmissionAttachmentSlotKey =
  | 'project_understanding'
  | 'quote_sheet'
  | 'schedule_plan';

type BidSubmissionAttachmentSlot = {
  commandField: 'projectUnderstandingFileAssetId' | 'quoteSheetFileAssetId' | 'schedulePlanFileAssetId';
  bidField: 'projectUnderstandingFileAssetId' | 'quoteSheetFileAssetId' | 'schedulePlanFileAssetId';
  slotKey: BidSubmissionAttachmentSlotKey;
  slotLabel: string;
  fileKind: string;
};

export const bidSubmissionAttachmentSlots: BidSubmissionAttachmentSlot[] = [
  {
    commandField: 'projectUnderstandingFileAssetId',
    bidField: 'projectUnderstandingFileAssetId',
    slotKey: 'project_understanding',
    slotLabel: '项目理解',
    fileKind: 'bid_project_understanding',
  },
  {
    commandField: 'quoteSheetFileAssetId',
    bidField: 'quoteSheetFileAssetId',
    slotKey: 'quote_sheet',
    slotLabel: '报价表',
    fileKind: 'bid_quote_sheet',
  },
  {
    commandField: 'schedulePlanFileAssetId',
    bidField: 'schedulePlanFileAssetId',
    slotKey: 'schedule_plan',
    slotLabel: '进度安排',
    fileKind: 'bid_schedule_plan',
  },
];

export type BidSubmissionAttachmentCarrier = {
  slotKey: BidSubmissionAttachmentSlotKey;
  slotLabel: string;
  fileAssetId: string;
  fileKind: string;
  mimeType: string;
};

export function buildBidSubmissionSnapshotAttachments(
  bid: BidEntity,
  fileAssetMap: Map<string, FileAssetEntity>,
) {
  return bidSubmissionAttachmentSlots.flatMap((slot) => {
    const fileAssetId = bid[slot.bidField]?.trim() ?? '';
    if (!fileAssetId) {
      return [];
    }
    const fileAsset = fileAssetMap.get(fileAssetId);
    if (!fileAsset) {
      return [];
    }
    return [
      {
        slotKey: slot.slotKey,
        slotLabel: slot.slotLabel,
        fileAssetId,
        fileKind: fileAsset.fileKind,
        mimeType: fileAsset.mimeType,
      } satisfies BidSubmissionAttachmentCarrier,
    ];
  });
}
