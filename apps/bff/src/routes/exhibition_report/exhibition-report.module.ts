import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppExhibitionReportController } from './app-exhibition-report.controller';
import { ExhibitionReportService } from './exhibition-report.service';

@Module({
  imports: [CoreModule],
  controllers: [AppExhibitionReportController],
  providers: [ExhibitionReportService]
})
export class ExhibitionReportModule {}
