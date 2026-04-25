import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppExhibitionP0PayController } from './app-exhibition-p0-pay.controller';
import { ExhibitionP0PayErrorService } from './exhibition-p0-pay-error.service';
import { ExhibitionP0PayPayloadService } from './exhibition-p0-pay-payload.service';
import { ExhibitionP0PayService } from './exhibition-p0-pay.service';

@Module({
  imports: [CoreModule],
  controllers: [AppExhibitionP0PayController],
  providers: [
    ExhibitionP0PayService,
    ExhibitionP0PayPayloadService,
    ExhibitionP0PayErrorService,
  ],
})
export class ExhibitionP0PayModule {}
