import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

///UI for boost item cards in the beginning of the game

class BoostOptionTile extends StatelessWidget {
  const BoostOptionTile({
    required this.title,
    required this.description,
    required this.quantity,
    required this.selected,
    required this.onTap,
    required this.enabled,
    super.key,
  });
  final String title;
  final String description;
  final int quantity;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(

      color: selected ? Colors.indigo.shade50 : theme.cardColor,
      elevation: selected ? 3 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: enabled ? onTap : null,
        leading: Checkbox(value: selected, onChanged: enabled ? (_) => onTap() : null, activeColor: Colors.indigo),
        title: Text('$title (${tr('boost.quantity', namedArgs: {'value': '$quantity'})})', style: theme.textTheme.bodyLarge),

        subtitle: Text(description, style: theme.textTheme.bodySmall),
      ),
    );
  }
}
