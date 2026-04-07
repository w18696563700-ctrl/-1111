import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { RuntimeConfigService } from './runtime-config.service';

@Injectable()
export class HealthService {
  constructor(
    private readonly config: RuntimeConfigService,
    private readonly dataSource: DataSource
  ) {}

  async getLive() {
    return {
      status: 'ok',
      service: this.config.appName,
      port: this.config.port,
      timestamp: new Date().toISOString()
    };
  }

  async getReady() {
    const ready = this.dataSource.isInitialized;
    return {
      status: ready ? 'ready' : 'not_ready',
      service: this.config.appName,
      timestamp: new Date().toISOString()
    };
  }
}
