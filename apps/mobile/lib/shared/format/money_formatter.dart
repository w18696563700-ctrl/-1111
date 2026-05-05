class MoneyFormatter {
  const MoneyFormatter._();

  static String yuan(
    num? amount, {
    String currency = 'CNY',
    String emptyLabel = '待确认',
    String unavailableLabel = '不可用',
    bool unavailable = false,
    bool hidden = false,
    String hiddenLabel = '金额已隐藏',
  }) {
    if (hidden) {
      return hiddenLabel;
    }
    if (unavailable) {
      return unavailableLabel;
    }
    if (amount == null) {
      return emptyLabel;
    }
    return _formatMajorAmount(amount, currency: currency);
  }

  static String cents(
    int? amountInCents, {
    String currency = 'CNY',
    String emptyLabel = '待确认',
    String unavailableLabel = '不可用',
    bool unavailable = false,
    bool hidden = false,
    String hiddenLabel = '金额已隐藏',
  }) {
    if (amountInCents == null) {
      return yuan(
        null,
        currency: currency,
        emptyLabel: emptyLabel,
        unavailableLabel: unavailableLabel,
        unavailable: unavailable,
        hidden: hidden,
        hiddenLabel: hiddenLabel,
      );
    }
    return yuan(
      amountInCents / 100,
      currency: currency,
      emptyLabel: emptyLabel,
      unavailableLabel: unavailableLabel,
      unavailable: unavailable,
      hidden: hidden,
      hiddenLabel: hiddenLabel,
    );
  }

  static String _formatMajorAmount(num amount, {required String currency}) {
    final normalizedCurrency = currency.trim().toUpperCase();
    final value = _trimmedFixed(amount);
    if (normalizedCurrency.isEmpty || normalizedCurrency == 'CNY') {
      return '¥$value';
    }
    return '$normalizedCurrency $value';
  }

  static String _trimmedFixed(num amount) {
    final fixed = amount.toStringAsFixed(2);
    if (!fixed.contains('.')) {
      return fixed;
    }
    final trimmed = fixed.replaceFirst(RegExp(r'0+$'), '');
    return trimmed.endsWith('.')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
