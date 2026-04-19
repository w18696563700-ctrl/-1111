import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager } from 'typeorm';
import {
  CREDIT_SHADOW_AGGREGATION_MODE,
  CREDIT_SHADOW_NUMERIC_SCORE_COLUMNS,
  CREDIT_SHADOW_TEXT_SCORE_COLUMNS
} from './credit-scoring-shadow.constants';
import {
  buildShadowAggregateSnapshot,
  resolveShadowRatingScoreValue
} from './credit-scoring-shadow.engine';
import {
  RecomputeTriggerInput,
  RatingScoreSourceMode,
  ShadowAggregateSnapshot,
  ShadowRatingValue
} from './credit-scoring-shadow.types';
import { OrganizationCreditShadowAggregateEntity } from './entities/organization-credit-shadow-aggregate.entity';
import { OrganizationCreditShadowLedgerEntryEntity } from './entities/organization-credit-shadow-ledger-entry.entity';
import { OrganizationCreditShadowRecomputeTriggerEntity } from './entities/organization-credit-shadow-recompute-trigger.entity';

@Injectable()
export class CreditScoringShadowAggregationService {
  constructor(private readonly dataSource: DataSource) {}

  async recomputeAfterFormalRatingSubmit(input: RecomputeTriggerInput) {
    const organizationId = input.organizationId.trim();
    if (!organizationId) {
      return null;
    }

    return this.dataSource.transaction(async (manager) => {
      const triggerRepo = manager.getRepository(OrganizationCreditShadowRecomputeTriggerEntity);
      const aggregateRepo = manager.getRepository(OrganizationCreditShadowAggregateEntity);
      const ledgerRepo = manager.getRepository(OrganizationCreditShadowLedgerEntryEntity);
      const triggeredAt = input.triggeredAt ?? new Date();
      const trigger = triggerRepo.create({
        triggerId: randomUUID(),
        organizationId,
        triggerType: 'formal_rating_submitted',
        sourceOrderId: this.normalizeNullableId(input.sourceOrderId),
        sourceRatingId: this.normalizeNullableId(input.sourceRatingId),
        reasonCodes: ['RATING_ONLY_MODE_ACTIVE'],
        triggerStatus: 'pending',
        processedAt: null
      });
      await triggerRepo.save(trigger);

      const previousAggregate = await aggregateRepo.findOneBy({ organizationId });
      const ratingRows = await this.fetchShadowRatingRows(manager, organizationId);
      const snapshot = buildShadowAggregateSnapshot(organizationId, ratingRows, triggeredAt);
      const aggregate = aggregateRepo.create({
        organizationId: snapshot.organizationId,
        aggregationMode: snapshot.aggregationMode,
        sampleStatus: snapshot.sampleStatus,
        ratedCompletedOrderCount: snapshot.ratedCompletedOrderCount,
        verySatisfiedCount: snapshot.verySatisfiedCount,
        satisfiedCount: snapshot.satisfiedCount,
        passableCount: snapshot.passableCount,
        negativeCount: snapshot.negativeCount,
        positiveRate: snapshot.positiveRate,
        negativeRate: snapshot.negativeRate,
        recentConsecutiveNegativeCount: snapshot.recentConsecutiveNegativeCount,
        last20RatedNegativeRate: snapshot.last20RatedNegativeRate,
        baseScore: snapshot.baseScore,
        rawScore: snapshot.rawScore,
        effectiveScore: snapshot.effectiveScore,
        publicScore: snapshot.publicScore,
        tierCode: snapshot.tierCode,
        riskPosture: snapshot.riskPosture,
        tierReasonCodes: [...snapshot.tierReasonCodes],
        postureReasonCodes: [...snapshot.postureReasonCodes],
        reasonSummary: snapshot.reasonSummary,
        version: snapshot.version,
        lastRatedOrderId: snapshot.lastRatedOrderId,
        lastRatedAt: snapshot.lastRatedAt
      });
      await aggregateRepo.save(aggregate);

      const ledgerEntry = ledgerRepo.create({
        entryId: randomUUID(),
        organizationId,
        triggerType: 'formal_rating_submitted',
        sourceOrderId: this.normalizeNullableId(input.sourceOrderId),
        sourceRatingId: this.normalizeNullableId(input.sourceRatingId),
        beforeScore: this.resolveLedgerScore(previousAggregate),
        afterScore: snapshot.publicScore,
        beforeTierCode: previousAggregate?.tierCode ?? null,
        afterTierCode: snapshot.tierCode,
        beforeRiskPosture: previousAggregate?.riskPosture ?? null,
        afterRiskPosture: snapshot.riskPosture,
        reasonCodes: this.buildLedgerReasonCodes(snapshot),
        changedAt: triggeredAt
      });
      await ledgerRepo.save(ledgerEntry);

      await triggerRepo.update(trigger.triggerId, {
        triggerStatus: 'processed',
        processedAt: triggeredAt
      });

      return snapshot;
    });
  }

  private async fetchShadowRatingRows(manager: EntityManager, organizationId: string) {
    const scoreSource = await this.discoverRatingScoreSource(manager);
    const selectPieces = [
      `o.id as "orderId"`,
      `r.id as "ratingId"`,
      `r.submitted_at as "submittedAt"`
    ];

    if (scoreSource.mode === 'numeric' && scoreSource.columnNames.length > 0) {
      selectPieces.push(`coalesce(${scoreSource.columnNames.map((column) => `r.${this.quoteIdentifier(column)}::numeric`).join(', ')}) as "scoreValue"`);
      selectPieces.push(`null::varchar as "scoreLabel"`);
    } else if (scoreSource.mode === 'label' && scoreSource.columnNames.length > 0) {
      selectPieces.push(`null::numeric as "scoreValue"`);
      selectPieces.push(`coalesce(${scoreSource.columnNames.map((column) => `lower(nullif(trim(r.${this.quoteIdentifier(column)}), ''))`).join(', ')}) as "scoreLabel"`);
    } else {
      selectPieces.push(`null::numeric as "scoreValue"`);
      selectPieces.push(`null::varchar as "scoreLabel"`);
    }

    const rows = (await manager.query(
      `
        select distinct on (o.id)
          ${selectPieces.join(',\n          ')}
        from public.orders o
        join public.ratings r on r.order_id = o.id
        where o.supplier_organization_id = $1
          and o.state = 'completed'
          and r.state = 'submitted'
        order by
          o.id asc,
          r.submitted_at desc nulls last,
          r.updated_at desc nulls last,
          r.created_at desc nulls last,
          r.id desc
      `,
      [organizationId]
    )) as Array<{
      orderId?: string;
      ratingId?: string;
      submittedAt?: string | Date | null;
      scoreValue?: string | number | null;
      scoreLabel?: string | null;
    }>;

    return rows
      .map((row) => ({
        orderId: this.normalizeRequiredId(row.orderId),
        ratingId: this.normalizeRequiredId(row.ratingId),
        submittedAt: this.normalizeDate(row.submittedAt),
        scoreValue:
          typeof row.scoreValue === 'number'
            ? row.scoreValue
            : row.scoreValue === null || row.scoreValue === undefined
              ? null
              : Number(row.scoreValue),
        scoreLabel: this.normalizeNullableText(row.scoreLabel)
      }))
      .filter((row) => row.orderId.length > 0 && row.ratingId.length > 0);
  }

  private async discoverRatingScoreSource(manager: EntityManager): Promise<RatingScoreSourceMode> {
    const rows = (await manager.query(
      `
        select
          column_name as "columnName",
          data_type as "dataType"
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'ratings'
      `
    )) as Array<{ columnName?: string; dataType?: string }>;

    const columnMap = new Map(
      rows
        .map((row) => ({
          columnName: this.normalizeNullableText(row.columnName),
          dataType: this.normalizeNullableText(row.dataType)
        }))
        .filter((row) => row.columnName.length > 0)
        .map((row) => [row.columnName, row.dataType])
    );

    const numericColumns = CREDIT_SHADOW_NUMERIC_SCORE_COLUMNS.filter((column) =>
      columnMap.has(column)
    );
    if (numericColumns.length > 0) {
      return { mode: 'numeric', columnNames: numericColumns };
    }

    const textColumns = CREDIT_SHADOW_TEXT_SCORE_COLUMNS.filter((column) => columnMap.has(column));
    if (textColumns.length > 0) {
      return { mode: 'label', columnNames: textColumns };
    }

    return { mode: 'none' };
  }

  private resolveLedgerScore(previousAggregate: OrganizationCreditShadowAggregateEntity | null) {
    if (!previousAggregate) {
      return null;
    }
    return previousAggregate.publicScore ?? previousAggregate.effectiveScore ?? null;
  }

  private buildLedgerReasonCodes(snapshot: ShadowAggregateSnapshot) {
    return [...snapshot.tierReasonCodes, ...snapshot.postureReasonCodes];
  }

  private normalizeNullableId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private normalizeRequiredId(value: string | undefined) {
    return value?.trim() ?? '';
  }

  private normalizeNullableText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private normalizeDate(value: string | Date | null | undefined) {
    if (!value) {
      return null;
    }
    if (value instanceof Date) {
      return value;
    }
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private quoteIdentifier(columnName: string) {
    return `"${columnName.replace(/"/g, '""')}"`;
  }
}
