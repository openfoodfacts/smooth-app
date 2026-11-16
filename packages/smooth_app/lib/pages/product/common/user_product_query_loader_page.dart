import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
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

        return const SmoothScaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        );
      },
    );
  }
}
