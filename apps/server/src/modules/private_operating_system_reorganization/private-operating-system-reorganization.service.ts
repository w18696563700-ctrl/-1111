import { Injectable } from '@nestjs/common';
import {
  buildProfileIndexProjection,
  buildShellContextProjection
} from './private-operating-system-reorganization.catalog';

@Injectable()
export class PrivateOperatingSystemReorganizationService {
  getProfileIndexProjection() {
    return buildProfileIndexProjection();
  }

  getShellContextProjection() {
    return buildShellContextProjection();
  }
}

