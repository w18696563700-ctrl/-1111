part of '../exhibition_trade_pages.dart';

const int _projectCommunicationOfficePreviewMaxChars = 12000;

final class _WorkbenchInAppPreviewDocument {
  const _WorkbenchInAppPreviewDocument({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
}

Future<bool> _showProjectCommunicationInAppFilePreviewDialog(
  BuildContext context, {
  required ProjectCommunicationFilePreviewAccessView preview,
  required List<int> bytes,
}) async {
  final document = _buildProjectCommunicationInAppPreviewDocument(
    preview: preview,
    bytes: bytes,
  );
  if (document == null) {
    return false;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return Dialog(
        insetPadding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 760,
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4DE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        document.icon,
                        color: const Color(0xFFB8751A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'App 内资料预览',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            document.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      document.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: SelectableText(
                          document.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.55,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '关闭预览后才能提交确认；该确认结果仍以 Server 返回状态为准。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return true;
}

_WorkbenchInAppPreviewDocument? _buildProjectCommunicationInAppPreviewDocument({
  required ProjectCommunicationFilePreviewAccessView preview,
  required List<int> bytes,
}) {
  final mimeType = preview.mimeType?.toLowerCase().trim() ?? '';
  final fileName = preview.fileName ?? preview.fileAssetId;
  final lowerName = fileName.toLowerCase();
  if (preview.previewType == 'text' ||
      mimeType.startsWith('text/') ||
      mimeType == 'application/json') {
    final text = _decodeProjectCommunicationPreviewText(bytes);
    if (text == null) return null;
    return _WorkbenchInAppPreviewDocument(
      title: fileName,
      subtitle: '文本资料 · App 内只读预览',
      body: text,
      icon: Icons.description_outlined,
    );
  }
  if (_isProjectCommunicationDocx(mimeType, lowerName)) {
    final text = _extractProjectCommunicationDocxText(bytes);
    if (text == null) return null;
    return _WorkbenchInAppPreviewDocument(
      title: fileName,
      subtitle: 'DOCX 文档 · App 内正文预览',
      body: text,
      icon: Icons.article_outlined,
    );
  }
  if (_isProjectCommunicationXlsx(mimeType, lowerName)) {
    final text = _extractProjectCommunicationXlsxText(bytes);
    if (text == null) return null;
    return _WorkbenchInAppPreviewDocument(
      title: fileName,
      subtitle: 'XLSX 表格 · App 内工作表预览',
      body: text,
      icon: Icons.table_chart_outlined,
    );
  }
  if (_isProjectCommunicationPptx(mimeType, lowerName)) {
    final text = _extractProjectCommunicationPptxText(bytes);
    if (text == null) return null;
    return _WorkbenchInAppPreviewDocument(
      title: fileName,
      subtitle: 'PPTX 演示文稿 · App 内文字预览',
      body: text,
      icon: Icons.slideshow_outlined,
    );
  }
  return null;
}

String? _decodeProjectCommunicationPreviewText(List<int> bytes) {
  try {
    final text = utf8.decode(bytes, allowMalformed: true).trim();
    return _normalizeProjectCommunicationPreviewText(text);
  } on FormatException {
    return null;
  }
}

String? _extractProjectCommunicationDocxText(List<int> bytes) {
  final archive = _decodeProjectCommunicationOfficeArchive(bytes);
  final file = archive?.find('word/document.xml');
  final xml = _readProjectCommunicationArchiveText(file);
  if (xml == null) return null;
  final document = _parseProjectCommunicationXml(xml);
  if (document == null) return null;
  final paragraphs = _xmlElementsByLocalName(document, 'p')
      .map((paragraph) => _xmlTextNodes(paragraph).join(''))
      .map((text) => text.trim())
      .where((text) => text.isNotEmpty)
      .toList(growable: false);
  return _normalizeProjectCommunicationPreviewText(paragraphs.join('\n\n'));
}

String? _extractProjectCommunicationXlsxText(List<int> bytes) {
  final archive = _decodeProjectCommunicationOfficeArchive(bytes);
  if (archive == null) return null;
  final sharedStrings = _readProjectCommunicationXlsxSharedStrings(archive);
  final sheetFiles =
      archive.files
          .where(
            (file) =>
                file.isFile &&
                RegExp(r'^xl/worksheets/sheet\d+\.xml$').hasMatch(file.name),
          )
          .toList(growable: false)
        ..sort((a, b) => a.name.compareTo(b.name));
  final sections = <String>[];
  for (var index = 0; index < sheetFiles.length && index < 6; index += 1) {
    final xml = _readProjectCommunicationArchiveText(sheetFiles[index]);
    final document = xml == null ? null : _parseProjectCommunicationXml(xml);
    if (document == null) continue;
    final rows = <String>[];
    for (final row in _xmlElementsByLocalName(document, 'row')) {
      final cells = <String>[];
      for (final cell in _childXmlElementsByLocalName(row, 'c')) {
        final value = _readProjectCommunicationXlsxCell(cell, sharedStrings);
        if (value.isNotEmpty) {
          cells.add(value);
        }
      }
      if (cells.isNotEmpty) {
        rows.add(cells.join('    '));
      }
      if (rows.length >= 80) break;
    }
    if (rows.isNotEmpty) {
      sections.add('工作表 ${index + 1}\n${rows.join('\n')}');
    }
  }
  return _normalizeProjectCommunicationPreviewText(sections.join('\n\n'));
}

String? _extractProjectCommunicationPptxText(List<int> bytes) {
  final archive = _decodeProjectCommunicationOfficeArchive(bytes);
  if (archive == null) return null;
  final slideFiles =
      archive.files
          .where(
            (file) =>
                file.isFile &&
                RegExp(r'^ppt/slides/slide\d+\.xml$').hasMatch(file.name),
          )
          .toList(growable: false)
        ..sort((a, b) => a.name.compareTo(b.name));
  final sections = <String>[];
  for (var index = 0; index < slideFiles.length && index < 30; index += 1) {
    final xml = _readProjectCommunicationArchiveText(slideFiles[index]);
    final document = xml == null ? null : _parseProjectCommunicationXml(xml);
    if (document == null) continue;
    final text = _xmlElementsByLocalName(document, 't')
        .map((node) => node.innerText.trim())
        .where((value) => value.isNotEmpty)
        .join('\n');
    if (text.isNotEmpty) {
      sections.add('第 ${index + 1} 页\n$text');
    }
  }
  return _normalizeProjectCommunicationPreviewText(sections.join('\n\n'));
}

Archive? _decodeProjectCommunicationOfficeArchive(List<int> bytes) {
  try {
    return ZipDecoder().decodeBytes(bytes, verify: false);
  } on ArchiveException {
    return null;
  } on FormatException {
    return null;
  } on RangeError {
    return null;
  }
}

String? _readProjectCommunicationArchiveText(ArchiveFile? file) {
  if (file == null || !file.isFile) return null;
  final bytes = file.readBytes();
  if (bytes == null || bytes.isEmpty) return null;
  try {
    return utf8.decode(bytes, allowMalformed: true);
  } on FormatException {
    return null;
  }
}

XmlDocument? _parseProjectCommunicationXml(String text) {
  try {
    return XmlDocument.parse(text);
  } on XmlParserException {
    return null;
  }
}

List<String> _readProjectCommunicationXlsxSharedStrings(Archive archive) {
  final xml = _readProjectCommunicationArchiveText(
    archive.find('xl/sharedStrings.xml'),
  );
  final document = xml == null ? null : _parseProjectCommunicationXml(xml);
  if (document == null) return const <String>[];
  return _xmlElementsByLocalName(
    document,
    'si',
  ).map((item) => _xmlTextNodes(item).join('').trim()).toList(growable: false);
}

String _readProjectCommunicationXlsxCell(
  XmlElement cell,
  List<String> sharedStrings,
) {
  final type = cell.getAttribute('t')?.trim();
  if (type == 'inlineStr') {
    return _xmlTextNodes(cell).join('').trim();
  }
  final values = _childXmlElementsByLocalName(cell, 'v')
      .map((node) => node.innerText.trim())
      .where((text) => text.isNotEmpty)
      .toList(growable: false);
  final value = values.isEmpty ? null : values.first;
  if (value == null) {
    return '';
  }
  if (type == 's') {
    final index = int.tryParse(value);
    if (index != null && index >= 0 && index < sharedStrings.length) {
      return sharedStrings[index];
    }
  }
  return value;
}

Iterable<XmlElement> _xmlElementsByLocalName(XmlNode node, String localName) {
  return node.descendants.whereType<XmlElement>().where(
    (element) => element.name.local == localName,
  );
}

Iterable<XmlElement> _childXmlElementsByLocalName(
  XmlElement node,
  String localName,
) {
  return node.children.whereType<XmlElement>().where(
    (element) => element.name.local == localName,
  );
}

List<String> _xmlTextNodes(XmlElement element) {
  return _xmlElementsByLocalName(element, 't')
      .map((node) => node.innerText)
      .where((text) => text.trim().isNotEmpty)
      .toList(growable: false);
}

String? _normalizeProjectCommunicationPreviewText(String text) {
  final normalized = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.length <= _projectCommunicationOfficePreviewMaxChars) {
    return normalized;
  }
  return '${normalized.substring(0, _projectCommunicationOfficePreviewMaxChars)}\n\n……内容较长，已截取前半部分用于确认预览。';
}

bool _isProjectCommunicationDocx(String mimeType, String lowerName) {
  return mimeType ==
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
      lowerName.endsWith('.docx');
}

bool _isProjectCommunicationXlsx(String mimeType, String lowerName) {
  return mimeType ==
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
      lowerName.endsWith('.xlsx');
}

bool _isProjectCommunicationPptx(String mimeType, String lowerName) {
  return mimeType ==
          'application/vnd.openxmlformats-officedocument.presentationml.presentation' ||
      lowerName.endsWith('.pptx');
}
