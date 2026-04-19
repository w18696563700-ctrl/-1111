import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppBidController } from './app-bid.controller';
import { BidController } from './bid.controller';
import { BidService } from './bid.service';

@Module({
  imports: [CoreModule],
  controllers: [BidController, AppBidController],
  providers: [BidService],
})
export class BidModule {}
