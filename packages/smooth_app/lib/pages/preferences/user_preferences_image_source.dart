import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';

class UserPreferencesImageSource extends StatelessWidget {
  const UserPreferencesImageSource();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.choose_image_source_title,
        appLocalizations.user_picture_source_ask,
        appLocalizations.settings_app_camera,
        appLocalizations.gallery_source_label,
      ],
      builder: (_) => const UserPreferencesImageSource(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return UserPreferencesMultipleChoicesItem<UserPictureSource>(
      title: appLocalizations.choose_image_source_title,
      leadingBuilder: <WidgetBuilder>[
        (_) => const Icon(Icons.edit_note_rounded),
        (_) => const Icon(Icons.camera),
        (_) => const Icon(Icons.image),
      ],
      labels: <String>[
        appLocalizations.user_picture_source_ask,
        appLocalizations.settings_app_camera,
        appLocalizations.gallery_source_label,
      ],
      values: const <UserPictureSource>[
        UserPictureSource.SELECT,
        UserPictureSource.CAMERA,
        UserPictureSource.GALLERY,
      ],
      currentValue: userPreferences.userPictureSource,
      onChanged: (final UserPictureSource? newValue) async =>
          userPreferences.setUserPictureSource(newValue!),
    );
  }
}
