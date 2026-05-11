import Link from 'next/link';
import { cookies } from 'next/headers';
import { getServerConfig } from '@/core/config/env';
import {
  ADMIN_SESSION_COOKIE,
  hasAdminSessionCarrier,
  resolveActiveAdminLoginMode,
  sanitizeAdminNextPath,
} from '@/core/auth/route-guard';
import {
  clearAdminSessionCarrierAction,
  connectAdminSessionCarrierAction,
  issueAdminSessionCarrierAction,
} from '@/core/auth/session-carrier-actions';

type LoginPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

const SESSION_ENTRY_PATH = '/login';
const AUDIT_ENTRY_PATH = '/audit';

type NavigationItem = {
  href: string;
  label: string;
  icon: string;
  active?: boolean;
  disabled?: boolean;
  disabledReason?: string;
};

type QuickLink = {
  href: string;
  label: string;
  description: string;
  tone: 'green' | 'gold' | 'slate' | 'blue';
};

const navigationItems: NavigationItem[] = [
  { href: SESSION_ENTRY_PATH, label: '会话接入', icon: '◇', active: true },
  { href: '/review', label: '审核任务', icon: '▣' },
  { href: '/review/change_requests', label: '展示变更', icon: '⇄' },
  { href: '/governance/penalties', label: '治理处罚', icon: '⚖' },
  { href: '/project_review', label: '举报案件', icon: '△' },
  { href: '/template_config', label: '模板治理', icon: '□' },
  { href: '/audit', label: '审计日志', icon: '▤' },
  {
    href: '/membership',
    label: '会员只读',
    icon: '◎',
    disabled: true,
    disabledReason: '当前 runtime 未开放，保留扩展位',
  },
  {
    href: '/ticketing',
    label: '工单占位',
    icon: '☑',
    disabled: true,
    disabledReason: '当前只保留占位，不接入工单系统',
  },
];

const quickLinks: QuickLink[] = [
  {
    href: '/review',
    label: '审核工作台',
    description: '处理内容与企业审核任务',
    tone: 'green',
  },
  {
    href: '/governance/penalties',
    label: '治理处罚',
    description: '查看和执行治理处罚',
    tone: 'gold',
  },
  {
    href: '/governance/appeals',
    label: '申诉处理',
    description: '处理用户申诉与复核申请',
    tone: 'slate',
  },
  {
    href: AUDIT_ENTRY_PATH,
    label: '审计日志',
    description: '查看所有操作审计记录',
    tone: 'blue',
  },
];

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const params = await searchParams;
  const cookieStore = await cookies();
  const configuredLoginMode = getServerConfig().loginMode;
  const activeLoginMode = resolveActiveAdminLoginMode();
  const nextPath = sanitizeAdminNextPath(readQueryParam(params?.next) ?? AUDIT_ENTRY_PATH);
  const sessionCarrier = cookieStore.get(ADMIN_SESSION_COOKIE)?.value ?? '';
  const carrierConnected = hasAdminSessionCarrier(sessionCarrier);
  const error = readQueryParam(params?.error);
  const notice = readQueryParam(params?.notice);

  return (
    <section className="admin-login-console">
      <aside className="admin-login-sidebar" aria-label="Admin 导航">
        <div className="admin-login-brand">
          <span className="brand-mark">◇</span>
          <div>
            <strong>Server Admin API</strong>
            <small>治理台</small>
          </div>
        </div>
        <nav className="admin-login-nav">
          {navigationItems.map((item) =>
            item.disabled ? (
              <span
                aria-disabled="true"
                className="admin-login-nav-item disabled"
                key={item.href}
                title={item.disabledReason}
              >
                <span>{item.icon}</span>
                {item.label}
              </span>
            ) : (
              <Link
                className={item.active ? 'admin-login-nav-item active' : 'admin-login-nav-item'}
                href={item.href}
                key={item.href}
              >
                <span>{item.icon}</span>
                {item.label}
              </Link>
            ),
          )}
        </nav>
        <div className="admin-login-session-card">
          <span className={carrierConnected ? 'session-dot connected' : 'session-dot'} />
          <div>
            <strong>{carrierConnected ? '已接入会话' : '未接入会话'}</strong>
            <small>{carrierConnected ? '可进入治理后台' : '请先完成会话接入'}</small>
          </div>
        </div>
      </aside>

      <div className="admin-login-workspace">
        <header className="admin-login-header">
          <div>
            <h1>Server Admin API 治理台</h1>
            <p>治理审核、处罚、申诉、审计的统一后台入口</p>
          </div>
          <div className="admin-login-status-grid" aria-label="当前接入状态">
            <StatusBadge label="当前模式" value={activeLoginMode} tone="green" />
            <StatusBadge
              label="会话状态"
              value={carrierConnected ? '已接入' : '未接入'}
              tone={carrierConnected ? 'green' : 'orange'}
            />
            <StatusBadge label="API 直连" value="Server Admin API" tone="gray" />
          </div>
        </header>

        <div className="admin-login-content">
          <div className="admin-login-main-column">
            <section className="admin-login-card primary-card">
              <div className="admin-login-card-heading">
                <span className="admin-card-icon">◇</span>
                <div>
                  <p className="eyebrow">Admin Session Carrier</p>
                  <h2>管理员会话接入</h2>
                  <p>
                    由 Server Auth 签发管理员 session carrier，验证通过后写入当前浏览器会话。
                  </p>
                </div>
              </div>
              <form className="issuer-form" action={issueAdminSessionCarrierAction}>
                <input name="next" type="hidden" value={nextPath} />
                <div className="issuer-form-grid">
                  <label>
                    管理员手机号
                    <input
                      autoComplete="username"
                      inputMode="tel"
                      name="mobile"
                      placeholder="输入已具备平台审核角色的手机号"
                      required
                    />
                  </label>
                  <label>
                    Server Auth 密码
                    <input
                      autoComplete="current-password"
                      name="password"
                      placeholder="输入 Server Auth 密码"
                      required
                      type="password"
                    />
                  </label>
                </div>
                <input name="deviceId" type="hidden" value="admin-carrier-browser" />
                <label className="issuer-consent">
                  <input name="consentAccepted" required type="checkbox" />
                  <span>
                    确认仅由 Server Auth 校验凭据并签发 carrier，Admin 不保存账号密码。
                  </span>
                </label>
                <button className="primary admin-login-submit" type="submit">
                  由 Server 签发并进入治理后台
                </button>
              </form>
              <div className="login-divider">
                <span>或粘贴已签发 carrier</span>
              </div>
              <form className="carrier-form" action={connectAdminSessionCarrierAction}>
                <input name="next" type="hidden" value={nextPath} />
                <label>
                  会话载体（session carrier）
                  <textarea
                    aria-label="服务端管理员会话载体"
                    name="sessionCarrier"
                    placeholder="粘贴 access carrier，或完整 Bearer 头"
                    required
                    rows={7}
                  />
                </label>
                <button className="primary admin-login-submit" type="submit">
                  验证并进入治理后台
                </button>
              </form>
              <div className="admin-login-default-entry">
                <span>接入后默认进入</span>
                <strong>审计日志 {nextPath}</strong>
              </div>
              {carrierConnected ? (
                <form className="clear-carrier-form" action={clearAdminSessionCarrierAction}>
                  <input name="next" type="hidden" value={nextPath} />
                  <button className="primary danger-button" type="submit">
                    清除当前会话载体
                  </button>
                </form>
              ) : null}
            </section>

            <section className="admin-login-card quick-card">
              <div className="section-heading">
                <span className="section-mark">▦</span>
                <h2>快捷入口</h2>
              </div>
              <div className="quick-entry-grid">
                {quickLinks.map((item) => (
                  <Link className={`quick-entry ${item.tone}`} href={item.href} key={item.href}>
                    <span className="quick-entry-icon">↗</span>
                    <strong>{item.label}</strong>
                    <small>{item.description}</small>
                  </Link>
                ))}
              </div>
            </section>
          </div>

          <aside className="admin-login-side-column" aria-label="接入说明">
            <InfoCard
              title="当前模式"
              badge={toLoginModeLabel(activeLoginMode)}
              items={[
                '仅依赖 Server 签发的管理员会话载体',
                '不经过 BFF',
                '不建立独立 Admin 账号密码体系',
              ]}
            />
            <ProcessCard />
            <InfoCard
              title="安全边界"
              items={[
                '不存储账号密码',
                '不伪造登录成功',
                '平台角色仍由 Server DB-backed membership 校验',
              ]}
              tone="gold"
            />
            {configuredLoginMode !== activeLoginMode ? (
              <div className="admin-login-alert">
                检测到旧配置仍在声明 {configuredLoginMode}，当前已强制收口为
                server_session_carrier_only。
              </div>
            ) : null}
            {notice ? <div className="admin-login-alert success">{toNoticeText(notice)}</div> : null}
            {error ? <div className="admin-login-alert danger">{error}</div> : null}
          </aside>
        </div>
        <footer className="admin-login-footer">
          <span>Server Admin API 治理台</span>
          <span>仅接收 Server 签发的管理员会话载体</span>
          <span>不建立独立 Admin 账号密码</span>
          <span>不经过 BFF</span>
        </footer>
      </div>
    </section>
  );
}

function StatusBadge({
  label,
  value,
  tone,
}: {
  label: string;
  value: string;
  tone: 'green' | 'orange' | 'gray';
}) {
  return (
    <div className={`status-badge ${tone}`}>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

function InfoCard({
  title,
  badge,
  items,
  tone = 'green',
}: {
  title: string;
  badge?: string;
  items: string[];
  tone?: 'green' | 'gold';
}) {
  return (
    <section className={`admin-login-card info-card ${tone}`}>
      <h2>{title}</h2>
      {badge ? <span className="mode-pill">{badge}</span> : null}
      <ul>
        {items.map((item) => (
          <li key={item}>{item}</li>
        ))}
      </ul>
    </section>
  );
}

function ProcessCard() {
  const steps = [
    ['提交 Server Auth 凭据', '仅发送给 Server，由 Server 判断身份与平台角色'],
    ['Server 签发 carrier', '通过 platform_reviewer 或 platform_super_admin 后返回管理员会话载体'],
    ['写入 admin_session 后进入工作台', '验证通过后写入浏览器会话并跳转'],
  ] as const;

  return (
    <section className="admin-login-card process-card">
      <h2>最小接入流程</h2>
      <ol>
        {steps.map(([title, description], index) => (
          <li key={title}>
            <span>{index + 1}</span>
            <div>
              <strong>{title}</strong>
              <small>{description}</small>
            </div>
          </li>
        ))}
      </ol>
    </section>
  );
}

function toLoginModeLabel(loginMode: string) {
  if (loginMode === 'server_session_carrier_only') {
    return '仅依赖服务端管理员会话载体';
  }
  return '凭据模式待确认';
}

function toNoticeText(value: string) {
  if (value === 'carrier_cleared') {
    return '当前浏览器内的 admin_session 会话载体已清除。';
  }
  return value;
}

function readQueryParam(value: string | string[] | undefined) {
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}
