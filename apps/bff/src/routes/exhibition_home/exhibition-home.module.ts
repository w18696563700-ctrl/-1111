import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppExhibitionHomeController } from './app-exhibition-home.controller';
import { ExhibitionHomeService } from './exhibition-home.service';

@Module({
  imports: [CoreModule],
  controllers: [AppExhibitionHomeController],
  providers: [ExhibitionHomeService],
})
export class ExhibitionHomeModule {}
