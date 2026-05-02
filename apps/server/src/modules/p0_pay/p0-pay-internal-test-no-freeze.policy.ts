export const PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_STATUS =
  'internal_test_no_freeze_required';

export const PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_GATE_STATUS =
  'internal_test_no_freeze_allowed';

export const PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_NOTICE =
  '内测期间暂不冻结真实资金，平台保留项目真实性诚意金流程记录；正式期是否恢复冻结以平台公告和页面状态为准。';

export function projectAuthenticitySincerityInternalTestNoFreezeEnabled() {
  return process.env.PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_NO_FREEZE !== 'false';
}
