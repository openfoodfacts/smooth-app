import 'package:flutter/material.dart';

/// Standard info tile about "owner fields".
class OwnerFieldInfo extends StatelessWidget {
  const OwnerFieldInfo({super.key});

  /// Icon to display when the product field value is "producer provided".
  static const IconData ownerFieldIconData = Icons.factory;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color? darkGrey = Colors.grey[700];
    final Color? lightGrey = Colors.grey[300];
    return ListTile(
      tileColor: dark ? darkGrey : lightGrey,
      leading: const Icon(ownerFieldIconData),
      // TODO(monsieurtanuki): localize
      title: const Text('Producer provided values'),
      subtitle: const Text(
          'With that logo we highlight data provided by the producer, and that may not be editable.'),
    );
  }
}
