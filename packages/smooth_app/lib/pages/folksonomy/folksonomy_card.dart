import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/pages/folksonomy/tag.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class FolksonomyCard extends StatelessWidget {
  const FolksonomyCard(this.product, {this.maxCount});

  final Product product;
  final int? maxCount;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>(
      create: (BuildContext context) =>
          FolksonomyProvider(product.barcode!, context.read<LocalDatabase>()),
      child: Provider<Product>.value(
        value: product,
        child: _FolksonomyCard(maxCount),
      ),
    );
  }
}

class _FolksonomyCard extends StatelessWidget {
  const _FolksonomyCard(this.maxCount);

  final int? maxCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
      child: ListView(
        padding: EdgeInsetsDirectional.zero,
        children: <Widget>[
          InkWell(
            onTap: () => _openFolksonomyPage(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  appLocalizations.product_tags_title,
                  style: const TextStyle(fontSize: 15.5),
                ),
                const _FolksonomyCardHeadIcon(),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.only(top: LARGE_SPACE),
            child: _FolksonomyCardBody(maxCount: maxCount),
          ),
        ],
      ),
    );
  }
}

Future<void> _openFolksonomyPage(BuildContext context) async {
  final Product product = context.read<Product>();
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

class _FolksonomyCardBody extends StatelessWidget {
  const _FolksonomyCardBody({required this.maxCount});

  final int? maxCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Consumer<FolksonomyProvider>(
      builder: (BuildContext context, FolksonomyProvider provider, _) {
        if (provider.value is FolksonomyStateLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (provider.value.tags?.isNotEmpty != true) {
          return InkWell(
            onTap: () async => _openFolksonomyPage(context),
            child: Text(appLocalizations.no_product_tags_found_message),
          );
        }
        final Iterable<ProductTag> displayTags;
        if (maxCount != null) {
          displayTags = provider.value.tags!.take(maxCount!);
        } else {
          displayTags = provider.value.tags!;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: displayTags
              .map((ProductTag tag) => Tag(productTag: tag))
              .toList(growable: false),
        );
      },
    );
  }
}

class _FolksonomyCardHeadIcon extends StatelessWidget {
  const _FolksonomyCardHeadIcon();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Consumer<FolksonomyProvider>(
      builder: (BuildContext context, FolksonomyProvider provider, _) {
        Widget getIcon(List<ProductTag> tags) {
          if (tags.isNotEmpty == true) {
            return Tooltip(
              message: appLocalizations.add_edit_tags,
              child: const icons.Edit(size: 15.0),
            );
          }
          return Tooltip(
            message: appLocalizations.add_tags,
            child: const icons.Add(),
          );
        }

        return switch (provider.value) {
          FolksonomyStateError(action: final FolksonomyAction? action)
              when action == null =>
            EMPTY_WIDGET,
          FolksonomyStateError(tags: final List<ProductTag> tags) => getIcon(
            tags,
          ),
          FolksonomyStateLoaded(tags: final List<ProductTag> tags) => getIcon(
            tags,
          ),
          FolksonomyStateAddedItem(tags: final List<ProductTag> tags) =>
            getIcon(tags),
          FolksonomyStateRemovedItem(tags: final List<ProductTag> tags) =>
            getIcon(tags),
          _ => EMPTY_WIDGET,
        };
      },
    );
  }
}
