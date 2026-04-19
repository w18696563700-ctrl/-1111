import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { DataSource } from 'typeorm';

const BID_SEAT_MIGRATION_KEY = '20260413_bid_seats_truth';

@Injectable()
export class BidSeatMigrationService implements OnApplicationBootstrap {
  private readonly logger = new Logger(BidSeatMigrationService.name);

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
        [BID_SEAT_MIGRATION_KEY]
      )) as Array<{ migration_key?: string }>;
      if (applied.length > 0) {
        return;
      }

      await queryRunner.startTransaction();
      try {
        await queryRunner.query(`
          CREATE TABLE IF NOT EXISTS bid_seats (
            seat_id varchar(64) PRIMARY KEY,
            project_id varchar(64) NOT NULL,
            bid_id varchar(64) NOT NULL,
            state varchar(32) NOT NULL DEFAULT 'locked',
            locked_at timestamptz NOT NULL,
            expires_at timestamptz NOT NULL,
            released_at timestamptz,
            updated_at timestamptz NOT NULL DEFAULT now(),
            CONSTRAINT chk_bid_seats_state
              CHECK (state IN ('locked', 'released', 'timed_out'))
          )
        `);
        await queryRunner.query(`
          CREATE UNIQUE INDEX IF NOT EXISTS idx_bid_seats_project_bid_unique
          ON bid_seats (project_id, bid_id)
        `);
        await queryRunner.query(`
          CREATE INDEX IF NOT EXISTS idx_bid_seats_project_state_updated
          ON bid_seats (project_id, state, updated_at DESC)
        `);
        await queryRunner.query(
          `INSERT INTO server_schema_migration (migration_key) VALUES ($1)`,
          [BID_SEAT_MIGRATION_KEY]
        );
        await queryRunner.commitTransaction();
        this.logger.log(`applied migration ${BID_SEAT_MIGRATION_KEY}`);
      } catch (error) {
        await queryRunner.rollbackTransaction();
        throw error;
      }
    } finally {
      await queryRunner.release();
    }
  }
}
