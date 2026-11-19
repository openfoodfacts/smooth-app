import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Replaces [AppLocalizations.localizationsDelegates]: the generated list still
/// uses the deprecated `flutter_localizations` Material and Cupertino
/// delegates, which do not provide the `material_ui` / `cupertino_ui`
/// localizations the widgets look up (non-English locales then fail).
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
