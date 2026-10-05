import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/prices/price_header_container.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// Page that displays the top prices users with infinite scrolling.
class PricesUsersPage extends StatefulWidget {
  const PricesUsersPage();

  @override
  State<PricesUsersPage> createState() => _PricesUsersPageState();
}

class _PricesUsersPageState extends State<PricesUsersPage>
    with TraceableClientMixin {
  final _InfiniteScrollUserManager _userManager = _InfiniteScrollUserManager();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothScaffold(
      backgroundColor: lightTheme ? extension.primaryLight : null,
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(appLocalizations.all_search_prices_top_user_title),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'users',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
          ),
        ],
      ),
      body: InfiniteScrollList<PriceUser>(manager: _userManager),
    );
  }
}

/// A manager for handling user data with infinite scrolling
class _InfiniteScrollUserManager extends InfiniteScrollManager<PriceUser> {
  static const int _pageSize = 20;

  @override
  Future<void> fetchData(final int pageNumber) async {
    final GetUsersParameters parameters = GetUsersParameters()
      ..orderBy = <OrderBy<GetUsersOrderField>>[
        const OrderBy<GetUsersOrderField>(
          field: GetUsersOrderField.priceCount,
          ascending: false,
        ),
      ]
      ..pageSize = _pageSize
      ..pageNumber = pageNumber;

    final MaybeError<GetUsersResult> result =
        await OpenPricesAPIClient.getUsers(
          parameters,
          uriHelper: ProductQuery.uriPricesHelper,
        );

    if (result.isError) {
      throw result.detailError;
    }

    final GetUsersResult value = result.value;
    updateItems(
      newItems: value.items,
      pageNumber: value.pageNumber,
      totalItems: value.total,
      totalPages: value.numberOfPages,
    );
  }

  @override
  Widget buildItem({required BuildContext context, required PriceUser item}) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothCard(
      elevation: 5.0,
      elevationColor: Colors.black26,
      margin: const EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        start: 8.0,
        end: 8.0,
      ),
      padding: EdgeInsetsDirectional.zero,
      color: lightTheme ? null : extension.primaryUltraBlack,
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: () async =>
            PriceUserButton.showUserPrices(user: item.userId, context: context),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: PriceHeaderContainer(
            placeholder: const icons.Profile(size: 32.0),
            line1: item.userId,
            count: item.priceCount,
            semanticsLabel: appLocalizations
                .prices_product_accessibility_summary(
                  item.priceCount ?? 0,
                  item.userId,
                ),
          ),
        ),
      ),
    );
  }

  @override
  String formattedItemCount(
    BuildContext context,
    int loadedItems,
    int? totalItems,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return totalItems != null
        ? appLocalizations.contributors_count_with_total(
            loadedItems,
            totalItems,
          )
        : appLocalizations.contributors_count(loadedItems);
  }

  @override
  Widget get emptyListIcon =>
      const SvgPicture(AssetBytesLoader('assets/icons/user_empty.svg.vec'));

  @override
  String emptyListTitle(AppLocalizations appLocalizations) =>
      appLocalizations.prices_users_empty_title;

  @override
  String emptyListExplanation(AppLocalizations appLocalizations) =>
      appLocalizations.prices_users_empty_explanation;
}
