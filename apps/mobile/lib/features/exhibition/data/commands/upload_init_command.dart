part of '../exhibition_consumer_layer.dart';

class UploadInitCommand {
  const UploadInitCommand({
    required this.businessType,
    required this.businessId,
    required this.fileKind,
    required this.mimeType,
    required this.size,
    required this.checksum,
  });

  final String businessType;
  final String businessId;
  final String fileKind;
  final String mimeType;
  final int size;
  final String checksum;

  Map<String, Object?> toJson() => <String, Object?>{
    'businessType': businessType,
    'businessId': businessId,
    'fileKind': fileKind,
    'mimeType': mimeType,
    'size': size,
    'checksum': checksum,
  };
}
