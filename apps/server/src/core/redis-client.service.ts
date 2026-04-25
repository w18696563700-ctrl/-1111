import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { createClient } from 'redis';
import { RuntimeConfigService } from './runtime-config.service';

type RedisConnection = ReturnType<typeof createClient>;

@Injectable()
export class RedisClientService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisClientService.name);
  private client: RedisConnection | null = null;
  private connectPromise: Promise<RedisConnection | null> | null = null;
  private disabledLogged = false;

  constructor(private readonly config: RuntimeConfigService) {}

  async getJson<T>(key: string): Promise<T | null> {
    const client = await this.getClient();
    if (!client) {
      return null;
    }

    try {
      const payload = await client.get(key);
      if (!payload) {
        return null;
      }
      return JSON.parse(String(payload)) as T;
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown redis read failure.';
      this.logger.warn(`redis get failed for ${key}: ${message}`);
      return null;
    }
  }

  async setJson(key: string, value: unknown, ttlSeconds: number) {
    const client = await this.getClient();
    if (!client) {
      return;
    }

    try {
      await client.set(key, JSON.stringify(value), { EX: ttlSeconds });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown redis write failure.';
      this.logger.warn(`redis set failed for ${key}: ${message}`);
    }
  }

  async onModuleDestroy() {
    if (!this.client?.isOpen) {
      return;
    }
    await this.client.quit();
  }

  private async getClient(): Promise<RedisConnection | null> {
    if (!this.config.redisEnabled) {
      if (!this.disabledLogged) {
        this.logger.warn(
          'redis runtime is disabled; weather cache will run as pass-through',
        );
        this.disabledLogged = true;
      }
      return null;
    }

    if (this.client?.isOpen) {
      return this.client;
    }
    if (this.connectPromise) {
      return this.connectPromise;
    }

    this.connectPromise = this.connect();
    return this.connectPromise;
  }

  private async connect(): Promise<RedisConnection | null> {
    const client = createClient({
      url: this.config.redisUrl,
    });

    client.on('error', (error) => {
      const message =
        error instanceof Error ? error.message : 'Unknown redis runtime error.';
      this.logger.warn(`redis runtime error: ${message}`);
    });

    try {
      await client.connect();
      this.client = client;
      return client;
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown redis connect failure.';
      this.logger.warn(`redis connect failed: ${message}`);
      try {
        if (client.isOpen) {
          await client.disconnect();
        }
      } catch {
        return null;
      } finally {
        this.connectPromise = null;
      }
      return null;
    } finally {
      if (this.client?.isOpen) {
        this.connectPromise = null;
      }
    }
  }
}
