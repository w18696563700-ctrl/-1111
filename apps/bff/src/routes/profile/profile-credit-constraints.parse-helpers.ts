export function requireKeys(source: Record<string, unknown>, keys: string[]) {
  if (keys.every((key) => Object.prototype.hasOwnProperty.call(source, key))) {
    return;
  }
  throw new Error('Credit-and-constraints response is missing required fields.');
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
  const block = requireRecord(value, `Credit-and-constraints ${context} is invalid.`);
  requireKeys(block, ['explanationKey', 'title', 'body']);
  return {
    explanationKey: readRequiredString(
      block.explanationKey,
      `Credit-and-constraints ${context}.explanationKey is invalid.`,
    ),
    title: readRequiredString(
      block.title,
      `Credit-and-constraints ${context}.title is invalid.`,
    ),
    body: readRequiredString(
      block.body,
      `Credit-and-constraints ${context}.body is invalid.`,
    ),
  };
}

export function readHandoffBlock(value: unknown, context: string) {
  const block = requireRecord(value, `Credit-and-constraints ${context} is invalid.`);
  requireKeys(block, ['handoffKey', 'title', 'body']);
  return {
    handoffKey: readRequiredString(
      block.handoffKey,
      `Credit-and-constraints ${context}.handoffKey is invalid.`,
    ),
    title: readRequiredString(
      block.title,
      `Credit-and-constraints ${context}.title is invalid.`,
    ),
    body: readRequiredString(
      block.body,
      `Credit-and-constraints ${context}.body is invalid.`,
    ),
  };
}

export function readDependencyReference(value: unknown) {
  if (value === null) {
    return null;
  }
  const dependency = requireRecord(
    value,
    'Credit-and-constraints dependencyReference is invalid.',
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
      'Credit-and-constraints dependencyReference.dependencyFamilyKey is invalid.',
    ),
    dependencyRequired: readRequiredBoolean(
      dependency.dependencyRequired,
      'Credit-and-constraints dependencyReference.dependencyRequired is invalid.',
    ),
    dependencyExplanationKey: readRequiredString(
      dependency.dependencyExplanationKey,
      'Credit-and-constraints dependencyReference.dependencyExplanationKey is invalid.',
    ),
    dependencyHandoffKey: readRequiredString(
      dependency.dependencyHandoffKey,
      'Credit-and-constraints dependencyReference.dependencyHandoffKey is invalid.',
    ),
  };
}

export function readDependencyExplanation(value: unknown) {
  if (value === null) {
    return null;
  }
  const dependency = requireRecord(
    value,
    'Credit-and-constraints dependencyExplanation is invalid.',
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
      'Credit-and-constraints dependencyExplanation.dependencyFamilyKey is invalid.',
    ),
    dependencyRequired: readRequiredBoolean(
      dependency.dependencyRequired,
      'Credit-and-constraints dependencyExplanation.dependencyRequired is invalid.',
    ),
    dependencyExplanationKey: readRequiredString(
      dependency.dependencyExplanationKey,
      'Credit-and-constraints dependencyExplanation.dependencyExplanationKey is invalid.',
    ),
    title: readRequiredString(
      dependency.title,
      'Credit-and-constraints dependencyExplanation.title is invalid.',
    ),
    body: readRequiredString(
      dependency.body,
      'Credit-and-constraints dependencyExplanation.body is invalid.',
    ),
  };
}

export function readDependencyHandoff(value: unknown) {
  if (value === null) {
    return null;
  }
  const dependency = requireRecord(
    value,
    'Credit-and-constraints dependencyHandoff is invalid.',
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
      'Credit-and-constraints dependencyHandoff.dependencyFamilyKey is invalid.',
    ),
    dependencyRequired: readRequiredBoolean(
      dependency.dependencyRequired,
      'Credit-and-constraints dependencyHandoff.dependencyRequired is invalid.',
    ),
    dependencyHandoffKey: readRequiredString(
      dependency.dependencyHandoffKey,
      'Credit-and-constraints dependencyHandoff.dependencyHandoffKey is invalid.',
    ),
    title: readRequiredString(
      dependency.title,
      'Credit-and-constraints dependencyHandoff.title is invalid.',
    ),
    body: readRequiredString(
      dependency.body,
      'Credit-and-constraints dependencyHandoff.body is invalid.',
    ),
  };
}
