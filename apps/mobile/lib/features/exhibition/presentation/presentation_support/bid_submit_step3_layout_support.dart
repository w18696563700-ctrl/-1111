part of '../exhibition_trade_pages.dart';

const double _bidSubmitAttachmentWideLayoutBreakpoint = 720;
const double _bidSubmitAttachmentGridSpacing = 12;
const double _bidSubmitAttachmentCardHeight = 312;
const double _bidSubmitTemplateCardHeight = 156;

List<List<T>> _chunkBidSubmitRows<T>(List<T> items, int columns) {
  final rows = <List<T>>[];
  for (int index = 0; index < items.length; index += columns) {
    final end = math.min(index + columns, items.length);
    rows.add(items.sublist(index, end));
  }
  return rows;
}
