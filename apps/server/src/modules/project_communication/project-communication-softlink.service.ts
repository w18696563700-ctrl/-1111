import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import { ProjectCommunicationAccessService } from './project-communication-access.service';

@Injectable()
export class ProjectCommunicationSoftLinkService {
  constructor(
    @InjectRepository(ProjectCommunicationThreadEntity)
    private readonly threadRepository: Repository<ProjectCommunicationThreadEntity>,
    @InjectRepository(ProjectCommunicationMessageEntity)
    private readonly messageRepository: Repository<ProjectCommunicationMessageEntity>,
    private readonly accessService: ProjectCommunicationAccessService
  ) {}

  async getSoftLink(query: Record<string, unknown>, context: RequestContext) {
    const projectId = this.readRequiredString(query.projectId, 'projectId');
    const threadId = this.readRequiredString(query.threadId, 'threadId');
    const messageId = this.readRequiredString(query.messageId, 'messageId');
    const thread = await this.threadRepository.findOneBy({ id: threadId, projectId });
    if (!thread) {
      throw this.invalid('Current project communication thread is unavailable for confirmation softLink.');
    }
    await this.accessService.requireExistingThreadParticipant(thread, context);
    const message = await this.messageRepository.findOneBy({ id: messageId, threadId, projectId });
    if (!message || message.messageKind !== 'confirmation_card') {
      throw this.invalid('Current confirmation-card message is unavailable for softLink.');
    }
    const confirmation = this.readConfirmation(message.payload);
    const confirmationType = this.toSoftLinkKind(confirmation.confirmationType);
    return {
      projectId,
      threadId,
      messageId,
      confirmationType,
      status: confirmation.status === 'recorded' ? 'recorded' : 'pending',
      title: confirmation.title,
      summary: confirmation.summary,
      routeTarget: this.routeTarget(projectId, threadId, messageId, confirmationType)
    };
  }

  private readConfirmation(payload: Record<string, unknown> | null | undefined) {
    const root = this.readOptionalRecord(payload);
    const confirmation = this.readOptionalRecord(root?.confirmation);
    if (!confirmation) {
      throw this.invalid('Current confirmation payload is unavailable for softLink.');
    }
    return {
      confirmationType: this.readRequiredString(confirmation.confirmationType, 'payload.confirmation.confirmationType'),
      title: this.readRequiredString(confirmation.title, 'payload.confirmation.title'),
      summary: this.readRequiredString(confirmation.summary, 'payload.confirmation.summary'),
      status: typeof confirmation.status === 'string' ? confirmation.status : 'pending'
    };
  }

  private toSoftLinkKind(value: string) {
    if (value === 'material_process') {
      return 'material';
    }
    if (value === 'quote' || value === 'schedule') {
      return value;
    }
    throw this.invalid('Current confirmation type does not support softLink.');
  }

  private routeTarget(projectId: string, threadId: string, messageId: string, kind: string) {
    return {
      canonicalPath: '/api/app/message/project-communication/messages',
      localEntryKey: `project_communication.confirmation.${kind}`,
      requiredParams: ['projectId', 'threadId', 'messageId'],
      routeParams: { projectId, threadId, messageId },
      state: 'enabled'
    };
  }

  private readOptionalRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      return null;
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw this.invalid(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private invalid(message: string) {
    return new BadRequestException({ code: 'CONFIRMATION_SOFTLINK_INVALID', message });
  }
}
