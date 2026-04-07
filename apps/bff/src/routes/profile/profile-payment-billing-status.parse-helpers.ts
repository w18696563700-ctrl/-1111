export function requireKeys(source: Record<string, unknown>, keys: string[]) {
  if (keys.every((key) => Object.prototype.hasOwnProperty.call(source, key))) {
    return;
  }
  throw new Error('Payment-and-billing-status response is missing required fields.');
}

export function requireRecord(value: unknown, message: string) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

export function readRequiredString(value: unknown, message: string) {
  if (typeof value !== 'string') {
    throw new Error(message);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(message);
  }
  return normalized;
}

export function readNullableString(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  return readRequiredString(value, 'Expected a string value.');
}

export function readRequiredBoolean(value: unknown, message: string) {
  if (typeof value !== 'boolean') {
    throw new Error(message);
  }
  return value;
}

export function readExplanationBlock(value: unknown, context: string) {
  const block = requireRecord(value, `Payment-and-billing-status ${context} is invalid.`);
  requireKeys(block, ['explanationKey', 'title', 'body']);
  return {
    explanationKey: readRequiredString(
      block.explanationKey,
      `Payment-and-billing-status ${context}.explanationKey is invalid.`,
    ),
    title: readRequiredString(
      block.title,
      `Payment-and-billing-status ${context}.title is invalid.`,
    ),
    body: readRequiredString(
      block.body,
      `Payment-and-billing-status ${context}.body is invalid.`,
    ),
  };
}

export function readHandoffBlock(value: unknown, context: string, keyName: string) {
  const block = requireRecord(value, `Payment-and-billing-status ${context} is invalid.`);
  requireKeys(block, [keyName, 'title', 'body']);
  return {
    [keyName]: readRequiredString(
      block[keyName],
      `Payment-and-billing-status ${context}.${keyName} is invalid.`,
    ),
    title: readRequiredString(
      block.title,
      `Payment-and-billing-status ${context}.title is invalid.`,
    ),
    body: readRequiredString(
      block.body,
      `Payment-and-billing-status ${context}.body is invalid.`,
    ),
  };
}

export function readDependencyReference(value: unknown) {
  if (value === null) {
    return null;
  }
  const dependency = requireRecord(
    value,
    'Payment-and-billing-status dependencyReference is invalid.',
  );
  requireKeys(dependency, [
    'dependencyFamilyKey',
    'dependencyRequired',
    'dependencyExplanationKey',
    'dependencyHandoffKey',
  ]);
  return {
    dependencyFamilyKey: readRequiredString(
      dependency.dependencyFamilyKey,
      'Payment-and-billing-status dependencyReference.dependencyFamilyKey is invalid.',
    ),
    dependencyRequired: readRequiredBoolean(
      dependency.dependencyRequired,
      'Payment-and-billing-status dependencyReference.dependencyRequired is invalid.',
    ),
    dependencyExplanationKey: readRequiredString(
      dependency.dependencyExplanationKey,
      'Payment-and-billing-status dependencyReference.dependencyExplanationKey is invalid.',
    ),
    dependencyHandoffKey: readRequiredString(
      dependency.dependencyHandoffKey,
      'Payment-and-billing-status dependencyReference.dependencyHandoffKey is invalid.',
    ),
  };
}

export function readDependencyExplanation(value: unknown) {
  if (value === null) {
    return null;
  }
  const dependency = requireRecord(
    value,
    'Payment-and-billing-status dependencyExplanation is invalid.',
  );
  requireKeys(dependency, [
    'dependencyFamilyKey',
    'dependencyRequired',
    'dependencyExplanationKey',
    'title',
    'body',
  ]);
  return {
    dependencyFamilyKey: readRequiredString(
      dependency.dependencyFamilyKey,
      'Payment-and-billing-status dependencyExplanation.dependencyFamilyKey is invalid.',
    ),
    dependencyRequired: readRequiredBoolean(
      dependency.dependencyRequired,
      'Payment-and-billing-status dependencyExplanation.dependencyRequired is invalid.',
    ),
    dependencyExplanationKey: readRequiredString(
      dependency.dependencyExplanationKey,
      'Payment-and-billing-status dependencyExplanation.dependencyExplanationKey is invalid.',
    ),
    title: readRequiredString(
      dependency.title,
      'Payment-and-billing-status dependencyExplanation.title is invalid.',
    ),
    body: readRequiredString(
      dependency.body,
      'Payment-and-billing-status dependencyExplanation.body is invalid.',
    ),
  };
}

export function readDependencyHandoff(value: unknown) {
  if (value === null) {
    return null;
  }
  const dependency = requireRecord(
    value,
    'Payment-and-billing-status dependencyHandoff is invalid.',
  );
  requireKeys(dependency, [
    'dependencyFamilyKey',
    'dependencyRequired',
    'dependencyHandoffKey',
    'title',
    'body',
  ]);
  return {
    dependencyFamilyKey: readRequiredString(
      dependency.dependencyFamilyKey,
      'Payment-and-billing-status dependencyHandoff.dependencyFamilyKey is invalid.',
    ),
    dependencyRequired: readRequiredBoolean(
      dependency.dependencyRequired,
      'Payment-and-billing-status dependencyHandoff.dependencyRequired is invalid.',
    ),
    dependencyHandoffKey: readRequiredString(
      dependency.dependencyHandoffKey,
      'Payment-and-billing-status dependencyHandoff.dependencyHandoffKey is invalid.',
    ),
    title: readRequiredString(
      dependency.title,
      'Payment-and-billing-status dependencyHandoff.title is invalid.',
    ),
    body: readRequiredString(
      dependency.body,
      'Payment-and-billing-status dependencyHandoff.body is invalid.',
    ),
  };
}
