import Link from 'next/link';
import './globals.css';

export const metadata = {
  title: '展陈管理后台',
  description: '管理员控制台基线',
};

const links = [
  { href: '/review', label: '审核' },
  { href: '/review/change_requests', label: '展示变更' },
  { href: '/governance', label: '治理' },
  { href: '/project_review', label: '项目审核' },
  { href: '/template_config', label: '模板配置' },
  { href: '/audit', label: '审计' },
  { href: '/ticketing', label: '工单' },
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
              <strong>受控的服务端管理接口</strong>
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
