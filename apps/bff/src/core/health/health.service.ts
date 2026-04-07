import { Injectable } from '@nestjs/common';
import { RuntimeConfigService } from '../runtime/runtime-config.service';

@Injectable()
export class HealthService {
  constructor(private readonly config: RuntimeConfigService) {}

  live() {
    return {
      status: 'ok',
      service: this.config.appName,
      port: this.config.port,
      timestamp: new Date().toISOString(),
    };
  }

  ready() {
    return {
      status: 'ready',
      service: this.config.appName,
      timestamp: new Date().toISOString(),
    };
  }
}
