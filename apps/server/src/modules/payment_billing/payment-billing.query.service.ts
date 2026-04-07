import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  buildSummaryStatus,
  findBillingExplanation,
  findDependency,
  findHandoff,
  findPaymentExplanation,
  getPaymentBillingDisclaimer
} from './payment-billing.catalog';
import {
  billingReferenceUnavailable,
  dependencyReferenceUnavailable,
  paymentHandoffUnavailable,
  paymentStatusUnavailable
} from './payment-billing.errors';
import { OrganizationBillingReferenceEntity } from './entities/organization-billing-reference.entity';
import { OrganizationPaymentHandoffEntity } from './entities/organization-payment-handoff.entity';
import { OrganizationPaymentStatusEntity } from './entities/organization-payment-status.entity';
import { PaymentBillingPresenter } from './payment-billing.presenter';

@Injectable()
export class PaymentBillingQueryService {
  constructor(
    @InjectRepository(OrganizationPaymentStatusEntity)
    private readonly paymentStatusRepository: Repository<OrganizationPaymentStatusEntity>,
    @InjectRepository(OrganizationBillingReferenceEntity)
    private readonly billingReferenceRepository: Repository<OrganizationBillingReferenceEntity>,
    @InjectRepository(OrganizationPaymentHandoffEntity)
    private readonly paymentHandoffRepository: Repository<OrganizationPaymentHandoffEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: PaymentBillingPresenter
  ) {}

  async getStatus(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toStatus({
      privateSummary: projection.privateSummary,
      paymentStatus: projection.paymentStatus,
      billingReference: projection.billingReference,
      dependencyReference: projection.dependencyReference
    });
  }

  async getExplanation(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toExplanation({
      paymentExplanation: projection.paymentExplanation,
      billingExplanation: projection.billingExplanation,
      dependencyExplanation: projection.dependencyExplanation,
      disclaimer: getPaymentBillingDisclaimer()
    });
  }

  async getHandoff(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toHandoff({
      paymentHandoff: projection.paymentHandoff,
      billingHandoff: projection.billingHandoff,
      dependencyHandoff: projection.dependencyHandoff
    });
  }

  private async buildProjection(context: RequestContext) {
    const organizationId = await this.requireCurrentOrganizationId(context);
    const [paymentStatusRow, billingReferenceRow, paymentHandoffRow] = await Promise.all([
      this.paymentStatusRepository.findOneBy({ organizationId }),
      this.billingReferenceRepository.findOneBy({ organizationId }),
      this.paymentHandoffRepository.findOneBy({ organizationId })
    ]);

    if (!paymentStatusRow) {
      throw paymentStatusUnavailable('Current organization payment status is unavailable.');
    }
    if (!billingReferenceRow) {
      throw billingReferenceUnavailable('Current organization billing reference is unavailable.');
    }
    if (!paymentHandoffRow) {
      throw paymentHandoffUnavailable('Current organization payment handoff is unavailable.');
    }

    const paymentExplanation = findPaymentExplanation(paymentStatusRow.paymentExplanationKey);
    if (!paymentExplanation) {
      throw paymentStatusUnavailable('Current organization payment explanation source is unavailable.');
    }

    const billingExplanation = findBillingExplanation(billingReferenceRow.billingExplanationKey);
    if (!billingExplanation) {
      throw billingReferenceUnavailable(
        'Current organization billing explanation source is unavailable.'
      );
    }

    const paymentHandoffCopy = findHandoff(paymentStatusRow.paymentHandoffKey);
    if (!paymentHandoffCopy) {
      throw paymentHandoffUnavailable('Current organization payment handoff source is unavailable.');
    }

    const billingHandoffCopy = findHandoff(billingReferenceRow.billingHandoffKey);
    if (!billingHandoffCopy) {
      throw billingReferenceUnavailable(
        'Current organization billing handoff source is unavailable.'
      );
    }

    const dependency = this.resolveDependency(
      paymentStatusRow.paymentDependencyKey ?? billingReferenceRow.billingDependencyKey,
      paymentHandoffRow.dependencyRequired
    );

    const updatedAt = this.pickLatestUpdatedAt([
      paymentStatusRow.updatedAt,
      billingReferenceRow.updatedAt,
      paymentHandoffRow.updatedAt
    ]);

    return {
      privateSummary: {
        entryKey: 'payment_and_billing_status',
        summaryStatus: buildSummaryStatus({
          paymentStatus: paymentStatusRow.paymentStatusCode as
            | 'pending'
            | 'unavailable'
            | 'handoff_required',
          paymentAvailabilityStatus: paymentStatusRow.paymentAvailabilityCode as
            | 'available'
            | 'unavailable',
          billingReferenceStatus: billingReferenceRow.billingReferenceStatusCode as
            | 'available'
            | 'unavailable',
          billingReferenceVisibilityStatus: billingReferenceRow.billingReferenceVisibilityCode as
            | 'visible'
            | 'hidden',
          handoffStatus: paymentHandoffRow.handoffStatusCode as
            | 'pending'
            | 'unavailable'
            | 'handoff_required',
          dependencyRequired:
            paymentHandoffRow.dependencyRequired || dependency?.dependencyRequired === true
        }),
        paymentStatus: paymentStatusRow.paymentStatusCode,
        billingReferenceStatus: billingReferenceRow.billingReferenceStatusCode,
        updatedAt
      },
      paymentStatus: {
        paymentStatus: paymentStatusRow.paymentStatusCode,
        paymentAvailabilityStatus: paymentStatusRow.paymentAvailabilityCode,
        paymentHandoffKey: paymentStatusRow.paymentHandoffKey,
        paymentExplanationKey: paymentStatusRow.paymentExplanationKey,
        paymentDependencyKey: paymentStatusRow.paymentDependencyKey,
        updatedAt: paymentStatusRow.updatedAt
      },
      billingReference: {
        billingReferenceStatus: billingReferenceRow.billingReferenceStatusCode,
        billingReferenceCode: billingReferenceRow.billingReferenceCode,
        billingReferenceVisibilityStatus: billingReferenceRow.billingReferenceVisibilityCode,
        billingExplanationKey: billingReferenceRow.billingExplanationKey,
        billingHandoffKey: billingReferenceRow.billingHandoffKey,
        billingDependencyKey: billingReferenceRow.billingDependencyKey,
        updatedAt: billingReferenceRow.updatedAt
      },
      dependencyReference: dependency
        ? {
            dependencyFamilyKey: dependency.dependencyFamilyKey,
            dependencyRequired: dependency.dependencyRequired,
            dependencyExplanationKey: dependency.dependencyExplanationKey,
            dependencyHandoffKey: dependency.dependencyHandoffKey
          }
        : null,
      paymentExplanation,
      billingExplanation,
      dependencyExplanation: dependency
        ? {
            dependencyFamilyKey: dependency.dependencyFamilyKey,
            dependencyRequired: dependency.dependencyRequired,
            dependencyExplanationKey: dependency.dependencyExplanationKey,
            title: dependency.title,
            body: dependency.body
          }
        : null,
      paymentHandoff: {
        paymentHandoffKey: paymentStatusRow.paymentHandoffKey,
        handoffStatus: paymentHandoffRow.handoffStatusCode,
        handoffTargetFamily: paymentHandoffRow.handoffTargetFamily,
        handoffExplanationKey: paymentHandoffRow.handoffExplanationKey,
        dependencyRequired: paymentHandoffRow.dependencyRequired,
        title: paymentHandoffCopy.title,
        body: paymentHandoffCopy.body,
        updatedAt: paymentHandoffRow.updatedAt
      },
      billingHandoff: {
        billingHandoffKey: billingReferenceRow.billingHandoffKey,
        title: billingHandoffCopy.title,
        body: billingHandoffCopy.body,
        updatedAt: billingReferenceRow.updatedAt
      },
      dependencyHandoff: dependency
        ? {
            dependencyFamilyKey: dependency.dependencyFamilyKey,
            dependencyRequired: dependency.dependencyRequired,
            dependencyHandoffKey: dependency.dependencyHandoffKey,
            title: findHandoff(dependency.dependencyHandoffKey)?.title ?? dependency.title,
            body: findHandoff(dependency.dependencyHandoffKey)?.body ?? dependency.body
          }
        : null
    };
  }

  private async requireCurrentOrganizationId(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authPermissionInsufficient('Current organization scope is required for payment/billing read.');
    }
    return scope.organization.id;
  }

  private resolveDependency(dependencyKey: string | null, dependencyRequired: boolean) {
    if (!dependencyKey) {
      if (dependencyRequired) {
        throw dependencyReferenceUnavailable(
          'Current organization payment/billing dependency reference is unavailable.'
        );
      }
      return null;
    }

    const dependency = findDependency(dependencyKey);
    if (!dependency) {
      throw dependencyReferenceUnavailable(
        'Current organization payment/billing dependency reference source is unavailable.'
      );
    }
    return dependency;
  }

  private pickLatestUpdatedAt(items: Date[]) {
    return items.reduce((latest, current) =>
      current.getTime() > latest.getTime() ? current : latest
    );
  }
}
