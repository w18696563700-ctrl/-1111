part of '../exhibition_consumer_layer.dart';

class UploadDirective {
  const UploadDirective({
    required this.uploadSessionId,
    required this.directUploadUrl,
    required this.directUploadMethod,
    required this.directUploadHeaders,
    required this.confirmEndpoint,
  });

  final String uploadSessionId;
  final String directUploadUrl;
  final String directUploadMethod;
  final Map<String, String> directUploadHeaders;
  final String confirmEndpoint;
}
