import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectPresenter } from '../project/project.presenter';
import { MyProjectController } from './my-project.controller';
import { MyProjectPresenter } from './my-project.presenter';
import { MyProjectQueryService } from './my-project.query.service';

@Module({
  imports: [TypeOrmModule.forFeature([ProjectEntity]), AuthModule, OrganizationModule],
  controllers: [MyProjectController],
  providers: [ProjectPresenter, MyProjectPresenter, MyProjectQueryService]
})
export class MyProjectModule {}
