import { CounterpartConversationBusinessCardProjection } from './counterpart-conversation.types';

export type CounterpartConversationCardSeed = {
  counterpartOrganizationId: string;
  counterpartDisplayName: string;
  counterpartAvatarUrl: string | null;
  projectId: string;
  p0PaySummary?: Record<string, unknown>;
  updatedAt: string;
  card: CounterpartConversationBusinessCardProjection;
};

export interface CounterpartConversationCardSource {
  buildSeeds(viewerOrganizationId: string): Promise<CounterpartConversationCardSeed[]>;
}
