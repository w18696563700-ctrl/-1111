import Link from 'next/link';

type GovernanceTab = 'penalties' | 'appeals';

export function GovernanceTabs({ tab }: { tab: GovernanceTab }) {
  return (
    <nav className="governance-tabs" aria-label="治理分区">
      <Link className={tab === 'penalties' ? 'tab-link active' : 'tab-link'} href="/governance/penalties">
        处罚
      </Link>
      <Link className={tab === 'appeals' ? 'tab-link active' : 'tab-link'} href="/governance/appeals">
        申诉
      </Link>
    </nav>
  );
}
