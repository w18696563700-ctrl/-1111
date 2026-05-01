import { Controller, Get, Headers, Param, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { MembershipAdminQueryService } from './membership-admin-query.service';

@Controller('server/admin/membership')
export class MembershipAdminController {
  constructor(private readonly adminQueryService: MembershipAdminQueryService) {}

  @Get('orders')
  listOrders(
    @Query() query: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.adminQueryService.listOrders(
      query,
      resolveRequestContext(headers)
    );
  }

  @Get('orders/:membershipOrderId')
  getOrderDetail(
    @Param('membershipOrderId') membershipOrderId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.adminQueryService.getOrderDetail(
      membershipOrderId,
      resolveRequestContext(headers)
    );
  }

  @Get('organizations/:organizationId/status')
  getOrganizationMembershipStatus(
    @Param('organizationId') organizationId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.adminQueryService.getOrganizationMembershipStatus(
      organizationId,
      resolveRequestContext(headers)
    );
  }
}
