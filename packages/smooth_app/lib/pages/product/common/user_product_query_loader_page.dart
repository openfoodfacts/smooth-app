import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Shows the products of the logged in user (eg: "Products I edited").
/// This page shouldn't be opened directly, it's only for deep links, as
/// the list is first looked up in the database.
class UserProductQueryLoaderPage extends StatefulWidget {
  const UserProductQueryLoaderPage({required this.type, super.key});

  final UserSearchType type;

  @override
  State<UserProductQueryLoaderPage> createState() =>
      _UserProductQueryLoaderPageState();
}

class _UserProductQueryLoaderPageState
    extends State<UserProductQueryLoaderPage> {
  Future<Widget>? _page;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _page ??= _loadPage();
  }

  Future<Widget> _loadPage() {
    return ProductQueryPageHelper.getBestChoiceWidget(
      productQuery: PagedUserProductQuery(
        userId: ProductQuery.getWriteUser().userId,
        type: widget.type,
        productType: ProductType.food,
      ),
      localDatabase: context.read<LocalDatabase>(),
      name: _getTitle(AppLocalizations.of(context)),
      context: context,
    );
  }

  void _retry() {
    setState(() => _page = _loadPage());
  }

  String _getTitle(AppLocalizations appLocalizations) => switch (widget.type) {
    UserSearchType.CONTRIBUTOR =>
      appLocalizations.user_search_contributor_title,
    UserSearchType.INFORMER => appLocalizations.user_search_informer_title,
    UserSearchType.PHOTOGRAPHER =>
      appLocalizations.user_search_photographer_title,
    UserSearchType.TO_BE_COMPLETED =>
      appLocalizations.user_search_to_be_completed_title,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _page,
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        final Widget? page = snapshot.data;

        if (page != null) {
          return page;
        }

        return SmoothScaffold(
          body: Center(
            // The previous error is kept until a retry completes
            child:
                snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done
                ? _UserProductQueryErrorState(onRetry: _retry)
                : const CircularProgressIndicator.adaptive(),
          ),
        );
      },
    );
  }
}

class _UserProductQueryErrorState extends StatelessWidget {
  const _UserProductQueryErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset('assets/misc/error.svg'),
          const SizedBox(height: VERY_LARGE_SPACE),
          Text(
            localizations.error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: VERY_LARGE_SPACE * 2),
          SmoothLargeButtonWithIcon(
            text: localizations.retry_button_label,
            leadingIcon: const Icon(Icons.sync),
            padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
