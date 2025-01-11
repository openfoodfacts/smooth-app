import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/pages/folksonomy/tag.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/themes/constant_icons.dart';

class FolksonomyCard extends StatelessWidget {
  const FolksonomyCard(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>(
      create: (_) => FolksonomyProvider(product.barcode!),
      child: _FolksonomyCard(product),
    );
  }
}

class _FolksonomyCard extends StatelessWidget {
  const _FolksonomyCard(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return InkWell(
      onTap: () async {
        if (!await ProductRefresher().checkIfLoggedIn(
          context,
          isLoggedInMandatory: true,
        )) {
          return;
        }
        if (!context.mounted) {
          return;
        }

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => FolksonomyPage(product),
          ),
        );
        if (context.mounted) {
          await Provider.of<FolksonomyProvider>(context, listen: false)
              .fetchProductTags();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: LARGE_SPACE),
        child: buildProductSmoothCard(
          title: Center(child: Text(appLocalizations.product_tags_title)),
          body: Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
            child: _FolksonomyCardList(),
          ),
        ),
      ),
    );
  }
}

class _FolksonomyCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final FolksonomyProvider provider = context.watch<FolksonomyProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    } else if (!provider.tagsExist) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                appLocalizations.no_product_tags_found_message,
                textAlign: TextAlign.center,
              ),
            ),
            Icon(ConstantIcons.forwardIcon),
          ],
        ),
      );
    } else {
      final Map<String, ProductTag> tags = provider.productTags!;
      final Iterable<MapEntry<String, ProductTag>> displayTags =
          tags.entries.toList(growable: false).take(5);

      return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: VERY_SMALL_SPACE,
          bottom: VERY_SMALL_SPACE,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      displayTags.map((MapEntry<String, ProductTag> entry) {
                    return Tag(
                        text:
                            '${entry.key}${appLocalizations.sep}: ${entry.value.value}');
                  }).toList(growable: false),
                ),
              ),
            ),
            Icon(ConstantIcons.forwardIcon),
          ],
        ),
      );
    }
  }
}
