import { APP_API_PATHS } from '../../../../packages/contracts/src/generated/app-api.types';
import type { AppApiPath } from '../../../../packages/contracts/src/generated/app-api.types';
import { ERROR_CODE_DEFINITIONS } from '../../../../packages/contracts/src/generated/error-codes';
import type { ErrorCode } from '../../../../packages/contracts/src/generated/error-codes';

const APP_API_PATH_SET = new Set<string>(APP_API_PATHS);
const ERROR_CODE_SET = new Set<string>(Object.keys(ERROR_CODE_DEFINITIONS));

export function requireAppApiPath<Path extends AppApiPath>(path: Path): Path {
  if (!APP_API_PATH_SET.has(path)) {
    throw new Error(`Frozen app api path missing from generated contracts: ${path}`);
  }
  return path;
}

export function requireErrorCode<Code extends ErrorCode>(code: Code): Code {
  if (!ERROR_CODE_SET.has(code)) {
    throw new Error(`Frozen error code missing from generated contracts: ${code}`);
  }
  return code;
}
