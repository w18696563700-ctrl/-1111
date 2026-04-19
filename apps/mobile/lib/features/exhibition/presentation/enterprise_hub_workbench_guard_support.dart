part of 'enterprise_hub_workbench_pages.dart';

class _GuardAction extends StatelessWidget {
  const _GuardAction({required this.actionLabel, required this.routeName});

  final String actionLabel;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.of(context).pushNamed(routeName),
      child: Text(actionLabel),
    );
  }
}
