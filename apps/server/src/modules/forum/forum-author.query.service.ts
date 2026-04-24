import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThan, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { ForumAuthorFollowEntity } from './entities/forum-author-follow.entity';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumAuthorProjectionService } from './forum-author-projection.service';
import { forumAuthorUnavailable } from './forum.errors';
import { ForumPresenter } from './forum.presenter';

@Injectable()
export class ForumAuthorQueryService {
  constructor(
    @InjectRepository(ForumPostEntity)
    private readonly postRepository: Repository<ForumPostEntity>,
    @InjectRepository(ForumCommentEntity)
    private readonly commentRepository: Repository<ForumCommentEntity>,
    @InjectRepository(ForumAuthorFollowEntity)
    private readonly authorFollowRepository: Repository<ForumAuthorFollowEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly authorProjectionService: ForumAuthorProjectionService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly presenter: ForumPresenter
  ) {}

  async getAuthorProfile(authorId?: string, context?: RequestContext) {
    const normalizedAuthorId = this.normalizeRequiredAuthorId(authorId);
    const [user, latestPost] = await Promise.all([
      this.userRepository.findOneBy({ id: normalizedAuthorId }),
      this.postRepository.findOne({
        where: { authorUserId: normalizedAuthorId, state: 'published' },
        order: { publishedAt: 'DESC', createdAt: 'DESC' }
      })
    ]);
    if (!user || !latestPost) {
      throw forumAuthorUnavailable('Forum public author is unavailable.');
    }

    const viewerUserId = await this.readViewerUserId(context);
    const [snapshotMap, publicPostCount, publicCommentCount, follow] = await Promise.all([
      this.authorProjectionService.buildAuthorSnapshotMap([latestPost]),
      this.postRepository.countBy({ authorUserId: normalizedAuthorId, state: 'published' }),
      this.commentRepository.countBy({ authorUserId: normalizedAuthorId, state: 'published' }),
      viewerUserId
        ? this.authorFollowRepository.findOneBy({
            followerUserId: viewerUserId,
            targetAuthorUserId: normalizedAuthorId
          })
        : null
    ]);
    const author = snapshotMap.get(latestPost.id);
    if (!author) {
      throw forumAuthorUnavailable('Forum public author projection is unavailable.');
    }

    return this.presenter.toAuthorProfileResponse({
      author,
      publicPostCount,
      publicCommentCount,
      viewerFollowsAuthor: Boolean(follow)
    });
  }

  async getAuthorPosts(authorId?: string, cursor?: string, pageSize?: string) {
    const normalizedAuthorId = this.normalizeRequiredAuthorId(authorId);
    const user = await this.userRepository.findOneBy({ id: normalizedAuthorId });
    if (!user) {
      throw forumAuthorUnavailable('Forum public author is unavailable.');
    }

    const limit = this.normalizePageSize(pageSize, 10, 20);
    const cursorDate = this.normalizeCursor(cursor);
    const posts = await this.postRepository.find({
      where: {
        authorUserId: normalizedAuthorId,
        state: 'published',
        ...(cursorDate ? { publishedAt: LessThan(cursorDate) } : {})
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' },
      take: limit + 1
    });
    const visiblePosts = posts.slice(0, limit);
    return this.presenter.toPublicAuthorPostListResponse(visiblePosts, {
      nextCursor: posts.length > limit ? visiblePosts[visiblePosts.length - 1]?.publishedAt.toISOString() ?? null : null,
      hasMore: posts.length > limit
    });
  }

  private normalizeRequiredAuthorId(authorId?: string) {
    const normalized = authorId?.trim() ?? '';
    if (!normalized) {
      throw forumAuthorUnavailable('authorId is required for forum public author.');
    }
    return normalized;
  }

  private normalizePageSize(value: string | undefined, fallback: number, max: number) {
    const parsed = typeof value === 'string' ? Number.parseInt(value, 10) : NaN;
    if (!Number.isInteger(parsed)) {
      return fallback;
    }
    return Math.min(Math.max(parsed, 1), max);
  }

  private normalizeCursor(value?: string) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    const parsed = new Date(normalized);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private async readViewerUserId(context?: RequestContext) {
    if (!context) {
      return null;
    }
    if (context.authorization.trim()) {
      const result = await this.currentSessionVerificationService.verifyCurrentSessionContext(context);
      return result.outcome === 'verified' ? result.currentSession.userId : null;
    }
    const normalized = context.userId.trim();
    return normalized || null;
  }
}
