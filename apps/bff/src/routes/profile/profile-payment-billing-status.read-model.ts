import {
  readDependencyExplanation,
  readDependencyHandoff,
  readDependencyReference,
  readExplanationBlock,
  readHandoffBlock,
  readNullableString,
  readRequiredBoolean,
  readRequiredString,
  requireKeys,
  requireRecord,
} from './profile-payment-billing-status.parse-helpers';

export type PaymentAndBillingStatusViewModel = {
  privateSummary: {
    entryKey: string;
    summaryStatus: string;
    paymentStatus: string;
    billingReferenceStatus: string;
    updatedAt: string;
  };
  paymentStatus: {
    paymentStatus: string;
    paymentAvailabilityStatus: string;
    paymentHandoffKey: string;
    paymentExplanationKey: string;
    paymentDependencyKey: string | null;
    updatedAt: string;
  };
  billingReference: {
    billingReferenceStatus: string;
    billingReferenceCode: string | null;
    billingReferenceVisibilityStatus: string;
    billingExplanationKey: string;
    billingHandoffKey: string;
    billingDependencyKey: string | null;
    updatedAt: string;
  };
  dependencyReference: {
    dependencyFamilyKey: string;
    dependencyRequired: boolean;
    dependencyExplanationKey: string;
    dependencyHandoffKey: string;
  } | null;
};

export type PaymentAndBillingExplanationViewModel = {
  paymentExplanation: {
    explanationKey: string;
    title: string;
    body: string;
  };
  billingExplanation: {
    explanationKey: string;
    title: string;
    body: string;
  };
  dependencyExplanation: {
    dependencyFamilyKey: string;
    dependencyRequired: boolean;
    dependencyExplanationKey: string;
    title: string;
    body: string;
  } | null;
  disclaimer: string;
};

export type PaymentAndBillingHandoffViewModel = {
  paymentHandoff: {
    paymentHandoffKey: string;
    handoffStatus: string;
    handoffTargetFamily: string;
    handoffExplanationKey: string;
    dependencyRequired: boolean;
    title: string;
    body: string;
    updatedAt: string;
  };
  billingHandoff: {
    billingHandoffKey: string;
    title: string;
    body: string;
    updatedAt: string;
  };
  dependencyHandoff: {
    dependencyFamilyKey: string;
    dependencyRequired: boolean;
    dependencyHandoffKey: string;
    title: string;
    body: string;
  } | null;
};

export function readPaymentAndBillingStatusViewModel(
  result: Record<string, unknown>,
): PaymentAndBillingStatusViewModel {
  requireKeys(result, [
    'privateSummary',
    'paymentStatus',
    'billingReference',
    'dependencyReference',
  ]);

  const privateSummary = requireRecord(
    result.privateSummary,
    'Payment-and-billing-status response is missing privateSummary.',
  );
  const paymentStatus = requireRecord(
    result.paymentStatus,
    'Payment-and-billing-status response is missing paymentStatus.',
  );
  const billingReference = requireRecord(
    result.billingReference,
    'Payment-and-billing-status response is missing billingReference.',
  );

  requireKeys(privateSummary, [
    'entryKey',
    'summaryStatus',
    'paymentStatus',
    'billingReferenceStatus',
    'updatedAt',
  ]);
  requireKeys(paymentStatus, [
    'paymentStatus',
    'paymentAvailabilityStatus',
    'paymentHandoffKey',
    'paymentExplanationKey',
    'paymentDependencyKey',
    'updatedAt',
  ]);
  requireKeys(billingReference, [
    'billingReferenceStatus',
    'billingReferenceCode',
    'billingReferenceVisibilityStatus',
    'billingExplanationKey',
    'billingHandoffKey',
    'billingDependencyKey',
    'updatedAt',
  ]);

  return {
    privateSummary: {
      entryKey: readRequiredString(
        privateSummary.entryKey,
        'Payment-and-billing-status privateSummary.entryKey is invalid.',
      ),
      summaryStatus: readRequiredString(
        privateSummary.summaryStatus,
        'Payment-and-billing-status privateSummary.summaryStatus is invalid.',
      ),
      paymentStatus: readRequiredString(
        privateSummary.paymentStatus,
        'Payment-and-billing-status privateSummary.paymentStatus is invalid.',
      ),
      billingReferenceStatus: readRequiredString(
        privateSummary.billingReferenceStatus,
        'Payment-and-billing-status privateSummary.billingReferenceStatus is invalid.',
      ),
      updatedAt: readRequiredString(
        privateSummary.updatedAt,
        'Payment-and-billing-status privateSummary.updatedAt is invalid.',
      ),
    },
    paymentStatus: {
      paymentStatus: readRequiredString(
        paymentStatus.paymentStatus,
        'Payment-and-billing-status paymentStatus.paymentStatus is invalid.',
      ),
      paymentAvailabilityStatus: readRequiredString(
        paymentStatus.paymentAvailabilityStatus,
        'Payment-and-billing-status paymentStatus.paymentAvailabilityStatus is invalid.',
      ),
      paymentHandoffKey: readRequiredString(
        paymentStatus.paymentHandoffKey,
        'Payment-and-billing-status paymentStatus.paymentHandoffKey is invalid.',
      ),
      paymentExplanationKey: readRequiredString(
        paymentStatus.paymentExplanationKey,
        'Payment-and-billing-status paymentStatus.paymentExplanationKey is invalid.',
      ),
      paymentDependencyKey: readNullableString(paymentStatus.paymentDependencyKey),
      updatedAt: readRequiredString(
        paymentStatus.updatedAt,
        'Payment-and-billing-status paymentStatus.updatedAt is invalid.',
      ),
    },
    billingReference: {
      billingReferenceStatus: readRequiredString(
        billingReference.billingReferenceStatus,
        'Payment-and-billing-status billingReference.billingReferenceStatus is invalid.',
      ),
      billingReferenceCode: readNullableString(billingReference.billingReferenceCode),
      billingReferenceVisibilityStatus: readRequiredString(
        billingReference.billingReferenceVisibilityStatus,
        'Payment-and-billing-status billingReference.billingReferenceVisibilityStatus is invalid.',
      ),
      billingExplanationKey: readRequiredString(
        billingReference.billingExplanationKey,
        'Payment-and-billing-status billingReference.billingExplanationKey is invalid.',
      ),
      billingHandoffKey: readRequiredString(
        billingReference.billingHandoffKey,
        'Payment-and-billing-status billingReference.billingHandoffKey is invalid.',
      ),
      billingDependencyKey: readNullableString(billingReference.billingDependencyKey),
      updatedAt: readRequiredString(
        billingReference.updatedAt,
        'Payment-and-billing-status billingReference.updatedAt is invalid.',
      ),
    },
    dependencyReference: readDependencyReference(result.dependencyReference),
  };
}

export function readPaymentAndBillingExplanationViewModel(
  result: Record<string, unknown>,
): PaymentAndBillingExplanationViewModel {
  requireKeys(result, [
    'paymentExplanation',
    'billingExplanation',
    'dependencyExplanation',
    'disclaimer',
  ]);

  return {
    paymentExplanation: readExplanationBlock(
      result.paymentExplanation,
      'paymentExplanation',
    ),
    billingExplanation: readExplanationBlock(
      result.billingExplanation,
      'billingExplanation',
    ),
    dependencyExplanation: readDependencyExplanation(result.dependencyExplanation),
    disclaimer: readRequiredString(
      result.disclaimer,
      'Payment-and-billing-status disclaimer is invalid.',
    ),
  };
}

export function readPaymentAndBillingHandoffViewModel(
  result: Record<string, unknown>,
): PaymentAndBillingHandoffViewModel {
  requireKeys(result, ['paymentHandoff', 'billingHandoff', 'dependencyHandoff']);

  const paymentHandoff = requireRecord(
    result.paymentHandoff,
    'Payment-and-billing-status paymentHandoff is invalid.',
  );
  const billingHandoff = requireRecord(
    result.billingHandoff,
    'Payment-and-billing-status billingHandoff is invalid.',
  );

  requireKeys(paymentHandoff, [
    'paymentHandoffKey',
    'handoffStatus',
    'handoffTargetFamily',
    'handoffExplanationKey',
    'dependencyRequired',
    'title',
    'body',
    'updatedAt',
  ]);
  requireKeys(billingHandoff, ['billingHandoffKey', 'title', 'body', 'updatedAt']);

  const paymentBlock = readHandoffBlock(
    paymentHandoff,
    'paymentHandoff',
    'paymentHandoffKey',
  ) as {
    paymentHandoffKey: string;
    title: string;
    body: string;
  };
  const billingBlock = readHandoffBlock(
    billingHandoff,
    'billingHandoff',
    'billingHandoffKey',
  ) as {
    billingHandoffKey: string;
    title: string;
    body: string;
  };

  return {
    paymentHandoff: {
      paymentHandoffKey: paymentBlock.paymentHandoffKey,
      handoffStatus: readRequiredString(
        paymentHandoff.handoffStatus,
        'Payment-and-billing-status paymentHandoff.handoffStatus is invalid.',
      ),
      handoffTargetFamily: readRequiredString(
        paymentHandoff.handoffTargetFamily,
        'Payment-and-billing-status paymentHandoff.handoffTargetFamily is invalid.',
      ),
      handoffExplanationKey: readRequiredString(
        paymentHandoff.handoffExplanationKey,
        'Payment-and-billing-status paymentHandoff.handoffExplanationKey is invalid.',
      ),
      dependencyRequired: readRequiredBoolean(
        paymentHandoff.dependencyRequired,
        'Payment-and-billing-status paymentHandoff.dependencyRequired is invalid.',
      ),
      title: paymentBlock.title,
      body: paymentBlock.body,
      updatedAt: readRequiredString(
        paymentHandoff.updatedAt,
        'Payment-and-billing-status paymentHandoff.updatedAt is invalid.',
      ),
    },
    billingHandoff: {
      billingHandoffKey: billingBlock.billingHandoffKey,
      title: billingBlock.title,
      body: billingBlock.body,
      updatedAt: readRequiredString(
        billingHandoff.updatedAt,
        'Payment-and-billing-status billingHandoff.updatedAt is invalid.',
      ),
    },
    dependencyHandoff: readDependencyHandoff(result.dependencyHandoff),
  };
}
