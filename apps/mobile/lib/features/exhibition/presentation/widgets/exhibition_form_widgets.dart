part of '../exhibition_trade_pages.dart';

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    this.fieldKey,
    this.inputKey,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    this.helperText,
    this.suffixText,
    this.suffixIcon,
    this.errorText,
    this.required = false,
    this.readOnly = false,
    this.contentPadding,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final Key? fieldKey;
  final Key? inputKey;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final String? helperText;
  final String? suffixText;
  final Widget? suffixIcon;
  final String? errorText;
  final bool required;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(18);
    final enabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: colorScheme.error),
    );
    return Padding(
      key: fieldKey,
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        key: inputKey,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          errorMaxLines: 2,
          helperMaxLines: 2,
          prefixText: required ? '* ' : null,
          prefixStyle: required
              ? theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                )
              : null,
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: colorScheme.surface,
          border: enabledBorder,
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          disabledBorder: enabledBorder,
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}
