import { Agent as HttpAgent } from 'http';
import { Agent as HttpsAgent } from 'https';
import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
import type { AxiosRequestConfig, Method } from 'axios';
import { RuntimeConfigService } from '../runtime/runtime-config.service';

type RequestOptions = {
  headers?: Record<string, string>;
  params?: Record<string, string | number | boolean | undefined>;
};

@Injectable()
export class ServerClientService {
  private readonly logger = new Logger(ServerClientService.name);
  private readonly httpAgent: HttpAgent;
  private readonly httpsAgent: HttpsAgent;

  constructor(
    private readonly httpService: HttpService,
    private readonly config: RuntimeConfigService,
  ) {
    const agentOptions = {
      keepAlive: this.config.serverKeepAliveEnabled,
      maxSockets: this.config.serverMaxSockets,
      maxFreeSockets: this.config.serverMaxFreeSockets,
    };
    this.httpAgent = new HttpAgent(agentOptions);
    this.httpsAgent = new HttpsAgent(agentOptions);
  }

  async get<T>(path: string, options: RequestOptions = {}): Promise<T> {
    return this.send<T>('GET', path, undefined, options, this.config.serverGetTimeoutMs);
  }

  async post<T>(path: string, body: unknown, options: RequestOptions = {}): Promise<T> {
    return this.send<T>('POST', path, body, options, this.config.serverPostTimeoutMs);
  }

  async put<T>(path: string, body: unknown, options: RequestOptions = {}): Promise<T> {
    return this.send<T>('PUT', path, body, options, this.config.serverPostTimeoutMs);
  }

  async patch<T>(path: string, body: unknown, options: RequestOptions = {}): Promise<T> {
    return this.send<T>('PATCH', path, body, options, this.config.serverPostTimeoutMs);
  }

  async delete<T>(path: string, options: RequestOptions = {}): Promise<T> {
    return this.send<T>('DELETE', path, undefined, options, this.config.serverPostTimeoutMs);
  }

  private async send<T>(
    method: Method,
    path: string,
    body: unknown,
    options: RequestOptions,
    timeout: number,
  ): Promise<T> {
    const requestId = options.headers?.['x-request-id'] ?? 'missing';
    const traceId = options.headers?.['x-trace-id'] ?? 'missing';
    const startedAt = Date.now();
    const requestConfig: AxiosRequestConfig<unknown> = {
      url: `${this.config.serverBaseUrl}${path}`,
      method,
      data: body,
      timeout,
      headers: options.headers,
      params: options.params,
      httpAgent: this.httpAgent,
      httpsAgent: this.httpsAgent,
    };

    try {
      const response = await this.httpService.axiosRef.request<T>(requestConfig);
      this.logger.log(
        `${method} ${path} upstream_status=${response.status} duration_ms=${Date.now() - startedAt} request_id=${requestId} trace_id=${traceId}`,
      );
      return response.data;
    } catch (error) {
      const transportError = error as {
        code?: string;
        message?: string;
        response?: {
          status?: number;
        };
      };
      const logLine =
        `${method} ${path} upstream_status=${transportError.response?.status ?? 'transport_error'} ` +
        `duration_ms=${Date.now() - startedAt} request_id=${requestId} trace_id=${traceId} ` +
        `error_code=${transportError.code ?? 'unknown'} message=${transportError.message ?? 'request failed'}`;
      if (transportError.code === 'ECONNABORTED') {
        this.logger.warn(logLine);
      } else {
        this.logger.error(logLine);
      }
      throw error;
    }
  }
}
