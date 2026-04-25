import { Injectable } from '@nestjs/common';

type MyBidListItem = {
  bidId: string;
  projectId: string;
  projectNo: string;
  projectTitle: string;
  quoteAmount: number;
  proposalSummaryPreview: string;
  submittedAt: string;
  outcomeState: string;
  canOpenBidThread: boolean;
  canOpenBidResult: boolean;
  snapshotReadable: boolean;
};

type BidSubmissionAttachmentItem = {
  slotKey: string;
  slotLabel: string;
  fileAssetId: string;
  fileKind: string;
  mimeType: string;
};

@Injectable()
export class MyBidPresenter {
  toListResponse(items: MyBidListItem[]) {
    return {
      items,
    };
  }

  toSnapshot(input: {
    projectId: string;
    bidId: string;
    bidder: {
      organizationId: string;
      displayName: string;
      avatarUrl: string | null;
    };
    submittedAt: Date;
    quoteAmount: number;
    proposalSummary: string;
    attachmentSummary: {
      count: number;
    };
    attachments: BidSubmissionAttachmentItem[];
    availability: Record<string, unknown>;
  }) {
    return {
      projectId: input.projectId,
      bidId: input.bidId,
      bidder: input.bidder,
      submittedAt: input.submittedAt.toISOString(),
      quoteAmount: input.quoteAmount,
      proposalSummary: input.proposalSummary,
      attachmentSummary: input.attachmentSummary,
      attachments: input.attachments,
      availability: input.availability,
    };
  }
}
