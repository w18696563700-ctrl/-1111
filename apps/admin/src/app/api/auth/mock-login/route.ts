import { NextResponse } from 'next/server';

export async function POST() {
  return NextResponse.json(
    {
      ok: false,
      code: 'ADMIN_CREDENTIAL_SOURCE_UNCONFIRMED',
      message: '当前未确认真实管理员凭据来源，禁止在占位页内伪造成功登录。',
    },
    { status: 409 },
  );
}
