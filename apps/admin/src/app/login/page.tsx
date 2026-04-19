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
} from '@/core/auth/session-carrier-actions';

type LoginPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const params = await searchParams;
  const cookieStore = await cookies();
  const configuredLoginMode = getServerConfig().loginMode;
  const activeLoginMode = resolveActiveAdminLoginMode();
  const nextPath = sanitizeAdminNextPath(readQueryParam(params?.next));
  const sessionCarrier = cookieStore.get(ADMIN_SESSION_COOKIE)?.value ?? '';
  const carrierConnected = hasAdminSessionCarrier(sessionCarrier);
  const error = readQueryParam(params?.error);
  const notice = readQueryParam(params?.notice);

  return (
    <section className="panel login-card">
      <p className="eyebrow">Admin Session Carrier</p>
      <h1>管理员会话载体接入</h1>
      <p className="lead">
        Admin 当前不再承接账号密码占位登录。后台只接收由 Server 已签发的管理员
        session carrier，并把它收口为当前浏览器内的 `admin_session` 会话载体，
        后续 review / governance 请求仍然直连 Server Admin API，不经过 BFF。
      </p>
      <div className="notice-grid">
        <div className="notice">
          <strong>当前激活模式</strong>
          <div>{toLoginModeLabel(activeLoginMode)}</div>
          <small>active：{activeLoginMode}</small>
        </div>
        {configuredLoginMode !== activeLoginMode ? (
          <div className="notice warning">
            检测到旧配置仍在声明 {configuredLoginMode}，但 Admin 已强制收口为
            server_session_carrier_only。
          </div>
        ) : null}
        <div className={carrierConnected ? 'notice' : 'notice warning'}>
          {carrierConnected
            ? '当前浏览器已检测到 admin_session 会话载体，可直接进入工作台。'
            : '当前浏览器未检测到 admin_session，会话保护路由会回到本页。'}
        </div>
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
      </div>
      <div className="notice">
        <strong>最小接入方式</strong>
        <div>1. 从受控 Server 会话来源取得已签发 carrier。</div>
        <div>2. 在本页粘贴 carrier，Admin 会先直连 Server 校验可用性。</div>
        <div>3. 校验通过后，仅写入 admin_session cookie，再进入同一工作台闭环。</div>
      </div>
      <form action={connectAdminSessionCarrierAction}>
        <input name="next" type="hidden" value={nextPath} />
        <label>
          服务端管理员会话载体
          <textarea
            aria-label="服务端管理员会话载体"
            name="sessionCarrier"
            placeholder="粘贴 Server 已签发的 access carrier，或完整 Bearer 头"
            required
            rows={6}
          />
        </label>
        <button className="primary" type="submit">
          验证并接入会话载体
        </button>
      </form>
      <div className="notice">
        <strong>接入后默认去向</strong>
        <div>{nextPath}</div>
      </div>
      <div className="notice-grid">
        {carrierConnected ? (
          <Link className="primary" href={nextPath}>
            进入当前工作台
          </Link>
        ) : null}
        <Link href="/review">Review Workbench</Link>
        <Link href="/governance/penalties">Governance Penalties</Link>
        <Link href="/governance/appeals">Governance Appeals</Link>
      </div>
      {carrierConnected ? (
        <form action={clearAdminSessionCarrierAction}>
          <input name="next" type="hidden" value={nextPath} />
          <button className="primary danger-button" type="submit">
            清除当前会话载体
          </button>
        </form>
      ) : null}
      <p className="helper-text">
        本页不会索取账号密码，也不会伪造登录成功；唯一允许的入口是受控 Server
        会话载体。
      </p>
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
