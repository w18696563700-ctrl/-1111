import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppExhibitionWorkbenchController } from './app-exhibition-workbench.controller';
import { ExhibitionWorkbenchService } from './exhibition-workbench.service';

@Module({
  imports: [CoreModule],
  controllers: [AppExhibitionWorkbenchController],
  providers: [ExhibitionWorkbenchService],
})
export class ExhibitionWorkbenchModule {}
