import { Module } from '@nestjs/common';
import { ExhibitionHomeController } from './exhibition-home.controller';
import { ExhibitionHomePresenter } from './exhibition-home.presenter';
import { ExhibitionHomeQueryService } from './exhibition-home.query.service';

@Module({
  controllers: [ExhibitionHomeController],
  providers: [ExhibitionHomePresenter, ExhibitionHomeQueryService]
})
export class ExhibitionHomeModule {}
