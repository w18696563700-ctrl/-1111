import { ModuleShell } from '@/shared/components/module-shell';

export function TicketingShell() {
  return (
    <ModuleShell
      title="工单占位"
      description="问题分流与人工升级入口当前只保留占位，不接入通用工单重系统。"
      apiPath="未开放：等待服务端治理案件与客服边界冻结"
      owner="服务端审核域 + 服务端通知域"
      nextStep="后续只能在治理案件、申诉和客服受理边界冻结后再进入实现。"
    />
  );
}
