import Link from 'next/link';
import './globals.css';

export const metadata = {
  title: '展陈管理后台',
  description: '管理员控制台基线',
};

const links = [
  { href: '/review', label: '审核任务' },
  { href: '/review/change_requests', label: '展示变更' },
  { href: '/governance', label: '治理处罚' },
  { href: '/project_review', label: '举报案件' },
  { href: '/template_config', label: '模板治理' },
  { href: '/audit', label: '审计日志' },
  { href: '/membership', label: '会员只读' },
  { href: '/ticketing', label: '工单占位' },
];

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN">
      <body>
        <main className="app-shell">
          <header className="topbar">
            <div>
              <p className="eyebrow">管理后台</p>
              <strong>Server Admin API 治理台</strong>
            </div>
            <nav>
              {links.map((link) => (
                <Link key={link.href} href={link.href}>
                  {link.label}
                </Link>
              ))}
            </nav>
          </header>
          {children}
        </main>
      </body>
    </html>
  );
}
