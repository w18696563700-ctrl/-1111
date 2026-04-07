import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { EnterpriseHubModule } from './enterprise_hub/enterprise-hub.module';
import { ExhibitionHomeModule } from './exhibition_home/exhibition-home.module';
import { ExhibitionWorkbenchModule } from './exhibition_workbench/exhibition-workbench.module';
import { FileUploadModule } from './file/file-upload.module';
import { ForumModule } from './forum/forum.module';
import { MyProjectModule } from './my_project/my-project.module';
import { ProfileReadModule } from './profile/profile-read.module';
import { ProjectModule } from './project/project.module';
import { ShellModule } from './shell/shell.module';

@Module({
  // Keep the local source graph aligned with the currently frozen app-facing surfaces in this workspace slice.
  imports: [
    AuthModule,
    EnterpriseHubModule,
    ExhibitionHomeModule,
    ExhibitionWorkbenchModule,
    ForumModule,
    MyProjectModule,
    ShellModule,
    ProfileReadModule,
    ProjectModule,
    FileUploadModule,
  ],
})
export class RoutesModule {}
