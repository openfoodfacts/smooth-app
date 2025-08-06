import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/query/category_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterCompareButton extends StatelessWidget {
  const ProductFooterCompareButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();

    const Set<String> blackListedCategories = <String>{'fr:vegan'};
    String? categoryTag;
    String? categoryLabel;
    final List<String>? labels =
        product.categoriesTagsInLanguages?[ProductQuery.getLanguage()];
    final List<String>? tags = product.categoriesTags;
    if (tags != null &&
        labels != null &&
        tags.isNotEmpty &&
        tags.length == labels.length) {
      categoryTag = product.comparedToCategory;
      if (categoryTag == null || blackListedCategories.contains(categoryTag)) {
        // fallback algorithm
        int index = tags.length - 1;
        // cf. https://github.com/openfoodfacts/openfoodfacts-dart/pull/474
        // looking for the most detailed non blacklisted category
        categoryTag = tags[index];
        while (blackListedCategories.contains(categoryTag) && index > 0) {
          index--;
          categoryTag = tags[index];
        }
      }
      if (categoryTag != null) {
        for (int i = 0; i < tags.length; i++) {
          if (categoryTag == tags[i]) {
            categoryLabel = labels[i];
          }
        }
      }
    }

    final bool enabled = categoryTag != null && categoryLabel != null;

    return ProductFooterButton(
      label: appLocalizations.product_search_same_category_short,
      semanticsLabel: appLocalizations.product_search_same_category,
      icon: enabled ? const icons.Compare() : const icons.Compare.disabled(),
      enabled: enabled,
      onTap: () => enabled
          ? _compareProduct(
              context: context,
              product: product,
              categoryLabel: categoryLabel!,
              categoryTag: categoryTag!,
            )
          : _showFeatureDisabledDialog(context),
    );
  }

  Future<void> _compareProduct({
    required BuildContext context,
    required Product product,
    required String categoryLabel,
    required String categoryTag,
  }) {
    return ProductQueryPageHelper.openBestChoice(
      name: categoryLabel,
      localDatabase: context.read<LocalDatabase>(),
      productQuery: CategoryProductQuery(
        categoryTag,
        productType: product.productType ?? ProductType.food,
      ),
      context: context,
      searchResult: false,
    );
  }

  void _showFeatureDisabledDialog(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SmoothFloatingSnackbar.error(
        context: context,
        text: appLocalizations.product_search_same_category_error,
        action: SnackBarAction(
          label: appLocalizations.okay,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
