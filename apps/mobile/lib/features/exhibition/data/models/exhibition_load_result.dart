part of '../exhibition_consumer_layer.dart';

class ExhibitionLoadResult {
  const ExhibitionLoadResult({
    required this.state,
    required this.method,
    required this.path,
    this.payload,
    this.errorCode,
    this.message,
  });

  final AppPageState state;
  final String method;
  final String path;
  final Object? payload;
  final String? errorCode;
  final String? message;
}
