import { Injectable } from '@nestjs/common';

@Injectable()
export class CreditConstraintsPresenter {
  toStatus(input: {
    privateSummary: {
      entryKey: string;
      summaryStatus: string;
      creditConstraintStatus: string;
      depositPostureStatus: string;
      transactionGuaranteeEligibilityStatus: string;
      updatedAt: Date;
    };
    creditConstraint: {
      creditConstraintStatus: string;
      performanceConstraintStatus: string;
      executionAvailabilityStatus: string;
      restrictionReasonCode: string | null;
      advisoryReasonCode: string | null;
      updatedAt: Date;
    };
    deposit: {
      depositRequirementStatus: string;
      depositEligibilityStatus: string;
      depositRestrictionStatus: string;
      depositPostureStatus: string;
      depositHandoffKey: string;
      depositDependencyKey: string | null;
      updatedAt: Date;
    };
    transactionGuarantee: {
      transactionGuaranteeEligibilityStatus: string;
      transactionGuaranteeRestrictionStatus: string;
      transactionGuaranteeExplanationKey: string;
      transactionGuaranteeHandoffKey: string;
      transactionGuaranteeDependencyKey: string | null;
      updatedAt: Date;
    };
    dependencyReference: {
      dependencyFamilyKey: string;
      dependencyRequired: boolean;
      dependencyExplanationKey: string;
      dependencyHandoffKey: string;
    } | null;
  }) {
    return {
      privateSummary: {
        ...input.privateSummary,
        updatedAt: input.privateSummary.updatedAt.toISOString()
      },
      creditConstraint: {
        ...input.creditConstraint,
        updatedAt: input.creditConstraint.updatedAt.toISOString()
      },
      deposit: {
        ...input.deposit,
        updatedAt: input.deposit.updatedAt.toISOString()
      },
      transactionGuarantee: {
        ...input.transactionGuarantee,
        updatedAt: input.transactionGuarantee.updatedAt.toISOString()
      },
      dependencyReference: input.dependencyReference
    };
  }

  toExplanation(input: {
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
  }) {
    return input;
  }

  toHandoff(input: {
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
  }) {
    return input;
  }
}
