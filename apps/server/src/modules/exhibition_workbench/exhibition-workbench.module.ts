import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { ExhibitionWorkbenchController } from './exhibition-workbench.controller';
import { ExhibitionWorkbenchPresenter } from './exhibition-workbench.presenter';
import { ExhibitionWorkbenchQueryService } from './exhibition-workbench.query.service';

@Module({
  imports: [TypeOrmModule.forFeature([ProjectEntity]), AuthModule, OrganizationModule],
  controllers: [ExhibitionWorkbenchController],
  providers: [ExhibitionWorkbenchPresenter, ExhibitionWorkbenchQueryService]
})
export class ExhibitionWorkbenchModule {}
