import { ModuleShell } from '@/shared/components/module-shell';

export function TicketingShell() {
  return (
    <ModuleShell
      title="工单"
      description="问题分流与人工升级入口的最小运维占位页。"
      apiPath="/admin/ticketing/*"
      owner="服务端审核域 + 服务端通知域"
      nextStep="待运维流程冻结后，再接入非交易型工单队列。"
    />
  );
}
