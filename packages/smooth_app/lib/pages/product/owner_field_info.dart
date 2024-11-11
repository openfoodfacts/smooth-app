import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Standard info tile about "owner fields".
class OwnerFieldInfo extends StatelessWidget {
  const OwnerFieldInfo({super.key});

  /// Icon to display when the product field value is "producer provided".
  static const IconData ownerFieldIconData = Icons.factory;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color? darkGrey = Colors.grey[700];
    final Color? lightGrey = Colors.grey[300];
    return ListTile(
      tileColor: dark ? darkGrey : lightGrey,
      leading: const Icon(ownerFieldIconData),
      title: Text(appLocalizations.owner_field_info_title),
      subtitle: Text(appLocalizations.owner_field_info_message),
    );
  }
}
