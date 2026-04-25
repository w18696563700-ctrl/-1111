import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppBidController } from './app-bid.controller';
import { AppBidOrderSelectionController } from './app-bid-order-selection.controller';
import { BidController } from './bid.controller';
import { BidOrderSelectionService } from './bid-order-selection.service';
import { BidService } from './bid.service';

@Module({
  imports: [CoreModule],
  controllers: [BidController, AppBidController, AppBidOrderSelectionController],
  providers: [BidService, BidOrderSelectionService],
})
export class BidModule {}
