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
  findCreditExplanation,
  findDependency,
  findDepositExplanationByStatus,
  findHandoff,
  findTransactionGuaranteeExplanation,
  getCreditAndConstraintsDisclaimer
} from './credit-constraints.catalog';
import {
  creditConstraintStatusUnavailable,
  dependencyReferenceUnavailable,
  depositPostureUnavailable,
  transactionGuaranteePostureUnavailable
} from './credit-constraints.errors';
import { OrganizationCreditConstraintPostureEntity } from './entities/organization-credit-constraint-posture.entity';
import { OrganizationDepositPostureEntity } from './entities/organization-deposit-posture.entity';
import { OrganizationTransactionGuaranteePostureEntity } from './entities/organization-transaction-guarantee-posture.entity';
import { CreditConstraintsPresenter } from './credit-constraints.presenter';

@Injectable()
export class CreditConstraintsQueryService {
  constructor(
    @InjectRepository(OrganizationCreditConstraintPostureEntity)
    private readonly creditPostureRepository: Repository<OrganizationCreditConstraintPostureEntity>,
    @InjectRepository(OrganizationDepositPostureEntity)
    private readonly depositPostureRepository: Repository<OrganizationDepositPostureEntity>,
    @InjectRepository(OrganizationTransactionGuaranteePostureEntity)
    private readonly transactionGuaranteePostureRepository: Repository<OrganizationTransactionGuaranteePostureEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: CreditConstraintsPresenter
  ) {}

  async getStatus(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toStatus({
      privateSummary: projection.privateSummary,
      creditConstraint: projection.creditConstraint,
      deposit: projection.deposit,
      transactionGuarantee: projection.transactionGuarantee,
      dependencyReference: projection.dependencyReference
    });
  }

  async getExplanation(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toExplanation({
      creditExplanation: projection.creditExplanation,
      depositExplanation: projection.depositExplanation,
      transactionGuaranteeExplanation: projection.transactionGuaranteeExplanation,
      dependencyExplanation: projection.dependencyExplanation,
      disclaimer: getCreditAndConstraintsDisclaimer()
    });
  }

  async getHandoff(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toHandoff({
      creditHandoff: projection.creditHandoff,
      depositHandoff: projection.depositHandoff,
      transactionGuaranteeHandoff: projection.transactionGuaranteeHandoff,
      dependencyHandoff: projection.dependencyHandoff
    });
  }

  private async buildProjection(context: RequestContext) {
    const organizationId = await this.requireCurrentOrganizationId(context);
    const [creditPosture, depositPosture, transactionGuaranteePosture] =
      await Promise.all([
        this.creditPostureRepository.findOneBy({ organizationId }),
        this.depositPostureRepository.findOneBy({ organizationId }),
        this.transactionGuaranteePostureRepository.findOneBy({ organizationId })
      ]);

    if (!creditPosture) {
      throw creditConstraintStatusUnavailable(
        'Current organization credit-constraint posture is unavailable.'
      );
    }
    if (!depositPosture) {
      throw depositPostureUnavailable('Current organization deposit posture is unavailable.');
    }
    if (!transactionGuaranteePosture) {
      throw transactionGuaranteePostureUnavailable(
        'Current organization transaction-guarantee posture is unavailable.'
      );
    }

    const dependency = this.resolveDependency(
      depositPosture.dependencyKey ??
        transactionGuaranteePosture.dependencyKey ??
        creditPosture.dependencyKey
    );
    const creditExplanation = findCreditExplanation(creditPosture.explanationKey);
    if (!creditExplanation) {
      throw creditConstraintStatusUnavailable(
        'Current organization credit explanation source is unavailable.'
      );
    }
    const depositExplanation = findDepositExplanationByStatus(
      depositPosture.depositPostureStatus as 'clear' | 'restricted' | 'handoff_required'
    );
    const transactionGuaranteeExplanation = findTransactionGuaranteeExplanation(
      transactionGuaranteePosture.explanationKey
    );
    if (!transactionGuaranteeExplanation) {
      throw transactionGuaranteePostureUnavailable(
        'Current organization transaction-guarantee explanation source is unavailable.'
      );
    }

    const creditHandoff = findHandoff(creditPosture.handoffKey);
    const depositHandoff = findHandoff(depositPosture.handoffKey);
    const transactionGuaranteeHandoff = findHandoff(transactionGuaranteePosture.handoffKey);
    if (!creditHandoff) {
      throw creditConstraintStatusUnavailable(
        'Current organization credit handoff source is unavailable.'
      );
    }
    if (!depositHandoff) {
      throw depositPostureUnavailable('Current organization deposit handoff source is unavailable.');
    }
    if (!transactionGuaranteeHandoff) {
      throw transactionGuaranteePostureUnavailable(
        'Current organization transaction-guarantee handoff source is unavailable.'
      );
    }

    const updatedAt = this.pickLatestUpdatedAt([
      creditPosture.updatedAt,
      depositPosture.updatedAt,
      transactionGuaranteePosture.updatedAt
    ]);

    const summaryStatus = buildSummaryStatus({
      creditConstraintStatus: creditPosture.creditConstraintStatus as 'clear' | 'constrained',
      performanceConstraintStatus: creditPosture.performanceConstraintStatus as
        | 'clear'
        | 'constrained',
      executionAvailabilityStatus: creditPosture.executionAvailabilityStatus as
        | 'available'
        | 'limited'
        | 'blocked',
      depositPostureStatus: depositPosture.depositPostureStatus as
        | 'clear'
        | 'restricted'
        | 'handoff_required',
      transactionGuaranteeRestrictionStatus: transactionGuaranteePosture.restrictionStatus as
        | 'clear'
        | 'restricted',
      dependencyRequired: dependency?.dependencyRequired ?? false
    });

    return {
      privateSummary: {
        entryKey: 'my_credit_and_constraints',
        summaryStatus,
        creditConstraintStatus: creditPosture.creditConstraintStatus,
        depositPostureStatus: depositPosture.depositPostureStatus,
        transactionGuaranteeEligibilityStatus: transactionGuaranteePosture.eligibilityStatus,
        updatedAt
      },
      creditConstraint: {
        creditConstraintStatus: creditPosture.creditConstraintStatus,
        performanceConstraintStatus: creditPosture.performanceConstraintStatus,
        executionAvailabilityStatus: creditPosture.executionAvailabilityStatus,
        restrictionReasonCode: creditPosture.restrictionReasonCode,
        advisoryReasonCode: creditPosture.advisoryReasonCode,
        updatedAt: creditPosture.updatedAt
      },
      deposit: {
        depositRequirementStatus: depositPosture.requirementStatus,
        depositEligibilityStatus: depositPosture.eligibilityStatus,
        depositRestrictionStatus: depositPosture.restrictionStatus,
        depositPostureStatus: depositPosture.depositPostureStatus,
        depositHandoffKey: depositPosture.handoffKey,
        depositDependencyKey: depositPosture.dependencyKey,
        updatedAt: depositPosture.updatedAt
      },
      transactionGuarantee: {
        transactionGuaranteeEligibilityStatus: transactionGuaranteePosture.eligibilityStatus,
        transactionGuaranteeRestrictionStatus: transactionGuaranteePosture.restrictionStatus,
        transactionGuaranteeExplanationKey: transactionGuaranteePosture.explanationKey,
        transactionGuaranteeHandoffKey: transactionGuaranteePosture.handoffKey,
        transactionGuaranteeDependencyKey: transactionGuaranteePosture.dependencyKey,
        updatedAt: transactionGuaranteePosture.updatedAt
      },
      dependencyReference: dependency
        ? {
            dependencyFamilyKey: dependency.dependencyFamilyKey,
            dependencyRequired: dependency.dependencyRequired,
            dependencyExplanationKey: dependency.dependencyExplanationKey,
            dependencyHandoffKey: dependency.dependencyHandoffKey
          }
        : null,
      creditExplanation,
      depositExplanation,
      transactionGuaranteeExplanation,
      dependencyExplanation: dependency
        ? {
            dependencyFamilyKey: dependency.dependencyFamilyKey,
            dependencyRequired: dependency.dependencyRequired,
            dependencyExplanationKey: dependency.dependencyExplanationKey,
            title: dependency.title,
            body: dependency.body
          }
        : null,
      creditHandoff,
      depositHandoff,
      transactionGuaranteeHandoff,
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
      throw authPermissionInsufficient(
        'Current organization scope is required for credit/deposit/guarantee read.'
      );
    }
    return scope.organization.id;
  }

  private resolveDependency(dependencyKey: string | null) {
    if (!dependencyKey) {
      return null;
    }
    const dependency = findDependency(dependencyKey);
    if (!dependency) {
      throw dependencyReferenceUnavailable(
        'Current organization dependency reference source is unavailable.'
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
