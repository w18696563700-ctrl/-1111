import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { contactRequired } from './enterprise-hub.errors';
import { EnterpriseContactEntity } from './entities/enterprise-contact.entity';

@Injectable()
export class EnterpriseHubContactWriteService {
  constructor(
    @InjectRepository(EnterpriseContactEntity)
    private readonly contactRepository: Repository<EnterpriseContactEntity>,
  ) {}

  async upsertPrimaryContactFromApplication(
    enterpriseId: string,
    contactName: string,
    contactMobile: string,
  ) {
    const existing = await this.loadWritableContact(enterpriseId);
    await this.contactRepository.save(
      this.contactRepository.create({
        ...(existing ?? { id: randomUUID(), enterpriseId }),
        contactName,
        mobile: contactMobile,
        isPrimary: true,
        visibleToPublic: true,
      }),
    );
  }

  async upsertPrimaryContactFromBasic(
    enterpriseId: string,
    input: {
      contactName: string | null;
      contactMobile: string | null;
      defaultVisibleToPublic: boolean;
    },
  ) {
    const existing = await this.loadWritableContact(enterpriseId);
    const nextContactName = input.contactName ?? existing?.contactName?.trim() ?? null;
    const nextContactMobile = input.contactMobile ?? existing?.mobile?.trim() ?? null;
    if (!nextContactName || !nextContactMobile) {
      return;
    }

    await this.contactRepository.save(
      this.contactRepository.create({
        ...(existing ?? { id: randomUUID(), enterpriseId }),
        contactName: nextContactName,
        mobile: nextContactMobile,
        isPrimary: true,
        visibleToPublic: existing?.visibleToPublic ?? input.defaultVisibleToPublic,
      }),
    );
  }

  async ensureContactMinimum(enterpriseId: string) {
    const count = await this.contactRepository.count({
      where: [
        { enterpriseId, isPrimary: true },
        { enterpriseId, visibleToPublic: true },
      ],
    });
    if (count === 0) {
      throw contactRequired('At least one primary or public contact is required before submit.');
    }
  }

  private async loadWritableContact(enterpriseId: string) {
    const primary = await this.contactRepository.findOne({
      where: { enterpriseId, isPrimary: true },
      order: { id: 'ASC' },
    });
    if (primary) {
      return primary;
    }
    return this.contactRepository.findOne({
      where: { enterpriseId, visibleToPublic: true },
      order: { id: 'ASC' },
    });
  }
}
