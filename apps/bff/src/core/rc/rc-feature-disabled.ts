import { HttpException, HttpStatus } from "@nestjs/common";

export function rcFeatureDisabled(feature: string): never {
  throw new HttpException(
    {
      statusCode: HttpStatus.FORBIDDEN,
      code: "PLATFORM_CAPABILITY_DISABLED",
      message: "该功能暂未开放",
      source: "bff",
      feature,
    },
    HttpStatus.FORBIDDEN,
  );
}
