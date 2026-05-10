import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, FindOptionsWhere, IsNull, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectCommunicationMessageEntity } from '../project_communication/entities/project-communication-message.entity';
import { ProjectCommunicationThreadEntity } from '../project_communication/entities/project-communication-thread.entity';
import { ApnsPushProviderAdapter } from './apns-push-provider.adapter';
import { AppNotificationEntity } from './entities/app-notification.entity';
import { DevicePushTokenEntity } from './entities/device-push-token.entity';
import { PushDeliveryAttemptEntity } from './entities/push-delivery-attempt.entity';
import {
  notificationForbidden,
  notificationInvalid,
  notificationMarkReadTargetUnavailable,
  pushTokenInvalid
} from './notification.errors';
import {
  NotificationListItemProjection,
  NotificationPresenter,
  NotificationRouteTargetAvailability
} from './notification.presenter';

type RegisterDeviceTokenCommand = {
  platform: 'ios' | 'android';
  provider: 'apns' | 'fcm';
  deviceToken: string;
  appInstallationId: string;
  appVersion: string | null;
  deviceLabel: string | null;
};

type ForumInteractionNotificationCommand = {
  tab: 'replies' | 'likes' | 'follows';
  title: string;
  body: string;
  recipientUserId: string;
  recipientOrganizationId: string;
  actorUserId: string;
  targetId: string | null;
};

const PAGE_SIZE_DEFAULT = 30;
const PAGE_SIZE_MAX = 50;
const DEVICE_PLATFORMS = new Set(['ios', 'android']);
const PUSH_PROVIDERS = new Set(['apns', 'fcm']);
const NOTIFICATION_SOURCE_FILTERS: Record<string, string[] | null> = {
  all: null,
  project_communication: ['project_communication'],
  forum_interaction: ['forum_interaction'],
  business_todo: ['business_todo', 'bid_participation_request'],
  system: ['system']
};

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(AppNotificationEntity)
    private readonly notificationRepository: Repository<AppNotificationEntity>,
    @InjectRepository(DevicePushTokenEntity)
    private readonly tokenRepository: Repository<DevicePushTokenEntity>,
    private readonly dataSource: DataSource,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly presenter: NotificationPresenter,
    @InjectRepository(ProjectCommunicationThreadEntity)
    private readonly threadRepository?: Repository<ProjectCommunicationThreadEntity>,
    private readonly pushProvider: ApnsPushProviderAdapter = new ApnsPushProviderAdapter()
  ) {}

  async registerDeviceToken(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toRegisterCommand(payload);
    const session = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(DevicePushTokenEntity);
      const existing = await repository.findOneBy({
        appInstallationId: command.appInstallationId,
        provider: command.provider
      });
      const token = existing ?? repository.create({ id: randomUUID() });
      token.userId = session.userId;
      token.organizationId = session.organizationId ?? '';
      token.platform = command.platform;
      token.provider = command.provider;
      token.deviceToken = command.deviceToken;
      token.appInstallationId = command.appInstallationId;
      token.appVersion = command.appVersion;
      token.deviceLabel = command.deviceLabel;
      token.tokenState = 'active';
      token.lastRegisteredAt = new Date();
      await repository.save(token);
      return {
        registered: true,
        tokenId: token.id,
        platform: token.platform,
        provider: token.provider
      };
    });
  }

  async listNotifications(query: Record<string, unknown>, context: RequestContext) {
    const session = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const limit = this.readPageSize(query.pageSize);
    const cursor = this.readOptionalDate(query.cursor);
    const sourceFilter = this.readSourceFilter(query.source ?? query.lane);
    const orgId = this.normalizeSessionOrganizationId(session.organizationId);
    const builder = this.notificationRepository
      .createQueryBuilder('n')
      .where('n.notification_state = :state', { state: 'active' })
      .orderBy('n.created_at', 'DESC')
      .addOrderBy('n.id', 'DESC')
      .take(limit + 1);
    this.applyActorNotificationScope(builder, session.userId, orgId);
    if (cursor) {
      builder.andWhere('n.created_at < :cursor', { cursor });
    }
    if (sourceFilter) {
      builder.andWhere('n.source IN (:...sources)', { sources: sourceFilter });
    }
    const [items, unread] = await Promise.all([
      builder.getMany(),
      this.countUnread(session.userId, orgId)
    ]);
    const projectedItems = await this.withRouteTargetAvailability(items, orgId);
    return this.presenter.toList(projectedItems, unread, limit);
  }

  async markRead(payload: Record<string, unknown>, context: RequestContext) {
    const notificationIds = this.readNotificationIds(payload.notificationIds);
    this.readMarkReadContext(payload.readContext);
    const session = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const orgId = this.normalizeSessionOrganizationId(session.organizationId);
    const readAt = new Date();
    const builder = this.notificationRepository
      .createQueryBuilder('n')
      .where('n.id IN (:...ids)', { ids: notificationIds })
      .andWhere('n.notification_state = :state', { state: 'active' });
    this.applyActorNotificationScope(builder, session.userId, orgId);
    const items = await builder.getMany();
    if (items.length !== notificationIds.length) {
      throw notificationForbidden('Current actor cannot mark one or more notifications as read.');
    }
    await this.assertRouteTargetsAvailableForRead(items, orgId);
    for (const item of items) {
      item.readAt = item.readAt ?? readAt;
    }
    await this.notificationRepository.save(items);
    return {
      readNotificationIds: items.map((item) => item.id),
      unread: await this.countUnread(session.userId, orgId)
    };
  }

  async createProjectCommunicationMessageNotification(
    message: ProjectCommunicationMessageEntity,
    thread: ProjectCommunicationThreadEntity,
    senderOrganizationId: string,
    manager: EntityManager
  ) {
    const recipientOrganizationId =
      senderOrganizationId === thread.ownerOrganizationId
        ? thread.counterpartOrganizationId
        : thread.ownerOrganizationId;
    if (!recipientOrganizationId || recipientOrganizationId === senderOrganizationId) {
      return null;
    }
    const notificationRepository = manager.getRepository(AppNotificationEntity);
    const notification = notificationRepository.create({
      id: randomUUID(),
      userId: '',
      organizationId: recipientOrganizationId,
      type: 'project_communication_message',
      source: 'project_communication',
      title: '有新的项目沟通消息',
      body: this.previewBody(message),
      projectId: thread.projectId,
      threadId: thread.id,
      routeTarget: this.projectCommunicationRouteTarget(thread.projectId, thread.id, senderOrganizationId),
      readAt: null,
      notificationState: 'active'
    });
    await notificationRepository.save(notification);
    await this.recordDeliveryAttempts(notification, recipientOrganizationId, manager);
    return notification;
  }

  async createBidParticipationRequestCreatedNotification(
    request: BidParticipationRequestEntity,
    project: ProjectEntity,
    manager: EntityManager
  ) {
    const recipientOrganizationId = project.organizationId?.trim() ?? '';
    if (!recipientOrganizationId || recipientOrganizationId === request.requesterOrganizationId) {
      return null;
    }
    const notificationRepository = manager.getRepository(AppNotificationEntity);
    const notification = notificationRepository.create({
      id: randomUUID(),
      userId: '',
      organizationId: recipientOrganizationId,
      type: 'bid_participation_request',
      source: 'bid_participation_request',
      title: '有新的参与竞标申请',
      body: '有供应商提交了参与竞标申请，请进入审核线程处理。',
      projectId: project.id,
      threadId: request.id,
      routeTarget: this.bidParticipationRequestRouteTarget(project.id, request.id),
      readAt: null,
      notificationState: 'active'
    });
    await notificationRepository.save(notification);
    await this.recordDeliveryAttempts(notification, recipientOrganizationId, manager);
    return notification;
  }

  async createForumInteractionNotification(
    command: ForumInteractionNotificationCommand,
    manager: EntityManager
  ) {
    const recipientUserId = command.recipientUserId.trim();
    const recipientOrganizationId = command.recipientOrganizationId.trim();
    if (!recipientUserId && !recipientOrganizationId) {
      return null;
    }
    if (recipientUserId && recipientUserId === command.actorUserId.trim()) {
      return null;
    }
    const notificationRepository = manager.getRepository(AppNotificationEntity);
    const notification = notificationRepository.create({
      id: randomUUID(),
      userId: recipientUserId,
      organizationId: recipientOrganizationId,
      type: 'forum_interaction',
      source: 'forum_interaction',
      title: command.title,
      body: command.body,
      projectId: null,
      threadId: null,
      routeTarget: this.forumInteractionRouteTarget(command.tab, command.targetId),
      readAt: null,
      notificationState: 'active'
    });
    await notificationRepository.save(notification);
    if (recipientOrganizationId) {
      await this.recordDeliveryAttempts(notification, recipientOrganizationId, manager);
    }
    return notification;
  }

  async countBidParticipationRequestUnreadForShell(userId: string, organizationId: string) {
    const normalizedUserId = userId.trim();
    const normalizedOrganizationId = organizationId.trim();
    if (!normalizedUserId && !normalizedOrganizationId) {
      return 0;
    }
    const where = [];
    if (normalizedUserId) {
      where.push({
        userId: normalizedUserId,
        source: 'bid_participation_request',
        readAt: IsNull(),
        notificationState: 'active'
      });
    }
    if (normalizedOrganizationId) {
      where.push({
        organizationId: normalizedOrganizationId,
        source: 'bid_participation_request',
        readAt: IsNull(),
        notificationState: 'active'
      });
    }
    if (!where.length) {
      return 0;
    }
    const items = await this.notificationRepository.find({ where });
    return new Set(items.map((item) => item.id)).size;
  }

  private async countUnread(userId: string, organizationId: string) {
    const where: FindOptionsWhere<AppNotificationEntity>[] = [
      { userId, readAt: IsNull(), notificationState: 'active' }
    ];
    if (organizationId) {
      where.push({ organizationId, readAt: IsNull(), notificationState: 'active' });
    }
    const items = await this.notificationRepository.find({
      where
    });
    const unread = this.presenter.emptyUnread();
    for (const item of items) {
      unread.total += 1;
      if (item.source === 'project_communication') {
        unread.projectCommunication += 1;
      } else if (item.source === 'business_todo') {
        unread.businessTodo += 1;
      } else if (item.source === 'bid_participation_request') {
        unread.businessTodo += 1;
        unread.bidParticipationRequest += 1;
      } else if (item.source === 'forum_interaction') {
        unread.forumInteraction += 1;
      } else if (item.source === 'system') {
        unread.system += 1;
      }
    }
    return unread;
  }

  private async recordDeliveryAttempts(
    notification: AppNotificationEntity,
    recipientOrganizationId: string,
    manager: EntityManager
  ) {
    const tokenRepository = manager.getRepository(DevicePushTokenEntity);
    const attemptRepository = manager.getRepository(PushDeliveryAttemptEntity);
    const tokens = await tokenRepository.findBy({
      organizationId: recipientOrganizationId,
      tokenState: 'active'
    });
    if (tokens.length === 0) {
      await attemptRepository.save(
        attemptRepository.create({
          id: randomUUID(),
          notificationId: notification.id,
          deviceTokenId: null,
          provider: 'noop',
          attemptStatus: 'skipped',
          errorCode: 'no_device_token',
          errorMessage: 'No registered device token for recipient organization.',
          attemptedAt: new Date()
        })
      );
      return;
    }
    const attempts = [];
    for (const token of tokens) {
      const delivery = await this.pushProvider.deliver(token, notification);
      if (delivery.attemptStatus === 'token_invalid') {
        token.tokenState = 'inactive';
        await tokenRepository.save(token);
      }
      attempts.push(
        attemptRepository.create({
          id: randomUUID(),
          notificationId: notification.id,
          deviceTokenId: token.id,
          provider: delivery.provider,
          attemptStatus: delivery.attemptStatus,
          errorCode: delivery.errorCode,
          errorMessage: delivery.errorMessage,
          attemptedAt: new Date()
        })
      );
    }
    await attemptRepository.save(attempts);
  }

  private async withRouteTargetAvailability(
    items: AppNotificationEntity[],
    organizationId: string
  ): Promise<NotificationListItemProjection[]> {
    return Promise.all(
      items.map(async (item) => ({
        item,
        routeTargetAvailability: await this.resolveRouteTargetAvailability(item, organizationId)
      }))
    );
  }

  private applyActorNotificationScope(
    builder: { andWhere(statement: string, params?: Record<string, unknown>): unknown },
    userId: string,
    organizationId: string
  ) {
    if (organizationId) {
      builder.andWhere('(n.user_id = :userId OR n.organization_id = :orgId)', {
        userId,
        orgId: organizationId
      });
      return;
    }
    builder.andWhere('n.user_id = :userId', { userId });
  }

  private async assertRouteTargetsAvailableForRead(
    items: AppNotificationEntity[],
    organizationId: string
  ) {
    const projections = await this.withRouteTargetAvailability(items, organizationId);
    const blocked = projections.find(
      (projection) => projection.routeTargetAvailability.state !== 'available'
    );
    if (!blocked) {
      return;
    }
    throw notificationMarkReadTargetUnavailable('Current notification route target is unavailable for mark-read.', {
      notificationId: blocked.item.id,
      routeTargetAvailability: blocked.routeTargetAvailability
    });
  }

  private async resolveRouteTargetAvailability(
    item: AppNotificationEntity,
    organizationId: string
  ): Promise<NotificationRouteTargetAvailability> {
    const routeTarget = this.toRouteTargetRecord(item.routeTarget);
    if (!routeTarget) {
      return this.unavailableRouteTarget(
        'missing_context',
        'ROUTE_TARGET_MISSING',
        '当前通知暂时无法定位，请稍后重试或从对应入口进入。'
      );
    }
    if (!this.isProjectCommunicationRouteTarget(item, routeTarget)) {
      return this.genericRouteTargetAvailability(routeTarget);
    }
    const conversationId = this.routeParam(routeTarget, 'conversationId');
    const projectId = this.routeParam(routeTarget, 'projectId') ?? this.normalizeRouteString(item.projectId);
    const threadId = this.routeParam(routeTarget, 'threadId') ?? this.normalizeRouteString(item.threadId);
    const fallbackRouteTarget =
      conversationId && projectId ? this.projectCommunicationSubjectListRouteTarget(projectId, conversationId) : null;
    if (!conversationId || !projectId || !threadId) {
      return this.unavailableRouteTarget(
        'missing_context',
        'PROJECT_COMMUNICATION_CONTEXT_MISSING',
        fallbackRouteTarget
          ? '入口已失效，可从主体项目列表重新进入。'
          : '当前通知暂时无法定位，请稍后重试或从对应入口进入。',
        fallbackRouteTarget
      );
    }
    if (!this.threadRepository) {
      return this.availableRouteTarget();
    }
    const thread = await this.threadRepository.findOneBy({ id: threadId, projectId });
    if (!thread) {
      return this.unavailableRouteTarget(
        'expired',
        'PROJECT_COMMUNICATION_THREAD_NOT_FOUND',
        '入口已失效，可从主体项目列表重新进入。',
        fallbackRouteTarget
      );
    }
    if (thread.threadState !== 'open') {
      return this.unavailableRouteTarget(
        'unavailable',
        'PROJECT_COMMUNICATION_THREAD_NOT_OPEN',
        '入口已失效，可从主体项目列表重新进入。',
        fallbackRouteTarget
      );
    }
    const belongsToThread =
      organizationId === thread.ownerOrganizationId || organizationId === thread.counterpartOrganizationId;
    if (!belongsToThread) {
      return this.unavailableRouteTarget(
        'forbidden',
        'PROJECT_COMMUNICATION_THREAD_FORBIDDEN',
        '当前账号暂无权限查看该项目沟通入口。'
      );
    }
    const conversationBelongsToThread =
      conversationId === thread.ownerOrganizationId || conversationId === thread.counterpartOrganizationId;
    if (!conversationBelongsToThread) {
      return this.unavailableRouteTarget(
        'missing_context',
        'PROJECT_COMMUNICATION_COUNTERPART_MISMATCH',
        '入口已失效，可从主体项目列表重新进入。',
        fallbackRouteTarget
      );
    }
    return this.availableRouteTarget();
  }

  private genericRouteTargetAvailability(routeTarget: Record<string, unknown>): NotificationRouteTargetAvailability {
    if (routeTarget.state !== 'enabled') {
      return this.unavailableRouteTarget(
        'unavailable',
        'ROUTE_TARGET_UNAVAILABLE',
        '当前通知入口暂不可用，请稍后重试或从对应入口进入。'
      );
    }
    return this.availableRouteTarget();
  }

  private projectCommunicationRouteTarget(projectId: string, threadId: string, conversationId: string) {
    return {
      canonicalPath: '/api/app/message/counterpart-conversation/detail',
      localEntryKey: 'counterpart_conversation.open',
      requiredParams: ['conversationId', 'projectId', 'threadId'],
      routeParams: { conversationId, projectId, threadId },
      state: 'enabled'
    };
  }

  private projectCommunicationSubjectListRouteTarget(projectId: string, conversationId: string) {
    return {
      canonicalPath: '/api/app/message/counterpart-conversation/detail',
      localEntryKey: 'counterpart_conversation.open',
      requiredParams: ['conversationId', 'projectId'],
      routeParams: { conversationId, projectId },
      state: 'enabled'
    };
  }

  private isProjectCommunicationRouteTarget(item: AppNotificationEntity, routeTarget: Record<string, unknown>) {
    return (
      item.source === 'project_communication' ||
      item.type === 'project_communication_message' ||
      routeTarget.canonicalPath === '/api/app/message/counterpart-conversation/detail'
    );
  }

  private availableRouteTarget(): NotificationRouteTargetAvailability {
    return {
      state: 'available',
      reasonCode: 'ROUTE_TARGET_AVAILABLE',
      reasonText: '当前通知入口可用。',
      fallbackAction: 'none',
      fallbackRouteTarget: null
    };
  }

  private unavailableRouteTarget(
    state: Exclude<NotificationRouteTargetAvailability['state'], 'available'>,
    reasonCode: string,
    reasonText: string,
    fallbackRouteTarget: Record<string, unknown> | null = null
  ): NotificationRouteTargetAvailability {
    return {
      state,
      reasonCode,
      reasonText,
      fallbackAction: fallbackRouteTarget ? 'open_subject_list' : 'none',
      fallbackRouteTarget
    };
  }

  private toRouteTargetRecord(value: unknown): Record<string, unknown> | null {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
      return null;
    }
    const record = value as Record<string, unknown>;
    return Object.keys(record).length > 0 ? record : null;
  }

  private routeParam(routeTarget: Record<string, unknown>, key: string) {
    const routeParams = this.toRouteTargetRecord(routeTarget.routeParams);
    return this.normalizeRouteString(routeParams?.[key]);
  }

  private normalizeRouteString(value: unknown) {
    return typeof value === 'string' && value.trim() ? value.trim() : null;
  }

  private normalizeSessionOrganizationId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized || '';
  }

  private bidParticipationRequestRouteTarget(projectId: string, requestId: string) {
    return {
      canonicalPath: '/api/app/project/bid-participation/thread/detail',
      localEntryKey: 'bid_participation_request.open',
      requiredParams: ['threadId', 'projectId', 'requestId'],
      routeParams: { threadId: requestId, projectId, requestId },
      state: 'enabled'
    };
  }

  private forumInteractionRouteTarget(tab: 'replies' | 'likes' | 'follows', targetId: string | null) {
    return {
      canonicalPath: '/api/app/forum/interaction/inbox',
      localEntryKey: 'forum_interaction.open',
      requiredParams: ['tab'],
      routeParams: {
        tab,
        ...(targetId ? { targetId } : {})
      },
      state: 'enabled'
    };
  }

  private previewBody(message: ProjectCommunicationMessageEntity) {
    const body = message.body.trim();
    if (body) {
      return body.slice(0, 120);
    }
    if (message.messageKind === 'image') {
      return '收到一张项目沟通图片。';
    }
    if (message.messageKind === 'file') {
      return '收到一个项目沟通附件。';
    }
    if (message.messageKind === 'confirmation_card') {
      return '收到一张项目确认卡。';
    }
    return null;
  }

  private toRegisterCommand(payload: Record<string, unknown>) {
    const platform = this.readPushString(payload.platform, 'platform');
    const provider = this.readPushString(payload.provider, 'provider');
    if (!DEVICE_PLATFORMS.has(platform)) {
      throw pushTokenInvalid('Field `platform` must be ios or android.');
    }
    if (!PUSH_PROVIDERS.has(provider)) {
      throw pushTokenInvalid('Field `provider` must be apns or fcm.');
    }
    return {
      platform: platform as RegisterDeviceTokenCommand['platform'],
      provider: provider as RegisterDeviceTokenCommand['provider'],
      deviceToken: this.readPushString(payload.deviceToken, 'deviceToken', 4096),
      appInstallationId: this.readPushString(payload.appInstallationId, 'appInstallationId', 128),
      appVersion: this.readOptionalPushString(payload.appVersion, 64),
      deviceLabel: this.readOptionalPushString(payload.deviceLabel, 128)
    } satisfies RegisterDeviceTokenCommand;
  }

  private readNotificationIds(value: unknown) {
    if (!Array.isArray(value) || value.length === 0 || value.length > 100) {
      throw notificationInvalid('Field `notificationIds` must contain 1 to 100 ids.');
    }
    const ids = value.map((item) => this.readNotificationString(item, 'notificationIds[]', 64));
    if (new Set(ids).size !== ids.length) {
      throw notificationInvalid('Field `notificationIds` must not contain duplicates.');
    }
    return ids;
  }

  private readMarkReadContext(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw notificationInvalid('Field `readContext` is required.');
    }
    const record = value as Record<string, unknown>;
    const availabilityState = this.readNotificationString(
      record.routeTargetAvailabilityState,
      'readContext.routeTargetAvailabilityState',
      32
    );
    if (availabilityState !== 'available') {
      throw notificationMarkReadTargetUnavailable(
        'Notification mark-read requires an available route target context.',
        { routeTargetAvailabilityState: availabilityState }
      );
    }
    const completion = this.readNotificationString(record.completion, 'readContext.completion', 64);
    if (completion !== 'navigated_to_available_target') {
      throw notificationInvalid('Field `readContext.completion` must be navigated_to_available_target.');
    }
  }

  private readPageSize(value: unknown) {
    if (value === undefined || value === null || value === '') {
      return PAGE_SIZE_DEFAULT;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    if (!Number.isInteger(parsed) || parsed <= 0) {
      throw notificationInvalid('Field `pageSize` must be a positive integer.');
    }
    return Math.min(parsed, PAGE_SIZE_MAX);
  }

  private readSourceFilter(value: unknown) {
    const normalized = this.readOptionalString(value);
    if (!normalized) {
      return null;
    }
    const filter = NOTIFICATION_SOURCE_FILTERS[normalized];
    if (filter === undefined) {
      throw notificationInvalid('Field `source` must be all, project_communication, forum_interaction, business_todo, or system.');
    }
    return filter;
  }

  private readOptionalDate(value: unknown) {
    const normalized = this.readOptionalString(value);
    if (!normalized) {
      return null;
    }
    const date = new Date(normalized);
    if (Number.isNaN(date.getTime())) {
      throw notificationInvalid('Field `cursor` must be an ISO timestamp.');
    }
    return date;
  }

  private readNotificationString(value: unknown, field: string, maxLength: number) {
    const normalized = this.readRequiredString(value, field, notificationInvalid);
    if (normalized.length > maxLength) {
      throw notificationInvalid(`Field \`${field}\` must be ${maxLength} chars or less.`);
    }
    return normalized;
  }

  private readPushString(value: unknown, field: string, maxLength = 64) {
    const normalized = this.readRequiredString(value, field, pushTokenInvalid);
    if (normalized.length > maxLength) {
      throw pushTokenInvalid(`Field \`${field}\` must be ${maxLength} chars or less.`);
    }
    return normalized;
  }

  private readOptionalPushString(value: unknown, maxLength: number) {
    const normalized = this.readOptionalString(value);
    if (!normalized) {
      return null;
    }
    if (normalized.length > maxLength) {
      throw pushTokenInvalid(`Optional field must be ${maxLength} chars or less.`);
    }
    return normalized;
  }

  private readRequiredString(
    value: unknown,
    field: string,
    makeError: (message: string) => Error
  ) {
    if (typeof value !== 'string') {
      throw makeError(`Field \`${field}\` is required.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw makeError(`Field \`${field}\` is required.`);
    }
    return normalized;
  }

  private readOptionalString(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw notificationInvalid('Optional string field must be a string when provided.');
    }
    const normalized = value.trim();
    return normalized || null;
  }
}
