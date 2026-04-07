import { Controller, Get, Headers } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ShellService } from './shell.service';

@Controller('bff/shell')
export class ShellController {
  constructor(private readonly shellService: ShellService) {}

  @Get('context')
  getContext(@Headers() headers: IncomingHttpHeaders) {
    return this.shellService.getContext(headers);
  }
}
