part of 'enterprise_hub_workbench_pages.dart';

const String _enterpriseDisplayBusinessType = 'enterprise_display';
const String _enterpriseLogoFileKind = 'enterprise_logo';
const String _enterpriseAlbumFileKind = 'enterprise_album';
const String _enterpriseFactoryShowcaseFileKind = 'enterprise_factory_showcase';
const String _enterpriseCaseMediaFileKind = 'enterprise_case_media';
const int _workbenchImageLimit = 6;

enum _WorkbenchImageStage { uploading, ready, failed }

class _WorkbenchPickedImage {
  const _WorkbenchPickedImage({
    required this.name,
    required this.bytes,
    required this.mimeType,
    required this.checksum,
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;
  final String checksum;
}

class _WorkbenchImageItem {
  const _WorkbenchImageItem({
    required this.localId,
    required this.fileName,
    required this.stage,
    this.bytes,
    this.mimeType,
    this.checksum,
    this.fileAssetId,
    this.imageUrl,
    this.statusMessage,
  });

  factory _WorkbenchImageItem.local({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    required String checksum,
    required _WorkbenchImageStage stage,
    String? statusMessage,
  }) {
    return _WorkbenchImageItem(
      localId: '${DateTime.now().microsecondsSinceEpoch}-$fileName',
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
      checksum: checksum,
      stage: stage,
      statusMessage: statusMessage,
    );
  }

  factory _WorkbenchImageItem.remote({
    required String fileAssetId,
    required String fallbackLabel,
    String? imageUrl,
  }) {
    final compactId = fileAssetId.length > 12
        ? fileAssetId.substring(fileAssetId.length - 12)
        : fileAssetId;
    return _WorkbenchImageItem(
      localId: fileAssetId,
      fileName: '$fallbackLabel · $compactId',
      fileAssetId: fileAssetId,
      imageUrl: imageUrl,
      stage: _WorkbenchImageStage.ready,
      statusMessage: '已保存',
    );
  }

  final String localId;
  final String fileName;
  final Uint8List? bytes;
  final String? mimeType;
  final String? checksum;
  final String? fileAssetId;
  final String? imageUrl;
  final _WorkbenchImageStage stage;
  final String? statusMessage;

  _WorkbenchImageItem copyWith({
    Uint8List? bytes,
    String? mimeType,
    String? checksum,
    String? fileAssetId,
    String? imageUrl,
    _WorkbenchImageStage? stage,
    String? statusMessage,
  }) {
    return _WorkbenchImageItem(
      localId: localId,
      fileName: fileName,
      bytes: bytes ?? this.bytes,
      mimeType: mimeType ?? this.mimeType,
      checksum: checksum ?? this.checksum,
      fileAssetId: fileAssetId ?? this.fileAssetId,
      imageUrl: imageUrl ?? this.imageUrl,
      stage: stage ?? this.stage,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class _WorkbenchEmptyUploadState extends StatelessWidget {
  const _WorkbenchEmptyUploadState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(message, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _WorkbenchImageTile extends StatelessWidget {
  const _WorkbenchImageTile({
    required this.item,
    this.imageFit = BoxFit.cover,
    this.imageHeight = 96,
    this.showMetadata = true,
    required this.onReplace,
    required this.onRemove,
  });

  final _WorkbenchImageItem item;
  final BoxFit imageFit;
  final double imageHeight;
  final bool showMetadata;
  final Future<void> Function()? onReplace;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: item.bytes != null
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.memory(item.bytes!, fit: imageFit),
                        ),
                      )
                    : item.imageUrl?.trim().isNotEmpty == true
                    ? Image.network(
                        item.imageUrl!.trim(),
                        fit: imageFit,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) => DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              child: const Center(
                                child: Icon(Icons.image_outlined, size: 28),
                              ),
                            ),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        child: const Center(
                          child: Icon(Icons.image_outlined, size: 28),
                        ),
                      ),
              ),
            ),
            if (showMetadata) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                item.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.statusMessage != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  item.statusMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (onReplace != null)
                  TextButton(onPressed: onReplace, child: const Text('替换')),
                if (onRemove != null)
                  TextButton(onPressed: onRemove, child: const Text('移除')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
