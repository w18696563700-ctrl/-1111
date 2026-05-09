import { Injectable } from '@nestjs/common';
import { EntityManager, In } from 'typeorm';
import { VerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { InquiryQuoteDepositEntity } from '../p0_pay/entities/inquiry-quote-deposit.entity';
import { ProjectAuthenticitySincerityFreezeFeedbackEntity } from '../p0_pay/entities/project-authenticity-sincerity-freeze-feedback.entity';
import {
  PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_GATE_STATUS,
  PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_STATUS,
} from '../p0_pay/p0-pay-internal-test-no-freeze.policy';
import { projectAuthenticitySincerityInternalTestPolicyUnavailable } from '../p0_pay/p0-pay.errors';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import { ProjectEntity } from './entities/project.entity';

const REQUIRED_QUOTE_BASIS_ATTACHMENT_KINDS = [
  'effect_image',
  'construction_doc',
  'material_sample',
] as const;

const REQUIRED_QUOTE_BASIS_ATTACHMENT_LABELS: Record<
  (typeof REQUIRED_QUOTE_BASIS_ATTACHMENT_KINDS)[number],
  string
> = {
  effect_image: '效果图',
  construction_doc: '尺寸图 / 施工图',
  material_sample: '材质图 / 材料样板',
};

export type ProjectPublishGateResult = {
  orderId: string | null;
  authenticitySincerityStatus: 'paid' | typeof PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_STATUS;
  authenticitySincerityGateResult: 'paid' | typeof PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_GATE_STATUS;
  freezeFeedbackChoice: string;
  requiredAttachmentKinds: readonly string[];
};

@Injectable()
export class ProjectPublishGateService {
  async requireProjectPublishGate(
    manager: EntityManager,
    project: ProjectEntity,
    currentSession: VerifiedCurrentSessionContext
  ): Promise<ProjectPublishGateResult> {
    await this.requireRequiredQuoteBasisAttachments(manager, project);
    const feedbackChoice = await this.requireCurrentUserGreenChannelFeedback(
      manager,
      project,
      currentSession
    );
    const paidOrder = await manager.getRepository(InquiryQuoteDepositEntity).findOne({
      where: {
        taskId: project.id,
        publisherOrganizationId: project.organizationId,
        status: 'paid',
      },
      order: { updatedAt: 'DESC' },
    });
    if (paidOrder) {
      return {
        orderId: paidOrder.id,
        authenticitySincerityStatus: 'paid',
        authenticitySincerityGateResult: 'paid',
        freezeFeedbackChoice: feedbackChoice,
        requiredAttachmentKinds: REQUIRED_QUOTE_BASIS_ATTACHMENT_KINDS,
      };
    }

    const latestOrder = await manager.getRepository(InquiryQuoteDepositEntity).findOne({
      where: {
        taskId: project.id,
        publisherOrganizationId: project.organizationId,
      },
      order: { updatedAt: 'DESC' },
    });
    return {
      orderId: latestOrder?.id ?? null,
      authenticitySincerityStatus: PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_STATUS,
      authenticitySincerityGateResult: PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_GATE_STATUS,
      freezeFeedbackChoice: feedbackChoice,
      requiredAttachmentKinds: REQUIRED_QUOTE_BASIS_ATTACHMENT_KINDS,
    };
  }

  private async requireRequiredQuoteBasisAttachments(
    manager: EntityManager,
    project: ProjectEntity
  ) {
    const attachments = await manager.getRepository(ProjectAttachmentEntity).find({
      where: {
        projectId: project.id,
        attachmentKind: In([...REQUIRED_QUOTE_BASIS_ATTACHMENT_KINDS]),
      },
    });
    const presentKinds = new Set(attachments.map((attachment) => attachment.attachmentKind));
    const missingKinds = REQUIRED_QUOTE_BASIS_ATTACHMENT_KINDS.filter(
      (kind) => !presentKinds.has(kind)
    );
    if (missingKinds.length > 0) {
      const labels = missingKinds.map((kind) => REQUIRED_QUOTE_BASIS_ATTACHMENT_LABELS[kind]);
      throw projectAuthenticitySincerityInternalTestPolicyUnavailable(
        `发布项目需先补齐必传报价依据资料：${labels.join('、')}。`
      );
    }
  }

  private async requireCurrentUserGreenChannelFeedback(
    manager: EntityManager,
    project: ProjectEntity,
    currentSession: VerifiedCurrentSessionContext
  ) {
    const feedback = await manager
      .getRepository(ProjectAuthenticitySincerityFreezeFeedbackEntity)
      .findOne({
        where: {
          projectId: project.id,
          userId: currentSession.userId,
        },
        order: { updatedAt: 'DESC' },
      });
    if (feedback?.choice === 'support_freeze' || feedback?.choice === 'oppose_freeze') {
      return feedback.choice;
    }
    throw projectAuthenticitySincerityInternalTestPolicyUnavailable(
      '发布项目需先完成项目真实性诚意金绿色通道表态；选择支持或暂不支持均可继续发布。'
    );
  }
}
