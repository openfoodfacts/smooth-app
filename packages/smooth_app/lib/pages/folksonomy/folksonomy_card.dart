import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/pages/folksonomy/tag.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class FolksonomyCard extends StatelessWidget {
  const FolksonomyCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>(
      create: (_) => FolksonomyProvider(product.barcode!),
      child: Provider<Product>.value(
        value: product,
        child: const _FolksonomyCard(),
      ),
    );
  }
}

class _FolksonomyCard extends StatelessWidget {
  const _FolksonomyCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: LARGE_SPACE,
        start: SMALL_SPACE,
        end: SMALL_SPACE,
      ),
      child: buildProductSmoothCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        titlePadding: const EdgeInsetsDirectional.symmetric(
          horizontal: SMALL_SPACE,
        ),
        title: Row(
          children: <Widget>[
            Expanded(child: Text(appLocalizations.product_tags_title)),
            IconButton(
              onPressed: () =>
                  _openFolksonomyPage(context, context.read<Product>()),
              icon: Consumer<FolksonomyProvider>(
                builder:
                    (BuildContext context, FolksonomyProvider provider, _) {
                      Widget getIcon(List<ProductTag> tags) {
                        if (tags.isNotEmpty == true) {
                          return Tooltip(
                            message: appLocalizations.add_edit_tags,
                            child: const icons.Edit(size: 15.0),
                          );
                        } else {
                          return Tooltip(
                            message: appLocalizations.add_tags,
                            child: const icons.Add(),
                          );
                        }
                      }

                      return switch (provider.value) {
                        FolksonomyStateError(
                          action: final FolksonomyAction? action,
                        )
                            when action == null =>
                          EMPTY_WIDGET,
                        FolksonomyStateError(
                          tags: final List<ProductTag> tags,
                        ) =>
                          getIcon(tags),
                        FolksonomyStateLoaded(
                          tags: final List<ProductTag> tags,
                        ) =>
                          getIcon(tags),
                        FolksonomyStateAddedItem(
                          tags: final List<ProductTag> tags,
                        ) =>
                          getIcon(tags),
                        FolksonomyStateRemovedItem(
                          tags: final List<ProductTag> tags,
                        ) =>
                          getIcon(tags),
                        _ => EMPTY_WIDGET,
                      };
                    },
              ),
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
          child: _FolksonomyCardBody(
            onEmptyPageTag: () =>
                _openFolksonomyPage(context, context.read<Product>()),
          ),
        ),
      ),
    );
  }

  Future<void> _openFolksonomyPage(
    BuildContext context,
    Product product,
  ) async {
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
        builder: (BuildContext lContext) => FolksonomyPage(
          product: product,
          provider: context.read<FolksonomyProvider>(),
        ),
      ),
    );
    if (context.mounted) {
      await context.read<FolksonomyProvider>().fetchProductTags();
    }
  }
}

class _FolksonomyCardBody extends StatelessWidget {
  const _FolksonomyCardBody({required this.onEmptyPageTag});

  final VoidCallback onEmptyPageTag;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Consumer<FolksonomyProvider>(
      builder: (BuildContext context, FolksonomyProvider provider, _) {
        if (provider.value is FolksonomyStateLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (provider.value.tags?.isNotEmpty != true) {
          return InkWell(
            onTap: onEmptyPageTag,
            child: Center(
              child: Text(
                appLocalizations.no_product_tags_found_message,
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          final Iterable<ProductTag> displayTags = provider.value.tags!.take(5);

          return Padding(
            padding: const EdgeInsetsDirectional.only(
              top: VERY_SMALL_SPACE,
              bottom: VERY_SMALL_SPACE,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayTags
                        .map((ProductTag tag) {
                          return Tag(
                            text:
                                '${tag.key}${appLocalizations.sep}: ${tag.value}',
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
