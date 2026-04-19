import { Controller, Get, Headers, Param, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { AuditLogQueryService } from './audit-log-query.service';

@Controller('server/admin/audit/logs')
export class AuditAdminController {
  constructor(private readonly auditLogQueryService: AuditLogQueryService) {}

  @Get()
  list(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.auditLogQueryService.list(query, resolveRequestContext(headers));
  }

  @Get(':auditLogId')
  detail(@Param('auditLogId') auditLogId: string, @Headers() headers: HeaderBag) {
    return this.auditLogQueryService.detail(auditLogId, resolveRequestContext(headers));
  }
}
