part of 'enterprise_hub_workbench_pages.dart';

class _SupplierModuleEntryData {
  const _SupplierModuleEntryData({
    required this.module,
    required this.icon,
    required this.title,
    required this.description,
    required this.complete,
  });

  final _SupplierWorkbenchModule module;
  final IconData icon;
  final String title;
  final String description;
  final bool complete;
}

class _SupplierHomepageImage extends StatelessWidget {
  const _SupplierHomepageImage({
    required this.imageUrl,
    required this.fallback,
  });

  final String? imageUrl;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 128,
      height: 128,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: imageUrl == null
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    fallback,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: const Center(child: Icon(Icons.storefront_rounded)),
                ),
              ),
      ),
    );
  }
}

class _SupplierHomepagePill extends StatelessWidget {
  const _SupplierHomepagePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}

class _SupplierCompletionBadge extends StatelessWidget {
  const _SupplierCompletionBadge({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: complete
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          complete ? '已完成' : '待完善',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _SupplierPreviewLine extends StatelessWidget {
  const _SupplierPreviewLine({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
