import {
  CounterpartConversationBusinessCardProjection,
  CounterpartConversationCertificationSummaryProjection,
} from './counterpart-conversation.types';

export type CounterpartConversationCardSeed = {
  counterpartOrganizationId: string;
  counterpartDisplayName: string;
  counterpartNickname: string | null;
  counterpartCompanyName: string;
  counterpartAvatarUrl: string | null;
  counterpartCertificationSummary: CounterpartConversationCertificationSummaryProjection | null;
  projectId: string;
  pricingSummary?: Record<string, unknown>;
  updatedAt: string;
  card: CounterpartConversationBusinessCardProjection;
};

export interface CounterpartConversationCardSource {
  buildSeeds(viewerOrganizationId: string): Promise<CounterpartConversationCardSeed[]>;
}
