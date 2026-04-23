type TradingImPayload = Record<string, unknown>;

const MESSAGE_KINDS = new Set(['actor_message', 'system_seed']);

export function readBidThreadDetailReadModel(value: unknown) {
  const record = requireRecord(value, 'Bid thread detail response must be an object.');
  const messages = Array.isArray(record.messages) ? record.messages : null;
  if (!messages) {
    return record;
  }

  return {
    ...record,
    messages: messages.map((item, index) =>
      readBidThreadMessage(
        requireRecord(item, `Bid thread detail message[${index}] must be an object.`),
      ),
    ),
  };
}

function readBidThreadMessage(record: TradingImPayload) {
  const normalizedKind = readMessageKind(record.messageKind);
  if (normalizedKind !== 'system_seed') {
    return {
      ...record,
      messageKind: normalizedKind,
    };
  }

  if (readOptionalString(record.systemSeedType) !== 'bid_submitted') {
    return {
      ...record,
      messageKind: 'actor_message',
    };
  }

  return compactRecord({
    ...record,
    messageKind: 'system_seed',
    systemSeedType: 'bid_submitted',
    systemSeedAction: readSystemSeedAction(record.systemSeedAction),
  });
}

function readMessageKind(value: unknown) {
  const normalized = readOptionalString(value);
  if (normalized && MESSAGE_KINDS.has(normalized)) {
    return normalized;
  }
  return 'actor_message';
}

function readSystemSeedAction(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return undefined;
  }
  const record = value as TradingImPayload;
  if (readOptionalString(record.actionKey) !== 'bid_submission_snapshot.open') {
    return undefined;
  }

  return compactRecord({
    objectType: readOptionalString(record.objectType) ?? 'bid_submission_snapshot',
    actionKey: 'bid_submission_snapshot.open',
    canonicalPath: readOptionalString(record.canonicalPath),
    params: readOptionalStringMap(record.params),
  });
}

function readOptionalStringMap(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return undefined;
  }

  const result: Record<string, string> = {};
  for (const [key, rawValue] of Object.entries(value as TradingImPayload)) {
    const normalized = readOptionalString(rawValue);
    if (normalized) {
      result[key] = normalized;
    }
  }
  return Object.keys(result).length > 0 ? result : undefined;
}

function compactRecord<T extends Record<string, unknown>>(value: T) {
  const result: Record<string, unknown> = {};
  for (const [key, rawValue] of Object.entries(value)) {
    if (rawValue !== undefined) {
      result[key] = rawValue;
    }
  }
  return result as T;
}

function requireRecord(value: unknown, message: string) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as TradingImPayload;
  }
  throw new Error(message);
}

function readOptionalString(value: unknown) {
  if (typeof value !== 'string') {
    return undefined;
  }
  const normalized = value.trim();
  return normalized ? normalized : undefined;
}
