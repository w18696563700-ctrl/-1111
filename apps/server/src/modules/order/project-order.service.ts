import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProjectOrderEntity } from './entities/project-order.entity';
import {
  PROJECT_ORDER_COMPLETED_STATE,
  canTransitionProjectOrderState,
  normalizeProjectOrderAnchor,
  normalizeProjectOrderState,
} from './project-order.state';

@Injectable()
export class ProjectOrderService {
  constructor(
    @InjectRepository(ProjectOrderEntity)
    private readonly orderRepository: Repository<ProjectOrderEntity>,
  ) {}

  async findById(orderId: string) {
    const id = this.readRequiredId(orderId);
    return this.orderRepository.findOne({ where: { id } });
  }

  async findByProjectId(projectId: string) {
    const normalizedProjectId = this.readRequiredId(projectId);
    return this.orderRepository.findOne({ where: { projectId: normalizedProjectId } });
  }

  isCompleted(order: Pick<ProjectOrderEntity, 'state'> | null | undefined) {
    return normalizeProjectOrderState(order?.state) === PROJECT_ORDER_COMPLETED_STATE;
  }

  requireTruthAnchor(order: Pick<
    ProjectOrderEntity,
    'projectId' | 'buyerOrganizationId' | 'sellerOrganizationId'
  >) {
    const anchor = normalizeProjectOrderAnchor({
      projectId: order.projectId,
      buyerOrganizationId: order.buyerOrganizationId,
      sellerOrganizationId: order.sellerOrganizationId,
    });
    if (!anchor) {
      throw new Error('ProjectOrder requires projectId, buyerOrganizationId, and sellerOrganizationId.');
    }
    return anchor;
  }

  requireStateTransition(from: string | null | undefined, to: string | null | undefined) {
    if (!canTransitionProjectOrderState(from, to)) {
      throw new Error(`ProjectOrder state transition is not allowed: ${from ?? 'null'} -> ${to ?? 'null'}.`);
    }
    return normalizeProjectOrderState(to)!;
  }

  private readRequiredId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw new Error('ProjectOrder id is required.');
    }
    return normalized;
  }
}
