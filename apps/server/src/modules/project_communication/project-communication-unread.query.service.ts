import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';

export type ProjectCommunicationUnreadStats = {
  unreadCount: number;
  hasUnread: boolean;
  latestUnreadMessageAt: string | null;
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

    const [cursors, messages] = await Promise.all([
      this.readCursorRepository.find({
        where: {
          organizationId: input.viewerOrganizationId,
          threadId: In(threads.map((thread) => thread.id)),
        },
      }),
      this.messageRepository.find({
        where: {
          threadId: In(threads.map((thread) => thread.id)),
          messageState: 'active',
        },
        order: { createdAt: 'ASC', id: 'ASC' },
      }),
    ]);
    const cursorMap = new Map(cursors.map((cursor) => [cursor.threadId, cursor]));
    const cursorMessageIds = this.normalizeIds(
      cursors
        .map((cursor) => cursor.lastReadMessageId ?? '')
        .filter(Boolean),
    );
    const cursorMessages = cursorMessageIds.length
      ? await this.messageRepository.findBy({ id: In(cursorMessageIds) })
      : [];
    const cursorMessageMap = new Map(
      cursorMessages.map((message) => [message.id, message]),
    );
    const threadMap = new Map(threads.map((thread) => [thread.id, thread]));

    for (const message of messages) {
      const thread = threadMap.get(message.threadId);
      if (!thread) {
        continue;
      }
      if (message.senderOrganizationId === input.viewerOrganizationId) {
        continue;
      }
      if (this.isCoveredByCursor(message, cursorMap.get(thread.id), cursorMessageMap)) {
        continue;
      }
      this.incrementUnread(
        unreadByProjectId,
        thread.projectId,
        message.createdAt,
      );
    }
    return unreadByProjectId;
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
