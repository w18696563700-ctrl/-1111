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
    this.enabled = true,
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
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: fieldKey,
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        key: inputKey,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          errorMaxLines: 2,
          prefixText: required ? '* ' : null,
          prefixStyle: required
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                )
              : null,
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
          contentPadding: contentPadding,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}
