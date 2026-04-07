import { Injectable } from '@nestjs/common';

@Injectable()
export class PaymentBillingPresenter {
  toStatus(input: {
    privateSummary: {
      entryKey: string;
      summaryStatus: string;
      paymentStatus: string;
      billingReferenceStatus: string;
      updatedAt: Date;
    };
    paymentStatus: {
      paymentStatus: string;
      paymentAvailabilityStatus: string;
      paymentHandoffKey: string;
      paymentExplanationKey: string;
      paymentDependencyKey: string | null;
      updatedAt: Date;
    };
    billingReference: {
      billingReferenceStatus: string;
      billingReferenceCode: string | null;
      billingReferenceVisibilityStatus: string;
      billingExplanationKey: string;
      billingHandoffKey: string;
      billingDependencyKey: string | null;
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
      paymentStatus: {
        ...input.paymentStatus,
        updatedAt: input.paymentStatus.updatedAt.toISOString()
      },
      billingReference: {
        ...input.billingReference,
        updatedAt: input.billingReference.updatedAt.toISOString()
      },
      dependencyReference: input.dependencyReference
    };
  }

  toExplanation(input: {
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
  }) {
    return input;
  }

  toHandoff(input: {
    paymentHandoff: {
      paymentHandoffKey: string;
      handoffStatus: string;
      handoffTargetFamily: string;
      handoffExplanationKey: string;
      dependencyRequired: boolean;
      title: string;
      body: string;
      updatedAt: Date;
    };
    billingHandoff: {
      billingHandoffKey: string;
      title: string;
      body: string;
      updatedAt: Date;
    };
    dependencyHandoff: {
      dependencyFamilyKey: string;
      dependencyRequired: boolean;
      dependencyHandoffKey: string;
      title: string;
      body: string;
    } | null;
  }) {
    return {
      paymentHandoff: {
        ...input.paymentHandoff,
        updatedAt: input.paymentHandoff.updatedAt.toISOString()
      },
      billingHandoff: {
        ...input.billingHandoff,
        updatedAt: input.billingHandoff.updatedAt.toISOString()
      },
      dependencyHandoff: input.dependencyHandoff
    };
  }
}
