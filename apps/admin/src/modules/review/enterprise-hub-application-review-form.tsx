import type {
  AdminApiError,
  EnterpriseHubApplicationReviewDetailResponse,
  EnterpriseHubApplicationReviewAction,
  EnterpriseHubApplicationReviewReason,
  EnterpriseHubApplicationReviewRequest,
} from '../../core/server/admin-api-client';
import type { EnterpriseHubApplicationReviewStatusSummary } from './enterprise-hub-application-review-state';

export const ENTERPRISE_HUB_APPLICATION_REVIEW_REASON_OPTIONS: Array<{
  value: EnterpriseHubApplicationReviewReason;
  label: string;
}> = [
  { value: 'basic_info_incomplete', label: '基本信息不完整' },
  { value: 'profile_incomplete', label: '档案信息不完整' },
  { value: 'case_incomplete', label: '案例信息不完整' },
  { value: 'contact_incomplete', label: '联系人信息不完整' },
  { value: 'certification_not_approved', label: '认证尚未通过' },
  { value: 'other', label: '其他' },
];

const REVIEW_REASON_SET = new Set(
  ENTERPRISE_HUB_APPLICATION_REVIEW_REASON_OPTIONS.map((item) => item.value),
);

export function readEnterpriseHubApplicationId(formData: FormData) {
  return readRequired(formData, 'applicationId', 96);
}

export function buildEnterpriseHubApplicationApprovePayload(
  formData: FormData,
): EnterpriseHubApplicationReviewRequest {
  return buildReviewPayload(formData, 'approved');
}

export function buildEnterpriseHubApplicationRevisionRequiredPayload(
  formData: FormData,
): EnterpriseHubApplicationReviewRequest {
  return buildReviewPayload(formData, 'revision_required');
}

export function buildEnterpriseHubApplicationRejectedPayload(
  formData: FormData,
): EnterpriseHubApplicationReviewRequest {
  return buildReviewPayload(formData, 'rejected');
}

export function EnterpriseHubApplicationReviewHiddenRouteContext({
  applicationStatus,
  boardType,
}: {
  applicationStatus?: string | null;
  boardType?: string | null;
}) {
  return (
    <>
      {applicationStatus ? (
        <input
          name="filterApplicationStatus"
          type="hidden"
          value={applicationStatus}
        />
      ) : null}
      {boardType ? (
        <input name="filterBoardType" type="hidden" value={boardType} />
      ) : null}
    </>
  );
}

export function toEnterpriseHubApplicationReviewActionError(error: unknown) {
  if (isAdminApiError(error)) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '服务端管理接口请求失败。';
}

export function ApproveEnterpriseHubApplicationReviewForm({
  detail,
  statusSummary,
  applicationStatus,
  boardType,
  submitAction,
}: {
  detail: EnterpriseHubApplicationReviewDetailResponse | null;
  statusSummary: EnterpriseHubApplicationReviewStatusSummary | null;
  applicationStatus?: string;
  boardType?: string;
  submitAction: (formData: FormData) => void | Promise<void>;
}) {
  if (!detail || !statusSummary) {
    return <div className="action-card empty-card">选中 application 后，才会开放 approved 命令。</div>;
  }

  return (
    <form className="action-card" action={submitAction}>
      <input name="applicationId" type="hidden" value={detail.application.applicationId} />
      <EnterpriseHubApplicationReviewHiddenRouteContext
        applicationStatus={applicationStatus}
        boardType={boardType}
      />
      <div>
        <p className="eyebrow">Approve</p>
        <h2>通过企业入驻申请</h2>
      </div>
      <label>
        审核备注
        <textarea
          name="reviewNote"
          placeholder="可选，只承接补充说明。"
        />
      </label>
      <button className="primary" disabled={!statusSummary.canReview} type="submit">
        提交 approved 命令
      </button>
    </form>
  );
}

export function RequestEnterpriseHubApplicationRevisionForm({
  detail,
  statusSummary,
  applicationStatus,
  boardType,
  submitAction,
}: {
  detail: EnterpriseHubApplicationReviewDetailResponse | null;
  statusSummary: EnterpriseHubApplicationReviewStatusSummary | null;
  applicationStatus?: string;
  boardType?: string;
  submitAction: (formData: FormData) => void | Promise<void>;
}) {
  if (!detail || !statusSummary) {
    return <div className="action-card empty-card">选中 application 后，才会开放 revision_required 命令。</div>;
  }

  return (
    <form className="action-card warning-card" action={submitAction}>
      <input name="applicationId" type="hidden" value={detail.application.applicationId} />
      <EnterpriseHubApplicationReviewHiddenRouteContext
        applicationStatus={applicationStatus}
        boardType={boardType}
      />
      <div>
        <p className="eyebrow">Revision Required</p>
        <h2>退回企业补充资料</h2>
      </div>
      <label>
        退回原因
        <select defaultValue={detail.application.rejectionReason ?? ''} name="reason" required>
          <option value="" disabled>
            请选择 reject reason
          </option>
          {ENTERPRISE_HUB_APPLICATION_REVIEW_REASON_OPTIONS.map((item) => (
            <option key={item.value} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
      </label>
      <label>
        审核备注
        <textarea
          name="reviewNote"
          placeholder="可选，只承接补充说明。"
        />
      </label>
      <button className="primary" disabled={!statusSummary.canReview} type="submit">
        提交 revision_required 命令
      </button>
    </form>
  );
}

export function RejectEnterpriseHubApplicationReviewForm({
  detail,
  statusSummary,
  applicationStatus,
  boardType,
  submitAction,
}: {
  detail: EnterpriseHubApplicationReviewDetailResponse | null;
  statusSummary: EnterpriseHubApplicationReviewStatusSummary | null;
  applicationStatus?: string;
  boardType?: string;
  submitAction: (formData: FormData) => void | Promise<void>;
}) {
  if (!detail || !statusSummary) {
    return <div className="action-card empty-card">选中 application 后，才会开放 rejected 命令。</div>;
  }

  return (
    <form className="action-card danger-card" action={submitAction}>
      <input name="applicationId" type="hidden" value={detail.application.applicationId} />
      <EnterpriseHubApplicationReviewHiddenRouteContext
        applicationStatus={applicationStatus}
        boardType={boardType}
      />
      <div>
        <p className="eyebrow">Reject</p>
        <h2>驳回企业入驻申请</h2>
      </div>
      <label>
        驳回原因
        <select defaultValue={detail.application.rejectionReason ?? ''} name="reason" required>
          <option value="" disabled>
            请选择 reject reason
          </option>
          {ENTERPRISE_HUB_APPLICATION_REVIEW_REASON_OPTIONS.map((item) => (
            <option key={item.value} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
      </label>
      <label>
        审核备注
        <textarea
          name="reviewNote"
          placeholder="可选，只承接补充说明。"
        />
      </label>
      <button className="primary" disabled={!statusSummary.canReview} type="submit">
        提交 rejected 命令
      </button>
    </form>
  );
}

function buildReviewPayload(
  formData: FormData,
  action: EnterpriseHubApplicationReviewAction,
): EnterpriseHubApplicationReviewRequest {
  const reviewNote = readOptional(formData, 'reviewNote', 500);
  if (action === 'approved') {
    return reviewNote
      ? { action: 'approved', reviewNote }
      : { action: 'approved' };
  }

  const reason = readReason(formData);
  return reviewNote ? { action, reason, reviewNote } : { action, reason };
}

function readReason(formData: FormData): EnterpriseHubApplicationReviewReason {
  const value = readRequired(formData, 'reason', 64) as EnterpriseHubApplicationReviewReason;
  if (!REVIEW_REASON_SET.has(value)) {
    throw new Error('reason 不在允许的企业入驻审核拒绝理由集合内。');
  }
  return value;
}

function readRequired(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${key} 为必填项。`);
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

function readOptional(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    return null;
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

function isAdminApiError(error: unknown): error is AdminApiError {
  return error instanceof Error && 'code' in error && 'status' in error;
}
