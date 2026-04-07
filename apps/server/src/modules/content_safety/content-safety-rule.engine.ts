import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  CONTENT_SAFETY_FALLBACK_RULES,
  ContentSafetyProfileField
} from './content-safety.constants';
import { ContentSafetyRuleEntity } from './entities/content-safety-rule.entity';

type RuleLike = {
  id: string;
  ruleKey: string;
  ruleType: string;
  fieldScope: string;
  matchMode: string;
  pattern: string;
  decision: string;
  reasonCode: string;
  reasonText: string;
  engineType?: string;
  enabled?: boolean;
};

export type ContentSafetyRuleResult = {
  decision: 'allow' | 'block';
  engineType: 'rule';
  matchedRules: Array<{
    id: string;
    ruleKey: string;
    ruleType: string;
    reasonCode: string;
    reasonText: string;
  }>;
  reasonCode: string | null;
  reasonText: string | null;
};

@Injectable()
export class ContentSafetyRuleEngine {
  constructor(
    @InjectRepository(ContentSafetyRuleEntity)
    private readonly ruleRepository: Repository<ContentSafetyRuleEntity>
  ) {}

  async evaluateProfileText(input: {
    fieldKey: Extract<ContentSafetyProfileField, 'nickname' | 'intro'>;
    content: string;
  }): Promise<ContentSafetyRuleResult> {
    const normalized = input.content.trim();
    const rules = await this.loadEnabledRules();
    const matchedRules = rules.filter((rule) =>
      this.ruleAppliesToField(rule, input.fieldKey) && this.matches(rule, normalized)
    );
    if (!matchedRules.length) {
      return {
        decision: 'allow',
        engineType: 'rule',
        matchedRules: [],
        reasonCode: null,
        reasonText: null
      };
    }
    const first = matchedRules[0];
    return {
      decision: 'block',
      engineType: 'rule',
      matchedRules: matchedRules.map((rule) => ({
        id: rule.id,
        ruleKey: rule.ruleKey,
        ruleType: rule.ruleType,
        reasonCode: rule.reasonCode,
        reasonText: rule.reasonText
      })),
      reasonCode: first.reasonCode,
      reasonText: first.reasonText
    };
  }

  private async loadEnabledRules(): Promise<RuleLike[]> {
    try {
      const rules = await this.ruleRepository.find({
        where: { enabled: true, engineType: 'rule' },
        order: { createdAt: 'ASC' }
      });
      if (rules.length) {
        return rules;
      }
    } catch {
      return [...CONTENT_SAFETY_FALLBACK_RULES];
    }
    return [...CONTENT_SAFETY_FALLBACK_RULES];
  }

  private ruleAppliesToField(rule: RuleLike, fieldKey: ContentSafetyProfileField) {
    return rule.fieldScope === 'profile' || rule.fieldScope === `profile.${fieldKey}`;
  }

  private matches(rule: RuleLike, content: string) {
    if (rule.matchMode === 'substring') {
      return content.includes(rule.pattern);
    }
    if (rule.matchMode === 'regex') {
      try {
        return new RegExp(rule.pattern, 'u').test(content);
      } catch {
        return false;
      }
    }
    return false;
  }
}
