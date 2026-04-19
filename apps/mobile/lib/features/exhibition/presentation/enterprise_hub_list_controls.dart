import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_board_surface.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_filter_options.dart';

class EnterpriseBoardListActionController {
  VoidCallback? onSearchPressed;

  void triggerSearch() {
    onSearchPressed?.call();
  }
}

class EnterpriseSelectOption<T> {
  const EnterpriseSelectOption({required this.label, required this.value});

  final String label;
  final T value;
}

class EnterprisePopupFilterButton<T> extends StatelessWidget {
  const EnterprisePopupFilterButton({
    super.key,
    required this.label,
    this.valueLabel,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String? valueLabel;
  final List<EnterpriseSelectOption<T>> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final displayText = valueLabel?.trim().isNotEmpty == true
        ? valueLabel!.trim()
        : label;
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<T>(
      tooltip: '',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return options
            .map(
              (EnterpriseSelectOption<T> option) => PopupMenuItem<T>(
                value: option.value,
                child: Text(option.label),
              ),
            )
            .toList(growable: false);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(displayText),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class EnterpriseActionFilterButton extends StatelessWidget {
  const EnterpriseActionFilterButton({
    super.key,
    required this.label,
    this.valueLabel,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final String? valueLabel;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final displayText = valueLabel?.trim().isNotEmpty == true
        ? valueLabel!.trim()
        : label;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.72);

    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.surface
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                displayText,
                style: TextStyle(color: foregroundColor),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: foregroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnterpriseInlineSearchField extends StatelessWidget {
  const EnterpriseInlineSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSubmitted,
    required this.onClear,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        suffixIcon: SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                onPressed: onSubmitted,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              IconButton(
                onPressed: controller.text.trim().isEmpty ? onClose : onClear,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnterpriseListMessageCard extends StatelessWidget {
  const EnterpriseListMessageCard({
    super.key,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final String? actionLabel;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onPressed != null) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: onPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EnterpriseListToolbarCard extends StatelessWidget {
  const EnterpriseListToolbarCard({
    super.key,
    required this.searchFieldVisible,
    required this.searchField,
    required this.filterButtons,
    this.toolbarNoticeText,
    required this.resultSummaryText,
  });

  final bool searchFieldVisible;
  final Widget searchField;
  final List<Widget> filterButtons;
  final String? toolbarNoticeText;
  final String resultSummaryText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: searchFieldVisible
                  ? Padding(
                      key: const ValueKey<String>('search-field'),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: searchField,
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('search-hidden'),
                    ),
            ),
            Wrap(spacing: 8, runSpacing: 8, children: filterButtons),
            if (toolbarNoticeText?.trim().isNotEmpty == true) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                toolbarNoticeText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              resultSummaryText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> buildEnterpriseBoardFilterButtons({
  required EnterpriseBoardType boardType,
  required EnterpriseBoardSurfaceSpec surfaceSpec,
  required String? selectedCityLabel,
  required String? selectedAreaLabel,
  required bool cityFilterEnabled,
  required VoidCallback onCityPressed,
  required ValueChanged<String> onAreaSelected,
}) {
  final buttons = <Widget>[
    EnterpriseActionFilterButton(
      label: surfaceSpec.cityFilterLabel,
      valueLabel: selectedCityLabel,
      enabled: cityFilterEnabled,
      onPressed: onCityPressed,
    ),
  ];

  if (boardType == EnterpriseBoardType.factory) {
    buttons.add(
      EnterprisePopupFilterButton<String>(
        label: surfaceSpec.plantAreaLabel ?? '厂房面积',
        valueLabel: selectedAreaLabel,
        options: <EnterpriseSelectOption<String>>[
          const EnterpriseSelectOption<String>(label: '全部', value: ''),
          ...enterpriseHubFactoryAreaOptions.map(
            (EnterpriseBoardFilterOption option) =>
                EnterpriseSelectOption<String>(
                  label: option.label,
                  value: option.value,
                ),
          ),
        ],
        onSelected: onAreaSelected,
      ),
    );
  }

  return buttons;
}
