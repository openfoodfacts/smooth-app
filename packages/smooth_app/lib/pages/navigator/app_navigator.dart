import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/pages/navigator/error_page.dart';
import 'package:smooth_app/pages/navigator/external_page.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_app/pages/product/product_loader_page.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/pages/search/search_product_helper.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
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
    super.key,
    List<NavigatorObserver>? observers,
    required super.child,
  }) : _router = _SmoothGoRouter(
          observers: observers,
        );

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

  Future<T?> push<T extends Object?>(String routeName, {dynamic extra}) async {
    assert(routeName.isNotEmpty);
    return _router.router.push(routeName, extra: extra);
  }

  void pushReplacement(String routeName, {dynamic extra}) {
    assert(routeName.isNotEmpty);
    _router.router.pushReplacement(routeName, extra: extra);
  }

  /// Remove all the screens from the stack
  void clearStack() {
    while (_router.router.canPop() == true) {
      _router.router.pop();
    }
  }

  /// Returns [true] if the pop was successful
  /// Returns [false] if there is nothing to pop (= no history)
  bool pop([dynamic result]) {
    try {
      _router.router.pop(result);
      return true;
    } on GoError catch (_) {
      return false;
    }
  }
}

/// Our router have the following routes:
/// - /                       Homepage
/// -   _product              Product details
/// -   _product_loader       Product loader (if not in the db)
/// -   _product_creator      Create a new product
/// -   _preferences          User preferences
/// -   _search               Search for a product
/// -   _guides/              List of guides
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
            if (!_appLanguageInitialized) {
              _initAppLanguage(context);
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
                } else if (state.extra is Map<String, dynamic>) {
                  product = Product.fromJson(
                    state.extra! as Map<String, dynamic>,
                  );
                } else {
                  throw Exception('No product provided!');
                }

                final Widget widget = ProductPage(
                  product,
                  withHeroAnimation:
                      state.uri.queryParameters['heroAnimation'] != 'false',
                  heroTag: state.uri.queryParameters['heroTag'],
                );

                if (ExternalScanCarouselManager.find(context) == null) {
                  return ExternalScanCarouselManager(child: widget);
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
                  mode: state.uri.queryParameters['edit'] == 'true'
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
              path: _InternalAppRoutes.SEARCH_PAGE,
              builder: (_, GoRouterState state) {
                if (state.extra != null) {
                  return SearchPage.fromExtra(state.extra! as SearchPageExtra);
                } else {
                  return SearchPage(SearchProductHelper());
                }
              },
            ),
            GoRoute(
              path: _InternalAppRoutes._GUIDES,
              routes: <GoRoute>[
                GoRoute(
                  path: _InternalAppRoutes.GUIDE_NUTRISCORE_V2_PAGE,
                  builder: (_, __) => const GuideNutriscoreV2(),
                ),
              ],
              redirect: (_, GoRouterState state) {
                if (state.uri.pathSegments.last !=
                    _InternalAppRoutes.GUIDE_NUTRISCORE_V2_PAGE) {
                  return AppRoutes.EXTERNAL(state.path ?? '');
                } else {
                  return null;
                }
              },
            ),
            GoRoute(
              path: _InternalAppRoutes.SIGNUP_PAGE,
              builder: (_, __) => const SignUpPage(),
            )
          ],
        ),
        GoRoute(
          path: '/${_InternalAppRoutes.EXTERNAL_PAGE}',
          builder: (BuildContext context, GoRouterState state) {
            return ExternalPage(
              path: Uri.decodeFull(state.uri.queryParameters['path']!),
            );
          },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final String path = state.matchedLocation;

        // Ignore deep links if the onboarding is not yet completed
        if (state.uri.toString() != _InternalAppRoutes.HOME_PAGE &&
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
              final String? barcode = state.uri.queryParameters['code'];

              if (barcode != null &&
                  state.uri.queryParameters['type'] == 'edit') {
                return AppRoutes.PRODUCT_LOADER(barcode, edit: true);
              } else {
                externalLink = true;
              }
            } else {
              externalLink = true;
            }
          } else if (path == _ExternalRoutes.MOBILE_APP_DOWNLOAD) {
            return AppRoutes.HOME();
          } else if (path == _ExternalRoutes.GUIDE_NUTRISCORE_V2) {
            return AppRoutes.GUIDE_NUTRISCORE_V2;
          } else if (path == _ExternalRoutes.SIGNUP) {
            return AppRoutes.SIGNUP;
          } else if (path != _InternalAppRoutes.HOME_PAGE) {
            externalLink = true;
          }
        }

        if (externalLink) {
          return _openExternalLink(path);
        } else if (path.isEmpty) {
          // Force the Homepage
          return _InternalAppRoutes.HOME_PAGE;
        } else {
          return state.uri.toString();
        }
      },
      errorBuilder: (_, GoRouterState state) => ErrorPage(
        url: state.uri.toString(),
      ),
    );
  }

  bool _appLanguageInitialized = false;

  /// Required to setup the whole app
  Future<void> _initAppLanguage(BuildContext context) {
    // Must be set first to ensure the method is only called once
    _appLanguageInitialized = true;
    ProductQuery.setLanguage(context, context.read<UserPreferences>());
    context.read<AppNewsProvider>().loadLatestNews();
    return context.read<ProductPreferences>().refresh();
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
  static const String SIGNUP_PAGE = '_signup';

  static const String _GUIDES = '_guides';
  static const String GUIDE_NUTRISCORE_V2_PAGE = '_nutriscore-v2';
}

class _ExternalRoutes {
  static const String MOBILE_APP_DOWNLOAD = '/open-food-facts-mobile-app';
  static const String PRODUCT_EDITION = '/cgi/product.pl';
  static const String GUIDE_NUTRISCORE_V2 = '/nutriscore-v2';
  static const String SIGNUP = '/signup';
}

/// A list of internal routes to use with [AppNavigator]
// TODO(g123k): Improve this with sealed classes (Dart 3 is required)
// ignore_for_file: non_constant_identifier_names
class AppRoutes {
  AppRoutes._();

  // Home page (or walkthrough during the onboarding)
  static String HOME({bool redraw = false}) =>
      '${_InternalAppRoutes.HOME_PAGE}?redraw:$redraw';

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

  // Guide for NutriScore (TODO: If we have more guides, we should use a more generic algorithm)
  static String get GUIDE_NUTRISCORE_V2 =>
      '/${_InternalAppRoutes._GUIDES}/${_InternalAppRoutes.GUIDE_NUTRISCORE_V2_PAGE}';

  static String get SIGNUP => '/${_InternalAppRoutes.SIGNUP_PAGE}';

  // Open an external link (where path is relative to the OFF website)
  static String EXTERNAL(String path) =>
      '/${_InternalAppRoutes.EXTERNAL_PAGE}?path=${Uri.encodeFull(path)}';
}
