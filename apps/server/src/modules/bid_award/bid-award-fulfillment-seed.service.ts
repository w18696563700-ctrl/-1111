import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { EntityManager } from 'typeorm';
import { OrderSeedCarrier } from '../order/order.seed';
import { orderConversionFailed } from './bid-award.errors';

type ProjectSeedSource = {
  title: string | null;
};

type FulfillmentSeedInput = {
  project: ProjectSeedSource;
  order: OrderSeedCarrier;
};

@Injectable()
export class BidAwardFulfillmentSeedService {
  async seedDefaultFulfillment(manager: EntityManager, input: FulfillmentSeedInput) {
    const milestoneId = randomUUID();
    const inspectionId = randomUUID();
    const title = this.resolveMilestoneTitle(input.project);

    try {
      const hasMilestoneNo = await this.hasColumn(manager, 'milestones', 'milestone_no');
      const hasInspectionNo = await this.hasColumn(manager, 'inspections', 'inspection_no');
      const milestoneColumns = [
        'id',
        'order_id',
        'sequence_no',
        'title',
        'amount',
        'state'
      ];
      const milestoneValues: Array<string | number> = [
        milestoneId,
        input.order.orderId,
        1,
        title,
        this.toMilestoneAmount(input.order.totalAmount),
        'pending_submission'
      ];
      if (hasMilestoneNo) {
        milestoneColumns.push('milestone_no');
        milestoneValues.push(this.toMilestoneNo(milestoneId));
      }
      const milestonePlaceholders = milestoneValues.map((_, index) => `$${index + 1}`).join(',\n            ');
      await manager.query(
        `
          insert into public.milestones (
            ${milestoneColumns.join(',\n            ')},
            created_at,
            updated_at
          ) values (
            ${milestonePlaceholders},
            now(),
            now()
          )
        `,
        milestoneValues,
      );

      const inspectionColumns = [
        'id',
        'milestone_id',
        'order_id',
        'state',
        'summary_text',
        'rectification_count',
        'recheck_count'
      ];
      const inspectionValues: Array<string | number> = [
        inspectionId,
        milestoneId,
        input.order.orderId,
        'draft',
        `${title} 默认验收待提交。`,
        0,
        0
      ];
      if (hasInspectionNo) {
        inspectionColumns.push('inspection_no');
        inspectionValues.push(this.toInspectionNo(inspectionId));
      }
      const inspectionPlaceholders = inspectionValues.map((_, index) => `$${index + 1}`).join(',\n            ');
      await manager.query(
        `
          insert into public.inspections (
            ${inspectionColumns.join(',\n            ')},
            created_at,
            updated_at
          ) values (
            ${inspectionPlaceholders},
            now(),
            now()
          )
        `,
        inspectionValues,
      );
    } catch (error) {
      throw orderConversionFailed('Fulfillment seed failed during bid award bridge closure.');
    }

    return { milestoneId, inspectionId };
  }

  private resolveMilestoneTitle(project: ProjectSeedSource) {
    const title = project.title?.trim() ?? '';
    return title ? `${title} 默认履约节点` : '默认履约节点';
  }

  private async hasColumn(manager: EntityManager, tableName: string, columnName: string) {
    const rows = (await manager.query(
      `
        select column_name as "columnName"
        from information_schema.columns
        where table_schema = 'public'
          and table_name = $1
          and column_name = $2
      `,
      [tableName, columnName],
    )) as Array<{ columnName?: string }>;
    return rows.some((row) => row.columnName === columnName);
  }

  private toMilestoneNo(milestoneId: string) {
    return `MS-${milestoneId.replace(/-/g, '').slice(0, 29).toUpperCase()}`;
  }

  private toInspectionNo(inspectionId: string) {
    return `IN-${inspectionId.replace(/-/g, '').slice(0, 29).toUpperCase()}`;
  }

  private toMilestoneAmount(amount: string) {
    const parsed = Number(amount);
    if (!Number.isFinite(parsed) || parsed <= 0) {
      return 0;
    }
    return Math.round(parsed);
  }
}
