import { OrderSeedCarrier } from '../order/order.seed';

type ProjectSeedSource = {
  projectNo: string;
  title: string | null;
};

export type ContractSeedCarrier = {
  contractId: string;
  orderId: string;
  contractNo: string;
  state: 'pending_confirm';
  summaryText: string | null;
  amendCount: number;
};

export function createContractSeed(
  project: ProjectSeedSource,
  order: OrderSeedCarrier,
  contractId: string
) {
  return {
    contractId,
    orderId: order.orderId,
    contractNo: toContractNo(order.orderNo, project.projectNo, contractId),
    state: 'pending_confirm',
    summaryText: toSummaryText(project.projectNo, project.title),
    amendCount: 0
  } satisfies ContractSeedCarrier;
}

function toContractNo(orderNo: string, projectNo: string, contractId: string) {
  const normalizedOrderNo = orderNo.trim();
  if (normalizedOrderNo) {
    const derived = normalizedOrderNo.startsWith('ORD-')
      ? `CTR-${normalizedOrderNo.slice(4)}`
      : `CTR-${normalizedOrderNo}`;
    return derived.slice(0, 64);
  }
  const normalizedProjectNo = projectNo.trim();
  if (normalizedProjectNo) {
    return `CTR-${normalizedProjectNo}`.slice(0, 64);
  }
  const fallback = contractId.replace(/-/g, '').slice(0, 24);
  return `CTR-${fallback}`.slice(0, 64);
}

function toSummaryText(projectNo: string, title: string | null) {
  const normalizedTitle = title?.trim() ?? '';
  if (normalizedTitle) {
    return `${normalizedTitle} 合同待确认种子`;
  }
  const normalizedProjectNo = projectNo.trim();
  return normalizedProjectNo ? `Bridge contract seed for ${normalizedProjectNo}` : null;
}
