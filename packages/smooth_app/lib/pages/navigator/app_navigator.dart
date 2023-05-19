import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/data_importer/smooth_app_data_importer.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/navigator/external_page.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_app/pages/product/product_loader_page.dart';
import 'package:smooth_app/pages/scan/search_page.dart';
import 'package:smooth_app/query/product_query.dart';

class AppNavigator extends InheritedWidget {
  AppNavigator({
    Key? key,
    required Widget child,
    List<NavigatorObserver>? observers,
  })  : _router = _SmoothGoRouter(
          observers: observers,
        ),
        super(key: key, child: child);

  // GoRouter is never accessible directly
  final _SmoothGoRouter _router;

  static AppNavigator of(BuildContext context) {
    final AppNavigator? result =
        context.dependOnInheritedWidgetOfExactType<AppNavigator>();
    assert(result != null, 'No AppNavigator found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppNavigator oldWidget) {
    return oldWidget._router != _router;
  }

  RouterConfig<Object> get router => _router.router;

  void push(String routeName, {dynamic extra}) {
    assert(routeName.isNotEmpty);
    _router.router.push(routeName, extra: extra);
  }

  void pushReplacement(String routeName, {dynamic extra}) {
    assert(routeName.isNotEmpty);
    _router.router.pushReplacement(routeName, extra: extra);
  }

  void pop([dynamic result]) {
    _router.router.pop(result);
  }
}

class _SmoothGoRouter {
  _SmoothGoRouter({
    List<NavigatorObserver>? observers,
  }) {
    router = GoRouter(
        observers: observers,
        routes: <GoRoute>[
          GoRoute(
            path: HOME_PAGE,
            builder: (BuildContext context, GoRouterState state) {
              if (!isInitialized) {
                _initAppLanguage(context);
                isInitialized = true;
              }

              return _findLastOnboardingPage(context);
            },
            // We use sub-routes to allow the back button from deep links to
            // go back to the homepage
            routes: <GoRoute>[
              GoRoute(
                path: '$PRODUCT_PAGE/:productId',
                builder: (BuildContext context, GoRouterState state) {
                  Product product;

                  if (state.extra is Product) {
                    product = state.extra! as Product;
                  } else {
                    throw Exception('No product provided!');
                  }

                  final Widget widget = ProductPage(product);

                  if (InheritedDataManager.find(context) == null) {
                    return InheritedDataManager(child: widget);
                  } else {
                    return widget;
                  }
                },
              ),
              GoRoute(
                path: '$PRODUCT_LOADER_PAGE/:productId',
                builder: (BuildContext context, GoRouterState state) {
                  final String barcode = state.pathParameters['productId']!;
                  return ProductLoaderPage(barcode: barcode);
                },
              ),
              GoRoute(
                path: SEARCH_PAGE,
                builder: (_, __) {
                  return SearchPage();
                },
              ),
              GoRoute(
                path: '$PREFERENCES_PAGE/:preferenceType',
                builder: (BuildContext context, GoRouterState state) {
                  final String? type = state.pathParameters['preferenceType'];

                  final PreferencePageType? pageType = PreferencePageType.values
                      .firstWhereOrNull(
                          (PreferencePageType e) => e.name == type);

                  if (pageType == null) {
                    throw Exception('Unsupported preference page type: $type');
                  }

                  return UserPreferencesPage(
                    type: pageType,
                  );
                },
              ),
              GoRoute(
                path: '$EXTERNAL_PAGE/:path',
                builder: (BuildContext context, GoRouterState state) {
                  return ExternalPage(path: state.pathParameters['path']!);
                },
              ),
            ],
          ),
        ],
        redirect: (BuildContext context, GoRouterState state) {
          // Ignore deep links if the onboarding is not completed
          if (state.location != HOME_PAGE && !_isOnboardingComplete(context)) {
            return HOME_PAGE;
          }

          // If a barcode is in the URL, ensure to manually fetch the product
          if (state.matchedLocation.isNotEmpty) {
            final int paths = state.matchedLocation.count('/');

            if (paths > 1) {
              final String? barcode =
                  _extractProductBarcode(state.matchedLocation);

              if (barcode != null) {
                if (state.extra is Product) {
                  return AppRoutes.PRODUCT(barcode);
                } else {
                  return AppRoutes.PRODUCT_LOADER(barcode);
                }
              }
            } else {
              // Unsupported link
              return AppRoutes.EXTERNAL(
                state.matchedLocation[0] == '/'
                    ? state.matchedLocation.substring(1)
                    : state.matchedLocation,
              );
            }
          }

          return state.location;
        });
  }

  late GoRouter router;

  // Indicates whether [_initAppLanguage] was already called
  bool isInitialized = false;

  void _initAppLanguage(BuildContext context) {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    ProductQuery.setLanguage(context, userPreferences);
    context.read<ProductPreferences>().refresh();

    // The migration requires the language to be set in the app!
    context.read<SmoothAppDataImporter>().startMigrationAsync();
  }

  /// All paths containing at least 8 digits in the second part are considered
  /// as a valid barcode
  String? _extractProductBarcode(String path) {
    if (path.isEmpty || path == HOME_PAGE) {
      return null;
    }

    final List<String> pathParams = path.split('/').sublist(1);

    if (pathParams.length > 1) {
      final String barcode = pathParams[1];

      if (int.tryParse(barcode) != null && barcode.length >= 8) {
        return barcode;
      }
    }

    return null;
  }

  bool _isOnboardingComplete(BuildContext context) {
    return _getCurrentOnboardingPage(context).isOnboardingComplete();
  }

  Widget _findLastOnboardingPage(BuildContext context) {
    return _getCurrentOnboardingPage(context).getPageWidget(context);
  }

  OnboardingPage _getCurrentOnboardingPage(BuildContext context) {
    final UserPreferences userPreferences = context.read<UserPreferences>();

    final OnboardingPage lastVisitedOnboardingPage =
        userPreferences.lastVisitedOnboardingPage;
    return lastVisitedOnboardingPage;
  }

  static const String HOME_PAGE = '/';
  static const String PRODUCT_PAGE = 'product';
  static const String PRODUCT_LOADER_PAGE = 'product_loader';
  static const String PREFERENCES_PAGE = 'preferences';
  static const String SEARCH_PAGE = 'search';
  static const String EXTERNAL_PAGE = 'external';
}

// TODO(g123k): Improve this with sealed classes
class AppRoutes {
  AppRoutes._();

  static const String HOME = _SmoothGoRouter.HOME_PAGE;

  static String PRODUCT(String barcode) =>
      '/${_SmoothGoRouter.PRODUCT_PAGE}/$barcode';

  static String PRODUCT_LOADER(String barcode) =>
      '/${_SmoothGoRouter.PRODUCT_LOADER_PAGE}/$barcode';

  static String PREFERENCES(PreferencePageType type) =>
      '/${_SmoothGoRouter.PREFERENCES_PAGE}/${type.name}';

  static const String SEARCH = '/${_SmoothGoRouter.SEARCH_PAGE}';

  static String EXTERNAL(String path) =>
      '/${_SmoothGoRouter.EXTERNAL_PAGE}/${path}';
}
