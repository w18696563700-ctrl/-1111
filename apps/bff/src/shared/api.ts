export type NormalizedErrorBody = {
  statusCode: number;
  code: string;
  message: string;
  details?: unknown;
  source: 'bff' | 'server';
};
