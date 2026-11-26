import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_error_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/search_empty_screen.dart';
import 'package:smooth_app/pages/product/common/search_loading_screen.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Deep-link loader page that resolves a contributor's added products query.
class ContributorProductsLoaderPage extends StatefulWidget {
  const ContributorProductsLoaderPage({required this.userId, super.key})
    : assert(userId != '');

  final String userId;

  @override
  State<ContributorProductsLoaderPage> createState() =>
      _ContributorProductsLoaderPageState();
}

class _ContributorProductsLoaderPageState
    extends State<ContributorProductsLoaderPage> {
  Future<Widget>? _pageFuture;
  late String _title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pageFuture != null) {
      return;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    _title = widget.userId == ProductQuery.getWriteUser().userId
        ? appLocalizations.user_search_contributor_title
        : widget.userId;
    _pageFuture = ProductQueryPageHelper.getBestChoiceWidget(
      productQuery: PagedUserProductQuery(
        userId: widget.userId,
        type: UserSearchType.CONTRIBUTOR,
        productType: ProductType.food,
      ),
      localDatabase: localDatabase,
      name: _title,
      context: context,
      editableAppBarTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _pageFuture,
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        if (snapshot.hasError) {
          return SearchEmptyScreen(
            name: _title,
            emptiness: Padding(
              padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
              child: SmoothErrorCard(
                errorMessage: snapshot.error.toString(),
                tryAgainFunction: () {
                  setState(() {
                    _pageFuture = null;
                  });
                },
              ),
            ),
          );
        }
        return SearchLoadingScreen(title: _title);
      },
    );
  }
}
