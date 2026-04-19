type ProjectSeedSource = {
  id: string;
  projectNo: string;
  organizationId: string;
  title: string | null;
};

type WinningBidSeedSource = {
  id: string;
  organizationId: string;
  quoteAmount: string | number | null;
};

export type OrderSeedCarrier = {
  orderId: string;
  orderNo: string;
  projectId: string;
  bidId: string;
  buyerOrganizationId: string;
  supplierOrganizationId: string;
  title: string;
  createdBy: string;
  totalAmount: string;
  state: 'active';
  activatedAt: string;
};

export function createOrderSeed(
  project: ProjectSeedSource,
  winningBid: WinningBidSeedSource,
  createdBy: string,
  orderId: string,
  activatedAt: string
) {
  return {
    orderId,
    orderNo: toOrderNo(project.projectNo, orderId),
    projectId: project.id,
    bidId: winningBid.id,
    buyerOrganizationId: project.organizationId,
    supplierOrganizationId: winningBid.organizationId,
    title: resolveOrderTitle(project),
    createdBy: readRequiredText(createdBy),
    totalAmount: normalizeAmount(winningBid.quoteAmount),
    state: 'active',
    activatedAt
  } satisfies OrderSeedCarrier;
}

function toOrderNo(projectNo: string, orderId: string) {
  const normalizedProjectNo = projectNo.trim();
  const fallback = orderId.replace(/-/g, '').slice(0, 16);
  const base = normalizedProjectNo ? `ORD-${normalizedProjectNo}` : `ORD-${fallback}`;
  return base.slice(0, 64);
}

function normalizeAmount(value: string | number | null) {
  const amount = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(amount) || amount <= 0) {
    return '0.00';
  }
  return amount.toFixed(2);
}

function resolveOrderTitle(project: ProjectSeedSource) {
  const title = project.title?.trim() ?? '';
  if (title) {
    return title;
  }
  const projectNo = project.projectNo.trim();
  if (projectNo) {
    return projectNo;
  }
  return project.id.trim();
}

function readRequiredText(value: string | null | undefined) {
  const normalized = value?.trim() ?? '';
  if (!normalized) {
    throw new Error('Current order seed requires a non-empty value.');
  }
  return normalized;
}
