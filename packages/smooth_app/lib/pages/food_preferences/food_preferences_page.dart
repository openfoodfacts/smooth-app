import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
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
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({super.key});

  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  late final FoodPreferencesController _controller;
  late final PendingPreferences _pendingPreferences;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeController();
  }

  void _initializeController() {
    final ProductPreferences productPreferences = context
        .watch<ProductPreferences>();
    final List<AttributeGroup>? attributeGroups =
        productPreferences.attributeGroups;

    if (attributeGroups == null || attributeGroups.isEmpty || _isInitialized) {
      return;
    }

    _controller = FoodPreferencesController(
      attributeGroups: attributeGroups,
      showIntroduction: true,
      showSummary: true,
    );
    _controller.addListener(_onControllerChanged);

    _pendingPreferences = PendingPreferences(
      productPreferences: productPreferences,
      attributeGroups: attributeGroups,
    );
    _pendingPreferences.addListener(_onPendingPreferencesChanged);

    _isInitialized = true;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.removeListener(_onControllerChanged);
      _controller.dispose();
      _pendingPreferences.removeListener(_onPendingPreferencesChanged);
      _pendingPreferences.dispose();
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

    // Show loading state while waiting for attribute groups
    if (!_isInitialized) {
      return SmoothScaffold(
        appBar: SmoothTopBar2(
          title: appLocalizations.food_preferences_page_title_introduction,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final ThemeData theme = Theme.of(context);

    final bool isSummaryPage = _controller.isSummaryPage;
    final Color headerColor = isSummaryPage
        ? Colors.green
        : theme.colorScheme.secondary;

    return ChangeNotifierProvider<PendingPreferences>.value(
      value: _pendingPreferences,
      child: SmoothScaffold(
        appBar: SmoothTopBar2(
          title: _getPageTitle(appLocalizations),
          forceMultiLines: true,
          backgroundColor: headerColor,
          foregroundColor: Colors.black,
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
                progressColor: lightTheme
                    ? extension.primaryDark
                    : extension.primaryNormal,
                backgroundColor: lightTheme
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
