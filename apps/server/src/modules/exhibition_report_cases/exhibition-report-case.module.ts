import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ContentSafetyModule } from '../content_safety/content-safety.module';
import { OrganizationModule } from '../organization/organization.module';
import { ExhibitionReportCaseAdminController } from './exhibition-report-case-admin.controller';
import { ExhibitionReportCaseAppController } from './exhibition-report-case-app.controller';
import { ExhibitionReportCasePresenter } from './exhibition-report-case.presenter';
import { ExhibitionReportCaseService } from './exhibition-report-case.service';
import { ExhibitionReportCaseEntity } from './entities/exhibition-report-case.entity';

@Module({
  imports: [
    AuthModule,
    ContentSafetyModule,
    OrganizationModule,
    TypeOrmModule.forFeature([ExhibitionReportCaseEntity])
  ],
  controllers: [ExhibitionReportCaseAppController, ExhibitionReportCaseAdminController],
  providers: [ExhibitionReportCasePresenter, ExhibitionReportCaseService]
})
export class ExhibitionReportCaseModule {}
