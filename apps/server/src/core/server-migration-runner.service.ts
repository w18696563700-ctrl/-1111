import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { serverMigrations } from './migrations/migrations';

@Injectable()
export class ServerMigrationRunnerService implements OnApplicationBootstrap {
  private readonly logger = new Logger(ServerMigrationRunnerService.name);

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
      const rows = (await queryRunner.query(
        `SELECT migration_key FROM server_schema_migration`,
      )) as Array<{ migration_key?: string }>;
      const appliedKeys = new Set(
        rows
          .map((row) => row.migration_key?.trim() ?? '')
          .filter((value) => value.length > 0),
      );
      const knownKeys = [...appliedKeys].sort();
      this.logger.log(
        `server_schema_migration snapshot count=${knownKeys.length} keys=${knownKeys.join(', ') || 'none'}`,
      );
      const appliedThisBoot: string[] = [];

      for (const migration of serverMigrations) {
        if (appliedKeys.has(migration.key)) {
          continue;
        }
        await queryRunner.startTransaction();
        try {
          for (const statement of migration.statements) {
            await queryRunner.query(statement);
          }
          await queryRunner.query(
            `INSERT INTO server_schema_migration (migration_key) VALUES ($1)`,
            [migration.key],
          );
          appliedKeys.add(migration.key);
          appliedThisBoot.push(migration.key);
          await queryRunner.commitTransaction();
          this.logger.log(`applied migration ${migration.key}`);
        } catch (error) {
          await queryRunner.rollbackTransaction();
          throw error;
        }
      }
      this.logger.log(
        `migration reconciliation complete; appliedThisBoot=${appliedThisBoot.join(', ') || 'none'}`,
      );
    } finally {
      await queryRunner.release();
    }
  }
}
