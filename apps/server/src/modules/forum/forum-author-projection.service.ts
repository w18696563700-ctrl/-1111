import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';

export type ForumAuthorSnapshot = {
  authorId: string;
  displayName: string;
  avatarUrl: string | null;
  organizationName: string | null;
};

type AuthorRecord = {
  id: string;
  authorUserId: string;
  organizationId: string;
};

@Injectable()
export class ForumAuthorProjectionService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    private readonly avatarUrlService: UploadPublicUrlService
  ) {}

  async buildAuthorSnapshotMap(records: AuthorRecord[]) {
    const authorIds = [...new Set(records.map((item) => item.authorUserId))];
    const organizationIds = [...new Set(records.map((item) => item.organizationId))];
    const [users, organizations] = await Promise.all([
      authorIds.length ? this.userRepository.findBy({ id: In(authorIds) }) : [],
      organizationIds.length ? this.organizationRepository.findBy({ id: In(organizationIds) }) : []
    ]);
    const userMap = new Map<string, UserEntity>(
      users.map((item): [string, UserEntity] => [item.id, item])
    );
    const organizationMap = new Map<string, OrganizationEntity>(
      organizations.map((item): [string, OrganizationEntity] => [item.id, item])
    );

    const entries = await Promise.all(
      records.map(async (record) => {
        const user = userMap.get(record.authorUserId);
        if (!user) {
          return null;
        }
        return [
          record.id,
          await this.toAuthorSnapshot(user, organizationMap.get(record.organizationId) ?? null)
        ] as const;
      })
    );
    return new Map(
      entries.filter((item): item is readonly [string, ForumAuthorSnapshot] => Boolean(item))
    );
  }

  async toAuthorSnapshot(user: UserEntity, organization: OrganizationEntity | null) {
    return {
      authorId: user.id,
      displayName: this.toDisplayName(user),
      avatarUrl: await this.readAvatarUrl(user.avatarUrl),
      organizationName: organization?.name ?? null
    } satisfies ForumAuthorSnapshot;
  }

  private async readAvatarUrl(rawAvatarUrl: string | null) {
    const normalized = rawAvatarUrl?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    return (await this.avatarUrlService.buildAccessUrlFromObjectUrl(normalized)) ?? normalized;
  }

  private toDisplayName(user: UserEntity) {
    const nickname = user.nickname?.trim();
    if (nickname) {
      return nickname;
    }
    const mobileSuffix = user.mobile.trim().slice(-4);
    return mobileSuffix ? `用户${mobileSuffix}` : `用户${user.id.slice(0, 6)}`;
  }
}
