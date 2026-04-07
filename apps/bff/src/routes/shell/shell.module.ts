import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppShellController } from './app-shell.controller';
import { ShellController } from './shell.controller';
import { ShellService } from './shell.service';

@Module({
  imports: [CoreModule],
  controllers: [ShellController, AppShellController],
  providers: [ShellService],
})
export class ShellModule {}
