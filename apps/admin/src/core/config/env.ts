const DEFAULT_SERVER_ADMIN_API_BASE_URL = 'http://127.0.0.1:3001/server/admin';
const DEFAULT_LOGIN_MODE = 'account_password_plus_second_factor';

export function getServerConfig() {
  return {
    serverAdminApiBaseUrl:
      process.env.SERVER_ADMIN_API_BASE_URL ?? DEFAULT_SERVER_ADMIN_API_BASE_URL,
    loginMode:
      process.env.NEXT_PUBLIC_ADMIN_LOGIN_MODE ?? DEFAULT_LOGIN_MODE,
  };
}

export function getClientConfig() {
  return {
    loginMode:
      process.env.NEXT_PUBLIC_ADMIN_LOGIN_MODE ?? DEFAULT_LOGIN_MODE,
  };
}
