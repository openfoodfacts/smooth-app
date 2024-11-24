import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/widgets/smooth_banner.dart';

/// Icon to display when the product field value is "producer provided".
const IconData _ownerFieldIconData = Icons.factory;

/// Standard info tile about "owner fields".
class OwnerFieldInfo extends StatelessWidget {
  const OwnerFieldInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color? darkGrey = Colors.grey[700];
    final Color? lightGrey = Colors.grey[300];
    return ListTile(
      tileColor: dark ? darkGrey : lightGrey,
      leading: const Icon(_ownerFieldIconData),
      title: Text(appLocalizations.owner_field_info_title),
      subtitle: Text(appLocalizations.owner_field_info_message),
    );
  }
}

class OwnerFieldBanner extends StatelessWidget {
  const OwnerFieldBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothBanner(
      icon: const OwnerFieldIcon(),
      title: appLocalizations.owner_field_info_title,
      content: appLocalizations.owner_field_info_message,
    );
  }
}

/// Standard icon about "owner fields".
class OwnerFieldIcon extends StatelessWidget {
  const OwnerFieldIcon();

  @override
  Widget build(BuildContext context) => Semantics(
        label: AppLocalizations.of(context).owner_field_info_title,
        child: const Icon(_ownerFieldIconData),
      );
}
