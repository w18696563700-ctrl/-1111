import {
  readDependencyExplanation,
  readDependencyHandoff,
  readDependencyReference,
  readExplanationBlock,
  readHandoffBlock,
  readNullableString,
  readRequiredString,
  requireKeys,
  requireRecord,
} from './profile-credit-constraints.parse-helpers';

export type CreditConstraintsStatusViewModel = {
  privateSummary: {
    entryKey: string;
    summaryStatus: string;
    creditConstraintStatus: string;
    depositPostureStatus: string;
    transactionGuaranteeEligibilityStatus: string;
    updatedAt: string;
  };
  creditConstraint: {
    creditConstraintStatus: string;
    performanceConstraintStatus: string;
    executionAvailabilityStatus: string;
    restrictionReasonCode: string | null;
    advisoryReasonCode: string | null;
    updatedAt: string;
  };
  deposit: {
    depositRequirementStatus: string;
    depositEligibilityStatus: string;
    depositRestrictionStatus: string;
    depositPostureStatus: string;
    depositHandoffKey: string;
    depositDependencyKey: string | null;
    updatedAt: string;
  };
  transactionGuarantee: {
    transactionGuaranteeEligibilityStatus: string;
    transactionGuaranteeRestrictionStatus: string;
    transactionGuaranteeExplanationKey: string;
    transactionGuaranteeHandoffKey: string;
    transactionGuaranteeDependencyKey: string | null;
    updatedAt: string;
  };
  dependencyReference: {
    dependencyFamilyKey: string;
    dependencyRequired: boolean;
    dependencyExplanationKey: string;
    dependencyHandoffKey: string;
  } | null;
};

export type CreditConstraintsExplanationViewModel = {
  creditExplanation: {
    explanationKey: string;
    title: string;
    body: string;
  };
  depositExplanation: {
    explanationKey: string;
    title: string;
    body: string;
  };
  transactionGuaranteeExplanation: {
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

export type CreditConstraintsHandoffViewModel = {
  creditHandoff: {
    handoffKey: string;
    title: string;
    body: string;
  };
  depositHandoff: {
    handoffKey: string;
    title: string;
    body: string;
  };
  transactionGuaranteeHandoff: {
    handoffKey: string;
    title: string;
    body: string;
  };
  dependencyHandoff: {
    dependencyFamilyKey: string;
    dependencyRequired: boolean;
    dependencyHandoffKey: string;
    title: string;
    body: string;
  } | null;
};

export function readCreditConstraintsStatusViewModel(
  result: Record<string, unknown>,
): CreditConstraintsStatusViewModel {
  requireKeys(result, [
    'privateSummary',
    'creditConstraint',
    'deposit',
    'transactionGuarantee',
    'dependencyReference',
  ]);

  const privateSummary = requireRecord(
    result.privateSummary,
    'Credit-and-constraints status response is missing privateSummary.',
  );
  const creditConstraint = requireRecord(
    result.creditConstraint,
    'Credit-and-constraints status response is missing creditConstraint.',
  );
  const deposit = requireRecord(
    result.deposit,
    'Credit-and-constraints status response is missing deposit.',
  );
  const transactionGuarantee = requireRecord(
    result.transactionGuarantee,
    'Credit-and-constraints status response is missing transactionGuarantee.',
  );

  requireKeys(privateSummary, [
    'entryKey',
    'summaryStatus',
    'creditConstraintStatus',
    'depositPostureStatus',
    'transactionGuaranteeEligibilityStatus',
    'updatedAt',
  ]);
  requireKeys(creditConstraint, [
    'creditConstraintStatus',
    'performanceConstraintStatus',
    'executionAvailabilityStatus',
    'restrictionReasonCode',
    'advisoryReasonCode',
    'updatedAt',
  ]);
  requireKeys(deposit, [
    'depositRequirementStatus',
    'depositEligibilityStatus',
    'depositRestrictionStatus',
    'depositPostureStatus',
    'depositHandoffKey',
    'depositDependencyKey',
    'updatedAt',
  ]);
  requireKeys(transactionGuarantee, [
    'transactionGuaranteeEligibilityStatus',
    'transactionGuaranteeRestrictionStatus',
    'transactionGuaranteeExplanationKey',
    'transactionGuaranteeHandoffKey',
    'transactionGuaranteeDependencyKey',
    'updatedAt',
  ]);

  return {
    privateSummary: {
      entryKey: readRequiredString(
        privateSummary.entryKey,
        'Credit-and-constraints privateSummary.entryKey is invalid.',
      ),
      summaryStatus: readRequiredString(
        privateSummary.summaryStatus,
        'Credit-and-constraints privateSummary.summaryStatus is invalid.',
      ),
      creditConstraintStatus: readRequiredString(
        privateSummary.creditConstraintStatus,
        'Credit-and-constraints privateSummary.creditConstraintStatus is invalid.',
      ),
      depositPostureStatus: readRequiredString(
        privateSummary.depositPostureStatus,
        'Credit-and-constraints privateSummary.depositPostureStatus is invalid.',
      ),
      transactionGuaranteeEligibilityStatus: readRequiredString(
        privateSummary.transactionGuaranteeEligibilityStatus,
        'Credit-and-constraints privateSummary.transactionGuaranteeEligibilityStatus is invalid.',
      ),
      updatedAt: readRequiredString(
        privateSummary.updatedAt,
        'Credit-and-constraints privateSummary.updatedAt is invalid.',
      ),
    },
    creditConstraint: {
      creditConstraintStatus: readRequiredString(
        creditConstraint.creditConstraintStatus,
        'Credit-and-constraints creditConstraint.creditConstraintStatus is invalid.',
      ),
      performanceConstraintStatus: readRequiredString(
        creditConstraint.performanceConstraintStatus,
        'Credit-and-constraints creditConstraint.performanceConstraintStatus is invalid.',
      ),
      executionAvailabilityStatus: readRequiredString(
        creditConstraint.executionAvailabilityStatus,
        'Credit-and-constraints creditConstraint.executionAvailabilityStatus is invalid.',
      ),
      restrictionReasonCode: readNullableString(creditConstraint.restrictionReasonCode),
      advisoryReasonCode: readNullableString(creditConstraint.advisoryReasonCode),
      updatedAt: readRequiredString(
        creditConstraint.updatedAt,
        'Credit-and-constraints creditConstraint.updatedAt is invalid.',
      ),
    },
    deposit: {
      depositRequirementStatus: readRequiredString(
        deposit.depositRequirementStatus,
        'Credit-and-constraints deposit.depositRequirementStatus is invalid.',
      ),
      depositEligibilityStatus: readRequiredString(
        deposit.depositEligibilityStatus,
        'Credit-and-constraints deposit.depositEligibilityStatus is invalid.',
      ),
      depositRestrictionStatus: readRequiredString(
        deposit.depositRestrictionStatus,
        'Credit-and-constraints deposit.depositRestrictionStatus is invalid.',
      ),
      depositPostureStatus: readRequiredString(
        deposit.depositPostureStatus,
        'Credit-and-constraints deposit.depositPostureStatus is invalid.',
      ),
      depositHandoffKey: readRequiredString(
        deposit.depositHandoffKey,
        'Credit-and-constraints deposit.depositHandoffKey is invalid.',
      ),
      depositDependencyKey: readNullableString(deposit.depositDependencyKey),
      updatedAt: readRequiredString(
        deposit.updatedAt,
        'Credit-and-constraints deposit.updatedAt is invalid.',
      ),
    },
    transactionGuarantee: {
      transactionGuaranteeEligibilityStatus: readRequiredString(
        transactionGuarantee.transactionGuaranteeEligibilityStatus,
        'Credit-and-constraints transactionGuarantee.transactionGuaranteeEligibilityStatus is invalid.',
      ),
      transactionGuaranteeRestrictionStatus: readRequiredString(
        transactionGuarantee.transactionGuaranteeRestrictionStatus,
        'Credit-and-constraints transactionGuarantee.transactionGuaranteeRestrictionStatus is invalid.',
      ),
      transactionGuaranteeExplanationKey: readRequiredString(
        transactionGuarantee.transactionGuaranteeExplanationKey,
        'Credit-and-constraints transactionGuarantee.transactionGuaranteeExplanationKey is invalid.',
      ),
      transactionGuaranteeHandoffKey: readRequiredString(
        transactionGuarantee.transactionGuaranteeHandoffKey,
        'Credit-and-constraints transactionGuarantee.transactionGuaranteeHandoffKey is invalid.',
      ),
      transactionGuaranteeDependencyKey: readNullableString(
        transactionGuarantee.transactionGuaranteeDependencyKey,
      ),
      updatedAt: readRequiredString(
        transactionGuarantee.updatedAt,
        'Credit-and-constraints transactionGuarantee.updatedAt is invalid.',
      ),
    },
    dependencyReference: readDependencyReference(result.dependencyReference),
  };
}

export function readCreditConstraintsExplanationViewModel(
  result: Record<string, unknown>,
): CreditConstraintsExplanationViewModel {
  requireKeys(result, [
    'creditExplanation',
    'depositExplanation',
    'transactionGuaranteeExplanation',
    'dependencyExplanation',
    'disclaimer',
  ]);

  return {
    creditExplanation: readExplanationBlock(result.creditExplanation, 'creditExplanation'),
    depositExplanation: readExplanationBlock(result.depositExplanation, 'depositExplanation'),
    transactionGuaranteeExplanation: readExplanationBlock(
      result.transactionGuaranteeExplanation,
      'transactionGuaranteeExplanation',
    ),
    dependencyExplanation: readDependencyExplanation(result.dependencyExplanation),
    disclaimer: readRequiredString(
      result.disclaimer,
      'Credit-and-constraints explanation disclaimer is invalid.',
    ),
  };
}

export function readCreditConstraintsHandoffViewModel(
  result: Record<string, unknown>,
): CreditConstraintsHandoffViewModel {
  requireKeys(result, [
    'creditHandoff',
    'depositHandoff',
    'transactionGuaranteeHandoff',
    'dependencyHandoff',
  ]);

  return {
    creditHandoff: readHandoffBlock(result.creditHandoff, 'creditHandoff'),
    depositHandoff: readHandoffBlock(result.depositHandoff, 'depositHandoff'),
    transactionGuaranteeHandoff: readHandoffBlock(
      result.transactionGuaranteeHandoff,
      'transactionGuaranteeHandoff',
    ),
    dependencyHandoff: readDependencyHandoff(result.dependencyHandoff),
  };
}
