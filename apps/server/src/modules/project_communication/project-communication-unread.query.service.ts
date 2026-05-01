import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';

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
    const normalizedProjectIds = this.normalizeIds(projectIds);
    const unreadByProjectId = new Map(
      normalizedProjectIds.map((projectId) => [projectId, 0]),
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
    return this.countUnreadThreadsByProject({
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
    const unreadByProjectId = await this.countUnreadThreadsByProject({
      threads,
      viewerOrganizationId: normalizedOrganizationId,
    });
    return [...unreadByProjectId.values()].reduce(
      (total, count) => total + count,
      0,
    );
  }

  private async countUnreadThreadsByProject(input: {
    threads: ProjectCommunicationThreadEntity[];
    viewerOrganizationId: string;
    initialProjectIds?: string[];
  }) {
    const unreadByProjectId = new Map(
      (input.initialProjectIds ?? []).map((projectId) => [projectId, 0]),
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
      this.messageRepository.findBy({
        id: In(threads.map((thread) => thread.lastMessageId as string)),
      }),
    ]);
    const cursorMap = new Map(cursors.map((cursor) => [cursor.threadId, cursor]));
    const messageMap = new Map(messages.map((message) => [message.id, message]));

    for (const thread of threads) {
      const lastMessage = messageMap.get(thread.lastMessageId as string);
      if (!lastMessage || lastMessage.senderOrganizationId === input.viewerOrganizationId) {
        continue;
      }
      const cursor = cursorMap.get(thread.id);
      if (cursor && cursor.lastReadAt >= (thread.lastMessageAt as Date)) {
        continue;
      }
      unreadByProjectId.set(
        thread.projectId,
        (unreadByProjectId.get(thread.projectId) ?? 0) + 1,
      );
    }
    return unreadByProjectId;
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
