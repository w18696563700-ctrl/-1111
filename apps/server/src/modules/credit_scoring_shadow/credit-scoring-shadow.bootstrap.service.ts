import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { CREDIT_SHADOW_MIGRATION_KEY, CREDIT_SHADOW_REASON_CODE_ROWS } from './credit-scoring-shadow.constants';

@Injectable()
export class CreditScoringShadowBootstrapService implements OnApplicationBootstrap {
  private readonly logger = new Logger(CreditScoringShadowBootstrapService.name);

  constructor(private readonly dataSource: DataSource) {}

  async onApplicationBootstrap() {
    await this.run();
  }

  private async run() {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    try {
      await queryRunner.query(`
        CREATE TABLE IF NOT EXISTS server_schema_migration (
          migration_key varchar(128) PRIMARY KEY,
          applied_at timestamptz NOT NULL DEFAULT now()
        )
      `);
      const applied = (await queryRunner.query(
        `SELECT migration_key FROM server_schema_migration WHERE migration_key = $1`,
        [CREDIT_SHADOW_MIGRATION_KEY]
      )) as Array<{ migration_key?: string }>;
      if (applied.length > 0) {
        return;
      }

      await queryRunner.startTransaction();
      try {
        await queryRunner.query(`
          CREATE TABLE IF NOT EXISTS organization_shadow_credit_aggregates (
            organization_id varchar(64) PRIMARY KEY,
            aggregation_mode varchar(32) NOT NULL,
            sample_status varchar(32) NOT NULL,
            rated_completed_order_count integer NOT NULL DEFAULT 0,
            very_satisfied_count integer NOT NULL DEFAULT 0,
            satisfied_count integer NOT NULL DEFAULT 0,
            passable_count integer NOT NULL DEFAULT 0,
            negative_count integer NOT NULL DEFAULT 0,
            positive_rate numeric(6,2) NOT NULL DEFAULT 0,
            negative_rate numeric(6,2) NOT NULL DEFAULT 0,
            recent_consecutive_negative_count integer NOT NULL DEFAULT 0,
            last20_rated_negative_rate numeric(6,2) NOT NULL DEFAULT 0,
            base_score numeric(6,2) NOT NULL DEFAULT 60,
            raw_score numeric(6,2) NOT NULL DEFAULT 0,
            effective_score numeric(6,2) NOT NULL DEFAULT 0,
            public_score numeric(6,2),
            tier_code varchar(8) NOT NULL,
            risk_posture varchar(16) NOT NULL,
            tier_reason_codes jsonb NOT NULL DEFAULT '[]'::jsonb,
            posture_reason_codes jsonb NOT NULL DEFAULT '[]'::jsonb,
            reason_summary text NOT NULL DEFAULT '',
            version integer NOT NULL DEFAULT 1,
            last_rated_order_id varchar(64),
            last_rated_at timestamptz,
            updated_at timestamptz NOT NULL DEFAULT now()
          )
        `);
        await queryRunner.query(`
          CREATE TABLE IF NOT EXISTS organization_shadow_credit_ledgers (
            entry_id varchar(64) PRIMARY KEY,
            organization_id varchar(64) NOT NULL,
            trigger_type varchar(64) NOT NULL,
            source_order_id varchar(64),
            source_rating_id varchar(64),
            before_score numeric(6,2),
            after_score numeric(6,2),
            before_tier_code varchar(8),
            after_tier_code varchar(8),
            before_risk_posture varchar(16),
            after_risk_posture varchar(16),
            reason_codes jsonb NOT NULL DEFAULT '[]'::jsonb,
            changed_at timestamptz NOT NULL
          )
        `);
        await queryRunner.query(`
          CREATE TABLE IF NOT EXISTS organization_shadow_credit_reason_codes (
            code varchar(64) PRIMARY KEY,
            title varchar(128) NOT NULL,
            category varchar(32) NOT NULL,
            description text NOT NULL,
            updated_at timestamptz NOT NULL DEFAULT now()
          )
        `);
        await queryRunner.query(`
          CREATE TABLE IF NOT EXISTS organization_shadow_credit_recompute_triggers (
            trigger_id varchar(64) PRIMARY KEY,
            organization_id varchar(64) NOT NULL,
            trigger_type varchar(64) NOT NULL,
            source_order_id varchar(64),
            source_rating_id varchar(64),
            reason_codes jsonb NOT NULL DEFAULT '[]'::jsonb,
            trigger_status varchar(32) NOT NULL DEFAULT 'processed',
            processed_at timestamptz,
            created_at timestamptz NOT NULL DEFAULT now()
          )
        `);
        await queryRunner.query(`
          CREATE INDEX IF NOT EXISTS idx_org_shadow_credit_ledgers_org_changed
          ON organization_shadow_credit_ledgers (organization_id, changed_at DESC)
        `);
        await queryRunner.query(`
          CREATE INDEX IF NOT EXISTS idx_org_shadow_credit_triggers_org_created
          ON organization_shadow_credit_recompute_triggers (organization_id, created_at DESC)
        `);

        for (const row of CREDIT_SHADOW_REASON_CODE_ROWS) {
          await queryRunner.query(
            `
              INSERT INTO organization_shadow_credit_reason_codes (
                code, title, category, description, updated_at
              ) VALUES ($1, $2, $3, $4, now())
              ON CONFLICT (code) DO UPDATE SET
                title = EXCLUDED.title,
                category = EXCLUDED.category,
                description = EXCLUDED.description,
                updated_at = now()
            `,
            [row.code, row.title, row.category, row.description]
          );
        }

        await queryRunner.query(
          `INSERT INTO server_schema_migration (migration_key) VALUES ($1)`,
          [CREDIT_SHADOW_MIGRATION_KEY]
        );
        await queryRunner.commitTransaction();
        this.logger.log(`applied migration ${CREDIT_SHADOW_MIGRATION_KEY}`);
      } catch (error) {
        await queryRunner.rollbackTransaction();
        throw error;
      }
    } finally {
      await queryRunner.release();
    }
  }
}

