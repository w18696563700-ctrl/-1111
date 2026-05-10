import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, In, Repository } from 'typeorm';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';

export type ProjectCommunicationUnreadStats = {
  unreadCount: number;
  hasUnread: boolean;
  latestUnreadMessageAt: string | null;
};

type UnreadAggregateRow = {
  projectId?: string;
  unreadCount?: string | number;
  latestUnreadMessageAt?: string | Date | null;
};

@Injectable()
export class ProjectCommunicationUnreadQueryService {
  constructor(
    @InjectRepository(ProjectCommunicationThreadEntity)
    private readonly threadRepository: Repository<ProjectCommunicationThreadEntity>,
    @InjectRepository(ProjectCommunicationReadCursorEntity)
    private readonly readCursorRepository: Repository<ProjectCommunicationReadCursorEntity>,
    @InjectRepository(ProjectCommunicationMessageEntity)
    private readonly messageRepository: Repository<ProjectCommunicationMessageEntity>,
  ) {}

  async buildUnreadMapForCounterpartProjects(
    projectIds: string[],
    viewerOrganizationId: string,
  ) {
    const stats = await this.buildUnreadStatsForCounterpartProjects(
      projectIds,
      viewerOrganizationId,
    );
    return new Map(
      [...stats.entries()].map(([projectId, value]) => [
        projectId,
        value.unreadCount,
      ]),
    );
  }

  async buildUnreadStatsForCounterpartProjects(
    projectIds: string[],
    viewerOrganizationId: string,
  ) {
    const normalizedProjectIds = this.normalizeIds(projectIds);
    const unreadByProjectId = new Map<string, ProjectCommunicationUnreadStats>(
      normalizedProjectIds.map((projectId) => [
        projectId,
        this.emptyStats(),
      ]),
    );
    if (!normalizedProjectIds.length) {
      return unreadByProjectId;
    }

    const threads = await this.threadRepository.find({
      where: [
        {
          projectId: In(normalizedProjectIds),
          ownerOrganizationId: viewerOrganizationId,
        },
        {
          projectId: In(normalizedProjectIds),
          counterpartOrganizationId: viewerOrganizationId,
        },
      ],
    });
    return this.countUnreadMessagesByProject({
      threads,
      viewerOrganizationId,
      initialProjectIds: normalizedProjectIds,
    });
  }

  async countUnreadForShell(viewerOrganizationId: string | null | undefined) {
    const normalizedOrganizationId = viewerOrganizationId?.trim() ?? '';
    if (!normalizedOrganizationId) {
      return 0;
    }

    const threads = await this.threadRepository.find({
      where: [
        { ownerOrganizationId: normalizedOrganizationId },
        { counterpartOrganizationId: normalizedOrganizationId },
      ],
    });
    const unreadByProjectId = await this.countUnreadMessagesByProject({
      threads,
      viewerOrganizationId: normalizedOrganizationId,
    });
    return [...unreadByProjectId.values()].reduce(
      (total, stats) => total + stats.unreadCount,
      0,
    );
  }

  private async countUnreadMessagesByProject(input: {
    threads: ProjectCommunicationThreadEntity[];
    viewerOrganizationId: string;
    initialProjectIds?: string[];
  }) {
    const unreadByProjectId = new Map<string, ProjectCommunicationUnreadStats>(
      (input.initialProjectIds ?? []).map((projectId) => [
        projectId,
        this.emptyStats(),
      ]),
    );
    const threads = this.uniqueThreads(input.threads).filter(
      (thread) => thread.lastMessageAt != null && thread.lastMessageId != null,
    );
    if (!threads.length) {
      return unreadByProjectId;
    }

    const cursors = await this.readCursorRepository.find({
      where: {
        organizationId: input.viewerOrganizationId,
        threadId: In(threads.map((thread) => thread.id)),
      },
    });
    if (typeof this.messageRepository.createQueryBuilder !== 'function') {
      const cursorMap = new Map(cursors.map((cursor) => [cursor.threadId, cursor]));
      const cursorMessageMap = await this.loadCursorMessageMap(cursors);
      return this.countUnreadMessagesByProjectInMemory({
        unreadByProjectId,
        threads,
        viewerOrganizationId: input.viewerOrganizationId,
        cursorMap,
        cursorMessageMap,
      });
    }
    const rows = await this.aggregateUnreadMessageRows({
      threads,
      viewerOrganizationId: input.viewerOrganizationId,
    });

    for (const row of rows) {
      const projectId = row.projectId?.trim() ?? '';
      if (!projectId) {
        continue;
      }
      const unreadCount = Number(row.unreadCount ?? 0);
      if (!Number.isFinite(unreadCount) || unreadCount <= 0) {
        continue;
      }
      const current = unreadByProjectId.get(projectId) ?? this.emptyStats();
      const latestUnreadMessageAt = this.toIso(row.latestUnreadMessageAt);
      const mergedLatestUnreadMessageAt = latestUnreadMessageAt
        ? this.maxIso(current.latestUnreadMessageAt, latestUnreadMessageAt)
        : current.latestUnreadMessageAt;
      unreadByProjectId.set(projectId, {
        unreadCount: current.unreadCount + unreadCount,
        hasUnread: true,
        latestUnreadMessageAt: mergedLatestUnreadMessageAt,
      });
    }
    return unreadByProjectId;
  }

  private async loadCursorMessageMap(cursors: ProjectCommunicationReadCursorEntity[]) {
    const cursorMessageIds = this.normalizeIds(
      cursors
        .map((cursor) => cursor.lastReadMessageId ?? '')
        .filter(Boolean),
    );
    const cursorMessages = cursorMessageIds.length
      ? await this.messageRepository.findBy({ id: In(cursorMessageIds) })
      : [];
    return new Map(cursorMessages.map((message) => [message.id, message]));
  }

  private async aggregateUnreadMessageRows(input: {
    threads: ProjectCommunicationThreadEntity[];
    viewerOrganizationId: string;
  }) {
    const query = this.messageRepository
      .createQueryBuilder('message')
      .innerJoin(ProjectCommunicationThreadEntity, 'thread', 'thread.id = message.thread_id')
      .leftJoin(
        ProjectCommunicationReadCursorEntity,
        'cursor',
        'cursor.thread_id = thread.id AND cursor.organization_id = :viewerOrganizationId',
        { viewerOrganizationId: input.viewerOrganizationId },
      )
      .leftJoin(
        ProjectCommunicationMessageEntity,
        'cursor_message',
        'cursor_message.id = cursor.last_read_message_id',
      )
      .select('thread.project_id', 'projectId')
      .addSelect('COUNT(*)', 'unreadCount')
      .addSelect('MAX(message.created_at)', 'latestUnreadMessageAt')
      .where('thread.id IN (:...threadIds)', {
        threadIds: input.threads.map((thread) => thread.id),
      })
      .andWhere('message.message_state = :messageState', { messageState: 'active' })
      .andWhere('message.sender_organization_id <> :viewerOrganizationId', {
        viewerOrganizationId: input.viewerOrganizationId,
      })
      .andWhere(
        'message.created_at > COALESCE(' +
          'CASE WHEN cursor_message.thread_id = thread.id THEN cursor_message.created_at END,' +
          'cursor.last_read_at,' +
          ':epoch' +
        ')',
        { epoch: new Date(0) },
      )
      .groupBy('thread.project_id');
    return query.getRawMany<UnreadAggregateRow>();
  }

  private async countUnreadMessagesByProjectInMemory(input: {
    unreadByProjectId: Map<string, ProjectCommunicationUnreadStats>;
    threads: ProjectCommunicationThreadEntity[];
    viewerOrganizationId: string;
    cursorMap: Map<string, ProjectCommunicationReadCursorEntity>;
    cursorMessageMap: Map<string, ProjectCommunicationMessageEntity>;
  }) {
    const messages = await this.messageRepository.find({
      where: {
        threadId: In(input.threads.map((thread) => thread.id)),
        messageState: 'active',
      },
      order: { createdAt: 'ASC', id: 'ASC' },
    });
    const threadMap = new Map(input.threads.map((thread) => [thread.id, thread]));

    for (const message of messages) {
      const thread = threadMap.get(message.threadId);
      if (!thread) {
        continue;
      }
      if (message.senderOrganizationId === input.viewerOrganizationId) {
        continue;
      }
      if (this.isCoveredByCursor(message, input.cursorMap.get(thread.id), input.cursorMessageMap)) {
        continue;
      }
      this.incrementUnread(
        input.unreadByProjectId,
        thread.projectId,
        message.createdAt,
      );
    }
    return input.unreadByProjectId;
  }

  private isCoveredByCursor(
    message: ProjectCommunicationMessageEntity,
    cursor: ProjectCommunicationReadCursorEntity | undefined,
    cursorMessageMap: Map<string, ProjectCommunicationMessageEntity>,
  ) {
    if (!cursor) {
      return false;
    }
    const cursorMessage = cursor.lastReadMessageId
      ? cursorMessageMap.get(cursor.lastReadMessageId)
      : null;
    if (cursorMessage?.threadId === message.threadId) {
      return message.createdAt <= cursorMessage.createdAt;
    }
    return message.createdAt <= cursor.lastReadAt;
  }

  private incrementUnread(
    unreadByProjectId: Map<string, ProjectCommunicationUnreadStats>,
    projectId: string,
    createdAt: Date,
  ) {
    const current = unreadByProjectId.get(projectId) ?? this.emptyStats();
    const latestUnreadMessageAt = this.maxIso(
      current.latestUnreadMessageAt,
      createdAt.toISOString(),
    );
    unreadByProjectId.set(projectId, {
      unreadCount: current.unreadCount + 1,
      hasUnread: true,
      latestUnreadMessageAt,
    });
  }

  private maxIso(left: string | null, right: string) {
    if (!left) {
      return right;
    }
    return left >= right ? left : right;
  }

  private toIso(value: string | Date | null | undefined) {
    if (!value) {
      return null;
    }
    if (value instanceof Date) {
      return value.toISOString();
    }
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date.toISOString();
  }

  private emptyStats(): ProjectCommunicationUnreadStats {
    return {
      unreadCount: 0,
      hasUnread: false,
      latestUnreadMessageAt: null,
    };
  }

  private uniqueThreads(threads: ProjectCommunicationThreadEntity[]) {
    const map = new Map<string, ProjectCommunicationThreadEntity>();
    for (const thread of threads) {
      map.set(thread.id, thread);
    }
    return [...map.values()];
  }

  private normalizeIds(ids: string[]) {
    return [...new Set(ids.map((id) => id.trim()).filter(Boolean))];
  }
}
