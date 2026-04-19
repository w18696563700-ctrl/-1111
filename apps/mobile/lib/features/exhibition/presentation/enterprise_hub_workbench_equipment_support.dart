part of 'enterprise_hub_workbench_pages.dart';

class _FactoryEquipmentEntry {
  _FactoryEquipmentEntry({String name = '', String quantity = ''})
    : nameController = TextEditingController(text: name),
      quantityController = TextEditingController(text: quantity);

  factory _FactoryEquipmentEntry.fromStorage(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return _FactoryEquipmentEntry();
    }
    final separator = normalized.contains('×')
        ? '×'
        : (normalized.contains(' x ') ? ' x ' : null);
    if (separator == null) {
      return _FactoryEquipmentEntry(name: normalized);
    }
    final parts = normalized.split(separator);
    if (parts.length < 2) {
      return _FactoryEquipmentEntry(name: normalized);
    }
    return _FactoryEquipmentEntry(
      name: parts.first.trim(),
      quantity: parts.sublist(1).join(separator).trim(),
    );
  }

  final TextEditingController nameController;
  final TextEditingController quantityController;

  bool get hasValue =>
      nameController.text.trim().isNotEmpty ||
      quantityController.text.trim().isNotEmpty;

  String? toStorageValue() {
    final name = nameController.text.trim();
    final quantity = quantityController.text.trim();
    if (name.isEmpty && quantity.isEmpty) {
      return null;
    }
    if (quantity.isEmpty) {
      return name;
    }
    if (name.isEmpty) {
      return quantity;
    }
    return '$name × $quantity';
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}
