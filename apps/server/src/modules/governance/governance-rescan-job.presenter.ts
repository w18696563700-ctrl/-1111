import { Injectable } from '@nestjs/common';
import { GovernanceRescanJobEntity } from './entities/governance-rescan-job.entity';

@Injectable()
export class GovernanceRescanJobPresenter {
  toPagination(page: number, pageSize: number, total: number) {
    return {
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total
    };
  }

  toListItem(job: GovernanceRescanJobEntity) {
    return {
      rescanJobId: job.id,
      scopeType: job.scopeType,
      status: job.status,
      candidateCount: job.candidateCount,
      createdAt: this.toIso(job.createdAt)
    };
  }

  toDetail(job: GovernanceRescanJobEntity) {
    return {
      rescanJobId: job.id,
      scopeType: job.scopeType,
      status: job.status,
      windowStart: this.toIso(job.windowStart),
      windowEnd: this.toIso(job.windowEnd),
      candidateCount: job.candidateCount,
      flaggedCount: job.flaggedCount,
      createdAt: this.toIso(job.createdAt),
      completedAt: this.toIso(job.completedAt)
    };
  }

  toCreateResponse(job: GovernanceRescanJobEntity, traceId: string) {
    return {
      rescanJobId: job.id,
      status: job.status,
      traceId
    };
  }

  private toIso(value: Date | null | undefined) {
    return value ? value.toISOString() : null;
  }
}
