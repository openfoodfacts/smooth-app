import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_controller.dart';
import 'package:smooth_app/pages/food_preferences/models/pending_preferences.dart';
import 'package:smooth_app/pages/food_preferences/pages/introduction_page.dart';
import 'package:smooth_app/pages/food_preferences/pages/summary_page.dart';
import 'package:smooth_app/pages/food_preferences/widgets/attribute_group_page.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preferences_navigation_bar.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

enum PreferencesPageProjects {
  food,
  products,
  beauty,
  pets;

  UriProductHelper getUriProductHelper() {
    switch (this) {
      case PreferencesPageProjects.food:
        return uriHelperFoodProd;
      case PreferencesPageProjects.products:
        return uriHelperProductsProd;
      case PreferencesPageProjects.beauty:
        return uriHelperBeautyProd;
      case PreferencesPageProjects.pets:
        return uriHelperPetFoodProd;
    }
  }

  Future<List<AttributeGroup>?> fetchAttributeGroups() async {
    try {
      final String languageCode = ProductQuery.getLanguage().code;
      final Uri uri = AvailableAttributeGroups.getUri(
        languageCode,
        uriHelper: getUriProductHelper(),
      );

      final http.Response response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final AvailableAttributeGroups availableAttributeGroups =
          AvailableAttributeGroups.loadFromJSONString(response.body);
      return availableAttributeGroups.attributeGroups;
    } catch (e) {
      debugPrint('Error fetching attribute groups for $name: $e');
      return null;
    }
  }
}

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({
    super.key,
    this.project = PreferencesPageProjects.food,
  });

  final PreferencesPageProjects project;

  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  late final FoodPreferencesController _controller;
  late final PendingPreferences _pendingPreferences;

  List<AttributeGroup>? _attributeGroups;
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttributeGroups();
  }

  Future<void> _loadAttributeGroups() async {
    setState(() {
      _isLoading = true;
    });

    // Try to fetch attribute groups for the specific project
    final List<AttributeGroup>? fetchedGroups = await widget.project
        .fetchAttributeGroups();

    if (fetchedGroups != null && fetchedGroups.isNotEmpty) {
      _attributeGroups = fetchedGroups;
    } else if (widget.project == PreferencesPageProjects.food) {
      // Fallback to ProductPreferences for foods project
      if (mounted) {
        final ProductPreferences productPreferences = context
            .read<ProductPreferences>();
        _attributeGroups = productPreferences.attributeGroups;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _initializeController();
    }
  }

  void _initializeController() {
    final UserPreferences userPreferences = context.read<UserPreferences>();

    if (_attributeGroups == null ||
        _attributeGroups!.isEmpty ||
        _isInitialized) {
      return;
    }

    _controller = FoodPreferencesController(
      attributeGroups: _attributeGroups!,
      showIntroduction: true,
      showSummary: true,
    )..addListener(_onControllerChanged);

    _pendingPreferences = PendingPreferences(
      userPreferences: userPreferences,
      attributeGroups: _attributeGroups!,
      project: widget.project,
    )..addListener(_onPendingPreferencesChanged);

    _isInitialized = true;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller
        ..removeListener(_onControllerChanged)
        ..dispose();
      _pendingPreferences
        ..removeListener(_onPendingPreferencesChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _onPendingPreferencesChanged() {
    setState(() {});
  }

  String _getPageTitle(AppLocalizations appLocalizations) {
    if (_controller.isIntroductionPage) {
      return appLocalizations.food_preferences_page_title_introduction;
    }

    if (_controller.isSummaryPage) {
      return appLocalizations.food_preferences_page_title_summary;
    }

    final AttributeGroup? currentGroup = _controller.currentAttributeGroup;
    if (currentGroup != null) {
      return currentGroup.name ?? currentGroup.id ?? '';
    }

    return '';
  }

  List<Widget> _buildPageWidgets() {
    final List<Widget> pages = <Widget>[];

    if (_controller.showIntroduction) {
      pages.add(IntroductionPage(attributeGroups: _controller.attributeGroups));
    }

    for (final AttributeGroup group in _controller.attributeGroups) {
      pages.add(AttributeGroupPage(attributeGroup: group));
    }

    if (_controller.showSummary) {
      pages.add(
        SummaryPage(
          onEditGroup: (int groupIndex) {
            final int pageIndex = _controller.getPageIndexForGroupIndex(
              groupIndex,
            );
            _controller.goToPage(pageIndex);
          },
        ),
      );
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // Show loading state while fetching attribute groups
    if (_isLoading) {
      return SmoothScaffold(
        appBar: SmoothTopBar2(
          title: appLocalizations.food_preferences_page_title_introduction,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state if attribute groups failed to load
    if (!_isInitialized) {
      return SmoothScaffold(
        appBar: SmoothTopBar2(
          title: appLocalizations.food_preferences_page_title_introduction,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                appLocalizations.food_preferences_error_loading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MEDIUM_SPACE),
              ElevatedButton(
                onPressed: _loadAttributeGroups,
                child: Text(appLocalizations.retry_button_label),
              ),
            ],
          ),
        ),
      );
    }

    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final bool isSummaryPage = _controller.isSummaryPage;
    final Color headerColor = isSummaryPage
        ? extension.success
        : extension.primaryMedium;
    final Color foregroundColor = isSummaryPage ? Colors.white : Colors.black;

    return ChangeNotifierProvider<PendingPreferences>.value(
      value: _pendingPreferences,
      child: SmoothScaffold(
        appBar: SmoothTopBar2(
          title: _getPageTitle(appLocalizations),
          forceMultiLines: true,
          backgroundColor: headerColor,
          foregroundColor: foregroundColor,
          elevationOnScroll: false,
          topWidget: PreferredSize(
            preferredSize: const Size(
              double.infinity,
              10.0 + SMALL_SPACE + VERY_SMALL_SPACE,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
                top: SMALL_SPACE,
                bottom: VERY_SMALL_SPACE,
              ),
              child: FAProgressBar(
                animatedDuration: SmoothAnimationsDuration.short,
                progressColor: isSummaryPage
                    ? Colors.white
                    : lightTheme
                    ? extension.primaryDark
                    : extension.primaryNormal,
                backgroundColor: isSummaryPage
                    ? Colors.white.withValues(alpha: 0.3)
                    : lightTheme
                    ? extension.primaryLight
                    : extension.primarySemiDark,
                currentValue: _controller.progress,
                maxValue: 1,
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _controller.pageController,
                  onPageChanged: _controller.onPageChanged,
                  children: _buildPageWidgets(),
                ),
              ),
              FoodPreferencesNavigationBar(
                isFirstPage: _controller.isFirstPage,
                isLastPage: _controller.isLastPage,
                isSummaryPage: _controller.isSummaryPage,
                onPrevious: _controller.previousPage,
                onNext: _controller.nextPage,
                onFinish: _onFinish,
                onLater: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onFinish() async {
    await _pendingPreferences.saveAll();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
