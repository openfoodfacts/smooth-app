import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/data_importer/smooth_app_data_importer.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/pages/carousel_manager.dart';
import 'package:smooth_app/pages/navigator/error_page.dart';
import 'package:smooth_app/pages/navigator/external_page.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_app/pages/product/product_loader_page.dart';
import 'package:smooth_app/pages/scan/search_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// A replacement for the [Navigator], where we internally use [GoRouter].
/// By itself the [GoRouter] attribute is not accessible, to allow us to easily
/// swap the solution if required
///
/// Three methods are available:
/// - Push: to open a new screen
/// - PushReplacement: to replace the current screen by a new one
/// - Pop: to close the current screen
///
/// Each screen is available in [AppRoutes].
///
/// /!\ [GoRouter] doesn't support [maybePop] or returning a result from a push.
class AppNavigator extends InheritedWidget {
  AppNavigator({
    Key? key,
    List<NavigatorObserver>? observers,
    required Widget child,
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

  // Router to use with a [WidgetsApp]
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

/// Our router have the following routes:
/// - /                       Homepage
/// -   _product              Product details
/// -   _product_loader       Product loader (if not in the db)
/// -   _product_creator      Create a new product
/// -   _preferences          User preferences
/// -   _search               Search for a product
/// -   _external             Open an external link on the OFF website
///
/// All our routes are prefixed with an underscore, as the [redirect] method
/// is also called with non prefixed paths for deep links.
///
/// One drawback of the implementation is that we never know the base URL of the
/// deep link (eg: es.openfoodfacts.org)
class _SmoothGoRouter {
  factory _SmoothGoRouter({
    List<NavigatorObserver>? observers,
  }) {
    _singleton ??= _SmoothGoRouter._internal(
      observers: observers,
    );

    return _singleton!;
  }

  _SmoothGoRouter._internal({
    List<NavigatorObserver>? observers,
  }) {
    router = GoRouter(
      observers: observers,
      routes: <GoRoute>[
        GoRoute(
          path: _InternalAppRoutes.HOME_PAGE,
          builder: (BuildContext context, GoRouterState state) {
            if (!isInitialized) {
              _initAppLanguage(context);
              isInitialized = true;
            }

            return _findLastOnboardingPage(context);
          },
          // We use sub-routes to allow the back button to work correctly
          // for deep links to go back to the homepage
          routes: <GoRoute>[
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_DETAILS_PAGE}/:productId',
              builder: (BuildContext context, GoRouterState state) {
                Product product;

                if (state.extra is Product) {
                  product = state.extra! as Product;
                } else {
                  throw Exception('No product provided!');
                }

                final Widget widget = ProductPage(
                  product,
                  withHeroAnimation:
                      state.queryParameters['heroAnimation'] != 'false',
                  heroTag: state.queryParameters['heroTag'],
                );

                if (ExternalCarouselManager.find(context) == null) {
                  return ExternalCarouselManager(child: widget);
                } else {
                  return widget;
                }
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_EDITOR_PAGE}/:productId',
              builder: (BuildContext context, GoRouterState state) {
                Product product;

                if (state.extra is Product) {
                  product = state.extra! as Product;
                } else {
                  throw Exception('No product provided!');
                }

                return EditProductPage(product);
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_LOADER_PAGE}/:productId',
              builder: (BuildContext context, GoRouterState state) {
                final String barcode = state.pathParameters['productId']!;
                return ProductLoaderPage(
                  barcode: barcode,
                  mode: state.queryParameters['edit'] == 'true'
                      ? ProductLoaderMode.editProduct
                      : ProductLoaderMode.viewProduct,
                );
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PRODUCT_CREATOR_PAGE}/:productId',
              builder: (BuildContext context, GoRouterState state) {
                final String barcode = state.pathParameters['productId']!;
                return AddNewProductPage.fromBarcode(barcode);
              },
            ),
            GoRoute(
              path: _InternalAppRoutes.SEARCH_PAGE,
              builder: (_, __) {
                return SearchPage();
              },
            ),
            GoRoute(
              path: '${_InternalAppRoutes.PREFERENCES_PAGE}/:preferenceType',
              builder: (BuildContext context, GoRouterState state) {
                final String? type = state.pathParameters['preferenceType'];

                final PreferencePageType? pageType = PreferencePageType.values
                    .firstWhereOrNull((PreferencePageType e) => e.name == type);

                if (pageType == null) {
                  throw Exception('Unsupported preference page type: $type');
                }

                return UserPreferencesPage(
                  type: pageType,
                );
              },
            ),
            GoRoute(
              path: _InternalAppRoutes.EXTERNAL_PAGE,
              builder: (BuildContext context, GoRouterState state) {
                return ExternalPage(path: state.queryParameters['path']!);
              },
            ),
          ],
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final String path = state.matchedLocation;

        // Ignore deep links if the onboarding is not yet completed
        if (state.location != _InternalAppRoutes.HOME_PAGE &&
            !_isOnboardingComplete(context)) {
          return _InternalAppRoutes.HOME_PAGE;
        } else if (_isAnInternalRoute(path)) {
          return null;
        }

        bool externalLink = false;

        // If a barcode is in the URL, ensure to manually fetch the product
        if (path.isNotEmpty) {
          final int subPaths = path.count('/');

          if (subPaths > 1) {
            final String? barcode = _extractProductBarcode(path);

            if (barcode != null) {
              AnalyticsHelper.trackEvent(
                AnalyticsEvent.productDeepLink,
                barcode: barcode,
              );

              if (state.extra is Product) {
                return AppRoutes.PRODUCT(barcode, useHeroAnimation: false);
              } else {
                return AppRoutes.PRODUCT_LOADER(barcode);
              }
            } else if (path == _ExternalRoutes.PRODUCT_EDITION) {
              // Support cgi/product.pl?type=edit&code=XXXX
              final String? barcode = state.queryParameters['code'];

              if (barcode != null && state.queryParameters['type'] == 'edit') {
                return AppRoutes.PRODUCT_LOADER(barcode, edit: true);
              } else {
                externalLink = true;
              }
            } else {
              externalLink = true;
            }
          } else if (path == _ExternalRoutes.MOBILE_APP_DOWNLOAD) {
            return AppRoutes.HOME;
          } else if (path != _InternalAppRoutes.HOME_PAGE) {
            externalLink = true;
          }
        }

        if (externalLink) {
          return _openExternalLink(path);
        } else {
          return state.location;
        }
      },
      errorBuilder: (_, GoRouterState state) => ErrorPage(
        url: state.location,
      ),
    );
  }

  String _openExternalLink(String path) {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.genericDeepLink,
    );

    // Unsupported link -> open the browser
    return AppRoutes.EXTERNAL(
      path[0] == '/' ? path.substring(1) : path,
    );
  }

  static _SmoothGoRouter? _singleton;
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

  /// Extract the barcode from a path only if the route have at least 8 digits
  /// in the second part (we don't care about extra elements)
  /// Some examples:
  /// - produit/156164894948
  /// - product/3017620422003/nutella-ferrero
  String? _extractProductBarcode(String path) {
    if (path.isEmpty) {
      return null;
    }

    final List<String> pathParams = path.split('/').sublist(1);

    if (pathParams.length > 1) {
      final String barcode = pathParams[1];

      // Ensure we only have digits and at least 8 characters
      if (int.tryParse(barcode) != null && barcode.length >= 8) {
        return barcode;
      }
    }

    return null;
  }

  bool _isAnInternalRoute(String path) {
    if (path == _InternalAppRoutes.HOME_PAGE) {
      return true;
    } else {
      return path.startsWith('/_');
    }
  }

  //region Onboarding

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

//endregion Onboarding
}

/// Internal routes
/// To differentiate external routes (eg: /product/12345678), we prefix all
/// internal routes with an underscore
class _InternalAppRoutes {
  static const String HOME_PAGE = '/';
  static const String PRODUCT_DETAILS_PAGE = '_product';
  static const String PRODUCT_LOADER_PAGE = '_product_loader';
  static const String PRODUCT_CREATOR_PAGE = '_product_creator';
  static const String PRODUCT_EDITOR_PAGE = '_product_editor';
  static const String PREFERENCES_PAGE = '_preferences';
  static const String SEARCH_PAGE = '_search';
  static const String EXTERNAL_PAGE = '_external';
}

class _ExternalRoutes {
  static const String MOBILE_APP_DOWNLOAD = '/open-food-facts-mobile-app';
  static const String PRODUCT_EDITION = '/cgi/product.pl';
}

/// A list of internal routes to use with [AppNavigator]
// TODO(g123k): Improve this with sealed classes (Dart 3 is required)
// ignore_for_file: non_constant_identifier_names
class AppRoutes {
  AppRoutes._();

  // Home page (or walkthrough during the onboarding)
  static String get HOME => _InternalAppRoutes.HOME_PAGE;

  // Product details (a [Product] is mandatory in the extra)
  static String PRODUCT(
    String barcode, {
    bool useHeroAnimation = true,
    String? heroTag = '',
  }) =>
      '/${_InternalAppRoutes.PRODUCT_DETAILS_PAGE}/$barcode'
      '?heroAnimation=$useHeroAnimation'
      '&heroTag=$heroTag';

  // Product loader (= when a product is not in the database) - typical use case: deep links
  static String PRODUCT_LOADER(String barcode, {bool edit = false}) =>
      '/${_InternalAppRoutes.PRODUCT_LOADER_PAGE}/$barcode?edit=$edit';

  // Product creator or "add product" feature
  static String PRODUCT_CREATOR(String barcode) =>
      '/${_InternalAppRoutes.PRODUCT_CREATOR_PAGE}/$barcode';

  // Product creator or "add product" feature
  static String PRODUCT_EDITOR(String barcode) =>
      '/${_InternalAppRoutes.PRODUCT_EDITOR_PAGE}/$barcode';

  // App preferences
  static String PREFERENCES(PreferencePageType type) =>
      '/${_InternalAppRoutes.PREFERENCES_PAGE}/${type.name}';

  // Search view
  static String get SEARCH => '/${_InternalAppRoutes.SEARCH_PAGE}';

  // Open an external link (where path is relative to the OFF website)
  static String EXTERNAL(String path) =>
      '/${_InternalAppRoutes.EXTERNAL_PAGE}/?path=$path';
}
