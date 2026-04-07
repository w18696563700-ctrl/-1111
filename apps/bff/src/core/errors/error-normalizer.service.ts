import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { isAxiosError } from 'axios';
import type { AxiosError } from 'axios';
import type { NormalizedErrorBody } from '../../shared/api';

@Injectable()
export class ErrorNormalizerService {
  toHttpException(
    error: unknown,
    fallbackCode: string,
    fallbackMessage: string,
    statusCodeMap: Partial<Record<number, string>> = {},
  ): HttpException {
    if (error instanceof HttpException) {
      return error;
    }

    if (isAxiosError<Record<string, unknown>>(error) && error.response) {
      const statusCode = error.response.status;
      const payload = this.asRecord(error.response.data);
      const body: NormalizedErrorBody = {
        statusCode,
        code:
          typeof payload.code === 'string'
            ? payload.code
            : statusCodeMap[statusCode] ?? fallbackCode,
        message:
          typeof payload.message === 'string'
            ? payload.message
            : fallbackMessage,
        details: payload.details ?? this.toOpaqueResponseDetails(error),
        source:
          payload.source === 'bff' || payload.source === 'server'
            ? payload.source
            : 'server',
      };
      return new HttpException(body, statusCode);
    }

    if (isAxiosError(error)) {
      const body: NormalizedErrorBody = {
        statusCode:
          error.code === 'ECONNABORTED'
            ? HttpStatus.GATEWAY_TIMEOUT
            : HttpStatus.BAD_GATEWAY,
        code: fallbackCode,
        message: fallbackMessage,
        details: this.toTransportDetails(error),
        source: 'bff',
      };
      return new HttpException(body, body.statusCode);
    }

    const body: NormalizedErrorBody = {
      statusCode: HttpStatus.BAD_GATEWAY,
      code: fallbackCode,
      message: fallbackMessage,
      details: this.toUnknownDetails(error),
      source: 'bff',
    };
    return new HttpException(body, body.statusCode);
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? (value as Record<string, unknown>)
      : {};
  }

  private toOpaqueResponseDetails(error: AxiosError): Record<string, unknown> {
    return {
      transportCode: error.code ?? 'unknown',
      upstreamMessage: error.message,
    };
  }

  private toTransportDetails(error: AxiosError): Record<string, unknown> {
    return {
      transportCode: error.code ?? 'unknown',
      upstreamMessage: error.message,
    };
  }

  private toUnknownDetails(error: unknown): Record<string, unknown> | undefined {
    if (error instanceof Error) {
      return {
        name: error.name,
        message: error.message,
      };
    }
    return undefined;
  }
}
