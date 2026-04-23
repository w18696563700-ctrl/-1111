import { Injectable } from '@nestjs/common';

type CounterpartSummary = {
  organizationId: string;
  displayName: string;
  avatarUrl: string | null;
  role: 'project_owner' | 'bidder';
};

type RouteTarget = {
  objectType: string;
  actionKey: string;
  canonicalPath: string;
  params: Record<string, string>;
};

type SeedSummary = {
  seedType: 'bid_submitted';
  title: string;
  summary: string;
  ctaLabel: string;
};

@Injectable()
export class MessageInteractionPresenter {
  toListResponse(
    lane: 'project_communication',
    items: Array<{
      interactionId: string;
      interactionType: 'bid_thread';
      threadId: string;
      projectId: string;
      bidId: string;
      counterpart: CounterpartSummary;
      seedSummary: SeedSummary;
      lastMessageSummary: string;
      updatedAt: string;
      routeTarget: RouteTarget;
    }>,
  ) {
    return {
      lane,
      items,
    };
  }
}
