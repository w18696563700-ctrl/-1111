part of '../exhibition_consumer_layer.dart';

class ExhibitionActionResult {
  const ExhibitionActionResult({
    required this.method,
    required this.path,
    required this.isSuccess,
    this.payload,
    this.controlledState,
    this.errorCode,
    this.message,
  });

  final String method;
  final String path;
  final bool isSuccess;
  final Object? payload;
  final AppPageState? controlledState;
  final String? errorCode;
  final String? message;
}
