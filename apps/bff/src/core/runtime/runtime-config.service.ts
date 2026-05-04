import { Injectable } from "@nestjs/common";

const DEFAULT_APP_NAME = "exhibition-bff";
const DEFAULT_PORT = 3000;
const DEFAULT_SERVER_BASE_URL = "http://127.0.0.1:3001";
const DEFAULT_SERVER_GET_TIMEOUT_MS = 5000;
const DEFAULT_SERVER_POST_TIMEOUT_MS = 10000;

function readIntegerEnv(name: string, fallback: number) {
  const raw = process.env[name];
  if (!raw) {
    return fallback;
  }
  const parsed = Number.parseInt(raw, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

@Injectable()
export class RuntimeConfigService {
  readonly appName = process.env.APP_NAME?.trim() || DEFAULT_APP_NAME;
  readonly nodeEnv = process.env.NODE_ENV?.trim() || "development";
  readonly runtimeEntryLabel =
    process.env.RUNTIME_ENTRY_LABEL?.trim() || "local-dev";
  readonly port = readIntegerEnv("PORT", DEFAULT_PORT);
  readonly serverBaseUrl =
    process.env.SERVER_BASE_URL?.trim() || DEFAULT_SERVER_BASE_URL;
  readonly serverGetTimeoutMs = readIntegerEnv(
    "SERVER_GET_TIMEOUT_MS",
    DEFAULT_SERVER_GET_TIMEOUT_MS,
  );
  readonly serverPostTimeoutMs = readIntegerEnv(
    "SERVER_POST_TIMEOUT_MS",
    DEFAULT_SERVER_POST_TIMEOUT_MS,
  );

  get hasExplicitServerBaseUrl() {
    return Boolean(process.env.SERVER_BASE_URL?.trim());
  }
}
