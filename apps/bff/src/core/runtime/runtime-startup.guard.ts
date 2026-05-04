import { Logger } from "@nestjs/common";
import { RuntimeConfigService } from "./runtime-config.service";

type StartupLogger = Pick<Logger, "log" | "warn">;

const DEFAULT_LOGGER = new Logger("BffRuntimeStartupGuard");

function isCloudRuntime(config: RuntimeConfigService) {
  return config.runtimeEntryLabel === "cloud-host";
}

export function assertBffRuntimeBoundary(
  config: RuntimeConfigService,
  logger: StartupLogger = DEFAULT_LOGGER,
) {
  if (
    config.nodeEnv === "production" &&
    isCloudRuntime(config) &&
    !config.hasExplicitServerBaseUrl
  ) {
    throw new Error(
      "BFF production cloud runtime cannot start with implicit SERVER_BASE_URL fallback.",
    );
  }

  if (!config.hasExplicitServerBaseUrl) {
    logger.warn(
      `BFF runtime using implicit SERVER_BASE_URL fallback: ${config.serverBaseUrl}`,
    );
    return;
  }

  logger.log(
    `BFF runtime SERVER_BASE_URL configured for ${config.runtimeEntryLabel}.`,
  );
}
