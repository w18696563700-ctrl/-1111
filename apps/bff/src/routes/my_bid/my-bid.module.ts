import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { MyBidController } from './my-bid.controller';
import { MyBidService } from './my-bid.service';

@Module({
  imports: [CoreModule],
  controllers: [MyBidController],
  providers: [MyBidService],
})
export class MyBidModule {}
