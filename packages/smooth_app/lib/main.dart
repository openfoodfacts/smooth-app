import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sentry/sentry.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

import 'package:smooth_app/pages/alternative_continuous_scan_page.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/contribution_page.dart';
import 'package:smooth_app/pages/continuous_scan_page.dart';
import 'package:smooth_app/pages/profile_page.dart';
import 'package:smooth_app/pages/tracking_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_action_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_layout_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_screen_model.dart';
import 'package:smooth_ui_library/navigation/smooth_navigation_layout.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';

Future<void> main() async {
  await Sentry.init(
    (dynamic options) {
      options.dsn =
          'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
    },
  );
  try {
    runApp(MyApp());
  } catch (exception, stackTrace) {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserPreferences _userPreferences;
  UserPreferencesModel _userPreferencesModel;
  LocalDatabase _localDatabase;
  final DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  Future<void> _init(BuildContext context) async {
    _userPreferences = await UserPreferences.getUserPreferences();
    _userPreferencesModel = await UserPreferencesModel.getUserPreferencesModel(
        DefaultAssetBundle.of(context));
    await _userPreferences.init(_userPreferencesModel);
    _localDatabase = await LocalDatabase.getLocalDatabase();
    themeChangeProvider.darkTheme =
        await themeChangeProvider.userThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: <ChangeNotifierProvider<dynamic>>[
              ChangeNotifierProvider<UserPreferences>.value(
                  value: _userPreferences),
              ChangeNotifierProvider<UserPreferencesModel>.value(
                  value: _userPreferencesModel),
              ChangeNotifierProvider<LocalDatabase>.value(
                  value: _localDatabase),
              ChangeNotifierProvider<DarkThemeProvider>.value(
                  value: themeChangeProvider),
            ],
            child: Consumer<DarkThemeProvider>(
              builder: (
                BuildContext context,
                DarkThemeProvider value,
                Widget child,
              ) {
                return MaterialApp(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: SmoothThemes.getSmoothThemeData(
                      themeChangeProvider.darkTheme, context),
                  home: SmoothAppGetLanguage(),
                );
              },
            ),
          );
        }
        return Container(); // as simple as possible
      },
    );
  }
}

/// Layer needed because we need to know the language
class SmoothAppGetLanguage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final Locale myLocale = Localizations.localeOf(context);
    final String languageCode = myLocale.languageCode;
    userPreferencesModel.refresh(DefaultAssetBundle.of(context), languageCode);
    return SmoothApp();
  }
}

class SmoothApp extends StatelessWidget {
  static const double _navigationIconSize = 32.0;
  static const double _navigationIconPadding = 5.0;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final bool mlKitState = userPreferences.getMlKitState();
    return SmoothNavigationLayout(
      layout: SmoothNavigationLayoutModel(
        screens: <SmoothNavigationScreenModel>[
          _generateScreenModel(
            context,
            mlKitState,
            'assets/ikonate_thin/search.svg',
            'Choose',
            ChoosePage(),
          ),
          /*
          _generateScreenModel(
            context,
            mlKitState,
            'assets/ikonate_thin/organize.svg',
            'Organize',
            OrganizationPage(),
          ),
           */
          _generateScreenModel(
            context,
            mlKitState,
            'assets/ikonate_thin/add.svg',
            'Contribute',
            CollaborationPage(),
          ),
          _generateScreenModel(
            context,
            mlKitState,
            'assets/ikonate_thin/activity.svg',
            'Track',
            TrackingPage(),
          ),
          _generateScreenModel(
            context,
            mlKitState,
            'assets/ikonate_thin/person.svg',
            'Profile',
            ProfilePage(),
          ),
        ],
      ),
      animationDuration: 300,
      animationCurve: Curves.easeInOutBack,
      borderRadius: 20.0,
      color: Theme.of(context).bottomAppBarColor,
      scanButtonColor: Theme.of(context).accentColor,
      scanShadowColor: context.watch<DarkThemeProvider>().darkTheme
          ? Colors.white.withOpacity(0.0)
          : Colors.deepPurple,
      scanIconColor: Theme.of(context).accentIconTheme.color,
      classicMode: true,
    );
  }

  SmoothNavigationScreenModel _generateScreenModel(
    final BuildContext context,
    final bool mlKitState,
    final String svg,
    final String title,
    final Widget page,
  ) =>
      SmoothNavigationScreenModel(
        icon: Container(
          padding: const EdgeInsets.all(_navigationIconPadding),
          child: SvgPicture.asset(
            svg,
            width: _navigationIconSize,
            height: _navigationIconSize,
            color: Theme.of(context).accentColor,
          ),
        ),
        title: title,
        page: page,
        action: SmoothNavigationActionModel(
          title: AppLocalizations.of(context).scanProductTitle,
          icon: 'assets/actions/scanner_alt_2.svg',
          iconPadding: _navigationIconPadding,
          iconSize: _navigationIconSize,
          onTap: () {
            final Widget newPage = mlKitState
                ? const ContinuousScanPage()
                : const AlternativeContinuousScanPage();
            Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => newPage),
            );
          },
        ),
      );
}
