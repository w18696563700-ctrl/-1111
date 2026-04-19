import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { CreditScoringShadowModule } from '../credit_scoring_shadow/credit-scoring-shadow.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { RatingController } from './rating.controller';
import { RatingPresenter } from './rating.presenter';
import { RatingQueryService } from './rating.query.service';
import { RatingWriteService } from './rating.write.service';

@Module({
  imports: [TypeOrmModule.forFeature([ProjectEntity]), AuthModule, OrganizationModule, CreditScoringShadowModule],
  controllers: [RatingController],
  providers: [RatingPresenter, RatingQueryService, RatingWriteService]
})
export class RatingModule {}
