import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseRecommendationSlotEntity } from './entities/enterprise-recommendation-slot.entity';

@Injectable()
export class EnterpriseHubAutoSlotService {
  constructor(
    @InjectRepository(EnterpriseRecommendationSlotEntity)
    private readonly recommendationSlotRepository: Repository<EnterpriseRecommendationSlotEntity>,
  ) {}

  async ensureFactoryRecommendationSlot(
    listing: EnterpriseListingEntity,
    now: Date,
  ) {
    if (
      listing.primaryBoardType !== 'factory' ||
      listing.enterpriseStatus !== 'published' ||
      listing.displayStatus !== 'visible'
    ) {
      return false;
    }
    const startAt = now;
    const endAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
    const activeOrPending = await this.recommendationSlotRepository.findBy({
      boardType: 'factory',
      slotStatus: In(['pending', 'active']),
    });
    if (
      activeOrPending.some(
        (item) => item.enterpriseId === listing.id && item.endAt > startAt,
      )
    ) {
      return true;
    }
    const slotPosition = [1, 2, 3].find(
      (candidate) =>
        !activeOrPending.some(
          (item) =>
            item.slotPosition === candidate &&
            !(item.endAt <= startAt || item.startAt >= endAt),
        ),
    );
    if (slotPosition == null) {
      return false;
    }
    const slot = this.recommendationSlotRepository.create({
      id: randomUUID(),
      boardType: 'factory',
      slotPosition,
      enterpriseId: listing.id,
      startAt,
      endAt,
      sourceType: 'auto_review',
      scoreSnapshot: null,
      slotStatus: 'active',
    });
    await this.recommendationSlotRepository.save(slot);
    return true;
  }
}
