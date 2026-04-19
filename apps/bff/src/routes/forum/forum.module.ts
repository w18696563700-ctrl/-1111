import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppForumController } from './app-forum.controller';
import { ForumCommandContextService } from './forum-command-context.service';
import { ForumCommandErrorService } from './forum-command-error.service';
import { ForumDraftCommandErrorMessageService } from './forum-draft-command-error-message.service';
import { ForumController } from './forum.controller';
import { ForumInteractionCommandErrorMessageService } from './forum-interaction-command-error-message.service';
import { ForumOwnPostCommandErrorMessageService } from './forum-own-post-command-error-message.service';
import { ForumPublishResultService } from './forum-publish-result.service';
import { ForumReportCommandErrorMessageService } from './forum-report-command-error-message.service';
import { ForumReportMineErrorService } from './forum-report-mine-error.service';
import { ForumReportMineService } from './forum-report-mine.service';
import { ForumService } from './forum.service';

@Module({
  imports: [CoreModule],
  controllers: [AppForumController, ForumController],
  providers: [
    ForumCommandContextService,
    ForumCommandErrorService,
    ForumDraftCommandErrorMessageService,
    ForumInteractionCommandErrorMessageService,
    ForumOwnPostCommandErrorMessageService,
    ForumPublishResultService,
    ForumReportCommandErrorMessageService,
    ForumReportMineErrorService,
    ForumReportMineService,
    ForumService,
  ],
})
export class ForumModule {}
